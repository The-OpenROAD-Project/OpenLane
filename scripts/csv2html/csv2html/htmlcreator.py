"""
create html file
"""
import csv
import os
import pandas as pd
from jinja2 import Environment, PackageLoader, select_autoescape

from .utils import get_static_folder

__all__ = ['create_output_html']

env = Environment(
    loader=PackageLoader('csv2html', 'templates'),
    autoescape=select_autoescape('html')
)


def get_data(csv_file):
    file = open(csv_file, 'r')
    csv_data = csv.reader(file)
    csv_headers = next(csv_data)
    return csv_headers, csv_data


template = env.get_template('main.html')


def create_output_html(file_name):
    colms = ['design','config','runtime','DIEAREA_mm^2','OpenDP_Util','cell_count','tritonRoute_violations',
            'Short_violations',	'Magic_violations', 'antenna_violations', 'wns', 'CLOCK_PERIOD']

    allData = pd.read_csv(file_name.csv_input) 
    dataFrame =  pd.DataFrame(data=allData)
    usedData = dataFrame[colms]
    usedData.to_csv(file_name.csv_input.split(".csv")[0]+"_tmp_report.csv")

    headers, data = get_data(file_name.csv_input.split(".csv")[0]+"_tmp_report.csv")

    with open(file_name.html_output, 'w') as output:
        static_file = 'style.css'
        output.write(template.render(headers=headers, rows=data, style_url=get_static_folder(static_file).resolve()))


    print(file_name.csv_input.split(".csv")[0]+"_tmp_report.csv")
    os.remove(file_name.csv_input.split(".csv")[0]+"_tmp_report.csv")