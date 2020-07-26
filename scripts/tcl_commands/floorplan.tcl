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

proc init_floorplan_or {args} {
        TIMER::timer_start
        set ::env(SAVE_DEF) $::env(verilog2def_tmp_file_tag)_openroad.def
        try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_floorplan.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(verilog2def_log_file_tag).openroad.log
        TIMER::timer_stop
        exec echo "[TIMER::get_runtime]" >> $::env(verilog2def_log_file_tag)_openroad_runtime.txt
        set_def $::env(verilog2def_tmp_file_tag)_openroad.def
}


proc init_floorplan {args} {
	TIMER::timer_start
	set ::env(CURRENT_STAGE) floorplan
	if {$::env(FP_SIZING) == "absolute"} {
		try_catch verilog2def \
			-verilog $::env(yosys_result_file_tag).v \
			-lef $::env(MERGED_LEF) \
			-liberty $::env(LIB_SYNTH) \
			-top_module $::env(DESIGN_NAME) \
			-site $::env(PLACE_SITE) \
			-tracks $::env(TRACKS_INFO_FILE) \
			-units $::env(DEF_UNITS_PER_MICRON) \
			\
			-die_area $::env(DIE_AREA) \
			-core_area $::env(CORE_AREA) \
			\
			-def $::env(verilog2def_tmp_file_tag)_broken.def \
			-verbose \
			|& tee $::env(TERMINAL_OUTPUT) $::env(verilog2def_log_file_tag).log
	} else {
		try_catch verilog2def \
			-verilog $::env(yosys_result_file_tag).v \
			-lef $::env(MERGED_LEF) \
			-liberty $::env(LIB_SYNTH) \
			-top_module $::env(DESIGN_NAME) \
			-site $::env(PLACE_SITE) \
			-tracks $::env(TRACKS_INFO_FILE) \
			-units $::env(DEF_UNITS_PER_MICRON) \
			\
			-utilization $::env(FP_CORE_UTIL) \
			-aspect_ratio $::env(FP_ASPECT_RATIO) \
			-core_space $::env(FP_CORE_MARGIN) \
			\
			-def $::env(verilog2def_tmp_file_tag)_broken.def \
			-verbose \
			|& tee $::env(TERMINAL_OUTPUT) $::env(verilog2def_log_file_tag).log
	}
	exec cat $::env(verilog2def_tmp_file_tag)_broken.def | sed -r "s/(ROW.*) by /\\1 BY /g" > $::env(verilog2def_tmp_file_tag).def
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(verilog2def_log_file_tag)_runtime.txt
	set_def $::env(verilog2def_tmp_file_tag).def
}

proc place_io {args} {
	TIMER::timer_start
	set ::env(SAVE_DEF) $::env(ioPlacer_tmp_file_tag).def

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_ioplacer.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(ioPlacer_log_file_tag)_runtime.txt
	set_def $::env(SAVE_DEF)
}

proc place_contextualized_io {args} {
	set options {{-lef required} {-def required}}
	set flags {}
	parse_key_args "place_contextualized_io" args arg_values $options flags_map $flags

	if {[file exists $arg_values(-def)] && [file exists $arg_values(-lef)]} {
	  TIMER::timer_start

	  file copy -force $arg_values(-def) $::env(TMP_DIR)/top_level.def
	  file copy -force $arg_values(-lef) $::env(TMP_DIR)/top_level.lef

	  set prev_def $::env(CURRENT_DEF)

	  try_catch python3 $::env(SCRIPTS_DIR)/contextualize.py \
	    -md $prev_def                       -ml $::env(MERGED_LEF_UNPADDED) \
	    -td $::env(TMP_DIR)/top_level.def   -tl $::env(TMP_DIR)/top_level.lef \
	    -o $::env(ioPlacer_tmp_file_tag).context.def |& \
	    tee $::env(ioPlacer_log_file_tag).contextualize.log

	  puts_info "Custom floorplan created"

	  set_def $::env(ioPlacer_tmp_file_tag).context.def
	  set ::env(SAVE_DEF) $::env(CURRENT_DEF)


	  set old_mode $::env(FP_IO_MODE)
	  set ::env(FP_IO_MODE) 0; # set matching mode
	  try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_ioplacer.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log
	  set ::env(FP_IO_MODE) $old_mode

	  move_pins -from $::env(CURRENT_DEF) -to $prev_def
	  set_def $prev_def

	  TIMER::timer_stop

	  exec echo "[TIMER::get_runtime]" >> $::env(ioPlacer_log_file_tag)_runtime.txt

	} else {
	  puts_warn "IO placement: def/lef files don't exist, performing regular IO placement"
	  place_io
	}
}

proc tap_decap {args} {
	try_catch cp $::env(CURRENT_DEF) $::env(tapcell_result_file_tag).def
	TIMER::timer_start
	try_catch tapcell -lef $::env(MERGED_LEF_UNPADDED) \
		-def $::env(tapcell_result_file_tag).def \
		-rule [expr $::env(FP_TAPCELL_DIST) * 2] \
		-welltap $::env(FP_WELLTAP_CELL) \
		-endcap $::env(FP_ENDCAP_CELL) \
		-outdef $::env(tapcell_result_file_tag).def \
		|& tee $::env(TERMINAL_OUTPUT) $::env(tapcell_log_file_tag).log
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(tapcell_log_file_tag)_runtime.txt
	set_def $::env(tapcell_result_file_tag).def
}
proc tap_decap_or {args} {
	#try_catch cp $::env(CURRENT_DEF) $::env(tapcell_result_file_tag).def
	TIMER::timer_start
	set ::env(SAVE_DEF) $::env(tapcell_result_file_tag).def
	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_tapcell.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(tapcell_log_file_tag).log
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(tapcell_log_file_tag)_runtime.txt
	set_def $::env(tapcell_result_file_tag).def
}


proc padframe_extract_area {args} {
  set options {{-cfg required}}
  set flags {}
  parse_key_args "padframe_extract_area" args arg_values $options flags_map $flags
  set area [exec $::env(SCRIPTS_DIR)/padframe_extract_area.sh $arg_values(-cfg)]
  # puts $area
  return $area
}

proc chip_floorplan {args} {
	# intial fp
	init_floorplan_or
	# remove pins section and others
	remove_pins -input $::env(CURRENT_DEF)
	remove_empty_nets -input $::env(CURRENT_DEF)
}

proc run_floorplan {args} {
	puts "\[INFO\]: Running Floorplanning..."
# |----------------------------------------------------|
# |----------------   2. FLOORPLAN   ------------------|
# |----------------------------------------------------|
#
	# intial fp
	init_floorplan_or

	# place io
	place_io

#	# pdn generation
#	gen_pdn

	# tapcell
	if {[info exists  ::env(FP_WELLTAP_CELL)] && $::env(FP_WELLTAP_CELL) ne ""} { 
		tap_decap_or
	}
}

package provide openlane 0.9
