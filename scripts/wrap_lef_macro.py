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

"""
Reads a LEF view of a macro and extends a subset of the pins to the nearest border
"""

import os
import re
import argparse
import subprocess

OPENLANE_ROOT = os.environ["OPENLANE_ROOT"]
assert OPENLANE_ROOT, "You need to set OPENLANE_ROOT"
print("OPENLANE_ROOT:", OPENLANE_ROOT)
SCRIPTS_DIR = OPENLANE_ROOT + "/scripts"

MIN_SIZE = 0.8
MAX_SIZE = 52
MARGIN = 100  # 100 um
SPACING = -0.6  # in um
ORIG_SIZE_X = 0
ORIG_SIZE_Y = 0
SIZE_X = 0
SIZE_Y = 0
VERTICAL_PAD = 0
HORIZONTAL_PAD = 0
PIN_REGEX = r"^\s*PIN\s+(\S+)$"
SIZE_REGEX = r"^\s*SIZE\s+(-?\d+\.?\d*)\s+BY\s+(-?\d+\.?\d*)\s+;$"
ORIGIN_REGEX = r"^\s*ORIGIN\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"
RECT_REGEX = r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"

def is_good_size(llx, lly, urx, ury):
    MAX_SIZE = 99999999  # ignore for now
    size_x = urx-llx
    size_y = ury-lly
    if MIN_SIZE <= size_x <= MAX_SIZE\
            or MIN_SIZE <= size_y <= MAX_SIZE:
        return True
    else:
        return False

def is_near_boundary(llx, lly, urx, ury, percentage=0.5):
    percentage /= 100
    if llx <= (0+MARGIN)+percentage*ORIG_SIZE_X\
            or urx >= (0+SIZE_X-MARGIN)-percentage*ORIG_SIZE_X\
            or lly <= (0+MARGIN)+percentage*ORIG_SIZE_Y\
            or ury >= (0+SIZE_Y-MARGIN)-percentage*ORIG_SIZE_Y:
        return True
    else:
        return False

def right_extension(llx, urx):
    llx = urx
    urx = SIZE_X-HORIZONTAL_PAD
    return llx, urx

def left_extension(llx, urx):
    urx = llx
    llx = 0+HORIZONTAL_PAD
    return llx, urx

def top_extension(lly, ury):
    lly = ury
    ury = SIZE_Y-VERTICAL_PAD
    return lly, ury

def bottom_extension(lly, ury):
    ury = lly
    lly = 0+VERTICAL_PAD
    return lly, ury


def extension_to_boundary(llx, lly, urx, ury):
    """
    returns an extension that needs to be added to a rectangle to the boundary
    specified by SIZE_X, SIZE_Y assumes a zero origin
    """
    # determine "orientation"
    width = urx-llx
    height = ury-lly
    left_distance = llx - (0 + HORIZONTAL_PAD)
    right_distance = (SIZE_X - HORIZONTAL_PAD) - urx
    bottom_distance = lly - (0 + VERTICAL_PAD)
    top_distance = (SIZE_Y - VERTICAL_PAD) - ury
    orientation = -1
    if width > height:
        orientation = 0 # HORIZONTAL
    elif width < height:
        orientation = 1  # VERTICAL

    if orientation == 0:
        if right_distance < left_distance:
            llx, urx = right_extension(llx, urx-width)
        else:
            llx, urx = left_extension(llx+width, urx)
    elif orientation == 1:
        if top_distance < bottom_distance:
            lly, ury = top_extension(lly, ury-height)
        else:
            lly, ury = bottom_extension(lly+height, ury)
    else: # square
        min_dist = min(right_distance, left_distance, bottom_distance, top_distance)
        # prefer right and left
        if right_distance == min_dist:
            llx, urx = right_extension(llx, urx-width)
        elif left_distance == min_dist:
            llx, urx = left_extension(llx+width, urx)
        elif top_distance == min_dist:
            lly, ury = top_extension(lly, ury-height)
        else:
            lly, ury = bottom_extension(lly+height, ury)

    return llx, lly, urx, ury

parser = argparse.ArgumentParser(
    description='Reads a LEF view of a macro and extends a subset of the pins to the nearest border')

parser.add_argument('input',
                    help='Input LEF')

parser.add_argument('--output', '-o',
                    default='output.lef', help='Output LEF')

parser.add_argument('--exclude', '-e', required=False, nargs='+',
                    default='', help='Pins NOT to extend')

parser.add_argument('--margin', '-m', required=False, type=float,
                    default=MARGIN, help='Margin around the macro in um')

parser.add_argument('--only-enlarge', required=False, default=False,
                    action='store_true',
                    help='Only enlarge the macro')

parser.add_argument('--only-obs', required=False, default=False,
                    action='store_true',
                    help='Only hide the internals within margin')

parser.add_argument('--only-mask', required=False, default=False,
                    action='store_true',
                    help='Only produce a LEF with the overlay mask that includes the extensions')

parser.add_argument('--no-obs', required=False, default=False,
                    action='store_true',
                    help='Don\'t put obstructions')

parser.add_argument('--no-erase', required=False, default=False,
                    action='store_true',
                    help='Don\'t erase the internals')

parser.add_argument('--horizontal-pad', required=False,  type=float,
                    default=HORIZONTAL_PAD,
                    help='horizontal padding in microns')

parser.add_argument('--vertical-pad', required=False, type=float,
                    default=VERTICAL_PAD,
                    help='horizontal padding in microns')

args = parser.parse_args()

allowed_layers = ["met3", "met4"]
input_file_name = args.input
output_file_name = args.output
output_tmp_file_name = args.output+".tmp"
excludes = args.exclude
only_enlarge = args.only_enlarge
only_obs = args.only_obs
only_mask = args.only_mask
no_obs = args.no_obs
no_erase = args.no_erase
HORIZONTAL_PAD = args.horizontal_pad
VERTICAL_PAD = args.vertical_pad

MARGIN = float(args.margin)

if only_mask:
    no_obs = True

if only_obs:
    SPACING = 0

print("Excluding ", excludes)

with open(input_file_name, 'r') as input_lef_file, \
        open(output_tmp_file_name, 'w') as output_tmp_lef_file:
    lef = input_lef_file.readlines()
    l = 0
    # ORIGIN and SIZE
    for l in range(0, len(lef)):
        line = lef[l]
        size_match = re.search(SIZE_REGEX, line)
        # origin_match = re.search(ORIGIN_REGEX, line)
        # if origin_match is not None:
        #     ORIGIN_X = float(origin_match.group(1))+MARGIN
        #     ORIGIN_Y = float(origin_match.group(2))+MARGIN
        #     output_tmp_lef_file.write("  ORIGIN {ORIGIN_X} BY {ORIGIN_Y} ;\n".format(
        #         ORIGIN_X=ORIGIN_X, ORIGIN_Y=ORIGIN_Y))
        if size_match is not None:
            ORIG_SIZE_X = SIZE_X = float(size_match.group(1))
            ORIG_SIZE_Y = SIZE_Y = float(size_match.group(2))
            if not only_obs:
                SIZE_X += 2*MARGIN
                SIZE_Y += 2*MARGIN
            SIZE_X = round(SIZE_X, 3)
            SIZE_Y = round(SIZE_Y, 3)
            output_tmp_lef_file.write("  SIZE %.3f BY %.3f ;\n" % (SIZE_X, SIZE_Y))
            break
        output_tmp_lef_file.write(line)

    # PIN
    pin_to_extend = None
    last_layer = ""
    for l in range(l+1, len(lef)):
        line = lef[l]

        if line.find("POLYGON") != -1:
            continue

        if line.find("LAYER") != -1:
            last_layer = line.split()[1]

        pin_match = re.search(PIN_REGEX, line)
        if pin_match is not None:
            if pin_match.group(1) not in excludes:
                pin_to_extend = pin_match.group(1)
            else:
                pin_to_extend = None
        if re.search(r"END\s+"+re.escape(str(pin_to_extend)), line) is not None:
            pin_to_extend = None

        rect_match = re.search(RECT_REGEX, line)
        if rect_match is not None:
            llx = float(rect_match.group(1))
            lly = float(rect_match.group(2))
            urx = float(rect_match.group(3))
            ury = float(rect_match.group(4))
            if not only_obs:
                llx += MARGIN
                lly += MARGIN
                urx += MARGIN
                ury += MARGIN
            if not only_mask:
                output_tmp_lef_file.write("        " +
                                          "RECT %.3f %.3f %.3f %.3f ;\n" % (llx,
                                                                            lly,
                                                                            urx,
                                                                            ury))
            if pin_to_extend is not None\
                    and not only_enlarge and\
                    not only_obs\
                    and last_layer in allowed_layers\
                    and is_near_boundary(llx, lly, urx, ury)\
                    and is_good_size(llx, lly, urx, ury):
                print("Extending", pin_to_extend)
                llx, lly, urx, ury = extension_to_boundary(llx, lly, urx, ury)
                output_tmp_lef_file.write("        " +
                                          "RECT %.3f %.3f %.3f %.3f ;\n" % (llx,
                                                                            lly,
                                                                            urx,
                                                                            ury))
            continue
        output_tmp_lef_file.write(line)

if only_enlarge:
    os.rename(output_tmp_file_name, output_file_name)
else:
    # delete everything inside the original macro
    with open(output_file_name, 'w') as output_lef_file, \
            open(output_tmp_file_name, 'r') as output_tmp_lef_file:

        # os.rename(output_tmp_file_name, output_file_name)
        # exit()
        rectify_process = subprocess.Popen(["python", SCRIPTS_DIR + "/rectify.py",
                                            str(MARGIN-SPACING), str(MARGIN-SPACING),
                                            str(0+SIZE_X-MARGIN+SPACING), str(0+SIZE_Y-MARGIN+SPACING)],
                                           stdin=output_tmp_lef_file, stdout=subprocess.PIPE)

        if not no_obs:
            obs_process = subprocess.Popen(["python", SCRIPTS_DIR + "/obs.py",
                                            str(MARGIN), str(MARGIN),
                                            str(0+SIZE_X-MARGIN), str(0+SIZE_Y-MARGIN)],
                                           stdin=rectify_process.stdout, stdout=subprocess.PIPE)
        else:
            obs_process = rectify_process

        port_clean_process = subprocess.Popen(["python", SCRIPTS_DIR + "/remove_empty_ports.py"],
                                                 stdin=obs_process.stdout, stdout=subprocess.PIPE)


        pin_clean_process = subprocess.Popen(["python", SCRIPTS_DIR + "/remove_empty_pins.py"],
                                             stdin=port_clean_process.stdout, stdout=output_lef_file)

    os.remove(output_tmp_file_name)

assert os.path.exists(output_file_name), "Failed to write %s" % (output_file_name)
print("Done", output_file_name)
