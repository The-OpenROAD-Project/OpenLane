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
import os
import sys
import yaml
import argparse
from gh import gh

dependencies_path = os.path.join(gh.root, "dependencies")
metadata_path = os.path.join(dependencies_path, "tool_metadata.yml")

sys.path.append(dependencies_path)

from tool import Tool  # noqa E402

parser = argparse.ArgumentParser()
parser.add_argument("tools", nargs="+")
args = parser.parse_args()

tools = Tool.from_metadata_yaml(open(metadata_path).read())


# Handle Multiline Strings Properly / https://stackoverflow.com/a/33300001
def represent_str(dumper: yaml.Dumper, data: str):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, represent_str)
dump_options = {"sort_keys": False}

changes = False
for tool_name in args.tools:
    tool = tools[tool_name]

    repo = gh.Repo(tool_name, tool.repo)
    repo.commit = tool.commit

    print("Found %s@%s (latest: %s)." % (repo.url, repo.commit, repo.latest_commit))

    if repo.commit != repo.latest_commit:
        changes = True
        metadata_str = open(metadata_path).read()
        metadata = yaml.safe_load(metadata_str)
        for tool in metadata:
            if tool["name"] == tool_name:
                tool["commit"] = repo.latest_commit
        metadata_str = yaml.dump(metadata, **dump_options)
        with open(metadata_path, "w") as f:
            f.write(metadata_str)

        if len(args.tools) == 1:
            gh.export_env("TOOL_COMMIT_HASH", repo.latest_commit)
        else:
            gh.export_env(f"{tool_name.upper()}_COMMIT_HASH", repo.latest_commit)

gh.export_env("NO_UPDATE", "0" if changes else "1")
