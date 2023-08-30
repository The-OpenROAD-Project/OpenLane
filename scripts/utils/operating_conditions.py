#!/usr/bin/env python3
# Copyright 2023 Efabless Corporation
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

import json
import os.path
import click


@click.group()
def cli():
    pass


@click.command("find_condition")
@click.argument("liberty-file", type=click.Path(dir_okay=False))
@click.argument("json-database-file", type=click.Path(dir_okay=False, exists=True))
def find_condition(liberty_file, json_database_file):
    print(json.load(open(json_database_file))[liberty_file])


@click.command("save")
@click.argument("condition")
@click.argument("liberty-file", type=click.Path(dir_okay=False))
@click.argument("json-database-file", type=click.Path(dir_okay=False))
def save(condition, liberty_file, json_database_file):
    data = {}
    if os.path.isfile(json_database_file):
        data = json.load(open(json_database_file))
    data[liberty_file] = condition
    with open(json_database_file, "w") as f:
        json.dump(data, f)


cli.add_command(save)
cli.add_command(find_condition)

if __name__ == "__main__":
    cli()
