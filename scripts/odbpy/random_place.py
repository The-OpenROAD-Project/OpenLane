#!/usr/bin/env python3
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
import click
import random

from reader import click_odb


def gridify(n, f):
    """
    e.g., (1.1243, 0.005) -> 1.120
    """
    return round(n / f) * f


@click.command()
@click_odb
def random_place(reader):
    core_area = reader.block.getCoreArea()
    LLX, LLY = core_area.ll()
    URX, URY = core_area.ur()
    insts = reader.block.getInsts()

    print("Design name:", reader.name)
    print("Core Area Boundaries:", LLX, LLY, URX, URY)
    print("Number of instances", len(insts))

    placed_cnt = 0
    for inst in insts:
        if inst.isFixed():
            continue
        master = inst.getMaster()
        master_width = master.getWidth()
        master_height = master.getHeight()
        x = gridify(random.randint(LLX, max(LLX, URX - master_width)), 5)
        y = gridify(random.randint(LLY, max(LLY, URY - master_height)), 5)
        inst.setLocation(x, y)
        inst.setPlacementStatus("PLACED")

        placed_cnt += 1

    print(f"Placed {placed_cnt} instances.")


if __name__ == "__main__":
    random_place()
