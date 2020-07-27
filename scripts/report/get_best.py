#!/usr/bin/python3 
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

import argparse
from operator import itemgetter


parser = argparse.ArgumentParser(
        description="Selects top configuration from a report file")

parser.add_argument("--input", '-i', required=True,
        help="input report file")
parser.add_argument("--output", '-o', required=True,
        help="output report file with top configuration")

args = parser.parse_args()
report_file = args.input
output_file = args.output

violations_idx = 0
wire_length_idx = 0
via_idx = 0
runtime_idx= 0
design_idx=0

def get_header(report_file):
    f = open(report_file, "r")
    header = f.readline()
    return header

def build_dictionary(report_file):
    with open(report_file, "r") as f:
        lines = list(filter(None, (line.rstrip() for line in f)))
        header = lines[0]
        lines = lines[1:]
        lines = [line.split(',') for line in lines]

    dictionary = {}
    for config in lines:
        if (len(config) < len(header.split(','))):
            continue

        key = config[design_idx]
        if (key in dictionary):
            dictionary[key].append(config[design_idx+1:])
        else:
            dictionary[key] = [config[design_idx+1:]]

    return dictionary


def get_best_violation(results_vector):
    print(results_vector)
    remover = 0
    n = len(results_vector)
    while(remover != n and n != 1):
        if results_vector[remover][runtime_idx] == '-1':
            results_vector.pop(remover)
            remover-=1
            n = len(results_vector)    
        remover+=1
    
    # change violations to int
    for i in range(len(results_vector)):
        row = results_vector[i]
        row[violations_idx] = int(row[violations_idx])
        results_vector[i] = row

    sorted_violations = sorted(results_vector, key=itemgetter(violations_idx))
    best_violation = int(sorted_violations[0][violations_idx])

    close_subset = [sorted_violations[0]]
    for result in sorted_violations[1:]:
        violation = int(result[violations_idx])
        if (abs(violation - best_violation) < 5) and best_violation != 0:
            close_subset.append(result)
        elif violation == 0:
            close_subset.append(result)

    for i in range(len(close_subset)):
        row = close_subset[i]
        wirelength = row[wire_length_idx]
        via = row[via_idx]
        row.append((int(wirelength) + int(via)))
        row[violations_idx] = str(row[violations_idx])
        close_subset[i] = row


    sorted_wire_length_via = sorted(close_subset, key=itemgetter(-1))
    best_result = sorted_wire_length_via[0][:-1]
    return best_result

def get_best_results(results_dictionary):
    best = {}
    for key in results_dictionary:
        results = results_dictionary[key]
        best_result = get_best_violation(results)
        best[key] = best_result
    
    return best
 
def save_top_results(results_dictionary, output_file, header):
    out = open(output_file, 'w')
    out.write(header)

    for key in results_dictionary:
        out.writelines("%s,%s" % (key, ','.join(results_dictionary[key])))
        out.write('\n')

    out.close()

def findIdx(header, column):

    for idx in range(len(header)):
        if header[idx] == column:
            return int(idx)
    return -1

header = get_header(report_file)

headerSplit = header.split(',')
design_idx = findIdx(headerSplit, 'design')

results_dictionary = build_dictionary(report_file)

violations_idx = findIdx(headerSplit, 'tritonRoute_violations')-(design_idx+1)
wire_length_idx = findIdx(headerSplit, 'wire_length')-(design_idx+1)
via_idx = findIdx(headerSplit, 'vias')-(design_idx+1)
runtime_idx = findIdx(headerSplit, 'runtime')-(design_idx+1)

best_results = get_best_results(results_dictionary)
 
save_top_results(best_results, output_file, ",".join(headerSplit[design_idx:]))

