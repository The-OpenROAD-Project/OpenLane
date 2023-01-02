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
import io
import sys
import json
import pathlib
import traceback
import functools
from typing import Optional
from os.path import dirname, abspath, join

sys.path.append(os.path.dirname(__file__))
import includedyaml as yaml  # noqa: E402

openlane_dir = abspath(dirname(dirname(__file__)))


def verify_versions(
    no_pdks: bool = False,
    no_tools: bool = False,
    report_file: io.TextIOBase = sys.stderr,
    pdk: Optional[str] = os.getenv("PDK"),
):
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

    if not no_pdks and pdk is not None:
        try:
            # 2. Check if the PDK is compatible with Flow Scripts
            pdk_root = os.getenv("PDK_ROOT")
            if not os.getenv("PDK_ROOT"):
                pdk_root = join(openlane_dir, "pdks")

            if functools.reduce(
                lambda x, y: x or y,
                [pdk.startswith(prefix) for prefix in ["sky130", "gf180mcu"]],
            ):
                pdk_dir = join(pdk_root, pdk)

                if not pathlib.Path(pdk_dir).is_dir():
                    raise Exception(f"{pdk_dir} not found.")

                tool_versions = []

                sources_file = join(pdk_dir, "SOURCES")
                config_file = join(pdk_dir, ".config", "nodeinfo.json")

                if os.path.isfile(sources_file):
                    sources_str = None
                    try:
                        sources_str = open(sources_file).read()
                    except FileNotFoundError:
                        raise Exception(
                            f"Could not find SOURCES file for the installed {pdk} PDK."
                        )

                    sources_str = sources_str.strip()

                    # Format: {tool} {commit}
                    #
                    #   This regex also handles an issue where older versions used the
                    #   non-standard echo -ne command, where the format is -ne {tool}\n{commit}\n.
                    #
                    name_rx = re.compile(
                        r"(?:\-ne\s+)?([\w\-]+)\s+([A-Fa-f0-9]+)", re.MULTILINE
                    )

                    for tool_match in name_rx.finditer(sources_str):
                        name = tool_match[1]
                        commit = tool_match[2]

                        manifest_name = manifest_names_by_SOURCES_name.get(name)
                        if manifest_name is None:
                            continue

                        tool_versions.append((manifest_name, commit))
                elif os.path.isfile(config_file):
                    config_str = open(config_file).read()
                    try:
                        config = json.loads(config_str)
                        commit_set = config["commit"]
                        if type(commit_set) == str:
                            tool_versions.append(("open_pdks", commit_set))
                        else:
                            for key, value in commit_set.items():
                                # Handle bug in some older versions of opdks where the magic commit field is empty.
                                if value.strip() == "":
                                    continue
                                tool_versions.append((key, value))
                    except json.decoder.JSONDecodeError:
                        raise Exception("Malformed .config/nodeinfo.json.")

                else:
                    raise Exception(
                        "Neither SOURCES nor .config/nodeinfo.json exist in the PDK."
                    )

                for name, commit in tool_versions:
                    manifest_commit = manifest_dict[name]["commit"]

                    if commit != manifest_commit:
                        mismatches = True
                        print(
                            f"The version of {name} used in building the PDK does not match the version OpenLane was tested on (installed: {commit}, tested: {manifest_commit})",
                            file=report_file,
                        )
                        print(
                            "This may introduce some issues. You may want to re-install the PDK by invoking `make pdk`.",
                            file=report_file,
                        )

                    pdk_manifest_names.add(name)
        except Exception as e:
            print(e, file=report_file)
            print(traceback.format_exc(), file=report_file)
            raise Exception("Failed to compare PDKs.")

    if not no_tools:
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
                environment_manifest.append(
                    {"name": tool, "repo": repo, "commit": commit}
                )
        else:
            # 3b. Compare Container And Installation Manifests
            try:
                container_manifest_path = join("/", "tool_metadata.yml")
                environment_manifest = yaml.safe_load(open(container_manifest_path))
            except FileNotFoundError:
                raise Exception(
                    "Container manifest not found. What this likely means is that the container is severely out of date."
                )

        tool_set_flow = (
            set([element["name"] for element in manifest]) - pdk_manifest_names
        )
        tool_set_container = (
            set([element["name"] for element in environment_manifest])
            - pdk_manifest_names
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
        no_tools = False
        no_pdks = False
        mismatches = sys.argv[1]
        if mismatches == "none":
            no_tools = True
            no_pdks = True
        elif mismatches == "pdk":
            no_tools = True
        elif mismatches == "tools":
            no_pdks = True
        elif mismatches != "all":
            print(f"Unknown mismatch test '{mismatches}'.", file=sys.stderr)
            sys.exit(-1)
        mismatches = verify_versions(no_tools=no_tools, no_pdks=no_pdks)
        sys.exit(os.EX_CONFIG if mismatches else os.EX_OK)
    except Exception as e:
        print(f"{e}")
        sys.exit(os.EX_UNAVAILABLE)
