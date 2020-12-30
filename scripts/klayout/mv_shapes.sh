#!/bin/sh

: ${1?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${2?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${3?"Usage: $0 file.gds src_layer/src_purpose targ_layer/targ_purpose [output.gds]"}
: ${PDK_ROOT?"You need to export PDK_ROOT"}
TECH=${TECH:-sky130A}

xvfb-run klayout -z -rd input_layout=$1 -rd tech_file=$PDK_ROOT/$TECH/libs.tech/klayout/$TECH.lyt -rd source_layer=$2 -rd target_layer=$3 -rd output_layout=$4 -rm $(dirname $0)/mv_shapes.py
