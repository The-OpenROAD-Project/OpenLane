#!/usr/bin/env python3
# Copyright (c) 2023 Efabless Corporation
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

from klayout.rdb import ReportDatabase
import click


@click.command()
@click.option("--xml-file")
@click.option("--json-file")
def cli(xml_file, json_file):
    database = ReportDatabase("Database")
    json_database = {}
    database.load(xml_file)
    total = 0
    for category in database.each_category():
        num_items = category.num_items()
        category_name = category.name()
        json_database[category_name] = num_items
        total += num_items

    json_database = dict(sorted(json_database.items(), key=lambda item: item[1]))
    json_database["total"] = total

    with open(json_file, "w", encoding="utf8") as f:
        json.dump(json_database, f)


if __name__ == "__main__":
    cli()
