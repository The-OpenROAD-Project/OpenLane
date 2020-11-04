#!/bin/bash
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



DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $4

generate_design_config () {
	local base_config_file=$1
	local output_path=$2
	local tag=$3


	
	echo "$( python $( dirname "${BASH_SOURCE[0]}" )/generate_config.py $output_path/${tag}_ $base_config_file $4)" 
	
}

generate_design_config $1 $2 $3 $4
