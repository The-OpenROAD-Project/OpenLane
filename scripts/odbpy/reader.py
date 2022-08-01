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
import inspect


class OdbReader(object):
    def __init__(self, lef_in, def_in):
        self.db = odb.dbDatabase.create()
        self.lef = []
        if not (isinstance(lef_in, list) or isinstance(lef_in, tuple)):
            lef_in = [lef_in]
        for lef in lef_in:
            self.lef.append(odb.read_lef(self.db, lef))
        self.tech = self.db.getTech()

        if def_in is not None:
            self.df = odb.read_def(self.db, def_in)
            self.block = self.db.getChip().getBlock()
            self.name = self.block.getName()
            self.rows = self.block.getRows()
            self.dbunits = self.block.getDefUnits()
            self.instances = self.block.getInsts()

    def add_lef(self, new_lef):
        self.lef.append(odb.read_lef(self.db, new_lef))


def click_odb(function):
    def wrapper(input_lef, input_def, output, **kwargs):
        reader = OdbReader(input_lef, input_def)

        signature = inspect.signature(function)
        parameter_keys = signature.parameters.keys()

        kwargs = kwargs.copy()
        kwargs["reader"] = reader

        if "input_def" in parameter_keys:
            kwargs["input_def"] = input_def
        if "input_lef" in parameter_keys:
            kwargs["input_lef"] = input_lef
        if "output" in parameter_keys:
            kwargs["output"] = output

        function(**kwargs)

        odb.write_def(reader.block, output)

    wrapper = click.option(
        "-o", "--output", default="./out.def", help="Output DEF file"
    )(wrapper)
    wrapper = click.option(
        "-l",
        "--input-lef",
        required=True,
        help="LEF file needed to have a proper view of the DEF files",
    )(wrapper)
    wrapper = click.argument("input_def")(wrapper)

    return wrapper
