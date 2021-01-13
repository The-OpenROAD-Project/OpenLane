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

export KLAYOUT_SKY130_TECH=/home/xrex/.klayout/tech/SKY130/SKY130.lyt

: ${1?"Usage: $0 input.def design_name prereq1.gds prereq2.gds ...."}
: ${2?"Usage: $0 input.def design_name prereq1.gds prereq2.gds ...."}
: ${3?"Usage: $0 input.def design_name prereq1.gds prereq2.gds ...."}

xvfb-run klayout -z -rd design_name=$2 \
        -rd in_def=$1 \
        -rd in_gds="${@:3}" \
        -rd config_file="" \
        -rd seal_gds="" \
        -rd out_gds=$(dirname $1)/$2.gds \
        -rd tech_file=$KLAYOUT_SKY130_TECH \
        -rm $(dirname $0)/def2gds.py
