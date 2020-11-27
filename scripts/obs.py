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

# takes a lef file and a y position => obstructs everything above
import re
import os
import sys

ARGV = sys.argv
if len(ARGV) < 5:
    print("Usage " + ARGV[0] + " llx lly urx ury")
    sys.exit(-1)
LLX = float(ARGV[1])
LLY = float(ARGV[2])
URX = float(ARGV[3])
URY = float(ARGV[4])
LAYER_LIST = ["li1", "met1", "met2", "met3", "met4", "met5"]

def print_obs_section():
    for layer in LAYERS:
        print("     LAYER %s ;" %(layer))
        print("       RECT %f %f %s %s ;" % (LLX, LLY, URX, URY))

obs_section = False
macro_name = None
for line in sys.stdin:
    if line.isspace():
        continue

    if line.startswith("MACRO"):
        macro_name = line.split()[1]
        LAYERS = {layer:False for layer in LAYER_LIST}

    if macro_name and line.startswith("END " + macro_name):
        macro_name = None
        if not any(l[1] for l in LAYERS.items()):
            print("   OBS")
            print_obs_section()
            print("   END")

    if line.find("OBS") != -1:
        obs_section = True
    elif obs_section and line.find("END") != -1:
        obs_section = False
        for layer in LAYERS:  # draw remaining obs on layers that didn't appear
            if not LAYERS[layer]:
                LAYERS[layer] = True
                print("     LAYER %s ;" % (layer))
                print("       RECT %.3f %.3f %.3f %.3f ;" %
                      (LLX, LLY, URX, URY))

    print(line, end='')
    if obs_section and line.find("LAYER") != -1:
        line = line.split()
        LAYERS[line[1]] = True
        print("       RECT %.3f %.3f %.3f %.3f ;" %
              (LLX, LLY, URX, URY))
