#!/usr/bin/env python3
# Copyright 2022 Efabless Corporation
# place_diodes Copyright (C) 2020 Sylvain Munaut <tnt@246tNt.com>
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

import sys
import click
import random
from decimal import Decimal

from reader import click_odb


@click.group()
def cli():
    pass


class DiodeInserter:
    def __init__(
        self,
        block,
        diode_cell,
        diode_pin,
        side_strategy="source",
        threshold_microns=0,
        port_protect=[],
        verbose=False,
    ):
        self.block = block
        self.verbose = verbose

        self.diode_cell = diode_cell
        self.diode_pin = diode_pin
        self.side_strategy = side_strategy
        self.threshold_microns = threshold_microns
        self.port_protect = port_protect

        self.diode_master = block.getDataBase().findMaster(diode_cell)
        self.diode_site = self.diode_master.getSite().getConstName()

        self.inserted = {}

    def debug(self, msg):
        if self.verbose:
            print(msg, file=sys.stderr)

    def error(self, msg):
        print(msg, file=sys.stderr)

    def net_source(self, net):
        # See if it's an input pad
        for bt in net.getBTerms():
            if bt.getIoType() != "INPUT":
                continue
            good, x, y = bt.getFirstPinLocation()
            if good:
                return (x, y)

        # Or maybe output of a cell
        # x = odb.new_int(0)
        # y = odb.new_int(0)

        for it in net.getITerms():
            if not it.isOutputSignal():
                continue
            found, x, y = it.getAvgXY()
            if found:
                return x, y

        # Nothing found
        return None

    def net_from_pin(self, net, io_types=None):
        for bt in net.getBTerms():
            if (io_types is None) or (bt.getIoType() in io_types):
                return True
        return False

    def net_has_diode(self, net):
        for it in net.getITerms():
            cell_type = it.getInst().getMaster().getConstName()
            cell_pin = it.getMTerm().getConstName()
            if (cell_type == self.diode_cell) and (cell_pin == self.diode_pin):
                return True
        else:
            return False

    def net_manhattan_distance(self, net):
        xs = []
        ys = []

        for bt in net.getBTerms():
            good, x, y = bt.getFirstPinLocation()
            if good:
                xs.append(x)
                ys.append(y)

        for it in net.getITerms():
            x, y = self.pin_position(it)
            xs.append(x)
            ys.append(y)

        if len(xs) == 0:
            return 0

        return (max(ys) - min(ys)) + (max(xs) - min(xs))

    def pin_position(self, it):
        # px = odb.new_int(0)
        # py = odb.new_int(0)

        found, px, py = it.getAvgXY()
        if found:
            # Got it
            return px, py
        else:
            # Failed, use the center coordinate of the instance as fall back
            return it.getInst().getLocation()

    def place_diode_stdcell(self, it, px, py, src_pos=None):
        # Get information about the instance
        inst_name = it.getInst().getConstName()
        inst_width = it.getInst().getMaster().getWidth()
        inst_pos = it.getInst().getLocation()
        inst_ori = it.getInst().getOrient()

        # Is the pin left-ish, center-ish or right-ish ?
        pos = None

        if self.side_strategy == "source":
            # Always be on the side of the source
            if src_pos is not None:
                pos = "l" if (src_pos[0] < inst_pos[0]) else "r"

        elif self.side_strategy == "pin":
            # Always be on the side of the pin
            pos = "l" if (px < (inst_pos[0] + inst_width // 2)) else "r"

        elif self.side_strategy == "balanced":
            # If pin is really on the side, use that, else use source side
            th_left = int(inst_pos[0] + inst_width * 0.25)
            th_right = int(inst_pos[0] + inst_width * 0.75)

            if px < th_left:
                pos = "l"
            elif px > th_right:
                pos = "r"
            elif src_pos is not None:
                # Sort of middle, so put it on the side where signal is coming from
                pos = "l" if (src_pos[0] < inst_pos[0]) else "r"

        if pos is None:
            # Coin toss ...
            pos = "l" if (random.random() > 0.5) else "r"

        # X position
        dw = self.diode_master.getWidth()

        if pos == "l":
            dx = inst_pos[0] - dw * (1 + self.inserted.get((inst_name, "l"), 0))
        else:
            dx = inst_pos[0] + inst_width + dw * self.inserted.get((inst_name, "r"), 0)

        # Record insertion
        self.inserted[(inst_name, pos)] = self.inserted.get((inst_name, pos), 0) + 1

        # Done
        return dx, inst_pos[1], inst_ori

    def place_diode_macro(self, it, px, py, src_pos=None):
        # Scan all rows to see how close we can get to the point
        best = None

        for row in self.block.getRows():
            rbb = row.getBBox()

            dx = max(min(rbb.xMax(), px), rbb.xMin())
            dy = rbb.yMin()
            do = row.getOrient()

            d = abs(px - dx) + abs(py - dy)

            if (best is None) or (best[0] > d):
                best = (d, dx, dy, do)

        return best[1:]

    def insert_diode(self, it, src_pos):
        # Get information about the instance
        inst = it.getInst()
        inst_name = inst.getConstName()
        inst_site = (
            inst.getMaster().getSite().getConstName()
            if (inst.getMaster().getSite() is not None)
            else None
        )

        # Find where the pin is
        px, py = self.pin_position(it)

        # Apply standard cell or macro placement ?
        if inst_site == self.diode_site:
            dx, dy, do = self.place_diode_stdcell(it, px, py, src_pos)
        else:
            dx, dy, do = self.place_diode_macro(it, px, py, src_pos)

        # Insert instance and wire it up
        diode_inst_name = "ANTENNA_" + inst_name + "_" + it.getMTerm().getConstName()
        diode_master = self.diode_master

        diode_inst = odb.dbInst_create(self.block, diode_master, diode_inst_name)

        diode_inst.setOrient(do)
        diode_inst.setLocation(dx, dy)
        diode_inst.setPlacementStatus("PLACED")

        ait = diode_inst.findITerm(self.diode_pin)
        ait.connect(it.getNet())

    def execute(self):
        # Scan all nets
        for net in self.block.getNets():
            # Skip special nets
            if net.isSpecial():
                self.debug(f"[d] Skipping special net {net.getConstName():s}")
                continue

            # Check if we already have diode on the net
            # if yes, then we assume that the user took care of that net manually
            if self.net_has_diode(net):
                self.debug(
                    f"[d] Skipping manually protected net {net.getConstName():s}"
                )
                continue

            # Find signal source (first one found ...)
            src_pos = self.net_source(net)

            # Is this an IO we need to protect
            io_protect = None
            if self.net_from_pin(net, io_types=["INPUT", "OUTPUT"]):
                io_protect = self.net_from_pin(net, io_types=self.port_protect)
                if io_protect:
                    self.debug(
                        f"[d] Forcing protection diode on I/O net {net.getConstName():s}"
                    )
                else:
                    self.debug(f"[d] Skipping I/O net {net.getConstName():s}")
                    continue

            # Determine the span of the signal and skip small internal nets
            span = self.net_manhattan_distance(net) / self.block.getDbUnitsPerMicron()
            if (span < self.threshold_microns) and not io_protect:
                self.debug(f"[d] Skipping small net {net.getConstName():s} ({span:f})")
                continue

            # Scan all internal terminals
            for it in net.getITerms():
                if it.isInputSignal():
                    self.insert_diode(it, src_pos)


@click.command()
@click.option(
    "-v", "--verbose", default=False, is_flag=True, help="Verbose debug output"
)
@click.option(
    "-c",
    "--diode-cell",
    default="sky130_fd_sc_hd__diode_2",
    help="Name of the cell to use as diode",
)
@click.option(
    "-p", "--diode-pin", default="DIODE", help="Name of the pin to use on diode cells"
)
@click.option(
    "--side-strategy",
    type=click.Choice(["source", "pin", "balanced", "random"]),
    default="source",
    help="Strategy to select if placing diode left/right of the cell",
)
@click.option(
    "--port-protect",
    type=click.Choice(["none", "in", "out", "both"]),
    default="in",
    help="Always place a true diode on nets connected to selected ports",
)
@click.option(
    "-t",
    "--threshold",
    "threshold_microns",
    type=Decimal,
    default=90,
    help="Minimum manhattan distance of a net to be considered an antenna risk requiring a diode",
)
@click_odb
def place(
    reader,
    verbose,
    diode_cell,
    diode_pin,
    side_strategy,
    port_protect,
    threshold_microns,
):

    print(f"Design name: {reader.name}")

    pp_val = {
        "none": [],
        "in": ["INPUT"],
        "out": ["OUTPUT"],
        "both": ["INPUT", "OUTPUT"],
    }

    di = DiodeInserter(
        reader.block,
        diode_cell=diode_cell,
        diode_pin=diode_pin,
        side_strategy=side_strategy,
        threshold_microns=threshold_microns,
        port_protect=pp_val[port_protect],
        verbose=verbose,
    )
    di.execute()

    print("Inserted", len(di.inserted), "diodes.")


cli.add_command(place)


if __name__ == "__main__":
    cli()
