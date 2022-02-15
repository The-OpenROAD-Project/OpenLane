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
import traceback
from os.path import dirname, abspath, join

try:
    import yaml
except ImportError:
    # If YAML doesn't exist, there is 100% a version mismatch.
    print("Environment does not support yaml manifest comparison.", file=sys.stderr)
    print(
        "What this likely means is that your environment is very out of date.",
        file=sys.stderr,
    )
    exit(os.EX_CONFIG)

openlane_dir = abspath(dirname(dirname(__file__)))


def verify_versions(no_tools: bool = False, report_file=sys.stderr):
    # 1. Load Current Flow Script Manifest
    manifest = None
    try:
        flow_script_manifest_path = join(
            openlane_dir, "dependencies", "tool_metadata.yml"
        )
        manifest = yaml.safe_load(open(flow_script_manifest_path))
    except FileNotFoundError:
        raise Exception(
            "Flow script tool manifest not found. This is a fatal error."
        )  # Is this even possible?

    manifest_dict = {element["name"]: element for element in manifest}
    mismatches = False

    manifest_names_by_SOURCES_name = {
        "open_pdks": "open_pdks",
        "skywater": "sky130",
        "magic": "magic",
    }
    pdk_manifest_names = set(manifest_names_by_SOURCES_name.values())

    try:
        # 2. Check if the Sky130 PDK is compatible with Flow Scripts
        pdk_root = os.getenv("PDK_ROOT")
        if not os.getenv("PDK_ROOT"):
            pdk_root = join(openlane_dir, "pdks")

        sky130_dir = join(pdk_root, "sky130A")

        if pathlib.Path(sky130_dir).is_dir():
            sources_file = join(sky130_dir, "SOURCES")

            sources_str = None
            try:
                sources_str = open(sources_file).read()
            except FileNotFoundError:
                raise Exception(
                    "Could not find SOURCES file for the installed sky130A PDK."
                )

            sources_str = sources_str.strip()

            sources_lines = list(filter(lambda x: x, sources_str.split("\n")))

            # Format: {tool} {commit}

            if sources_str.startswith("-ne"):
                # Broken file on BSD/macOS where echo -ne is not a thing
                # Solution: Translate to proper format
                #
                # Format:
                # -ne {tool}
                # {commit}

                entries = len(sources_lines) // 2
                name_rx = re.compile(r"\-ne\s+([\w\-]+)")

                new_sources_lines = []

                for entry in range(entries):
                    name_line = sources_lines[entry * 2]
                    commit_line = sources_lines[entry * 2 + 1]

                    name_data = name_rx.match(name_line)
                    if name_data is None:
                        raise Exception(
                            f"Malformed sky130A SOURCES file: {name_line} did not match regex."
                        )

                    name = name_data[1]
                    commit = commit_line.strip()

                    new_sources_lines.append(f"{name} {commit}")

                sources_lines = new_sources_lines

            name_rx = re.compile(r"([\w\-]+)\s+(\w+)")
            for line in sources_lines:
                match = name_rx.match(line)
                if match is None:
                    raise Exception(
                        f"Malformed sky130A SOURCES file: {line} did not match regex."
                    )
                name = match[1]
                commit = match[2]

                manifest_name = manifest_names_by_SOURCES_name.get(name)
                if manifest_name is None:
                    continue
                manifest_commit = manifest_dict[manifest_name]["commit"]

                if commit != manifest_commit:
                    mismatches = True
                    print(
                        f"The version of {manifest_name} used in building PDK does not match the version OpenLane was tested on (installed: {commit}, tested: {manifest_commit})",
                        file=report_file,
                    )
                    print(
                        "This may introduce some issues. You may want to re-install the PDK by invoking `make pdk`.",
                        file=report_file,
                    )

                pdk_manifest_names.add(manifest_name)
        else:
            raise Exception(f"{sky130_dir} not found.")
    except Exception as e:
        print(e, file=report_file)
        print(traceback.format_exc(), file=report_file)
        raise Exception("Failed to compare PDKs.")

    if no_tools:
        return mismatches

    installed = os.getenv("OPENLANE_LOCAL_INSTALL") == "1"
    environment_manifest = None
    if installed:
        # 3a. Compare with installed versions
        installed_versions_path = join(
            os.environ["OL_INSTALL_DIR"], "build", "versions"
        )
        environment_manifest = []
        for tool in os.listdir(installed_versions_path):
            protocol, url, commit = (
                open(join(installed_versions_path, tool)).read().split(":")
            )
            repo = f"{protocol}:{url}"
            environment_manifest.append({"name": tool, "repo": repo, "commit": commit})
    else:
        # 3b. Compare Container And Installation Manifests
        try:
            container_manifest_path = join("/", "tool_metadata.yml")
            environment_manifest = yaml.safe_load(open(container_manifest_path))
        except FileNotFoundError:
            raise Exception(
                "Container manifest not found. What this likely means is that the container is severely out of date."
            )

    tool_set_flow = set([element["name"] for element in manifest]) - pdk_manifest_names
    tool_set_container = (
        set([element["name"] for element in environment_manifest]) - pdk_manifest_names
    )

    unmatched_tools_flow = tool_set_flow - tool_set_container
    for tool in unmatched_tools_flow:
        tool_object = manifest_dict[tool]
        if (
            tool_object.get("in_container") is not None
            and not tool_object["in_container"]
        ):
            continue
        if (
            installed
            and tool_object.get("in_install") is not None
            and not tool_object["in_install"]
        ):
            continue
        print(
            f"Tool {tool} is required by the flow scripts being used, but appears to not be installed in the environment.",
            file=report_file,
        )
        mismatches = True

    unmatched_tools_container = tool_set_container - tool_set_flow
    for tool in unmatched_tools_container:
        print(
            f"Tool {tool} is installed in the environment, but has no corresponding entry in the flow scripts.",
            file=report_file,
        )
        mismatches = True

    for tool in environment_manifest:
        if tool["name"] in pdk_manifest_names:
            continue  # PDK Stuff Already Checked
        flow_script_counterpart = manifest_dict.get(tool["name"])
        if flow_script_counterpart is None:
            continue
        container_commit = tool["commit"]
        flow_script_commit = flow_script_counterpart["commit"]
        if container_commit != flow_script_commit:
            print(
                f"The version of {tool['name']} installed in the environment does not match the one required by the OpenLane flow scripts (installed: {container_commit}, expected: {flow_script_commit})",
                file=report_file,
            )
            mismatches = True

    return mismatches


if __name__ == "__main__":
    try:
        mismatches = verify_versions(no_tools=False)
        sys.exit(os.EX_CONFIG if mismatches else os.EX_OK)
    except Exception as e:
        print(f"{e}")
        sys.exit(os.EX_UNAVAILABLE)
