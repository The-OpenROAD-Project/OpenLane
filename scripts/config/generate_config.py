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

import sys
import os

outputPrefix = sys.argv[1]
baseConfigFile = sys.argv[2]
regressionFile = sys.argv[3]

idx = [0]

valuesList = []
keysList = []

extra =[]

std_cell_library = []


def readContent(regressionFile):
    try:
        tmpFile = open(regressionFile,"r")
        if tmpFile.mode == 'r':
            regressionFileContent = tmpFile.read().split("\n")
            i = 0
            while i < len(regressionFileContent):
                line = regressionFileContent[i]
                if line == "":
                    i+=1
                    continue
                elif line.find("extra") != -1:
                    while regressionFileContent[i][0] != "\"":
                        i+=1
                        if (regressionFileContent[i][0] != "\"") and (regressionFileContent[i] != ""):
                            extra.append(regressionFileContent[i])
                elif line.find("std_cell_library") != -1:
                    while regressionFileContent[i][0] != "\"":
                        i+=1
                        if (regressionFileContent[i][0] != "\"") and (regressionFileContent[i] != ""):
                            std_cell_library.append(regressionFileContent[i])
                else:
                    keysList.append(line.split("=")[0])
                    vals = line.split("=")[1]
                    vals = vals[1:-1]
                    valuesList.append(vals.split(","))
                i+=1
    except  OSError:
        print ("Could not open/read file:", regressionFile)
        sys.exit()


def resolveExpression(valExpression,expressionKeeper):
    for i in expressionKeeper.keys():
        valExpression= valExpression.replace(i,expressionKeeper[i])
    try:
        ret = eval(valExpression)
        return ret
    except Exception:
        return valExpression


def insertSCL(configs):
    if len(std_cell_library):
        lines = configs.split("\n")
        for idx in range(len(lines)):
            if lines[idx].find("$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl") != -1:
                for var in std_cell_library:
                    lines.insert(idx,var)
                    idx+=1
                configs = "\n".join(lines)
                return configs
        for var in std_cell_library:
            lines.insert(0,var)
        configs = "\n".join(lines)
        return configs
    else:
        return configs

def Generator(i,j, regression_config, expressionKeeper):
    if (i == len(keysList)-1):
        outFileName = outputPrefix+str(idx[0])+".tcl"
        outFile = open(outFileName, "w")
        outFile.write("\n# Design\n")
        baseConfigFileRead = open(baseConfigFile,"r")
        outFile.write(insertSCL(baseConfigFileRead.read()))
        outFile.write("\n# Regression\n")
        newVal = valuesList[i][j]
        if newVal.isupper() or newVal.islower():
            newVal = str(resolveExpression(newVal, expressionKeeper))
        outFile.write(regression_config+"set ::env("+keysList[i]+") \""+newVal+"\"\n")
        outFile.write("\n# Extra\n")
        for x in extra:
            outFile.write(x+"\n")
        outFile.close()
        idx[0]+=1
    else:
        for k in range(len(valuesList[i+1])):
            newVal = valuesList[i][j]
            if newVal.isupper() or newVal.islower():
                newVal = str(resolveExpression(newVal, expressionKeeper))

            expressionKeeper[keysList[i]]=newVal
            Generator(i+1,k,regression_config+"set ::env("+keysList[i]+") \""+newVal+"\"\n",expressionKeeper)
            expressionKeeper.pop(keysList[i])



readContent(regressionFile)
expressionKeeper = dict()
for k in range(len(valuesList[0])):
    Generator(0,k,"",expressionKeeper)

print (idx[0])
