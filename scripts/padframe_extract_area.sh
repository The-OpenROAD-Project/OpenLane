#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
# grep -P "/^AREA\s(\d+)\s(\d+)\s;$/" $1
padarea=$(perl -ne 'print "$1 $2" if /^AREA\s(\d+)\s(\d+)\s;$/' $1)
diearea="0 0"
for dim in $padarea
do
	diearea="$diearea $(( $dim + 1 ))"
done
echo $diearea
