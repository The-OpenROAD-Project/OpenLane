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

from reader import OdbReader


@click.group()
def cli():
    pass


@click.command("insert_buffer")
@click.option("-o", "--output", default="./out.tcl", help="Output eco_fix.tcl")
@click.option("-i", "--input-rpt", required=True, help="Input multi corner sta report")
@click.option("-s", "--skip_pin", type=int, required=True, help="skip input output cases")
@click.option(
    "-l",
    "--input-lef",
    required=True,
    help="LEF file needed to have a proper view of the DEF files",
)
@click.argument("input_def")
def insert_buffer(output, input_lef, input_rpt, skip_pin, input_def):
    splitLine = "\n\n\n"
    printArr = []

    top = OdbReader(input_lef, input_def)
    insts = top.block.getInsts()

    vio_dict = {}

    # iteration to find minus slack
    # create insert_buffer command
    # Converting Magic DRC
    if os.path.exists(input_rpt):
        drcFileOpener = open(input_rpt)
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
                    start_point_str = re.search("Startpoint: (.*?)[ \n]", vio_name)
                    if start_point_str is not None:
                        start_point = start_point_str.group(1)
                        # FF
                        pin_name = ""
                        for inst in insts:
                            # find the pin inside inst
                            if inst.getName() == start_point:
                                for iterm in inst.getITerms():  # instance pin
                                    mterm = (
                                        iterm.getMTerm()
                                    )  # mterm get the information
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
    outputFileOpener = open(output, "w")
    outputFileOpener.write("\n".join(printArr))
    outputFileOpener.close()


cli.add_command(insert_buffer)

if __name__ == "__main__":
    cli()
