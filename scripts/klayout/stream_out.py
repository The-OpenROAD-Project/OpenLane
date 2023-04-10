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
import sys
from typing import TYPE_CHECKING, Optional

if "klayout" in os.path.basename(sys.executable):
    import pya
else:
    import click

    @click.command()
    @click.option("-o", "--output", required=True)
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
    @click.option("-w", "--with-gds-file", "input_gds_files", multiple=True, default=[])
    @click.option("-s", "--seal-gds-file", "seal_gds", default=None)
    @click.option(
        "-t",
        "--top",
        "design_name",
        required=True,
        help="Name of the design/top module",
    )
    @click.argument("input")
    def stream_out(**kwargs):
        args = [
            "klayout",
            "-b",
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
        stream_out()


if TYPE_CHECKING:
    # Dummy data for type-checking
    input: str = ""
    output: str = ""
    input_lefs: str = ""
    lyp: str = ""
    lyt: str = ""
    lym: str = ""
    design_name: str = ""
    input_gds_files: str = ""
    seal_gds: Optional[str] = ""

if seal_gds == "NULL":
    seal_gds = None


try:
    # Load technology file
    tech = pya.Technology()
    tech.load(lyt)
    layout_options = tech.load_layout_options
    layout_options.lefdef_config.macro_resolution_mode = 1
    layout_options.lefdef_config.read_lef_with_def = False
    layout_options.lefdef_config.lef_files = input_lefs.split(";")
    layout_options.lefdef_config.map_file = lym

    # Load def file
    main_layout = pya.Layout()
    # main_layout.load_layer_props(props_file)
    main_layout.read(input, layout_options)

    # Clear cells
    top_cell_index = main_layout.cell(design_name).cell_index()

    print("[INFO] Clearing cells…")
    for i in main_layout.each_cell():
        if i.cell_index() != top_cell_index:
            if not i.name.startswith("VIA"):
                i.clear()

    # Load in the gds to merge
    print("[INFO] Merging GDS files…")
    for gds in input_gds_files.split(";"):
        print(f"\t{gds}")
        main_layout.read(gds)

    # Copy the top level only to a new layout
    print(f"[INFO] Copying top level cell '{design_name}'…")
    top_only_layout = pya.Layout()
    top_only_layout.dbu = main_layout.dbu
    top = top_only_layout.create_cell(design_name)
    top.copy_tree(main_layout.cell(design_name))

    print("[INFO] Checking for missing GDS…")
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

        print(f"[INFO] Reading seal GDS file '{seal_gds}'…")
        top_only_layout.read(seal_gds)

        for cell in top_only_layout.top_cells():
            if cell != top_cell:
                print(f"[INFO] Merging '{cell.name}' as child of '{top_cell.name}'…")
                top.insert(pya.CellInstArray(cell.cell_index(), pya.Trans()))

    # Write out the GDS
    print(f"[INFO] Writing out GDS '{output}'…")
    top_only_layout.write(output)
    print("[INFO] Done.")

    pya.Application.instance().exit(0)
except Exception as e:
    print(e)

    pya.Application.instance().exit(1)
