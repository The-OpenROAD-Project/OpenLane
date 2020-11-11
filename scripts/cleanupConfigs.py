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
import subprocess
import utils.utils as utils
import os

parser = argparse.ArgumentParser(
        description="cleanup (remove comments and redundancies) configuration of design(s) per given PDK")

parser.add_argument('--designs_dir', '-r', action='store', default='./designs',
                help="The root directory for the designs.")

parser.add_argument('--pdk', '-p', action='store', required=True,
                help="The name of the PDK")

parser.add_argument('--std-cell-library', '-scl', action='store', required=True,
                help="The name of the standard cell library")


parser.add_argument('--designs', '-d', nargs='+', default=[],
                help="designs to update ")

args = parser.parse_args()
root = args.designs_dir
pdk = args.pdk
std_cell_library = args.std_cell_library
designs = list(dict.fromkeys(args.designs))

if len(designs) == 0:
    designs= [x  for x in os.listdir(str(root)+'/')]
    for i in designs:
        if os.path.isdir(str(root)+'/'+i) == False:
            designs.remove(i)


for design in designs:
    print("Updating "+ design + " config...")
    try:
        base_path = utils.get_design_path(design=design)
        configFileToUpdate = str(base_path)+"/"+str(pdk)+"_"+str(std_cell_library)+"_config.tcl"
        configFileToUpdateOpener = open(configFileToUpdate, 'r')
        configsContent = configFileToUpdateOpener.read().split("\n")
        configFileToUpdateOpener.close()
        configsMap = dict()
        for line in configsContent:
            if line.strip().startswith("set"):
                config = ' '.join(line.split()).split()
                if len(config) > 2:
                    configsMap[config[1]] = ' '.join(config[2:])
        newData= "# SCL Configs\n"
        for key in configsMap:
            newData+= "set "+key+" "+configsMap[key]+"\n"
        configFileToUpdateOpener = open(configFileToUpdate, 'w')
        configFileToUpdateOpener.write(newData)
        configFileToUpdateOpener.close()
    except OSError as e:
        print("No config found for "+ design)

