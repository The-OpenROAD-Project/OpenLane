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
    description='initiates the li1 hack to prevent routing on li1')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--lefFile', '-l',required=True,
                   help='Input LEF')

parser.add_argument('--tmpFile', '-t', required=True,
                    help='tmp file to store tmp value')

args = parser.parse_args()
def_file_name = args.defFile
lef_file_name = args.lefFile
tmp_file_name = args.tmpFile


defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defContent =defFileOpener.read().split("\n")
defFileOpener.close()



areaOut = ["0", "0"]
printedXY = ["0", "0"]

exitFlag = False
outOrder = 0

for i in range(len(defContent)):
   
    if outOrder == 4:
        break
   
    if defContent[i].find("DIEAREA") != -1:
        tmpLine = defContent[i].split(" ")
        areaOut[0] = str(int(int(tmpLine[6])/1000)) + "." + str((int(tmpLine[6]))%1000)
        areaOut[1] = str(int(int(tmpLine[7])/1000)) + "." + str((int(tmpLine[7]))%1000)
        outOrder+=1
        continue
    
    if defContent[i].find("li1") != -1:
        tmpLine = defContent[i].split(" ")
        if tmpLine [0] != "TRACKS":
            continue
        if tmpLine[1] == "X":
            printedXY[0] = tmpLine[4]
            tmpLine[4] = "1"    
        else:
            printedXY[1] = tmpLine[4]
            tmpLine[4] = "1"    
        defContent[i] = " ".join(tmpLine)
        outOrder+=1
        continue

    if defContent[i].find("COMPONENTS") != -1 and exitFlag ==False:
        tmpLine = defContent[i].split(" ")
        tmpLine[1] = str(int(tmpLine[1])+1) 
        defContent[i] = " ".join(tmpLine)
        defContent.insert(i+1,"- obs_li1 obs + PLACED ( 0 0 ) N ;") 
        exitFlag = True
        outOrder+=1
        continue


    

defFileOpener = open(def_file_name,"w")
defFileOpener.write("\n".join(defContent))
defFileOpener.close()

lefFileOpener = open(lef_file_name,"r")
if lefFileOpener.mode == 'r':
    lefContent =lefFileOpener.read().split("\n")
lefFileOpener.close()


printedString = "MACRO obs\n \
  CLASS BLOCK ;\n \
  FOREIGN obs ;\n \
  ORIGIN 0.000000 0.000000 ;\n \
  SIZE "+ areaOut[0] +" BY "+ areaOut[1] +" ;\n \
  OBS\n \
      LAYER li1 ;\n \
        RECT 0.000 0.000 "+areaOut[0] +" "+areaOut[1] +" ;\n \
  END\n \
END obs"


lefContent.insert(len(lefContent)-1,printedString)

lefFileOpener = open(lef_file_name,"w")
lefFileOpener.write("\n".join(lefContent))
lefFileOpener.close()


tmpFileOpener = open(tmp_file_name,"w")
tmpFileOpener.write("\n".join(printedXY))
tmpFileOpener.close()
