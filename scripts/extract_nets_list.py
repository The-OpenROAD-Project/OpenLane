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
    description='extracts the list of nets from a def file')

parser.add_argument('--defFile', '-d',required=True,
                    help='Input DEF')

parser.add_argument('--output', '-o', required=True,
                    help='output file to store results')

args = parser.parse_args()
def_file_name = args.defFile
out_file_name = args.output

nets_list=[]

defFileOpener = open(def_file_name, "r")
if defFileOpener.mode == 'r':
    defContent = defFileOpener.read()
defFileOpener.close()

netsLocation = defContent.find("\nNETS ")
processedText=";".join(defContent[netsLocation:].split(";")[1:])
pattern = re.compile(r'\-\s*[\S+]+\s*\(\s*')
print(type(processedText))
nets = re.findall(pattern, processedText)
for net in nets:
    nets_list.append(net.split("-")[1].split(" ( ")[0])
    print(net)     

outFileOpener = open(out_file_name, "w")
outFileOpener.write(" ".join(nets_list))
outFileOpener.close()
