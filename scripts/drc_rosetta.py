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
import re
import click
from enum import IntEnum
from io import StringIO


MAGIC_SPLIT_LINE = "----------------------------------------"


def magic_to_rdb(magic_input: str, input_file_path: str = "UNKNOWN") -> str:
    """
    >>> print(magic_to_rdb('''RAM8
    ... ----------------------------------------
    ... P-diff distance to N-tap must be < 15.0um (LU.3)
    ... ----------------------------------------
    ...  17.990um 21.995um 18.265um 22.995um
    ...  20.905um 22.935um 21.575um 22.995um
    ...  18.535um 21.995um 18.795um 22.635um''')) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    $RAM8 100
    r_0_LU.3
    500 500 2 Nov 29 03:26:39 2020
    Rule File Pathname: UNKNOWN
    LU.3: P-diff distance to N-tap must be < 15.0um
    p 1 4
    1700 2100
    1800 2100
    1800 2200
    1700 2200
    p 2 4
    2000 2200
    2100 2200
    2100 2200
    2000 2200
    p 3 4
    1800 2100
    1800 2100
    1800 2200
    1800 2200
    """
    # Developed by @ganeshgore
    class State(IntEnum):
        drc = 0
        data = 1

    state = State.data

    return_value = ""

    with StringIO() as f:
        for i, line in enumerate(magic_input.split("\n")):
            if ("[INFO]" in line) or (len(line.strip()) == 0):
                continue
            elif i == 0:
                f.write(f"${line} 100\n")
            elif MAGIC_SPLIT_LINE in line:
                state = State.drc if state == State.data else State.data
            elif state == State.drc:
                drcRule = line.strip().split("(")
                drcRule = [drcRule, "UnknownRule"] if len(drcRule) < 2 else drcRule
                f.write(f"r_0_{drcRule[1][:-1]}\n")
                f.write("500 500 2 Nov 29 03:26:39 2020\n")
                f.write(f"Rule File Pathname: {input_file_path}\n")
                f.write(f"{drcRule[1][:-1]}: {drcRule[0]}\n")
                drcNumber = 1
            elif state == State.data:

                cord = [
                    int(float(i)) * 100
                    for i in line.strip().replace("um", "").split(" ")
                ]
                f.write(f"p {drcNumber} 4\n")
                f.write(f"{cord[0]} {cord[1]}\n")
                f.write(f"{cord[2]} {cord[1]}\n")
                f.write(f"{cord[2]} {cord[3]}\n")
                f.write(f"{cord[0]} {cord[3]}\n")
                drcNumber += 1
        return_value = f.getvalue()
    return return_value


def magic_to_tcl(magic_input: str) -> str:
    """
    >>> print(magic_to_tcl('''RAM8
    ... ----------------------------------------
    ... P-diff distance to N-tap must be < 15.0um (LU.3)
    ... ----------------------------------------
    ...  17.990um 21.995um 18.265um 22.995um
    ...  20.905um 22.935um 21.575um 22.995um
    ...  18.535um 21.995um 18.795um 22.635um''')) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    box 17.990um 21.995um 18.265um 22.995um; feedback add "P-diff distance to N-tap must be < 15.0um (LU.3)" medium
    box 20.905um 22.935um 21.575um 22.995um; feedback add "P-diff distance to N-tap must be < 15.0um (LU.3)" medium
    box 18.535um 21.995um 18.795um 22.635um; feedback add "P-diff distance to N-tap must be < 15.0um (LU.3)" medium
    """

    sections = magic_input.split(MAGIC_SPLIT_LINE)

    return_value = ""

    with StringIO() as f:
        for i in range(1, len(sections) - 1, 2):
            vio_name = sections[i].strip()
            for vio in sections[i + 1].split("\n"):
                vio = vio.strip()
                if len(vio):
                    print(f'box {vio}; feedback add "{vio_name}" medium', file=f)
        return_value = f.getvalue()
    return return_value


def magic_to_tr(magic_input: str) -> str:
    """
    >>> print(magic_to_tr('''RAM8
    ... ----------------------------------------
    ... P-diff distance to N-tap must be < 15.0um (LU.3)
    ... ----------------------------------------
    ...  17.990um 21.995um 18.265um 22.995um
    ...  20.905um 22.935um 21.575um 22.995um
    ...  18.535um 21.995um 18.795um 22.635um''')) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
        srcs: N/A N/A
        bbox = ( 17.990, 21.995 ) - ( 18.265, 22.995 ) on Layer LU
    violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
        srcs: N/A N/A
        bbox = ( 20.905, 22.935 ) - ( 21.575, 22.995 ) on Layer LU
    violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
        srcs: N/A N/A
        bbox = ( 18.535, 21.995 ) - ( 18.795, 22.635 ) on Layer LU
    """

    def cleanup(vio_type):
        return (
            str(vio_type)
            .replace(" ", "_")
            .replace(">", "gt")
            .replace("<", "lt")
            .replace("=", "eq")
            .replace("!", "not")
            .replace("^", "pow")
            .replace(".", "dot")
            .replace("-", "_")
            .replace("+", "plus")
            .replace("(", "")
            .replace(")", "")
        )

    sections = magic_input.split(MAGIC_SPLIT_LINE)

    layer_extraction = re.compile(r".*\s*\((\S+)\.?\s*[^\(\)]+\)")

    return_value = ""

    with StringIO() as f:
        for i in range(1, len(sections) - 1, 2):
            vio_name = sections[i].strip()
            vio_name_clean = cleanup(vio_name)

            m = layer_extraction.match(vio_name)
            layer = m.group(1).split(".")[0] if m is not None else "UNKNOWN"

            for vio in sections[i + 1].split("\n"):
                vio_cor = vio.strip().replace("um", "").split()
                if len(vio_cor) > 3:
                    print(f"  violation type: {vio_name_clean}", file=f)
                    print("    srcs: N/A N/A", file=f)
                    print(
                        f"    bbox = ( {vio_cor[0]}, {vio_cor[1]} ) - ( {vio_cor[2]}, {vio_cor[3]} ) on Layer {layer}",
                        file=f,
                    )

        return_value = f.getvalue()

    return return_value


def tr_to_klayout(tr_input: str, design_name: str) -> str:
    """
    >>> print(tr_to_klayout('''
    ... violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
    ...     srcs: N/A N/A
    ...     bbox = ( 17.990, 21.995 ) - ( 18.265, 22.995 ) on Layer LU
    ... violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
    ...     srcs: N/A N/A
    ...     bbox = ( 20.905, 22.935 ) - ( 21.575, 22.995 ) on Layer LU
    ... violation type: P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3
    ...     srcs: N/A N/A
    ...     bbox = ( 18.535, 21.995 ) - ( 18.795, 22.635 ) on Layer LU''', "RAM8")) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    <?xml version="1.0" ?>
    <report-database>
        <categories>
            <category>
                <name>P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3</name>
            </category>
        </categories>
        <cells>
            <cell>
                <name>RAM8</name>
            </cell>
        </cells>
        <items>
            <item>
                <category>P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3</category>
                <cell>RAM8</cell>
                <visited>false</visited>
                <multiplicity>1</multiplicity>
                <values>
                    <value>box: (17.990,21.995;18.265,22.995)</value>
                    <value>text: 'On layer LU'</value>
                    <value>text: 'Between N/A N/A'</value>
                </values>
            </item>
            <item>
                <category>P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3</category>
                <cell>RAM8</cell>
                <visited>false</visited>
                <multiplicity>1</multiplicity>
                <values>
                    <value>box: (20.905,22.935;21.575,22.995)</value>
                    <value>text: 'On layer LU'</value>
                    <value>text: 'Between N/A N/A'</value>
                </values>
            </item>
            <item>
                <category>P_diff_distance_to_N_tap_must_be_lt_15dot0um_LUdot3</category>
                <cell>RAM8</cell>
                <visited>false</visited>
                <multiplicity>1</multiplicity>
                <values>
                    <value>box: (18.535,21.995;18.795,22.635)</value>
                    <value>text: 'On layer LU'</value>
                    <value>text: 'Between N/A N/A'</value>
                </values>
            </item>
        </items>
    </report-database>
    """

    import xml.etree.ElementTree as ET
    import xml.dom.minidom as minidom

    RE_VIOLATION = re.compile(
        r"violation type: (?P<type>\S+)\s+"
        + r"srcs: (?P<src1>\S+)( (?P<src2>\S+))?\s+"
        + r"bbox = \( (?P<llx>\S+), (?P<lly>\S+) \)"
        + r" - "
        + r"\( (?P<urx>\S+), (?P<ury>\S+) \) "
        + r"on Layer (?P<layer>\S+)",
        re.M,
    )

    def prettify(elem):  # Return a pretty-printed XML string for the Element.
        rough_string = ET.tostring(elem, "utf-8")
        reparsed = minidom.parseString(rough_string)
        return reparsed.toprettyxml(indent="    ", newl="\n")

    count = 0
    vio_dict = {}
    for match in RE_VIOLATION.finditer(tr_input):
        count += 1
        type_ = match.group("type")
        src1 = match.group("src1")
        src2 = match.group("src2")
        llx = match.group("llx")
        lly = match.group("lly")
        urx = match.group("urx")
        ury = match.group("ury")
        layer = match.group("layer")

        item = ET.Element("item")
        ET.SubElement(item, "category").text = type_
        ET.SubElement(item, "cell").text = design_name
        ET.SubElement(item, "visited").text = "false"
        ET.SubElement(item, "multiplicity").text = "1"
        values = ET.SubElement(item, "values")
        box = ET.SubElement(values, "value")
        box.text = f"box: ({llx},{lly};{urx},{ury})"
        layer_msg = ET.SubElement(values, "value")
        layer_msg.text = f"text: 'On layer {layer}'"
        srcs = ET.SubElement(values, "value")
        if src2:
            srcs.text = f"text: 'Between {src1} {src2}'"
        else:
            srcs.text = f"text: 'Between {src1}'"

        # create XML object
        if type_ not in vio_dict:
            vio_dict[type_] = []

        vio_dict[type_].append(item)

    report_database = ET.Element("report-database")
    categories = ET.SubElement(report_database, "categories")
    for type_ in vio_dict.keys():
        category = ET.SubElement(categories, "category")
        ET.SubElement(category, "name").text = type_

    cells = ET.SubElement(report_database, "cells")
    cell = ET.SubElement(cells, "cell")
    ET.SubElement(cell, "name").text = design_name

    items = ET.Element("items")
    for _, vios in vio_dict.items():
        for item in vios:
            items.append(item)

    report_database.append(items)

    return prettify(report_database)


# ---


@click.group()
def cli():
    pass


@click.group()
def magic():
    """
    Conversions from Magic
    """
    pass


cli.add_command(magic)


@click.command("to_rdb")
@click.option("-o", "--output", required=True, help="Output .rdb file")
@click.argument("magic_input")
def magic_to_rdb_cmd(output, magic_input):
    with open(output, "w") as f:
        f.write(magic_to_rdb(open(magic_input).read(), magic_input))


magic.add_command(magic_to_rdb_cmd)


@click.command("to_tcl")
@click.option("-o", "--output", required=True, help="Output .tcl file")
@click.argument("magic_input")
def magic_to_tcl_cmd(output, magic_input):
    with open(output, "w") as f:
        f.write(magic_to_tcl(open(magic_input).read()))


magic.add_command(magic_to_tcl_cmd)


@click.command("to_tr")
@click.option("-o", "--output", required=True, help="Output .tr.drc file")
@click.argument("magic_input")
def magic_to_tr_cmd(output, magic_input):
    with open(output, "w") as f:
        f.write(magic_to_tr(open(magic_input).read()))


magic.add_command(magic_to_tr_cmd)


@click.group("tr")
def tr():
    """
    Conversions from TritonRoute
    """
    pass


cli.add_command(tr)


@click.command("to_klayout")
@click.option("-o", "--output", required=True, help="Output .klayout.xml file")
@click.option("-n", "--design-name", required=True, help="Design Name")
@click.argument("tr_input")
def tr_to_klayout_cmd(output, design_name, tr_input):
    with open(output, "w") as f:
        f.write(tr_to_klayout(open(tr_input).read(), design_name))


tr.add_command(tr_to_klayout_cmd)

if __name__ == "__main__":
    cli()
