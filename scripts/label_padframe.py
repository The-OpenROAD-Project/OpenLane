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

"""
Takes a padframe view (mag -- or def TODO) and the padframe cfg file
inserts labels on the pads
"""
from subprocess import Popen, PIPE, STDOUT
import argparse
import sys
import os
import re
# import opendbpy as odb

TECH = ""
PDK_ROOT = os.environ["PDK_ROOT"]
os.environ["MAGTYPE"] = "maglef"

parser = argparse.ArgumentParser(
    description='Labels the pins in the padframe')

parser.add_argument('--padframe', '-pf', required=True,
                    help='A view (MAG/DEF) of the padframe')

parser.add_argument('--padframe-config', '-cfg', required=True,
                    help='CFG file -- input to padring')

parser.add_argument('--label-layer', '-ll',
                    required=False,
                    default='met5')

parser.add_argument('--label-format', '-lf',
                    required=False,
                    default='NAME',
                    help='How labels are derived from the instance name.\
                    use NAME (which is (\\S+)) to refer to the label to capture\
                    from the instance name. Follows python regex format.')

parser.add_argument('--map', '-m', action='append',
                    nargs=1,
                    required=False,
                    default=None,
                    help='Mappings of internal pad pins to external ports.\
                    Format: --map [<pad_type_substring>/]<pin_name_on_pad>. Order\
                    matters.')

parser.add_argument('--opendb', '-odb', action='store_true', required=False)

args = parser.parse_args()

padframe_file_name = args.padframe
config_file_name = args.padframe_config
use_opendb_flag = args.opendb
mappings = args.map
label_layer = args.label_layer
label_format = args.label_format

if mappings is None:
    # sw defaults
    mappings = [['pad'],  # if pad found in name, apply this mapping (label its pad pin). works in SW because all pads have _pad in the type name
                ['vssa'],  # if vssa found in pad name, apply this mapping (label its vssa pin)
                ['vdda'],
                ['vddio'],
                ['vssio'],
                ['vccd'],
                ['vssd']
                ]
else:
    for i in range(len(mappings)):
        if len(mappings[i]) > 2:
            print("Usage error: A maximum of two values can be given to --map\n\
                  --map <pin_name_on_pad> [<port_name_regex>]")
            sys.exit(1)
        elif len(mappings[i]) == 1:
            mappings[i].append('NAME')

if use_opendb_flag:
    print("TODO")
    sys.exit(1)

# USE MAGIC FOR creating LABELS
# extension = os.path.splitext(filename)[1]

padframe = {}
padframe["pads"] = []
with open(config_file_name, 'r') as config_file:
    for line in config_file:
        if line.isspace():
            continue
        line = line.split()
        if line[0] == "AREA":
            padframe["size"] = (int(line[1]), int(line[2]))
        elif line[0] == "PAD":
            padframe["pads"].append({
                "instance_name": line[1],
                "pad_type": line[3]
            })

# get tech
if ".mag" in padframe_file_name:
    with open(padframe_file_name, 'r') as padframe_file:
        for line in padframe_file:
            if line.isspace():
                continue
            line = line.split()
            if line[0] == "tech":
                TECH = line[1]
                print("tech found in mag file:", TECH)
                break
elif TECH == "":
    print("DEF FILES TODO")
    print("no tech found to run magic")
    sys.exit(1)

print("Parsed", len(padframe["pads"]), "pads")


def get_pin_name(pad_type):
    pin_name = ""
    for mapping in mappings:
        type_pin_pair = mapping[0].split('/')
        if len(type_pin_pair) == 1:
            substr = type_pin_pair[0]
            mapped_pin = substr
        elif len(type_pin_pair) == 2:
            substr = type_pin_pair[0]
            mapped_pin = type_pin_pair[1]
        else:
            print("More than one / found in mapping")
            sys.exit(1)
        if substr in pad_type:
            pin_name = mapped_pin
    return pin_name


def get_port_name(instance_name):
    label_regex = label_format.replace("NAME", "(\\S+)")
    return re.match(label_regex, instance_name)[1]


# apply the mappings
for i in range(len(padframe["pads"])):
    pad_type = padframe["pads"][i]["pad_type"]
    instance_name = padframe["pads"][i]["instance_name"]
    pin_name = get_pin_name(pad_type)
    port_name = get_port_name(instance_name)
    padframe["pads"][i]["pin"] = pin_name
    padframe["pads"][i]["port"] = port_name


labeled_ports = {}

# GENERATE MAGIC SCRIPT FOR LABELLING
magic_script =\
    """
    drc off
    load %s -dereference
    select top cell
    expand
    """ % (padframe_file_name)

# find pin labels, create port labels on top of them
for pad in padframe["pads"]:
    if pad["port"] in labeled_ports:
        continue
    labeled_ports[pad["port"]] = 0
    magic_script +=\
        """
        findlabel %s/%s
        erase labels
        label %s center -%s
        port make
        # IO direction missing
        """ % (pad["instance_name"], pad["pin"], pad["port"], label_layer)

magic_script +=\
    """
    save
    """

p = Popen(["magic",
           "-rcfile",
           "%s/%s/libs.tech/magic/current/%s.magicrc" % (PDK_ROOT, TECH, TECH),
           "-noc",
           "-dnull"
           ],
          stdout=PIPE,
          stdin=PIPE,
          stderr=PIPE,
          encoding='utf8'
          )

print(magic_script)

output = p.communicate(magic_script)
print("STDOUT:")
print(output[0].strip())
print("STDERR:")
print(output[1].strip())

print("Done")
