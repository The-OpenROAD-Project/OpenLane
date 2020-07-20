import argparse

parser = argparse.ArgumentParser(
    description='sets the tracks on a layer to specific value')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--layer', '-l',required=True,
                   help='layer to change')

parser.add_argument('--valuesFile', '-v',required=True,
                   help='tmp file to read the new value from')

parser.add_argument('--originalFile', '-o', required=True,
                    help='tmp file to store the original value')



args = parser.parse_args()
def_file_name = args.defFile
layer = args.layer
input_file_name = args.valuesFile
output_file_name = args.originalFile

defFileOpener = open(def_file_name,"r")
if defFileOpener.mode == 'r':
    defContent =defFileOpener.read().split("\n")
defFileOpener.close()


inputFileOpener = open(input_file_name,"r")
if inputFileOpener.mode == 'r':
    inputXY =inputFileOpener.read().split()
inputFileOpener.close()

printedXY = ["0", "0"]

outOrder = 0
for i in range(len(defContent)):
    if outOrder == 2:
        break    
    if defContent[i].find(layer) != -1:
        tmpLine = defContent[i].split(" ")
        if tmpLine [0] != "TRACKS":
            continue
        if tmpLine[1] == "X":
            printedXY[0] = tmpLine[4]
            tmpLine[4] = inputXY[0]    
        else:
            printedXY[1] = tmpLine[4]
            tmpLine[4] = inputXY[1]    
        defContent[i] = " ".join(tmpLine)
        outOrder+=1
        continue


defFileOpener = open(def_file_name,"w")
defFileOpener.write("\n".join(defContent))
defFileOpener.close()

outputFileOpener = open(output_file_name,"w")
outputFileOpener.write("\n".join(printedXY))
outputFileOpener.close()