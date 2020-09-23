"""
Program to plot cell using DEF and LEF data.

Author: Tri Minh Cao
Email: tricao@utdallas.edu
Date: September 2016
"""
from def_parser import *
from lef_parser import *
import util
import matplotlib.pyplot as plt
import time

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

def draw_via(location, via_info, color='blue'):
    """
    Method to draw a via using the location and VIA info from the LEF file.
    :param location: via location
    :param via_info: VIA data from LEF file.
    :return: void
    """
    for each_layer in via_info.layers:
        # print (each_layer.name)
        if each_layer.name == 'metal2':
            color = 'red'
        elif each_layer.name == 'metal1':
            color = 'blue'
        for shape in each_layer.shapes:
            scaled_pts = scalePts(shape.points, SCALE)
            for i in range(len(scaled_pts)):
                scaled_pts[i][0] += location[0]
                scaled_pts[i][1] += location[1]
            # print (scaled_pts)
            if shape.type == "RECT":
                scaled_pts = rect_to_polygon(scaled_pts)
            # print (scaled_pts)
            draw_shape = plt.Polygon(scaled_pts, closed=True, fill=True,
                                     color=color)
            plt.gca().add_patch(draw_shape)

def plot_component(comp_name, lef_data, def_data, macro_via1_dict):
    """
    Use pyplot to plot a component from the DEF data
    :param comp_name: name of the component
    :param lef_data: data parsed from LEF file.
    :param def_data: data parsed from DEF file.
    :param macro_via_dict: dictionary contains macro and via1 data
    :return: void
    """
    # get info of the component and macro from DEF and LEF
    comp_info = def_data.components.comp_dict[comp_name]
    macro_name = comp_info.macro
    macro_info = lef_data.macro_dict[macro_name]
    macro_size = macro_info.info["SIZE"]
    scale = float(def_data.scale)
    # get the placement of the component
    bottom_left_pt = comp_info.placed
    top_right_pt = [int(macro_size[0] * scale),
                    int(macro_size[1] * scale)]
    corners = [[0, 0], top_right_pt]
    # find the vias inside the component's area
    vias_in_comp = macro_via1_dict[comp_name]
    vias_draw = []
    for pin in vias_in_comp:
        if pin != "MACRO":
            for each_via in vias_in_comp[pin]:
                each_via_loc = each_via[0]
                via_type = each_via[1]
                new_via_loc = [0, 0]
                new_via_loc[0] = each_via_loc[0] - bottom_left_pt[0]
                new_via_loc[1] = each_via_loc[1] - bottom_left_pt[1]
                if inside_area(new_via_loc, corners):
                    vias_draw.append((new_via_loc, via_type))

    # NOTE: figsize(6, 9) can be changed to adapt to other cell size
    plt.figure(figsize=(3, 5), dpi=80, frameon=False)
    # draw the cell boundary
    # scaled_pts = rect_to_polygon(corners)
    # draw_shape = plt.Polygon(scaled_pts, closed=True, fill=None,
    #                          color="blue")
    # plt.gca().add_patch(draw_shape)
    # plot vias
    for via in vias_draw:
        via_name = via[1]
        via_info = lef_data.via_dict[via_name]
        via_loc = via[0]
        draw_via(via_loc, via_info)
    # scale the axis of the subplot
    test_axis = [corners[0][0], corners[1][0], corners[0][1], corners[1][1]]
    # print (test_axis)
    plt.axis(test_axis)
    plt.axis('off')
    plt.gca().set_aspect('equal', adjustable='box')
    # plt.savefig('foo.png', bbox_inches='tight')
    # compose the output file name
    out_folder = './images/'
    current_time = time.strftime('%H%M%d%m%Y')
    out_file = comp_name + '_' + macro_name + '_' + current_time
    # plt.savefig(out_folder + out_file, transparent=True)
    plt.savefig(out_folder + out_file, transparent=False)
    # plt.show()
    plt.close('all')

def plot_component2(comp_name, lef_data, def_data, macro_via1_dict):
    """
    Use pyplot to plot a component from the DEF data
    :param comp_name: name of the component
    :param lef_data: data parsed from LEF file.
    :param def_data: data parsed from DEF file.
    :param macro_via_dict: dictionary contains macro and via1 data
    :return: void
    """
    # get info of the component and macro from DEF and LEF
    comp_info = def_data.components.comp_dict[comp_name]
    macro_name = comp_info.macro
    macro_info = lef_data.macro_dict[macro_name]
    macro_size = macro_info.info["SIZE"]
    scale = float(def_data.scale)
    # get the placement of the component
    bottom_left_pt = comp_info.placed
    top_right_pt = [bottom_left_pt[0] + int(macro_size[0] * scale),
                    bottom_left_pt[1] + int(macro_size[1] * scale)]
    corners = [bottom_left_pt, top_right_pt]
    # find the vias inside the component's area
    vias_in_comp = macro_via1_dict[comp_name]
    vias_draw = []
    for pin in vias_in_comp:
        if pin != "MACRO":
            for each_via in vias_in_comp[pin]:
                each_via_loc = each_via[0]
                via_type = each_via[1]
                # new_via_loc = [0, 0]
                # new_via_loc[0] = each_via_loc[0]
                # new_via_loc[1] = each_via_loc[1]
                if inside_area(each_via_loc, corners):
                    vias_draw.append((each_via_loc, via_type))

    # sort the vias by x-coordinate
    vias_draw.sort(key=lambda x: x[0][0])
    # print (vias_draw)
    # NOTE: figsize(6, 9) can be changed to adapt to other cell size
    plt.figure(figsize=(1, 1.6), dpi=80, frameon=False)
    margin = 350
    left_pt = [vias_draw[0][0][0] - margin, bottom_left_pt[1]]
    width = vias_draw[-1][0][0] - left_pt[0] + margin
    height = macro_size[1] * scale
    # print (height)
    corners = [left_pt]
    corners.append((left_pt[0] + width, left_pt[1] + height))
    # draw the cell boundary
    # scaled_pts = rect_to_polygon(corners)
    # draw_shape = plt.Polygon(scaled_pts, closed=True, fill=None,
    #                          color="blue")
    # plt.gca().add_patch(draw_shape)
    # plot vias
    for via in vias_draw:
        via_name = via[1]
        via_info = lef_data.via_dict[via_name]
        via_loc = via[0]
        draw_via(via_loc, via_info)

    # scale the axis of the subplot
    axis = [corners[0][0], corners[1][0], corners[0][1], corners[1][1]]
    # print (test_axis)
    plt.axis(axis)
    plt.axis('off')
    plt.gca().set_aspect('equal', adjustable='box')
    # plt.savefig('foo.png', bbox_inches='tight')
    # compose the output file name
    out_folder = './images/'
    current_time = time.strftime('%H%M%S%d%m%Y')
    out_file = comp_name + '_' + macro_name + '_' + current_time
    # plt.savefig(out_folder + out_file, transparent=True)
    plt.savefig(out_folder + out_file, transparent=False)
    # plt.show()
    plt.close('all')

# Main Class
if __name__ == '__main__':
    # read_path = './libraries/DEF/c1908_tri_no_metal1.def'
    read_path = './libraries/layout_freepdk45/c3540.def'
    def_parser = DefParser(read_path)
    def_parser.parse()

    lef_file = "./libraries/FreePDK45/gscl45nm.lef"
    lef_parser = LefParser(lef_file)
    lef_parser.parse()

    print ("Process file:", read_path)
    # test macro and via (note: only via1)
    macro_via1_dict = macro_and_via1(def_parser, via_type="M2_M1_via")
    # for comp in macro_via1_dict:
    #     print (comp)
    #     for pin in macro_via1_dict[comp]:
    #         print ("    " + pin + ": " + str(macro_via1_dict[comp][pin]))
    #     print ()
    # plot_component("U521", lef_parser, def_parser, macro_via1_dict)
    num_comps = 0
    for each_comp in macro_via1_dict:
        comp_info = def_parser.components.comp_dict[each_comp]
        # if (comp_info.macro == "INVX8"):
        print (each_comp)
        plot_component2(each_comp, lef_parser, def_parser, macro_via1_dict)
        num_comps += 1
        # if num_comps > 20:
        #     break
    print ("Finished!")
    # plot_component("U4068", lef_parser, def_parser, macro_via1_dict)

