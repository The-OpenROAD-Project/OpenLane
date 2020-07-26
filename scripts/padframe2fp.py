#!/usr/bin/env python3
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

import re
import argparse
RECT_REGEX = r"\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;\s+"
SIZE_REGEX = r"^\s*SIZE\s+(-?\d+\.?\d*)\s+BY\s+(-?\d+\.?\d*)\s+;$"
LAYER_REGEX = r'LAYER\s+(\S+)\s+;\s+((RECT\s+-?\d+\.?\d*\s+-?\d+\.?\d*\s+-?\d+\.?\d*\s+-?\d+\.?\d*\s+;\s+)*)'
PINS_REGEX = r'PIN\s+(\S+).*PORT\s+(.*;\s+)END.*END\s+\1\n'
PLACED_COMP_REGEX = r"^\s*-\s+([^\s]+)\s+([^\s]+)\s+\+\s+PLACED\s+\(\s(-?\d+)\s(-?\d+)\s\)\s+([NEWS])\s+;$"
PIN_IGNORE = ['VSS', 'VDD', 'PAD', 'in3v', 'vdd']
NETS_IGNORE = ['vdd', 'vss']
NETSECTION_REGEX = r"^NETS\s+\S+\s+;\s+(.*)END NETS\s+"
# \s+([NEWS])\s+;$"
def getMacroPins(content, macro_name):
    """
    -> (macro_size(sz_x, sz_y), pins:{layer:array of rectangles} )
    """
    macro = [s for s in content if macro_name in s][0]
    pins = re.findall(PINS_REGEX, macro, re.M | re.DOTALL)
    size = re.findall(SIZE_REGEX, macro, re.M | re.DOTALL)
    pins_ds = {}
    ds = {}
    for pin in pins:
        name = pin[0]
        #print(pin[1])
        layers = re.findall(LAYER_REGEX, pin[1], re.M | re.DOTALL)
        for layer in layers:
            layer_name = layer[0]
            rectangles_s = re.findall(RECT_REGEX, layer[1], re.M | re.DOTALL)
            rectangles = []
            for rectangle in rectangles_s:
                rectangles.append(tuple([float(num) for num in rectangle]))
            pins_ds.setdefault(name, [])
            pins_ds[name] += [(layer_name, rectangles)]
    ds["pins"] = pins_ds
    ds["_sz_x"] = float(size[0][0])
    ds["_sz_y"] = float(size[0][1])
    # print(ds)
    return ds
def getDefComponents(comp_section):
    placed_comps = re.findall(PLACED_COMP_REGEX, comps_section, re.M | re.DOTALL)
    ds = {}
    for comp in placed_comps:
        ds[comp[0]] = {}
        ds[comp[0]]["macro"] = comp[1]
        ds[comp[0]]["pos"] = (int(comp[2]), int(comp[3]))
        ds[comp[0]]["orientation"] = comp[4]
    # print(ds)
    return ds
def getNetsDict(def_file):
    nets_section = re.findall(NETSECTION_REGEX, content, re.M | re.DOTALL)

    nets = filter(None, nets_section[0].replace('\n', ' ').split("- "))
    nets_dict = {}
    for net in nets:
        net_name = re.findall(r"\s*(\S+).*;",net)
        if any(net_name[0].find(net_ignore) != -1 for net_ignore in NETS_IGNORE):
            continue
        connections = re.findall(r"\(\s+(.*?)\s+\)",net)
        connections = [connection.replace('\\','') for connection in connections]
        nets_dict[net_name[0]] = connections
        #print(net_name, connections)

    return nets_dict

parser = argparse.ArgumentParser(
    description='Pads to ios')
parser.add_argument('--inputLef', '-il', required=True, help='Input Lef', nargs='+')
parser.add_argument('--inputDef', '-id', required=True, help='Input Def', nargs='+')
parser.add_argument('--inputDefNets', '-idn', required=True, help='Input Def')
args = parser.parse_args()
# parsing netsdef
f = open(args.inputDefNets)
content = f.read()
f.close()
nets_dict = getNetsDict(content)

# parsing lef
f = open(args.inputLef[0])
content = f.read()
f.close()
pattern = r"^MACRO.*?^END\s\S+"
all_macros_content = re.findall(pattern, content, re.M | re.DOTALL)
# parsing def
f = open(args.inputDef[0])
content = f.read()
f.close()
pattern = r"^COMPONENTS.*?^END COMPONENTS$"
comps_section = re.findall(pattern, content, re.M | re.DOTALL)[0] # extract COMPONENTS section
comps = getDefComponents(comps_section) ##
pin_section = """"""
pin_cnt = 0
macro_db = {}
for comp in comps:
    if (comp.find('FILL') != -1):
        continue
    comp_data = comps[comp]
    macro_data = macro_db.setdefault(comp_data["macro"], getMacroPins(all_macros_content, comp_data["macro"]))
    sz_x = macro_data["_sz_x"]
    sz_y = macro_data["_sz_y"]
    pos_x = comp_data["pos"][0]
    pos_y = comp_data["pos"][1]
    orientation = comp_data["orientation"]
    if orientation == "E":
        pos_y += int(sz_x*1000)
    elif orientation == "W":
        pos_x += int(sz_y*1000)
    elif orientation == "S":
        pos_y += int(sz_y*1000)
        pos_x += int(sz_x*1000)
    for pin in macro_data["pins"]:
        if any(pin.find(pin_ignore) != -1 for pin_ignore in PIN_IGNORE):
            continue
        pin_data = macro_data["pins"][pin]
        # print(pin_data)
        #pin_tag = comp+"."+comp_data["macro"]+'.'+pin
        pin_tag = comp+" "+pin
        found = False
        for net in nets_dict:
            if pin_tag in nets_dict[net]:
                pin_tag = net
                found = True
                break
        if not found:
            continue
        pin_cnt += 1
        pin_section += "- %s + NET %s\n+ PLACED ( %d %d ) %s" % \
        (pin_tag, pin_tag, pos_x, pos_y, orientation)
        for layer in pin_data:
            layer_name = layer[0]
            for rect in layer[1]:
                pin_section += "\n+ LAYER %s ( %d %d ) ( %d %d )" % \
                (layer_name, rect[0]*1000, rect[1]*1000, rect[2]*1000, rect[3]*1000) + ' '
        pin_section += ";\n\n"
pin_section = "PINS %d ;\n%s\nEND PINS" % (pin_cnt, pin_section)
print(pin_section)
