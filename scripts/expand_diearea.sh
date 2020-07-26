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


delta=$1
# diearea=$(perl -0ne 'print $1-$ENV{'delta'}," ", $2-$ENV{'delta'}," ", $3+$ENV{'delta'}," ", $4+$ENV{'delta'} if /DIEAREA.*\s(\d+)\s(\d+).*\s(\d+)\s(\d+)\s.*\n/' $2)
diearea=( $(sed -En "1,20 s/^DIEAREA \( (-?[0-9]+) (-?[0-9]+) \) \( (-?[0-9]+) (-?[0-9]+) \) ;$/\1 \2 \3 \4/p" $2) )


diearea[0]=$(( ${diearea[0]}-$delta ))
diearea[1]=$(( ${diearea[1]}-$delta ))
diearea[2]=$(( ${diearea[2]}+$delta ))
diearea[3]=$(( ${diearea[3]}+$delta ))

echo ${diearea[@]}

sed -i -E "1,20 s/^DIEAREA \( (-?[0-9]+) (-?[0-9]+) \) \( (-?[0-9]+) (-?[0-9]+) \) ;$/DIEAREA \( ${diearea[0]} ${diearea[1]} \) \( ${diearea[2]} ${diearea[3]} \) ;/" $2
