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


config_file=$1
args=()
for arg in "$@"; do
	args+=("$arg")
done
for config_name in "${args[@]:1}"; do
	val=$(grep "($config_name)" $config_file | tail -1 |sed  "s/set *::env(${config_name}) *//")
	if ! [[ $val ]]; then val=-1; fi
	printf "##$val"
done
printf "##\n"

#get_config_val $config_path $af
#af_val=$val
#get_config_val $config_path $util
#util_val=$val
#get_config_val $config_path $dens
#dens_val=$val
#get_config_val $config_path $strat
#strat_val=$val
#get_config_val $config_path $fan
#fan_val=$val
#get_config_val $config_path $pdn_v
#pdn_v_val=$val
#get_config_val $config_path $pdn_h
#pdn_h_val=$val
#get_config_val $config_path $ar
#ar_val=$val

#echo "$af_val $util_val $dens_val $strat_val $fan_val $pdn_v_val $pdn_h_val $ar_val"
