#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

delta=$1
# diearea=$(perl -0ne 'print $1-$ENV{'delta'}," ", $2-$ENV{'delta'}," ", $3+$ENV{'delta'}," ", $4+$ENV{'delta'} if /DIEAREA.*\s(\d+)\s(\d+).*\s(\d+)\s(\d+)\s.*\n/' $2)
diearea=( $(sed -En "1,20 s/^DIEAREA \( (-?[0-9]+) (-?[0-9]+) \) \( (-?[0-9]+) (-?[0-9]+) \) ;$/\1 \2 \3 \4/p" $2) )


diearea[0]=$(( ${diearea[0]}-$delta ))
diearea[1]=$(( ${diearea[1]}-$delta ))
diearea[2]=$(( ${diearea[2]}+$delta ))
diearea[3]=$(( ${diearea[3]}+$delta ))

echo ${diearea[@]}

sed -i -E "1,20 s/^DIEAREA \( (-?[0-9]+) (-?[0-9]+) \) \( (-?[0-9]+) (-?[0-9]+) \) ;$/DIEAREA \( ${diearea[0]} ${diearea[1]} \) \( ${diearea[2]} ${diearea[3]} \) ;/" $2
