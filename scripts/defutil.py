# Copyright 2021 Efabless Corporation
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

import re
import click

import odb

# For checks of file existance
import os
import shutil

# For sys.exit
import sys


@click.group()
def cli():
    pass


class OdbReader(object):
    def __init__(self, lef_in, def_in):
        self.db = odb.dbDatabase.create()

        self.lef = odb.read_lef(self.db, lef_in)
        self.sites = self.lef.getSites()

        self.df = odb.read_def(self.db, def_in)
        self.block = self.db.getChip().getBlock()
        self.rows = self.block.getRows()
        self.dbunits = self.block.getDefUnits()
        self.nets = self.block.getNets()


# OdbReader("designs/def_test/runs/RUN_2022.01.30_12.32.26/tmp/merged.lef", "designs/def_test/runs/RUN_2022.01.30_12.32.26/results/final/def/def_test.def")

# if isinstance(lef_in, collections.Sequence):
#            self.lef = []
#            for lef_inst in lef_in:
#                self.lef.append(odb.read_lef(self.db, lef_inst))
#        else:


@click.command("extract_core_dims")
@click.option("-o", "--output-data", required=True, help="Output")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
def extract_core_dims(output_data, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    core_area = reader.block.getCoreArea()

    with open(output_data, "w") as f:
        print(
            f"{core_area.dx() / reader.dbunits} {core_area.dy() / reader.dbunits}",
            file=f,
        )


cli.add_command(extract_core_dims)


@click.command("mark_component_fixed")
@click.option(
    "-c", "--cell-name", required=True, help="Cell name of the components to mark fixed"
)
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
def mark_component_fixed(cell_name, output, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    instances = reader.block.getInsts()
    for instance in instances:
        if instance.getMaster().getName() == cell_name:
            instance.setPlacementStatus("FIRM")

    assert odb.write_def(reader.block, output) == 1


cli.add_command(mark_component_fixed)


def merge_item_section(
    item: str, def_one_str: str, def_two_str: str, replace_two: bool = False
) -> str:
    import re

    section_start_rx = re.compile(rf"{item}\s+(\d+)\s*;\s*")
    section_end_rx = re.compile(rf"END\s+{item}")

    def_one_lines = def_one_str.splitlines()
    def_two_lines = def_two_str.splitlines()

    collecting = False
    def_two_out_lines = []
    def_two_count = 0
    for line in def_two_lines:
        start_match = section_start_rx.search(line)
        end_match = section_end_rx.search(line)
        if end_match is not None:
            collecting = False
            break
        if collecting:
            def_two_out_lines.append(line)
        if start_match is not None:
            def_two_count = int(start_match[1])
            collecting = True

    # assert(len(def_two_out_lines) == def_two_count) # sanity check
    final_out_lines = []

    def_one_count = 0
    for line in def_one_lines:
        start_match = section_start_rx.search(line)
        end_match = section_end_rx.search(line)
        if start_match is not None:
            def_one_count = int(start_match[1])
            final_count = def_one_count
            if not replace_two:
                final_count += def_two_count
            final_out_lines.append(f"{item} {final_count} ;")
        elif end_match is not None:
            if not replace_two:
                final_out_lines += def_two_out_lines
            final_out_lines.append(f"END {item}")
        else:
            final_out_lines.append(line)

    return "\n".join(final_out_lines)


@click.command("merge_components")
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("def_one")
@click.argument("def_two")
def merge_components(output, input_lef, def_one, def_two):
    # TODO: Rewrite in OpenDB if possible
    def_one_str = open(def_one).read()
    def_two_str = open(def_two).read()

    with open(output, "w") as f:
        f.write(merge_item_section("COMPONENTS", def_one_str, def_two_str))


cli.add_command(merge_components)


@click.command("merge_pins")
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("def_one")
@click.argument("def_two")
def merge_pins(output, input_lef, def_one, def_two):
    # TODO: Rewrite in OpenDB if possible
    def_one_str = open(def_one).read()
    def_two_str = open(def_two).read()

    with open(output, "w") as f:
        f.write(merge_item_section("PINS", def_one_str, def_two_str))


# openroad -python scripts/defutil.py replace_pins -o output.def -l designs/def_test/runs/RUN_2022.01.30_12.32.26/tmp/merged.lef designs/def_test/runs/RUN_2022.01.30_12.32.26/tmp/floorplan/4-io.def designs/def_test/def_test.def


@click.command(
    "replace_pins",
    help="""
Copies first_def to output, then if same pin exists in reference def and first def then, it's written to output def

Note: assumes that all pins are on metal layers and via pins dont exist
Note: It assumes that all pins are rectangles, not polygons
Note: This tool assumes no power pins exist in reference def
Note: it should leave pins in first_def as-is if no pin in reference def is found
Note: It assumes only one port with the same name exist
""",
)
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("first_def")
@click.argument("reference_def")
def replace_pins(output, input_lef, first_def, reference_def):
    # --------------------------------
    # 0. Sanity check: Check for all defs and lefs to exist
    # I removed the output def to NOT exist check, as it was making testing harder
    # --------------------------------

    if not os.path.isfile(input_lef):
        print("LEF file ", input_lef, " not found")
        raise FileNotFoundError
    if not os.path.isfile(first_def):
        print("First DEF file ", first_def, " not found")
        raise FileNotFoundError
    if not os.path.isfile(reference_def):
        print("Reference DEF file ", reference_def, " not found")
        raise FileNotFoundError
    # if os.path.isfile(output):
    #    print("Not overwriting output DEF file ", reference_def)
    #    raise FileNotFoundError

    # --------------------------------
    # 1. Copy the one def to second
    # --------------------------------
    print("[defutil.py:replace_pins] Creating output DEF based on first DEF")
    shutil.copy(first_def, output)

    # --------------------------------
    # 2. Find list of all bterms in first def
    # --------------------------------
    first_db = odb.dbDatabase.create()
    odb.read_lef(first_db, input_lef)
    odb.read_def(first_db, first_def)
    first_bterms = first_db.getChip().getBlock().getBTerms()

    all_bterm_names = set()

    for first_bterm in first_bterms:
        first_name = first_bterm.getName()
        # print("Bterm", first_name, "is declared as", first_bterm.getSigType())

        # --------------------------------
        # 3. Check no bterms should be marked as power, because it is assumed that caller already removed them
        # --------------------------------
        if (first_bterm.getSigType() == "POWER") or (
            first_bterm.getSigType() == "GROUND"
        ):
            print(
                "Bterm",
                first_name,
                "is declared as",
                first_bterm.getSigType(),
                "ignoring it",
            )
            continue
        all_bterm_names.add(first_name)

    print(
        "[defutil.py:replace_pins] Found",
        len(all_bterm_names),
        "block terminals in first def",
    )

    # --------------------------------
    # 4. Read the reference def
    # --------------------------------
    ref_db = odb.dbDatabase.create()
    odb.read_lef(ref_db, input_lef)
    odb.read_def(ref_db, reference_def)
    ref_bterms = ref_db.getChip().getBlock().getBTerms()

    # --------------------------------
    # 5. Create a dict with net -> pin location. Check for only one pin location to exist, overwise return an error
    # --------------------------------
    ref_bterm_locations = dict()

    for ref_bterm in ref_bterms:
        ref_name = ref_bterm.getName()
        ref_pins = ref_bterm.getBPins()

        # TODO: Move layers too
        for ref_pin in ref_pins:
            boxes = ref_pin.getBoxes()

            for box in boxes:
                layer = box.getTechLayer().getName()
                if ref_name not in ref_bterm_locations:
                    ref_bterm_locations[ref_name] = []
                ref_bterm_locations[ref_name].append(
                    (
                        layer,
                        box.xMin(),
                        box.yMin(),
                        box.xMax(),
                        box.yMax(),
                    )
                )

    print("[defutil.py:replace_pins] Found ref_bterms: ", len(ref_bterm_locations))

    # for ref_bterm_name in ref_bterm_locations:
    #    print(ref_bterm_name, ": ", ref_bterm_locations[ref_bterm_name])

    # --------------------------------
    # 6. Modify the pins in out def, according to dict
    # --------------------------------
    output_db = odb.dbDatabase.create()
    odb.read_lef(output_db, input_lef)
    odb.read_def(output_db, output)
    output_tech = output_db.getTech()
    output_block = output_db.getChip().getBlock()
    output_bterms = output_block.getBTerms()

    for output_bterm in output_bterms:
        name = output_bterm.getName()
        output_bpins = output_bterm.getBPins()

        if name in ref_bterm_locations and name in all_bterm_names:
            for output_bpin in output_bpins:
                odb.dbBPin.destroy(output_bpin)

            for ref_bterm_location_tuple in ref_bterm_locations[name]:
                layer = output_tech.findLayer(ref_bterm_location_tuple[0])
                shape = ref_bterm_location_tuple[1]

                # --------------------------------
                # 6.2 Create new pin
                # --------------------------------

                output_new_bpin = odb.dbBPin.create(output_bterm)

                # print("For:", name,"Wrote on layer:", layer.getName(), "coordinates: ", ref_bterm_location_tuple[1], ref_bterm_location_tuple[2], ref_bterm_location_tuple[3], ref_bterm_location_tuple[4])
                odb.dbBox.create(
                    output_new_bpin,
                    layer,
                    ref_bterm_location_tuple[1],
                    ref_bterm_location_tuple[2],
                    ref_bterm_location_tuple[3],
                    ref_bterm_location_tuple[4],
                )
                output_new_bpin.setPlacementStatus("PLACED")
        else:
            print(
                "[defutil.py:replace_pins] Not found",
                name,
                "in reference def, but found in output def. Leaving as-is",
            )

    # --------------------------------
    # 7. Write back the output def
    # --------------------------------
    print("[defutil.py:replace_pins] Writing output def to: ", output)
    odb.write_def(output_block, output)

    # Steps:
    # Fetch the BTerms and then BPins of the second
    #
    # with open(output, "w") as f:
    #    f.write(merge_item_section("PINS", def_one_str, def_two_str, replace_two=True))


cli.add_command(replace_pins)


@click.command("remove_components")
@click.option(
    "--rx/--not-rx", default=True, help="Treat instance name as a regular expression"
)
@click.option(
    "-n",
    "--instance-name",
    default=".+",
    help="Instance name to be removed (Default '.+', as a regular expression, removes everything.)",
)
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
def remove_components(rx, instance_name, output, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(instance_name if rx else f"^{re.escape(instance_name)}$")
    instances = reader.block.getInsts()
    for instance in instances:
        name = instance.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            odb.dbInst.destroy(instance)

    assert odb.write_def(reader.block, output) == 1


cli.add_command(remove_components)


@click.command("remove_nets")
@click.option(
    "--rx/--not-rx", default=True, help="Treat net name as a regular expression"
)
@click.option(
    "-n",
    "--net-name",
    default=".+",
    help="Net name to be removed (Default '.+', as a regular expression, removes everything.)",
)
@click.option("-o", "--output", default="./out.def")
@click.option(
    "--empty-only", is_flag=True, default=False, help="Only remove empty nets."
)
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
def remove_nets(rx, net_name, output, empty_only, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(net_name if rx else f"^{re.escape(net_name)}$")
    nets = reader.block.getNets()
    for net in nets:
        name = net.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            if empty_only and len(net.getITerms()) > 0:
                continue
            # BTerms = PINS, if it has a pin we need to keep the net
            if len(net.getBTerms()) > 0:
                for port in net.getITerms():
                    odb.dbITerm.disconnect(port)
            else:
                odb.dbNet.destroy(net)

    assert odb.write_def(reader.block, output) == 1


cli.add_command(remove_nets)


@click.command("remove_pins")
@click.option(
    "--rx/--not-rx", default=True, help="Treat pin name as a regular expression"
)
@click.option(
    "-n",
    "--pin-name",
    default=".+",
    help="Pin name to be removed (Default '.+', as a regular expression, removes everything.)",
)
@click.option("-o", "--output", default="./out.def")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.argument("input_def")
def remove_pins(rx, pin_name, output, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(pin_name if rx else f"^{re.escape(pin_name)}$")
    pins = reader.block.getBTerms()
    for pin in pins:
        name = pin.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            odb.dbBTerm.destroy(pin)

    assert odb.write_def(reader.block, output) == 1


cli.add_command(remove_pins)


if __name__ == "__main__":
    cli()
