# Copyright 2021-2022 Efabless Corporation
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
import click


class OdbReader(object):
    def __init__(self, lef_in, def_in):
        self.db = odb.dbDatabase.create()
        if isinstance(lef_in, list) or isinstance(lef_in, tuple):
            self.lef = []
            for lef in lef_in:
                lef_read_result = odb.read_lef(self.db, lef)
                if lef_read_result is None:
                    raise Exception(f"read_lef returned None for '{lef}'")
                self.lef.append(lef_read_result)
            self.sites = [lef.getSites() for lef in self.lef]
        else:
            self.lef = odb.read_lef(self.db, lef_in)
            if self.lef is None:
                raise Exception(f"read_lef returned None for '{lef_in}'")
            self.sites = self.lef.getSites()
        self.tech = self.db.getTech()

        if def_in is not None:
            self.df = odb.read_def(self.db, def_in)
            self.block = self.db.getChip().getBlock()
            self.name = self.block.getName()
            self.rows = self.block.getRows()
            self.dbunits = self.block.getDefUnits()


def click_odb(function):
    function = click.option(
        "-o", "--output", default="./out.def", help="Output DEF file"
    )(function)
    function = click.option(
        "-l",
        "--input-lef",
        required=True,
        help="LEF file needed to have a proper view of the DEF files",
    )(function)
    function = click.argument("input_def")(function)
    return function
