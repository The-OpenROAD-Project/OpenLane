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
        self.bigCapacitanceTable = {}
        self.capCounter = 0
        self.resCounter = 0

    # this extracts the vias and viarules definied in the def file given the lines in which the vias are defined
    def extractViasFromDef(self, vias_data):
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
        for key in self.def_parser.nets.net_dict:
            name = self.def_parser.nets.net_dict[key].name
            abbrev = "*" + str(name_counter)
            self.def_parser.nets.net_dict[key].name = abbrev
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
            firstLayer = self.lef_parser.via_dict[via].layers[0].name
            secondLayer = self.lef_parser.via_dict[via].layers[1].name
            thirdLayer = self.lef_parser.via_dict[via].layers[2].name
        elif via in self.vias_dict_def:
            firstLayer = self.vias_dict_def[via]['LAYERS'][0]
            secondLayer = self.vias_dict_def[via]['LAYERS'][1]
            thirdLayer = self.vias_dict_def[via]['LAYERS'][2]

        if self.lef_parser.layer_dict[firstLayer].layer_type == 'CUT':
            cutLayer = firstLayer

        if self.lef_parser.layer_dict[secondLayer].layer_type == 'CUT':
            cutLayer = secondLayer

        if self.lef_parser.layer_dict[thirdLayer].layer_type == 'CUT':
            cutLayer = thirdLayer

        return cutLayer

    # method to get the resistance of a certain segment (wire of via) using
    # its length (distance between 2 points) and info from the lef file
    # point is a list of (x, y)
    def get_resistance_modified(self, point1, point2, layer_name, via_type):

        if point1 == point2:
            # we have a via
            if self.lef_parser.layer_dict[via_type].resistance is not None:
                return self.lef_parser.layer_dict[via_type].resistance
            else:
                return 0  # return 0 if u cannot find the target via in the LEF file.
        else:
            # we have a wire
            rPerSquare = self.lef_parser.layer_dict[layer_name].resistance[1]

            width = self.lef_parser.layer_dict[layer_name].width  # width in microns
            wire_len = (abs(point1[0] - point2[0]) + abs(point1[1] - point2[1]))/1000  # length in microns
            resistance = wire_len * rPerSquare / width  # R in ohms

            return resistance

    # method to get the capacitance of a certain segment (wire of via) using
    # its length (distance between 2 points) and info from the lef file
    # point is a list of (x, y)
    def get_capacitance_modified(self, point1, point2, layer_name, via_type):
        if point1 == point2:
            # we have a via
            if self.lef_parser.layer_dict[via_type].edge_cap is None:
                return 0
            else:
                return self.lef_parser.layer_dict[via_type].edge_cap
        else:
            # we have a wire
            if self.lef_parser.layer_dict[layer_name].capacitance is not None:
                cPerSquare = self.capacitanceFactor * self.lef_parser.layer_dict[layer_name].capacitance[1]  # unit in lef is pF
            else:
                cPerSquare = 0
            width = self.lef_parser.layer_dict[layer_name].width  # width in microns
            length = (abs(point1[0] - point2[0]) + abs(point1[1] - point2[1]))/1000  # length in microns
            if self.lef_parser.layer_dict[layer_name].edge_cap is not None:
                edgeCapacitance = self.capacitanceFactor * self.lef_parser.layer_dict[layer_name].edge_cap
            else:
                edgeCapacitance = 0

            # the edge capacitance factor value is 1 by default
            capacitance = length * cPerSquare * width + edgeCapFactor * 2 * edgeCapacitance * (length + width)   # capactiance in pF

            return capacitance

    # method to look for intersetions between segment nodes in order to decide
    # on creating a new node or add to the existing capacitance
    def checkPinsTable(self, point, layer, pinsTable):
        for pin in pinsTable:
            locations = pin[0]
            for location in locations:
                if(location[2] == layer
                   or (location[2] == 'met1' and layer == 'li1')
                   or (location[2] == 'li1' and layer == 'met1')):
                    if((type(location[0]) == "<class 'int'>")
                       or (type(location[0]) == "<class 'float'>")):
                        if point[0] == location[0] and point[1] == location[1]:
                            return pin
                    else:
                        if ((location[0][0] - 5 <= float(point[0]) <= location[1][0] + 5)
                            and (location[0][1] - 5 <= float(point[1]) <= location[1][1] + 5)):
                            return pin
        return "new"

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
            self.printNet(f, netsDict, key)

    # method to print a particular net into SPEF format
    def printNet(self, f, netsDict, wireName):
        var = '*D_NET' + " " + wireName + " " + str(netsDict[wireName]['maxC'])
        f.write(var + '\n')
        var = '*CONN'
        f.write(var + '\n')
        for eachConnection in netsDict[wireName]['conn']:
            var = eachConnection[0] + " " + eachConnection[1] + " " + eachConnection[2]
            f.write(var + '\n')

        var = '*CAP'
        f.write(var + '\n')
        for key, value in self.bigCapacitanceTable[wireName].items():
            var = str(self.capCounter) + " " + str(key) + " " + str(value)
            f.write(var + '\n')
            self.capCounter += 1

        var = '*RES'
        f.write(var + '\n')
        for eachSegment in netsDict[wireName]['segments']:
            var = str(self.resCounter) + " " + str(eachSegment[0]) + " " + str(eachSegment[1]) + " " + str(eachSegment[2])
            f.write(var + '\n')
            self.resCounter += 1

        var = '*END\n'
        f.write(var + '\n')

    def extract_net(self, net):
        """From a DEF net extract the corresponding SPEF net"""

        # a list of the connections in the net
        conList = []
        # a list of all pins referenced in the net, including the internal nodes between each 2 segments
        pinsTable = []
        segmentsList = []

        # A SPEF net is made of CONNs, capacities and resistors.
        # A CONN correspond to either an external PAD or an internal cell PIN.
        # generate the conn data structure for conn section
        for con in net.comp_pin:
            # Check if con != ';'
            if con[0] == ';':
                continue
            if con[0] == "PIN":
                # It is an external PAD
                x = self.def_parser.pins.get_pin(con[1])
                if x.direction == "INPUT":
                    pin_dir = "I"
                else:
                    pin_dir = "O"
                current_pin = ["*P", con[1], pin_dir]

                # these are used for the pinsTable
                pin = self.def_parser.pins.pin_dict[con[1]]
                pinLocation = pin.placed
                metalLayer = pin.layer.name
                locationsOfCurrentPin = [((pinLocation[0], pinLocation[1]),
                                          (pinLocation[0], pinLocation[1]),
                                          metalLayer)]
            else:
                # It is an internal pin, check for input or output
                cell_type = self.def_parser.components.comp_dict[con[0]].macro

                # some cells do not have direction
                # check first if a cell has a direction or not

                pinInfo = self.lef_parser.macro_dict[cell_type].pin_dict[con[1]]

                # check if it has a direction
                direction = pinInfo.info.get("DIRECTION")
                if direction is None:
                    # check if cell has 'in' or 'out' in its name
                    if cell_type.find("in"):
                        direction = "INPUT"
                    else:
                        direction = "OUTPUT"

                if direction == "INPUT":
                    pin_dir = "I"
                else:
                    pin_dir = "O"
                current_pin = ["*I", con[0] + ":" + con[1], pin_dir]

                # this is used for the pins table
                metalLayerInfo = pinInfo.info
                metalLayer = metalLayerInfo['PORT'].info['LAYER'][0].name
                locationsOfCurrentPin = self.getPinLocation(con[0], con[1], metalLayer)

            # we append list of pin locations - cellName - pinName - metalLayer
            pinsTable.append((locationsOfCurrentPin, con[0], con[1], metalLayer))
            conList.append(current_pin)


        # the value will be incremented if more than 1 segment end at the same node
        counter = 1
        currentNodeList = {}
        for segment in net.routed:
            if segment.end_via == 'RECT':
                continue
            # traversing all segments in a certain net to get all their information
            for it in range(len(segment.points)):
                # traversing all points in a certain segment, classifyng them as starting and ending points and
                # checking for their existence in the pinstable, using checkPinsTable method
                last = 0
                if it < (len(segment.points) - 1):
                    spoint = segment.points[it]
                    epoint = segment.points[it+1]
                else:
                    # last point in the line (either via or no via)
                    spoint = segment.points[it]
                    epoint = segment.points[it]
                    last = 1
                    # if we are at the last point and there is no via, then ignore the point
                    # as it has already been considered with the previous point
                    if segment.end_via == ';' or segment.end_via is None:
                        continue

                sflag = self.checkPinsTable(spoint, segment.layer, pinsTable)
                if sflag != "new":
                    snode = sflag
                else:
                    # Add a new pin
                    snode = [[((spoint[0], spoint[1]),
                               (spoint[0], spoint[1]),
                               segment.layer)],
                             net.name,
                             str(counter),
                             segment.layer]
                    counter += 1
                    pinsTable.append(snode)

                if last and (segment.end_via != ';' and segment.end_via is not None):
                    # special handeling for vias to tget the via types through the via name
                    myVia = segment.end_via
                    if myVia[-1] == ';':
                        myVia = myVia[0:-1]

                    if myVia in self.lef_parser.via_dict:
                        firstLayer = self.lef_parser.via_dict[myVia].layers[0].name
                        secondLayer = self.lef_parser.via_dict[myVia].layers[1].name
                        thirdLayer = self.lef_parser.via_dict[myVia].layers[2].name

                    elif myVia in self.vias_dict_def:

                        firstLayer = self.vias_dict_def[myVia]['LAYERS'][0]
                        secondLayer = self.vias_dict_def[myVia]['LAYERS'][1]
                        thirdLayer = self.vias_dict_def[myVia]['LAYERS'][2]

                    if self.lef_parser.layer_dict[firstLayer].layer_type == 'CUT':
                        first = secondLayer
                        second = thirdLayer

                    if self.lef_parser.layer_dict[secondLayer].layer_type == 'CUT':
                        first = firstLayer
                        second = thirdLayer

                    if self.lef_parser.layer_dict[thirdLayer].layer_type == 'CUT':
                        first = firstLayer
                        second = secondLayer

                    if first == segment.layer:
                        choose = 2  # choose second layer in case of creating end node
                        eflag = self.checkPinsTable(epoint, second, pinsTable)
                    else:
                        choose = 1  # choose first layer in case of creating end node
                        eflag = self.checkPinsTable(epoint, first, pinsTable)

                else:
                    eflag = self.checkPinsTable(epoint, segment.layer, pinsTable)

                if eflag != "new":
                    enode = eflag
                else:
                    if last:
                        # if it is a VIA and starting point was on second layer
                        if choose == 1:
                            layer = first
                        else:
                            layer = second
                    else:
                        layer = segment.layer
                    enode = [[((epoint[0], epoint[1]),
                               (epoint[0], epoint[1]), layer)],
                             net.name,
                             str(counter),
                             layer]
                    counter += 1
                    pinsTable.append(enode)

                seg = []

                # TODO: pass segment.endvia to function to be used if 2 points are equal

                if segment.end_via is not None and segment.end_via != ';':
                    via_type = self.getViaType(segment.end_via)
                else:
                    # dummy via
                    via_type = 'via'
                resistance = self.get_resistance_modified(spoint, epoint, segment.layer, via_type)
                capacitance = self.get_capacitance_modified(spoint, epoint, segment.layer, via_type)

                # the name of the first node of the segment
                currentSNodeName = str(snode[1]) + ':' + str(snode[2])
                # the name of the second node of the segment
                currentENodeName = str(enode[1]) + ':' + str(enode[2])

                # put the capacitance for the current node.
                existsS = False
                existsE = False

                if wireModel == 'PI':
                    for key in currentNodeList:
                        if currentSNodeName == key:
                            existsS = True
                        if currentENodeName == key:
                            existsE = True

                    # these 2 if-else statements add half the capactiances at each of the endpoints of thes egment
                    # to use a pi model
                    if existsS:
                        # adding the capacitance to the previous capacitances in an existing node
                        currentNodeList[currentSNodeName] += 0.5 * capacitance
                    else:
                        # assigning the new node capacitance
                        currentNodeList[currentSNodeName] = 0.5 * capacitance

                    if existsE:
                        # adding the capacitance to the previous capacitances in an existing node
                        currentNodeList[currentENodeName] += 0.5 * capacitance
                    else:
                        # assigning the new node capacitance
                        currentNodeList[currentENodeName] = 0.5 * capacitance

                    if snode[1] != 'PIN':
                        seg.append(snode[1] + ':' + snode[2])
                    else:
                        seg.append(snode[2])
                    if enode[1] != 'PIN':
                        seg.append(enode[1] + ':' + enode[2])
                    else:
                        seg.append(enode[2])

                # use the L wire model. Essentially, we will add the capacitance of the segment
                # at the starting node
                else:

                    for key in currentNodeList:
                        if currentSNodeName == key:
                            existsS = True

                    # these 2 if-else statements add half the capactiances at each of the endpoints of thes egment
                    # to use a pi model
                    if existsS:
                        # adding the capacitance to the previous capacitances in an existing node
                        currentNodeList[currentSNodeName] += capacitance
                    else:
                        # assigning the new node capacitance
                        currentNodeList[currentSNodeName] = capacitance

                    if snode[1] != 'PIN':
                        seg.append(snode[1] + ':' + snode[2])
                    else:
                        seg.append(snode[2])
                    if enode[1] != 'PIN':
                        seg.append(enode[1] + ':' + enode[2])
                    else:
                        seg.append(enode[2])

                seg.append(resistance)
                seg.append(capacitance)
                segmentsList.append(seg)

        # appending the pins, segments resistances and node capacitances into the big table dictionaries that will
        # be used for printing the final SPEF
        self.bigCapacitanceTable[net.name] = currentNodeList

        sumC = 0
        for k in currentNodeList:
            sumC += currentNodeList[k]
        return {'conn': conList, 'maxC': sumC, 'segments': segmentsList}

    def extract(self, lef_file_name, def_file_name, wireModel, edgeCapFactor):
        # main starts here:
        # create all the data structures that we will be using
        pinsTable = []
        segmentsList = []
        self.bigCapacitanceTable = {}
        netsDict = {}
        self.vias_dict_def = {}

        # We had to modify the lef parser to ignore the second parameter for the offset
        # since our files provide only 1 value
        self.lef_parser = LefParser(lef_file_name)
        self.lef_parser.parse()

        # read the updated def
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

        for net in self.def_parser.nets:
            # traversing all nets in the def file to extract segments
            # information
            netsDict[net.name] = self.extract_net(net)

        print("RC Extraction is done")

        # writing into SPEF file
        self.capCounter = 0
        self.resCounter = 0

        f = open(str(def_file_name[:-4]) + ".spef", "w", newline='\n')
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
