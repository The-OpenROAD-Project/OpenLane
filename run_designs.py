#!/usr/bin/env python3
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
import os
import re
import sys
import json
import click
import queue
import shutil
import logging
import datetime
import threading
import subprocess

from scripts.report.report import Report
from scripts.config.config import ConfigHandler, expand_matrix
from scripts.config.tcl import read_tcl_env
import scripts.utils.utils as utils

configuration_line_rx = re.compile(r"^\s*(\w+)\s*=\s*(.+)\s*$")


def get_design_name(config_file: str) -> str:
    vars = None
    if config_file.endswith(".tcl"):
        vars = read_tcl_env(config_file)
    elif config_file.endswith(".json"):
        vars = json.load(open(config_file))
    else:
        raise ValueError(f"{config_file}: Configuration files must end with .tcl/.json")

    name = vars.get("DESIGN_NAME")
    if name is None:
        raise ValueError(f"{config_file}: No DESIGN_NAME variable")
    return name


@click.command()
@click.option(
    "-c",
    "--config_file",
    default="config",
    help="(Base) configuration filename. Must inside the design directory. If an extension is omitted, both JSON and Tcl will be tried.",
)
@click.option(
    "-m", "--matrix", default=None, help="Path to configuration matrix JSON file"
)
@click.option("-t", "--tag", default=None, help="Tag for the log file")
@click.option(
    "-j", "--threads", default=1, type=int, help="Number of designs in parallel"
)
@click.option(
    "-p",
    "--configuration_parameters",
    default=None,
    help="File containing configuration parameters to append to report: You can also put 'all' to report all possible configurations",
)
@click.option(
    "-e",
    "--excluded_designs",
    default="",
    help="Exclude the following comma,delimited,designs from the run",
)
@click.option(
    "-b", "--benchmark", default=None, help="Benchmark report file to compare with."
)
@click.option(
    "-p",
    "--print_rem",
    default=0,
    help="If provided with a number >0, a list of remaining designs is printed every <print_rem> seconds.",
)
@click.option(
    "--enable_timestamp/--disable_timestamp",
    default=True,
    help="Enables or disables appending the timestamp to the file names and tags.",
)
@click.option(
    "--append_configurations/--dont_append_configurations",
    default=False,
    help="Append configuration parameters provided to the existing default printed configurations",
)
@click.option(
    "--delete/--retain",
    default=False,
    help="Delete the entire run directory upon completion, leaving only the final_report.txt file.",
)
@click.option(
    "--show_output/--hide_output",
    default=False,
    help="Enables showing the output from flow invocations into stdout. Will be forced to be false if more than one design is specified.",
)
@click.argument("designs", nargs=-1)
def cli(
    config_file,
    matrix,
    tag,
    threads,
    configuration_parameters,
    excluded_designs,
    benchmark,
    print_rem,
    enable_timestamp,
    append_configurations,
    delete,
    show_output,
    designs,
):
    """
    Run multiple designs in parallel, for testing or exploration.
    """

    if tag is None:
        if matrix is not None:
            tag = "matrix"
        else:
            tag = "run"

    designs = list(designs)
    excluded_designs = excluded_designs.split(",")

    for excluded_design in excluded_designs:
        if excluded_design in designs:
            designs.remove(excluded_design)

    show_log_output = show_output and (len(designs) == 1) and (matrix is None)

    if print_rem is not None and not show_log_output:
        if float(print_rem) > 0:
            mutex = threading.Lock()
            print_rem_time = float(print_rem)
        else:
            print_rem_time = None
    else:
        print_rem_time = None

    if print_rem_time is not None:
        rem_designs = dict.fromkeys(designs, 1)

    num_workers = threads

    config_name = os.path.splitext(config_file)[0]

    if matrix is not None:
        configuration_matrix_variables = []
        configuration_matrix_str = open(matrix).read()

        for line in configuration_matrix_str.splitlines():
            match = configuration_line_rx.match(line)
            if match is None:
                continue

            if "extra" in line:
                break

            configuration_matrix_variables.append(line[1])

        if len(configuration_matrix_variables) > 0:
            ConfigHandler.update_configuration_values(
                configuration_matrix_variables, True
            )

    if configuration_parameters is not None:
        if configuration_parameters == "all":
            ConfigHandler.update_configuration_values_to_all(append_configurations)
        else:
            try:
                with open(configuration_parameters, "r") as f:
                    configuration_parameters = f.read().split(",")
                    ConfigHandler.update_configuration_values(
                        configuration_parameters, append_configurations
                    )
            except OSError:
                print("Could not open/read file:", configuration_parameters)
                sys.exit()

    store_dir = ""
    report_file_name = ""
    if enable_timestamp:
        timestamp = datetime.datetime.now().strftime("%d_%m_%Y_%H_%M")
        store_dir = f"./regression_results/{tag}_{timestamp}"
        report_file_name = f"{store_dir}/{tag}_{timestamp}"
    else:
        store_dir = f"./regression_results/{tag}"
        report_file_name = f"{store_dir}/{tag}"

        utils.mkdirp(store_dir)

    log = logging.getLogger("log")
    log_formatter = logging.Formatter("%(asctime)s | %(message)s", "%Y-%m-%d %H:%M")
    handler1 = logging.FileHandler(f"{report_file_name}.log", "w")
    handler1.setFormatter(log_formatter)
    log.addHandler(handler1)
    handler2 = logging.StreamHandler()
    handler2.setFormatter(log_formatter)
    log.addHandler(handler2)
    log.setLevel(logging.INFO)

    report_log = logging.getLogger("report_log")
    report_formatter = logging.Formatter("%(message)s")
    report_handler = logging.FileHandler(f"{report_file_name}.csv", "w")
    report_handler.setFormatter(report_formatter)
    report_log.addHandler(report_handler)
    report_log.setLevel(logging.INFO)

    report_log.info(Report.get_header() + "," + ConfigHandler.get_header())

    allow_print_rem_designs = False

    def printRemDesignList():
        t = threading.Timer(print_rem_time, printRemDesignList)
        t.start()
        if allow_print_rem_designs:
            print("Remaining designs (design, # of times): ", rem_designs)
        if len(rem_designs) == 0:
            t.cancel()

    def rmDesignFromPrintList(design):
        if design in rem_designs.keys():
            mutex.acquire()
            try:
                rem_designs[design] -= 1
                if rem_designs[design] == 0:
                    rem_designs.pop(design)
            finally:
                mutex.release()

    if print_rem_time is not None:
        printRemDesignList()
        allow_print_rem_designs = True

    def update(status: str, design: str, message: str = None, error: bool = False):
        width = 10
        str = f"%-7s| %-{width}s" % (
            status,
            design[: width - 3] + "." * 3 if len(design) > width else design,
        )
        if message is not None:
            str += f" | {message}"

        if error:
            log.error(str)
        else:
            log.info(str)

    def resolve_config(conf_file, allow_tcl=False):
        if os.path.isfile(conf_file):
            return conf_file

        if conf_file.endswith(".tcl") or conf_file.endswith(".json"):
            update(
                "ERROR",
                design,
                f"Cannot run: {conf_file} not found",
                error=True,
            )
            return None

        tcl = f"{conf_file}.tcl"
        json = f"{conf_file}.json"
        if os.path.isfile(tcl):
            if allow_tcl:
                return tcl
            else:
                update(
                    "ERROR",
                    design,
                    "Matrix mode is incompatible with .tcl config files",
                    error=True,
                )
                return None
        elif os.path.isfile(json):
            return json
        else:
            update(
                "ERROR",
                design,
                f"Cannot run: No {config_file}.tcl/{config_file}.json found",
                error=True,
            )
            return None

    flow_failure_flag = False
    design_failure_flag = False

    def run_design(designs_queue):
        nonlocal design_failure_flag, flow_failure_flag
        while not designs_queue.empty():
            design, conf_file, design_name = designs_queue.get(timeout=3)  # 3s timeout
            tag = os.path.splitext(os.path.basename(conf_file))[0]
            run_path = utils.get_run_path(design=design, tag=tag)
            update("START", design, tag)
            command = [
                os.getenv("OPENLANE_ENTRY") or "./flow.tcl",
                "-design",
                design,
                "-tag",
                tag,
                "-config_file",
                conf_file,
                "-overwrite",
                "-run_hooks",
            ] + (["-verbose", "1"] if show_log_output else [])
            run_path_relative = os.path.relpath(run_path, ".")
            try:
                shutil.rmtree(run_path_relative)
            except FileNotFoundError:
                pass
            skip_rm_from_rems = False
            try:
                if show_log_output:
                    subprocess.check_call(command)
                else:
                    subprocess.check_output(command, stderr=subprocess.STDOUT)

                update(
                    "SUCCESS",
                    design,
                    "",
                )
            except subprocess.CalledProcessError as e:
                if print_rem_time is not None:
                    rmDesignFromPrintList(design)
                    skip_rm_from_rems = True
                log_path = f"{run_path_relative}/openlane.log"
                if os.path.isfile(log_path):
                    update(
                        "FAIL",
                        design,
                        f"Check {log_path}",
                        error=True,
                    )
                else:
                    update(
                        "FAIL",
                        design,
                        "OpenLane failed to start up:",
                        error=True,
                    )
                    print(e.stdout.decode("utf8"))

                design_failure_flag = True

            if print_rem_time is not None and not skip_rm_from_rems:
                rmDesignFromPrintList(design)

            try:
                params = ConfigHandler.get_config_for_run(None, design, tag)
                update("DONE", design, f"{tag}: Writing report...")

                report_str = Report(design, tag, design_name, params).get_report()
                report_log.info(report_str)

                with open(f"{run_path}/report.csv", "w") as report_file:
                    report_file.write(
                        Report.get_header() + "," + ",".join(params.keys())
                    )
                    report_file.write("\n")
                    report_file.write(report_str)
            except FileNotFoundError:
                pass

            if benchmark is not None:
                try:
                    update("DONE", design, "Comparing with benchmark results...")
                    subprocess.check_output(
                        [
                            "python3",
                            "./scripts/compare_regression_design.py",
                            "--output-report",
                            f"{report_file_name}.rpt.yml",
                            "--benchmark",
                            benchmark,
                            "--design",
                            design,
                            "--run-path",
                            run_path,
                            f"{report_file_name}.csv",
                        ],
                        stderr=subprocess.PIPE,
                    )
                except subprocess.CalledProcessError as e:
                    error_msg = e.stderr.decode("utf8")
                    update(
                        "ERROR",
                        design,
                        f"Failed to compare with benchmark: {error_msg}",
                    )
                    flow_failure_flag = True

            if delete:
                try:
                    update("DONE", design, "Deleting run directory...")
                    shutil.rmtree(run_path)
                    update("DONE", design, "Deleted run directory.")
                except FileNotFoundError:
                    pass
                except Exception:
                    update(
                        "ERROR", design, "Failed to delete run directory.", error=True
                    )
                    flow_failure_flag = True

    q = queue.Queue()
    total_runs = 0
    for design in designs:
        base_path = utils.get_design_path(design=design)
        if base_path is None:
            update("ALERT", design, "Not found, skipping", error=True)
            if print_rem_time is not None:
                if design in rem_designs.keys():
                    rem_designs.pop(design)
            continue

        conf_file = os.path.join(base_path, config_file)
        conf_file = resolve_config(conf_file, matrix is None)
        if conf_file is None:
            continue

        try:
            design_name = get_design_name(conf_file)
        except ValueError as e:
            update("ERROR", design, f"Cannot run: {e}", error=True)
            continue

        if matrix is not None:
            config_file_paths = expand_matrix(
                conf_file, matrix, os.path.join(base_path, f"{tag}_config")
            )

            total_runs += len(config_file_paths)
            if print_rem_time is not None:
                rem_designs[design] = total_runs

            for config_name in config_file_paths:
                q.put((design, config_name, design_name))
        else:
            conf_name, conf_ext = os.path.splitext(os.path.basename(conf_file))
            target_config = os.path.join(base_path, f"{tag}_{conf_name}{conf_ext}")
            shutil.copyfile(conf_file, target_config)

            q.put((design, target_config, design_name))

    workers = []
    for i in range(num_workers):
        workers.append(threading.Thread(target=run_design, args=(q,)))
        workers[i].start()

    for i in range(num_workers):
        while workers[i].is_alive():
            workers[i].join(100)
        log.info(f"Exiting thread {i}...")

    log.info("Getting top results...")
    subprocess.check_output(
        [
            "python3",
            "./scripts/report/get_best.py",
            "-i",
            report_handler.baseFilename,
            "-o",
            f"{report_file_name}_best.csv",
        ]
    )

    utils.add_computed_statistics(report_file_name + ".csv")
    utils.add_computed_statistics(report_file_name + "_best.csv")

    if benchmark is not None:
        log.info("Benchmarking...")
        full_benchmark_comp_cmd = [
            "python3",
            "./scripts/compare_regression_reports.py",
            "--no-full-benchmark",
            "--benchmark",
            benchmark,
            "--output-report",
            f"{report_file_name}.rpt",
            "--output-xlsx",
            f"{report_file_name}.rpt.xlsx",
            f"{report_file_name}.csv",
        ]
        subprocess.check_output(full_benchmark_comp_cmd)

    log.info("Done.")

    if design_failure_flag:
        exit(2)
    if flow_failure_flag:
        exit(1)


if __name__ == "__main__":
    cli()
