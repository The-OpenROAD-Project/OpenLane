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
import os
import glob
import json
import click
import shutil
import pathlib
import textwrap


def mkdirp(path):
    return pathlib.Path(path).mkdir(parents=True, exist_ok=True)


@click.command()
@click.option("--add-to-designs/--dont-add-to-designs", default=False, help="")
@click.option("-d", "--design-dir", required=True, help="")
@click.option("-n", "--design-name", required=True, help="")
@click.option("-c", "--config-file-name", default="config.json", help="")
@click.argument("verilog_files", nargs=-1)
def init_config(
    add_to_designs, design_dir, design_name, config_file_name, verilog_files
):
    _, extension = os.path.splitext(config_file_name)

    src_dir = os.path.join(design_dir, "src")
    glob_in_config = True
    if not add_to_designs:
        glob_in_config = False
        design_dir = os.path.join(".", "openlane", design_name)
    config_path = os.path.join(design_dir, config_file_name)

    mkdirp(design_dir)

    verilog_files_resolved = []
    for file in verilog_files:
        if "*" in file:
            verilog_files_resolved += glob.glob(file)
        else:
            verilog_files_resolved.append(file)

    verilog_files_rel = [
        os.path.relpath(file, design_dir) for file in verilog_files_resolved
    ]

    if extension == ".tcl":
        verilog_arg = "[glob $::env(DESIGN_DIR)/src/*.v]"
        if not glob_in_config:
            verilog_arg = " ".join(
                [os.path.join("$::env(DESIGN_DIR)", file) for file in verilog_files_rel]
            )
            verilog_arg = f'"{verilog_arg}"'
        with open(config_path, "w") as f:
            f.write(
                textwrap.dedent(
                    f"""
                        set ::env(DESIGN_NAME) {{{design_name}}}
                        set ::env(VERILOG_FILES) {verilog_arg}
                        set ::env(CLOCK_PORT) "clk"
                        set ::env(CLOCK_PERIOD) "10.0"

                        set ::env(DESIGN_IS_CORE) {{1}}

                        set tech_specific_config "$::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl"
                        if {{ [file exists $tech_specific_config] == 1 }} {{
                            source $tech_specific_config
                        }}
                    """
                )
            )
    elif extension == ".json":
        verilog_arg = "dir::src/*.v"
        if not glob_in_config:
            verilog_arg = " ".join(verilog_files_rel)
        with open(config_path, "w") as f:
            f.write(
                json.dumps(
                    {
                        "DESIGN_NAME": design_name,
                        "VERILOG_FILES": verilog_arg,
                        "CLOCK_PORT": "clk",
                        "CLOCK_PERIOD": 10.0,
                        "DESIGN_IS_CORE": True,
                    },
                    indent=4,
                    sort_keys=False,
                )
            )
    else:
        raise Exception(f"Unsupported extension '{extension}' for configuration files.")

    if add_to_designs:
        mkdirp(src_dir)
        for src in verilog_files_resolved:
            dst = os.path.join(src_dir, os.path.basename(src))
            shutil.copyfile(src, dst, follow_symlinks=True)
    else:
        gitignore_path = os.path.join(design_dir, ".gitignore")
        with open(gitignore_path, "w") as f:
            f.write("/runs\n")

    print(config_path, end="")


if __name__ == "__main__":
    init_config()
