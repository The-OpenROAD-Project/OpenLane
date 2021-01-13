# Copyright 2020 Efabless Corporation
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

import pya
import re

WIDTH = 2048
HEIGHT = 2048

app = pya.Application.instance()
win = app.main_window()

# Load technology file
tech = pya.Technology()
tech.load(tech_file)
layoutOptions = tech.load_layout_options

# Load def file in the main window
cell_view = win.load_layout(input_layout, layoutOptions, 0)
layout_view = cell_view.view()

layout_view.max_hier()
# layout_view.clear_layers()

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

layout_view.save_image(input_layout+".png", WIDTH, HEIGHT)

app.exit(0)
