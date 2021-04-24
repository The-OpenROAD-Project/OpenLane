#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import re
import os
import subprocess
from gh import gh
from update_common import process_update_on_repos

makefile = os.path.join(gh.root, "Makefile")
documentation = os.path.join(gh.root, "docs", "source", "Manual_PDK_installation.md")
print("Reading Makefile…")

skywater = gh.Repo(
    "Skywater PDK",
    "https://github.com/google/skywater-pdk.git",
    r"refs/heads/CID\-latest\-pdk(?:\-(\w+)-(?:\w+))?",
    r"SKYWATER_COMMIT\s*\?=\s*(\w+)"
)

open_pdks = gh.Repo(
    "Open PDKs",
    "https://github.com/rtimothyedwards/open_pdks",
    r"refs/heads/CID\-latest\-pdk(?:\-(?:\w+)-(\w+))?",
    r"OPEN_PDKS_COMMIT\s*\?=\s*(\w+)"
)

with open(makefile) as f:
    for line in f:
        skywater.commit = skywater.match_line(line) or skywater.commit
        open_pdks.commit = open_pdks.match_line(line) or open_pdks.commit

print("Found %s:%s. (latest: %s)" % (skywater.url, skywater.commit, skywater.latest_commit))
print("Found %s:%s. (latest: %s)" % (open_pdks.url, open_pdks.commit, open_pdks.latest_commit))

changed = process_update_on_repos([skywater, open_pdks], [makefile, documentation])
gh.export_env("SKYWATER_COMMIT_HASH", skywater.latest_commit)
gh.export_env("OPEN_PDKS_COMMIT_HASH", open_pdks.latest_commit)
gh.export_env("NO_UPDATE", "false" if changed else "true")