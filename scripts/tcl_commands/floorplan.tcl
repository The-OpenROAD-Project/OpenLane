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

		set die_area_file [open $::env(verilog2def_report_file_tag).die_area.rpt]
		set ::env(CORE_AREA) [read $die_area_file]
		close $die_area_file

		puts $::env(CORE_AREA)

		set core_width [expr {[lindex $::env(CORE_AREA) 2] - [lindex $::env(CORE_AREA) 0]}]
		set core_height [expr {[lindex $::env(CORE_AREA) 3] - [lindex $::env(CORE_AREA) 1]}]

		puts_info "Core area width: $core_width"
		puts_info "Core area height: $core_height"

		if { $core_width <= [expr {$::env(FP_PDN_VOFFSET) + $::env(FP_PDN_VPITCH)}] ||\
				$core_height <= [expr {$::env(FP_PDN_HOFFSET) + $::env(FP_PDN_HPITCH)}]} {
						puts_warn "Current core area is too small for a power grid"
						puts_warn "Minimizing the power grid!!!!"

						set ::env(FP_PDN_VOFFSET) [expr {$core_width/6.0}]
						set ::env(FP_PDN_HOFFSET) [expr {$core_height/6.0}]

						set ::env(FP_PDN_VPITCH) [expr {$core_width/3.0}]
						set ::env(FP_PDN_HPITCH) [expr {$core_height/3.0}]
		}

		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" >> $::env(verilog2def_log_file_tag)_openroad_runtime.txt
		set_def $::env(verilog2def_tmp_file_tag)_openroad.def
}


proc init_floorplan {args} {
		TIMER::timer_start
		set ::env(CURRENT_STAGE) floorplan
		if {$::env(FP_SIZING) == "absolute"} {
				if { [info exists ::env(CORE_AREA)] } {
						puts_warn "Ignoring CORE_AREA set; deriving it from *_MARGIN_MULT configurations"
				}
				set die_area $::env(DIE_AREA)
				set ll_x [lindex $die_area 0]
				set ll_y [lindex $die_area 1]
				set ur_x [lindex $die_area 2]
				set ur_y [lindex $die_area 3]

				set ll_x [expr {$ll_x + $::env(LEFT_MARGIN_MULT) * $::env(PLACE_SITE_WIDTH)}]
				set ll_y [expr {$ll_y + $::env(BOTTOM_MARGIN_MULT) * $::env(PLACE_SITE_HEIGHT)}]
				set ur_x [expr {$ur_x - $::env(RIGHT_MARGIN_MULT) * $::env(PLACE_SITE_WIDTH)}]
				set ur_y [expr {$ur_y - $::env(TOP_MARGIN_MULT) * $::env(PLACE_SITE_HEIGHT)}]

				set ::env(CORE_AREA) [list $ll_x $ll_y $ur_x $ur_y]


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

proc place_io_ol {args} {
		set options {
				{-lef optional}
				{-def optional}
				{-cfg optional}
				{-horizontal_layer optional}
				{-vertical_layer optional}
				{-horizontal_mult optional}
				{-vertical_layer optional}
				{-vertical_mult optional}
				{-length optional}
				{-output_def optional}
				{-extra_args optional}
		}
		set flags {}
		# set proc_name [info level 0]
		parse_key_args "place_io_ol" args arg_values $options flags_map $flags

		set_if_unset arg_values(-lef) $::env(MERGED_LEF)
		set_if_unset arg_values(-def) $::env(CURRENT_DEF)

		set_if_unset arg_values(-cfg) ""

		set_if_unset arg_values(-horizontal_layer) $::env(FP_IO_HMETAL)
		set_if_unset arg_values(-vertical_layer) $::env(FP_IO_VMETAL)

		set_if_unset arg_values(-vertical_mult) $::env(FP_IO_VTHICKNESS_MULT)
		set_if_unset arg_values(-horizontal_mult) $::env(FP_IO_HTHICKNESS_MULT)
		set_if_unset arg_values(-length) [expr max($::env(FP_IO_VLENGTH), $::env(FP_IO_HLENGTH))]
		set_if_unset arg_values(-output_def) $::env(ioPlacer_tmp_file_tag).def

		set_if_unset arg_values(-extra_args) ""

		try_catch python3 $::env(SCRIPTS_DIR)/io_place.py\
				--input-lef $arg_values(-lef)\
				--input-def $arg_values(-def)\
				--config $arg_values(-cfg)\
				--hor-layer $arg_values(-horizontal_layer)\
				--ver-layer $arg_values(-vertical_layer)\
				--ver-width-mult $arg_values(-vertical_mult)\
				--hor-width-mult $arg_values(-horizontal_mult)\
				--length-mult $arg_values(-length)\
				-o $arg_values(-output_def)\
				{*}$arg_values(-extra_args) |& tee $::env(LOG_DIR)/floorplan/place_io_ol.log $::env(TERMINAL_OUTPUT)

		set_def $arg_values(-output_def)
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
				set ::env(CONTEXTUAL_IO_FLAG_) 1
				try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_ioplacer.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log
				set ::env(FP_IO_MODE) $old_mode

				move_pins -from $::env(CURRENT_DEF) -to $prev_def
				set_def $prev_def

				TIMER::timer_stop

				exec echo "[TIMER::get_runtime]" >> $::env(ioPlacer_log_file_tag)_runtime.txt

		} else {
				puts_err "Contextual IO placement: def/lef files don't exist, exiting"
				return -code error
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
		if { [info exists ::env(FP_PIN_ORDER_CFG)] } {
				place_io_ol -cfg $::env(FP_PIN_ORDER_CFG)
		} else {
				place_io
		}

		#	# pdn generation
		#	gen_pdn

		# tapcell
		if {[info exists  ::env(FP_WELLTAP_CELL)] && $::env(FP_WELLTAP_CELL) ne ""} { 
				tap_decap_or
		}
}

package provide openlane 0.9
