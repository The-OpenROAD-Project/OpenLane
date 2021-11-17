# Copyright 2020-2021 Efabless Corporation
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

if { [info exists ::env(CONTEXTUAL_IO_FLAG_)] } {
	read_lef $::env(TMP_DIR)/top_level.lef
	#ppl::set_num_slots 2
}


if {[catch {read_lef $::env(MERGED_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
	exit 1
}

ppl::set_hor_length $::env(FP_IO_HLENGTH)
ppl::set_ver_length $::env(FP_IO_VLENGTH)
ppl::set_hor_length_extend $::env(FP_IO_VEXTEND)
ppl::set_ver_length_extend $::env(FP_IO_HEXTEND)
ppl::set_ver_thick_multiplier $::env(FP_IO_VTHICKNESS_MULT)
ppl::set_hor_thick_multiplier $::env(FP_IO_HTHICKNESS_MULT)

set opts ""
if { $::env(FP_IO_MODE) == 1 } {
    set opts "-random"
}

set HMETAL [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_HMETAL)-1}]]
set VMETAL [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_VMETAL)-1}]]
place_pins $opts\
	-min_distance $::env(FP_IO_MIN_DISTANCE)\
	-random_seed 42 \
	-hor_layers $HMETAL \
	-ver_layers $VMETAL

write_def $::env(SAVE_DEF)
