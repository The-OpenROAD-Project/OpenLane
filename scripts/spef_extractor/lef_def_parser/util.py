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


def nCr(n,r):
    f = math.factorial
    return f(n) / f(r) / f(n-r)


def str_to_list(s):
    """
    Function to turn a string separated by space into list of words
    :param s: input string
    :return: a list of words
    """
    result = s.split()
    # check if the last word is ';' and remove it
    #if len(result) >= 1:
    #    if result[len(result) - 1] == ";":
    #        result.pop()
    return result

def scalePts(pts, alpha):
    """
    scale a list of points
    :return:
    """
    scaled = []
    for pt in pts:
        scaled_pt = [alpha*pt[0], alpha*pt[1]]
        scaled.append(scaled_pt)
    return scaled

def rect_to_polygon(rect_pts):
    """
    Convert the rect point list into polygon point list (for easy plotting)
    :param pts:
    :return:
    """
    poly_pt = []
    pt1 = list(rect_pts[0])
    poly_pt.append(pt1)
    pt2 = [rect_pts[0][0], rect_pts[1][1]]
    poly_pt.append(pt2)
    pt3 = list(rect_pts[1])
    poly_pt.append(pt3)
    pt4 = [rect_pts[1][0], rect_pts[0][1]]
    poly_pt.append(pt4)
    return poly_pt


def split_parentheses(info):
    """
    make all strings inside parentheses a list
    :param s: a list of strings (called info)
    :return: info list without parentheses
    """
    # if we see the "(" sign, then we start adding stuff to a temp list
    # in case of ")" sign, we append the temp list to the new_info list
    # otherwise, just add the string to the new_info list
    new_info = []
    make_list = False
    current_list = []
    for idx in range(len(info)):
        if info[idx] == "(":
            make_list = True
        elif info[idx] == ")":
            make_list = False
            new_info.append(current_list)
            current_list = []
        else:
            if make_list:
                current_list.append(info[idx])
            else:
                new_info.append(info[idx])
    return new_info


def split_plus(line):
    """
    Split a line according to the + (plus) sign.
    :param line:
    :return:
    """
    new_line = line.split("+")
    return new_line

def split_space(line):
    """
    Split a line according to space.
    :param line:
    :return:
    """
    new_line = line.split()
    return new_line


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

def compare_metal(metal_a, metal_b):
    """
    Compare metal layers
    :param metal_a: the first metal layer description
    :param metal_b: the second metal layer description
    :return:
    """
    if metal_a == "poly":
        if metal_b == "poly":
            return 0
        else:
            return -1
    else:
        if metal_b == "poly":
            return 1
        else:
            metal_a_num = get_metal_num(metal_a)
            metal_b_num = get_metal_num(metal_b)
            return (metal_a_num - metal_b_num)


def get_metal_num(metal):
    """
    Get mental layer number from a string, such as "metal1" or "metal10"
    :param metal: string that describes the metal layer
    :return: metal number
    """
    len_metal = len("metal")
    parse_num = ""
    for idx in range(len_metal, len(metal)):
        parse_num += metal[idx]
    return int(parse_num)


def inside_area(location, corners):
    """
    Check if the location is inside an area.
    :param location: location
    :param corners: corner points of the rectangle area.
    :return:
    """
    x1 = corners[0][0]
    x2 = corners[1][0]
    y1 = corners[0][1]
    y2 = corners[1][1]
    return (location[0] > x1 and location[0] < x2
            and location[1] > y1 and location[1] < y2)


def relocate_area(left_pt, corners):
    """
    Relocate the corners based on the new bottom left point
    :param left_pt:
    :param corners:
    :return:
    """
    x = left_pt[0]
    y = left_pt[1]
    new_corners = []
    for each in corners:
        new_pt = [each[0] + x, each[1] + y]
        new_corners.append(new_pt)
    return new_corners


def macro_and_via1(def_info, via_type):
    """
    Method to get macros/cells info and via1 information.
    :param def_info: information from a DEF file
    :param via_type: the name of the via type, such as "via1" or "M2_M1_via"
    :return: a macro dictionary that contains via info
    """
    result_dict = {}
    # add components to the dictionary
    for each_comp in def_info.components.comps:
        result_dict[each_comp.name] = {}
        result_dict[each_comp.name]["MACRO"] = each_comp.macro
    # process the nets
    for net in def_info.nets.nets:
        for route in net.routed:
            if route.end_via != None:
                # check for the via type of the end_via
                if route.end_via[:len(via_type)] == via_type:
                    via_loc = route.end_via_loc
                    via_name = route.end_via
                    via_info = (via_loc, via_name)
                    # add the via to the component dict
                    for each_comp in net.comp_pin:
                        comp_name = each_comp[0]
                        pin_name = each_comp[1]
                        if comp_name in result_dict:
                            if pin_name in result_dict[comp_name]:
                                result_dict[comp_name][pin_name].append(via_info)
                            else:
                                result_dict[comp_name][pin_name] = [via_info]
    #print (result_dict)
    return result_dict


def predict_score(predicts, actuals):
    """
    Find the number of correct cell predictions.
    :param predicts: a list of predictions.
    :param actuals: a list of actual cells.
    :return: # correct predictions, # cells
    """
    len_preds = len(predicts)
    len_actuals = len(actuals)
    shorter_len = min(len_preds, len_actuals)
    gap_predict = 0
    gap_actual = 0
    num_correct = 0
    # print (shorter_len)
    for i in range(shorter_len):
        # print (i)
        # print (gap_predict)
        # print (gap_actual)
        # print ()
        if predicts[i + gap_predict] == actuals[i + gap_actual]:
            num_correct += 1
        else:
            if len_preds < len_actuals:
                gap_actual += 1
                len_preds += 1
            elif len_preds > len_actuals:
                gap_predict += 1
                len_actuals += 1
    return num_correct, len(actuals)


def get_all_vias(def_info, via_type):
    """
    method to get all vias of the via_type and put them in a list
    :param def_info: DEF data
    :param via_type: via type
    :return: a list of all vias
    """
    vias = []
    # process the nets
    for net in def_info.nets.nets:
        for route in net.routed:
            if route.end_via != None:
                # check for the via type of the end_via
                if route.end_via[:len(via_type)] == via_type:
                    via_loc = route.end_via_loc
                    via_name = route.end_via
                    default_via_type = -1 # 0 = input, 1 = output
                    via_info = [via_loc, via_name, net.name, default_via_type]
                    # add a via to the vias list
                    vias.append(via_info)
    #print (result_dict)
    return vias

def sort_vias_by_row(layout_area, row_height, vias):
    """
    Sort the vias by row
    :param layout_area: a list [x, y] that stores the area of the layout
    :param vias: a list of vias that need to be sorted
    :return: a list of rows, each containing a list of vias in that row.
    """
    num_rows = layout_area[1] // row_height + 1
    rows = []
    for i in range(num_rows):
        rows.append([])
    for via in vias:
        via_y = via[0][1]
        row_dest = via_y // row_height
        rows[row_dest].append(via)
    # sort vias in each row based on x-coordinate
    for each_row in rows:
        each_row.sort(key = lambda x: x[0][0])
    return rows


def randomize(dataset, labels):
    permutation = np.random.permutation(labels.shape[0])
    shuffled_dataset = dataset[permutation, :]
    shuffled_labels = labels[permutation]
    return shuffled_dataset, shuffled_labels


def group_via(via_list, max_number, max_distance):
    """
    Method to group the vias together to check if they belong to a cell.
    :param via_list: a list of all vias.
    :return: a list of groups of vias.
    """
    groups = []
    length = len(via_list)
    for i in range(length):
        # one_group = [via_list[i]]
        curr_via = via_list[i]
        curr_list = []
        for j in range(2, max_number + 1):
            if i + j - 1 < length:
                right_via = via_list[i + j - 1]
                dist = right_via[0][0] - curr_via[0][0]
                if dist < max_distance:
                    curr_list.append(via_list[i:i+j])
        # only add via group list that is not empty
        if len(curr_list) > 0:
            groups.append(curr_list)
    return groups


def sorted_components(layout_area, row_height, comps):
    """
    Sort the components by row
    :param layout_area: a list [x, y] that stores the area of the layout
    :param comps: a list of components that need to be sorted
    :return: a list of rows, each containing a list of components in that row.
    """
    num_rows = layout_area[1] // row_height + 1
    rows = []
    for i in range(num_rows):
        rows.append([])
    for comp in comps:
        comp_y = comp.placed[1]
        row_dest = comp_y // row_height
        rows[row_dest].append(comp)
    # sort vias in each row based on x-coordinate
    for each_row in rows:
        each_row.sort(key = lambda x: x.placed[0])
    return rows
