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