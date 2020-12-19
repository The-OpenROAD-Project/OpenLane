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

layout_view.save_image(input_layout+".png", WIDTH, HEIGHT)

app.exit(0)
