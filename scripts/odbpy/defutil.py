# Copyright 2021-2022 Efabless Corporation
# Copyright 2022 Arman Avetisyan
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

import click

from reader import OdbReader, click_odb


@click.group()
def cli():
    pass


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
@click_odb
def mark_component_fixed(cell_name, reader):
    instances = reader.block.getInsts()
    for instance in instances:
        if instance.getMaster().getName() == cell_name:
            instance.setPlacementStatus("FIRM")


cli.add_command(mark_component_fixed)


@click.command("merge_components")
@click.option(
    "-w",
    "--with-components-from",
    "donor_def",
    required=True,
    help="A donor def file from which to extract components.",
)
@click_odb
def merge_components(reader, donor_def, input_lef):
    """
    Adds all components in a donor DEF file that do not exist in the (recipient) INPUT_DEF.

    Existing components with the same name will *not* be overwritten.
    """
    donor = OdbReader(input_lef, donor_def)
    recipient = reader

    for instance in donor.instances:
        odb.dbInst_create(recipient.block, instance.getMaster(), instance.getName())


cli.add_command(merge_components)


def move_diearea(target_db, input_lef, template_def):
    source_db = odb.dbDatabase.create()

    odb.read_lef(source_db, input_lef)
    odb.read_def(source_db, template_def)

    assert (
        source_db.getTech().getManufacturingGrid()
        == target_db.getTech().getManufacturingGrid()
    )
    assert (
        source_db.getTech().getDbUnitsPerMicron()
        == target_db.getTech().getDbUnitsPerMicron()
    )

    diearea = source_db.getChip().getBlock().getDieArea()
    output_block = target_db.getChip().getBlock()
    output_block.setDieArea(diearea)


@click.command("move_diearea")
@click.option("-i", "--template-def", required=True, help="Input DEF")
@click_odb
def move_diearea_command(reader, input_lef, template_def):
    """
    Move die area from input def to output def
    """
    move_diearea(reader.db, input_lef, template_def)


def check_pin_grid(manufacturing_grid, dbu_per_microns, pin_name, pin_coordinate):
    if (pin_coordinate % manufacturing_grid) != 0:
        print(
            f"[ERROR]: Pin {pin_name}'s coordinate {pin_coordinate} does not lie on the manufacturing grid."
        )  # IDK how to do this
        return True


def relocate_pins(db, input_lef, template_def):
    # --------------------------------
    # 1. Find list of all bterms in existing database
    # --------------------------------
    source_db = db
    source_bterms = source_db.getChip().getBlock().getBTerms()

    manufacturing_grid = source_db.getTech().getManufacturingGrid()
    dbu_per_microns = source_db.getTech().getDbUnitsPerMicron()

    print(
        f"Using manufacturing grid: {manufacturing_grid}",
        f"Using dbu per mircons: {dbu_per_microns}",
    )

    all_bterm_names = set()

    for source_bterm in source_bterms:
        source_name = source_bterm.getName()
        # TODO: Check for pin name matches net name
        # print("Bterm", source_name, "is declared as", source_bterm.getSigType())

        # --------------------------------
        # 3. Check no bterms should be marked as power, because it is assumed that caller already removed them
        # --------------------------------
        sigtype = source_bterm.getSigType()
        if sigtype in ["POWER", "GROUND"]:
            print(
                f"[WARNING] Bterm {source_name} is declared as a '{sigtype}' pin. It will be ignored.",
            )
            continue
        all_bterm_names.add(source_name)

    print(
        f"Found {len(all_bterm_names)} block terminals in existing database...",
    )

    # --------------------------------
    # 2. Read the donor def
    # --------------------------------
    template_db = odb.dbDatabase.create()
    odb.read_lef(template_db, input_lef)
    odb.read_def(template_db, template_def)
    template_bterms = template_db.getChip().getBlock().getBTerms()

    assert (
        source_db.getTech().getManufacturingGrid()
        == template_db.getTech().getManufacturingGrid()
    )
    assert (
        source_db.getTech().getDbUnitsPerMicron()
        == template_db.getTech().getDbUnitsPerMicron()
    )

    # --------------------------------
    # 3. Create a dict with net -> pin location. Check for only one pin location to exist, overwise return an error
    # --------------------------------
    template_bterm_locations = dict()

    for template_bterm in template_bterms:
        template_name = template_bterm.getName()
        template_pins = template_bterm.getBPins()

        # TODO: Check for pin name matches net name
        for template_pin in template_pins:
            boxes = template_pin.getBoxes()

            for box in boxes:
                layer = box.getTechLayer().getName()
                if template_name not in template_bterm_locations:
                    template_bterm_locations[template_name] = []
                template_bterm_locations[template_name].append(
                    (
                        layer,
                        box.xMin(),
                        box.yMin(),
                        box.xMax(),
                        box.yMax(),
                    )
                )

    print(f"Found {len(template_bterm_locations)} template_bterms:")

    for name in template_bterm_locations.keys():
        print(f"  * {name}: {template_bterm_locations[name]}")

    # --------------------------------
    # 4. Modify the pins in out def, according to dict
    # --------------------------------
    output_db = db
    output_tech = output_db.getTech()
    output_block = output_db.getChip().getBlock()
    output_bterms = output_block.getBTerms()
    grid_errors = False
    for output_bterm in output_bterms:
        name = output_bterm.getName()
        output_bpins = output_bterm.getBPins()

        if name in template_bterm_locations and name in all_bterm_names:
            for output_bpin in output_bpins:
                odb.dbBPin.destroy(output_bpin)

            for template_bterm_location_tuple in template_bterm_locations[name]:
                layer = output_tech.findLayer(template_bterm_location_tuple[0])

                # --------------------------------
                # 6.2 Create new pin
                # --------------------------------

                output_new_bpin = odb.dbBPin.create(output_bterm)

                print(
                    f"Wrote pin {name} at layer {layer.getName()} at {template_bterm_location_tuple[1:]}..."
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[1],
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[2],
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[3],
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[4],
                    )
                    or grid_errors
                )
                odb.dbBox.create(
                    output_new_bpin,
                    layer,
                    template_bterm_location_tuple[1],
                    template_bterm_location_tuple[2],
                    template_bterm_location_tuple[3],
                    template_bterm_location_tuple[4],
                )
                output_new_bpin.setPlacementStatus("PLACED")
        else:
            print(
                f"{name} not found in donor def, but found in output def. Leaving as-is.",
            )

    if grid_errors:
        print(
            "[ERROR]: Some pins were grid-misaligned. Please check the log.",
            file=sys.stderr,
        )
        exit(os.EX_DATAERR)


@click.command("relocate_pins")
@click.option(
    "-t",
    "--template-def",
    required=True,
    help="Template DEF to use the locations of pins from.",
)
@click_odb
def relocate_pins_command(reader, input_lef, template_def):
    """
    Moves pins that are common between a template_def and the database to the
    location specified in the template_def.

    Assumptions:
        * The template def lacks power pins.
        * All pins are on metal layers (none on vias.)
        * All pins are rectangular.
        * All pins have unique names.
        * All pin names match the net names in the template DEF.
    """
    relocate_pins(reader.db, input_lef, template_def)


cli.add_command(relocate_pins_command)


@click.command("remove_components")
@click.option(
    "-m",
    "--match",
    "rx_str",
    default="^.+$",
    help="Regular expression to match for components to be removed. (Default: '^.+$', matches all strings.)",
)
@click_odb
def remove_components(rx_str, reader):
    matcher = re.compile(rx_str)
    instances = reader.block.getInsts()
    for instance in instances:
        name = instance.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            odb.dbInst.destroy(instance)


cli.add_command(remove_components)


@click.command("remove_nets")
@click.option(
    "-m",
    "--match",
    "rx_str",
    default="^.+$",
    help="Regular expression to match for nets to be removed. (Default: '^.+$', matches all strings.)",
)
@click.option(
    "--empty-only",
    is_flag=True,
    default=False,
    help="Adds a further condition to only remove empty nets (i.e. unconnected nets).",
)
@click_odb
def remove_nets(rx_str, empty_only, reader):
    matcher = re.compile(rx_str)
    nets = reader.block.getNets()
    for net in nets:
        name = net.getName()
        name_m = matcher.match(name)
        if name_m is not None:
            if empty_only and len(net.getITerms()) > 0:
                continue
            # BTerms = PINS, if it has a pin we need to keep the net
            if len(net.getBTerms()) > 0:
                for port in net.getITerms():
                    odb.dbITerm.disconnect(port)
            else:
                odb.dbNet.destroy(net)


cli.add_command(remove_nets)


@click.command("remove_pins")
@click.option(
    "-m",
    "--match",
    "rx_str",
    default="^.+$",
    help="Regular expression to match for components to be removed. (Default: '^.+$', matches all strings.)",
)
@click_odb
def remove_pins(rx_str, reader):
    matcher = re.compile(rx_str)
    pins = reader.block.getBTerms()
    for pin in pins:
        name = pin.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            odb.dbBTerm.destroy(pin)


cli.add_command(remove_pins)


@click.command("replace_instance_prefixes")
@click.option("-f", "--original-prefix", required=True, help="The original prefix.")
@click.option("-t", "--new-prefix", required=True, help="The new prefix.")
@click_odb
def replace_instance_prefixes(original_prefix, new_prefix, reader):
    for instance in reader.block.getInsts():
        name: str = instance.getName()
        if name.startswith(f"{original_prefix}_"):
            new_name = name.replace(f"{original_prefix}_", f"{new_prefix}_")
            instance.rename(new_name)


cli.add_command(replace_instance_prefixes)


@click.command("add_obstructions")
@click.option(
    "-O",
    "--obstructions",
    required=True,
    help="Format: layer llx lly urx ury, (microns)",
)
@click_odb
def add_obstructions(obstructions, reader):
    RE_NUMBER = r"[\-]?[0-9]+(\.[0-9]+)?"
    RE_OBS = (
        r"(?P<layer>\S+)\s+"
        + r"(?P<bbox>"
        + RE_NUMBER
        + r"\s+"
        + RE_NUMBER
        + r"\s+"
        + RE_NUMBER
        + r"\s+"
        + RE_NUMBER
        + r")"
    )

    obses = obstructions.split(",")
    obs_list = []
    for obs in obses:
        obs = obs.strip()
        m = re.match(RE_OBS, obs)
        assert (
            m
        ), "Incorrectly formatted input (%s).\n Format: layer llx lly urx ury, ..." % (
            obs
        )
        layer = m.group("layer")
        bbox = [float(x) for x in m.group("bbox").split()]
        obs_list.append((layer, bbox))

    for obs in obs_list:
        layer = obs[0]
        bbox = obs[1]
        dbu = reader.tech.getDbUnitsPerMicron()
        bbox = [int(x * dbu) for x in bbox]
        print("Creating an obstruction on", layer, "at", *bbox, "(DBU)")
        odb.dbObstruction_create(reader.block, reader.tech.findLayer(layer), *bbox)


cli.add_command(add_obstructions)

if __name__ == "__main__":
    cli()
