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
import re
parser = argparse.ArgumentParser(
    description='Converts a magic.drc file to a TritonRoute DRC format file.')

parser.add_argument('--input_file', '-i', required=True,
                    help='input magic.drc')

parser.add_argument('--output_file', '-o', required=True,
                    help='output magic.tr.drc')

args = parser.parse_args()
input_file = args.input_file
output_file = args.output_file


def cleanup(vio_type):
    return str(vio_type).replace(" ","_").replace(">","gt").replace("<","lt").replace("=","eq").replace("!","not").replace("^","pow").replace(".","dot").replace("-","_").replace("+","plus").replace("(","").replace(")","")

printArr = []

splitLine = '----------------------------------------'

# Converting Magic DRC
if os.path.exists(input_file):
    drcFileOpener = open(input_file)
    if drcFileOpener.mode == 'r':
        drcContent = drcFileOpener.read()
    drcFileOpener.close()

    # design name
    # violation message
    # list of violations
    # Total Count:
    pattern = re.compile(r'.*\s*\((\S+)\.?\s*[^\(\)]+\)')
    if drcContent is not None:
        drcSections = drcContent.split(splitLine)
        if (len(drcSections) > 2):
            for i in range(1, len(drcSections) - 1, 2):
                vio_name = drcSections[i].strip()
                m = pattern.match(vio_name)
                if m:
                    layer = m.group(1).split(".")[0]
                message_prefix= "  violation type: "+cleanup(vio_name)+"\n    srcs: N/A N/A\n"
                for vio in drcSections[i + 1].split("\n"):
                    vio_cor = vio.strip().replace("um","").split()
                    if len(vio_cor)>3:
                        vio_line=message_prefix+"    bbox = ( "+vio_cor[0]+", "+vio_cor[1]+" ) - ( "+vio_cor[2]+", "+vio_cor[3]+" ) on Layer "+layer
                        printArr.append(vio_line)
else:
    printArr.append("Source not found.")

# write into file
outputFileOpener = open(output_file,"w")
outputFileOpener.write("\n".join(printArr))
outputFileOpener.close()
