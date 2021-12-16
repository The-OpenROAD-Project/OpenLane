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
    description='produces a widened site lef')

parser.add_argument('--lefFile', '-l',required=True,
                    help='Input LEF')

parser.add_argument('--widenValue', '-w',
                    help='widen value to be used as a factor or an absolute value based on the factor flage')

parser.add_argument('--factor', '-f', action='store_true', default=False,
                help="use the widen value as a factor or an absolute value")


parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
lef_file_name = args.lefFile
widenValue = args.widenValue
isFactor = args.factor
out_file_name = args.output

#reading lef
lefFileOpener = open(lef_file_name,"r")
if lefFileOpener.mode == 'r':
    lefContent = lefFileOpener.read().split("\n")
lefFileOpener.close()


startFlag = False
doneFlag = False
for i in range(len(lefContent)):
    #looking for SITE
    if lefContent[i].find("SITE") != -1:
        startFlag = True

    if startFlag:
        #looking for SIZE
        if lefContent[i].find("SIZE") != -1:
            line = lefContent[i].split(" ")
            for j in range(len(line)):
                if line[j] == "SIZE":
                    #if a factor modify the value by the factor
                    for x  in range(j+1,len(line)):
                        if line[x] != "": 
                            if isFactor:
                                orgVal = float(line[x])
                                widenValue = float(widenValue)*orgVal
                            #change the value
                            line[x] = str(widenValue)
                            doneFlag = True
                            break
                    break
            lefContent[i] = " ".join(line)

    if doneFlag:
        break

#writing to output file
outFileOpener = open(out_file_name,"w")
outFileOpener.write("\n".join(lefContent))
outFileOpener.close()