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
