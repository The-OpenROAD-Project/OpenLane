#!/usr/bin/env python3
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
import re

parser = argparse.ArgumentParser(
    description='Applies a template DEF to a user DEF.')

parser.add_argument('--templateDEF', '-t',required=True,
                    help='Template DEF')

parser.add_argument('--userDEF', '-u',required=True,
                   help='User DEF')

parser.add_argument('--scriptsDir', '-s',required=True,
                   help='scripts Directory')

args = parser.parse_args()
templateDEF = args.templateDEF
userDEF = args.userDEF
scriptsDir = args.scriptsDir


def remove_power_pins(DEF):
    templateDEFOpener = open(DEF,"r")
    if templateDEFOpener.mode == 'r':
        templateDEFSections =templateDEFOpener.read().split("PINS")
    templateDEFOpener.close()
    PINS = templateDEFSections[1].split("- ")
    OUT_PINS=[" ;"]
    cnt = 0
    for pin in PINS[1:]:
        if pin.find("USE GROUND") + pin.find("USE POWER") == -2:
            cnt+=1 
            OUT_PINS.append(pin)
    OUT_PINS[0] = " "+str(cnt) + OUT_PINS[0] + PINS[0].split(";")[1]
    OUT_PINS[-1] = OUT_PINS[-1].replace("END ", "")
    OUT_PINS[-1] = OUT_PINS[-1] + "END "
    templateDEFSections[1] = "- ".join(OUT_PINS)
    templateDEFOpener = open(DEF,"w")
    templateDEFOpener.write("PINS".join(templateDEFSections))
    templateDEFOpener.close()
    

command = 'cp {templateDEF} {newtemplateDEF}'.format(templateDEF=templateDEF, newtemplateDEF=userDEF+".template.tmp")
subprocess.check_output(command.split(), stderr=subprocess.PIPE) 

templateDEF = userDEF+".template.tmp"
remove_power_pins(templateDEF)


command = 'sh {scriptsDir}/mv_pins.sh {templateDEF} {userDEF}'.format(scriptsDir=scriptsDir,templateDEF=templateDEF, userDEF=userDEF)
subprocess.check_output(command.split(), stderr=subprocess.PIPE)   

#read template Def
templateDEFOpener = open(templateDEF,"r")
if templateDEFOpener.mode == 'r':
    templateDEFContent =templateDEFOpener.read()
templateDEFOpener.close()


#read user Def
userDEFOpener = open(userDEF,"r")
if userDEFOpener.mode == 'r':
    userDEFContent =userDEFOpener.read()
userDEFOpener.close()


def copyStringWithWord(word, f_rom, t_o):
    pattern = re.compile(r'\b%s\b\s*\([^)]*\)\s*\([^)]*\)' % word)
    instances = re.findall(pattern, f_rom)
    if len(instances) == 1:
        str_from = instances[0]
        tmp = re.sub(pattern, str_from, t_o)
        return tmp
    return None



# Copy DIEAREA
word='DIEAREA'
userDEFContent = copyStringWithWord(word, templateDEFContent, userDEFContent)


if userDEFContent is not None:
    userDEFOpener = open(userDEF,"w")
    userDEFOpener.write(userDEFContent)
    userDEFOpener.close()
else:
    raise Exception("DIEAREA not found in DEF")
