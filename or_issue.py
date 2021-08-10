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
This script creates a reproducible, self-contained package of files to demonstrate OpenROAD behavior in a vaccum, suitable for filing issues.

Requires UNIX-like operating system. Final tarball's path is printed to stdout.

Usage example:

You'll have to extract three key elements from the error:
* The Run Path (run_path)
* The Script Where The Failure Occurred (script)
* The Final Layout Before The Failure Occurred (input)

As a practical example, for this log from flow_summary.txt:

[INFO]: Changing layout from /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27/results/cts/eth_top.cts.def to /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27/tmp/placement/12-resizer_timing.def
[...]
[INFO]: Running Global Routing...
[INFO]: current step index: 15
[ERROR]: during executing: "openroad -exit /opt/openlane/scripts/openroad/or_groute.tcl |& tee >&@stdout /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27/logs/routing/15-fastroute.log"
[ERROR]: Exit code: 1
[ERROR]: Last 10 lines:
child killed: kill signal

The three elements would be:
* run_path: /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27
* script: ./scripts/openroad/or_groute.tcl (Note that the script is addressed relatively to the OpenLane repo.)
* input: /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27/tmp/placement/12-resizer_timing.def

Then you'd want to run this script as follows, from the root of the OpenLane Repo:
    python3 ./or_issue.py\
        /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27\
        -s ./scripts/openroad/or_groute.tcl\
        -i /donn/ol_issue_sandbox/eth_top/runs/05-08_13-27/tmp/placement/12-resizer_timing.def

Which will create a folder called _build, with two entries:
    * 05-08_13-27_or_groute_packaged/: A folder for human inspection
    * 05-08_13-27_or_groute_packaged.tar.gz: A gzipped tarball of that same folder.

Ensure that you inspect this folder manually and the output of this script. This script only attempts a best effort, and it is very likely that it might miss something, in which case, feel free to file an issue.

When working with a proprietary PDK, also inspect the tarball and ensure no proprietary data resulting ends up in there. This is *critical*, if something leaks, this scripts' authors take no responsibility and you are very much on your own. We will try our best to output warnings for your own good if something looks like a part of a proprietary PDK, but the absence of this message does not necessarily indicate that your folder and tarball are free of confidential material. 
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
parser.add_argument('-c', '--compression', default="gzip", help='Comma,delimited list of compression techniques to use after tar. Use "None" to disable compression altogether. Valid technologies: gzip/gz, xzip/xz, bzip2/bz2 [default: gzip]')
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
compression = args.compression
or_scripts_path = join(openlane_path, "scripts", "openroad")
current_def = args.input
save_def = args.output

if not script_path.startswith(or_scripts_path):
    print(f"⚠ The OpenROAD script {script_path} does not appear to be in {or_scripts_path}.", file=sys.stderr)
    print("This script's behavior may be undefined.", file=sys.stderr)

run_name = basename(run_path)
script_basename = basename(args.or_script)[:-4]

script_path_containerized = script_path.replace(openlane_path, "/openLANE_flow")
run_path_containerized = run_path.replace(openlane_path, "/openLANE_flow")


# Phase 1: Read All Environment Variables
# pdk_config = join(args.pdk_root, "sky130A", "libs.tech", "openlane", "config.tcl")
print(f"Parsing config file(s)...", file=sys.stderr)
run_config = join(run_path, "config.tcl")

env = {}


def read_env(config_path: str, from_path: str, input_env={}) -> dict:
    rx = r"\s*set\s*::env\((.+?)\)\s*(.+)"
    env = input_env.copy()
    string_data = ""
    try:
        string_data = open(config_path).read()
    except FileNotFoundError:
        print(f"❌ File {config_path} not found. The {from_path} path may have been specified incorrectly.", file=sys.stderr)
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
        # print(value)
        env[name] = value

    return env
    
env = read_env(run_config, "Run Path") # , read_env(pdk_config, "PDK Root"))
# Cannot be reliably read from config.tcl
env["CURRENT_DEF"] = current_def
env["SAVE_DEF"] = save_def


# Phase 2: Set up destination folder
destination_folder = abspath(join(".", "_build", f"{run_name}_{script_basename}_packaged"))
print(f"Setting up {destination_folder}...", file=sys.stderr)

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

def copy(frm, to):
    parents = dirname(to)
    mkdirp(parents)

    try:
        incomplete_matches = glob.glob(frm + "*")
        if len(incomplete_matches) == 0:
            raise Exception()
        elif len(incomplete_matches) != 1 or incomplete_matches[0] != frm:
            # Prefix File
            for match in incomplete_matches:
                new_frm = match
                new_to = to + new_frm[len(frm):]
                copy(new_frm, new_to)
        else:
            if isdir(frm):
                shutil.copytree(frm, to)
            else:
                shutil.copyfile(frm, to)
    except:
        print(f"ℹ Couldn't copy {frm}, skipping...", file=sys.stderr)

for key in env_keys_used:
    value = env[key]
    if value.startswith(run_path_containerized):
        relative = relpath(value, run_path_containerized)
        final_value = join(".", relative)
        final_path = join(destination_folder, final_value)
        from_path = value.replace(run_path_containerized, run_path)
        copy(from_path, final_path)        
        final_env_pairs.append((key, final_value))
    elif value.startswith(pdk_root):
        nonfree_warning = True
        value_components = os.path.split(value)
        for pdk in OPEN_SOURCE_PDKS:
            if pdk in value_components:
                nonfree_warning = False
        if nonfree_warning:
            print(f"⚠ CAUTION: {value} appears to be a confidential PDK file. ENSURE THAT YOU INSPECT THE RESULTS.", file=sys.stderr) 
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
last_output = destination_folder
if compression != "None":
    technology_dict = {
        "xz": ("xz", "xz"),
        "xzip": ("xz", "xz"),
        "gz": ("gzip", "gz"),
        "gzip": ("gzip", "gz"),
        "bz2": ("bzip2", "bz2"),
        "bzip2": ("bzip2", "bz2"),
    }
    technologies = compression.split(',')

    ext = ".".join([technology_dict[k][1] for k in technologies])
    last_output = f"{destination_folder}.tar.{ext}"

    pipes = " ".join([f"| {technology_dict[k][0]}" for k in technologies])
    os.system(f"tar -cvC {destination_folder} . {pipes} > {last_output}")

print("✔ Done.", file=sys.stderr)
print(last_output)
