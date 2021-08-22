#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2021 Efabless Corporation
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
import re
import sys
import pathlib
from os.path import dirname, abspath, join

try:
    import yaml
except:
    # If YAML doesn't exist, there is 100% a version mismatch.
    print(f"Environment does not support yaml manifest comparison.", file=sys.stderr)
    print(f"What this likely means is that your environment is very out of date.", file=sys.stderr)
    exit(os.EX_CONFIG)


EX_OK = os.EX_OK
EX_MISMATCH = 1

openlane_dir = abspath(dirname(dirname(__file__)))

# 1. Load Current Flow Script Manifest
manifest = None
try:
   flow_script_manifest_path = join(openlane_dir, "dependencies", "tool_metadata.yml")
   manifest = yaml.safe_load(open(flow_script_manifest_path))
except FileNotFoundError:
    raise Exception("Flow script tool manifest not found. This is a fatal error.")

manifest_dict = { element['name']: element for element in manifest }
mismatches = False

try:
    # 2. Check if the Sky130 PDK is compatible with Flow Scripts
    if not os.getenv("PDK_ROOT"):
        raise Exception("Environment variable PDK_ROOT is not set.")

    pdk_root = os.environ["PDK_ROOT"]
    sky130_dir = join(pdk_root, "sky130A")

    if pathlib.Path(sky130_dir).is_dir():
        sources_file = join(sky130_dir, "SOURCES")

        sources_str = None
        try:
            sources_str = open(sources_file).read()
        except FileNotFoundError:
            raise Exception("Could not find SOURCES file for sky130A.")

        sources_lines = list(filter(lambda x: x, open(sources_file).read().split("\n")))
        entries = len(sources_lines) // 2

        manifest_names = {
            "open_pdks": "open_pdks",
            "skywater": "sky130"
        }

        name_rx = re.compile(r"\-ne\s+(\w+)")
        for entry in range(entries):
            name_line = sources_lines[entry * 2]
            commit_line = sources_lines[entry * 2 + 1]
            
            name_data = name_rx.match(name_line)
            if name_data is None:
                raise Exception(f"Malformed sky130A SOURCES file: {name_line} did not match regex.")

            name = name_data[1]
            commit = commit_line.strip()

            manifest_name = manifest_names.get(name)
            if manifest_name is None:
                continue
            manifest_commit = manifest_dict[manifest_name]["commit"]
            
            if commit != manifest_commit:
                mismatches = True
                print(f"The version of {manifest_name} installed does not match the one required by the OpenLane flow scripts (installed: {commit}, expected: {manifest_commit})", file=sys.stderr)
                print(f"You may want to re-install the PDK by invoking `make pdk`.", file=sys.stderr)
except Exception as e:
    print("Failed to compare PDKS", file=sys.stderr)
    print(e, file=sys.stderr)
    exit(os.EX_CONFIG)

installed_versions_path = join(openlane_dir, "build", "versions")
installed = pathlib.Path(installed_versions_path).is_dir()
environment_manifest = None
if installed:
    # 3a. Compare with installed versions
    environment_manifest = []
    for tool in os.listdir(installed_versions_path):
        protocol, url, commit = open(join(installed_versions_path, tool)).read().split(':')
        repo = f"{protocol}:{url}"
        environment_manifest.append({
            "name": tool,
            "repo": repo,
            "commit": commit
        })
else: 
    # 3b. Compare Container And Installation Manifests
    try:
        container_manifest_path = join("/", "tool_metadata.yml")
        environment_manifest = yaml.safe_load(open(container_manifest_path))
    except FileNotFoundError:
        raise Exception("Container manifest not found. What this likely means is that the container is severely out of date.")

tool_set_flow = set([element['name'] for element in manifest])
tool_set_container = set([element['name'] for element in environment_manifest])

unmatched_tools_flow = tool_set_flow - tool_set_container
for tool in unmatched_tools_flow:
    tool_object = manifest_dict[tool]
    if tool_object.get("in_container") is not None and not tool_object["in_container"]:
        continue
    if installed and tool_object.get("in_install") is not None and not tool_object["in_install"]:
        continue
    print(f"Tool {tool} is required by the flow scripts being used, but appears to not be installed in the environment.", file=sys.stderr)
    mismatches = True

unmatched_tools_container = tool_set_container - tool_set_flow
for tool in unmatched_tools_container:
    print(f"Tool {tool} is installed in the environment, but has no corresponding entry in the flow scripts.", file=sys.stderr)
    mismatches = True

for tool in environment_manifest:
    flow_script_counterpart = manifest_dict.get(tool["name"])
    if flow_script_counterpart is None:
        continue
    container_commit = tool['commit']
    flow_script_commit = flow_script_counterpart['commit']
    if container_commit != flow_script_commit:
        print(f"The version of {tool['name']} installed in the environment does not match the one required by the OpenLane flow scripts (installed: {container_commit}, expected: {flow_script_commit})")
        mismatches = True
            
if mismatches:
    exit(EX_MISMATCH)
else:
    exit(EX_OK)
