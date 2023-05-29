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

if "klayout" in os.path.basename(sys.executable):
    import pya
else:
    import click

    @click.command()
    @click.option(
        "-l",
        "--input-lef",
        "input_lefs",
        multiple=True,
    )
    @click.option(
        "-T",
        "--lyt",
        required=True,
        help="KLayout .lyt file",
    )
    @click.option(
        "-P",
        "--lyp",
        required=True,
        help="KLayout .lyp file",
    )
    @click.option(
        "-M",
        "--lym",
        required=True,
        help="KLayout .map (LEF/DEF layer map) file",
    )
    @click.argument("input")
    def cli(**kwargs):
        args = [
            "klayout",
            "-rm",
            __file__,
        ]
        for key, value in kwargs.items():
            args.append("-rd")
            if isinstance(value, tuple) or isinstance(value, list):
                value = ";".join(value)
            elif (
                isinstance(value, str)
                and os.path.exists(value)
                and key != "design_name"
            ):
                value = os.path.abspath(value)

            args.append(f"{key}={value or 'NULL'}")

        os.execlp("klayout", *args)

    if __name__ == "__main__":
        cli()


if TYPE_CHECKING:
    # Dummy data for type-checking
    input: str = ""
    input_lefs: str = ""
    lyp: str = ""
    lyt: str = ""
    lym: str = ""

try:
    main_window = pya.Application.instance().main_window()

    tech = pya.Technology()
    tech.load(lyt)

    layout_options = tech.load_layout_options
    layout_options.keep_other_cells = True
    layout_options.lefdef_config.macro_resolution_mode = 1
    layout_options.lefdef_config.read_lef_with_def = False
    layout_options.lefdef_config.lef_files = input_lefs.split(";")
    layout_options.lefdef_config.map_file = lym

    cell_view = main_window.load_layout(input, layout_options, 0)
    layout_view = cell_view.view()
    layout_view.load_layer_props(lyp)

except Exception as e:
    print(e, file=sys.stderr)

    pya.Application.instance().exit(1)
