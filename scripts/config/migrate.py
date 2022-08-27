#!/usr/bin/python3
# Copyright 2020-2022 Efabless Corporation
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
import os
import json
import click


@click.command()
@click.argument("design")
def migrate_config(design):
    """
    Usage: migrate_config.py <path to design>

    Creates a config.json out of existing config.tcls
    """

    final = {}

    config_files = [x for x in os.listdir(design) if x.endswith("config.tcl")]
    config_files.sort()

    pdk_scl_rx = re.compile(r"([A-Za-z0-9]+)_(\w+)_config.tcl")
    setting_pattern = re.compile(r"\s*?set ::env\((\w+)\)\s*?([^\n]+)\s*")
    expr_pattern = re.compile(r"\[\s*expr\s+([^\n\]]+)\s*\]")
    glob_pattern = re.compile(r"\[\s*glob\s+([^\n\]]+)\s*\]")
    expr_env = re.compile(r"\$::env\((\w+)\)")

    for config_file in config_files:
        object = final
        m = pdk_scl_rx.match(config_file)
        if m is not None:
            pdk = m[1]
            scl = m[2]

            final[f"pdk::{pdk}"] = final.get(f"pdk::{pdk}") or {}
            final[f"pdk::{pdk}"][f"scl::{scl}"] = (
                final[f"pdk::{pdk}"].get(f"scl::{scl}") or {}
            )

            object = final[f"pdk::{pdk}"][f"scl::{scl}"]

        config_file_path = os.path.join(design, config_file)
        for setting in re.findall(setting_pattern, open(config_file_path).read()):
            key = setting[0]
            value = setting[1].strip('"{} ')

            expr_match = expr_pattern.match(value)
            if expr_match is not None:
                value = expr_match[1].strip()
                value = expr_env.sub(r"$\1", value)
                value = f"expr::{value}"

            glob_match = glob_pattern.match(value)
            if glob_match is not None:
                value = glob_match[1].strip()

            if value.startswith("$::env(DESIGN_DIR)/"):
                value = value.replace("$::env(DESIGN_DIR)/", "dir::")

            object[key] = value

    final_json_path = os.path.join(design, "config.json")
    with open(final_json_path, "w") as f:
        f.write(json.dumps(final, indent=4, sort_keys=False))


if __name__ == "__main__":
    migrate_config()
