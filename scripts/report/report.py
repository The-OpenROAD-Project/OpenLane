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

from collections import defaultdict
import os
import re
import sys
import yaml
import fnmatch
from typing import Iterable, Optional, Dict

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from .get_file_name import get_name  # noqa E402
from config.config import ConfigHandler  # noqa E402
from utils.utils import get_run_path, mkdirp  # noqa E402


def debug(*args, **kwargs):
    if os.getenv("REPORT_INFRASTRUCTURE_VERBOSE") == "1":
        print(*args, **kwargs, file=sys.stderr)


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
        # >10 bytes is a magic number, yes. It was this way in the script I rewrote and I'm not a fan of shaking beehives.
        return self.is_valid() and os.path.getsize(self.path) > 10

    def log_to_report(self, report_name: str, locus: str):
        report_path = os.path.join(self.run_path, "reports", self.step, report_name)
        if not self.is_logtoreport_valid():
            debug(f"{self.step}:{self.filename} not found or empty.")
            return

        debug(f"Writing '{report_path}'...")
        start = locus
        end = f"{locus}_end"
        mkdirp(os.path.dirname(report_path))
        with open(report_path, "w") as f:
            started = False
            for line in open(self.path):
                if line.strip() == end:
                    break
                if started:
                    print(line, end="", file=f)
                if line.strip() == start:
                    started = True

            if not started:
                f.write("SKIPPED!")

    def generate_reports(self, *args: Iterable[Iterable[str]]):
        if (self.index or "") == "":
            self.index = "X"
        for report in args:
            filename = f"{self.index}-{report[0]}"
            locus = report[1]
            self.log_to_report(filename, locus)


class Report(object):
    def __init__(
        self,
        design_path: str,
        tag: str,
        design_name: str,
        params: Dict[str, str],
        run_path: Optional[str] = None,
    ):
        self.design_path = design_path
        self.design_name = design_name
        self.tag = tag
        self.current_directory = os.path.dirname(__file__)
        if run_path is None:
            run_path = get_run_path(design=design_path, tag=tag)
        self.run_path = run_path
        self.configuration = params.values()
        self.configuration_full = ConfigHandler.get_config_for_run(
            run_path, design_path, tag, full=True
        )
        self.raw_report = None
        self.formatted_report = None

    values = (
        [
            "design",
            "design_name",
            "config",
            "flow_status",
            "total_runtime",
            "routed_runtime",
            "DIEAREA_mm^2",
            "CellPer_mm^2",
            "OpenDP_Util",
            "Final_Util",
            "Peak_Memory_Usage_MB",
            "synth_cell_count",
            "tritonRoute_violations",
            "Short_violations",
            "MetSpc_violations",
            "OffGrid_violations",
            "MinHole_violations",
            "Other_violations",
            "Magic_violations",
            "pin_antenna_violations",
            "net_antenna_violations",
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
        ]
        + (["NOT"] if os.getenv("MORE_METRICS") else [])
        + [
            "inputs",
            "outputs",
            "level",
            "DecapCells",
            "WelltapCells",
            "DiodeCells",
            "FillCells",
            "NonPhysCells",
            "TotalCells",
        ]
        + [
            "CoreArea_um^2",
            "power_slowest_internal_uW",
            "power_slowest_switching_uW",
            "power_slowest_leakage_uW",
            "power_typical_internal_uW",
            "power_typical_switching_uW",
            "power_typical_leakage_uW",
            "power_fastest_internal_uW",
            "power_fastest_switching_uW",
            "power_fastest_leakage_uW",
            "critical_path_ns",
        ]
    )

    @classmethod
    def get_header(Self):
        header = ",".join(Self.values)
        return header

    def reports_from_logs(self):
        rp = self.run_path

        report_set = [
            ("_sta.checks.rpt", "checks_report"),
            ("_sta.min.rpt", "min_report"),
            ("_sta.max.rpt", "max_report"),
            ("_sta.skew.rpt", "skew_report"),
            ("_sta.summary.rpt", "summary_report"),
            ("_sta.power.rpt", "power_report"),
        ]

        for name, log in [
            ("syn", Artifact(rp, "logs", "synthesis", "sta.log")),
            ("cts", Artifact(rp, "logs", "cts", "cts_sta.log")),
            ("gpl", Artifact(rp, "logs", "placement", "gpl_sta.log")),
            ("dpl", Artifact(rp, "logs", "placement", "dpl_sta.log")),
            ("rsz_design", Artifact(rp, "logs", "routing", "rsz_design_sta.log")),
            ("rsz_timing", Artifact(rp, "logs", "routing", "rsz_timing_sta.log")),
            ("grt", Artifact(rp, "logs", "routing", "grt_sta.log")),
            ("rcx", Artifact(rp, "logs", "signoff", "rcx_sta.log")),
            ("mca/rcx_nom", Artifact(rp, "logs", "signoff", "rcx_mcsta.nom.log")),
            ("mca/rcx_min", Artifact(rp, "logs", "signoff", "rcx_mcsta.min.log")),
            ("mca/rcx_max", Artifact(rp, "logs", "signoff", "rcx_mcsta.max.log")),
        ]:
            generate_report_args = [
                (name + report_postfix, report_locus)
                for report_postfix, report_locus in report_set
            ]
            log.generate_reports(*generate_report_args)

    def extract_all_values(self):
        rp = self.run_path
        self.reports_from_logs()

        def re_get_last_capture(rx, string):
            matches = re.findall(rx, string)
            if len(matches) == 0:
                return None
            return matches[-1]

        # Runtime

        flow_status = "flow_exceptional_failure"
        total_runtime = -1
        routed_runtime = -1
        try:
            runtime_yaml_str = open(os.path.join(rp, "runtime.yaml")).read()
            yaml_docs = list(yaml.safe_load_all(runtime_yaml_str))
            if len(yaml_docs) != 2:
                raise Exception("Attempted to generate report on a non-finalized run.")

            routed_info, total_info = yaml_docs[1]

            flow_status = total_info["status"]
            total_runtime = total_info["runtime_ts"]
            routed_runtime = routed_info["runtime_ts"]
        except Exception as e:
            print(
                f"Failed to extract runtime info for {self.design_name}/{self.tag}: {e}",
                file=sys.stderr,
            )

        # Cell Count
        synth_cell_count = -1
        yosys_report = Artifact(rp, "reports", "synthesis", ".stat.rpt", True)
        yosys_report_content = yosys_report.get_content()
        if yosys_report_content is not None:
            match = re.search(r"Number of cells:\s*(\d+)", yosys_report_content)
            if match is not None:
                synth_cell_count = int(match[1])

        # Die Area
        die_area = -1
        placed_def = Artifact(rp, "results", "floorplan", f"{self.design_name}.def")
        def_content = placed_def.get_content()
        if def_content is not None:
            match = re.search(
                r"DIEAREA\s*\(\s*(\d+)\s+(\d+)\s*\)\s*\(\s*(\d+)\s+(\d+)\s*\)",
                def_content,
            )
            if match is not None:
                lx, ly, ux, uy = (
                    float(match[1]),
                    float(match[2]),
                    float(match[3]),
                    float(match[4]),
                )

                die_area = ((ux - lx) / 1000) * ((uy - ly) / 1000)

                die_area /= 1000000  # To mm^2

        # Initial FP Core Area
        core_area = -1
        floorplan_report = Artifact(
            rp, "reports", "floorplan", "initial_fp_core_area.rpt"
        )
        floorplan_report_content = floorplan_report.get_content()
        if floorplan_report_content is not None:
            match = re.search(
                r"\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s*",
                floorplan_report_content,
            )
            if match is not None:
                lx, ly, ux, uy = (
                    float(match[1]),
                    float(match[2]),
                    float(match[3]),
                    float(match[4]),
                )
                core_area = (ux - lx) * (uy - ly)  # Probably um^2

        # Power after parasitics-extraction, multi-corner STA
        power_multi_corner_sta = defaultdict(lambda: defaultdict(lambda: -1))
        power_report = Artifact(rp, "reports", "signoff", "rcx_sta.power.rpt")
        power_report_content = power_report.get_content()
        if power_report_content is not None:
            current_corner = None
            for line in power_report_content.splitlines():
                if "Slowest Corner" in line:
                    current_corner = "slowest"
                elif "Typical Corner" in line:
                    current_corner = "typical"
                elif "Fastest Corner" in line:
                    current_corner = "fastest"

                match = re.match(
                    r"^Total\s+([\d.Ee\-+]+)\s+([\d.Ee\-+]+)\s+([\d.Ee\-+]+)\s+([\d.Ee\-+]+).*$",
                    line,
                )
                if match:
                    power_multi_corner_sta[current_corner].update(
                        {
                            "internal": float(match[1]),
                            "switching": float(match[2]),
                            "leakage": float(match[3]),
                            "total": float(match[4]),
                        }
                    )
        power_metrics_values = [
            power_multi_corner_sta["slowest"]["internal"],
            power_multi_corner_sta["slowest"]["switching"],
            power_multi_corner_sta["slowest"]["leakage"],
            power_multi_corner_sta["typical"]["internal"],
            power_multi_corner_sta["typical"]["switching"],
            power_multi_corner_sta["typical"]["leakage"],
            power_multi_corner_sta["fastest"]["internal"],
            power_multi_corner_sta["fastest"]["switching"],
            power_multi_corner_sta["fastest"]["leakage"],
        ]

        # Critical path
        critical_path_ns = -1
        critical_path_report = Artifact(rp, "reports", "signoff", "rcx_sta.max.rpt")
        critical_path_report_content = critical_path_report.get_content()
        if critical_path_report_content is not None:
            start = 0
            end = None
            for line in critical_path_report_content.splitlines():
                match = re.search(r"([\-.\d]+)[\sv^]+input external delay", line)
                if match:
                    start = float(match[1])
                    continue
                match = re.search(r"([\-.\d]+)[\sv^]+data arrival time", line)
                if match:
                    end = float(match[1])
                    break
            if end is not None:
                critical_path_ns = end - start

        # OpenDP Utilization and HPWL
        utilization = -1
        hpwl = -1  # Half Perimeter Wire Length?
        global_placement_log = Artifact(rp, "logs", "placement", "global.log")
        global_log_content = global_placement_log.get_content()
        if global_log_content is not None:
            match = re.search(r"Util\(%\):\s*([\d\.]+)", global_log_content)

            if match is not None:
                utilization = float(match[1])

            match = re_get_last_capture(r"HPWL:\s*([\d\.]+)", global_log_content)
            if match is not None:
                hpwl = float(match)

        final_utilization = -1
        # ./reports/signoff/26-rcx_sta.area.rpt
        final_utilization_report = Artifact(
            rp, "reports", "signoff", "rcx_sta.area.rpt"
        )
        final_utilization_content = final_utilization_report.get_content()
        if final_utilization_content is not None:
            match = re.search(r"\s+([\d]+\.*[\d]*)%", final_utilization_content)
            if match is not None:
                final_utilization = float(match[1])

        # TritonRoute Logged Info Extraction
        tr_log = Artifact(rp, "logs", "routing", "detailed.log")
        tr_log_content = tr_log.get_content()

        tr_memory_peak = -1
        tr_violations = -1
        wire_length = -1
        vias = -1
        if tr_log_content is not None:
            match = re_get_last_capture(r"peak\s*=\s*([\d\.]+)", tr_log_content)
            if match is not None:
                tr_memory_peak = float(match)

            match = re_get_last_capture(
                r"Number of violations\s*=\s*(\d+)", tr_log_content
            )
            if match is not None:
                tr_violations = int(match)

            match = re_get_last_capture(
                r"Total wire length = ([\d\.]+)\s*\wm", tr_log_content
            )
            if match is not None:
                wire_length = int(match)

            match = re_get_last_capture(r"Total number of vias = (\d+)", tr_log_content)
            if match is not None:
                vias = int(match)

        # TritonRoute DRC Extraction
        tr_drc = Artifact(rp, "reports", "routing", "drt.drc")
        tr_drc_content = tr_drc.get_content()

        other_violations = tr_violations
        short_violations = -1
        metspc_violations = -1
        offgrid_violations = -1
        minhole_violations = -1
        if tr_drc_content is not None:
            short_violations = 0
            metspc_violations = 0
            offgrid_violations = 0
            minhole_violations = 0
            for line in tr_drc_content.split("\n"):
                if "Short" in line:
                    short_violations += 1
                    other_violations -= 1
                if "MetSpc" in line:
                    metspc_violations += 1
                    other_violations -= 1
                if "OffGrid" in line:
                    offgrid_violations += 1
                    other_violations -= 1
                if "MinHole" in line:
                    minhole_violations += 1
                    other_violations -= 1

        # Magic Violations
        magic_drc = Artifact(rp, "reports", "signoff", "drc.rpt")
        magic_drc_content = magic_drc.get_content()

        magic_violations = -1
        if magic_drc_content is not None:
            # Magic DRC Content
            match = re.search(r"COUNT:\s*(\d+)", magic_drc_content)
            if match is not None:
                magic_violations_raw = int(match[1])

                # Not really sure why we do this
                magic_violations = (magic_violations_raw + 3) // 4

        # KLayout DRC Violations
        klayout_drc = Artifact(rp, "reports", "signoff", "magic.lydrc", True)
        klayout_drc_content = klayout_drc.get_content()

        klayout_violations = -1
        if klayout_drc_content is not None:
            klayout_violations = 0
            for line in klayout_drc_content.split("\n"):
                if "<item>" in line:
                    klayout_violations += 1

        # Antenna Violations
        arc_antenna_report = Artifact(rp, "logs", "signoff", "arc.log")
        aar_content = arc_antenna_report.get_content()

        pin_antenna_violations = -1
        net_antenna_violations = -1
        if aar_content is not None:
            net_violations = re.search(r"Found (\d+) net violations", aar_content)
            pin_violations = re.search(r"Found (\d+) pin violations", aar_content)

            pin_antenna_violations = (
                int(pin_violations[1]) if pin_violations is not None else 0
            )
            net_antenna_violations = (
                int(net_violations[1]) if net_violations is not None else 0
            )
        else:
            # Old Magic-Based Check: Just Count The Lines
            magic_antenna_report = Artifact(
                rp, "reports", "signoff", "antenna_violators.rpt"
            )
            mar_content = magic_antenna_report.get_content()

            if mar_content is not None:
                net_antenna_violations = len(mar_content.split("\n"))

        # STA Report Extractions
        def sta_report_extraction(
            sta_report_filename: str, filter: str, kind="reports", step="synthesis"
        ):
            value = -1
            report = Artifact(rp, kind, step, sta_report_filename)
            report_content = report.get_content()
            if report_content is not None:
                match = re.search(rf"{filter}\s+(-?[\d\.]+)", report_content)
                if match is not None:
                    value = float(match[1])
                else:
                    debug(
                        f"Didn't find {filter} in {kind}/{step}/{sta_report_filename}"
                    )
            else:
                debug(f"Can't find {kind}/{step}/{sta_report_filename}")
            return value

        wns = sta_report_extraction("syn_sta.summary.rpt", "wns", step="synthesis")
        spef_wns = sta_report_extraction("rcx_sta.summary.rpt", "wns", step="signoff")
        opt_wns = sta_report_extraction("rt_rsz_sta.summary.rpt", "wns", step="routing")
        pl_wns = sta_report_extraction(
            "global.log", "wns", kind="logs", step="placement"
        )
        fr_wns = sta_report_extraction("global.log", "wns", kind="logs", step="routing")

        tns = sta_report_extraction("syn_sta.summary.rpt", "tns", step="synthesis")
        spef_tns = sta_report_extraction("rcx_sta.summary.rpt", "tns", step="signoff")
        opt_tns = sta_report_extraction("rt_rsz_sta.summary.rpt", "tns", step="routing")
        pl_tns = sta_report_extraction(
            "global.log", "tns", kind="logs", step="placement"
        )
        fr_tns = sta_report_extraction("global.log", "tns", kind="logs", step="routing")

        # Yosys Metrics
        yosys_metrics = [
            "Number of wires:",
            "Number of wire bits:",
            "Number of public wires:",
            "Number of public wire bits:",
            "Number of memories:",
            "Number of memory bits:",
            "Number of processes:",
            "Number of cells:",
            "$_AND_",
            "$_DFF_",
            "$_NAND_",
            "$_NOR_",
            "$_OR_",
            "$_XOR_",
            "$_XNOR_",
            "$_MUX_",
        ]

        if os.getenv("MORE_METRICS"):
            yosys_metrics.append("$_NOT_")

        yosys_log = Artifact(rp, "logs", "synthesis", "synthesis.log")
        yosys_log_content = yosys_log.get_content()

        yosys_metrics_values = []
        for metric in yosys_metrics:
            metric_value = -1
            if yosys_log_content is not None:
                metric_value = 0
                metric_name_escaped = re.escape(metric)

                if metric == "$_DFF_":
                    metric_name_escaped = r"\$_DFF_(?:\w+)?"

                match = re.search(rf"{metric_name_escaped}\s+(\d+)", yosys_log_content)

                if match is not None:
                    metric_value = int(match[1])
            yosys_metrics_values.append(metric_value)

        # ABC Info
        abc_i = -1
        abc_o = -1
        abc_level = -1

        if yosys_log_content is not None:
            match = re.search(
                r"ABC:\s*netlist\s*:\s*i\/o\s*=\s*(\d+)\/\s*(\d+)\s+lat\s*=\s*(\d+)\s+nd\s*=\s*(\d+)\s*edge\s*=\s*(\d+)\s*area\s*=\s*([\d\.]+)\s+delay\s*=\s*([\d\.]+)\s*lev\s*=\s*(\d+)",
                yosys_log_content,
            )

            if match is not None:
                abc_i = match[1]
                abc_o = match[2]
                # We don't use most of the ones in the middle.
                abc_level = match[8]

        # Fastroute Layer Usage Percentages
        routing_log = Artifact(rp, "logs", "routing", "global.log")
        routing_log_content = routing_log.get_content()

        # MAGIC NUMBER ALERT
        layer_usage = [-1] * 6
        if routing_log_content is not None:
            routing_log_lines = routing_log_content.split("\n")

            final_congestion_report_start_line = None
            for i, line in enumerate(routing_log_lines):
                if "Final congestion report" in line:
                    final_congestion_report_start_line = i
                    break

            if final_congestion_report_start_line is not None:
                start = final_congestion_report_start_line
                header = start + 1
                separator = header + 1
                layer_start = separator + 1
                for i in range(6):
                    line = routing_log_lines[layer_start + i]
                    match = re.search(r"([\d\.]+)%", line)
                    if match is not None:
                        layer_usage[i] = float(match[1])

        # Process Filler Cells
        # Also includes endcap info
        def count_cells(cell_wildcards, def_content):
            def_content_split = def_content.split()
            count = 0
            for cell_wildcard in cell_wildcards:
                count += len(fnmatch.filter(def_content_split, cell_wildcard))

            return count

        design_netlist = Artifact(rp, "results", "final/def", f"{self.design_name}.def")
        diode_count = -1
        well_tap_count = -1
        decap_count = -1
        filler_count = -1
        non_phys_count = -1
        total_cells_count = -1

        design_netlist_content = design_netlist.get_content()
        diode_cell_names = self.configuration_full.get("DIODE_CELL", "").split()
        fill_cell_names = self.configuration_full.get("FILL_CELL", "").split()
        well_tap_cell_names = self.configuration_full.get("FP_WELLTAP_CELL", "").split()
        decap_cell_names = self.configuration_full.get("DECAP_CELL", "").split()
        if design_netlist_content is not None:
            diode_count = count_cells(diode_cell_names, design_netlist_content)
            well_tap_count = count_cells(well_tap_cell_names, design_netlist_content)
            decap_count = count_cells(decap_cell_names, design_netlist_content)
            filler_count = count_cells(fill_cell_names, design_netlist_content)
            all_cells_count_match = re.search(
                r"COMPONENTS\s+([\d]+)\s+;", design_netlist_content
            )
            if all_cells_count_match is not None:
                total_cells_count = int(all_cells_count_match[1])
                non_phys_count = (
                    total_cells_count
                    - decap_count
                    - well_tap_count
                    - diode_count
                    - filler_count
                )

        # Cells per micrometer
        cells_per_mm = -1
        if non_phys_count != -1 and die_area != -1:
            cells_per_mm = non_phys_count / die_area

        # LVS Total Errors
        lvs_report = Artifact(rp, "reports", "signoff", f"{self.design_name}.lvs.rpt")
        lvs_report_content = lvs_report.get_content()

        lvs_total_errors = -1
        if lvs_report_content is not None:
            lvs_total_errors = 0
            match = re.search(r"Total errors\s*=\s*(\d+)", lvs_report_content)
            if match is not None:
                lvs_total_errors = int(match[1])

        # CVC Total Errors
        cvc_log = Artifact(rp, "logs", "signoff", "erc_screen.log")
        cvc_log_content = cvc_log.get_content()

        cvc_total_errors = -1
        if cvc_log_content is not None:
            match = re.search(r"CVC:\s*Total:\s*(\d+)", cvc_log_content)
            if match is not None:
                cvc_total_errors = int(match[1])

        return [
            flow_status,
            total_runtime,
            routed_runtime,
            die_area,
            cells_per_mm,
            utilization,
            final_utilization,
            tr_memory_peak,
            synth_cell_count,
            tr_violations,
            short_violations,
            metspc_violations,
            offgrid_violations,
            minhole_violations,
            other_violations,
            magic_violations,
            pin_antenna_violations,
            net_antenna_violations,
            lvs_total_errors,
            cvc_total_errors,
            klayout_violations,
            wire_length,
            vias,
            wns,
            pl_wns,
            opt_wns,
            fr_wns,
            spef_wns,
            tns,
            pl_tns,
            opt_tns,
            fr_tns,
            spef_tns,
            hpwl,
            *layer_usage,
            *yosys_metrics_values,
            abc_i,
            abc_o,
            abc_level,
            decap_count,
            well_tap_count,
            diode_count,
            filler_count,
            non_phys_count,
            total_cells_count,
            core_area,
            *power_metrics_values,
            critical_path_ns,
        ]

    def get_report(self):
        row = [
            self.design_path,
            self.design_name,
            self.tag,
            *self.extract_all_values(),
            *self.configuration,
        ]
        return ",".join([f"{cell}" for cell in row])
