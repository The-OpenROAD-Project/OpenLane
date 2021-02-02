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
import re
from scripts.report.report import Report
from scripts.config.config import ConfigHandler
import scripts.utils.utils as utils
from scripts.report.get_file_name import get_name

parser = argparse.ArgumentParser(
    description='Creates a final summary csv report for a given design \
        + a manufacturability report + a runtime summary report.')

parser.add_argument('--design', '-d', required=True,
                    help='Design Path')

parser.add_argument('--design_name', '-dn', required=True,
                    help='Design Name')

parser.add_argument('--tag', '-t', required=True,
                    help='Run Tag')

parser.add_argument('--run_path', '-r', default=None,
                    help='Run Path')

parser.add_argument('--output_file', '-o', required=True,
                    help='Output Final Summary Report')

parser.add_argument('--man_report', '-m', required=True,
                    help='Output Manufacturability Reports')

parser.add_argument('--runtime_summary', '-rs', required=True,
                    help='Output Runtime Summary Reports')

args = parser.parse_args()
design = args.design
design_name = args.design_name
tag = args.tag
run_path=args.run_path
output_file = args.output_file
man_report = args.man_report
runtime_summary = args.runtime_summary

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
if run_path is None:
    run_path = utils.get_run_path(design, tag)
magic_drc_report=get_name(str(run_path)+"/reports/magic/", "magic.drc")
lvs_report=str(run_path)+"/results/lvs/"+design_name+".lvs_parsed.lef.log"
if not os.path.exists(lvs_report):
    lvs_report=str(run_path)+"/results/lvs/"+design_name+".lvs_parsed.gds.log"
magic_antenna_report=get_name(str(run_path)+"/reports/magic/","magic.antenna_violators.rpt")
arc_antenna_report=get_name(str(run_path)+"/reports/routing/","antenna.rpt")

printArr = []

printArr.append("Design Name: " + design_name)
printArr.append("Run Directory: " + str(run_path))

splitLine = '----------------------------------------'

# Summarizing Magic DRC
drcVioDict = dict()
cnt = 0
if os.path.exists(magic_drc_report):
    drcFileOpener = open(magic_drc_report)
    if drcFileOpener.mode == 'r':
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
        if (len(drcSections) > 2):
            for i in range(1, len(drcSections) - 1, 2):
                drcVioDict[drcSections[i]] = len(drcSections[i + 1].split("\n")) - 2
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
    tot_cnt = 0
    for ant in antContent:
        if len(str(ant).strip()):
            tot_cnt+=1
    printArr.append("Number of pins violated: " + str(tot_cnt))
else:
    printArr.append("No antenna report found.")


# write into file
outputFileOpener = open(man_report,"w")
outputFileOpener.write("\n".join(printArr))
outputFileOpener.close()




def getListOfFiles(dirName):
    # create a list of file and sub directories
    # names in the given directory
    allFiles = list()
    listOfFile = os.listdir(dirName)
    # Iterate over all the entries
    for entry in listOfFile:
        # Create full path
        fullPath = os.path.join(dirName, entry)
        # If entry is a directory then get the list of files in this directory
        if os.path.isdir(fullPath):
            allFiles = allFiles + getListOfFiles(fullPath)
        else:
            allFiles.append(fullPath)
    return allFiles

def conver_to_seconds(runtime):
    pattern = re.compile(r'\s*([\d+]+)h([\d+]+)m([\d+]+)s([\d+]+)+ms')
    m = pattern.match(runtime)
    time = int(m.group(1))*60*60 + int(m.group(2))*60 + int(m.group(3)) + int(m.group(4))/1000.0
    return str(time)

# Creating a runtime summary report
logs_path=run_path+"/logs"
neededfiles = sorted([(int(os.path.basename(f).split("-",1)[0]),f) for f in getListOfFiles(logs_path) if os.path.isfile(os.path.join(logs_path, f)) and len(f.split('_')) > 1 and f.split('_')[-1] == "runtime.txt" and len(os.path.basename(f).split('-')) > 1 and os.path.basename(f).split('-')[0].isnumeric()])
runtimeArr = []
prasableRuntimeArr= []
for (idx,f) in neededfiles:
    stagename = os.path.basename(f).split("_runtime.txt")[0]
    runtimeFileOpener = open(f, "r")
    if runtimeFileOpener.mode == 'r':
        runtimeContent = runtimeFileOpener.read().strip()
    runtimeFileOpener.close()
    runtimeArr.append(str(stagename)+ " "+ str(runtimeContent))
    prasableRuntimeArr.append(str(stagename)+ " "+ conver_to_seconds(runtimeContent))

# write into file
outputFileOpener = open(runtime_summary,"w")
outputFileOpener.write("\n".join(runtimeArr))
outputFileOpener.close()

outputFileOpener = open(runtime_summary+".parsable","w")
outputFileOpener.write("\n".join(prasableRuntimeArr))
outputFileOpener.close()
