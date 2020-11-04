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

import re
import argparse


#for i in range(len(sys.argv)):

parser = argparse.ArgumentParser(
    description='Replaces fake diodes with real diodes based on the violating cells/pins')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--viosFile', '-v', required=True,
                    help='vios.txt containing white space separated cells that cause antenna violations')

parser.add_argument('--fakeDiode', '-f', required=True,
                    help='the name of the fake diode')
parser.add_argument('--trueDiode', '-t', required=True,
                    help='the name of the true diode')

args = parser.parse_args()

viosFile    =   args.viosFile
defFile     =   args.defFile

fakeDiode   =   args.fakeDiode
trueDiode   =   args.trueDiode




tmpFile = open(viosFile,"r")
if tmpFile.mode == 'r':
    listOfVios =tmpFile.read().split()
tmpFile.close()

tmpFile = open(defFile,"r")
if tmpFile.mode == 'r':
    defContent = tmpFile.read().split("\n")
tmpFile.close()

exitFlag = False
for i in range(len(defContent)):
    if defContent[i].find("COMPONENTS") != -1:
        if exitFlag == True:
            break
        else:
            exitFlag = True
            continue

    antennaPos = defContent[i].find("ANTENNA_")
    if antennaPos != -1:
        cell = re.findall(r'- ANTENNA_(\S+)_.* '+fakeDiode+'.*', defContent[i])
        if len(cell) >= 1:
            if cell[0] in listOfVios:
                defContent[i] = defContent[i].replace(fakeDiode, trueDiode)
                
tmpFile = open(defFile,"w")
tmpFile.write("\n".join(defContent))
tmpFile.close()



