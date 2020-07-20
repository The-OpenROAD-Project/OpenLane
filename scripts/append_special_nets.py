#!/usr/bin/env python3

import argparse  # argument parsing
import re
from shutil import copyfile

parser = argparse.ArgumentParser(
    description='Adds special nets from one file to another')
parser.add_argument('--source', required=True)
parser.add_argument('--destination', required=True)
args = parser.parse_args()

source_file = args.source
destination_file = args.destination

with open(source_file, 'r') as source, \
open(destination_file, 'r+') as destination:
	input_def = source.read()
	pattern = r'^ *SPECIALNETS.*^ *END SPECIALNETS *\s'
	special_nets_section = re.findall(pattern, input_def, re.M | re.DOTALL)

	output_def = destination.read()
	output_def = re.sub("END DESIGN", "", output_def)
	output_def = output_def + "\n" + special_nets_section[0]
	destination.seek(0)
	destination.write(output_def)
	destination.truncate()
