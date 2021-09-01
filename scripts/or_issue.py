#!/usr/bin/env python3

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
from collections import deque
from os.path import join, abspath, dirname, basename, isdir, relpath

openlane_path = abspath(dirname(__file__))

parser = argparse.ArgumentParser(description="OpenROAD Issue Packager")
parser.add_argument('--or-script', '-s', required=True, help='Path to the OpenROAD script causing the failure: i.e. ./scripts/openroad/or_antenna_check.tcl, ./scripts/openroad/or_pdn.tcl, etc. [required]')
parser.add_argument('--pdk-root', required=(os.getenv("PDK_ROOT") is None), default=os.getenv("PDK_ROOT"), help='Path to the PDK root [required if environment variable PDK_ROOT is not set]')
parser.add_argument('--input', '-i', required=True, help='Name of def file input into the OR script (usually denoted by environment variable CURRENT_DEF: get it from the logs) [required]')
parser.add_argument('--output', '-o', default="./out.def", help='Name of def file to be generated [default: ./out.def]')
parser.add_argument('--verbose', action="store_true", default=False, help='Verbose output of all found environment variables.')
parser.add_argument('run_path', help='Path to the run folder.')
args = parser.parse_args()

OPEN_SOURCE_PDKS = ["sky130A"]
print("""
EFABLESS CORPORATION AND ALL AUTHORS OF THE OPENLANE PROJECT SHALL NOT BE HELD
LIABLE FOR ANY LEAKS THAT MAY OCCUR TO ANY PROPRIETARY DATA AS A RESULT OF USING
THIS SCRIPT. THIS SCRIPT IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND.

BY USING THIS SCRIPT, YOU ACKNOWLEDGE THAT YOU FULLY UNDERSTAND THIS DISCLAIMER
AND ALL IT ENTAILS.
""", file=sys.stderr)

script_path = abspath(args.or_script)
run_path = abspath(args.run_path)
pdk_root = abspath(args.pdk_root)
or_scripts_path = join(openlane_path, "scripts", "openroad")
current_def = abspath(args.input)
save_def = args.output
verbose = args.verbose

if not os.path.exists(current_def):
    print(f"❌ {current_def} not found.", file=sys.stderr)
    exit(os.EX_CONFIG)

if not script_path.startswith(or_scripts_path):
    print(f"❌ The OpenROAD script {script_path} does not appear to be in {or_scripts_path}.", file=sys.stderr)
    exit(os.EX_CONFIG)

if not os.path.exists(run_path) and os.path.isdir(run_path):
    print(f"❌ The run path {run_path} is not a valid folder.", file=sys.stderr)
    exit(os.EX_CONFIG)

run_name = basename(run_path)
script_basename = basename(args.or_script)[:-4]

script_path_containerized = script_path.replace(openlane_path, "/openLANE_flow")
run_path_containerized = run_path.replace(openlane_path, "/openLANE_flow")


# Phase 1: Read All Environment Variables
# pdk_config = join(args.pdk_root, "sky130A", "libs.tech", "openlane", "config.tcl")
print(f"Parsing config file(s)…", file=sys.stderr)
run_config = join(run_path, "config.tcl")

env = {}


def read_env(config_path: str, from_path: str, input_env={}) -> dict:
    rx = r"\s*set\s*::env\((.+?)\)\s*(.+)"
    env = input_env.copy()
    string_data = ""
    try:
        string_data = open(config_path).read()
    except FileNotFoundError:
        print(f"❌ File {config_path} not found. The path {from_path} may have been specified incorrectly.", file=sys.stderr)
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
        name = match[1]; value = match[2]
        # remove double quotes
        if value.startswith('"') and value.endswith('"'): 
            value = value[1:-1]
        env[name] = value

    return env
    
env = read_env(run_config, "Run Path") # , read_env(pdk_config, "PDK Root"))
# Cannot be reliably read from config.tcl
env["CURRENT_DEF"] = current_def
env["SAVE_DEF"] = save_def


# Phase 2: Set up destination folder
destination_folder = abspath(join(".", "_build", f"{run_name}_{script_basename}_packaged"))
print(f"Setting up {destination_folder}…", file=sys.stderr)

def mkdirp(path):
    return pathlib.Path(path).mkdir(parents=True, exist_ok=True)

try:
    shutil.rmtree(destination_folder)
except FileNotFoundError:
    pass

mkdirp(destination_folder)

# Phase 3: Process TCL Scripts To Find Full List Of Files
tcls_to_process = deque([ script_path ])
def shift(deque):
    try:
        return deque.popleft()
    except:
        return None

env_keys_used = ["OR_SCRIPT"]
env["OR_SCRIPT"] = script_path_containerized

current = shift(tcls_to_process)
while current is not None:
    script = open(current).read()

    for key, value in env.items():
        key_accessor = f"$::env({key})"
        if not key_accessor in script:
            continue
        env_keys_used.append(key)
        if value.endswith(".tcl"):
            tcls_to_process.append(value)

    current = shift(tcls_to_process)

# Phase 4: Copy The Files
final_env_pairs = []

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
                    new_to = to + new_frm[len(frm):]
                    copy(new_frm, new_to)
        else:
            do_copy()
    except Exception as e:
        warnings.append(f"ℹ Couldn't copy {frm}: {e}. Skipped.")

if verbose:
    print("\nProcessing environment variables…\n---", file=sys.stderr)
for key in env_keys_used:
    value = env[key]
    if verbose:
        print(f"{key}: {value}")
    if value.startswith(run_path_containerized):
        relative = relpath(value, run_path_containerized)
        final_value = join(".", relative)
        final_path = join(destination_folder, final_value)
        from_path = value.replace(run_path_containerized, run_path)
        copy(from_path, final_path)        
        final_env_pairs.append((key, final_value))
    elif value.startswith(pdk_root):
        nonfree_warning = True
        value_components = value.split(os.path.sep)
        for pdk in OPEN_SOURCE_PDKS:
            if pdk in value_components:
                nonfree_warning = False
        if nonfree_warning:
            warnings.append(f"⚠ CAUTION: {value} appears to be a confidential PDK file. ENSURE THAT YOU INSPECT THE RESULTS.") 
        relative = relpath(value, pdk_root)
        final_value = join("pdk", relative)
        final_path = join(destination_folder, final_value)
        copy(value, final_path)
        final_env_pairs.append((key, final_value))
    elif value.startswith("/openLANE_flow"):
        relative = relpath(value, "/openLANE_flow")
        final_value = join("openlane", relative)
        final_path = join(destination_folder, final_value)
        from_path = value.replace("/openLANE_flow", openlane_path)
        copy(from_path, final_path)       
        final_env_pairs.append((key, final_value))
    elif value.startswith("/"):
        final_value = value[1:]
        final_path = join(destination_folder, final_value)
        copy(value, final_path)
        final_env_pairs.append((key, final_value))
    else:
        final_env_pairs.append((key, value))  
if verbose:
    print("---\n", file=sys.stderr)

for warning in warnings:
    print(warning)
print('\n')
    
# Phase 5: Create Run Files
run_ol = join(destination_folder, "run_ol")
with open(run_ol, "w") as f:
    env_list = "\\\n    ".join([f"-e {key}='{value}'" for key, value in final_env_pairs])
    f.write(f"""\
#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
docker run --rm\\
    -tiv `pwd`:`pwd` -w `pwd`\\
    {env_list}\\
    {os.getenv("IMAGE_NAME") or "efabless/openlane:current"} openroad \\$::env\\(OR_SCRIPT\\)
    """)
os.chmod(run_ol, 0o755)

run_raw = join(destination_folder, "run")
with open(run_raw, "w") as f:
    env_list = "\n".join([f"export {key}='{value}';" for key, value in final_env_pairs])
    f.write(f"""\
#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
{env_list}
OPENROAD_BIN=${{OPENROAD_BIN:-openroad}}
$OPENROAD_BIN -exit $OR_SCRIPT
    """)
os.chmod(run_raw, 0o755)

# Phase 6: Tarball and output
last_output = f"{destination_folder}.tar.gz"

os.system(f"tar -cvC {destination_folder} . | gzip > {last_output}")

print("⭕️ Done.", file=sys.stderr)
print(last_output)
