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
    description="Selects top configuration from a report file and produces a new report file containing the top configurations only for each design"
)

parser.add_argument("--input", "-i", required=True, help="input report file")
parser.add_argument(
    "--output", "-o", required=True, help="output report file with top configuration"
)

args = parser.parse_args()
report_file = args.input
output_file = args.output

tr_violations_idx = 0
lvs_errors_idx = 0
magic_violations_idx = 0
antenna_violations_idx = 0
wire_length_idx = 0
via_idx = 0
flow_status_idx = 0
design_idx = 0


def get_header(report_file):
    f = open(report_file, "r")
    header = f.readline()
    return header


def build_dictionary(report_file):
    with open(report_file, "r") as f:
        lines = list(filter(None, (line.rstrip() for line in f)))
        header = lines[0]
        lines = lines[1:]
        lines = [line.split(",") for line in lines]

    dictionary = {}
    for config in lines:
        if len(config) < len(header.split(",")):
            continue

        key = config[design_idx]
        if key in dictionary:
            dictionary[key].append(config[design_idx + 1 :])
        else:
            dictionary[key] = [config[design_idx + 1 :]]

    return dictionary


def convert_vio_to_int(val):
    val = int(val)
    if val < 0:
        val = 2**31  # Explode
    return val


def convert_vio_to_string(val):
    if val == 2**31:
        val = -1
    return str(val)


def convert_vios_to_int(results_vector):
    # change violations to int
    for i in range(len(results_vector)):
        row = results_vector[i]
        row[tr_violations_idx] = convert_vio_to_int(row[tr_violations_idx])
        row[lvs_errors_idx] = convert_vio_to_int(row[lvs_errors_idx])
        row[magic_violations_idx] = convert_vio_to_int(row[magic_violations_idx])
        row[antenna_violations_idx] = convert_vio_to_int(row[antenna_violations_idx])
        results_vector[i] = row
    return results_vector


def filter_by_tr_vios(results_vector):
    # Get a close subset by TR vios
    sorted_violations = sorted(results_vector, key=itemgetter(tr_violations_idx))
    best_violation = int(sorted_violations[0][tr_violations_idx])

    close_subset = [sorted_violations[0]]
    for result in sorted_violations[1:]:
        violation = int(result[tr_violations_idx])
        if (abs(violation - best_violation) < 5) and best_violation != 0:
            close_subset.append(result)
        elif violation == 0:
            close_subset.append(result)
    return close_subset


def filter_by_lvs_errors(results_vector):
    # Get a close subset by LVS errors
    # The philosiphy here is if one run is LVS clean, then don't accept anything that
    # is not LVS clean. Otherwise, don't trust the reported result by netgen and pass
    # everything as is to the next filter.
    sorted_violations = sorted(results_vector, key=itemgetter(lvs_errors_idx))
    best_violation = int(sorted_violations[0][lvs_errors_idx])

    if best_violation == 0:
        close_subset = [sorted_violations[0]]
        for result in sorted_violations[1:]:
            violation = int(result[lvs_errors_idx])
            if violation == 0:
                close_subset.append(result)
        return close_subset
    else:
        return results_vector


def filter_by_magic_vios(results_vector):
    # Get a close subset by magic drc vios
    sorted_violations = sorted(results_vector, key=itemgetter(magic_violations_idx))
    best_violation = int(sorted_violations[0][magic_violations_idx])

    close_subset = [sorted_violations[0]]
    for result in sorted_violations[1:]:
        violation = int(result[magic_violations_idx])
        # Allow for 100 vios tolerance (given the history of magic drc(full))
        if (abs(violation - best_violation) < 100) and best_violation != 0:
            close_subset.append(result)
        elif violation == 0:
            close_subset.append(result)
    return close_subset


def filter_by_antenna_vios(results_vector):
    # Get a close subset by antenna vios
    sorted_violations = sorted(results_vector, key=itemgetter(antenna_violations_idx))
    best_violation = int(sorted_violations[0][antenna_violations_idx])

    close_subset = [sorted_violations[0]]
    for result in sorted_violations[1:]:
        violation = int(result[antenna_violations_idx])
        # Allow for 10 vios tolerance
        if (abs(violation - best_violation) < 10) and best_violation != 0:
            close_subset.append(result)
        elif violation == 0:
            close_subset.append(result)
    return close_subset


def get_best_violation(results_vector):
    # Remove all failing designs (unless they are all failing then only keep one of them)
    remover = 0
    n = len(results_vector)
    while remover != n and n != 1:
        if "fail" in str(results_vector[remover][flow_status_idx]):
            results_vector.pop(remover)
            remover -= 1
            n = len(results_vector)
        remover += 1
    # Convert violations to integers
    results_vector = convert_vios_to_int(results_vector)

    # Filter the results vector by TR violations
    close_subset = filter_by_tr_vios(results_vector)
    # Filter the close subset by LVS errors
    close_subset = filter_by_lvs_errors(close_subset)
    # Filter the close subset by magic DRC violations
    close_subset = filter_by_magic_vios(close_subset)
    # Filter the close subset by antenna violations
    close_subset = filter_by_antenna_vios(close_subset)
    # Finalize selection based on wire length and via count
    for i in range(len(close_subset)):
        row = close_subset[i]
        wirelength = row[wire_length_idx]
        via = row[via_idx]
        row.append((int(wirelength) + int(via)))
        row[tr_violations_idx] = convert_vio_to_string(row[tr_violations_idx])
        row[lvs_errors_idx] = convert_vio_to_string(row[lvs_errors_idx])
        row[magic_violations_idx] = convert_vio_to_string(row[magic_violations_idx])
        row[antenna_violations_idx] = convert_vio_to_string(row[antenna_violations_idx])
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
    out = open(output_file, "w")
    out.write(header)

    for key in results_dictionary:
        out.writelines("%s,%s" % (key, ",".join(results_dictionary[key])))
        out.write("\n")

    out.close()


def findIdx(header, column):

    for idx in range(len(header)):
        if header[idx] == column:
            return int(idx)
    return -1


header = get_header(report_file)

headerSplit = header.split(",")
design_idx = findIdx(headerSplit, "design")

results_dictionary = build_dictionary(report_file)

tr_violations_idx = findIdx(headerSplit, "tritonRoute_violations") - (design_idx + 1)
lvs_errors_idx = findIdx(headerSplit, "lvs_total_errors") - (design_idx + 1)
magic_violations_idx = findIdx(headerSplit, "Magic_violations") - (design_idx + 1)
antenna_violations_idx = findIdx(headerSplit, "pin_antenna_violations") - (
    design_idx + 1
)
wire_length_idx = findIdx(headerSplit, "wire_length") - (design_idx + 1)
via_idx = findIdx(headerSplit, "vias") - (design_idx + 1)
flow_status_idx = findIdx(headerSplit, "flow_status") - (design_idx + 1)
best_results = get_best_results(results_dictionary)

save_top_results(best_results, output_file, ",".join(headerSplit[design_idx:]))
