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
import re
parser = argparse.ArgumentParser(
    description='initiates the li1 hack')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--configFile', '-c', required=True,
                    help='padframe.cfg file to get pad order')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
def_file_name = args.defFile
cfg_file_name = args.configFile
out_file_name = args.output

cfgFileOpener = open(cfg_file_name, "r")
if cfgFileOpener.mode == 'r':
    cfgContent = cfgFileOpener.read().split("\n")
cfgFileOpener.close()


padDict = {"E":[], "N":[], "W":[], "S":[]}

padPinDict = dict()

for line in cfgContent:
    if line != "":
        splitLine = line.split(" ") 
        if splitLine[0] == "PAD":
            if splitLine[2] in padDict.keys():
                padDict[splitLine[2]].append(splitLine[1])

defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defContent =defFileOpener.read().split("\n")
defFileOpener.close()





startFlag = False
for line in defContent:
    if line.find("NETS") != -1:
        if startFlag:
            break
        else:
            startFlag = True

    if startFlag:
        if line != "":
            if line[0] == '-':
                splitLine = re.split(r'[()]', line)
                for key in padDict.keys():
                    for i in range(len(splitLine)):
                        if i:
                            tmp = splitLine[i].split(" ")
                            while len(tmp)>1 and tmp[0] == "":
                                tmp.pop(0)
                            if tmp[0] in padDict[key]:
                                for j in range(len(splitLine)):
                                    if j:
                                        macroPin = splitLine[j].split(" ")
                                        while len(macroPin) and macroPin[0] == "":
                                            macroPin.pop(0)
                                        if len(macroPin):
                                            if macroPin[0] in padPinDict.keys():
                                                padPinDict[macroPin[0]][key].append(macroPin[1])
                                            else:
                                                padPinDict[macroPin[0]] = {"E":[], "N":[], "W":[], "S":[]}
                                                padPinDict[macroPin[0]][key].append(macroPin[1])
                                break


bigListOut = []
for comp in padPinDict.keys():
    bigListOut.append("\n- " + comp)
    for ori in padPinDict[comp].keys():
        bigListOut.append("\n"+ori+"\n")
        bigListOut.extend(padPinDict[comp][ori])

outFileOpener = open(out_file_name, "w")
outFileOpener.write("\n".join(bigListOut))
outFileOpener.close()
