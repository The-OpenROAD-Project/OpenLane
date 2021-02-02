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
    description='extracts the list of routing metal layers from a technology LEF file')

parser.add_argument('--techlef', '-t',required=True,
                    help='technology LEF file')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
techlef_name = args.techlef
out_file_name = args.output

pattern = re.compile(r'\s*LAYER\s*([\S+]+)\s*')

metal_list=[]
current_layer_name = ''
printed = False

with open(techlef_name, "r") as f:
    for line in f:
        m = pattern.match(line)
        if m:
            current_layer_name = m.group(1)
            print(current_layer_name)
            printed = False

        if 'ROUTING' in line and not printed:
            metal_list.append(current_layer_name + ' ')
            printed = True
print(metal_list)
print(len(metal_list))
outFileOpener = open(out_file_name, "w")
outFileOpener.write(" ".join(metal_list).strip())
outFileOpener.close()
