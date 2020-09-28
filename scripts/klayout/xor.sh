#!/bin/sh

: ${1?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}
: ${2?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}
: ${3?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}

klayout -r $(dirname $0)/xor.drc -rd top_cell=$3 -rd a=$1 -rd b=$2 -rd thr=$(nproc) -rd ol=xor.gds -zz
