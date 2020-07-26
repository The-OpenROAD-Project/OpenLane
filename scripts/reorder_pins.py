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
    description='initiates the li1 hack')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--macroName','-m',required=True,
                    help='macro name')

parser.add_argument('--configFile', '-c', required=True,
                    help='extracted pad pin order file to get pad order')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
def_file_name = args.defFile
macroName = args.macroName
cfg_file_name = args.configFile
out_file_name = args.output

dumpFile = "reorderPinDumpFile"
dumpArray = []

#reading the def sections, sections[1] is pins 
defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defSections =defFileOpener.read().split("PINS")
defFileOpener.close()

#reading the pre-extracted config file
cfgFileOpener = open(cfg_file_name, "r")
if cfgFileOpener.mode == 'r':
    cfgContent = cfgFileOpener.read().split("\n")
cfgFileOpener.close()

if len(cfgContent) < 10:
    outFileOpener = open(out_file_name, "w")
    outFileOpener.write("PINS".join(defSections))
    outFileOpener.close()
    exit()


#extracting the macro info from the file
padPinDict = {"E":[], "N":[], "W":[], "S":[]}

curOri = ""

startFlag = False
for line in cfgContent:
    if line != "":
        if line[0] == '-':
            if startFlag:
                break
            else:
                if line.split(" ")[1] == macroName:
                    startFlag = True 
                    continue
        if startFlag:
            if line in padPinDict.keys():
                curOri = line
                continue
            if curOri != "":
                padPinDict[curOri].append(line.split(" ")[0])


pinsComplete = defSections[1].split("- ")

pinsCnt = pinsComplete[0].split(" ")[1]
pinsComplete.pop(0)

pinsComplete[len(pinsComplete)-1] = pinsComplete[len(pinsComplete)-1].split(";")[0]+";"

#determining the minimum and maximum X and Y to determine the orientation of PINs
X = [0, 0]
Y = [0, 0]

pinsByName = dict()

for pin in pinsComplete:
    pinSections = pin.split("+")
    if pinSections[0].split(" ")[0] != "":
        pinsByName[pinSections[0].split(" ")[0]] = pin
    else:
        pinsByName[pinSections[0].split(" ")[1]] = pin
    
    for sec in pinSections:
        if sec.find("PLACED") != -1:
            secSplitted = sec.split(" ")
            X[0] = min(X[0], int(secSplitted[3]))
            X[1] = max(X[1], int(secSplitted[3]))
            Y[0] = min(Y[0], int(secSplitted[4]))
            Y[1] = max(Y[1], int(secSplitted[4]))
            break

pinOriDict = {"E":[], "N":[], "W":[], "S":[]}

def getOri(X, Y, x, y):
    ix = int(x)
    iy = int(y)
    if ix == X[0]:
        return "W"
    if ix == X[1]:
        return "E"
    if iy == Y[0]:
        return "N"
    if iy == Y[1]:
        return "S"
    lX = X[1] - X[0]
    lY = Y[1] - Y[0]
    if (ix - X[0]) < 0.05 * lX:
        return "W"
    if (X[1] - ix) < 0.05 * lX:
        return "E"
    if (iy - Y[0]) < 0.05 * lY:
        return "N"
    if (Y[1] - iy) < 0.05 * lY:
        return "S"
        

for pinName, pinInfo in pinsByName.items():
    pinSections = pinInfo.split("+")
    for sec in pinSections:
        if sec.find("PLACED") != -1:
            secSplitted = sec.split(" ")
            ori = getOri(X,Y,secSplitted[3],secSplitted[4])
            if ori in pinOriDict.keys():
                pinOriDict[ori].append(pinName)
          

#Removing pins that are already directed in the right orientation
for ori in pinOriDict.keys():
    commonList =  list(set(pinOriDict[ori]).intersection(padPinDict[ori]))
    for pin in pinOriDict[ori]: 
        if pin in commonList: 
            pinOriDict[ori].remove(pin) 
    for pin in padPinDict[ori]: 
        if pin in commonList: 
            padPinDict[ori].remove(pin) 



def pinSwap(pinA, pinB):  
    pinAInfo = pinsByName[pinA]
    pinBInfo = pinsByName[pinB]

    layerIdxA = -1
    layerIdxB = -1
    placedIdxA = -1
    placedIdxB = -1
    
   
    pinASections = pinAInfo.split("+")
    for sec in range(len(pinASections)):
        if pinASections[sec].find("LAYER") != -1:
            layerIdxA = sec
        elif pinASections[sec].find("PLACED") != -1:
            placedIdxA = sec

    pinBSections = pinBInfo.split("+")
    for sec in range(len(pinBSections)):
        if pinBSections[sec].find("LAYER") != -1:
            layerIdxB = sec
        elif pinBSections[sec].find("PLACED") != -1:
            placedIdxB = sec

    sucess = [(layerIdxA != -1), (layerIdxB !=-1)]
    if sucess[0] & sucess[1]:
        tmpSec = pinASections[layerIdxA]
        pinASections[layerIdxA] = pinBSections[layerIdxB]
        pinBSections[layerIdxB] = tmpSec
   
    sucess[0]&=(placedIdxA != -1)
    sucess[1]&=(placedIdxB !=-1)
    if sucess[0] & sucess[1]:
        tmpSec = pinASections[placedIdxA]
        pinASections[placedIdxA] = pinBSections[placedIdxB]
        pinBSections[placedIdxB] = tmpSec
   
    if sucess[0] & sucess[1]:
        pinsByName[pinA] = "+".join(pinASections)
        pinsByName[pinB] = "+".join(pinBSections)

    return sucess

oris = ["E", "N", "W", "S"]
#Trying to swap E <-> N, E <-> W, E <-> S, N <-> W, N <-> S, W <->S 
for i in range(len(oris)):
    for j in range(len(oris)):
        if j <= i:
            continue

    commonList1to2 = list(set(pinOriDict[oris[i]]).intersection(padPinDict[oris[j]]))
    commonList2to1 = list(set(padPinDict[oris[i]]).intersection(pinOriDict[oris[j]]))
    
    swapRange = min(len(commonList1to2),len(commonList2to1))
    k = 0
    v = 0
    while k < len(commonList1to2) and v < len(commonList2to1):
        sucess = pinSwap(commonList1to2[k], commonList2to1[v])
        if sucess[0] & sucess[1]:
            dumpArray.append(oris[i])
            dumpArray.append(commonList1to2[k])
            dumpArray.append(oris[j])
            dumpArray.append(commonList2to1[v])
            pinOriDict[oris[i]].remove(commonList1to2[k])
            pinOriDict[oris[j]].remove(commonList2to1[v])
            k+=1
            v+=1
        else:
            if sucess[0] == False:
                k+=1
            if sucess[1] == False:
                v+=1
            

pinsOut = []
for pin in pinsByName.keys():
    pinsOut.append(pinsByName[pin])


pinsOut.insert(0," "+pinsCnt+" ; \n")
pinsOut[len(pinsOut)-1] = pinsOut[len(pinsOut)-1] + " \n END " 
defSections[1] = "- ".join(pinsOut)

outFileOpener = open(out_file_name, "w")
outFileOpener.write("PINS".join(defSections))
outFileOpener.close()


dumpFileOpener = open(dumpFile,"w")
dumpFileOpener.write("\n".join(dumpArray))
dumpFileOpener.close()