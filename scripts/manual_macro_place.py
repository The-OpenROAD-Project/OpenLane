#!/usr/bin/env python3
"""

"""

import argparse

parser = argparse.ArgumentParser(
    description='Fixes macros in positions specified by a config file')

parser.add_argument('--input', '-i',
                    help='Input DEF')

parser.add_argument('--output', '-o',
                    default='output.def', help='Output DEF')

parser.add_argument('--config', '-c', required=True,
                    help='Configuration file')

parser.add_argument('--fixed', '-f', action='store_true', default=False,
                help="a flag to signal whether the placement should be fixed or placed")



args = parser.parse_args()
input_file_name = args.input
output_file_name = args.output
config_file_name = args.config
fixed_flag = args.fixed
# read config

macros = {}
with open(config_file_name, 'r') as config_file:
    for line in config_file:
        line = line.split()
        macros[line[0]] = (str(int(float(line[1])*1000)), str(int(float(line[2])*1000)))

print("Placing the following macros:")
print(macros)

in_components = False
with open(output_file_name, 'w') as output_def_file, \
        open(input_file_name, 'r') as input_def_file:
    for line in input_def_file:
        line = line.split()
        if len(line) >= 2:
            if line[0] == "COMPONENTS": # COMPONENTS # ;
                in_components = True
            elif line[0] == "END" and line[1] == "COMPONENTS": # END COMPONENTS
                in_components = False
            elif in_components:
                if line[1] in macros:
                    print("Placing ", line[1])
                    macro_name = line[1]
                    if (line[4] != "FIXED") & (line[4] != "PLACED"):
                        print("[ERROR] DEF Format Not Supported for MACRO Placement!") 
                        exit()  
                    if fixed_flag == True:
                        line[4] = "FIXED"
                    else:
                        line[4] = "PLACED"
                    line[6] = macros[macro_name][0]
                    line[7] = macros[macro_name][1]
        output_def_file.write(" ".join(line+["\n"]))
