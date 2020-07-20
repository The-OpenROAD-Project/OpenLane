import argparse
import subprocess

parser = argparse.ArgumentParser(
        description="update configuration of design(s) per given PDK")

parser.add_argument('--root', '-r', action='store', default='./',
                help="The root directory. assuming root/designs, root/scripts root/logs")

parser.add_argument('--pdk', '-p', action='store', required=True,
                help="The name of the PDK")

parser.add_argument('--pdkVariant', '-pv', action='store', required=True,
                help="The name of the PDK_VARIANT")


parser.add_argument('--designs', '-d', nargs='+', default=[],
                help="designs to update ")

parser.add_argument('--log', '-l', action='store', required=True,
                help="name of the log file from which to extract the name of the best configs")

parser.add_argument('--clean', '-cl', action='store_true', default=False,
                help="deletes the config file that the data was extracted from")


args = parser.parse_args()
root = args.root
pdk = args.pdk
pdkVariant = args.pdkVariant
designs = list(dict.fromkeys(args.designs))
log = args.log
clean = args.clean

logFileOpener = open(root+"/logs/"+log, 'r')
logFileData = logFileOpener.read().split("\n")
logFileOpener.close()


headerInfo = logFileData[0].split(",")
configIdx = 0
designIdx = 0
for i in range(len(headerInfo)):
    if headerInfo[i] == "config":
        configIdx = i
        continue
    if headerInfo[i] == "design":
        designIdx = i

designConfigDict = dict()

logFileData = logFileData[1:]
print(logFileData)
for line in logFileData:
    if line != "":
        splitLine = line.split(",")
        designConfigDict[str(splitLine[designIdx])] = str(splitLine[configIdx])

if len(designs) == 0:
    designs = [key for key in designConfigDict]

for design in designs:
    configFileToUpdate = str(root)+"designs/"+str(design)+"/"+str(pdk)+"_"+str(pdkVariant)+"_config.tcl"
    configFileBest = str(root)+"designs/"+str(design)+"/"+str(designConfigDict[design])+".tcl"
    
    configFileBestOpener = open(configFileBest, 'r')
    configFileBestData = configFileBestOpener.read().split("\n")
    configFileBestOpener.close()
    
    newData = ""
    copyFrom = False
    for line in configFileBestData:
        if line == "# Regression":
            copyFrom = True

        if copyFrom == True:
            newData+=line+"\n"
    
    configFileToUpdateOpener = open(configFileToUpdate, 'a+')
    configFileToUpdateOpener.write(newData)
    configFileToUpdateOpener.close()
    
    if clean == True:
        clean_cmd = "rm -f {configFileBest}".format(
                    configFileBest=configFileBest,
        )
        subprocess.check_output(clean_cmd.split())
        #clean config file