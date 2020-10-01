"""
Useful functions for DEF/LEF parsers.
Author: Tri Minh Cao
Email: tricao@utdallas.edu
Date: August 2016
"""

SCALE = 2000
import matplotlib.pyplot as plt
import numpy as np
import math


def draw_obs(obs, color):
    """
    Helper method to draw a OBS object
    :return: void
    """
    # process each Layer
    for layer in obs.info["LAYER"]:
        for shape in layer.shapes:
            scaled_pts = scalePts(shape.points, SCALE)
            if (shape.type == "RECT"):
                scaled_pts = rect_to_polygon(scaled_pts)
            draw_shape = plt.Polygon(scaled_pts, closed=True, fill=True,
                                     color=color)
            plt.gca().add_patch(draw_shape)


def draw_port(port, color):
    """
    Helper method to draw a PORT object
    :return: void
    """
    # process each Layer
    for layer in port.info["LAYER"]:
        for shape in layer.shapes:
            scaled_pts = scalePts(shape.points, SCALE)
            if (shape.type == "RECT"):
                scaled_pts = rect_to_polygon(scaled_pts)
            #print (scaled_pts)
            draw_shape = plt.Polygon(scaled_pts, closed=True, fill=True,
                                     color=color)
            plt.gca().add_patch(draw_shape)


def draw_pin(pin):
    """
    function to draw a PIN object
    :param pin: a pin object
    :return: void
    """
    # chosen color of the PIN in the sketch

    color = "blue"
    pin_name = pin.name.lower()
    if pin_name == "vdd" or pin_name == "gnd":
        color = "blue"
    else:
        color = "red"
    draw_port(pin.info["PORT"], color)

def draw_macro(macro):
    """
    function to draw a Macro (cell) object
    :param macro: a Macro object
    :return: void
    """
    # draw OBS (if it exists)
    if "OBS" in macro.info:
        draw_obs(macro.info["OBS"], "blue")
    # draw each PIN
    for pin in macro.info["PIN"]:
        draw_pin(pin)

def draw_cells():
    """
    code to draw cells based on LEF information.
    :return: void
    """
    to_draw = []
    to_draw.append(input("Enter the first macro: "))
    to_draw.append(input("Enter the second macro: "))
    #to_draw = ["AND2X1", "AND2X2"]


    plt.figure(figsize=(12, 9), dpi=80)
    plt.axes()

    num_plot = 1
    for macro_name in to_draw:
        # check user's input
        if macro_name not in lef_parser.macro_dict:
            print ("Error: This macro does not exist in the parsed library.")
            quit()
        macro = lef_parser.macro_dict[macro_name]
        sub = plt.subplot(1, 2, num_plot)
        # need to add title
        sub.set_title(macro.name)
        draw_macro(macro)
        num_plot += 1
        # scale the axis of the subplot
        plt.axis('scaled')


    # start drawing
    print ("Start drawing...")
    plt.show()
