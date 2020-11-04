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

parser = argparse.ArgumentParser(
    description='Ends the li1 hack to prevent routing on li1')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--tmpFile', '-t', required=True,
                    help='Configuration file')

args = parser.parse_args()
def_file_name = args.defFile
tmp_file_name = args.tmpFile




defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defContent =defFileOpener.read().split("\n")
defFileOpener.close()

tmpFileOpener = open(tmp_file_name,"r")
if tmpFileOpener.mode == 'r':
    printedXY =tmpFileOpener.read().split("\n")
tmpFileOpener.close()

outOrder = 0
for i in range(len(defContent)):
    if outOrder == 2:
        break    
    
    if defContent[i].find("li1") != -1:
        tmpLine = defContent[i].split(" ")
        if tmpLine [0] != "TRACKS":
            continue
        if tmpLine[1] == "X":
            tmpLine[4] = printedXY[0]    
        else:
            tmpLine[4] = printedXY[1]    
        defContent[i] = " ".join(tmpLine)
        outOrder+=1
        continue


defFileOpener = open(def_file_name,"w")
defFileOpener.write("\n".join(defContent))
defFileOpener.close()