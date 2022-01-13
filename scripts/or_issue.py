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

"""
See <openlane_root>/docs/source/using_or_issue.md.

This script is intended for use by bug reporters and maintainers and is not part of the flow.
"""

import os
import re
import sys
import glob
import shutil
import pathlib
import argparse
from typing import List
from collections import deque
from os.path import join, abspath, dirname, basename, isdir, relpath

openlane_path = abspath(dirname(dirname(__file__)))

parser = argparse.ArgumentParser(description="OpenROAD Issue Packager")
parser.add_argument(
    "--or-script",
    "-s",
    required=True,
    help="Path to the OpenROAD script causing the failure: i.e. ./scripts/openroad/antenna_check.tcl, ./scripts/openroad/pdn.tcl, etc. [required]",
)
parser.add_argument(
    "--pdk-root",
    required=(os.getenv("PDK_ROOT") is None),
    default=os.getenv("PDK_ROOT"),
    help="Path to the PDK root [required if environment variable PDK_ROOT is not set]",
)
parser.add_argument(
    "--run-path",
    "-r",
    default=None,
    help="The run path. If not specified, the script will attempt to discern it from the input_def path.",
)
parser.add_argument(
    "--output",
    "-o",
    default="./out.def",
    help="Name of def file to be generated [default: ./out.def]",
)
parser.add_argument(
    "--verbose",
    action="store_true",
    default=False,
    help="Verbose output of all found environment variables.",
)
parser.add_argument(
    "--netlist",
    "-n",
    action="store_true",
    default=False,
    help="Use the netlist as an input instead of a def file. Useful for evaluating some scripts such as floorplan.tcl.",
)
parser.add_argument("--output-dir", default=None, help="Output to this directory.")
parser.add_argument(
    "input",
    help="Name of input into the OR script (usually denoted by environment variable CURRENT_NETLIST or CURRENT_DEF: get it from the logs) [required]",
)
args = parser.parse_args()

OPEN_SOURCE_PDKS = ["sky130A"]
print(
    """
or_issue.py OpenROAD Issue Packager

EFABLESS CORPORATION AND ALL AUTHORS OF THE OPENLANE PROJECT SHALL NOT BE HELD
LIABLE FOR ANY LEAKS THAT MAY OCCUR TO ANY PROPRIETARY DATA AS A RESULT OF USING
THIS SCRIPT. THIS SCRIPT IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND.

BY USING THIS SCRIPT, YOU ACKNOWLEDGE THAT YOU FULLY UNDERSTAND THIS DISCLAIMER
AND ALL IT ENTAILS.
""",
    file=sys.stderr,
)

script_path = abspath(args.or_script)
pdk_root = abspath(args.pdk_root)
or_scripts_path = join(openlane_path, "scripts", "openroad")
use_netlist = args.netlist
input_file = abspath(args.input)
run_path = None
if args.run_path is not None:
    run_path = abspath(args.run_path)
else:
    current_dir = dirname(input_file)
    while current_dir != "/":
        if "config.tcl" in os.listdir(current_dir):
            run_path = current_dir
            break
        current_dir = dirname(current_dir)

    if run_path is None:
        print(
            f"[ERR] No run path provided and {input_file} is not in the run path.",
            file=sys.stderr,
        )
        exit(os.EX_USAGE)
    else:
        print(f"[INF] Resolved run path to {run_path}.")

save_def = args.output
verbose = args.verbose

if not os.path.exists(input_file):
    print(f"[ERR] {input_file} not found.", file=sys.stderr)
    exit(os.EX_NOINPUT)

if not script_path.startswith(or_scripts_path):
    print(
        f"[ERR] The OpenROAD script {script_path} does not appear to be in {or_scripts_path}.",
        file=sys.stderr,
    )
    exit(os.EX_CONFIG)

if not os.path.exists(run_path) and os.path.isdir(run_path):
    print(f"[ERR] The run path {run_path} is not a valid folder.", file=sys.stderr)
    exit(os.EX_CONFIG)

run_name = basename(run_path)

# Phase 1: Read All Environment Variables
# pdk_config = join(args.pdk_root, "sky130A", "libs.tech", "openlane", "config.tcl")
print("Parsing config file(s)…", file=sys.stderr)
run_config = join(run_path, "config.tcl")

env = {}


def read_env(config_path: str, from_path: str, input_env={}) -> dict:
    rx = r"\s*set\s*::env\((.+?)\)\s*(.+)"
    env = input_env.copy()
    string_data = ""
    try:
        string_data = open(config_path).read()
    except FileNotFoundError:
        print(
            f"❌ File {config_path} not found. The path {from_path} may have been specified incorrectly.",
            file=sys.stderr,
        )
        exit(os.EX_NOINPUT)

    # Process \ at ends of lines, remove semicolons
    entries = string_data.split("\n")
    i = 0
    while i < len(entries):
        if not entries[i].endswith("\\"):
            if entries[i].endswith(";"):
                entries[i] = entries[i][:-1]
            i += 1
            continue
        entries[i] = entries[i][:-1] + entries[i + 1]
        del entries[i + 1]

    for entry in entries:
        match = re.match(rx, entry)
        if match is None:
            continue
        name = match[1]
        value = match[2]
        # remove double quotes/{}
        value = value.strip('"')
        value = value.strip("{}")
        env[name] = value

    return env


env = read_env(run_config, "Run Path")  # , read_env(pdk_config, "PDK Root"))

# Cannot be reliably read from config.tcl
input_key = "CURRENT_DEF"
if use_netlist:
    input_key = "CURRENT_NETLIST"
env[input_key] = input_file
env["SAVE_DEF"] = save_def


# Phase 2: Set up destination folder
script_basename = basename(args.or_script)[:-4]
destination_folder = args.output_dir or abspath(
    join(".", "_build", f"{run_name}_{script_basename}_packaged")
)
print(f"Setting up {destination_folder}…", file=sys.stderr)


def mkdirp(path):
    return pathlib.Path(path).mkdir(parents=True, exist_ok=True)


try:
    shutil.rmtree(destination_folder)
except FileNotFoundError:
    pass

mkdirp(destination_folder)

# Phase 3: Process TCL Scripts To Find Full List Of Files
tcls_to_process = deque([script_path])


def shift(deque):
    try:
        return deque.popleft()
    except Exception:
        return None


or_script_counter = 0


def get_or_script():
    global or_script_counter
    value = f"OR_SCRIPT_{or_script_counter}"
    or_script_counter += 1
    return value


env_keys_used = set()
tcls = set()
current = shift(tcls_to_process)
while current is not None:
    env_key = get_or_script()
    env_keys_used.add(env_key)
    env[env_key] = current

    try:
        script = open(current).read()

        for key, value in env.items():
            key_accessor = re.compile(rf"((\$::env\({re.escape(key)}\))([/\-\w\.]*))")
            for use in key_accessor.findall(script):
                use: List[str]
                full, accessor, extra = use
                env_keys_used.add(key)

                value_substituted = full.replace(accessor, value)

                if value_substituted.endswith(".tcl") or value_substituted.endswith(
                    ".sdc"
                ):
                    if value_substituted not in tcls:
                        tcls.add(value_substituted)
                        tcls_to_process.append(value_substituted)
    except Exception:
        print(
            f"[WRN] {current} was not found, might be a product. Skipping",
            file=sys.stderr,
        )

    current = shift(tcls_to_process)

# Phase 4: Copy The Files
final_env = {}

pdk_path = join(destination_folder, "pdk")
openlane_misc_path = join(destination_folder, "openlane")

warnings = []


def copy(frm, to):
    parents = dirname(to)
    mkdirp(parents)

    def do_copy():
        if isdir(frm):
            shutil.copytree(frm, to)
        else:
            shutil.copyfile(frm, to)

    try:
        incomplete_matches = glob.glob(frm + "*")

        if len(incomplete_matches) == 0:
            raise Exception()
        elif len(incomplete_matches) != 1 or incomplete_matches[0] != frm:
            # Prefix For Other Files
            for match in incomplete_matches:
                if match == frm:
                    # If it's both a file AND a prefix for other files
                    do_copy()
                else:
                    new_frm = match
                    new_to = to + new_frm[len(frm) :]
                    copy(new_frm, new_to)
        else:
            do_copy()
    except Exception as e:
        warnings.append(f"[WRN] Couldn't copy {frm}: {e}. Skipped.")


if verbose:
    print("\nProcessing environment variables…\n---", file=sys.stderr)
for key in env_keys_used:
    value = env[key]
    if verbose:
        print(f"{key}: {value}")
    if value == input_file:
        final_path = join(destination_folder, "in.def")
        from_path = value
        copy(from_path, final_path)

        final_env[input_key] = "./in.def"
    elif value.startswith(run_path):
        relative = relpath(value, run_path)
        final_value = join(".", relative)
        final_path = join(destination_folder, final_value)
        from_path = value
        copy(from_path, final_path)

        final_env[key] = final_value
    elif value.startswith(pdk_root):
        nonfree_warning = True
        value_components = value.split(os.path.sep)
        for pdk in OPEN_SOURCE_PDKS:
            if pdk in value_components:
                nonfree_warning = False
        if nonfree_warning:
            warnings.append(
                f"[WRN] {value} appears to be a confidential PDK file. ENSURE THAT YOU INSPECT THE RESULTS."
            )
        relative = relpath(value, pdk_root)
        final_value = join("pdk", relative)
        final_path = join(destination_folder, final_value)
        copy(value, final_path)
        final_env[key] = final_value
    elif value.startswith("/openlane"):
        relative = relpath(value, "/openlane")
        final_value = join("openlane", relative)
        final_path = join(destination_folder, final_value)
        from_path = value.replace("/openlane", openlane_path)
        if value != "/openlane/scripts":  # Too many files to copy otherwise
            copy(from_path, final_path)
        final_env[key] = final_value
    elif value.startswith("/"):
        final_value = value[1:]
        final_path = join(destination_folder, final_value)
        copy(value, final_path)
        final_env[key] = final_value
    else:
        final_env[key] = value
if verbose:
    print("---\n", file=sys.stderr)

for warning in warnings:
    print(warning)
print("\n")

# Phase 5: Create Environment Set/Run Files
run_shell = join(destination_folder, "run.sh")
with open(run_shell, "w") as f:
    env_list = "\n".join(
        [f"export {key}='{value}';" for key, value in final_env.items()]
    )
    f.write(
        f"""\
#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
{env_list}
OPENROAD_BIN=${{OPENROAD_BIN:-openroad}}
$OPENROAD_BIN -exit $OR_SCRIPT_0
    """
    )
os.chmod(run_shell, 0o755)

run_tcl = join(destination_folder, "run.tcl")
with open(run_tcl, "w") as f:
    env_list = "\n".join(
        [f"set ::env({key}) {{{value}}};" for key, value in final_env.items()]
    )
    f.write(
        f"""\
#!/usr/bin/env openroad
{env_list}
source $::env(OR_SCRIPT_0)
    """
    )
os.chmod(run_tcl, 0o755)

gdb_env = join(destination_folder, "env.gdb")
with open(gdb_env, "w") as f:
    env_list = "\n".join([f"set env {key} {value}" for key, value in final_env.items()])
    f.write(
        f"""\
{env_list}
    """
    )

lldb_env = join(destination_folder, "env.lldb")
with open(lldb_env, "w") as f:
    env_list = "\n".join([f"env {key}={value}" for key, value in final_env.items()])
    f.write(
        f"""\
{env_list}
    """
    )

print("[FIN] Done.", file=sys.stderr)
print(destination_folder)
