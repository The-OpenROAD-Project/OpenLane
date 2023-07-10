# Copyright 2020 Efabless Corporation
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


class AntennaViolation:
    def __init__(self, net, pin, required_ratio, partial_ratio, layer):
        self.net = net
        self.pin = pin
        self.required_ratio = float(required_ratio)
        self.partial_ratio = float(partial_ratio)
        self.layer = layer
        self.partial_to_required = self.partial_ratio / self.required_ratio

    def __lt__(self, other):
        return self.partial_to_required < other.partial_to_required

    def __str__(self):
        return f"Partial/Required: {self.partial_to_required:5.2f}, Required: {self.required_ratio:8}, Partial: {self.partial_ratio:8}, Net: {self.net}, Pin: {self.pin}, Layer: {self.layer}"


@click.command()
@click.option(
    "-o",
    "--output",
    required=True,
    type=click.Path(
        exists=False,
        dir_okay=False,
        writable=True,
    ),
    help="Output file to store results.",
)
@click.option(
    "--plain-out",
    type=click.Path(
        exists=False,
        dir_okay=False,
        writable=True,
    ),
    default=None,
    help="If provided, outputs violator pins in a plain, EOL-delimited format to the path specified.",
)
@click.argument("report", nargs=1)
def extract_antenna_violators(output, plain_out, report):
    """
    Usage: extract_antenna_violators.py -o <output text file> <input ARC report>
    Extracts the list of violating nets from an ARC report file"
    """

    net_pattern = re.compile(r"\s*Net:\s*(\S+)")
    required_ratio_pattern = re.compile(r"\s*Required ratio:\s+([\d.]+)")
    partial_ratio_pattern = re.compile(r"\s*Partial area ratio:\s+([\d.]+)")
    layer_pattern = re.compile(r"\s*Layer:\s+(\S+)")
    pin_pattern = re.compile(r"\s*Pin:\s+(\S+)")

    required_ratio = None
    layer = None
    partial_ratio = None
    required_ratio = None
    pin = None
    net = None
    violations = []

    with open(report, "r") as f:
        for line in f:
            pin_new = pin_pattern.match(line)
            required_ratio_new = required_ratio_pattern.match(line)
            partial_ratio_new = partial_ratio_pattern.match(line)
            layer_new = layer_pattern.match(line)
            net_new = net_pattern.match(line)
            required_ratio = (
                required_ratio_new.group(1)
                if required_ratio_new is not None
                else required_ratio
            )
            partial_ratio = (
                partial_ratio_new.group(1)
                if partial_ratio_new is not None
                else partial_ratio
            )
            layer = layer_new.group(1) if layer_new is not None else layer
            pin = pin_new.group(1) if pin_new is not None else pin
            net = net_new.group(1) if net_new is not None else net

            if "VIOLATED" in line:
                violations.append(
                    AntennaViolation(
                        net=net,
                        pin=pin,
                        partial_ratio=partial_ratio,
                        layer=layer,
                        required_ratio=required_ratio,
                    )
                )

    violations.sort(reverse=True)
    with open(output, "w") as f:
        for violation in violations:
            print(violation)
            f.write(f"{violation}\n")

    if plain_out is not None:
        with open(plain_out, "w") as f:
            for violation in violations:
                f.write(f"{violation.pin}\n")


if __name__ == "__main__":
    extract_antenna_violators()
