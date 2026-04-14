#!/usr/bin/env python3

# Copyright © 2026 Cisco Systems, Inc. and its affiliates.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

"""Changelog fragment collector.

Usage:
    python3 scripts/changelog.py preview
    python3 scripts/changelog.py release <version>
"""

import os
import sys

FRAGMENT_DIR = ".changelog"
CHANGELOG_FILE = "CHANGELOG.md"


def read_fragments():
    """Read all .md files from the fragment directory (excluding README.md),
    collect lines starting with '- ', and return them sorted by source filename."""
    if not os.path.isdir(FRAGMENT_DIR):
        return []

    filenames = sorted(
        name
        for name in os.listdir(FRAGMENT_DIR)
        if name.endswith(".md")
        and name.upper() != "README.MD"
        and os.path.isfile(os.path.join(FRAGMENT_DIR, name))
    )

    lines = []
    for name in filenames:
        content = open(os.path.join(FRAGMENT_DIR, name)).read().strip()
        for line in content.splitlines():
            line = line.rstrip()
            if line.startswith("- "):
                lines.append(line)
    return lines


def preview():
    entries = read_fragments()
    if not entries:
        print("No changelog fragments found.")
        return
    print("## Unreleased\n")
    for entry in entries:
        print(entry)


def release(version):
    entries = read_fragments()
    if not entries:
        print("No changelog fragments found in .changelog/", file=sys.stderr)
        sys.exit(1)

    existing = ""
    if os.path.isfile(CHANGELOG_FILE):
        existing = open(CHANGELOG_FILE).read().lstrip("\n")

    new_section = f"## {version}\n\n" + "\n".join(entries) + "\n\n"
    open(CHANGELOG_FILE, "w").write(new_section + existing)

    # Delete fragment files
    for name in os.listdir(FRAGMENT_DIR):
        path = os.path.join(FRAGMENT_DIR, name)
        if (
            name.endswith(".md")
            and name.upper() != "README.MD"
            and os.path.isfile(path)
        ):
            os.remove(path)

    print(
        f"Released {version}: {len(entries)} entries added to {CHANGELOG_FILE}, fragments deleted."
    )


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/changelog.py <preview|release> [version]", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]
    if command == "preview":
        preview()
    elif command == "release":
        if len(sys.argv) < 3:
            print("Usage: python3 scripts/changelog.py release <version>", file=sys.stderr)
            sys.exit(1)
        release(sys.argv[2])
    else:
        print(f"Unknown command: {command} (expected 'preview' or 'release')", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
