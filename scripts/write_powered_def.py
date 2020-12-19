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

import os
import sys
import argparse
from subprocess import Popen, PIPE, STDOUT
import opendbpy as odb

parser = argparse.ArgumentParser(
    description='Add cell power connections in the netlist. Useful for LVS purposes.')

parser.add_argument('--input-def', '-d', required=True,
                    help='DEF view of the design')

parser.add_argument('--input-lef', '-l', required=True,
                    help='LEF file needed to have a proper view of the design.'
                         'Every cell having a pin labeled as a power pin (e.g., USE POWER) will'
                         'be connected to the power/ground port of the design')

parser.add_argument('--power-port', '-v',
                    help='Name of the power port of the design. The power pin of the'
                         'subcells will be connected to it by default')

parser.add_argument('--ground-port', '-g',
                    help='Name of the ground port of the design. The ground pin of the'
                         'subcells will be connected to it by default')

parser.add_argument('--powered-netlist', '-pv',
                    help='A structural verilog netlist, readable by openroad, '
                         'that includes extra power connections that are to be'
                         'applied after connecting to the default power-port and ground-port specified.')

parser.add_argument('--ignore-missing-pins', '-q', action='store_true', required=False)

parser.add_argument('--output', '-o',
                    default='output.def', help='Output modified netlist')

# parser.add_argument('--create-pg-ports',
#                     help='Create power and ground ports if not found')

args = parser.parse_args()

def_file_name = args.input_def
lef_file_name = args.input_lef
power_port_name = args.power_port
ground_port_name = args.ground_port

powered_netlist_file_name = args.powered_netlist

ignore_missing_pins = args.ignore_missing_pins

output_file_name = args.output

def get_power_ground_ports(ports):
    vdd_ports = []
    gnd_ports = []
    for port in ports:
        if port.getSigType() == "POWER" or port.getName() == power_port_name:
            vdd_ports.append(port)
        elif port.getSigType() == "GROUND" or port.getName() == ground_port_name:
            gnd_ports.append(port)
    return (vdd_ports, gnd_ports)

def find_power_ground_port(port_name, ports):
    for port in ports:
        if port.getName() == port_name:
            return port
    return None

db = odb.dbDatabase.create()

odb.read_lef(db, lef_file_name)
odb.read_def(db, def_file_name)

chip = db.getChip()
block = chip.getBlock()
design_name = block.getName()

print("Top-level design name:", design_name)

VDD_PORTS, GND_PORTS = get_power_ground_ports(block.getBTerms())
assert VDD_PORTS and GND_PORTS, "No power ports found at the top-level. "\
    "Make sure that they exist and have the USE POWER|GROUND property or "\
    "they match the arguments specified with --power-port and --ground-port."

DEFAULT_VDD = VDD_PORTS[0].getNet()
DEFAULT_GND = GND_PORTS[0].getNet()

print("Default power net: ", DEFAULT_VDD.getName())
print("Default ground net:", DEFAULT_GND.getName())

print("Found a total of", len(VDD_PORTS), "power ports.")
print("Found a total of", len(GND_PORTS), "ground ports.")

modified_cells = 0
cells = block.getInsts()
for cell in cells:
    iterms = cell.getITerms()
    cell_name = cell.getName()
    if len(iterms) == 0:
        continue

    VDD_ITERMS = []
    GND_ITERMS = []
    VDD_ITERM_BY_NAME = None
    GND_ITERM_BY_NAME = None
    for iterm in iterms:
        if iterm.getSigType() == "POWER":
            VDD_ITERMS.append(iterm)
        elif iterm.getSigType() == "GROUND":
            GND_ITERMS.append(iterm)
        elif iterm.getMTerm().getName() == power_port_name:
            VDD_ITERM_BY_NAME = iterm
        elif iterm.getMTerm().getName() == ground_port_name:  # note **PORT**
            GND_ITERM_BY_NAME = iterm

    if len(VDD_ITERMS) == 0:
        print("Warning: No pins in the LEF view of", cell_name, " marked for use as power")
        print("Warning: Attempting to match power pin by name (using top-level port name) for cell:", cell_name)
        if VDD_ITERM_BY_NAME is not None:  # note **PORT**
            print("Found", power_port_name, "using that as a power pin")
            VDD_ITERMS.append(VDD_ITERM_BY_NAME)

    if len(GND_ITERMS) == 0:
        print("Warning: No pins in the LEF view of", cell_name, " marked for use as ground")
        print("Warning: Attempting to match ground pin by name (using top-level port name) for cell:", cell_name)
        if GND_ITERM_BY_NAME is not None:  # note **PORT**
            print("Found", ground_port_name, "using that as a ground pin")
            GND_ITERMS.append(GND_ITERM_BY_NAME)

    if len(VDD_ITERMS) == 0 or len(GND_ITERMS) == 0:
        print("Warning: not all power pins found for cell:", cell_name)
        if ignore_missing_pins:
            print("Warning: ignoring", cell_name, "!!!!!!!")
            continue
        else:
            print("Exiting... Use --ignore-missing-pins to ignore such errors")
            sys.exit(1)

    if len(VDD_ITERMS) > 2:
        print("Warning: cell", cell_name, "has", len(VDD_ITERMS), "power pins.")

    if len(GND_ITERMS) > 2:
        print("Warning: cell", cell_name, "has", len(GND_ITERMS), "ground pins.")

    for VDD_ITERM in VDD_ITERMS:
        if VDD_ITERM.isConnected():
            pin_name = VDD_ITERM.getMTerm().getName()
            cell_name = cell_name
            print("Warning: power pin", pin_name, "of", cell_name, "is already connected")
            print("Warning: ignoring", cell_name + "/" + pin_name, "!!!!!!!")
        else:
            odb.dbITerm_connect(VDD_ITERM, DEFAULT_VDD)

    for GND_ITERM in GND_ITERMS:
        if GND_ITERM.isConnected():
            pin_name = GND_ITERM.getMTerm().getName()
            cell_name = cell_name
            print("Warning: ground pin", pin_name, "of", cell_name, "is already connected")
            print("Warning: ignoring", cell_name + "/" + pin_name, "!!!!!!!")
        else:
            odb.dbITerm_connect(GND_ITERM, DEFAULT_GND)

    modified_cells += 1

print("Modified power connections of", modified_cells, "cells (Remaining:",
      len(cells)-modified_cells,
      ").")

# apply extra special connections taken from another netlist:
if powered_netlist_file_name is not None \
        and os.path.exists(powered_netlist_file_name):
    tmp_def_file = f"{os.path.splitext(powered_netlist_file_name)[0]}.def"
    openroad_script = []
    openroad_script.append(f"read_lef {lef_file_name}")
    openroad_script.append(f"read_verilog {powered_netlist_file_name}")
    openroad_script.append(f"link_design {design_name}")
    openroad_script.append(f"write_def {tmp_def_file}")
    openroad_script.append(f"exit")

    p = Popen(["openroad"],
              stdout=PIPE,
              stdin=PIPE,
              stderr=PIPE,
              encoding='utf8'
              )

    openroad_script = '\n'.join(openroad_script)

    output = p.communicate(openroad_script)
    print("STDOUT:")
    print(output[0].strip())
    print("STDERR:")
    print(output[1].strip())
    print("openroad exit code:", p.returncode)
    assert p.returncode == 0, p.returncode
    assert os.path.exists(tmp_def_file), "DEF file doesn't exist"

    db_power = odb.dbDatabase.create()
    odb.read_lef(db_power, lef_file_name)
    odb.read_def(db_power, tmp_def_file)
    chip_power = db_power.getChip()
    block_power = chip_power.getBlock()
    assert block_power.getName() == design_name
    print("Successfully created a new database")
    POWER_GROUND_PORT_NAMES = [port.getName() for port in VDD_PORTS+GND_PORTS]

    # using get_power_ground_ports doesn't work since the pins weren't
    # created using pdngen
    power_ground_ports = [port for port in block_power.getBTerms()\
                          if port.getName() in POWER_GROUND_PORT_NAMES]

    for port in power_ground_ports:
        iterms = port.getNet().getITerms()
        for iterm in iterms:
            inst_name = iterm.getInst().getName()
            pin_name = iterm.getMTerm().getName()

            original_inst = block.findInst(inst_name)
            assert original_inst is not None, "Instance " + inst_name + " not found in the original netlist. Perhaps it was optimized out during synthesis?"

            original_iterm = original_inst.findITerm(pin_name)
            assert original_iterm is not None, inst_name + " doesn't have a pin named " + pin_name

            original_port = find_power_ground_port(port.getName(), VDD_PORTS+GND_PORTS)
            assert original_port is not None, port.getName() + " not found in the original netlist."

            odb.dbITerm_disconnect(original_iterm)
            odb.dbITerm_connect(original_iterm, original_port.getNet())
            print("Modified connections between", port.getName(), "and", inst_name)

odb.write_def(block, output_file_name)
