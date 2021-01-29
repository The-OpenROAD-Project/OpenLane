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
import os
import argparse


parser = argparse.ArgumentParser(
    description='The script takes a checks output directory from running the fuzzy checks in the Precheck, \
     and lists the number of macros in the ')

parser.add_argument('--lydrc', '-l',required=True,
                    help='lydrc klayout xml database.')

parser.add_argument('--output_script', '-o',required=True,
                help="outputs the script to be used to run klayout drc.")


args = parser.parse_args()
lydrc = args.lydrc
output_script = args.output_script

def cleanup(text):
    return str(text).replace("&gt;",">").replace("&lt;","<").replace("&amp;","&")

def make_verbose(text):
    return str(text).replace("verbose(false)","verbose(true)")

if(os.path.exists(lydrc)):
    lydrcFileOpener = open(lydrc, "r", encoding="utf-8")
    if lydrcFileOpener.mode == 'r':
        lydrcContent = lydrcFileOpener.read()
    lydrcFileOpener.close()
    sections = lydrcContent.split("<text>")
    if len(sections) == 2:
        text = sections[1].split("</text>")[0]
        output_scriptFileOpener = open(output_script,"w", encoding="utf-8")
        output_scriptFileOpener.write(make_verbose(cleanup(text)))
        output_scriptFileOpener.close()
