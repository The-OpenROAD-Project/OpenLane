# Copyright 2020-2021 Efabless Corporation
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

# The only purpose of this file is to create a wrapper around report.py and config.py and make them usable by flow.tcl

import os
import click
import re

import utils.utils as utils

from report.report import Report
from report.get_file_name import get_name

from config.config import ConfigHandler


@click.command()
@click.option("--design", "-d", required=True, help="Design Path")
@click.option("--design_name", "-n", required=True, help="Design Name")
@click.option("--tag", "-t", required=True, help="Run Tag")
@click.option(
    "--run_path",
    "-r",
    default=None,
    help="Run Path [Optional, otherwise derived from tag]",
)
@click.option("--output_file", "-o", required=True, help="Output Final Summary Report")
@click.option(
    "--man_report", "-m", default="/dev/null", help="Output Manufacturability Reports"
)
def cli(design, design_name, tag, run_path, output_file, man_report):
    """
    Creates manufacturability and metric summary reports for a given design and OpenLane run.
    """
    # Extracting Configurations
    params = ConfigHandler.get_config_for_run(run_path, design, tag)

    # Extracting Report
    report = Report(design, tag, design_name, params, run_path).get_report()
    # Write into file
    with open(output_file, "w") as f:
        f.write(Report.get_header() + "," + ConfigHandler.get_header())
        f.write("\n")
        f.write(report)

    # Adding Extra Attributes computed from configs and reported statistics
    utils.add_computed_statistics(output_file)

    # Tracking Magic DRC, LVS, Antenna Logs:
    run_path = run_path or utils.get_run_path(design, tag)

    _, magic_antenna_report = get_name(
        os.path.join(run_path, "reports", "routing"), "antenna_violators.rpt"
    )
    _, arc_antenna_report = get_name(
        os.path.join(run_path, "logs", "signoff"), "arc.log"
    )
    _, magic_drc_report = get_name(
        os.path.join(run_path, "reports", "signoff"), "drc.rpt"
    )
    _, lvs_report = get_name(
        os.path.join(run_path, "logs", "signoff"), f"{design_name}.lef.lvs.log"
    )

    printArr = []

    printArr.append("Design Name: " + design_name)
    printArr.append("Run Directory: " + str(run_path))

    splitLine = "----------------------------------------"

    # Summarizing Magic DRC
    drcVioDict = dict()
    cnt = 0
    if os.path.exists(magic_drc_report):
        drcFileOpener = open(magic_drc_report)
        if drcFileOpener.mode == "r":
            drcContent = drcFileOpener.read()
        drcFileOpener.close()

        # design name
        # violation message
        # list of violations
        # Total Count:
        printArr.append(splitLine)
        printArr.append("\nMagic DRC Summary:")
        printArr.append("Source: " + str(magic_drc_report))
        if drcContent is not None:
            drcSections = drcContent.split(splitLine)
            if len(drcSections) > 2:
                for i in range(1, len(drcSections) - 1, 2):
                    drcVioDict[drcSections[i]] = len(drcSections[i + 1].split("\n")) - 2
                for key in drcVioDict:
                    val = drcVioDict[key]
                    cnt += val
                    printArr.append(
                        'Violation Message "'
                        + str(key.strip())
                        + ' "found '
                        + str(val)
                        + " Times."
                    )
        printArr.append("Total Magic DRC violations is " + str(cnt))
    else:
        printArr.append("Source not found.")
    # Summarizing LVS
    printArr.append(splitLine)
    printArr.append("\nLVS Summary:")
    printArr.append("Source: " + str(lvs_report))
    if os.path.exists(lvs_report):
        lvsFileOpener = open(lvs_report)
        if lvsFileOpener.mode == "r":
            lvsContent = lvsFileOpener.read()
        lvsFileOpener.close()
        flag = False
        for line in lvsContent.split("\n"):
            if line.find("Total errors =") != -1:
                flag = True
                printArr.append(line)
            elif line.find("net") != -1:
                printArr.append(line)

        if not flag:
            printArr.append("Design is LVS clean.")
    else:
        printArr.append("Source not found.")

    # Summarizing Antennas
    printArr.append(splitLine)
    printArr.append("\nAntenna Summary:")

    if os.path.exists(arc_antenna_report):
        printArr.append("Source: " + str(arc_antenna_report))
        antFileOpener = open(arc_antenna_report)
        antContent = []
        if antFileOpener.mode == "r":
            antContent = antFileOpener.read().split("\n")
        antFileOpener.close()
        pin_violations = -1
        net_violations = -1
        for line in antContent:
            pin_violation_match = re.match(r".*Found\s+(\d+)\s+pin violations", line)
            if pin_violation_match is not None:
                pin_violations = pin_violation_match[1]
            net_violation_match = re.match(r".*Found\s+(\d+)\s+net violations", line)
            if net_violation_match is not None:
                net_violations = net_violation_match[1]
        printArr.append(f"Pin violations: {pin_violations}")
        printArr.append(f"Net violations: {net_violations}")
    elif os.path.exists(magic_antenna_report):
        printArr.append("Source: " + str(magic_antenna_report))
        antFileOpener = open(magic_antenna_report)
        antContent = []
        if antFileOpener.mode == "r":
            antContent = antFileOpener.read().split("\n")
        antFileOpener.close()
        tot_cnt = 0
        for ant in antContent:
            if len(str(ant).strip()):
                tot_cnt += 1
        printArr.append("Number of pins violated: " + str(tot_cnt))
    else:
        printArr.append("No antenna report found.")

    # write into file
    with open(man_report, "w") as f:
        f.write("\n".join(printArr))
        f.write("\n")


if __name__ == "__main__":
    cli()
