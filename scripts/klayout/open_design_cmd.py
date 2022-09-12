#!/usr/bin/env python3
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

import os
import click
import subprocess


@click.command("open_design")
@click.option(
    "-l",
    "--input-lef",
    default=os.getenv("MERGED_LEF"),
    help="Input merged technology/cells LEF file",
)
@click.option(
    "-P",
    "--pdk-root",
    default=os.getenv("PDK_ROOT"),
    required=not os.getenv("PDK_ROOT"),
    help="PDK Root",
)
@click.option("-p", "--pdk", default="sky130A", help="Name of the PDK")
@click.argument("input_def")
def open_design(input_lef, pdk_root, pdk, input_def):
    """
    Opens a design in KLayout.
    """
    dir = os.path.dirname(__file__)
    klayout_script_path = os.path.join(dir, "open_design.py")
    env = os.environ.copy()

    env["EXPLICITLY_LISTED_LEFS"] = input_lef
    env["PDK_ROOT"] = pdk_root
    env["PDK"] = pdk
    env["LAYOUT"] = input_def

    subprocess.check_call(
        [
            "klayout",
            "-rm",
            klayout_script_path,
        ],
        env=env,
    )


if __name__ == "__main__":
    open_design()
