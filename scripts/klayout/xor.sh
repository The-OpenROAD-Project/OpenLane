#!/bin/sh

klayout -r $(dirname $0)/xor.drc -rd top_cell=$3 -rd a=$1 -rd b=$2 -rd thr=$(nproc) -rd ol=xor.gds -zz
