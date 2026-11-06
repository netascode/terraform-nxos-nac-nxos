# Copyright: (c) 2026, Daniel Schmidt <danischm@cisco.com>

import json
import os
import time

import jmespath
import requests
import urllib3

from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.Collections import Collections
from robot.utils import is_truthy

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

__version__ = "0.1.0"


class UtilsLib:
    ROBOT_LIBRARY_VERSION = __version__
    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    GET_RETRIES = 6
    TRANSIENT_STATUS_CODES = (429, 502, 503, 504)

    def __init__(self):
        self.BuiltIn = BuiltIn()
        self.Collections = Collections()
        self._cookies = {}
        self._unsupported_classes = {}

    def _get_verify(self):
        """Return TLS verify setting from NXOS_INSECURE env var."""
        insecure = os.environ.get("NXOS_INSECURE", "True")
        return not is_truthy(insecure)

    @keyword("NXOS Login")
    def nxos_login(self, url):
        """
        Authenticate to a NXOS device via /api/aaaLogin.json.

        Performs up to 6 retries with 10s intervals (matching the original
        Wait Until Keyword Succeeds  6x  10s pattern).
        """
        username = os.environ.get("NXOS_USERNAME")
        password = os.environ.get("NXOS_PASSWORD")
        verify = self._get_verify()
        payload = json.dumps(
            {"aaaUser": {"attributes": {"name": username, "pwd": password}}}
        )

        last_error = None
        for attempt in range(6):
            try:
                response = requests.post(
                    f"{url}/api/aaaLogin.json",
                    data=payload,
                    verify=verify,
                    timeout=60,
                )
                response.raise_for_status()
                data = response.json()
                token = jmespath.search(
                    "imdata[0].aaaLogin.attributes.token", data
                )
                if token:
                    self._cookies[url] = dict(response.cookies)
                    return token
                raise RuntimeError("Token not found in login response")
            except Exception as e:
                last_error = e
                logger.debug(
                    f"NXOS login attempt {attempt + 1}/6 failed: {e}"
                )
                if attempt < 5:
                    time.sleep(10)

        raise RuntimeError(f"NXOS login failed after 6 attempts: {last_error}")

    @keyword("NXOS Get Cookies")
    def nxos_get_cookies(self, url):
        """Return cookies captured during login for a device URL."""
        return self._cookies.get(url, {})

    @keyword("NXOS Get Subtree")
    def nxos_get_subtree(self, alias, url, classes=""):
        """
        Read an object including its subtree, restricted to the given
        comma-separated child classes, and return the JSON response.

        Classes the device reports as unknown (e.g. classes introduced in a
        later NX-OS release) are omitted and remembered for subsequent reads,
        matching the behavior of the Terraform provider. NX-OS only reports the
        first unknown class, e.g.
        {"imdata":[{"error":{"attributes":{"code":"17","text":"Unknown class esgMatchVlanInterface"}}}]}
        """
        requests_lib = self.BuiltIn.get_library_instance("RequestsLibrary")
        unsupported = self._unsupported_classes.setdefault(alias, set())
        classes = [c for c in classes.split(",") if c and c not in unsupported]
        attempt = 0
        while True:
            params = {"rsp-subtree": "no"}
            if classes:
                params = {"rsp-subtree": "full", "rsp-subtree-class": ",".join(classes)}
            response = requests_lib.get_on_session(
                alias, url, params=params, expected_status="anything"
            )
            # NX-API (nginx) returns 503 when overloaded by many parallel requests
            if (
                response.status_code in self.TRANSIENT_STATUS_CODES
                and attempt < self.GET_RETRIES
            ):
                attempt += 1
                delay = min(2**attempt, 30)
                logger.debug(
                    f"GET {url} returned {response.status_code} (attempt {attempt}/{self.GET_RETRIES}), retrying in {delay}s"
                )
                time.sleep(delay)
                continue
            if response.status_code == 200:
                return response.json()
            try:
                error = response.json()["imdata"][0]["error"]["attributes"]
            except (ValueError, KeyError, IndexError, TypeError):
                error = {}
            text = error.get("text", "")
            unknown_class = text.removeprefix("Unknown class ")
            if (
                error.get("code") != "17"
                or unknown_class == text
                or unknown_class not in classes
            ):
                response.raise_for_status()
                raise RuntimeError(
                    f"Unexpected response {response.status_code}: {response.text}"
                )
            logger.warn(
                f"Class {unknown_class} is not supported by device {alias}, ignoring it"
            )
            unsupported.add(unknown_class)
            classes.remove(unknown_class)

    # --- Pabot keywords with retries ---
    #
    # The PabotLib remote server is single-threaded with a listen backlog of 5
    # and every call opens a new connection. When many pabot processes start at
    # once, connections are reset ("[Errno 54] Connection reset by peer").
    # PabotLib raises a RuntimeError in that case and reconnects on the next
    # call, so the calls below are retried.

    PABOT_RETRIES = 5
    PABOT_RETRY_DELAY = 1

    def _pabot_call(self, method, *args):
        for attempt in range(1, self.PABOT_RETRIES + 1):
            try:
                return method(*args)
            except RuntimeError as e:
                if attempt == self.PABOT_RETRIES:
                    raise
                logger.warn(
                    f"PabotLib call {method.__name__} failed (attempt {attempt}/{self.PABOT_RETRIES}), retrying: {e}"
                )
                time.sleep(self.PABOT_RETRY_DELAY)

    @keyword("Run Only Once With Retry")
    def run_only_once_with_retry(self, name, *args):
        """
        Same as PabotLib 'Run Only Once', but retries calls to the PabotLib
        server. Unlike 'Run Only Once', the keyword is only marked as failed
        for other processes if the keyword itself fails, not if a call to the
        PabotLib server fails.
        """
        pabot = self.BuiltIn.get_library_instance("pabot.PabotLib")
        lock_name = f"pabot_run_only_once_with_retry_{name}_{args}"
        self._pabot_call(pabot.acquire_lock, lock_name)
        try:
            status = self._pabot_call(pabot.get_parallel_value_for_key, lock_name)
            if status == "FAILED":
                raise AssertionError("Keyword failed in other process")
            if status == "PASSED":
                logger.info("Skipped in this item")
                return
            try:
                self.BuiltIn.run_keyword(name, *args)
            except Exception:
                self._pabot_call(pabot.set_parallel_value_for_key, lock_name, "FAILED")
                raise
            self._pabot_call(pabot.set_parallel_value_for_key, lock_name, "PASSED")
        finally:
            self._pabot_call(pabot.release_lock, lock_name)

    @keyword("Get Parallel Value For Key With Retry")
    def get_parallel_value_for_key_with_retry(self, key):
        """Same as PabotLib 'Get Parallel Value For Key', with retries."""
        pabot = self.BuiltIn.get_library_instance("pabot.PabotLib")
        return self._pabot_call(pabot.get_parallel_value_for_key, key)

    @keyword("Set Parallel Value For Key With Retry")
    def set_parallel_value_for_key_with_retry(self, key, value):
        """Same as PabotLib 'Set Parallel Value For Key', with retries."""
        pabot = self.BuiltIn.get_library_instance("pabot.PabotLib")
        self._pabot_call(pabot.set_parallel_value_for_key, key, value)

    # --- JMESPath assertion keywords ---

    def _jmespath_search(self, data, expression):
        """Execute a JMESPath query and return the raw result."""
        try:
            return jmespath.search(expression, data)
        except Exception as e:
            raise RuntimeError(
                f"JMESPath query failed: {expression}\nError: {str(e)}"
            )

    @keyword("Should Be Equal Value Json String")
    def should_be_equal_value_json_string(self, json_data, json_path, value=""):
        if not value:
            return
        r_value = self._jmespath_search(json_data, json_path)
        if r_value is None:
            r_value = ""
        elif isinstance(r_value, list):
            r_value = str(r_value[0]) if r_value else ""
        else:
            r_value = str(r_value)
        self.BuiltIn.should_be_equal_as_strings(r_value, value)

    @keyword("Should Be Equal Value Json List")
    def should_be_equal_value_json_list(self, json_data, json_path, value=None):
        if value is None:
            return
        r_value = self._jmespath_search(json_data, json_path)
        if r_value is None:
            r_value = []
        elif not isinstance(r_value, list):
            r_value = [r_value]
        self.Collections.lists_should_be_equal(
            r_value, value, ignore_order=True
        )

    @keyword("Should Be Equal Value Json Bool")
    def should_be_equal_value_json_bool(self, json_data, json_path, value=""):
        if not value:
            return
        r_value = self._jmespath_search(json_data, json_path)
        if r_value is None:
            r_value = ""
        elif isinstance(r_value, list):
            r_value = str(r_value[0]) if r_value else ""
        else:
            r_value = str(r_value)
        # Normalize NX-OS yes/no/enable/disable to true/false for comparison
        bool_map = {"yes": "true", "no": "false", "enable": "true", "disable": "false", "enabled": "true", "disabled": "false"}
        r_value = bool_map.get(r_value.lower(), r_value.lower())
        value = bool_map.get(str(value).lower(), str(value).lower())
        self.BuiltIn.should_be_equal_as_strings(r_value, value)

    @keyword("Should Be Equal Value Json Numeric")
    def should_be_equal_value_json_numeric(self, json_data, json_path, value=""):
        if not value:
            return
        r_value = self._jmespath_search(json_data, json_path)
        if r_value is None:
            raise AssertionError(
                f"JMESPath query returned None for: {json_path}"
            )
        if isinstance(r_value, list):
            r_value = r_value[0] if r_value else None
        if r_value is None:
            raise AssertionError(
                f"JMESPath query returned empty list for: {json_path}"
            )
        self.BuiltIn.should_be_equal_as_numbers(r_value, value)
