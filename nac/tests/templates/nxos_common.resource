*** Settings ***
Library   pabot.PabotLib
Library   RequestsLibrary
Library   Collections
Library   OperatingSystem
Library   ./lib/UtilsLib.py

*** Keywords ***
{% for device in nxos.devices | default([]) %}
Get NXOS Token {{ device.name }}
    NXOS Login   {{ device.url }}
    ${cookies}=   NXOS Get Cookies   {{ device.url }}
    ${cookies_str}=   Evaluate   json.dumps($cookies)   json
    Set Parallel Value For Key With Retry   nxos_cookies_{{ device.name }}   ${cookies_str}

{% endfor %}
Login NXOS
    ${nxos_insecure}=   Get Environment Variable   NXOS_INSECURE   True
    ${verify}=   Set Variable If   '${nxos_insecure}' == 'True' or '${nxos_insecure}' == 'true'   False   True
{% for device in nxos.devices | default([]) %}
    Run Only Once With Retry   Get NXOS Token {{ device.name }}
    ${cookies_str}=   Get Parallel Value For Key With Retry   nxos_cookies_{{ device.name }}
    ${cookies}=   Evaluate   json.loads($cookies_str)   json
    ${cookie_header}=   Evaluate   "; ".join(f"{k}={v}" for k, v in $cookies.items())
    ${headers}=   Create Dictionary   Cookie=${cookie_header}
    Create Session   NXOS_{{ device.name }}   {{ device.url }}   headers=${headers}   verify=${verify}
{% endfor %}
