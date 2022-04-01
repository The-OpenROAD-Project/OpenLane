# Copyright 2021 The University of Michigan
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
import os
import odb
from collections import defaultdict
import math

parser = argparse.ArgumentParser(
    description="Converts a 23-spef_extraction_multi_corner_sta.min.rpt file to a eco insert buffer tcl file."
)

parser.add_argument(
    "--skip_pin", "-s", type=int, required=True, help="skip input ouput cases"
)
parser.add_argument(
    "--input_file",
    "-i",
    required=True,
    help="input 23-spef_extraction_multi_corner_sta.min.rpt",
)
parser.add_argument(
    "--lef_file", "-l", required=True, help="input lef file to load design"
)
parser.add_argument(
    "--def_file", "-d", required=True, help="input def file for detailed information"
)
parser.add_argument("--output_file", "-o", required=True, help="output eco_fix.tcl")

args = parser.parse_args()
input_file = args.input_file
output_file = args.output_file
def_file = args.def_file
lef_file = args.lef_file
skip_pin = args.skip_pin

splitLine = "\n\n\n"
printArr = []


db = odb.dbDatabase.create()
print(def_file)
odb.read_lef(db, lef_file)
odb.read_def(db, os.path.join(def_file))  # get db from the file
chip = db.getChip()
block = chip.getBlock()
insts = block.getInsts()
insts_pin = block.getBTerms()  # pins boundary

vio_dict = defaultdict(list)

# iteration to find minus slack
# create insert_buffer command
# Converting Magic DRC
if os.path.exists(input_file):
    drcFileOpener = open(input_file)
    if drcFileOpener.mode == "r":
        drcContent = drcFileOpener.read()
    drcFileOpener.close()

    # design name
    # violation message
    # list of violations
    # Total Count:
    vio_count = 0
    if drcContent is not None:
        drcSections = drcContent.split(splitLine)
        # if (len(drcSections) > 2):
        for i in range(0, len(drcSections)):
            vio_name = drcSections[i].strip()
            report_end_str = re.search("min_report_end", vio_name)
            if report_end_str is not None:
                print("report is incomplete")
                break
            minus_time_str = re.search(
                r"([0-9]+\.[0-9]+) +slack +\(VIOLATED\)", vio_name
            )
            if minus_time_str is not None:
                # vio_count += 1
                start_point_str = re.search(r"Startpoint: (.*?)[ \n]", vio_name)
                if start_point_str is not None:
                    start_point = start_point_str.group(1)
                    # FF
                    pin_name = ""
                    for inst in insts:
                        # find the pin inside inst
                        if inst.getName() == start_point:
                            for iterm in inst.getITerms():  # instance pin
                                mterm = iterm.getMTerm()  # mterm get the information
                                if mterm.getIoType() == "OUTPUT":
                                    printArr.append(
                                        "# Found SP: "
                                        + start_point
                                        + "mterm: "
                                        + mterm.getName()
                                    )
                                    pin_name = start_point + "/" + mterm.getName()
                                    pin_type = "ITerm"
                                    # master = inst.getMaster()
                                    vio_dict[pin_name + " " + pin_type].append(
                                        float(minus_time_str.group(1))
                                    )
                                    break
                    # pin
                    if pin_name == "" and skip_pin == 0:
                        pin_name = start_point
                        pin_type = "BTerm"
                        # continue
                        vio_dict[pin_name + " " + pin_type].append(
                            float(minus_time_str.group(1))
                        )

        eco_iter = os.environ["ECO_ITER"]
        for pin_unq in vio_dict.keys():
            insert_times = math.floor(
                abs(min(vio_dict[pin_unq])) / 0.5
            )  # insert buffer conservatively
            if insert_times < 1:
                insert_times = 1

            for i in range(0, insert_times):
                vio_count += 1
                print("insert multiple buffers: ", insert_times + 1)
                insert_buffer_line = f"insert_buffer {pin_unq} sky130_fd_sc_hd__dlygate4sd3_1 net_HOLD_NET_{eco_iter}_{vio_count} U_HOLD_FIX_BUF_{eco_iter}_{vio_count}"
                printArr.append(insert_buffer_line)
                print(insert_buffer_line)

        if vio_count == 0:
            insert_buffer_line = "No violations found"
            printArr.append(insert_buffer_line)
else:
    printArr.append("Source not found.")

# write into file
outputFileOpener = open(output_file, "w")
outputFileOpener.write("\n".join(printArr))
outputFileOpener.close()
