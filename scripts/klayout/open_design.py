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
import pya

app = pya.Application.instance()

try:
    win = app.main_window()

    layout = os.getenv("LAYOUT")
    if layout is None:
        raise Exception("LAYOUT environment variable is not set.")

    pdk_root = os.getenv("PDK_ROOT")
    if pdk_root is None:
        raise Exception("PDK_ROOT environment variable is not set.")

    pdk_name = os.getenv("PDK")
    if pdk_name is None:
        raise Exception("PDK environment variable is not set.")

    # Relative to the layout path, ':' delimited. If not provided, all LEFs
    # in the same folder as the layout will be loaded.
    explicitly_listed_lefs_raw = os.getenv("EXPLICITLY_LISTED_LEFS")

    use_explicitly_listed_lefs = explicitly_listed_lefs_raw is not None

    tech_file_path = os.path.join(
        pdk_root, pdk_name, "libs.tech", "klayout", f"{pdk_name}.lyt"
    )

    tech = pya.Technology()
    tech.load(tech_file_path)

    layout_options = tech.load_layout_options

    layout_options.keep_other_cells = True

    layout_options = tech.load_layout_options
    layout_options.lefdef_config.macro_resolution_mode = 1

    if use_explicitly_listed_lefs:
        explicitly_listed_lefs = explicitly_listed_lefs_raw.split(":")
        layout_options.lefdef_config.read_lef_with_def = False
        layout_options.lefdef_config.lef_files = explicitly_listed_lefs

    cell_view = win.load_layout(layout, layout_options, 0)

except Exception as e:
    print(e, file=sys.stderr)
    app.exit(-1)
