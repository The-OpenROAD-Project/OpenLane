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

import re
import click

from reader import OdbReader, click_odb

import os  # For checks of file existance
import shutil  # For copy
import sys  # For stderr


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


@click.command("move_diearea")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.option(
    "-o",
    "--output-def",
    required=True,
    help="Output DEF. File should exist. Die area will be applied to this DEF",
)
@click.option("-i", "--template-def", required=True, help="Input DEF")
def move_diearea_command(input_lef, output_def, template_def):
    """
    Move die area from input def to output def
    """
    move_diearea(input_lef, output_def, template_def)


def move_diearea(input_lef, output_def, template_def):
    if not os.path.isfile(template_def):
        print("LEF file ", input_lef, " not found")
        raise FileNotFoundError
    if not os.path.isfile(template_def):
        print("Input DEF file ", template_def, " not found")
        raise FileNotFoundError
    if not os.path.isfile(output_def):
        print("Output DEF file ", output_def, " not found")
        raise FileNotFoundError

    source_db = odb.dbDatabase.create()
    destination_db = odb.dbDatabase.create()
    odb.read_lef(source_db, input_lef)
    odb.read_lef(destination_db, input_lef)

    odb.read_def(source_db, template_def)
    odb.read_def(destination_db, output_def)

    assert (
        source_db.getTech().getManufacturingGrid()
        == destination_db.getTech().getManufacturingGrid()
    )
    assert (
        source_db.getTech().getDbUnitsPerMicron()
        == destination_db.getTech().getDbUnitsPerMicron()
    )

    diearea = source_db.getChip().getBlock().getDieArea()
    output_block = destination_db.getChip().getBlock()
    output_block.setDieArea(diearea)
    # print("Applied die area: ", destination_db.getChip().getBlock().getDieArea().ur(), destination_db.getChip().getBlock().getDieArea().ll(), file=sys.stderr)

    assert odb.write_def(output_block, output_def) == 1


def check_pin_grid(
    manufacturing_grid, dbu_per_microns, pin_name, pin_coordinate, logfile
):
    if (pin_coordinate % manufacturing_grid) != 0:
        print(
            "[ERROR]: Pin coordinate",
            pin_coordinate,
            "for pin",
            pin_name,
            "does not match the manufacturing grid",
            file=sys.stderr,
        )
        print(
            "[ERROR]: Pin coordinate",
            pin_coordinate,
            "for pin",
            pin_name,
            "does not match the manufacturing grid",
            file=logfile,
        )  # IDK how to do this
        return True


@click.command("replace_pins")
@click.option("-o", "--output-def", default="./out.def", help="Destination DEF path")
@click.option("-l", "--input-lef", required=True, help="Merged LEF file")
@click.option("--log", "logpath", help="Log output file")
@click.argument("source_def")
@click.argument("template_def")
def replace_pins_command(output_def, input_lef, logpath, source_def, template_def):
    """
        Copies source_def to output, then if same pin exists in template def and first def then, it's written to output def

    Example to run:

        openroad -python scripts/defutil.py replace_pins -o output.def\
            --log defutil.log\
            --input-lef designs/def_test/runs/RUN_2022.01.30_12.32.26/tmp/merged.lef\
                designs/def_test/runs/RUN_2022.01.30_12.32.26/tmp/floorplan/4-io.def designs/def_test/def_test.def

    Note: Assumes that all pins are on metal layers and via pins dont exist.
    Note: It assumes that all pins are rectangles, not polygons.
    Note: This tool assumes no power pins exist in template def.
    Note: It should leave pins in source_def as-is if no pin in template def is found.
    Note: It assumes only one port with the same name exist.
    Note: It assumes that pin names matches the net names in template DEF.
    """
    replace_pins(output_def, input_lef, logpath, source_def, template_def)


cli.add_command(replace_pins_command)

# Note: If you decide to change any parameters, also change replace_pins_command's
def replace_pins(output_def, input_lef, logpath, source_def, template_def):
    # --------------------------------
    # 0. Sanity check: Check for all defs and lefs to exist
    # I removed the output def to NOT exist check, as it was making testing harder
    # --------------------------------

    if not os.path.isfile(input_lef):
        print("LEF file ", input_lef, " not found")
        raise FileNotFoundError
    if not os.path.isfile(source_def):
        print("First DEF file ", source_def, " not found")
        raise FileNotFoundError
    if not os.path.isfile(template_def):
        print("Template DEF file ", template_def, " not found")
        raise FileNotFoundError
    if logpath is None:
        logfile = sys.stdout
    else:
        logfile = open(logpath, "w+")

    # --------------------------------
    # 1. Copy the one def to second
    # --------------------------------
    print(
        "[defutil.py:replace_pins] Creating output DEF based on first DEF", file=logfile
    )
    shutil.copy(source_def, output_def)

    # --------------------------------
    # 2. Find list of all bterms in first def
    # --------------------------------
    source_db = odb.dbDatabase.create()
    odb.read_lef(source_db, input_lef)
    odb.read_def(source_db, source_def)
    source_bterms = source_db.getChip().getBlock().getBTerms()

    manufacturing_grid = source_db.getTech().getManufacturingGrid()
    dbu_per_microns = source_db.getTech().getDbUnitsPerMicron()

    print(
        "Using manufacturing grid:",
        manufacturing_grid,
        "Using dbu per mircons: ",
        dbu_per_microns,
        file=logfile,
    )

    all_bterm_names = set()

    for source_bterm in source_bterms:
        source_name = source_bterm.getName()
        # TODO: Check for pin name matches net name
        # print("Bterm", source_name, "is declared as", source_bterm.getSigType())

        # --------------------------------
        # 3. Check no bterms should be marked as power, because it is assumed that caller already removed them
        # --------------------------------
        if (source_bterm.getSigType() == "POWER") or (
            source_bterm.getSigType() == "GROUND"
        ):
            print(
                "Bterm",
                source_name,
                "is declared as",
                source_bterm.getSigType(),
                "ignoring it",
                file=logfile,
            )
            continue
        all_bterm_names.add(source_name)

    print(
        "[defutil.py:replace_pins] Found",
        len(all_bterm_names),
        "block terminals in first def",
        file=logfile,
    )

    # --------------------------------
    # 4. Read the template def
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
    # 5. Create a dict with net -> pin location. Check for only one pin location to exist, overwise return an error
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

    print(
        "[defutil.py:replace_pins] Found template_bterms: ",
        len(template_bterm_locations),
        file=logfile,
    )

    for template_bterm_name in template_bterm_locations:
        print(
            template_bterm_name,
            ": ",
            template_bterm_locations[template_bterm_name],
            file=logfile,
        )

    # --------------------------------
    # 6. Modify the pins in out def, according to dict
    # --------------------------------
    output_db = odb.dbDatabase.create()
    odb.read_lef(output_db, input_lef)
    odb.read_def(output_db, output_def)
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
                    "For:",
                    name,
                    "Wrote on layer:",
                    layer.getName(),
                    "coordinates: ",
                    template_bterm_location_tuple[1],
                    template_bterm_location_tuple[2],
                    template_bterm_location_tuple[3],
                    template_bterm_location_tuple[4],
                    file=logfile,
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[1],
                        logfile,
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[2],
                        logfile,
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[3],
                        logfile,
                    )
                    or grid_errors
                )
                grid_errors = (
                    check_pin_grid(
                        manufacturing_grid,
                        dbu_per_microns,
                        name,
                        template_bterm_location_tuple[4],
                        logfile,
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
                "[defutil.py:replace_pins] Not found",
                name,
                "in template def, but found in output def. Leaving as-is",
                file=logfile,
            )

    if grid_errors:
        sys.exit("[ERROR]: Grid errors happened. Check log for grid errors.")
    # --------------------------------
    # 7. Write back the output def
    # --------------------------------
    print("[defutil.py:replace_pins] Writing output def to: ", output_def, file=logfile)
    assert odb.write_def(output_block, output_def) == 1


@click.command("remove_components")
@click.option(
    "-m",
    "--match",
    "rx_str",
    default="^.+$",
    help="Regular expression to match for components to be removed. (Default: '^.+$', matches all strings.)",
)
@click_odb
def remove_components(rx_str, output, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(rx_str)
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
def remove_nets(rx_str, output, empty_only, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(rx_str)
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
    "-m",
    "--match",
    "rx_str",
    default="^.+$",
    help="Regular expression to match for components to be removed. (Default: '^.+$', matches all strings.)",
)
@click_odb
def remove_pins(rx_str, output, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)
    matcher = re.compile(rx_str)
    pins = reader.block.getBTerms()
    for pin in pins:
        name = pin.getName()
        name_m = matcher.search(name)
        if name_m is not None:
            odb.dbBTerm.destroy(pin)

    assert odb.write_def(reader.block, output) == 1


cli.add_command(remove_pins)


@click.command("replace_instance_prefixes")
@click.option("-f", "--original-prefix", required=True, help="The original prefix.")
@click.option("-t", "--new-prefix", required=True, help="The new prefix.")
@click_odb
def replace_instance_prefixes(
    original_prefix, new_prefix, output, input_lef, input_def
):
    reader = OdbReader(input_lef, input_def)

    for instance in reader.block.getInsts():
        name: str = instance.getName()
        if name.startswith(f"{original_prefix}_"):
            new_name = name.replace(f"{original_prefix}_", f"{new_prefix}_")
            instance.rename(new_name)

    assert odb.write_def(reader.block, output) == 1


cli.add_command(replace_instance_prefixes)


@click.command("add_def_obstructions")
@click.option(
    "-O",
    "--obstructions",
    required=True,
    help="Format: layer llx lly urx ury, (microns)",
)
@click_odb
def add_def_obstructions(output, obstructions, input_lef, input_def):
    reader = OdbReader(input_lef, input_def)

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

    odb.write_def(reader.block, output)


cli.add_command(add_def_obstructions)

if __name__ == "__main__":
    cli()
