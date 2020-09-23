"""
DEF Splitter for Split Manufacturing
Author: Tri Minh Cao
Email: tricao@utdallas.edu
Date: August 2016
"""
from def_parser import *
from lef_parser import *

def proper_layers(back_end, front_end, split_layer):
    layers = set()
    if back_end == False and front_end == False:
        return layers
    elif back_end == True and front_end == False:
        for each in LAYERS:
            if compare_metal(each, split_layer) >= 0:
                layers.add(each)
        return layers
    elif back_end == False and front_end == True:
        for each in LAYERS:
            if compare_metal(each, split_layer) < 0:
                layers.add(each)
        return layers
    else:
        return LAYERS

# names of back-end and front-end layers
LAYERS = {"poly", "metal1", "metal2", "metal3", "metal4", "metal5", "metal6",
          "metal7", "metal8", "metal9", "metal10"}


# outside function needed to output the NETS data selectively, because
# possibly we need to check LEF data and that requires bigger scope.
def output_nets(nets, def_info, lef_info):
    """
    Output the NETS section information with possible back end and front
    end selections.
    :param def_info: a DefParser object that contains DEF info.
    :param lef_info: a LefParser object
    :return: string
    """
    s = ""
    # add each net's data to nets_str
    nets_str = ""
    num_nets = 0
    for net in nets.nets:
        net_data = output_net(net, def_info, lef_info)
        if net_data != "":
            nets_str += net_data
            nets_str += "\n"
            num_nets += 1
    if num_nets > 0:
        s += "NETS " + str(num_nets) + " ;\n"
        s += nets_str
        s += "END NETS"
    return s


def output_net_routes(net, def_info, lef_info):
    """
    Return None if there are no routes in the
    :param net: a Net object
    :param def_info: a DefParser object that contains DEF info.
    :param lef_info: a LefParser object
    :return: routes if good route exists, None if no route available.
    """
    s = ""
    # output routes
    num_route = 0
    first_route_done = False
    for i in range(len(net.routed)):
        if net.routed[i].get_layer() in GOOD_LAYERS:
            num_route += 1
            if first_route_done:
                s += "    " + "NEW " + net.routed[i].to_def_format() + "\n"
            else:
                s += "  + ROUTED " + net.routed[i].to_def_format() + "\n"
                first_route_done = True
    if num_route == 0:
        return "no route"
    else:
        return s

def output_net(net, def_info, lef_info):
    """
    Output a Net object inside the NETS section information with possible back
    end and front end selections.
    :param def_info: a DefParser object that contains DEF info.
    :param lef_info: a LefParser object
    :return: string
    """
    # check number of routes and get the routes
    routes = output_net_routes(net, def_info, lef_info)
    if routes == "no route":
        routes = ""
    # start setting up the string
    s = ""
    s += "- " + net.name + "\n"
    s += " "
    for each_comp in net.comp_pin:
        # study each comp/pin
        # if it's a pin, check the Pin object layer (already parsed)
        if each_comp[0] == "PIN":
            pin_name = each_comp[1]
            if def_info.pins.get_pin(pin_name).get_metal_layer() in GOOD_LAYERS:
                s += " ( " + " ".join(each_comp) + " )"
        else:
            # for component, need to check LEF info
            comp_id = each_comp[0]
            pin_name = each_comp[1]
            comp = def_info.components.get_comp(comp_id).get_macro()
            #print (comp)
            # get info from LEF Parser
            comp_info = lef_info.macro_dict[comp]
            # get pin layer info
            pin_info = comp_info.pin_dict[pin_name]
            if pin_info.get_top_metal() in GOOD_LAYERS:
                s += " ( " + " ".join(each_comp) + " )"
    # output routes
    s += "\n"
    s += routes
    s += " ;"
    return s

def output_comps(comps):
    """
    Method to write/output a component to the DEF file
    :param comp: component to be written
    :param def_info: DEF file data
    :param lef_info: LEF file data
    :return: a string that contains Components section in DEF format.
    """
    # assume all components are in bottom layers
    if "metal1" in GOOD_LAYERS:
        return comps.to_def_format()
    else:
        return ""

def output_pin(pin, def_info):
    """
    Method to write/output a pin to the DEF file
    :param pin: Pin object
    :param def_info: DEF data
    :return: a string that contains a Pin in DEF format.
    """
    #print (pin.get_layer())
    if pin.get_metal_layer() in GOOD_LAYERS:
        return pin.to_def_format()
    else:
        s = ""
        s += "- " + pin.name + " + NET " + pin.net
        s += " + DIRECTION " + pin.direction + " + USE " + pin.use + "\n ;"
        return s

def output_pins(pins, def_info):
    """
    Method to write/output the PINS section to the DEF file.
    :param pins: Pin object
    :param def_info: DEF data
    :return: a tring that contains the PINS section in DEF format
    """
    s = ""
    num_pins = 0
    pins_string = ""
    for each_pin in pins.pins:
        pin_data = output_pin(each_pin, def_info)
        pins_string += pin_data
        pins_string += "\n"
        # only count the pin that has proper metal layer
        if each_pin.get_metal_layer() in GOOD_LAYERS:
            num_pins += 1
    # only write PINS section when we have > 0 pins
    s = "PINS " + str(num_pins) + " ;\n"
    s += pins_string
    s += "END PINS"
    return s

def output_tracks(def_info):
    """
    Method to write/output TRACKS to DEF file.
    :param def_info: DEF data
    :return: a string that contains TRACKS info in DEF format.
    """
    s = ""
    for track in def_info.tracks:
        if track.get_layer() in GOOD_LAYERS:
            s += track.to_def_format()
            s += "\n"
    return s

def output_new_def(def_info, lef_info):
    """
    Output DEF data to new DEF file with selected metal layers.
    :param def_info: DEF data
    :param lef_info: LEF data
    :return: a string that contains new DEF data in DEF format.
    """
    s = ""
    s += "#  Generated by tricao@utdallas.edu for testing only.\n"
    s += "#  Included Metal Layers:"
    for each in GOOD_LAYERS:
        s += " " + each
    s += "\n\n"
    s += "VERSION " + def_info.version + " ;" + "\n"
    s += "DIVIDERCHAR " + def_info.dividerchar + " ;" + "\n"
    s += "BUSBITCHARS " + def_info.busbitchars + " ;" + "\n"
    s += "DESIGN " + def_info.design_name + " ;" + "\n"
    s += "UNITS DISTANCE " + def_info.units + " " + def_info.scale + " ;" + "\n"
    s += "\n"
    props = def_info.property
    s += props.to_def_format()
    s += "\n"
    s += "DIEAREA"
    s += (" ( " + str(def_info.diearea[0][0]) + " " + str(def_info.diearea[0][1]) +
          " )")
    s += (" ( " + str(def_info.diearea[1][0]) + " " + str(def_info.diearea[1][1]) +
          " )" + " ;")
    s += "\n\n"
    for each_row in def_info.rows:
        s += each_row.to_def_format()
        s += "\n"
    s += "\n"
    s += output_tracks(def_info)
    s += "\n"
    for each_gcell in def_info.gcellgrids:
        s += each_gcell.to_def_format()
        s += "\n"
    s += "\n"
    comps = def_parser.components
    s += output_comps(comps)
    s += "\n\n"
    pins = def_parser.pins
    s += output_pins(pins, def_info)
    s += "\n\n"
    nets = def_parser.nets
    s += output_nets(nets, def_info, lef_info)
    return s

def to_bool(str):
    if str.lower() == "false":
        return False
    else:
        return bool(str)

# Main Class
if __name__ == '__main__':
    # default settings
    BACK_END = True
    FRONT_END = True
    SPLIT_LAYER = "metal2"
    OUTPUT_FILE = "./def_write/test.def"
    INPUT_FILE = "./libraries/DEF/c1908.def"
    # load last setup from split_def.ini
    print ("Last setup: ")
    last_setup = open("split_def.ini", "r")
    for line in last_setup:
        print (line[:-1])
        text = line.split()
        if text[0] == "BACK_END":
            BACK_END = to_bool(text[2])
        elif text[0] == "FRONT_END":
            FRONT_END = to_bool(text[2])
        elif text[0] == "SPLIT_LAYER":
            SPLIT_LAYER = text[2]
        elif text[0] == "OUTPUT_FILE_NAME":
            OUTPUT_FILE = text[2]
        elif text[0] == "INPUT_FILE_NAME":
            INPUT_FILE = text[2]

    print ()
    last_setup.close()

    use_last_setup = input("Use last setup? (y/n): ")
    if use_last_setup == "n":
        input_name = input("Enter input DEF file path: ")
        INPUT_FILE = input_name
        # user will choose whether to keep back_end and/or front_end
        write_back_end = input("Want bottom layers? (y/n): ")
        if write_back_end == "n":
            FRONT_END = False
        else:
            FRONT_END = True
        write_front_end = input("Want top layers? (y/n): ")
        if write_front_end == "n":
            BACK_END = False
        else:
            BACK_END = True
        SPLIT_LAYER = input("Split layer? (choices from metal1 to metal10): ")
        if SPLIT_LAYER not in LAYERS:
            SPLIT_LAYER = "metal2"
        output_name = input("Enter DEF output file path: ")
        OUTPUT_FILE = output_name
        # write current settings to a file
        setup_file = open("split_def.ini", "w+")
        setup_file.write("INPUT_FILE_NAME = " + input_name +"\n")
        setup_file.write("BACK_END = " + str(BACK_END) + "\n")
        setup_file.write("FRONT_END = " + str(FRONT_END) + "\n")
        setup_file.write("SPLIT_LAYER = " + SPLIT_LAYER + "\n")
        setup_file.write("OUTPUT_FILE_NAME = " + output_name +"\n")
        setup_file.close()
    else:
        print ("The program will use the last setup listed above.")

    #print (BACK_END)
    #print (FRONT_END)
    #print (SPLIT_LAYER)

    # need to know what layers are good for the current back-end and
    # front-end settings
    GOOD_LAYERS = proper_layers(BACK_END, FRONT_END, SPLIT_LAYER)

    print ()
    lef_file = "./libraries/Nangate/NangateOpenCellLibrary.lef"
    lef_parser = LefParser(lef_file)
    lef_parser.parse()
    print ()
    def_file = INPUT_FILE
    def_parser = DefParser(def_file)
    def_parser.parse()
    print ("Writing data to new DEF file with path: " + OUTPUT_FILE )
    out_file = open(OUTPUT_FILE, "w+")
    out_file.write(output_new_def(def_parser, lef_parser))
    out_file.close()
    print ("Writing data done.")
