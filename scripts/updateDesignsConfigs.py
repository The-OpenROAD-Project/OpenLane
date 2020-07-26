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
import subprocess

parser = argparse.ArgumentParser(
        description="update configuration of design(s) per given PDK")

parser.add_argument('--root', '-r', action='store', default='./',
                help="The root directory. assuming root/designs, root/scripts root/logs")

parser.add_argument('--pdk', '-p', action='store', required=True,
                help="The name of the PDK")

parser.add_argument('--pdkVariant', '-pv', action='store', required=True,
                help="The name of the PDK_VARIANT")


parser.add_argument('--designs', '-d', nargs='+', default=[],
                help="designs to update ")

parser.add_argument('--best_results', '-b', action='store', required=True,
                help="name of the log file from which to extract the name of the best configs")

parser.add_argument('--clean', '-cl', action='store_true', default=False,
                help="deletes the config file that the data was extracted from")


args = parser.parse_args()
root = args.root
pdk = args.pdk
pdkVariant = args.pdkVariant
designs = list(dict.fromkeys(args.designs))
best_results = args.best_results
clean = args.clean

logFileOpener = open(root+'/regression_results/'+best_results, 'r')
logFileData = logFileOpener.read().split("\n")
logFileOpener.close()


headerInfo = logFileData[0].split(",")
configIdx = 0
designIdx = 0
runtimeIdx = 0
for i in range(len(headerInfo)):
    if headerInfo[i] == "config":
        configIdx = i
        continue
    if headerInfo[i] == "design":
        designIdx = i
        continue
    if headerInfo[i] == "runtime":
        runtimeIdx = i

designConfigDict = dict()
designFailDict = dict()

logFileData = logFileData[1:]

for line in logFileData:
    if line != "":
        splitLine = line.split(",")
        designConfigDict[str(splitLine[designIdx])] = str(splitLine[configIdx])
        designFailDict[str(splitLine[designIdx])] = str(splitLine[runtimeIdx])

if len(designs) == 0:
    designs = [key for key in designConfigDict]

for design in designs:
    if designFailDict[design] == '-1':
        print("Skipping " + design + " ...")
        continue
    
    print("Updating "+ design + " config...")

    configFileToUpdate = str(root)+"designs/"+str(design)+"/"+str(pdk)+"_"+str(pdkVariant)+"_config.tcl"
    configFileBest = str(root)+"designs/"+str(design)+"/"+str(designConfigDict[design])+".tcl"
    
    configFileBestOpener = open(configFileBest, 'r')
    configFileBestData = configFileBestOpener.read().split("\n")
    configFileBestOpener.close()
    
    newData = ""
    copyFrom = False
    for line in configFileBestData:
        if line == "# Regression":
            copyFrom = True

        if copyFrom == True:
            newData+=line+"\n"
    
    configFileToUpdateOpener = open(configFileToUpdate, 'a+')
    configFileToUpdateOpener.write(newData)
    configFileToUpdateOpener.close()
    
    if clean == True:
        clean_cmd = "rm -f {configFileBest}".format(
                    configFileBest=configFileBest,
        )
        subprocess.check_output(clean_cmd.split())
        #clean config file