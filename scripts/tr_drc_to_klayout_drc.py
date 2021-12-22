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

import argparse
import re
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom

parser = argparse.ArgumentParser(
    description='Converts a TritonRoute DRC Report to a KLayout database')

parser.add_argument('--input', '-i', required=True,
                    help='')

parser.add_argument('--design-name', '-name', required=True,
                    help='')

parser.add_argument('--output', '-o', required=True,
                    help='')

args = parser.parse_args()

input_file_name = args.input
design_name = args.design_name
output_file_name = args.output

RE_VIOLATION = re.compile(r'violation type: (?P<type>\S+)\s+'
                          r'srcs: (?P<src1>\S+)( (?P<src2>\S+))?\s+'
                          r'bbox = \( (?P<llx>\S+), (?P<lly>\S+) \)'
                          r' - '
                          r'\( (?P<urx>\S+), (?P<ury>\S+) \) '
                          r'on Layer (?P<layer>\S+)', re.M)

def prettify(elem):
    """
    Return a pretty-printed XML string for the Element.
    """
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="    ",
                                newl="\n")
                                # encoding='utf-8')

with open(input_file_name, 'r') as f:
    content = f.read()

cnt = 0
vio_dict  = {}
for match in RE_VIOLATION.finditer(content):
    cnt += 1
    type_ = match.group('type')
    src1 = match.group('src1')
    src2 = match.group('src2')
    llx = match.group('llx')
    lly = match.group('lly')
    urx = match.group('urx')
    ury = match.group('ury')
    layer = match.group('layer')

    item = ET.Element('item')
    ET.SubElement(item, 'category').text = type_
    ET.SubElement(item, 'cell').text = design_name
    ET.SubElement(item, 'visited').text = 'false'
    ET.SubElement(item, 'multiplicity').text = '1'
    values = ET.SubElement(item, 'values')
    box = ET.SubElement(values, 'value')
    box.text = f"box: ({llx},{lly};{urx},{ury})"
    layer_msg = ET.SubElement(values, 'value')
    layer_msg.text = f"text: 'On layer {layer}'"
    srcs = ET.SubElement(values, 'value')
    if src2:
        srcs.text = f"text: 'Between {src1} {src2}'"
    else:
        srcs.text = f"text: 'Between {src1}'"

    # create XML object
    if type_ not in vio_dict:
        vio_dict[type_] = []

    vio_dict[type_].append(item)

print("Found", cnt, "violations")

report_database = ET.Element('report-database')
categories = ET.SubElement(report_database, 'categories')
for type_ in vio_dict.keys():
    category = ET.SubElement(categories, 'category')
    ET.SubElement(category, 'name').text = type_

cells = ET.SubElement(report_database, 'cells')
cell = ET.SubElement(cells, 'cell')
ET.SubElement(cell, 'name').text = design_name

items = ET.Element('items')
for _, vios in vio_dict.items():
    for item in vios:
        items.append(item)

report_database.append(items)

report_database_str = prettify(report_database)

with open(output_file_name, 'w') as f:
    f.write(report_database_str)
