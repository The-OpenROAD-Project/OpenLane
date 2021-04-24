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

def git(cmd, check=True, **kwargs):
    subprocess.run(
        ["git"] + cmd,
        check=check,
        **kwargs
    )

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

if commit_count < 2:
    print("Only %i out of 2 new commits required for a new tag." % commit_count)
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

BRANCH_NAME="create-pull-request/green-tag-update"
print("Checking out to a new branch…")
git(["branch", "-D", BRANCH_NAME], check=False) # Ignore failure if branch doesn't exist.
git([
    "checkout",
    "-b",
    BRANCH_NAME
])

old_tag_rx = r"^\s*IMAGE_NAME\s*\?=\s*efabless\/openlane\:([^\s]+?)\s*$"

mf = open("Makefile").read()
old_tag = None
for line in mf.split("\n"):
    match = re.match(old_tag_rx, line)
    if match is not None:
        old_tag = match[1]

print("""\
Latest Tag: {lt}
Old Tag: {ot}
New Tag: {nt}
""".format(lt=latest_tag, ot=old_tag, nt=new_tag))

print("Updating tag in referenced documentation and Makefiles…")
for file in ["Makefile", "docker_build/Makefile", "README.md"]:
    file_str = open(file).read()
    file_str_new = re.sub(old_tag, new_tag, file_str)
    with open(file, 'w') as f:
        f.write(file_str_new)
    git(["add", file])

git([
    "commit",
    "-m",
    "Update latest green tag to %s" % new_tag
])

print("Pushing commits and tags to GitHub…")
git([
    "push", "--force",
    "--set-upstream", "origin",
    "create-pull-request/green-tag-update"
], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
git([
    "push",
    "--set-upstream", "origin",
    "--tags"
], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

print("Done.")