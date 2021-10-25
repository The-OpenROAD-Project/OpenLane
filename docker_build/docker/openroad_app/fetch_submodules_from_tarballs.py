#!/usr/bin/env python3
# Copyright 2020-2021 Efabless Corporation
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
# gitmodules = open(".gitmodules").read()
import re
import os
import sys
import json
import shutil
import pathlib
import tempfile
import subprocess
import urllib.parse

"""
Must be run from inside an extracted repository tarball.

Given the repository's URL and commit, which are available, a table of the
git submodules with their repositories, commits and paths is constructed and
then promptly downloaded and extracted using only the GitHub APIs (and curl),
no git involved.

This makes things much faster than having to clone an repo's entire history then
its submodule's entire history.
"""

args = sys.argv[1:]

if len(args) != 2:
    print(f"Usage: {__file__} <repository> <commit>", file=sys.stderr)
    exit(os.EX_USAGE)

repository, commit = args

repository_path_info: urllib.parse.SplitResult = urllib.parse.urlsplit(repository)

# 1. Get Commits Of Submodules
api_result = None

try:
    api_result = subprocess.check_output([
        "curl",
        "--fail",
        "-s",
        "-L",
        "-H", "Accept: application/vnd.github.v3+json",
        f"https://api.github.com/repos{repository_path_info.path}/git/trees/{commit}?recursive=True"
    ])
except Exception as e:
    print(e, file=sys.stderr)
    sys.exit(os.EX_DATAERR)

api_result_parsed = json.loads(api_result)
api_result_tree = api_result_parsed["tree"]
submodules = [element for element in api_result_tree if element['type'] == 'commit']
shas_by_path = { submodule['path']: submodule['sha'] for submodule in submodules }

# 2. Get Submodule Manifest
api_result = None

try:
    api_result = subprocess.check_output([
        "curl",
        "--fail",
        "-s",
        "-L",
        f"https://raw.githubusercontent.com/{repository_path_info.path}/{commit}/.gitmodules"
    ])
except Exception as e:
    print(e, file=sys.stderr)
    sys.exit(os.EX_DATAERR)

gitmodules = api_result.decode("utf8")

section_line_rx = re.compile(r"\[\s*submodule\s+\"([\w\-\/]+)\"\]")
key_value_line_rx = re.compile(r"(\w+)\s*=\s*(.+)")

submodules_by_name = {}
current = {} # First one is discarded
for line in gitmodules.split("\n"):
    section_match = section_line_rx.search(line)
    if section_match is not None:
        name = section_match[1]
        submodules_by_name[name] = {}
        current = submodules_by_name[name]
    
    kvl_match = key_value_line_rx.search(line)
    if kvl_match is not None:
        key, value = kvl_match[1], kvl_match[2]
        current[key] = value

for name, submodule in submodules_by_name.items():
    submodule["commit"] = shas_by_path.get(submodule["path"])
    if submodule["url"].endswith(".git"):
        submodule["url"] = submodule["url"][:-4]

# 3. Extract Submodules
temp_dir = tempfile.gettempdir()
for (name, values) in submodules_by_name.items():
    name_fs = re.sub(r"\/", "_", name)
    tarball = os.path.join(temp_dir, f"{name_fs}.tar.gz")
    path = values["path"]
    url = values["url"]
    commit = values["commit"]

    url = os.path.join(url, "tarball", commit)

    print(f"Downloading {url} to {path}...", file=sys.stderr)
    subprocess.check_call([
        "curl", "-sL", "-o", tarball, url        
    ])

    shutil.rmtree(path, ignore_errors=True)
    
    pathlib.Path(path).mkdir(parents=True, exist_ok=True)
    
    subprocess.check_call([
        "tar", "-xzf", tarball, "--strip-components=1", "-C", path
    ])

