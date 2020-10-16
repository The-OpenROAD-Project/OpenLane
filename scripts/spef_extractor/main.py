# MIT License
#
# Copyright (c) 2019 HanyMoussa
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

'''
Authors:
    Ramez Moussa
    Hany Moussa
'''

import argparse
import datetime
from lef_def_parser.def_parser import DefParser
from lef_def_parser.lef_parser import LefParser


class SpefExtractor:
    def __init__(self):
        self.def_parser = None
        self.lef_parser = None
        self.l2d = None
        self.vias_dict_def = {}
        self.capacitanceFactor = 1
        self.capCounter = 0
        self.resCounter = 0
        self.pinCounter = 0

    # this extracts the vias and viarules definied in the def file given the lines in which the vias are defined
    def extractViasFromDef(self, vias_data):
        self.vias_dict_def = {}
        vias = {}
        for line in vias_data:
            words = line.strip().split()
            if words:
                if words[0] == '-':
                    current_via_name = words[1]
                    vias[current_via_name] = []
                elif words[0] != ';':
                    vias[current_via_name].append(words)

        for via, lines in vias.items():
            current_via = {}
            if lines[0][1].lower() == 'viarule':
                for line in lines:
                    current_via[line[1]] = line[2:]
            else:
                layers = []
                for line in lines:
                    layers.append(line[2])
                current_via['LAYERS'] = layers
            self.vias_dict_def[via] = current_via

    # name mapping method that reduces all net names in order to minimize the SPEF size
    def remap_names(self):
        name_counter = 0
        map_of_names = []
        for key, val in self.def_parser.nets.net_dict.items():
            name = val.name
            abbrev = "*" + str(name_counter)
            val.name = abbrev
            name_counter += 1
            map_of_names.append((name, abbrev))
        return map_of_names

    # printing the keys of the name map into the SPEF file
    def printNameMap(self, f, map_of_names):
        f.write('*NAME_MAP\n')
        for name, abbrev in map_of_names:
            f.write(abbrev + " " + name + "\n")
        f.write("\n")

    # A method that takes an instance and a pin and returns a list of all
    # rectangles of that pin
    def getPinLocation(self, instanceName, pinName, metalLayer):
        inst = self.def_parser.components.comp_dict[instanceName]
        origin = inst.placed
        orientation = inst.orient
        cellType = inst.macro
        size = self.lef_parser.macro_dict[cellType].info['SIZE']
        cellWidth = size[0] * self.l2d
        cellHeight = size[1] * self.l2d

        pinObject = self.lef_parser.macro_dict[cellType].pin_dict[pinName]
        port_info = pinObject.info['PORT'].info['LAYER'][0]
        res = []

        if orientation == 'N':
            for shape in port_info.shapes:
                llx = shape.points[0][0]*self.l2d + origin[0]
                lly = shape.points[0][1]*self.l2d + origin[1]
                urx = shape.points[1][0]*self.l2d + origin[0]
                ury = shape.points[1][1]*self.l2d + origin[1]
                ll = (llx, lly)
                ur = (urx, ury)
                res.append((ll, ur, metalLayer))

        elif orientation == 'S':
            # consider origin to be top right corner
            rotatedOrigin = (origin[0]+cellWidth, origin[1] + cellHeight)
            for shape in port_info.shapes:
                llx = rotatedOrigin[0] - shape.points[1][0]*self.l2d
                lly = rotatedOrigin[1] - shape.points[1][1]*self.l2d
                urx = rotatedOrigin[0] - shape.points[0][0]*self.l2d
                ury = rotatedOrigin[1] - shape.points[0][1]*self.l2d
                ll = (llx, lly)
                ur = (urx, ury)
                res.append((ll, ur, metalLayer))

        elif orientation == 'W':
            # consider origin to be bottom right corner
            rotatedOrigin = (origin[0]+cellHeight, origin[1])
            for shape in port_info.shapes:
                lrx = rotatedOrigin[0] - shape.points[0][1]*self.l2d
                lry = rotatedOrigin[1] + shape.points[0][0]*self.l2d
                ulx = rotatedOrigin[0] - shape.points[1][1]*self.l2d
                uly = rotatedOrigin[1] + shape.points[1][0]*self.l2d

                ll = (ulx, lry)
                ur = (lrx, uly)
                res.append((ll, ur, metalLayer))

        elif orientation == 'E':
            # consider origin to be top left corner
            rotatedOrigin = (origin[0], origin[1]+cellWidth)
            for shape in port_info.shapes:
                ulx = rotatedOrigin[0] + shape.points[0][1]*self.l2d
                uly = rotatedOrigin[1] - shape.points[0][0]*self.l2d
                lrx = rotatedOrigin[0] + shape.points[1][1]*self.l2d
                lry = rotatedOrigin[1] - shape.points[1][0]*self.l2d

                ll = (ulx, lry)
                ur = (lrx, uly)
                res.append((ll, ur, metalLayer))

        elif orientation == 'FN':
            # consider origin to be bottom right corner
            rotatedOrigin = (origin[0]+cellWidth, origin[1])
            for shape in port_info.shapes:
                lrx = rotatedOrigin[0] - shape.points[0][0]*self.l2d
                lry = rotatedOrigin[1] + shape.points[0][1]*self.l2d
                ulx = rotatedOrigin[0] - shape.points[1][0]*self.l2d
                uly = rotatedOrigin[1] + shape.points[1][1]*self.l2d

                ll = (ulx, lry)
                ur = (lrx, uly)
                res.append((ll, ur, metalLayer))

        elif orientation == 'FS':
            # consider origin to be upper left corner
            rotatedOrigin = (origin[0], origin[1]+cellHeight)
            for shape in port_info.shapes:
                lrx = rotatedOrigin[0] + shape.points[1][0]*self.l2d
                lry = rotatedOrigin[1] - shape.points[1][1]*self.l2d
                ulx = rotatedOrigin[0] + shape.points[0][0]*self.l2d
                uly = rotatedOrigin[1] - shape.points[0][1]*self.l2d

                ll = (ulx, lry)
                ur = (lrx, uly)
                res.append((ll, ur, metalLayer))

        elif orientation == 'FW':
            # consider origin to be bottom left corner
            rotatedOrigin = (origin[0], origin[1])
            for shape in port_info.shapes:
                llx = rotatedOrigin[0] + shape.points[0][1]*self.l2d
                lly = rotatedOrigin[1] + shape.points[0][0]*self.l2d
                urx = rotatedOrigin[0] + shape.points[1][1]*self.l2d
                ury = rotatedOrigin[1] + shape.points[1][0]*self.l2d

                ll = (llx, lly)
                ur = (urx, ury)
                res.append((ll, ur, metalLayer))

        elif orientation == 'FE':
            # consider origin to be top right corner
            rotatedOrigin = (origin[0] + cellHeight, origin[1] + cellWidth)
            for shape in port_info.shapes:
                llx = rotatedOrigin[0] - shape.points[1][1]*self.l2d
                lly = rotatedOrigin[1] - shape.points[1][0]*self.l2d
                urx = rotatedOrigin[0] - shape.points[0][1]*self.l2d
                ury = rotatedOrigin[1] - shape.points[0][0]*self.l2d

                ll = (llx, lly)
                ur = (urx, ury)
                res.append((ll, ur, metalLayer))

        return res

    # method to extract the via type by its name fromt the lef file
    def getViaType(self, via):
        # this 'met' and 'li1' have to be handeled design by design.
        if via in self.lef_parser.via_dict:
            viaLayers = self.lef_parser.via_dict[via].layers
            firstLayer = viaLayers[0].name
            secondLayer = viaLayers[1].name
            thirdLayer = viaLayers[2].name

        elif via in self.vias_dict_def:
            viaLayers = self.vias_dict_def[via]['LAYERS']
            firstLayer = viaLayers[0]
            secondLayer = viaLayers[1]
            thirdLayer = viaLayers[2]

        if self.lef_parser.layer_dict[firstLayer].layer_type == 'CUT':
            return (secondLayer, firstLayer, thirdLayer)

        if self.lef_parser.layer_dict[secondLayer].layer_type == 'CUT':
            return (firstLayer, secondLayer, thirdLayer)

        if self.lef_parser.layer_dict[thirdLayer].layer_type == 'CUT':
            return (firstLayer, thirdLayer, secondLayer)

        # There must be a cut layer in a via
        assert False

    # method to get the resistance of a via
    def get_via_resistance_modified(self, via_layer):
        # return 0 if u cannot find the target via in the LEF file.
        return self.lef_parser.layer_dict[via_layer].resistance or 0

    # method to get the resistance of a certain segment using
    # its length (distance between 2 points) and info from the lef file
    # point is a list of (x, y)
    def get_wire_resistance_modified(self, point1, point2, layer_name):
        layer = self.lef_parser.layer_dict[layer_name]
        rPerSquare = layer.resistance[1]
        width = layer.width  # width in microns
        wire_len = (abs(point1[0] - point2[0]) + abs(point1[1] - point2[1]))/1000  # length in microns
        resistance = wire_len * rPerSquare / width  # R in ohms
        return resistance

    # method to get the capacitance of a via
    def get_via_capacitance_modified(self, via_type):
        return self.lef_parser.layer_dict[via_type].edge_cap or 0

    # method to get the capacitance of a certain segment using
    # its length (distance between 2 points) and info from the lef file
    # point is a list of (x, y)
    def get_wire_capacitance_modified(self, point1, point2, layer_name):
        capacitance = 0.0  # in pF
        layer = self.lef_parser.layer_dict[layer_name]
        # width and length in microns
        width = layer.width
        length = (abs(point1[0] - point2[0]) + abs(point1[1] - point2[1]))/1000
        if layer.capacitance is not None:
            cPerSquare = self.capacitanceFactor * layer.capacitance[1]  # unit in lef is pF
            capacitance += length * cPerSquare * width
        if layer.edge_cap is not None:
            edgeCapacitance = self.capacitanceFactor * layer.edge_cap
            capacitance += edgeCapFactor * 2 * edgeCapacitance * (length + width)
        return capacitance

    # method to look for intersetions between segment nodes in order to decide
    # on creating a new node or add to the existing capacitance
    def checkPinsTable(self, point, layer, netName, pinsTable):
        for pin in pinsTable:
            locations = pin[0]
            for location in locations:
                if(location[2] == layer
                   or (location[2] == 'met1' and layer == 'li1')
                   or (location[2] == 'li1' and layer == 'met1')):
                    if ((location[0][0] - 5 <= point[0] <= location[1][0] + 5)
                        and (location[0][1] - 5 <= point[1] <= location[1][1] + 5)):
                        return pin
        # Add a new pin
        pin = [[((point[0], point[1]),
                 (point[0], point[1]),
                 layer)],
               '{}:{}'.format(netName, self.pinCounter)]
        self.pinCounter += 1
        pinsTable.append(pin)
        return pin

    # method for creating the header of the SPEF file
    def printSPEFHeader(self, f):
        now = datetime.datetime.now()

        f.write('*SPEF "IEEE 1481-1998"' + '\n')
        f.write('*DESIGN "' + self.def_parser.design_name + '"' + '\n')
        f.write('*DATE "' + now.strftime("%a %b %d %H:%M:%S %Y") + '"\n')
        f.write('*VENDOR "AUC CSCE Department"\n')
        f.write('*PROGRAM "SPEF Extractor"\n')
        f.write('*VERSION "1.0"\n')
        f.write('*DESIGN_FLOW "PIN_CAP NONE"' + '\n')
        f.write('*DIVIDER ' + self.def_parser.dividerchar[1] + '\n')
        f.write('*DELIMITER :' + '\n')
        f.write('*BUS_DELIMITER ' + self.def_parser.busbitchars[1:3] + '\n')
        f.write('*T_UNIT 1.00000 NS' + '\n')
        f.write('*C_UNIT 1.00000 PF' + '\n')
        f.write('*R_UNIT 1.00000 OHM' + '\n')
        f.write('*L_UNIT 1.00000 HENRY' + '\n')
        f.write('\n' + '\n')

    # method to print all nets in the net dictionay
    def printSPEFNets(self, f, netsDict):
        for key, value in netsDict.items():
            self.printNet(f, value, key)

    # method to print a particular net into SPEF format
    def printNet(self, f, net, wireName):
        sumC = sum(net['cap'].values())
        print('*D_NET {} {}'.format(wireName, sumC), file=f)
        print('*CONN', file=f)
        for conn in net['conn']:
            print('{} {} {}'.format(conn[0], conn[1], conn[2]), file=f)

        print('*CAP', file=f)
        for key, value in net['cap'].items():
            print('{} {} {}'.format(self.capCounter, key, value), file=f)
            self.capCounter += 1

        print('*RES', file=f)
        for res in net['res']:
            print('{} {} {} {}'.format(self.resCounter, res[0], res[1], res[2]),
                  file=f)
            self.resCounter += 1

        print('*END\n', file=f)

    def extract_net(self, net):
        """From a DEF net extract the corresponding SPEF net"""

        # a list of the connections in the net
        conList = []
        # a list of all pins referenced in the net, including the internal nodes between each 2 segments
        pinsTable = []

        # A SPEF net is made of CONNs, capacities and resistors.
        # A CONN correspond to either an external PAD or an internal cell PIN.
        # generate the conn data structure for conn section
        for con in net.comp_pin:
            # Check if con != ';'
            if con[0] == ';':
                continue
            if con[0] == "PIN":
                # It is an external PAD
                pinName = con[1]
                x = self.def_parser.pins.get_pin(pinName)
                direction = x.direction
                pinType = "*P"

                # these are used for the pinsTable
                pin = self.def_parser.pins.pin_dict[pinName]
                pinLocation = pin.placed
                metalLayer = pin.layer.name
                locationsOfCurrentPin = [((pinLocation[0], pinLocation[1]),
                                          (pinLocation[0], pinLocation[1]),
                                          metalLayer)]
            else:
                # It is an internal pin
                cell_type = self.def_parser.components.comp_dict[con[0]].macro
                pinInfo = self.lef_parser.macro_dict[cell_type].pin_dict[con[1]]

                # check if it has a direction
                # some cells do not have direction
                direction = pinInfo.info.get("DIRECTION")
                if direction is None:
                    # check if cell has 'in' or 'out' in its name
                    if cell_type.find("in"):
                        direction = "INPUT"
                    else:
                        direction = "OUTPUT"

                pinName = con[0] + ":" + con[1]
                pinType = "*I"

                # this is used for the pins table
                metalLayer = pinInfo.info['PORT'].info['LAYER'][0].name
                locationsOfCurrentPin = self.getPinLocation(con[0], con[1], metalLayer)

            # we append list of pin locations - cellName - pinName
            pinsTable.append((locationsOfCurrentPin, pinName))
            if direction == "INPUT":
                pinDir = "I"
            else:
                pinDir = "O"
            conList.append([pinType, pinName, pinDir])

        # the value will be incremented if more than 1 segment end at
        # the same node
        self.pinCounter = 1

        # A net has a list of segments which are composed of points.
        # Each segment lies on a layer.
        # The points create multiple segments in the same layer.
        capList = {}
        resList = []
        for segment in net.routed:
            if segment.end_via == 'RECT':
                continue
            # traversing all segments in a certain net to get all their information
            for it in range(len(segment.points)):
                # Traversing all points in a certain segment, classifyng them
                # as starting and ending points and checking for their
                # existence in the pinstable, using checkPinsTable method
                myVia = None
                if it < (len(segment.points) - 1):
                    # Normal segment
                    spoint = segment.points[it]
                    epoint = segment.points[it+1]
                    layer = segment.layer
                else:
                    # last point in the line (either via or no via)
                    spoint = segment.points[it]
                    epoint = segment.points[it]
                    myVia = segment.end_via
                    # If we are at the last point and there is no via, then
                    # ignore the point as it has already been considered with
                    # the previous point
                    if myVia == ';' or myVia is None:
                        continue
                    if myVia[-1] == ';':
                        # Remove trailing ';'
                        myVia = myVia[0:-1]

                    # Special handeling for vias to get the via types
                    # through the via name
                    first, via_layer, second = self.getViaType(myVia)

                    # Select the other layer
                    if first == segment.layer:
                        layer = second
                    else:
                        layer = first

                # Get or create the start pin for the segment
                snode = self.checkPinsTable(spoint, segment.layer, net.name, pinsTable)

                enode = self.checkPinsTable(epoint, layer, net.name, pinsTable)

                # TODO: pass segment.endvia to function to be used if 2 points are equal

                if myVia:
                    resistance = self.get_via_resistance_modified(via_layer)
                    capacitance = self.get_via_capacitance_modified(via_layer)
                else:
                    resistance = self.get_wire_resistance_modified(spoint, epoint, segment.layer)
                    capacitance = self.get_wire_capacitance_modified(spoint, epoint, segment.layer)

                # the name of the first node of the segment
                snodeName = snode[1]
                # the name of the second node of the segment
                enodeName = enode[1]

                resList.append([snodeName, enodeName, resistance])

                if wireModel == 'PI':
                    # PI model: add half the capacitances at each of
                    # the endpoints of the segment to use a pi model
                    capList.setdefault(snodeName, 0)
                    capList[snodeName] += 0.5 * capacitance
                    capList.setdefault(enodeName, 0)
                    capList[enodeName] += 0.5 * capacitance
                else:
                    # L wire model:  add the capacitance of the segment
                    # at the starting node
                    capList.setdefault(snodeName, 0)
                    capList[snodeName] += capacitance

        return {'conn': conList, 'cap': capList, 'res': resList}

    def extract(self, lef_file_name, def_file_name, wireModel, edgeCapFactor):
        # We had to modify the lef parser to ignore the second
        # parameter for the offset since our files provide only 1 value
        self.lef_parser = LefParser(lef_file_name)
        self.lef_parser.parse()

        # read the def
        self.def_parser = DefParser(def_file_name)
        self.def_parser.parse()

        self.extractViasFromDef(self.def_parser.vias)

        # l2d is the conversion factor between the scale in LEF and DEF
        self.l2d = 1000  # an initial value
        if self.def_parser.scale is not None:
            self.l2d = float(self.def_parser.scale)

        # Get a factor conversion so that the unit of capacitance is PICOFARADS
        capacitanceUnit = self.lef_parser.units_dict.get('CAPACITANCE')
        self.capacitanceFactor = 1
        if capacitanceUnit is None:
            pass
        elif capacitanceUnit[0] == "NANOFARADS":
            self.capacitanceFactor = float(capacitanceUnit[1]) * 1e3
        elif capacitanceUnit[0] == "PICOFARADS":
            self.capacitanceFactor = float(capacitanceUnit[1])
        elif capacitanceUnit[0] == "FEMTOFARADS":
            self.capacitanceFactor = float(capacitanceUnit[1]) * 1e-3

        print("Parameters Used:")
        print("Edge Capacitance Factor:", edgeCapFactor)
        print("Wire model:", wireModel, '\n')

        # creation of the name map
        map_of_names = self.remap_names()

        netsDict = {}
        for net in self.def_parser.nets:
            # traversing all nets in the def file to extract segments
            # information
            netsDict[net.name] = self.extract_net(net)

        print("RC Extraction is done")

        # writing into SPEF file
        self.capCounter = 0
        self.resCounter = 0

        f = open(def_file_name[:-4] + ".spef", "w", newline='\n')
        print("Start writing SPEF file")
        self.printSPEFHeader(f)
        self.printNameMap(f, map_of_names)
        self.printSPEFNets(f, netsDict)
        f.close()

        print("Writing SPEF is done")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Create a parasitic SPEF file from def and lef files.')

    parser.add_argument('--def_file', '-d', required=True,
                        help='Input DEF')

    parser.add_argument('--lef_file', '-l', required=True,
                        help='Input LEF')

    parser.add_argument('--wire_model', '-mw', default='PI', required=False,
                        help='name of wire model')

    parser.add_argument('--edge_cap_factor', '-ec', default=1, required=False,
                        help='Edge Capacitance Factor 0 to 1')

    args = parser.parse_args()

    inst = SpefExtractor()
    lef_file_name = args.lef_file
    def_file_name = args.def_file
    wireModel = args.wire_model
    edgeCapFactor = float(args.edge_cap_factor)

    inst.extract(lef_file_name, def_file_name, wireModel, edgeCapFactor)
