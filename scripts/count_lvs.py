#!/usr/bin/python3
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

#
# ---------------------------------------------------------
# LVS failure check
#
# This is a Python script that parses the comp.json
# output from netgen and reports on the number of
# errors in the top-level netlist.
#
# ---------------------------------------------------------
# Written by Tim Edwards
# efabless, inc.
# Pulled from qflow GUI as standalone script Aug 20, 2018
# ---------------------------------------------------------

import re
import json
import argparse


def count_LVS_failures(filename):
    with open(filename, "r") as cfile:
        lvsdata = json.load(cfile)

    # Count errors in the JSON file
    failures = 0
    devfail = 0
    netfail = 0
    pinfail = 0
    propfail = 0
    netdiff = 0
    devdiff = 0
    ncells = len(lvsdata)
    for c in range(0, ncells):
        cellrec = lvsdata[c]

        if c == ncells - 1:
            topcell = True
        else:
            topcell = False

        # Most errors must only be counted for the top cell, because individual
        # failing cells are flattened and the matching attempted again on the
        # flattened netlist.

        if topcell:
            if "devices" in cellrec:
                devices = cellrec["devices"]
                devlist = [val for pair in zip(devices[0], devices[1]) for val in pair]
                devpair = list(devlist[p : p + 2] for p in range(0, len(devlist), 2))
                for dev in devpair:
                    c1dev = dev[0]
                    c2dev = dev[1]
                    diffdevs = abs(c1dev[1] - c2dev[1])
                    failures += diffdevs
                    devdiff += diffdevs

            if "nets" in cellrec:
                nets = cellrec["nets"]
                diffnets = abs(nets[0] - nets[1])
                failures += diffnets
                netdiff += diffnets

            if "badnets" in cellrec:
                badnets = cellrec["badnets"]
                failures += len(badnets)
                netfail += len(badnets)

            if "badelements" in cellrec:
                badelements = cellrec["badelements"]
                failures += len(badelements)
                devfail += len(badelements)

            if "pins" in cellrec:
                pins = cellrec["pins"]
                pinlist = [val for pair in zip(pins[0], pins[1]) for val in pair]
                pinpair = list(pinlist[p : p + 2] for p in range(0, len(pinlist), 2))
                for pin in pinpair:
                    # Avoid flagging global vs. local names, e.g., "gnd" vs. "gnd!,"
                    # and ignore case when comparing pins.
                    pin0 = re.sub("!$", "", pin[0].lower())
                    pin1 = re.sub("!$", "", pin[1].lower())
                    if pin0 != pin1:
                        # The text "(no pin)" indicates a missing pin that can be
                        # ignored because the pin in the other netlist is a no-connect
                        if pin0 != "(no pin)" and pin1 != "(no pin)":
                            failures += 1
                            pinfail += 1

        # Property errors must be counted for every cell
        if "properties" in cellrec:
            properties = cellrec["properties"]
            failures += len(properties)
            propfail += len(properties)

    return [failures, netfail, devfail, pinfail, propfail, netdiff, devdiff]


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Parses netgen lvs")
    parser.add_argument("--file", "-f", required=True)
    args = parser.parse_args()
    failures = count_LVS_failures(args.file)
    total = failures[0]
    if total > 0:
        failed = True
        print("LVS reports:")
        print("    net count difference = " + str(failures[5]))
        print("    device count difference = " + str(failures[6]))
        print("    unmatched nets = " + str(failures[1]))
        print("    unmatched devices = " + str(failures[2]))
        print("    unmatched pins = " + str(failures[3]))
        print("    property failures = " + str(failures[4]))
    else:
        print("LVS reports no net, device, pin, or property mismatches.")

    print("")
    print("Total errors = " + str(total))
