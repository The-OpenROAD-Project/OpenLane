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

import click
import xlsxwriter


@click.command()
@click.option(
    "--benchmark",
    "-b",
    "benchmark_file",
    required=True,
    help="The csv file from which to extract the benchmark results",
)
@click.option(
    "--full-benchmark/--no-full-benchmark",
    default=True,
    help="If no, use the regression results instead of the benchmark as the design list, i.e., don't look for *every* design in the benchmark.",
)
@click.option(
    "--output-report",
    "-o",
    "output_report_file",
    required=True,
    help="The file to print the final report in",
)
@click.option(
    "--output-xlsx",
    "-x",
    "output_xlsx_file",
    required=False,
    help="The csv file to print a merged csv file benchmark vs regression_script in",
)
@click.argument("regression_results_file")
def cli(
    benchmark_file,
    full_benchmark,
    output_report_file,
    output_xlsx_file,
    regression_results_file,
):
    not_full_benchmark = not full_benchmark

    benchmark = dict()
    regression_results = dict()

    output_report_list = []

    testFail = False

    configuration_mismatches = []
    critical_mismatches = []

    missing_configs = []

    base_configs = [
        "CLOCK_PERIOD",
        "SYNTH_STRATEGY",
        "MAX_FANOUT_CONSTRAINT",
        "FP_CORE_UTIL",
        "FP_ASPECT_RATIO",
        "FP_PDN_VPITCH",
        "FP_PDN_HPITCH",
        "PL_TARGET_DENSITY",
        "GRT_ADJUSTMENT",
        "STD_CELL_LIBRARY",
    ]

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

    note_worthy_statistics = []

    ignore_list = ["", "design", "design_name", "config"]

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

    def findIdx(header, label):
        for idx in range(len(header)):
            if label == header[idx]:
                return idx
        else:
            return -1

    def diff_list(l1, l2):
        return [x for x in l1 if x not in l2]

    def parseCSV(csv_file, isBenchmark):
        nonlocal note_worthy_statistics
        map_out = dict()
        csvOpener = open(csv_file, "r", encoding="utf8")
        csvData = csvOpener.read().split("\n")
        headerInfo = csvData[0].split(",")
        designNameIdx = findIdx(headerInfo, "design")
        if isBenchmark:
            note_worthy_statistics = diff_list(
                diff_list(diff_list(headerInfo, ignore_list), critical_statistics),
                base_configs,
            )

        remover = 0
        size = len(base_configs)
        while remover < size:
            if base_configs[remover] not in headerInfo:
                missing_configs.append(base_configs[remover])
                base_configs.pop(remover)
                remover -= 1
                size -= 1
            remover += 1

        if designNameIdx == -1:
            print("Invalid report. No design name was found.")
            exit(-1)
        for i in range(1, len(csvData)):
            if len(csvData[i]):
                entry = csvData[i].split(",")
                designName = entry[designNameIdx]
                for idx in range(len(headerInfo)):
                    if idx != designNameIdx:
                        if designName not in map_out.keys():
                            map_out[designName] = dict()
                            if isBenchmark:
                                map_out[designName]["Status"] = "PASSED"
                            else:
                                map_out[designName]["Status"] = "----"
                        map_out[designName][headerInfo[idx]] = str(entry[idx])
        return map_out

    def configurationMismatch(benchmark, regression_results):
        nonlocal configuration_mismatches
        designList = list()
        if not_full_benchmark:
            designList = regression_results.keys()
        else:
            designList = benchmark.keys()

        for design in designList:
            output_report_list.append(
                "\nComparing Configurations for: " + design + "\n"
            )
            configuration_mismatches.append(
                "\nComparing Configurations for: " + design + "\n"
            )
            if design not in regression_results:
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided regression sheet\n"
                )
                configuration_mismatches.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided regression sheet\n"
                )
                continue

            if design not in benchmark:
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided benchmark sheet\n"
                )
                configuration_mismatches.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided benchmark sheet\n"
                )
                continue

            size_before = len(configuration_mismatches)
            for config in base_configs:
                if benchmark[design][config] == regression_results[design][config]:
                    output_report_list.append("\tConfiguration " + config + " MATCH\n")
                    output_report_list.append(
                        "\t\tConfiguration "
                        + config
                        + " value: "
                        + benchmark[design][config]
                        + "\n"
                    )
                else:
                    configuration_mismatches.append(
                        "\tConfiguration " + config + " MISMATCH\n"
                    )
                    output_report_list.append(
                        "\tConfiguration " + config + " MISMATCH\n"
                    )
                    configuration_mismatches.append(
                        "\t\tDesign "
                        + design
                        + " Configuration "
                        + config
                        + " BENCHMARK value: "
                        + benchmark[design][config]
                        + "\n"
                    )
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Configuration "
                        + config
                        + " BENCHMARK value: "
                        + benchmark[design][config]
                        + "\n"
                    )
                    configuration_mismatches.append(
                        "\t\tDesign "
                        + design
                        + " Configuration "
                        + config
                        + " USER value: "
                        + regression_results[design][config]
                        + "\n"
                    )
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Configuration "
                        + config
                        + " USER value: "
                        + regression_results[design][config]
                        + "\n"
                    )
            if size_before == len(configuration_mismatches):
                configuration_mismatches = configuration_mismatches[:-1]

    def criticalMistmatch(benchmark, regression_results):
        nonlocal testFail
        nonlocal critical_mismatches
        designList = list()
        if not_full_benchmark:
            designList = regression_results.keys()
        else:
            designList = benchmark.keys()

        for design in designList:
            output_report_list.append(
                "\nComparing Critical Statistics for: " + design + "\n"
            )
            critical_mismatches.append(
                "\nComparing Critical Statistics for: " + design + "\n"
            )
            if design not in regression_results:
                testFail = True
                benchmark[design]["Status"] = "NOT FOUND"
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided regression sheet\n"
                )
                critical_mismatches.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided regression sheet\n"
                )
                continue

            if design not in benchmark:
                testFail = False
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided benchmark sheet\n"
                )
                critical_mismatches.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided benchmark sheet\n"
                )
                continue

            size_before = len(critical_mismatches)
            for stat in critical_statistics:
                if compare_vals(
                    benchmark[design][stat], regression_results[design][stat], stat
                ):
                    output_report_list.append("\tStatistic " + stat + " MATCH\n")
                    output_report_list.append(
                        "\t\tStatistic "
                        + stat
                        + " value: "
                        + benchmark[design][stat]
                        + "\n"
                    )
                else:
                    testFail = True
                    benchmark[design]["Status"] = "FAIL"
                    critical_mismatches.append("\tStatistic " + stat + " MISMATCH\n")
                    output_report_list.append("\tStatistic " + stat + " MISMATCH\n")
                    critical_mismatches.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " BENCHMARK value: "
                        + benchmark[design][stat]
                        + "\n"
                    )
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " BENCHMARK value: "
                        + benchmark[design][stat]
                        + "\n"
                    )
                    critical_mismatches.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " USER value: "
                        + regression_results[design][stat]
                        + "\n"
                    )
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " USER value: "
                        + regression_results[design][stat]
                        + "\n"
                    )
            if len(critical_mismatches) == size_before:
                critical_mismatches = critical_mismatches[:-1]

    def noteWorthyMismatch(benchmark, regression_results):
        designList = list()
        if not_full_benchmark:
            designList = regression_results.keys()
        else:
            designList = benchmark.keys()

        for design in designList:
            output_report_list.append(
                "\nComparing Note Worthy Statistics for: " + design + "\n"
            )
            if design not in regression_results:
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided regression sheet\n"
                )
                continue

            if design not in benchmark:
                output_report_list.append(
                    "\tDesign "
                    + design
                    + " Not Found in the provided benchmark sheet\n"
                )
                continue

            for stat in note_worthy_statistics:
                if (
                    benchmark[design][stat] == regression_results[design][stat]
                    or benchmark[design][stat] == "-1"
                ):
                    output_report_list.append("\tStatistic " + stat + " MATCH\n")
                    output_report_list.append(
                        "\t\tStatistic "
                        + stat
                        + " value: "
                        + benchmark[design][stat]
                        + "\n"
                    )
                else:
                    output_report_list.append("\tStatistic " + stat + " MISMATCH\n")
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " BENCHMARK value: "
                        + benchmark[design][stat]
                        + "\n"
                    )
                    output_report_list.append(
                        "\t\tDesign "
                        + design
                        + " Statistic "
                        + stat
                        + " USER value: "
                        + regression_results[design][stat]
                        + "\n"
                    )

    flow_failures = []

    def flowFailures(regression_results):
        nonlocal flow_failures
        for design in regression_results.keys():
            if "failed" in regression_results[design]["flow_status"]:
                flow_failures.append(design)

    benchmark = parseCSV(benchmark_file, 1)
    regression_results = parseCSV(regression_results_file, 0)
    flowFailures(regression_results)
    configurationMismatch(benchmark, regression_results)
    criticalMistmatch(benchmark, regression_results)
    noteWorthyMismatch(benchmark, regression_results)

    with open(output_report_file, "w") as report_file:

        def write(*args, **kwargs):
            print(*args, **kwargs, file=report_file)

        if testFail:
            write("Failed")
        else:
            write("Passed")
        write("---")

        if len(flow_failures):
            write("[OpenLane Flow Failures] (Designs where OpenLane failed outright)")
            write("")
            for failure in flow_failures:
                write(failure)
            write("")
            write("---")

        if len(missing_configs):
            write("[Missing Configuration Variables]  (Do not exist in the sheets.)")
            write("")
            for variable in missing_configs:
                write(variable)
            write("")
            write("---")

        if testFail:
            write("[Critical Mismatches] (Cause Failures)")
            write("".join(critical_mismatches))
            write("---")

        if testFail and len(configuration_mismatches):
            write(
                "[Configuration Mismatches] (May Contribute To Differences Between Results)"
            )
            write("".join(configuration_mismatches))
            write("---")

        write("[Full Report]")
        write("".join(output_report_list))

    def formNotFoundStatus(benchmark, regression_results):
        for design in benchmark.keys():
            if design not in regression_results:
                benchmark[design]["Status"] = "NOT FOUND"

    formNotFoundStatus(benchmark, regression_results)

    if output_xlsx_file is None:
        return

    # Open an Excel workbook
    workbook = xlsxwriter.Workbook(output_xlsx_file)

    # Set up a format
    fail_format = workbook.add_format(properties={"bold": True, "font_color": "red"})
    pass_format = workbook.add_format(properties={"bold": True, "font_color": "green"})
    diff_format = workbook.add_format(properties={"font_color": "blue"})
    header_format = workbook.add_format(properties={"font_color": "gray"})
    benchmark_format = workbook.add_format(
        properties={"bold": True, "font_color": "navy"}
    )

    # Create a sheet
    worksheet = workbook.add_worksheet("diff")

    headerInfo = ["Owner", "design", "Status"]
    headerInfo.extend(critical_statistics)
    headerInfo.extend(note_worthy_statistics)
    headerInfo.extend(base_configs)

    # Write the headers
    for col_num, header in enumerate(headerInfo):
        worksheet.write(0, col_num, header, header_format)

    # Save the data from the OrderedDict into the excel sheet
    idx = 0
    while idx < len(benchmark):
        worksheet.write(idx * 2 + 1, 0, "Benchmark", benchmark_format)
        worksheet.write(idx * 2 + 2, 0, "User")

        design = str(list(benchmark.keys())[idx])
        if design not in regression_results:
            for col_num, header in enumerate(headerInfo):
                if header == "Owner":
                    worksheet.write(idx * 2 + 1, col_num, "Benchmark", benchmark_format)
                    worksheet.write(idx * 2 + 2, col_num, "User")
                    continue
                if header == "design":
                    worksheet.write(idx * 2 + 1, col_num, design)
                    worksheet.write(idx * 2 + 2, col_num, design)
                    continue
                worksheet.write(idx * 2 + 1, col_num, benchmark[design][header])
        else:
            for col_num, header in enumerate(headerInfo):
                if header == "Owner":
                    worksheet.write(idx * 2 + 1, col_num, "Benchmark", benchmark_format)
                    worksheet.write(idx * 2 + 2, col_num, "User")
                    continue
                if header == "design":
                    worksheet.write(idx * 2 + 1, col_num, design)
                    worksheet.write(idx * 2 + 2, col_num, design)
                    continue
                if header == "Status":
                    if benchmark[design][header] == "PASSED":
                        worksheet.write(
                            idx * 2 + 1, col_num, benchmark[design][header], pass_format
                        )
                        worksheet.write(
                            idx * 2 + 2,
                            col_num,
                            regression_results[design][header],
                            pass_format,
                        )
                    else:
                        worksheet.write(
                            idx * 2 + 1, col_num, benchmark[design][header], fail_format
                        )
                        worksheet.write(
                            idx * 2 + 2,
                            col_num,
                            regression_results[design][header],
                            fail_format,
                        )
                    continue
                if benchmark[design][header] != regression_results[design][header]:
                    if header in critical_statistics:
                        if not compare_vals(
                            benchmark[design][header],
                            regression_results[design][header],
                            header,
                        ):
                            worksheet.write(
                                idx * 2 + 1,
                                col_num,
                                benchmark[design][header],
                                fail_format,
                            )
                            worksheet.write(
                                idx * 2 + 2,
                                col_num,
                                regression_results[design][header],
                                fail_format,
                            )
                        else:
                            worksheet.write(
                                idx * 2 + 1,
                                col_num,
                                benchmark[design][header],
                                pass_format,
                            )
                            worksheet.write(
                                idx * 2 + 2,
                                col_num,
                                regression_results[design][header],
                                pass_format,
                            )
                    else:
                        worksheet.write(
                            idx * 2 + 1, col_num, benchmark[design][header], diff_format
                        )
                        worksheet.write(
                            idx * 2 + 2,
                            col_num,
                            regression_results[design][header],
                            diff_format,
                        )
                else:
                    worksheet.write(idx * 2 + 1, col_num, benchmark[design][header])
                    worksheet.write(
                        idx * 2 + 2, col_num, regression_results[design][header]
                    )
        idx += 1

    # Close the workbook
    workbook.close()


if __name__ == "__main__":
    cli()
