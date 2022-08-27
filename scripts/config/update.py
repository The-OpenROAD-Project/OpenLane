# Copyright 2020-2022 Efabless Corporation
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
import click
import subprocess


@click.command()
@click.option(
    "-p",
    "--pdk",
    required=True,
    help="The name of the PDK that the updated design(s) configuration belongs to.",
)
@click.option(
    "-s",
    "--scl",
    required=True,
    help="The name of the STD_CELL_LIBRARY that the updated design(s) configuration belongs to.",
)
@click.option(
    "-b",
    "--best-results",
    required=True,
    help="""
    This is the CSV file containing the best run for each design in a specific exploration. The log file will be used to determine the name of the configuration file to update from.

    The csv file provided must only have one ocurrence of each design. In the event
    of multiple occurences for a design, only the last value will be reflected.

    To tolerate custom CSV files, the script only exctracts the name of the design, its corresponding configuration file path, and whether the design passed or not by reading the flow_status.
    """,
)
@click.option(
    "-C/-K",
    "--clean/--keep",
    default=False,
    help="Delete the config file from which data was extracted.",
)
@click.option(
    "-u/-k",
    "--update-clock-period/--dont-update-clock-period",
    default=False,
    help="Specifies whether or not to delete the old configuration file that the updated configuration file is based off.",
)
@click.argument("designs", nargs=-1)
def update(pdk, scl, best_results, clean, update_clock_period, designs):
    OPENLANE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    DESIGN_DIR = os.path.join(OPENLANE_DIR, "designs")

    logFileOpener = open(OPENLANE_DIR + "/regression_results/" + best_results, "r")
    logFileData = logFileOpener.read().split("\n")
    logFileOpener.close()

    headerInfo = logFileData[0].split(",")
    configIdx = 0
    designIdx = 0
    flow_statusIdx = 0
    clkPeriodIdx = -1
    for i in range(len(headerInfo)):
        if headerInfo[i] == "config":
            configIdx = i
            continue
        if headerInfo[i] == "design":
            designIdx = i
            continue
        if headerInfo[i] == "flow_status":
            flow_statusIdx = i
            continue
        if headerInfo[i] == "suggested_clock_period":
            clkPeriodIdx = i

    designConfigDict = dict()
    designFailDict = dict()
    designClockDict = dict()

    logFileData = logFileData[1:]

    for line in logFileData:
        if line != "":
            splitLine = line.split(",")
            designConfigDict[str(splitLine[designIdx])] = str(splitLine[configIdx])
            designFailDict[str(splitLine[designIdx])] = (
                str(splitLine[flow_statusIdx]) == "flow_completed"
            )
            if clkPeriodIdx != -1:
                designClockDict[str(splitLine[designIdx])] = str(
                    splitLine[clkPeriodIdx]
                )

    if len(designs) == 0:
        designs = [key for key in designConfigDict]

    for design in designs:
        if design not in designConfigDict.keys():
            print(f"{design} not found in sheet. Skipping...")

        if not designFailDict[design]:
            print(f"Skipping {design} ...")
            continue

        print(f"Updating {design} config...")
        base_path = design
        if not os.path.isdir(design):
            # Check if design exists in OpenLane designs folder
            base_path = os.path.join(DESIGN_DIR, design)
            if not os.path.isdir(base_path):
                print(
                    f"Design {design} not found either relative to the current working directory or the OpenLane design order.",
                    file=sys.stderr,
                )
                exit(-1)

        configFileToUpdate = (
            str(base_path) + "/" + str(pdk) + "_" + str(scl) + "_config.tcl"
        )
        configFileBest = str(base_path) + "/" + str(designConfigDict[design]) + ".tcl"

        configFileBestOpener = open(configFileBest, "r")
        configFileBestData = configFileBestOpener.read().split("\n")
        configFileBestOpener.close()

        newData = ""
        copyFrom = False
        for line in configFileBestData:
            if line == "# Regression":
                copyFrom = True

            if copyFrom:
                newData += line + "\n"

        configFileToUpdateOpener = open(configFileToUpdate, "a+")
        configFileToUpdateOpener.write(newData)
        if update_clock_period:
            if design in designClockDict and float(designClockDict[design]) > 0:
                clockLine = (
                    '\n# Suggested Clock Period:\nset ::env(CLOCK_PERIOD) "'
                    + str(round(float(designClockDict[design]), 2))
                    + '"\n'
                )
                configFileToUpdateOpener.write(clockLine)
        configFileToUpdateOpener.close()

        if clean:
            clean_cmd = f"rm -f {configFileBest}"
            subprocess.check_output(clean_cmd.split())
            # clean config file


if __name__ == "__main__":
    update()
