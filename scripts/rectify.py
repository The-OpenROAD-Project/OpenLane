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
takes a lef file and a rectangle => trims all RECT statements within the area
"""
import re
import sys

ARGV = sys.argv
if len(ARGV) < 5:
    print("Usage " + ARGV[0] + " llx lly urx ury")
    sys.exit(-1)
LLX = float(ARGV[1])
LLY = float(ARGV[2])
URX = float(ARGV[3])
URY = float(ARGV[4])
LAYERS = ["li1", "met1", "met2", "met3", "met4", "met5"]
RECT_REGEX = (
    r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"
)
# SIZE_REGEX = r"^\s*SIZE\s+(-?\d+\.?\d*)\s+BY\s+\s+(-?\d+\.?\d*);$"


def get_cut_rect_x(rect, axis):
    """
    cuts one rect about an x axis
    """
    rects = [rect]
    llx, lly, urx, ury = rect
    if llx < axis and urx > axis:
        rects = [(llx, lly, axis, ury), (axis, lly, urx, ury)]
    return rects


def get_cut_rect_y(rect, axis):
    """
    cuts one rect about an y axis
    """
    rects = [rect]
    llx, lly, urx, ury = rect
    if lly < axis and ury > axis:
        rects = [(llx, lly, urx, axis), (llx, axis, urx, ury)]
    return rects


def rects2cutrects(rects, axis, direction):
    """
    cut a list of rects (4-tuple) and returns another list of of rects (4-tuple)
    cut by an x or y axis

    axix is a position

    direction is either 'x' or 'y'
    """
    rects_cut = []
    if direction == "x":
        for rect in rects:
            rects_cut += get_cut_rect_x(rect, axis)
    else:
        for rect in rects:
            rects_cut += get_cut_rect_y(rect, axis)
    return rects_cut


def get_all_cut_rects(rect):
    """
    cut a rect about the 4 axis LLX, LLY, URX, URY
    """
    rects = [rect]
    rects = rects2cutrects(rects, LLX, "x")
    rects = rects2cutrects(rects, URX, "x")
    rects = rects2cutrects(rects, LLY, "y")
    rects = rects2cutrects(rects, URY, "y")
    return rects


def rectify(rects):
    """
    gets a list of already cut rects (4-tuple) and returns another list of of
    rects (4-tuple) that are not within LLX, LLY, URX, URY
    """
    rect_outside = []
    for rect in rects:
        llx, lly, urx, ury = rect
        if (
            llx < LLX
            or llx > URX
            or urx > URX
            or urx < LLX
            or lly < LLY
            or lly > URY
            or ury > URY
            or ury < LLY
        ):
            rect_outside += [rect]
    return rect_outside


def print_rects(prefix, rects):
    for rect in rects:
        llx, lly, urx, ury = rect
        print(prefix + "RECT %f %f %f %f ;" % (llx, lly, urx, ury))


layer = ""
for line in sys.stdin:
    if line.isspace():
        continue
    rect_match = re.search(RECT_REGEX, line)
    if rect_match:
        llx, lly, urx, ury = (
            float(rect_match.group(1)),
            float(rect_match.group(2)),
            float(rect_match.group(3)),
            float(rect_match.group(4)),
        )
        if (
            (lly < LLY and ury < LLY)
            or (lly > URY and ury > URY)
            or (llx < LLX and urx < LLX)
            or (llx > URX and urx > URX)
        ):  # outside the whole thing
            rects = [(llx, lly, urx, ury)]
        else:
            rects = rectify(get_all_cut_rects((llx, lly, urx, ury)))
        if len(rects) > 0:
            print(layer)
            if layer != "":  # LAYER printed, clear it
                layer = ""
            print_rects(line[: line.find("R")], rects)
    else:
        if line.find("LAYER") != -1:  # print it only if there're RECTs
            layer = line
        else:
            print(line, end="")
