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
"""

import os
import re
import sys
import glob
import shutil
import pathlib
import textwrap
from typing import List, Dict
from collections import deque
from os.path import join, abspath, dirname, basename, isdir, relpath

import click

from config.tcl import read_tcl_env

openlane_path = abspath(dirname(dirname(__file__)))


@click.command()
@click.option(
    "--script",
    "-s",
    required=True,
    help="Path to the Tcl script causing the failure: i.e. ./scripts/openroad/antenna_check.tcl, ./scripts/magic/drc.tcl, etc. [required]",
)
@click.option(
    "--pdk-root",
    required=(os.getenv("PDK_ROOT") is None),
    default=os.getenv("PDK_ROOT"),
    help="Path to the PDK root [required if environment variable PDK_ROOT is not set]",
)
@click.option(
    "--run-path",
    "-r",
    default=None,
    help="The run path. If not specified, the script will attempt to discern it from the input file's path.",
)
@click.option(
    "--output",
    "-o",
    "save_def",
    default="./out.def",
    help="Name of def file to be generated [default: ./out.def]",
)
@click.option(
    "--output-db",
    "-O",
    "save_odb",
    default="./out.odb",
    help="Name of odb file to be generated [default: ./out.odb]",
)
@click.option(
    "--verbose/--not-verbose",
    default=False,
    help="Verbose output of all found environment variables.",
)
@click.option(
    "--input-type",
    type=click.Choice(["def", "netlist", "odb"]),
    default="odb",
    help="Use a netlist or a DEF layout as an input instead of an ODB file. Useful for evaluating some scripts such as floorplan.tcl.",
)
@click.option("--output-dir", default=None, help="Output to this directory.")
@click.option(
    "--tool",
    type=click.Choice(["openroad", "magic"]),
    help="The tool used for the desired Tcl script. [required]",
)
@click.argument("input_file")
def issue(
    script,
    pdk_root,
    run_path,
    save_def,
    save_odb,
    verbose,
    input_type,
    output_dir,
    tool,
    input_file,
):
    """
    Issue packager for Tcl-based tools (currently: OpenROAD, Magic)

    The or_ prefix is an artifact name because this used to only work with OpenROAD.

    Usage: or_issue.py [OPTIONS] <input_file>

    input_file: Name of input into the script (usually denoted by environment variable CURRENT_NETLIST or CURRENT_DEF: get it from the logs)
    """

    OPEN_SOURCE_PDKS = ["sky130A", "sky130B"]
    print(
        textwrap.dedent(
            """\
            OpenLane TCL Issue Packager

            EFABLESS CORPORATION AND ALL AUTHORS OF THE OPENLANE PROJECT SHALL NOT BE HELD
            LIABLE FOR ANY LEAKS THAT MAY OCCUR TO ANY PROPRIETARY DATA AS A RESULT OF USING
            THIS SCRIPT. THIS SCRIPT IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OR
            CONDITIONS OF ANY KIND.

            BY USING THIS SCRIPT, YOU ACKNOWLEDGE THAT YOU FULLY UNDERSTAND THIS DISCLAIMER
            AND ALL IT ENTAILS.
            """
        ),
        file=sys.stderr,
    )

    scripts_path = join(openlane_path, "scripts", tool)
    if run_path is not None:
        run_path = abspath(run_path)
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

    if not os.path.exists(input_file):
        print(f"[ERR] {input_file} not found.", file=sys.stderr)
        exit(os.EX_NOINPUT)

    if not script.startswith(scripts_path):
        print(
            f"[ERR] The {tool} script {script} does not appear to be in {scripts_path}.",
            file=sys.stderr,
        )
        exit(os.EX_CONFIG)

    if not os.path.exists(run_path) and os.path.isdir(run_path):
        print(f"[ERR] The run path {run_path} is not a valid folder.", file=sys.stderr)
        exit(os.EX_CONFIG)

    run_name = basename(run_path)

    # Phase 1: Read All Environment Variables
    print("Parsing config file(s)…", file=sys.stderr)
    run_config = join(run_path, "config.tcl")

    env = read_tcl_env(run_config)

    # Cannot be reliably read from config.tcl
    env["SAVE_DEF"] = save_def
    input_key = "CURRENT_DEF"
    if input_type == "odb":
        input_key = "CURRENT_ODB"
        env["SAVE_ODB"] = save_odb
    elif input_type == "netlist":
        input_key = "CURRENT_NETLIST"

    env[input_key] = input_file

    # Phase 2: Set up destination folder
    script_basename = basename(script)[:-4]
    destination_folder = output_dir or abspath(
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
    tcls_to_process = deque([script])

    def shift(deque):
        try:
            return deque.popleft()
        except Exception:
            return None

    script_counter = 0

    def get_script_key():
        nonlocal script_counter
        value = f"PACKAGED_SCRIPT_{script_counter}"
        script_counter += 1
        return value

    env_keys_used = set()
    if tool == "magic":
        env_keys_used.add("MAGIC_MAGICRC")
    tcls = set()
    current = shift(tcls_to_process)
    while current is not None:
        env_key = get_script_key()
        env_keys_used.add(env_key)
        env[env_key] = current

        try:
            script = open(current).read()
            if verbose:
                print(f"Processing {current}...", file=sys.stderr)

            for key, value in env.items():
                key_accessor = re.compile(
                    rf"((\$::env\({re.escape(key)}\))([/\-\w\.]*))"
                )
                for use in key_accessor.findall(script):
                    use: List[str]
                    full, accessor, extra = use
                    env_keys_used.add(key)
                    if verbose:
                        print(f"Found {accessor}…", file=sys.stderr)

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
            print(f"Processing {key}: {value}…", file=sys.stderr)
        if value.startswith(run_path):
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
        elif value.startswith("/") and not value.startswith(
            "/dev"
        ):  # /dev/null, /dev/stdout, /dev/stderr, etc should still work
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
    def env_list(
        format_string: str = "{key}={value}",
        env: Dict[str, str] = final_env,
        indent: int = 0,
    ) -> str:
        array = []
        for key, value in sorted(env.items()):
            array.append(format_string.format(key=key, value=value))
        value = f"\n{'    ' * indent}".join(array)
        return value

    run_shell = join(destination_folder, "run.sh")
    with open(run_shell, "w") as f:
        run_cmd = None
        if tool == "openroad":
            run_cmd = "$TOOL_BIN -exit $PACKAGED_SCRIPT_0"
        elif tool == "magic":
            run_cmd = "$TOOL_BIN -dnull -noconsole -rcfile $MAGIC_MAGICRC < $PACKAGED_SCRIPT_0"
        f.write(
            textwrap.dedent(
                f"""\
                #!/bin/sh
                dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
                cd $dir;
                {env_list("export {key}='{value}';", indent=4)}
                TOOL_BIN=${{TOOL_BIN:-{tool}}}
                {run_cmd}
                """
            )
        )
    os.chmod(run_shell, 0o755)

    if tool == "openroad":
        run_tcl = join(destination_folder, "run.tcl")
        with open(run_tcl, "w") as f:
            f.write(
                textwrap.dedent(
                    f"""\
                    #!/usr/bin/env openroad
                    {env_list('set ::env({key}) {{{value}}};', indent=5)}
                    source $::env(PACKAGED_SCRIPT_0)
                    """
                )
            )
        os.chmod(run_tcl, 0o755)

    gdb_env = join(destination_folder, "env.gdb")
    with open(gdb_env, "w") as f:
        f.write(env_list("set env {key} {value}"))

    lldb_env = join(destination_folder, "env.lldb")
    with open(lldb_env, "w") as f:
        f.write(env_list("env {key}={value}"))

    print("Done.", file=sys.stderr)
    print(destination_folder)


if __name__ == "__main__":
    issue()
