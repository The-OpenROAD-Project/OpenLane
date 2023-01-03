#!/usr/bin/python3
# Copyright 2022 Efabless Corporation
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
import glob

import click

from tcl import read_tcl_env


@click.command()
@click.option(
    "--output",
    default="/dev/stdout",
    help="Path to write a source-able Tcl script with the opt variables",
)
@click.option("--pdk-root", required=True, help="The PDK root in use")
@click.option("--pdk", required=True, help="The PDK")
@click.option("--opt-scl", required=True, help="The optimization standard cell library")
@click.argument("pdk_config_path")
@click.argument("scl_config_path")
def extract_opt_variables(
    output, pdk_root, pdk, opt_scl, pdk_config_path, scl_config_path
):
    """
    Extracts and process SCL-specific config variables and postfixes them
    with _OPT for the optimization standard cell library (STD_CELL_LIBRARY_OPT).
    """
    target_variables = [
        "LIB_SYNTH",
        "TECH_LEF",
        "CELLS_LEF",
        "DRC_EXCLUDE_CELL_LIST",
        "NO_SYNTH_CELL_LIST",
    ]
    env = {
        "PDK_ROOT": pdk_root,
        "PDK": pdk,
        "STD_CELL_LIBRARY": opt_scl,
    }
    config = read_tcl_env(pdk_config_path)
    scl_config = read_tcl_env(scl_config_path)
    config.update(scl_config)
    cfg_filtered = {k: v.strip() for k, v in config.items() if k in target_variables}

    env_access = re.compile(r"(\$(?:\:\:)?env\((\w+)\))")
    glob_rx = re.compile(r"\[\s*glob\s+[\"\{]([^}\"]+)\"]")
    final = {}
    for key, value in cfg_filtered.items():
        for full_match, accessor in env_access.findall(value):
            if accessor in env:
                value = value.replace(full_match, env[accessor])

        glob_match = glob_rx.match(value)
        if glob_match is not None:
            files = glob.glob(glob_match[1])
            value = " ".join(files)
        final[key] = value

    with open(output, "w") as f:
        for key, value in final.items():
            print(f"set ::env({key}_OPT) {{{value}}}", file=f)


if __name__ == "__main__":
    extract_opt_variables()
