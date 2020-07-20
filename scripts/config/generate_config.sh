#!/bin/bash

# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $4

generate_design_config () {
	local base_config_file=$1
	local output_path=$2
	local tag=$3


	
	echo "$( python $( dirname "${BASH_SOURCE[0]}" )/generate_config.py $output_path/${tag}_ $base_config_file $4)" 
	
	#echo "$idx"
}

generate_design_config $1 $2 $3 $4
