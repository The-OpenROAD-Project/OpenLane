# Copyright 2021-2022 The University of Michigan
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
import os
import math
import click
from collections import defaultdict

from reader import OdbReader


class eco:
    def __init__(self, input_lef, input_def, skip_pin):
        self.odb = OdbReader(input_lef, input_def)
        self.skip_pin = skip_pin

        self.vio_dict = defaultdict(float)
        self.vio_count = 0
        self.eco_iter = os.environ["ECO_ITER"]
        self.repairs = []
        self.vio_re = re.compile(r"([0-9]+\.[0-9]+) +slack +\(VIOLATED\)")
        self.startpoint_re = re.compile(r"Startpoint: (.*?)[ \n]")

    def _parse_one_stanza(self, s):
        m = self.vio_re.search(s)
        if not m:
            return
        minus_time = float(m.group(1))

        m = self.startpoint_re.search(s)
        if not m:
            print("WARN: could not find Startpoint")
            return
        start_point = m.group(1)

        if minus_time > self.vio_dict[start_point]:
            self.vio_dict[start_point] = minus_time

    def parse_rpt(self, filename):
        with open(filename) as f:
            in_min = False
            in_stanza = False
            s = ""
            for line in f:
                if line.strip() == "min_report":
                    in_min = True
                    in_stanza = False
                    s = ""
                    continue
                elif line.strip() == "min_report_end":
                    in_min = False
                    in_stanza = False
                    if len(s):
                        self._parse_one_stanza(s)
                    s = ""
                    continue

                if in_min:
                    if "Startpoint" in line:
                        in_stanza = True
                        if len(s):
                            self._parse_one_stanza(s)
                        s = ""

                    if in_stanza:
                        s = s + line

    def _repair_one(self, pin_name, pin_type, minus_time):
        insert_times = math.floor(minus_time / 0.5)
        if insert_times < 1:
            insert_times = 1

        for i in range(0, insert_times):
            self.vio_count += 1
            insert_buffer_line = f"insert_buffer {pin_name} {pin_type} sky130_fd_sc_hd__dlygate4sd3_1 net_HOLD_NET_{self.eco_iter}_{self.vio_count} U_HOLD_FIX_BUF_{self.eco_iter}_{self.vio_count}"
            self.repairs.append(insert_buffer_line)

    def repair(self):
        insts = self.odb.block.getInsts()
        # Single pass through insts
        for inst in insts:
            if inst.getName() in self.vio_dict:
                start_point = inst.getName()
                minus_time = self.vio_dict[start_point]
                for iterm in inst.getITerms():
                    mterm = iterm.getMTerm()  # mterm get the information
                    if mterm.getIoType() == "OUTPUT":
                        pin_name = start_point + "/" + mterm.getName()
                        pin_type = "ITerm"
                        self._repair_one(pin_name, pin_type, minus_time)
                        break

                # pin
                if pin_name == "" and self.skip_pin == 0:
                    pin_name = start_point
                    pin_type = "BTerm"
                    self._repair_one(pin_name, pin_type, minus_time)

    def write_tcl(self, filename):
        with open(filename, "w") as f:
            if len(self.repairs) == 0:
                f.write("No violations found")
            else:
                f.write("\n".join(self.repairs))

            f.write("\n")


@click.group()
def cli():
    pass


@click.command("insert_buffer")
@click.option("-o", "--output", default="./out.tcl", help="Output eco_fix.tcl")
@click.option(
    "-i",
    "--input-rpt",
    required=True,
    multiple=True,
    help="Input multi corner sta report",
)
@click.option(
    "-s", "--skip_pin", type=int, required=True, help="skip input output cases"
)
@click.option(
    "-l",
    "--input-lef",
    required=True,
    help="LEF file needed to have a proper view of the DEF files",
)
@click.argument("input_def")
def insert_buffer(output, input_lef, input_rpt, skip_pin, input_def):
    e = eco(input_lef=input_lef, input_def=input_def, skip_pin=skip_pin)
    for rpt in input_rpt:
        e.parse_rpt(rpt)
    e.repair()
    e.write_tcl(output)


cli.add_command(insert_buffer)

if __name__ == "__main__":
    cli()
