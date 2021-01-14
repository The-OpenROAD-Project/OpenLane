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

: ${1?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}
: ${2?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}
: ${3?"Usage: $0 file1.gds file2.gds <top_level_module_name>"}

klayout -r $(dirname $0)/xor.drc -rd top_cell=$3 -rd a=$1 -rd b=$2 -rd thr=$(nproc) -rd ol=xor.gds -zz
