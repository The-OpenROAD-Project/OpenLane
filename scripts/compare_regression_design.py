# Copyright 2020-2021 Efabless Corporation
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

import os
import yaml
import click
import sys


@click.command()
@click.option(
    "--benchmark",
    "-b",
    "benchmark_file",
    required=True,
    help="The csv file from which to extract the benchmark results",
)
@click.option(
    "--design",
    "-d",
    required=True,
    help="The design to compare for between the two scripts. Same as -design in flow.tcl",
)
@click.option(
    "--run-path",
    "-p",
    required=True,
    help="The run path, will be used to search for any missing files.",
)
@click.option(
    "--output-report",
    "-o",
    "output_report_file",
    required=True,
    help="The file to print the final report in",
)
@click.argument("regression_results_file")
def cli(benchmark_file, design, run_path, output_report_file, regression_results_file):
    tolerance = {
        "general_tolerance": 1,
        "tritonRoute_violations": 2,
        "Magic_violations": 10,
        "pin_antenna_violations": 10,
        "lvs_total_errors": 0,
    }

    critical_statistics = [
        "tritonRoute_violations",
        "Magic_violations",
        "pin_antenna_violations",
        "lvs_total_errors",
    ]

    magic_file_extensions = ["gds", "mag", "lef", "spice"]

    def compare_vals(benchmark_value, regression_value, param):
        if str(benchmark_value) == "-1":
            return True
        if str(regression_value) == "-1":
            return False
        tol = 0 - tolerance["general_tolerance"]
        if param in tolerance.keys():
            tol = 0 - tolerance[param]
        if float(benchmark_value) - float(regression_value) >= tol:
            return True
        else:
            return False

    def parse_csv(csv_file):
        def get_csv_index(header, label):
            for i in range(len(header)):
                if label == header[i]:
                    return i
            else:
                return -1

        design_out = dict()
        csv_opener = open(csv_file, "r", encoding="utf8")
        csv_data = csv_opener.read().split("\n")
        header_info = csv_data[0].split(",")
        designPathIdx = get_csv_index(header_info, "design")
        if designPathIdx == -1:
            print(f"invalid report {csv_file}. No design paths.")
            exit(1)
        for i in range(1, len(csv_data)):
            if not len(csv_data[i]):
                continue
            entry = csv_data[i].split(",")
            designPath = entry[designPathIdx]
            if designPath == design:
                for idx in range(len(header_info)):
                    if idx != designPathIdx:
                        design_out[header_info[idx]] = entry[idx]
                break
        return design_out

    def critical_mismatch(benchmark, regression_result):
        if len(benchmark) == 0:
            return (
                True,
                "The design is not benchmarked. Make sure --design and 'design' field in benchmark are the identical",
            )
        for stat in critical_statistics:
            if compare_vals(benchmark[stat], regression_result[stat], stat):
                continue
            else:
                if str(regression_result[stat]) == "-1":
                    return (
                        True,
                        "The test didn't pass the stage responsible for " + stat,
                    )
                else:
                    return (
                        True,
                        "The results of " + stat + " mismatched with the benchmark",
                    )
        return False, "The test passed"

    def compare_status(benchmark, regression_result):
        if len(benchmark) == 0:
            return False, "The design is not benchmarked"
        elif "fail" in str(regression_result["flow_status"]):
            if "fail" in str(benchmark["flow_status"]):
                return (
                    False,
                    "The OpenLane flow failed, but the benchmark never saw it succeed",
                )
            else:
                return True, "The OpenLane flow failed outright, check the logs"
        else:
            return False, "The test passed"

    def missing_resulting_files(design):
        search_prefix = os.path.join(
            run_path, "results", "signoff", str(design["design_name"])
        )
        for ext in magic_file_extensions:
            required_result = f"{search_prefix}.{ext}"
            if not os.path.isfile(required_result):
                return (
                    True,
                    f"File {required_result} is missing from the results directory",
                )
        return False, "The test passed"

    benchmark = parse_csv(benchmark_file)
    regression_result = parse_csv(regression_results_file)

    did_pass = True
    notes = None

    failure, reason = compare_status(benchmark, regression_result)
    if failure:
        did_pass = False
        notes = notes or reason

    failure, reason = critical_mismatch(benchmark, regression_result)
    if failure:
        did_pass = False
        notes = notes or reason

    failure, reason = missing_resulting_files(regression_result)
    if failure:
        did_pass = False
        notes = notes or reason

    design_report = {"pass": did_pass, "notes": notes}

    current_yaml_str = "{}"
    try:
        current_yaml_str = open(output_report_file).read()
    except FileNotFoundError:
        pass

    current_yaml = yaml.safe_load(current_yaml_str)
    current_yaml[design] = design_report

    current_yaml_str = yaml.safe_dump(current_yaml, sort_keys=False)

    with open(output_report_file, "w") as f:
        f.write(current_yaml_str)

    if not did_pass:
        print(notes, file=sys.stderr)
        exit(1)


if __name__ == "__main__":
    cli()
