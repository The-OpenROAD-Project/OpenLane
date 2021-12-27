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
import os
from os import path
import utils.utils as utils

parser = argparse.ArgumentParser(
        description="replicate configurations of design(s) from a given (PDK, STD_CELL_LIB) to another, or generates an empty config file for a given (PDK, STD_CELL_LIB)")


parser.add_argument('--from-pdk', '-fp', action='store',
                help="The name of the PDK to copy from")

parser.add_argument('--from-std-cell-library', '-fscl', action='store',
                help="The name of the STD_CELL_LIBRARY to copy from")

parser.add_argument('--to-pdk', '-tp', action='store', required=True,
                help="The name of the PDK to copy to")

parser.add_argument('--to-std-cell-library', '-tscl', action='store', required=True,
                help="The name of the STD_CELL_LIBRARY to copy to")

parser.add_argument('--designs', '-d', nargs='+', default=[],
                help="designs to update. Same as -d in run desings. If none provided, then all designs under ./designs will be replicated")


args = parser.parse_args()
pdkFrom = args.from_pdk
from_std_cell_library = args.from_std_cell_library
pdkTo = args.to_pdk
to_std_cell_library = args.to_std_cell_library

designs = list(dict.fromkeys(args.designs))

if pdkFrom is None:
    pdkFrom = "ThisFileDoesntExist"

if from_std_cell_library is None:
    from_std_cell_library = "ThisFileDoesntExist"


if len(designs) == 0:
    designs= [x  for x in os.listdir('./designs/')]
    for i in designs:
        if os.path.isdir('./designs/'+i) == False:
            designs.remove(i)

for design in designs:
    print("Replicating "+ design + " config...")
    base_path = utils.get_design_path(design=design)
    configFileTo = str(base_path)+"/"+str(pdkTo)+"_"+str(to_std_cell_library)+"_config.tcl"
    configFileFrom = str(base_path)+"/"+str(pdkFrom)+"_"+str(from_std_cell_library)+"_config.tcl"
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
