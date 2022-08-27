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

from reader import OdbReader


@click.group()
def cli():
    pass


@click.command("get_metal_layers")
@click.option("--output", "-o", default="/dev/stdout", help="Output file.")
@click.argument("lefs", nargs=-1)
def get_metal_layers(output, lefs):
    reader = OdbReader(lefs, None)

    layers = [
        layer for layer in reader.tech.getLayers() if layer.getRoutingLevel() >= 1
    ]

    layer_names = [
        layer.getName() for layer in sorted(layers, key=lambda l: l.getRoutingLevel())
    ]

    with open(output, "w") as f:
        f.write(" ".join(layer_names))

    print(layer_names)


cli.add_command(get_metal_layers)


@click.command("widen_site")
@click.option("--widen-value", "-w", type=float, required=True)
@click.option(
    "--factor/--absolute",
    "-f/-a",
    default=False,
    help="use the widen value as a factor or an absolute value",
)
@click.option("--output", "-o", default="./out.lef", help="Output file.")
@click.argument("lef")
def widen_site(output, widen_value, factor, lef):
    # TODO: Redo using OpenDB (if possible)
    lef_content = open(lef).read().splitlines()

    started = False
    done = False
    for i in range(len(lef_content)):
        # looking for SITE
        if lef_content[i].find("SITE") != -1:
            started = True

        if started:
            # looking for SIZE
            if lef_content[i].find("SIZE") != -1:
                line = lef_content[i].split(" ")
                for j in range(len(line)):
                    if line[j] == "SIZE":
                        # if a factor modify the value by the factor
                        for x in range(j + 1, len(line)):
                            if line[x] != "":
                                if factor:
                                    orgVal = float(line[x])
                                    widen_value = float(widen_value) * orgVal
                                # change the value
                                line[x] = str(widen_value)
                                done = True
                                break
                        break
                lef_content[i] = " ".join(line)

        if done:
            break

    # writing to output file
    with open(output, "w") as f:
        for line in lef_content:
            print(line, file=f)


cli.add_command(widen_site)


@click.command("zeroize_origin")
@click.option("--output", "-o", default="./out.lef", help="Output file.")
@click.argument("lef")
def zeroize_origin(output, lef):
    # TODO: Redo using OpenDB (if possible)
    RECT_REGEX = re.compile(
        r"^\s*RECT\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$"
    )
    ORIGIN_REGEX = re.compile(r"^\s*ORIGIN\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+;$")

    lef_lines = open(lef).read().splitlines()

    with open(output, "w") as f:
        OFFSET_X = OFFSET_Y = 0
        for line in lef_lines:
            if line.isspace():
                continue
            origin_match = ORIGIN_REGEX.search(line)
            if origin_match:
                OFFSET_X, OFFSET_Y = float(origin_match.group(1)), float(
                    origin_match.group(2)
                )
                print(line[: line.find("O")] + "ORIGIN %.3f %.3f ;" % (0, 0), file=f)
            else:
                rect_match = RECT_REGEX.search(line)
                if rect_match:
                    llx, lly, urx, ury = (
                        float(rect_match.group(1)),
                        float(rect_match.group(2)),
                        float(rect_match.group(3)),
                        float(rect_match.group(4)),
                    )
                    print(
                        line[: line.find("R")]
                        + "RECT %.3f %.3f %.3f %.3f ;"
                        % (
                            llx + OFFSET_X,
                            lly + OFFSET_Y,
                            urx + OFFSET_X,
                            ury + OFFSET_Y,
                        ),
                        file=f,
                    )
                else:
                    print(line, end="", file=f)


cli.add_command(zeroize_origin)

if __name__ == "__main__":
    cli()
