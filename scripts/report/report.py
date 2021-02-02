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

import os
import subprocess
import sys
from ..utils.utils import *


class Report:
    def __init__(self, design, tag, design_name,params,run_path=None):
        self.design = design
        self.design_name=design_name
        self.tag = tag
        self.current_directory = os.path.dirname(__file__)
        self.report_script = os.path.join(self.current_directory, 'report.sh')
        if run_path is None:
            run_path=get_run_path(design=design, tag=tag)
        self.report_command = '{script} {path} {design_name} {script_dir}'.format(
                script=self.report_script,
                path=run_path,
                design_name=self.design_name,
                script_dir=self.current_directory
            )
        self.configuration = params
        self.raw_report = None
        self.formatted_report = None

    values = ['design', 'design_name','config', 'flow_status', 'total_runtime', 'routed_runtime','DIEAREA_mm^2','CellPer_mm^2' ,'OpenDP_Util','Peak_Memory_Usage_MB','cell_count',
            'tritonRoute_violations', 'Short_violations','MetSpc_violations','OffGrid_violations','MinHole_violations','Other_violations',
            'Magic_violations', 'antenna_violations', 'lvs_total_errors', 'cvc_total_errors', 'klayout_violations', 'wire_length', 'vias',
            'wns', 'pl_wns', 'optimized_wns', 'fastroute_wns', 'spef_wns', 'tns', 'pl_tns', 'optimized_tns', 'fastroute_tns' , 'spef_tns',
            'HPWL', 'routing_layer1_pct', 'routing_layer2_pct', 'routing_layer3_pct', 'routing_layer4_pct', 'routing_layer5_pct', 'routing_layer6_pct',
            'wires_count', 'wire_bits', 'public_wires_count', 'public_wire_bits','memories_count','memory_bits', 'processes_count' ,'cells_pre_abc',
            'AND','DFF', 'NAND', 'NOR' ,'OR', 'XOR', 'XNOR', 'MUX','inputs', 'outputs', 'level','EndCaps', 'TapCells', 'Diodes', 'Total_Physical_Cells']


    @classmethod
    def get_header(cls):
        header = ','.join(cls.values)
        return header


    def run_script(self):
        return subprocess.check_output(self.report_command.split()).decode(sys.getfilesystemencoding())

    def format_report(self):
        prefixIdx = self.values.index('config')+1
        cellperumIdx = self.values.index('CellPer_mm^2') - prefixIdx
        dieareaIdx = self.values.index('DIEAREA_mm^2') - prefixIdx
        cell_countIdx = self.values.index('cell_count') - prefixIdx
        splited_report = self.raw_report.split()
        splited_report[dieareaIdx] = str(float(splited_report[dieareaIdx])/1000000)
        splited_report[cellperumIdx] = str(int(splited_report[cell_countIdx])/float(splited_report[dieareaIdx]))
        report = ",".join(splited_report)
        report = "{design},{design_name},{tag},".format(
                design=self.design,
                design_name=self.design_name,
                tag=self.tag
                ) + report + "," + ",".join(self.configuration)

        return report


    def get_report(self):
        self.raw_report = self.run_script()
        self.formatted_report = self.format_report()

        return self.formatted_report


if __name__ == '__main__':
    report = Report('test_design', 'test_tag','test_design_name' ,'test_config')
    print(Report.get_header())
