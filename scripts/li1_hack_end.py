import argparse

parser = argparse.ArgumentParser(
    description='Fixes macros in positions specified by a config file')

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