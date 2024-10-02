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
import shlex
import argparse
from typing import Tuple

import pya  # Must be run inside KLayout-- the library version of pya does not include "Application"


def open_design(input_lefs: Tuple[str, ...], lyt: str, lyp: str, lym: str, input: str):
    try:
        main_window = pya.Application.instance().main_window()

        tech = pya.Technology()
        tech.load(lyt)

        layout_options = tech.load_layout_options
        layout_options.keep_other_cells = True
        layout_options.lefdef_config.macro_resolution_mode = 1
        layout_options.lefdef_config.read_lef_with_def = False
        layout_options.lefdef_config.lef_files = list(input_lefs)
        layout_options.lefdef_config.map_file = lym

        cell_view = main_window.load_layout(input, layout_options, 0)
        layout_view = cell_view.view()
        layout_view.load_layer_props(lyp)
    except Exception as e:
        print(e, file=sys.stderr)
        pya.Application.instance().exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Open design in KLayout")
    parser.add_argument(
        "-l",
        "--input-lef",
        action="append",
        dest="input_lefs",
        help="KLayout .lef files",
    )
    parser.add_argument("-T", "--lyt", required=True, help="KLayout .lyt file")
    parser.add_argument("-P", "--lyp", required=True, help="KLayout .lyp file")
    parser.add_argument(
        "-M", "--lym", required=True, help="KLayout .map (LEF/DEF layer map) file"
    )
    parser.add_argument("input", help="KLayout cell name")

    args = parser.parse_args(shlex.split(os.environ["KLAYOUT_ARGV"]))
    open_design(args.input_lefs, args.lyt, args.lyp, args.lym, args.input)
