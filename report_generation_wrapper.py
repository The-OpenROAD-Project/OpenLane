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

# The only purpose of this file is to create a wrapper around report.py and config.py and make them usable by flow.tcl

import argparse
import os
from scripts.report.report import Report
from scripts.config.config import ConfigHandler
import scripts.utils.utils as utils

parser = argparse.ArgumentParser(
    description='Creates a csv report for a given design.')

parser.add_argument('--design', '-d', required=True,
                    help='Design Path')

parser.add_argument('--design_name', '-dn', required=True,
                    help='Design Name')

parser.add_argument('--tag', '-t', required=True,
                    help='Run Tag')

parser.add_argument('--run_path', '-r', default=None,
                    help='Run Path')

parser.add_argument('--output_file', '-o', required=True,
                    help='Final Summary Report')

parser.add_argument('--man_report', '-m', required=True,
                    help='Manufacturability Reports')

args = parser.parse_args()
design = args.design
design_name = args.design_name
tag = args.tag
run_path=args.run_path
output_file = args.output_file
man_report = args.man_report

# Extracting Configurations
params = ConfigHandler.get_config(design, tag, run_path)
# Extracting Report
report = Report(design, tag, design_name,params,run_path).get_report()
# write into file
outputFileOpener = open(output_file,"w")
outputFileOpener.write(Report.get_header() + "," + ConfigHandler.get_header())
outputFileOpener.write("\n")
outputFileOpener.write(report)
outputFileOpener.close()

# Adding Extra Attributes computed from configs and reported statistics
utils.addComputedStatistics(output_file)

# Tracking Magic DRC, LVS, Antenna Logs:
magic_drc_report=str(run_path)+"/logs/magic/magic.drc"
lvs_report=str(run_path)+"/results/lvs/"+design_name+".lvs_parsed.log"
magic_antenna_report=str(run_path)+"/reports/magic/magic.antenna_violators.rpt"
arc_antenna_report=str(run_path)+"/reports/routing/antenna.rpt"

printArr = []

printArr.append("Design Name: " + design_name)
printArr.append("Run Directory: " + run_path)


# Summarizing Magic DRC
drcVioDict = dict()
cnt = 0
if os.path.exists(magic_drc_report):
    drcFileOpener = open(magic_drc_report)
    if drcFileOpener.mode == 'r':
        drcContent = drcFileOpener.read()
    drcFileOpener.close()

    splitLine = '----------------------------------------'

    # design name
    # violation message
    # list of violations
    # Total Count:
    printArr.append(splitLine)
    printArr.append("\nMagic DRC Summary:")
    printArr.append("Source: " + str(magic_drc_report))
    if drcContent is not None:
        drcSections = drcContent.split(splitLine)
        if (len(drcSections) > 2):
            for i in range(1, len(drcSections) - 1, 2):
                drcVioDict[drcSections[i]] = len(drcSections[i + 1].split("\n"))
            for key in drcVioDict:
                val = drcVioDict[key]
                cnt += val
                printArr.append("Violation Message \"" + str(key.strip()) + " \"found " + str(val) + " Times.")
    printArr.append("Total Magic DRC violations is " + str(cnt))
else:
    printArr.append("Source not found.")
# Summarizing LVS
printArr.append(splitLine)
printArr.append("\nLVS Summary:")
printArr.append("Source: "+str(lvs_report))
if os.path.exists(lvs_report):
    lvsFileOpener = open(lvs_report)
    if lvsFileOpener.mode == 'r':
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
    if antFileOpener.mode == 'r':
        antContent = antFileOpener.read().split("\n")[-5:]
    antFileOpener.close()
    for line in antContent:
        if line.find("violated:") != -1:
            printArr.append(line)
elif os.path.exists(magic_antenna_report):
    printArr.append("Source: " + str(magic_antenna_report))
    antFileOpener = open(magic_antenna_report)
    if antFileOpener.mode == 'r':
        antContent = antFileOpener.read().split("\n")
    antFileOpener.close()
    printArr.append("Number of pins violated: " + str(len(antContent)))
else:
    printArr.append("No antenna report found.")


# write into file
outputFileOpener = open(man_report,"w")
outputFileOpener.write("\n".join(printArr))
outputFileOpener.close()
