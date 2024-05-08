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
from openroad import Tech, Design
from typing import ClassVar, Optional

import os
import sys
import inspect
import functools

import click


class OdbReader(object):
    primary_reader: ClassVar[Optional["OdbReader"]] = None

    def __init__(self, *args):
        if primary := OdbReader.primary_reader:
            self.db = odb.dbDatabase.create()
            self.db.setLogger(primary.design.getLogger())
        else:
            self.ord_tech = Tech()
            self.design = Design(self.ord_tech)
            self.db = self.ord_tech.getDB()

        if len(args) == 1:
            db_in = args[0]
            self.db = odb.read_db(self.db, db_in)
        elif len(args) == 2:
            lef_in, def_in = args
            if not (isinstance(lef_in, list) or isinstance(lef_in, tuple)):
                lef_in = [lef_in]
            for lef in lef_in:
                odb.read_lef(self.db, lef)
            if def_in is not None:
                odb.read_def(self.db.getTech(), def_in)

        self.tech = self.db.getTech()
        self.chip = self.db.getChip()
        if self.chip is not None:
            self.block = self.db.getChip().getBlock()
            self.name = self.block.getName()
            self.rows = self.block.getRows()
            self.dbunits = self.block.getDefUnits()
            self.instances = self.block.getInsts()

        if OdbReader.primary_reader is None:
            OdbReader.primary_reader = self

    def add_lef(self, new_lef):
        odb.read_lef(self.db, new_lef)


def click_odb(function):
    @functools.wraps(function)
    def wrapper(input_db, output, output_def, input_lef, **kwargs):
        reader = OdbReader(input_db)

        signature = inspect.signature(function)
        parameter_keys = signature.parameters.keys()

        kwargs = kwargs.copy()
        kwargs["reader"] = reader

        if "input_db" in parameter_keys:
            kwargs["input_db"] = input_db
        if "input_lef" in parameter_keys:
            kwargs["input_lef"] = input_lef
        if "output" in parameter_keys:
            kwargs["output"] = output

        if input_db.endswith(".def"):
            print(
                "Error: Invocation was not updated to use an odb file.", file=sys.stderr
            )
            exit(os.EX_USAGE)

        function(**kwargs)

        if output_def is not None:
            odb.write_def(reader.block, output_def)
        sys.stdout.flush()
        odb.write_db(reader.db, output)

    wrapper = click.option(
        "-O", "--output-def", default="./out.def", help="Output DEF file"
    )(wrapper)
    wrapper = click.option(
        "-o", "--output", default="./out.odb", help="Output ODB file"
    )(wrapper)
    wrapper = click.option(
        "-l",
        "--input-lef",
        required=True,
        help="LEF file needed to have a proper view of the DEF files",
    )(wrapper)
    wrapper = click.argument("input_db")(wrapper)

    return wrapper
