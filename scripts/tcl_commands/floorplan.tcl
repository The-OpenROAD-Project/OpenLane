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
    handle_deprecated_command init_floorplan
}

proc init_floorplan {args} {
		puts_info "Running Initial Floorplanning..."
		TIMER::timer_start
		set ::env(SAVE_DEF) $::env(verilog2def_tmp_file_tag)_openroad.def

		try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_floorplan.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(verilog2def_log_file_tag).openroad.log
		check_floorplan_missing_lef
		check_floorplan_missing_pins

		set die_area_file [open $::env(verilog2def_report_file_tag).die_area.rpt]
		set core_area_file [open $::env(verilog2def_report_file_tag).core_area.rpt]

		set ::env(DIE_AREA) [read $die_area_file]
		set ::env(CORE_AREA) [read $core_area_file]

		close $die_area_file
		close $core_area_file

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


proc place_io_ol {args} {
		set options {
				{-lef optional}
				{-def optional}
				{-cfg optional}
				{-horizontal_layer optional}
				{-vertical_layer optional}
				{-horizontal_mult optional}
				{-horizontal_ext optional}
				{-vertical_layer optional}
				{-vertical_mult optional}
				{-vertical_ext optional}
				{-length optional}
				{-output_def optional}
				{-extra_args optional}
		}
		set flags {}
		
		parse_key_args "place_io_ol" args arg_values $options flags_map $flags

		set_if_unset arg_values(-lef) $::env(MERGED_LEF)
		set_if_unset arg_values(-def) $::env(CURRENT_DEF)

		set_if_unset arg_values(-cfg) $::env(FP_PIN_ORDER_CFG)

		set_if_unset arg_values(-horizontal_layer) $::env(FP_IO_HMETAL)
		set_if_unset arg_values(-vertical_layer) $::env(FP_IO_VMETAL)

		set_if_unset arg_values(-vertical_mult) $::env(FP_IO_VTHICKNESS_MULT)
		set_if_unset arg_values(-horizontal_mult) $::env(FP_IO_HTHICKNESS_MULT)

		set_if_unset arg_values(-vertical_ext) $::env(FP_IO_VEXTEND)
		set_if_unset arg_values(-horizontal_ext) $::env(FP_IO_HEXTEND)

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
				--hor-extension $arg_values(-horizontal_ext)\
				--ver-extension $arg_values(-vertical_ext)\
				--length $arg_values(-length)\
				-o $arg_values(-output_def)\
				{*}$arg_values(-extra_args) |& tee $::env(LOG_DIR)/floorplan/place_io_ol.log $::env(TERMINAL_OUTPUT)

		set_def $arg_values(-output_def)
}

proc place_io {args} {
		puts_info "Running IO Placement..."
		TIMER::timer_start
		set ::env(SAVE_DEF) $::env(ioPlacer_tmp_file_tag).def

		try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_ioplacer.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log

		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" >> $::env(ioPlacer_log_file_tag)_runtime.txt
		set_def $::env(SAVE_DEF)
}

proc place_contextualized_io {args} {
		puts_info "Running Contextualized IO Placement..."
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

				set ::env(SAVE_DEF) $::env(ioPlacer_tmp_file_tag).def

				set old_mode $::env(FP_IO_MODE)
				set ::env(FP_IO_MODE) 0; # set matching mode
				set ::env(CONTEXTUAL_IO_FLAG_) 1
				try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_ioplacer.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log
				set ::env(FP_IO_MODE) $old_mode

				move_pins -from $::env(SAVE_DEF) -to $prev_def
				set_def $prev_def

				TIMER::timer_stop

				exec echo "[TIMER::get_runtime]" >> $::env(ioPlacer_log_file_tag)_runtime.txt

		} else {
				puts_err "Contextual IO placement: def/lef files don't exist, exiting"
				return -code error
		}
}

proc tap_decap_or {args} {
		puts_info "Running Tap/Decap Insertion..."
		TIMER::timer_start
		set ::env(SAVE_DEF) $::env(tapcell_result_file_tag).def
		try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_tapcell.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(tapcell_log_file_tag).log
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" >> $::env(tapcell_log_file_tag)_runtime.txt
		set_def $::env(tapcell_result_file_tag).def
}


proc padframe_extract_area {args} {
		puts_info "Extracting Padframe area..."
		set options {{-cfg required}}
		set flags {}
		parse_key_args "padframe_extract_area" args arg_values $options flags_map $flags
		set area [exec $::env(SCRIPTS_DIR)/padframe_extract_area.sh $arg_values(-cfg)]
		return $area
}

proc chip_floorplan {args} {
		puts_info "Running Chip Floorplanning..."
		# intial fp
		init_floorplan
		# remove pins section and others
		remove_pins -input $::env(CURRENT_DEF)
		remove_empty_nets -input $::env(CURRENT_DEF)
}

proc apply_def_template {args} {
	if { [info exists ::env(FP_DEF_TEMPLATE)] } {		
		puts_info "Applying DEF template..."
		try_catch python3 $::env(SCRIPTS_DIR)/apply_def_template.py -t $::env(FP_DEF_TEMPLATE) -u $::env(CURRENT_DEF) -s $::env(SCRIPTS_DIR)
	}


}

proc run_floorplan {args} {
		puts_info "Running Floorplanning..."
		# |----------------------------------------------------|
		# |----------------   2. FLOORPLAN   ------------------|
		# |----------------------------------------------------|
		#
		# intial fp
		init_floorplan


		# place io
		if { [info exists ::env(FP_PIN_ORDER_CFG)] } {
				place_io_ol
		} else {
			if { [info exists ::env(FP_CONTEXT_DEF)] && [info exists ::env(FP_CONTEXT_LEF)] } {
				place_io
				global_placement_or
				place_contextualized_io \
					-lef $::env(FP_CONTEXT_LEF) \
					-def $::env(FP_CONTEXT_DEF)
			} else {
				place_io
			}
		}
		
		apply_def_template

		if { [info exist ::env(EXTRA_LEFS)] } {
			if { [info exist ::env(MACRO_PLACEMENT_CFG)] } {
				file copy -force $::env(MACRO_PLACEMENT_CFG) $::env(TMP_DIR)/macro_placement.cfg
				manual_macro_placement f
			} else {
				global_placement_or
				basic_macro_placement
			}
		}

		# tapcell
		if {[info exists  ::env(FP_WELLTAP_CELL)] && $::env(FP_WELLTAP_CELL) ne ""} { 
				tap_decap_or
		}

		gen_pdn
}

package provide openlane 0.9
