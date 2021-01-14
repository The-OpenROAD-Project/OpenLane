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

: ${1?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${2?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${3?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${PDK_ROOT?"You need to export PDK_ROOT"}
TECH=${TECH:-sky130A}

xvfb-run klayout -z -rd input_layout=$1 -rd tech_file=$PDK_ROOT/$TECH/libs.tech/klayout/$TECH.lyt -rd source_layer=$2 -rd target_layer=$3 -rd output_layout=$4 -rm $(dirname $0)/mv_shapes.py
