# Copyright 2020-2022 Efabless Corporation
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
import odb

import os
import re
import sys
import math
import click
import random

from reader import click_odb


def grid_to_tracks(origin, count, step):
    tracks = []
    pos = origin
    for _ in range(count):
        tracks.append(pos)
        pos += step
    assert len(tracks) > 0
    tracks.sort()

    return tracks


def equally_spaced_sequence(side, side_pin_placement, possible_locations):
    virtual_pin_count = 0
    actual_pin_count = len(side_pin_placement)
    total_pin_count = actual_pin_count + virtual_pin_count
    for i in range(len(side_pin_placement)):
        if isinstance(
            side_pin_placement[i], int
        ):  # This is an int value indicating virtual pins
            virtual_pin_count = virtual_pin_count + side_pin_placement[i]
            actual_pin_count = (
                actual_pin_count - 1
            )  # Decrement actual pin count, this value was only there to indicate virtual pin count
            total_pin_count = actual_pin_count + virtual_pin_count
    result = []
    tracks = len(possible_locations)

    if total_pin_count > tracks:
        print(
            f"There are more pins/virtual_pins: {total_pin_count}, than places to put them: {tracks} in the {side} side. Try making your floorplan area larger."
        )
        sys.exit(1)
    elif total_pin_count == tracks:
        return possible_locations, side_pin_placement  # All positions.
    elif total_pin_count == 0:
        return result, side_pin_placement

    # From this point, pin_count always < tracks.
    tracks_per_pin = math.floor(tracks / total_pin_count)  # >=1
    # O| | | O| | | O| | |
    # tracks_per_pin = 3
    # notice the last two tracks are unused
    # thus:
    used_tracks = tracks_per_pin * (total_pin_count - 1) + 1
    unused_tracks = tracks - used_tracks

    # Place the pins at those tracks...
    current_track = unused_tracks // 2  # So that the tracks used are centered
    starting_track_index = current_track
    if virtual_pin_count == 0:  # No virtual pins
        for _ in range(0, total_pin_count):
            result.append(possible_locations[current_track])
            current_track += tracks_per_pin
    else:  # There are virtual pins
        for i in range(len(side_pin_placement)):
            if not isinstance(side_pin_placement[i], int):  # We have an actual pin
                result.append(possible_locations[current_track])
                current_track += tracks_per_pin
            else:  # Virtual Pins, so just leave their needed spaces
                current_track += tracks_per_pin * side_pin_placement[i]
        side_pin_placement = [
            pin for pin in side_pin_placement if not isinstance(pin, int)
        ]  # Remove the virtual pins from the side_pin_placement list

    print(f"Placement details for the {side} side")
    print("Virtual pin count: ", virtual_pin_count)
    print("Actual pin count: ", actual_pin_count)
    print("Total pin count: ", total_pin_count)
    print("Tracks count: ", len(possible_locations))
    print("Tracks per pin: ", tracks_per_pin)
    print("Used tracks count: ", used_tracks)
    print("Unused track count: ", unused_tracks)
    print("Starting track index: ", starting_track_index)

    VISUALIZE_PLACEMENT = True
    if VISUALIZE_PLACEMENT:
        print("Placement Map:")
        print("[", end="")
        used_track_indices = []
        for i, location in enumerate(possible_locations):
            if location in result:
                print(f"\033[91m{location}\033[0m, ", end="")
                used_track_indices.append(i)
            else:
                print(f"{location}, ", end="")
        print("]")
        print(f"Indices of used tracks: {used_track_indices}")
        print("---")

    return result, side_pin_placement


# HUMAN SORTING: https://stackoverflow.com/questions/5967500/how-to-correctly-sort-a-string-with-a-number-inside
def natural_keys(enum):
    def atof(text):
        try:
            retval = float(text)
        except ValueError:
            retval = text
        return retval

    text = enum[0]
    text = re.sub(r"(\[|\]|\.|\$)", "", text)
    """
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (see toothy's implementation in the comments)
    float regex comes from https://stackoverflow.com/a/12643073/190597
    """
    return [atof(c) for c in re.split(r"[+-]?([0-9]+(?:[.][0-9]*)?|[.][0-9]+)", text)]


def bus_keys(enum):
    text = enum[0]
    m = re.match(r"^.*\[(\d+)\]$", text)
    if not m:
        return -1
    else:
        return int(m.group(1))


@click.command()
@click.option(
    "-u",
    "--unmatched-error",
    is_flag=True,
    default=False,
    help="Treat unmatched pins as error",
)
@click.option("-c", "--config", required=False, help="Optional configuration file.")
@click.option(
    "-r",
    "--reverse",
    default="",
    type=str,
    help="Reverse along comma,delimited,cardinals: e.g. N,E",
)
@click.option("-L", "--length", default=2, type=float, help="Pin length in microns.")
@click.option(
    "-V",
    "--ver-layer",
    required=True,
    help="Name of metal layer to place vertical pins on.",
)
@click.option(
    "-H",
    "--hor-layer",
    required=True,
    help="Name of metal layer to place horizontal pins on.",
)
@click.option(
    "--hor-extension",
    default=0,
    type=float,
    help="Extension for vertical pins in microns.",
)
@click.option(
    "--ver-extension",
    default=0,
    type=float,
    help="Extension for horizontal pins in microns.",
)
@click.option(
    "--ver-width-mult", default=2, type=float, help="Multiplier for vertical pins."
)
@click.option(
    "--hor-width-mult", default=2, type=float, help="Multiplier for horizontal pins."
)
@click.option(
    "--bus-sort/--no-bus-sort",
    default=False,
    help="Misnomer: pins are grouped by index instead of bus, i.e. a[0] goes with b[0] instead of a[1].",
)
@click_odb
def io_place(
    reader,
    config,
    ver_layer,
    hor_layer,
    ver_width_mult,
    hor_width_mult,
    length,
    hor_extension,
    ver_extension,
    reverse,
    bus_sort,
    unmatched_error,
):
    """
    Places the IOs in an input def with an optional config file that supports regexes.

    Config format:
    #N|#S|#E|#W
    pin1_regex (low co-ordinates to high co-ordinates; e.g., bottom to top and left to right)
    pin2_regex
    ...

    #S|#N|#E|#W
    """
    config_file_name = config
    bus_sort_flag = bus_sort
    unmatched_error_flag = unmatched_error

    h_layer_name = hor_layer
    v_layer_name = ver_layer

    h_width_mult = float(hor_width_mult)
    v_width_mult = float(ver_width_mult)

    micron_in_units = reader.dbunits

    LENGTH = int(micron_in_units * length)

    H_EXTENSION = int(micron_in_units * hor_extension)
    V_EXTENSION = int(micron_in_units * ver_extension)

    if H_EXTENSION < 0:
        H_EXTENSION = 0

    if V_EXTENSION < 0:
        V_EXTENSION = 0

    reverse_arr_raw = reverse.split(",")
    reverse_arr = []
    for element in reverse_arr_raw:
        if element.strip() != "":
            reverse_arr.append(f"#{element}")
    # read config

    pin_placement_cfg = {"#N": [], "#E": [], "#S": [], "#W": []}
    cur_side = None
    if config_file_name is not None and config_file_name != "":
        with open(config_file_name, "r") as config_file:
            for line in config_file:
                line = line.split()
                if len(line) == 0:
                    continue

                if len(line) > 1:
                    print("Only one entry allowed per line.")
                    sys.exit(1)

                token = line[0]

                if cur_side is not None and token[0] != "#":
                    pin_placement_cfg[cur_side].append(token)
                elif token not in [
                    "#N",
                    "#E",
                    "#S",
                    "#W",
                    "#NR",
                    "#ER",
                    "#SR",
                    "#WR",
                    "#BUS_SORT",
                ]:
                    print(
                        "Valid directives are #N, #E, #S, or #W. Append R for reversing the default order.",
                        "Use #BUS_SORT to group 'bus bits' by index.",
                        "Please make sure you have set a valid side first before listing pins",
                    )
                    sys.exit(1)
                elif token == "#BUS_SORT":
                    bus_sort_flag = True
                else:
                    if len(token) == 3:
                        token = token[0:2]
                        reverse_arr.append(token)
                    cur_side = token

    # build a list of pins
    H_LAYER = reader.tech.findLayer(h_layer_name)
    V_LAYER = reader.tech.findLayer(v_layer_name)

    H_WIDTH = int(h_width_mult * H_LAYER.getWidth())
    V_WIDTH = int(v_width_mult * V_LAYER.getWidth())

    print("Top-level design name:", reader.name)

    bterms = reader.block.getBTerms()
    bterms_enum = []
    for bterm in bterms:
        pin_name = bterm.getName()
        bterms_enum.append((pin_name, bterm))

    # sort them "humanly"
    bterms_enum.sort(key=natural_keys)
    if bus_sort_flag:
        bterms_enum.sort(key=bus_keys)
    bterms = [bterm[1] for bterm in bterms_enum]

    pin_placement = {"#N": [], "#E": [], "#S": [], "#W": []}
    pin_distance_min = {
        "#N": V_WIDTH + V_LAYER.getSpacing(),
        "#S": V_WIDTH + V_LAYER.getSpacing(),
        "#E": H_WIDTH + H_LAYER.getSpacing(),
        "#W": H_WIDTH + H_LAYER.getSpacing(),
    }
    pin_distance = pin_distance_min.copy()
    bterm_regex_map = {}
    for side in pin_placement_cfg:
        for regex in pin_placement_cfg[side]:  # going through them in order
            if regex[0] == "$":  # Sign of Virtual Pins
                try:
                    virtual_pins_count = int(regex[1:])
                    pin_placement[side].append(virtual_pins_count)
                except ValueError:
                    print("You provided invalid values for virtual pins")
                    sys.exit(1)
            elif regex[0] == "@":
                variable = regex[1:].split("=")
                if variable[0] == "min_distance":
                    pin_distance[side] = float(variable[1]) * reader.dbunits
                    if pin_distance[side] < pin_distance_min[side]:
                        print(
                            f"Warning: Using min_distance {pin_distance_min[side] / reader.dbunits} for {side} pins to avoid overlap"
                        )
                        pin_distance[side] = pin_distance_min[side]
            else:
                regex += "$"  # anchor
                for bterm in bterms:
                    # if a pin name matches multiple regexes, their order will be
                    # arbitrary. More refinement requires more strict regexes (or just
                    # the exact pin name).
                    pin_name = bterm.getName()
                    if re.match(regex, pin_name) is not None:
                        if bterm in bterm_regex_map:
                            print(
                                f"Error: Multiple regexes matched {pin_name}. Those are {bterm_regex_map[bterm]} and {regex}"
                            )
                            sys.exit(os.EX_DATAERR)
                        bterm_regex_map[bterm] = regex
                        pin_placement[side].append(bterm)  # to maintain the order

    unmatched_bterms = [bterm for bterm in bterms if bterm not in bterm_regex_map]

    if len(unmatched_bterms) > 0:
        print("Warning: Some pins weren't matched by the config file")
        print("Those are:", [bterm.getName() for bterm in unmatched_bterms])
        if unmatched_error_flag:
            print("Treating unmatched pins as errors. Exiting..")
            sys.exit(1)
        else:
            print("Assigning random sides to the above pins")
            for bterm in unmatched_bterms:
                random_side = random.choice(list(pin_placement.keys()))
                pin_placement[random_side].append(bterm)

    # generate slots

    DIE_AREA = reader.block.getDieArea()
    BLOCK_LL_X = DIE_AREA.xMin()
    BLOCK_LL_Y = DIE_AREA.yMin()
    BLOCK_UR_X = DIE_AREA.xMax()
    BLOCK_UR_Y = DIE_AREA.yMax()

    print("Block boundaries:", BLOCK_LL_X, BLOCK_LL_Y, BLOCK_UR_X, BLOCK_UR_Y)

    origin, count, h_step = reader.block.findTrackGrid(H_LAYER).getGridPatternY(0)
    print(f"Horizontal Tracks Origin: {origin}, Count: {count}, Step: {h_step}")
    h_tracks = grid_to_tracks(origin, count, h_step)

    origin, count, v_step = reader.block.findTrackGrid(V_LAYER).getGridPatternX(0)
    print(f"Vertical Tracks Origin: {origin}, Count: {count}, Step: {v_step}")
    v_tracks = grid_to_tracks(origin, count, v_step)

    for rev in reverse_arr:
        pin_placement[rev].reverse()

    pin_tracks = {}
    for side in pin_placement:
        if side in ["#N", "#S"]:
            pin_tracks[side] = [
                v_tracks[i]
                for i in range(len(v_tracks))
                if (i % (math.ceil(pin_distance[side] / v_step))) == 0
            ]
        elif side in ["#W", "#E"]:
            pin_tracks[side] = [
                h_tracks[i]
                for i in range(len(h_tracks))
                if (i % (math.ceil(pin_distance[side] / h_step))) == 0
            ]

    # create the pins
    for side in pin_placement:
        slots, pin_placement[side] = equally_spaced_sequence(
            side, pin_placement[side], pin_tracks[side]
        )

        assert len(slots) == len(pin_placement[side])

        for i in range(len(pin_placement[side])):
            bterm = pin_placement[side][i]
            slot = slots[i]
            # print(f"Pin name: {bterm.getName()}, placed at slot: {slot}")

            pin_name = bterm.getName()
            pins = bterm.getBPins()
            if len(pins) > 0:
                print(f"Warning: {pin_name} already has shapes. Modifying them")
                assert len(pins) == 1
                pin_bpin = pins[0]
            else:
                pin_bpin = odb.dbBPin_create(bterm)

            pin_bpin.setPlacementStatus("PLACED")

            if side in ["#N", "#S"]:
                rect = odb.Rect(0, 0, V_WIDTH, LENGTH + V_EXTENSION)
                if side == "#N":
                    y = BLOCK_UR_Y - LENGTH
                else:
                    y = BLOCK_LL_Y - V_EXTENSION
                rect.moveTo(slot - V_WIDTH // 2, y)
                odb.dbBox_create(pin_bpin, V_LAYER, *rect.ll(), *rect.ur())
            else:
                rect = odb.Rect(0, 0, LENGTH + H_EXTENSION, H_WIDTH)
                if side == "#E":
                    x = BLOCK_UR_X - LENGTH
                else:
                    x = BLOCK_LL_X - H_EXTENSION
                rect.moveTo(x, slot - H_WIDTH // 2)
                odb.dbBox_create(pin_bpin, H_LAYER, *rect.ll(), *rect.ur())


if __name__ == "__main__":
    io_place()
