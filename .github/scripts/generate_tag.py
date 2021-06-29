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

new_tag = "NO_NEW_TAG"

print("Getting latest release index…")

lri = None
for tag in gh.openlane.tags:
    _, name = tag
    if "release-" in name:
        relevant_component = name.split("-")[1]
        lri = relevant_component.split(".")[0]

prefix = lri if lri is not None else "v0"

print("Using prefix %s, getting the latest tag…" % prefix)

latest_tag = "%s.0" % prefix # Base case: Will create prefix.1
latest_tag_commit = "dad497fccc1b48f4f16e570b0214b6f0e1fc2f9b" # Base case: First commit, always > 2
for tag in gh.openlane.tags:
    commit, name = tag
    if name.startswith(prefix):
        latest_tag = name
        latest_tag_commit = commit

commit_count = int(subprocess.check_output(["git", "rev-list", "--count", "%s..%s" % (latest_tag_commit, "HEAD")]))

if commit_count == 0:
    print("No new commits.")
    gh.export_env("NEW_TAG", "NO_NEW_TAG")
    exit(0)

new_tag = None
if not latest_tag.startswith("v"):
    new_tag = "%s.1" % prefix
    print("Last tag (%s) lacked a v, replacing with %s…" % (latest_tag, new_tag))
else:
    current = int(latest_tag.split(".")[1])
    new = current + 1 
    new_tag = "%s.%i" % (prefix, new)

print("Naming new tag %s." % new_tag)
gh.export_env("NEW_TAG", new_tag)