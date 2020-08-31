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
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Add cell power connections in the netlist. Useful for LVS purposes.')

parser.add_argument('--input-def', '-d', required=True,
                    help='DEF view of the design')

parser.add_argument('--input-lef', '-l', required=True,
                    help='LEF file needed to have a proper view of the design.\
                    Every cell having a pin labeled as a power pin (e.g., USE POWER) will\
                    be connected to the power/ground port of the design')

parser.add_argument('--power-port', '-v',
                    help='Name of the power port of the design. The power pin of the\
                    subcells will be conneted to it')

parser.add_argument('--ground-port', '-g',
                    help='Name of the ground port of the design. The ground pin of the\
                    subcells will be conneted to it')

parser.add_argument('--output', '-o',
                    default='output.def', help='Output modified netlist')

parser.add_argument('--ignore-missing-pins', '-q', action='store_true', required=False)

# parser.add_argument('--create-pg-ports',
#                     help='Create power and ground ports if not found')

args = parser.parse_args()

def_file_name = args.input_def
lef_file_name = args.input_lef
power_port_name = args.power_port
ground_port_name = args.ground_port

ignore_missing_pins = args.ignore_missing_pins

output_file_name = args.output

db = odb.dbDatabase.create()

odb.read_lef(db, lef_file_name)
odb.read_def(db, def_file_name)

chip = db.getChip()
block = chip.getBlock()
design_name = block.getName()

print("Top-level design name:", design_name)

VDD = None
GND = None
ports = block.getBTerms()

for port in ports:
    if port.getSigType() == "POWER" or port.getName() == power_port_name:
        print("Found port", port.getName(), "of type POWER")
        VDD = port
    elif port.getSigType() == "GROUND" or port.getName() == ground_port_name:
        print("Found port", port.getName(), "of type GROUND")
        GND = port

if None in [VDD, GND]:  # and not --create-pg-ports
    print("Error: No power ports found at the top-level. Make sure that they exist\
          and have the USE POWER|GROUND property or they match the argumens\
          specified with --power-port and --ground-port")
    exit(1)

VDD = VDD.getNet()
GND = GND.getNet()

print("Power net: ", VDD.getName())
print("Ground net:", GND.getName())

connection_count = 0
cells = block.getInsts()
for cell in cells:
    iterms = cell.getITerms()
    VDD_ITERM = None
    GND_ITERM = None
    for iterm in iterms:
        if iterm.getSigType() == "POWER":
            VDD_ITERM = iterm
        elif iterm.getSigType() == "GROUND":
            GND_ITERM = iterm
        else:
            print("Warning: No pins in the LEF view of", cell.getName(), " marked for use as power nor ground")
            print("Warning: Attempting to match power pins by name (using top-level port name) for cell:", cell.getName())
            if iterm.getMTerm().getName() == power_port_name:  # note **PORT**
                print("Found", power_port_name, "using that as a power pin")
                VDD_ITERM = iterm
            elif iterm.getMTerm().getName() == ground_port_name:  # note **PORT**
                print("Found", ground_port_name, "using that as a ground pin")
                GND_ITERM = iterm

    if None in [VDD_ITERM, GND_ITERM]:
        print("Warning: not all power pins found for cell:", cell.getName())
        if ignore_missing_pins:
            print("Warning: ignoring", cell.getName(), "!!!!!!!")
            continue
        else:
            print("Exiting... Use --ignore-missing-pins to ignore such errors")
            sys.exit(1)

    if VDD_ITERM.isConnected() or GND_ITERM.isConnected():
        print("Warning: power pins of", cell.getName(), "are already connected")
        print("Warning: ignoring", cell.getName(), "!!!!!!!")
        continue    # or exit

    odb.dbITerm_connect(VDD_ITERM, VDD)
    odb.dbITerm_connect(GND_ITERM, GND)
    connection_count += 1

print("Connected", connection_count, "instances to power (Remaining:",
      len(cells)-connection_count,
      ").")
odb.write_def(block, output_file_name)
