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
import re

parser = argparse.ArgumentParser(
    description='Fixes macros in positions specified by a config file')

parser.add_argument('--input', '-i', required=True,
                    help='Input DEF')

parser.add_argument('--output', '-o',
                    default='output.def', help='Output DEF')

parser.add_argument('--config', '-c', required=True,
                    help='Configuration file')

args = parser.parse_args()
input_file_name = args.input
output_file_name = args.output
config_file_name = args.config

pads = []
with open(config_file_name, 'r') as config_file:
    for line in config_file:
        line = line.split(' ')
        if line[0] == "PAD" or line[0] == "CORNER":
            pads.append(line[1])

in_components = False
with open(output_file_name, 'w') as output_def_file, \
        open(input_file_name, 'r') as input_def_file:
    for line in input_def_file:
        if in_components == False:
            if line.find("COMPONENTS") != -1: # COMPONENTS # ;
                in_components = True
        elif in_components:
      
            if line.find("END COMPONENTS") != -1: # END COMPONENTS
                in_components = False
            rem = None
            for pad in pads:
                if line.find(pad) != -1:
                    line = line.replace(pad,"padframe."+pad)
                    rem = pad
            if rem is not None:
                pads.remove(rem)
        output_def_file.write(line)