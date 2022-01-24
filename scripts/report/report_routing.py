# Copyright 2021 The University of Michigan
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
import sys
from typing import Iterable, Optional

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from utils.utils import get_run_path  # noqa E402
from .get_file_name import get_name  # noqa E402


def debug(*args, **kwargs):
    if os.getenv("REPORT_INFRASTRUCTURE_VERBOSE") == "1":
        print(*args, **kwargs)


def parse_to_report(
    input_log: str, output_report: str, start: str, end: Optional[str] = None
):
    """
    Parses a log in the format
    START_MARKER
    data
    END_MARKER
    to a report file.
    """
    if end is None:
        end = f"{start}_end"

    log_lines = open(input_log).read().split("\n")
    with open(output_report, "w") as f:
        started = False

        for line in log_lines:
            if line.strip() == end:
                break
            if started:
                f.write(line + "\n")
            if line.strip() == start:
                started = True

        if not started:
            f.write("SKIPPED!")


class Artifact(object):
    def __init__(
        self,
        run_path: str,
        kind: str,
        step: str,
        filename: str,
        find_by_partial_match: bool = False,
    ):
        self.run_path = run_path
        self.kind = kind
        self.step = step

        self.pathname = os.path.join(self.run_path, self.kind, self.step)
        self.filename = filename

        self.index, self.path = get_name(
            self.pathname, self.filename, find_by_partial_match
        )

        if self.is_valid():
            debug(f"Resolved {kind}, {step}, {filename} to {self.path}")
        else:
            debug(f"Failed to resolve {kind}, {step}, {filename}")

    def is_valid(self) -> bool:
        valid = os.path.exists(self.path) and os.path.isfile(self.path)
        return valid

    def get_content(self) -> Optional[str]:
        if not self.is_valid():
            return None
        return open(self.path).read()

    def is_logtoreport_valid(self) -> bool:
        return self.is_valid() and os.path.getsize(self.path) > 10

    def log_to_report(self, report_name: str, start: str, end: Optional[str] = None):
        report_path = os.path.join(self.run_path, "reports", self.step, report_name)
        if not self.is_logtoreport_valid():
            with open(report_path, "w") as f:
                f.write(f"{self.step}:{self.filename} not found or empty.")
            return
        parse_to_report(self.path, report_path, start, end)

    def generate_reports(self, *args: Iterable[Iterable[str]]):
        for report in args:
            filename = f"{self.index}-{report[0]}"
            start = report[1]
            end = None
            try:
                end = report[2]
            except Exception:
                pass
            self.log_to_report(filename, start, end)


class Report(object):
    def __init__(self, design_path, tag, design_name, params, run_path=None):
        self.design_path = design_path
        self.design_name = design_name
        self.tag = tag
        self.current_directory = os.path.dirname(__file__)
        if run_path is None:
            run_path = get_run_path(design=design_path, tag=tag)
        self.run_path = run_path
        self.configuration = params
        self.raw_report = None
        self.formatted_report = None

    values = [
        "design",
        "design_name",
        "config",
        "flow_status",
        "total_runtime",
        "routed_runtime",
        "DIEAREA_mm^2",
        "CellPer_mm^2",
        "OpenDP_Util",
        "Peak_Memory_Usage_MB",
        "cell_count",
        "tritonRoute_violations",
        "Short_violations",
        "MetSpc_violations",
        "OffGrid_violations",
        "MinHole_violations",
        "Other_violations",
        "Magic_violations",
        "antenna_violations",
        "lvs_total_errors",
        "cvc_total_errors",
        "klayout_violations",
        "wire_length",
        "vias",
        "wns",
        "pl_wns",
        "optimized_wns",
        "fastroute_wns",
        "spef_wns",
        "tns",
        "pl_tns",
        "optimized_tns",
        "fastroute_tns",
        "spef_tns",
        "HPWL",
        "routing_layer1_pct",
        "routing_layer2_pct",
        "routing_layer3_pct",
        "routing_layer4_pct",
        "routing_layer5_pct",
        "routing_layer6_pct",
        "wires_count",
        "wire_bits",
        "public_wires_count",
        "public_wire_bits",
        "memories_count",
        "memory_bits",
        "processes_count",
        "cells_pre_abc",
        "AND",
        "DFF",
        "NAND",
        "NOR",
        "OR",
        "XOR",
        "XNOR",
        "MUX",
        "inputs",
        "outputs",
        "level",
        "EndCaps",
        "TapCells",
        "Diodes",
        "Total_Physical_Cells",
    ]

    @classmethod
    def get_header(Self):
        header = ",".join(Self.values)
        return header

    def reports_from_logs(self):
        rp = self.run_path

        routing_log = Artifact(rp, "logs", "routing", "fastroute.log")
        routing_log.generate_reports(
            ("fastroute_sta.rpt", "check_report"),
            ("fastroute_sta.clock_skew.rpt", "clock_skew"),
            ("fastroute_sta.min.rpt", "min_report"),
            ("fastroute_sta.max.rpt", "max_report"),
            ("fastroute_sta.wns.rpt", "wns_report"),
            ("fastroute_sta.tns.rpt", "tns_report"),
        )

        sta_spef_log = Artifact(rp, "logs", "routing", "spef_extraction_sta")
        sta_spef_log.generate_reports(
            ("spef_extraction_sta.rpt", "check_report"),
            ("spef_extraction_sta.min.rpt", "min_report"),
            ("spef_extraction_sta.max.rpt", "max_report"),
            ("spef_extraction_sta.wns.rpt", "wns_report"),
            ("spef_extraction_sta.tns.rpt", "tns_report"),
            ("spef_extraction_sta.slew.rpt", "check_slew"),
            ("spef_extraction_sta.worst_slack.rpt", "worst_slack"),
            ("spef_extraction_sta.clock_skew.rpt", "clock_skew"),
            ("spef_extraction_sta.power.rpt", "power_report"),
            ("spef_extraction_sta.area.rpt", "area_report"),
        )

        sta_spef_multi_corner_log = Artifact(
            rp, "logs", "routing", "spef_extraction_multi_corner_sta"
        )
        sta_spef_multi_corner_log.generate_reports(
            ("spef_extraction_multi_corner_sta.rpt", "check_report"),
            ("spef_extraction_multi_corner_sta.min.rpt", "min_report"),
            ("spef_extraction_multi_corner_sta.max.rpt", "max_report"),
            ("spef_extraction_multi_corner_sta.wns.rpt", "wns_report"),
            ("spef_extraction_multi_corner_sta.tns.rpt", "tns_report"),
            ("spef_extraction_multi_corner_sta.slew.rpt", "check_slew"),
            ("spef_extraction_multi_corner_sta.worst_slack.rpt", "worst_slack"),
            ("spef_extraction_multi_corner_sta.clock_skew.rpt", "clock_skew"),
            ("spef_extraction_multi_corner_sta.power.rpt", "power_report"),
            ("spef_extraction_multi_corner_sta.area.rpt", "area_report"),
        )
