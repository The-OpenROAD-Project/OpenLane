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


parser = argparse.ArgumentParser(
    description='Takes a list of macros and creates a def file containing them at arbitrary locations')

parser.add_argument('--macros', '-m', nargs='+', default=[],
                help="list of macros to add in the def file")

parser.add_argument('--verilog', '-v', nargs='+', default=[],
                help="top level verilog containing those macros")

parser.add_argument('--output', '-o',
                    default='core.def', help='Output DEF')

args = parser.parse_args()
macros = args.macros
verilog_file_name = args.verilog
output_file_name = args.output

defContent="DESIGN CORE ;\nUNITS DISTANCE MICRONS 1000 ;"
for macro in macros:
    
    defContent+="\n"
#write into Def
defFileOpener = open(output_file_name,"w")
defFileOpener.write(defContent)
defFileOpener.close()