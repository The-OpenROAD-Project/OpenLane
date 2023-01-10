#!/usr/bin/env python3
# Copyright 2020-2022 Efabless Corporation
# Copyright 2021 The American University in Cairo and the Cloud V Project
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
import sys
from typing import TYPE_CHECKING

try:
    import pya
except ImportError:
    import click

    @click.command()
    @click.option(
        "-l",
        "--input-lef",
        required=os.getenv("MERGED_LEF") is None,
        default=os.getenv("MERGED_LEF"),
    )
    @click.option(
        "-T",
        "--tech-file",
        "lyt",
        required=os.getenv("KLAYOUT_TECH") is None,
        default=os.getenv("KLAYOUT_TECH"),
        help="KLayout .lyt file",
    )
    @click.option(
        "-P",
        "--props-file",
        "lyp",
        required=os.getenv("KLAYOUT_PROPERTIES") is None,
        default=os.getenv("KLAYOUT_PROPERTIES"),
        help="KLayout .lyp file",
    )
    @click.argument("input_def")
    def open_design(
        input_lef,
        lyt,
        lyp,
        input_def,
    ):
        args = [
            "klayout",
            "-rm",
            __file__,
            "-rd",
            f"input_lef={os.path.abspath(input_lef)}",
            "-rd",
            f"tech_file={os.path.abspath(lyt)}",
            "-rd",
            f"props_file={os.path.abspath(lyp)}",
            "-rd",
            f"input_def={os.path.abspath(input_def)}",
        ]
        os.execlp("klayout", *args)

    if __name__ == "__main__":
        open_design()

if TYPE_CHECKING:
    # Dummy data for type-checking
    input_def: str = ""
    tech_file: str = ""
    props_file: str = ""
    input_lef: str = ""

try:
    main_window = pya.Application.instance().main_window()

    tech = pya.Technology()
    tech.load(tech_file)

    layout_options = tech.load_layout_options
    layout_options.keep_other_cells = True
    layout_options.lefdef_config.macro_resolution_mode = 1
    layout_options.lefdef_config.read_lef_with_def = False
    layout_options.lefdef_config.lef_files = [input_lef]

    cell_view = main_window.load_layout(input_def, layout_options, 0)
    exit(0)
except Exception as e:
    print(e, file=sys.stderr)
    exit(-1)
