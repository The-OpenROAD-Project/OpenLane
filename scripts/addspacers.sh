#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

cell_name=$1
lef_file=$2
input=$3
output=$4

addspacers \
		   -o ${output}_broken \
		   -l $lef_file \
		   -f $cell_name $input \
		   -v

cp $input $output
sh $SCRIPTS_DIR/mv_components.sh ${output}_broken $output &&
	rm ${output}_broken
