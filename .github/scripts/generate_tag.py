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
import datetime
import subprocess
from gh import gh

new_tag = "NO_NEW_TAG"

print("Getting latest release index…")

print("Getting the latest tag…")

latest_tag = None 
latest_tag_commit = None
for tag in gh.openlane.tags:
    commit, name = tag
    latest_tag = name
    latest_tag_commit = commit

commit_count = int(subprocess.check_output(["git", "rev-list", "--count", "%s..%s" % (latest_tag_commit, "HEAD")]))

if commit_count == 0:
    print("No new commits.")
    gh.export_env("NEW_TAG", "NO_NEW_TAG")
    exit(0)

now = datetime.datetime.now()

new_tag = now.strftime("%Y.%m.%d_%H.%M.%S")

print("Naming new tag %s." % new_tag)
gh.export_env("NEW_TAG", new_tag)