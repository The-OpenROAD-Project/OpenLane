#!/usr/bin/python3
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
import io
import click

MULTIPLE_FAILURES = r"""
21. Executing CHECK pass (checking for obvious problems).
Checking module spm...
Warning: multiple conflicting drivers for spm.\x:
    module input f[0]
    module input x[0]
Warning: multiple conflicting drivers for spm.\y:
    port Y[0] of cell $ternary$/openlane/designs/spm/src/spm.v:18$1 ($tribuf)
    port Y[0] of cell $ternary$/openlane/designs/spm/src/spm.v:19$3 ($tribuf)
    module input y[0]
Warning: found logic loop in module spm:
    cell $ternary$/openlane/designs/spm/src/spm.v:18$1 ($tribuf)
    wire \y
Found and reported 3 problems.
"""

NO_TRISTATE = r"""
21. Executing CHECK pass (checking for obvious problems).
Checking module spm...
Warning: Wire spm.\k is used but has no driver.
Found and reported 1 problems.
"""

TRISTATE_ONLY = r"""
21. Executing CHECK pass (checking for obvious problems).
Checking module spm...
Warning: multiple conflicting drivers for spm.\y:
    port Y[0] of cell $ternary$/openlane/designs/spm/src/spm.v:16$1 ($tribuf)
    port Y[0] of cell $ternary$/openlane/designs/spm/src/spm.v:17$3 ($tribuf)
    module input y[0]
Warning: found logic loop in module spm:
    cell $ternary$/openlane/designs/spm/src/spm.v:16$1 ($tribuf)
    wire \y
Found and reported 2 problems.
"""

starts_with_whitespace = re.compile(r"^\s+.+$")


def parse_yosys_check(
    report: io.TextIOBase,
    tristate_okay: bool = False,
    quiet: bool = False,
    tristate_cell_prefix: str = "",
) -> bool:
    """
    >>> rpt = io.StringIO(MULTIPLE_FAILURES); parse_yosys_check(rpt, False, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    True
    >>> rpt = io.StringIO(MULTIPLE_FAILURES); parse_yosys_check(rpt, True, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    True
    >>> rpt = io.StringIO(NO_TRISTATE); parse_yosys_check(rpt, True, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    True
    >>> rpt = io.StringIO(NO_TRISTATE); parse_yosys_check(rpt, False, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    True
    >>> rpt = io.StringIO(TRISTATE_ONLY); parse_yosys_check(rpt, True, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    False
    >>> rpt = io.StringIO(TRISTATE_ONLY); parse_yosys_check(rpt, False, True) #doctest: +REPORT_NDIFF +NORMALIZE_WHITESPACE
    True
    """
    log = (lambda *a, **k: 0) if quiet else print
    error_encountered = False
    current_warning = None
    for line in report:
        if line.startswith("Warning:") or line.startswith("Found and reported"):
            if current_warning is not None:
                if tristate_okay and (
                    ("tribuf" in current_warning)
                    or (
                        tristate_cell_prefix != ""
                        and tristate_cell_prefix in current_warning
                    )
                ):
                    log("Ignoring tristate-related error:")
                    log(current_warning)
                else:
                    log("Encountered check error:")
                    log(current_warning)
                    error_encountered = True
            current_warning = line
        elif starts_with_whitespace.match(line) is not None:
            current_warning += line
        else:
            pass
    return error_encountered


@click.command()
@click.option(
    "--tristate-okay/--all-errors",
    default=False,
    help="Ignore check warnings related to use of tri-state buffers.",
)
@click.option("--tristate-cell-prefix", default="", help="Prefix of tristate cell")
@click.argument(
    "report",
    required=True,
)
def cli(tristate_okay, report, tristate_cell_prefix):
    """
    Takes output of yosys check command, generated using tee -o <report> check.
    Then checks if the warnings generated belong to tristate buffers only
    """
    if parse_yosys_check(
        open(report), tristate_okay, tristate_cell_prefix=tristate_cell_prefix
    ):
        exit(2)
    else:
        exit(0)


if __name__ == "__main__":
    cli()
