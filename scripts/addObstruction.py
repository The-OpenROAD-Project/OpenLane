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
    description='Creates and obstruction in def and lef files.')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--lefFile', '-l',required=True,
                   help='Input LEF')

parser.add_argument('--obstruction', '-obs', required=True,
                    help='name of obstruction')

parser.add_argument('--placementX', '-px', required=False,default=0,
                    help='X coordinate to place, defaults to 0')

parser.add_argument('--placementY', '-py', required=False,default=0,
                    help='Y coordinate to place, defaults to 0')


parser.add_argument('--sizeWidth', '-sw', required=True,
                    help='the width of the macro')

parser.add_argument('--sizeHeight', '-sh', required=True,
                    help='the height of the macro')

parser.add_argument('--dbunit', '-db', required=False,default=1000,
                    help='reflects the value of the data base unit')

parser.add_argument('--layerNames', '-ln', nargs='+',required=True,
                    help='the name of the layers on which to place the macro')

parser.add_argument('--fixed', '-f', action='store_true', default=False,
                help="a flag to signal whether the placement should be fixed or placed")



args = parser.parse_args()
#def/lef names
def_file_name = args.defFile
lef_file_name = args.lefFile

#obstruction Info
obs = args.obstruction
X = args.placementX
Y = args.placementY
W = args.sizeWidth
H = args.sizeHeight 
fixed = args.fixed
layerNames = list(dict.fromkeys(args.layerNames))
dbunit = args.dbunit

#read Def
defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defContent =defFileOpener.read().split("\n")
defFileOpener.close()

#modify Def
for i in range(len(defContent)):
    if defContent[i].find("COMPONENTS") != -1:
        tmpLine = defContent[i].split(" ")
        tmpLine[1] = str(int(tmpLine[1])+1) 
        defContent[i] = " ".join(tmpLine)
        placedWord =""
        if fixed:
            placedWord = "FIXED"
        else:
            placedWord = "PLACED"
        defContent.insert(i+1,"- obs_"+str(obs)+" obs_"+str(obs)+" + "+placedWord+" ( "+str(int(float(X)*float(dbunit)))+" "+str(int(float(Y)*float(dbunit)))+" ) N ;") 
        break

#write into Def
defFileOpener = open(def_file_name,"w")
defFileOpener.write("\n".join(defContent))
defFileOpener.close()


lefFileOpener = open(lef_file_name,"r")
if lefFileOpener.mode == 'r':
    lefContent =lefFileOpener.read().split("\n")
lefFileOpener.close()


printedString = "MACRO obs_"+str(obs)+"\n \
  CLASS BLOCK ;\n \
  FOREIGN obs_"+str(obs)+" ;\n \
  ORIGIN 0.000 0.000 ;\n \
  SIZE "+ str(float(W)) +" BY "+ str(float(H)) +" ;\n \
  OBS\n"

for lname in layerNames:
    printedString+="        LAYER "+lname+" ;\n \
            RECT 0.000 0.000 "+str(float(W)) +" "+str(float(H)) +" ;\n"

printedString+="   END\n \
END obs_"+str(obs)

#append the obstruction definition
lefContent.insert(len(lefContent)-1,printedString)

#write the modified lef
lefFileOpener = open(lef_file_name,"w")
lefFileOpener.write("\n".join(lefContent))
lefFileOpener.close()
