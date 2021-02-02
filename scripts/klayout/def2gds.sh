#!/bin/sh
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

set -e

: ${1?"Usage: $0 tech_file input.def design_name out_gds.gds prereq1.gds prereq2.gds ...."}
: ${2?"Usage: $0 tech_file input.def design_name out_gds.gds prereq1.gds prereq2.gds ...."}
: ${3?"Usage: $0 tech_file input.def design_name out_gds.gds prereq1.gds prereq2.gds ...."}
: ${4?"Usage: $0 tech_file input.def design_name out_gds.gds prereq1.gds prereq2.gds ...."}
: ${5?"Usage: $0 tech_file input.def design_name out_gds.gds prereq1.gds prereq2.gds ...."}

echo "Using Techfile: $1"
echo "Using DEF file: $2"
echo "Design Name: $3"
echo "Output GDS will be: $4"
echo "Extra GDSes:"
echo $5

# The -a here is necessary to handle race conditions.
# This limits the max number of possible jobs to 100.
xvfb-run -a klayout -z -rd design_name=$3 \
        -rd in_def=$2 \
        -rd in_gds="${@:5}" \
        -rd config_file="" \
        -rd seal_gds="" \
        -rd out_gds=$4 \
        -rd tech_file=$1 \
        -rm $(dirname $0)/def2gds.py

exit 0
