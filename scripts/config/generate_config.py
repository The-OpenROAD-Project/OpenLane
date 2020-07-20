import sys
import os
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

#for i in range(len(sys.argv)):

outputPrefix = sys.argv[1]
baseConfigFile = sys.argv[2]
regressionFile = sys.argv[3]

idx = [0]

valuesList = []
keysList = []

extra =[]

debugFileOpener = open("Debug_Generate_config.txt", "w+")



def readContent(regressionFile):
    try:
        tmpFile = open(regressionFile,"r")
        if tmpFile.mode == 'r':
            regressionFileContent = tmpFile.read().split("\n")
            for i in range(len(regressionFileContent)):
                line = regressionFileContent[i]
                if line == "":
                    continue
                elif line[0:5] == "extra":
                    while regressionFileContent[i][0] != "\"":
                        i+=1
                        if (regressionFileContent[i] != "\"") & (regressionFileContent[i] != ""):
                            extra.append(regressionFileContent[i])
                    break
                else:
                    keysList.append(line.split("=")[0])
                    vals = line.split("=")[1]
                    vals = vals[1:-1]
                    valuesList.append(vals.split(" "))
                    debugFileOpener.write(line.split("=")[0])
                    debugFileOpener.write("\n")
                    debugFileOpener.write(vals)
                    debugFileOpener.write("\n")
                    
                    debugFileOpener.write("\n")
                    debugFileOpener.write(valuesList[-1][0])
                    debugFileOpener.write("\n")
                    debugFileOpener.write("\n")
    except  OSError:
        print ("Could not open/read file:", regressionFile)
        sys.exit()


def resolveExpression(valExpression,expressionKeeper):
    debugFileOpener.write(valExpression)
    debugFileOpener.write("\n")
    for i in expressionKeeper.keys():
        debugFileOpener.write(i)
        debugFileOpener.write("\n")
        valExpression= valExpression.replace(i,expressionKeeper[i])
    return eval(valExpression)

def Generator(i,j, regression_config, expressionKeeper):
    if (i+1 == len(keysList)):
        outFileName = outputPrefix+str(idx[0])+".tcl"
        outFile = open(outFileName, "w")
        outFile.write("\n# Design\n")
        baseConfigFileRead = open(baseConfigFile,"r")
        outFile.write(baseConfigFileRead.read())
        #os.system("$(cat "+baseConfigFile+">>"+outFileName+")")
        outFile.write("\n# Regression\n")
        outFile.write(regression_config+"set ::env("+keysList[i]+") "+valuesList[i][j]+"\n")
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
            Generator(i+1,k,regression_config+"set ::env("+keysList[i]+") "+newVal+"\n",expressionKeeper)
            expressionKeeper.pop(keysList[i])



readContent(regressionFile)
expressionKeeper = dict()
for k in range(len(valuesList[0])):
    Generator(0,k,"",expressionKeeper)

print (idx[0])
