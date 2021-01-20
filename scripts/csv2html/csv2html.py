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

import csv
import os
import argparse
import pathlib
import pandas as pd
from jinja2 import Environment, PackageLoader, select_autoescape

parser = argparse.ArgumentParser(
    description='Takes an input csv report from the run_designs.py script and creates an html summary for it')

parser.add_argument('--csv_file', '-i',required=True,
                   help='The input csv file')

parser.add_argument('--html_file', '-o', required=True,
                    help='The output html file')

args = parser.parse_args()
csv_file = args.csv_file
html_file = args.html_file

env = Environment(
    loader=PackageLoader('csv2html', 'templates'),
    autoescape=select_autoescape('html')
)

template = env.get_template('main.html')


def get_static_folder(file_name):
    p = pathlib.Path('.')
    return pathlib.PosixPath(str(p) +'/scripts/csv2html/static/'+str(file_name))


def read_csv(csv_file):
    csv_file_opener = open(csv_file, 'r')
    csv_data = csv.reader(csv_file_opener)
    csv_headers = next(csv_data)
    return csv_headers, csv_data


def create_output_html(csv_file, html_file):
    colms = ['design','config','total_runtime','DIEAREA_mm^2','OpenDP_Util','cell_count','tritonRoute_violations',
            'Short_violations',	'Magic_violations', 'antenna_violations', 'wns', 'CLOCK_PERIOD']

    allData = pd.read_csv(csv_file, error_bad_lines=False)
    dataFrame =  pd.DataFrame(data=allData)
    usedData = dataFrame[colms]
    usedData.to_csv(csv_file.split(".csv")[0]+"_tmp_report.csv")

    headers, data = read_csv(csv_file.split(".csv")[0]+"_tmp_report.csv")

    with open(html_file, 'w') as output:
        static_file = 'style.css'
        output.write(template.render(headers=headers, rows=data, style_url=get_static_folder(static_file).resolve()))

    os.remove(csv_file.split(".csv")[0]+"_tmp_report.csv")



if __name__ == '__main__':
    create_output_html(csv_file, html_file)
