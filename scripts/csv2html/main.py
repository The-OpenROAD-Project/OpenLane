"""
convert csv files to html files
"""
import argparse
from csv2html import create_output_html

parser = argparse.ArgumentParser()
parser.add_argument('csv_input', help="csv file")
parser.add_argument('html_output', help='html output file')
args = parser.parse_args()

if __name__ == '__main__':
    create_output_html(args)
