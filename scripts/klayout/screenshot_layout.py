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
from typing import TYPE_CHECKING

try:
    import pya
except ImportError:
    import click

    @click.command()
    @click.option("-o", "--output", required=True)
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
    def screenshot_layout(
        output,
        input_lef,
        lyt,
        lyp,
        input_def,
    ):
        args = [
            # "xvfb-run",
            # "-a",
            "klayout",
            "-rm",
            __file__,
            "-rd",
            f"out_png={os.path.abspath(output)}",
            "-rd",
            f"lef_file={os.path.abspath(input_lef)}",
            "-rd",
            f"tech_file={os.path.abspath(lyt)}",
            "-rd",
            f"props_file={os.path.abspath(lyp)}",
            "-rd",
            f"in_def={os.path.abspath(input_def)}",
        ]
        os.execlp("klayout", *args)

    if __name__ == "__main__":
        screenshot_layout()

if TYPE_CHECKING:
    # Dummy data for type-checking
    in_def: str = ""
    out_png: str = ""
    tech_file: str = ""
    props_file: str = ""
    lef_file: str = ""

try:
    WIDTH = 2048
    HEIGHT = 2048

    main_window = pya.Application.instance().main_window()

    # Load technology file
    print(f"[INFO] Reading tech file: '{str(tech_file)}'...")
    tech = pya.Technology()
    tech.load(tech_file)

    layout_options = tech.load_layout_options
    layout_options.keep_other_cells = True
    layout_options.lefdef_config.macro_resolution_mode = 1
    layout_options.lefdef_config.read_lef_with_def = False
    layout_options.lefdef_config.lef_files = [lef_file]

    # Load def file in the main window
    print(f"[INFO] Reading layout file: '{str(in_def)}'...")
    cell_view = main_window.load_layout(in_def, layout_options, 0)
    layout_view = cell_view.view()
    layout_view.load_layer_props(props_file)
    layout_view.max_hier()

    # Hide layers with these purposes
    hidden_purposes = [0, 4, 5]

    li = layout_view.begin_layers()
    while not li.at_end():
        lp = li.current()
        if lp.source_datatype in hidden_purposes:
            new_lp = lp.dup()
            new_lp.visible = False
            layout_view.set_layer_properties(li, new_lp)

        li.next()

    print(f"[INFO] Writing out screenshot to '{out_png}'...")
    layout_view.save_image(out_png, WIDTH, HEIGHT)
    print("Done.")
    exit(0)
except Exception as e:
    print(e)
    exit(-1)
