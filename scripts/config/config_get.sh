#!/bin/bash
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

config_file=$1
args=()
for arg in "$@"; do
	args+=("$arg")
done
for config_name in "${args[@]:1}"; do
	val=$(grep $config_name $config_file | tail -1 |sed  "s/set *::env(${config_name}) *//")
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
