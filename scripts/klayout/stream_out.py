#!/usr/bin/env python3
# Copyright (c) 2021-2022 Efabless Corporation
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

# Original Copyright Follows
#
# BSD 3-Clause License
#
# Copyright (c) 2018, The Regents of the University of California
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import os
from typing import TYPE_CHECKING, Optional

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
        "--def-layer-map-file",
        required=True,
        help="KLayout .lmp (layer map file) file",
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
    @click.option("-w", "--with-gds-file", "input_gds_files", multiple=True, default=[])
    @click.option("-s", "--seal-gds-file", default=None)
    @click.option("-t", "--top", required=True, help="Name of the design/top module")
    @click.argument("input_def")
    def stream_out(
        output,
        input_lef,
        lyt,
        lyp,
        input_gds_files,
        seal_gds_file,
        def_layer_map_file,
        top,
        input_def,
    ):
        args = [
            "klayout",
            "-b",
            "-rm",
            __file__,
            "-rd",
            f"out_gds={output}",
            "-rd",
            f"lef_file={input_lef}",
            "-rd",
            f"def_layer_map_file={def_layer_map_file}",
            "-rd",
            f"tech_file={lyt}",
            "-rd",
            f"props_file={lyp}",
            "-rd",
            f"design_name={top}",
            "-rd",
            f"in_def={input_def}",
            "-rd",
            f"in_gds={';'.join(list(input_gds_files))}",
            "-rd",
            f"seal_gds={seal_gds_file}",
        ]
        os.execlp("klayout", *args)

    if __name__ == "__main__":
        stream_out()


if TYPE_CHECKING:
    # Dummy data for type-checking
    in_def: str = ""
    out_gds: str = ""
    design_name: str = ""
    tech_file: str = ""
    props_file: str = ""
    in_gds: str = ""
    lef_file: str = ""
    seal_gds: Optional[str] = ""

if seal_gds == "None":
    seal_gds = None


try:
    # Load technology file
    tech = pya.Technology()
    tech.load(tech_file)
    layout_options = tech.load_layout_options
    layout_options.lefdef_config.macro_resolution_mode = 1
    layout_options.lefdef_config.read_lef_with_def = False
    layout_options.lefdef_config.lef_files = [lef_file]
    layout_options.lefdef_config.map_file = def_layer_map_file

    # Load def file
    main_layout = pya.Layout()
    # main_layout.load_layer_props(props_file)
    main_layout.read(in_def, layout_options)

    # Clear cells
    top_cell_index = main_layout.cell(design_name).cell_index()

    print("[INFO] Clearing cells...")
    for i in main_layout.each_cell():
        if i.cell_index() != top_cell_index:
            if not i.name.startswith("VIA"):
                i.clear()

    # Load in the gds to merge
    print("[INFO] Merging GDS files...")
    for gds in in_gds.split(";"):
        print(f"\t{gds}")
        main_layout.read(gds)

    # Copy the top level only to a new layout
    print(f"[INFO] Copying top level cell '{design_name}'...")
    top_only_layout = pya.Layout()
    top_only_layout.dbu = main_layout.dbu
    top = top_only_layout.create_cell(design_name)
    top.copy_tree(main_layout.cell(design_name))

    print("[INFO] Checking for missing GDS...")
    missing_gds = False
    for i in top_only_layout.each_cell():
        if i.is_empty():
            missing_gds = True
            print(f"[ERROR] LEF Cell '{i.name}' has no matching GDS cell.")

    if missing_gds:
        raise Exception("One or more cell GDS files are missing.")
    else:
        print("[INFO] All LEF cells have matching GDS cells.")

    if seal_gds is not None:
        top_cell = top_only_layout.top_cell()

        print(f"[INFO] Reading seal GDS file '{seal_gds}'...")
        top_only_layout.read(seal_gds)

        for cell in top_only_layout.top_cells():
            if cell != top_cell:
                print(f"[INFO] Merging '{cell.name}' as child of '{top_cell.name}'...")
                top.insert(pya.CellInstArray(cell.cell_index(), pya.Trans()))

    # Write out the GDS
    print(f"[INFO] Writing out GDS '{out_gds}'...")
    top_only_layout.write(out_gds)
    print("[INFO] Done.")
    pya.Application.instance().exit(0)
except Exception as e:
    print(e)
    pya.Application.instance().exit(1)
