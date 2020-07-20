
import argparse
import os
from os import path

parser = argparse.ArgumentParser(
        description="update configuration of design(s) per given PDK")

parser.add_argument('--root', '-r', action='store', default='./',
                help="The root directory. assuming root/designs, root/scripts root/logs")

parser.add_argument('--pdkFrom', '-pf', action='store',
                help="The name of the PDK to copy from")

parser.add_argument('--pdkVariantFrom', '-pvf', action='store',
                help="The name of the PDK_VARIANT to copy from")

parser.add_argument('--pdkTo', '-pt', action='store', required=True,
                help="The name of the PDK to copy to")

parser.add_argument('--pdkVariantTo', '-pvt', action='store', required=True,
                help="The name of the PDK_VARIANT to copy to")

parser.add_argument('--designs', '-d', nargs='+', default=[],
                help="designs to update")


args = parser.parse_args()
root = args.root
pdkFrom = args.pdkFrom
pdkVariantFrom = args.pdkVariantFrom
pdkTo = args.pdkTo
pdkVariantTo = args.pdkVariantTo

designs = list(dict.fromkeys(args.designs))

if pdkFrom is None:
    pdkFrom = "ThisFileDoesntExist"

if pdkVariantFrom is None:
    pdkVariantFrom = "ThisFileDoesntExist"


if len(designs) == 0:
    designs= [x  for x in os.listdir(root+'/designs/')]
    for i in designs:
        if os.path.isdir(root+'/designs/'+i) == False:
            designs.remove(i)
print(designs)

for design in designs:
    configFileTo = str(root)+"designs/"+str(design)+"/"+str(pdkTo)+"_"+str(pdkVariantTo)+"_config.tcl"
    configFileFrom = str(root)+"designs/"+str(design)+"/"+str(pdkFrom)+"_"+str(pdkVariantFrom)+"_config.tcl"
    if(path.exists(configFileFrom)):
        configFileFromOpener = open(configFileFrom, 'r')
        configFileFromData = configFileFromOpener.read()
        configFileFromOpener.close()
        
        configFileToOpener = open(configFileTo, 'w+')
        configFileToOpener.write(configFileFromData)
        configFileToOpener.close()
    else:
        configFileToOpener = open(configFileTo, 'w+')
        configFileToOpener.write("#init Configs")
        configFileToOpener.close()