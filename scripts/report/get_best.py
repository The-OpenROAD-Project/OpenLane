#!/usr/bin/python3 
import argparse
from operator import itemgetter

# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

parser = argparse.ArgumentParser(
        description="Selects top configuration from a report file")

parser.add_argument("--input", '-i', required=True,
        help="input report file")
parser.add_argument("--output", '-o', required=True,
        help="output report file with top configuration")

args = parser.parse_args()
report_file = args.input
output_file = args.output

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

        key = config[0]
        if (key in dictionary):
            dictionary[config[0]].append(config[1:])
        else:
            dictionary[config[0]] = [config[1:]]

    return dictionary


def get_best_violation(results_vector):
    print(results_vector)
    violations_idx = 7
    # change violations to int
    for i in range(len(results_vector)):
        row = results_vector[i]
        print(row)
        print(row[violations_idx])
        row[violations_idx] = int(row[violations_idx])
        results_vector[i] = row

    sorted_violations = sorted(results_vector, key=itemgetter(violations_idx))
    best_violation = int(sorted_violations[0][violations_idx])

    close_subset = [sorted_violations[0]]
    for result in sorted_violations[1:]:
        violation = int(result[violations_idx])
        if (abs(violation - best_violation) < 5):
            close_subset.append(result)

    wire_length_idx = 15
    via_idx = 16
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

results_dictionary = build_dictionary(report_file)
header = get_header(report_file)
best_results = get_best_results(results_dictionary)
save_top_results(best_results, output_file, header)

