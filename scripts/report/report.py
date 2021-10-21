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
import sys
from typing import Iterable, Optional
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from utils.utils import *
from .get_file_name import get_name

def debug(*args, **kwargs):
    if os.getenv("REPORT_INFRASTRUCTURE_VERBOSE") == "1":
        print(*args, **kwargs)

def parse_to_report(input_log: str, output_report: str, start: str, end: Optional[str] = None):
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
                f.write(line)
            if line.strip() == start:
                started = True

        if not started:
            f.write("SKIPPED!")

class Artifact(object):
    def __init__(self, run_path: str, kind: str, step: str, filename: str, find_by_partial_match: bool = False):
        self.run_path = run_path
        self.kind = kind
        self.step = step

        self.pathname = os.path.join(self.run_path, self.kind, self.step)
        self.filename = filename

        self.path = get_name(self.pathname, self.filename, find_by_partial_match)

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
        return self.is_valid() and os.path.getsize(self.path) > 10 # >10 bytes is a magic number, yes. It was this way in the script I rewrote and I'm not a fan of shaking beehives.

    def log_to_report(self, report_name: str, start: str, end: Optional[str] = None):
        report_path = os.path.join(self.run_path, "reports", self.step, report_name)
        if not self.is_logtoreport_valid():
            with open(report_path, "w") as f:
                f.write(f"{self.step}:{self.filename} not found or empty.")
            return
        parse_to_report(self.path, report_path, start, end)

    def generate_reports(self, *args: Iterable[Iterable[str]]):
        for report in args:
            filename = report[0]
            start = report[1]
            end = None
            try:
                end = report[2]
            except:
                pass
            self.log_to_report(filename, start, end)


class Report(object):
    def __init__(self, design_path, tag, design_name, params, run_path=None):
        self.design_path = design_path
        self.design_name = design_name
        self.tag = tag
        self.current_directory = os.path.dirname(__file__)
        if run_path is None:
            run_path=get_run_path(design=design_path, tag=tag)
        self.run_path = run_path
        self.configuration = params
        self.raw_report = None
        self.formatted_report = None

    values = [
        'design',
        'design_name',
        'config',
        'flow_status',
        'total_runtime',
        'routed_runtime',
        'DIEAREA_mm^2',
        'CellPer_mm^2' ,
        'OpenDP_Util',
        'Peak_Memory_Usage_MB',
        'cell_count',
        'tritonRoute_violations',
        'Short_violations',
        'MetSpc_violations',
        'OffGrid_violations',
        'MinHole_violations',
        'Other_violations',
        'Magic_violations',
        'antenna_violations',
        'lvs_total_errors',
        'cvc_total_errors',
        'klayout_violations',
        'wire_length',
        'vias',
        'wns',
        'pl_wns',
        'optimized_wns',
        'fastroute_wns',
        'spef_wns',
        'tns',
        'pl_tns',
        'optimized_tns',
        'fastroute_tns' ,
        'spef_tns',
        'HPWL',
        'routing_layer1_pct',
        'routing_layer2_pct',
        'routing_layer3_pct',
        'routing_layer4_pct',
        'routing_layer5_pct',
        'routing_layer6_pct',
        'wires_count',
        'wire_bits',
        'public_wires_count',
        'public_wire_bits',
        'memories_count',
        'memory_bits',
        'processes_count',
        'cells_pre_abc',
        'AND',
        'DFF',
        'NAND',
        'NOR',
        'OR',
        'XOR',
        'XNOR',
        'MUX',
        'inputs',
        'outputs',
        'level',
        'EndCaps',
        'TapCells',
        'Diodes',
        'Total_Physical_Cells'
    ]
    
    @classmethod
    def get_header(Self):
        header = ','.join(Self.values)
        return header

    def reports_from_logs(self):
        rp = self.run_path

        cts_log = Artifact(rp, "logs", "cts", "cts.log")
        cts_log.generate_reports(
            ("cts.rpt", "check_report"),
            ("cts.timing.rpt", "timing_report"),
            ("cts.min_max.rpt", "min_max_report"),
            ("cts_wns.rpt", "wns_report"),
            ("cts_tns.rpt", "tns_report"),
            ("cts_clock_skew.rpt", "cts_clock_skew_report"),
        )

        routing_log = Artifact(rp, "logs", "routing", "fastroute.log")
        routing_log.generate_reports(
            ("fastroute.rpt", "check_report"),
            ("fastroute.timing.rpt", "timing_report"),
            ("fastroute.min_max.rpt", "min_max_report"),
            ("fastroute_wns.rpt", "wns_report"),
            ("fastroute_tns.rpt", "tns_report")
        )
        
        placement_log = Artifact(rp, "logs", "placement", "replace.log")
        placement_log.generate_reports(
            ("replace.rpt", "check_report"),
            ("replace.timing.rpt", "timing_report"),
            ("replace.min_max.rpt", "min_max_report"),
            ("replace_wns.rpt", "wns_report"),
            ("replace_tns.rpt", "tns_report")
        )

        sta_log = Artifact(rp, "logs", "synthesis", "opensta")
        sta_log.generate_reports(
            ("opensta.rpt", "check_report"),
            ("opensta.timing.rpt", "timing_report"),
            ("opensta.min_max.rpt", "min_max_report"),
            ("opensta_wns.rpt", "wns_report"),
            ("opensta_tns.rpt", "tns_report"),
            ("opensta.slew.rpt", "check_slew")
        )

        sta_post_resizer_log = Artifact(rp, "logs", "synthesis", "opensta_post_resizer")
        sta_post_resizer_log.generate_reports(
            ("opensta_post_resizer.rpt", "check_report"),
            ("opensta_post_resizer.timing.rpt", "timing_report"),
            ("opensta_post_resizer.min_max.rpt", "min_max_report"),
            ("opensta_post_resizer_wns.rpt", "wns_report"),
            ("opensta_post_resizer_tns.rpt", "tns_report"),
            ("opensta_post_resizer.slew.rpt", "check_slew")
        )

        sta_post_resizer_timing_log = Artifact(rp, "logs", "synthesis", "opensta_post_resizer_timing")
        sta_post_resizer_timing_log.generate_reports(
            ("opensta_post_resizer_timing.rpt", "check_report"),
            ("opensta_post_resizer_timing.timing.rpt", "timing_report"),
            ("opensta_post_resizer_timing.min_max.rpt", "min_max_report"),
            ("opensta_post_resizer_timing_wns.rpt", "wns_report"),
            ("opensta_post_resizer_timing_tns.rpt", "tns_report"),
            ("opensta_post_resizer_timing.slew.rpt", "check_slew")
        )

        sta_post_resizer_routing_timing_log = Artifact(rp, "logs", "synthesis", "opensta_post_resizer_routing_timing")
        sta_post_resizer_routing_timing_log.generate_reports(
            ("opensta_post_resizer_routing_timing.rpt", "check_report"),
            ("opensta_post_resizer_routing_timing.timing.rpt", "timing_report"),
            ("opensta_post_resizer_routing_timing.min_max.rpt", "min_max_report"),
            ("opensta_post_resizer_routing_timing_wns.rpt", "wns_report"),
            ("opensta_post_resizer_routing_timing_tns.rpt", "tns_report"),
            ("opensta_post_resizer_routing_timing.slew.rpt", "check_slew")
        )

        sta_spef_log = Artifact(rp, "logs", "synthesis", "opensta_spef")
        sta_spef_log.generate_reports(
            ("opensta_spef.rpt", "check_report"),
            ("opensta_spef.timing.rpt", "timing_report"),
            ("opensta_spef.min_max.rpt", "min_max_report"),
            ("opensta_spef_wns.rpt", "wns_report"),
            ("opensta_spef_tns.rpt", "tns_report"),
            ("opensta_spef.slew.rpt", "check_slew")
        )

        sta_spef_tt_log = Artifact(rp, "logs", "synthesis", "opensta_spef_tt")
        sta_spef_tt_log.generate_reports(
            ("opensta_spef_tt.rpt", "check_report"),
            ("opensta_spef_tt.timing.rpt", "timing_report"),
            ("opensta_spef_tt.min_max.rpt", "min_max_report"),
            ("opensta_spef_wns_tt.rpt", "wns_report"),
            ("opensta_spef_tns_tt.rpt", "tns_report"),
            ("opensta_spef_tt.slew.rpt", "check_slew")
        )

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
        try:
            total_runtime_content = open(os.path.join(rp, "reports", "total_runtime.txt")).read().strip()
            match = re.search(r"([\w ]+?)\s+for\s+(\w+)\/([\w\-\.]+)\s+in\s+(\w+)", total_runtime_content)
            if match is not None:
                flow_status = re.sub(r" ", "_", match[1])
                total_runtime = match[4]
        except Exception as e:
            print(f"Warning: failed to get extract runtime info for {self.design}/{self.tag}: {e}", file=sys.stderr)

        routed_runtime = -1
        try:
            routed_runtime_content = open(os.path.join(rp, "reports", "routed_runtime.txt")).read().strip()
            match = re.search(r"([\w ]+?)\s+for\s+(\w+)\/([\w\-]+)\s+in\s+(\w+)", routed_runtime_content)
            if match is not None:
                routed_runtime = match[4]
        except Exception as e:
            pass

        # Cell Count
        cell_count = -1
        yosys_report = Artifact(rp, 'reports', "synthesis", ".stat.rpt", True)
        yosys_report_content = yosys_report.get_content()
        if yosys_report_content is not None:
            match = re.search(r"Number of cells:\s*(\d+)", yosys_report_content)
            if match is not None:
                cell_count = int(match[1])

        # Die Area
        die_area = -1
        placed_def = Artifact(rp, 'results', "placement", f"{self.design_name}.placement.def")
        def_content = placed_def.get_content()
        if def_content is not None:
            match = re.search(r"DIEAREA\s*\(\s*(\d+)\s+(\d+)\s*\)\s*\(\s*(\d+)\s+(\d+)\s*\)", def_content)
            if match is not None:
                lx, ly, ux, uy = float(match[1]), float(match[2]), float(match[3]), float(match[4])
            
                die_area = ((ux - lx) / 1000) * ((uy - ly) / 1000)

                die_area /= 1000000 # To mm^2

        # Cells per micrometer
        cells_per_mm = - 1
        if cell_count != -1 and die_area != -1:
            cells_per_mm = cell_count / die_area

        # OpenDP Utilization and HPWL
        utilization = -1
        hpwl = -1 # Half Perimeter Wire Length?
        replace_log = Artifact(rp, 'logs', "placement", "replace.log")
        replace_log_content = replace_log.get_content()
        if replace_log_content is not None:
            match = re.search(r"Util\(%\):\s*([\d\.]+)", replace_log_content)

            if match is not None:
                utilization = float(match[1])

            match = re_get_last_capture(r"HPWL:\s*([\d\.]+)", replace_log_content)
            if match is not None:
                hpwl = float(match)

        # TritonRoute Logged Info Extraction
        tr_log = Artifact(rp, 'logs', "routing", "tritonRoute.log")
        tr_log_content = tr_log.get_content()
        
        tr_memory_peak = -1
        tr_violations = -1
        wire_length = -1
        vias = -1
        if tr_log_content is not None:
            match = re_get_last_capture(r"peak\s*=\s*([\d\.]+)", tr_log_content)
            if match is not None:
                tr_memory_peak = float(match)

            match = re_get_last_capture(r"Number of violations\s*=\s*(\d+)", tr_log_content)
            if match is not None:
                tr_violations = int(match)

            match = re_get_last_capture(r"Total wire length = ([\d\.]+)\s*\wm", tr_log_content)
            if match is not None:
                wire_length = int(match)

            match = re_get_last_capture(r"Total number of vias = (\d+)", tr_log_content)
            if match is not None:
                vias = int(match)

        # TritonRoute DRC Extraction
        tr_drc = Artifact(rp, 'reports', "routing", "tritonRoute.drc")
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
        magic_drc = Artifact(rp, 'reports', "magic", "magic.drc")
        magic_drc_content = magic_drc.get_content()

        magic_violations = -1
        if magic_drc_content is not None:
            # Magic DRC Content
            match = re.search(r"COUNT:\s*(\d+)", magic_drc_content)
            if match is not None:
                magic_violations_raw = int(match[1])

                # Not really sure why we do this
                magic_violations = (magic_violations_raw + 3) // 4

        
        # Klayout DRC Violations
        klayout_drc = Artifact(rp, 'reports', 'klayout', 'magic.lydrc', True)
        klayout_drc_content = klayout_drc.get_content()

        klayout_violations = -1
        if klayout_drc_content is not None:
            klayout_violations = 0
            for line in klayout_violations.split("\n"):
                if "<item>" in line:
                    klayout_violations += 1

        # Antenna Violations
        arc_antenna_report = Artifact(rp, 'reports', "routing", "antenna.rpt")
        aar_content = arc_antenna_report.get_content()

        magic_antenna_report = Artifact(rp, 'reports', "magic", "magic.antenna_violators.rpt")
        mar_content = magic_antenna_report.get_content()

        antenna_violations = -1
        if aar_content is not None:
            match = re.search(r"Number of pins violated:\s*(\d+)", aar_content)
            
            if match is not None:
                antenna_violations = int(match[1])
        elif mar_content is not None:
            # Old Magic-Based Check: Just Count The Lines
            antenna_violations = len(mar_content.split("\n"))

        # OpenSTA Extractions
        def sta_report_extraction(sta_report_filename: str, filter: str, kind='reports', step="synthesis"):
            value = -1
            report = Artifact(rp, kind, step, sta_report_filename)
            report_content = report.get_content()
            if report_content is not None:
                match = re.search(rf"{filter}\s+(-?[\d\.]+)", report_content)
                if match is not None:
                    value = float(match[1])
                else:
                    debug(f"Didn't find {filter} in {sta_report_filename}")
            else:
                debug(f"Can't find {sta_report_filename}")
            return value

        wns = sta_report_extraction("opensta_wns.rpt", 'wns')
        spef_wns = sta_report_extraction("opensta_spef_wns.rpt", 'wns')
        opt_wns = sta_report_extraction("sta_post_resizer_timing_wns.rpt", 'wns')
        pl_wns = sta_report_extraction("replace.log", 'wns', kind='logs', step="placement")
        fr_wns = sta_report_extraction("fastroute.log", 'wns', kind='logs', step="routing")

        tns = sta_report_extraction("opensta_tns.rpt", 'tns')
        spef_tns = sta_report_extraction("opensta_spef_tns.rpt", 'tns')
        opt_tns = sta_report_extraction("sta_post_resizer_timing_tns.rpt", 'tns')
        pl_tns = sta_report_extraction("replace.log", 'tns', kind='logs', step="placement")
        fr_tns = sta_report_extraction("fastroute.log", 'tns', kind='logs', step="routing")

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
            "\$_AND_",
            "\$_DFF_",
            "\$_NAND_",
            "\$_NOR_",
            "\$_OR",
            "\$_XOR",
            "\$_XNOR",
            "\$_MUX"
        ]

        yosys_log = Artifact(rp, 'logs', "synthesis", "yosys.log")
        yosys_log_content = yosys_log.get_content()

        yosys_metrics_values = []
        for metric in yosys_metrics:
            metric_value = -1
            if yosys_log_content is not None:
                metric_value = 0
                metric_name_escaped = re.escape(metric)
                
                match = re.search(rf"{metric_name_escaped}\s*(\d+)", yosys_log_content)

                if match is not None:
                    metric_value = int(match[1])
            yosys_metrics_values.append(metric_value)

        # ABC Info
        abc_i = -1
        abc_o = -1
        abc_level = -1

        if yosys_log_content is not None:
            match = re.search(r"ABC:\s*netlist\s*:\s*i\/o\s*=\s*(\d+)\/\s*(\d+)\s+lat\s*=\s*(\d+)\s+nd\s*=\s*(\d+)\s*edge\s*=\s*(\d+)\s*area\s*=\s*([\d\.]+)\s+delay\s*=\s*([\d\.]+)\s*lev\s*=\s*(\d+)", yosys_log_content)

            if match is not None:
                abc_i = match[1]
                abc_o = match[2]
                # We don't use most of the ones in the middle.
                abc_level = match[8]

        # Fastroute Layer Usage Percentages
        routing_log = Artifact(rp, 'logs', 'routing', 'fastroute.log')
        routing_log_content = routing_log.get_content()

        layer_usage = [-1] * 6 # 6 layers magic number, much?
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
        tapcell_log = Artifact(rp, 'logs', 'floorplan', "tapcell.log") # Also includes endcap info
        tapcell_log_content = tapcell_log.get_content()

        diode_log = Artifact(rp, 'logs', 'placement', 'diodes.log')
        diode_log_content = diode_log.get_content()

        tapcells, endcaps, diodes = 0, 0, 0
        if tapcell_log_content is not None:
            match = re.search(r"Inserted (\d+) end\s*caps\.", tapcell_log_content)

            if match is not None:
                endcaps = int(match[1])

            match = re.search(r"Inserted (\d+) tap\s*cells\.", tapcell_log_content)

            if match is not None:
                tapcells = int(match[1])

        if diode_log_content is not None:
            match = None
            if "inserted!" in diode_log_content:
                match = re.search(r"(\d+)\s+of\s+.+?\s+inserted!", diode_log_content)
            else:
                match = re.search(r"(\d+)\s+diodes\s+inserted\.", diode_log_content)
            if match is not None:
                diodes = int(match[1])

        filler_cells = tapcells + endcaps + diodes

        # LVS Total Errors
        lvs_report = Artifact(rp, 'results', "lvs", f"{self.design_name}.lvs_parsed.lef.log")
        lvs_report_content = lvs_report.get_content()
        
        lvs_total_errors = -1
        if lvs_report_content is not None:
            lvs_total_errors = 0
            match = re.search(r"Total errors\s*=\s*(\d+)", lvs_report_content)
            if match is not None:
                lvs_total_errors = int(match[1])

        # CVC Total Errors
        cvc_log = Artifact(rp, 'logs', "cvc", "cvc_screen.log")
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
            tr_memory_peak,
            cell_count,
            tr_violations,
            short_violations,
            metspc_violations,
            offgrid_violations,
            minhole_violations,
            other_violations,
            magic_violations,
            antenna_violations,
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
            endcaps,
            tapcells,
            diodes,
            filler_cells
        ]

    def get_report(self):
        row = [
            self.design_path,
            self.design_name,
            self.tag,
            *self.extract_all_values(),
            *self.configuration
        ]
        return ",".join([f"{cell}" for cell in row])