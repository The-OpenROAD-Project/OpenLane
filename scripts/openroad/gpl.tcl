# Copyright 2020-2022 Efabless Corporation
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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

set ::block [[[::ord::get_db] getChip] getBlock]
set ::insts [$::block getInsts]

set placement_needed 0

foreach inst $::insts {
	if { ![$inst isFixed] } {
		set placement_needed 1
		break
	}
}

if { !$placement_needed } {
	puts "\[WARN] All instances are FIXED/FIRM."
	puts "\[WARN] No need to perform global placement."
	puts "\[WARN] Skipping..."
	write
	exit 0
}

set arg_list [list]

lappend arg_list -density $::env(PL_TARGET_DENSITY)

if { $::env(PL_BASIC_PLACEMENT) } {
	lappend arg_list -overflow 0.9
	lappend arg_list -init_density_penalty 0.0001
	lappend arg_list -initial_place_max_iter 20
	lappend arg_list -bin_grid_count 64
}

if { $::env(PL_TIME_DRIVEN) } {
	source $::env(SCRIPTS_DIR)/openroad/common/set_rc.tcl
	lappend arg_list -timing_driven
}

if { $::env(PL_ROUTABILITY_DRIVEN) } {
	source $::env(SCRIPTS_DIR)/openroad/common/set_routing_layers.tcl
	set_macro_extension $::env(GRT_MACRO_EXTENSION)
	source $::env(SCRIPTS_DIR)/openroad/common/set_layer_adjustments.tcl
	lappend arg_list -routability_driven
}

if { $::env(PL_SKIP_INITIAL_PLACEMENT) && !$::env(PL_BASIC_PLACEMENT) } {
	lappend arg_list -skip_initial_place
}

set cell_pad_side [expr $::env(GPL_CELL_PADDING) / 2]

lappend arg_list -pad_right $cell_pad_side
lappend arg_list -pad_left $cell_pad_side

lappend arg_list -init_wirelength_coef $::env(PL_WIRELENGTH_COEF)

global_placement {*}$arg_list

write
