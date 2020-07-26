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
    def __init__(self, design, tag, params):
        self.design = design
        self.tag = tag
        self.current_directory = os.path.dirname(__file__)
        self.report_script = os.path.join(self.current_directory, 'report.sh')
        self.report_command = '{script} {path} {design}'.format(
                script=self.report_script,
                path=get_run_path(design=design, tag=tag),
                design=self.design
            )
        self.configuration = params
        self.raw_report = None
        self.formatted_report = None

    values = ['design', 'config', 'runtime','DIEAREA_mm^2','CellPer_mm^2' ,'OpenDP_Util','Peak_Memory_Usage_MB','cell_count', 'tritonRoute_violations',
            'Short_violations','MetSpc_violations','OffGrid_violations','MinHole_violations','Other_violations' ,
            'Magic_violations', 'antenna_violations' ,'wire_length', 'vias', 'wns', 'HPWL', 'wires_count','wire_bits','public_wires_count',
            'public_wire_bits','memories_count','memory_bits', 'processes_count' ,'cells_pre_abc', 'AND','DFF','NAND',
            'NOR' ,'OR', 'XOR', 'XNOR', 'MUX','inputs', 'outputs', 'level','EndCaps', 'TapCells', 'Diodes', 'Total_Physical_Cells']


    @classmethod
    def get_header(cls):
        header = ','.join(cls.values)
        return header


    def run_script(self):
        return subprocess.check_output(self.report_command.split()).decode(sys.getfilesystemencoding())

    def format_report(self):
        cellperumIdx = self.values.index('CellPer_mm^2') - 2
        dieareaIdx = self.values.index('DIEAREA_mm^2') - 2
        cell_countIdx = self.values.index('cell_count') - 2
        splited_report = self.raw_report.split()
        splited_report[dieareaIdx] = str(float(splited_report[dieareaIdx])/1000000) 
        splited_report[cellperumIdx] = str(int(splited_report[cell_countIdx])/float(splited_report[dieareaIdx]))
        report = ",".join(splited_report)
        report = "{design},{tag},".format(
                design=self.design,
                tag=self.tag
                ) + report + "," + ",".join(self.configuration)

        return report


    def get_report(self):
        self.raw_report = self.run_script()
        self.formatted_report = self.format_report()

        return self.formatted_report


if __name__ == '__main__':
    report = Report('test_design', 'test_tag', 'test_config')
    print(Report.get_header())
