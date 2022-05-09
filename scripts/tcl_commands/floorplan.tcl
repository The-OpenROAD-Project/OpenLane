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
proc set_core_dims {args} {
	puts_info "Setting Core Dimensions..."
	set options {}
	parse_key_args "set_core_dims" args values $options
	set def_units $::env(DEF_UNITS_PER_MICRON)

	set out_tmp $::env(TMP_DIR)/dimensions.txt

	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/defutil.py\
		extract_core_dims\
		--output-data $out_tmp\
		--input-lef $::env(MERGED_LEF)\
		$::env(CURRENT_DEF)

	set dims [join [cat $out_tmp] " "]

	set ::env(CORE_WIDTH) [lindex $dims 0]
	set ::env(CORE_HEIGHT) [lindex $dims 1]
}

proc init_floorplan_or {args} {
	handle_deprecated_command init_floorplan
}

proc init_floorplan {args} {
	increment_index
	puts_info "Running Initial Floorplanning..."
	TIMER::timer_start
	set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles)/initial_fp.def]
	set ::env(SAVE_SDC) [index_file $::env(floorplan_tmpfiles)/initial_fp.sdc]

	set ::env(fp_report_prefix) [index_file $::env(floorplan_reports)/initial_fp]

	run_openroad_script $::env(SCRIPTS_DIR)/openroad/floorplan.tcl -indexed_log [index_file $::env(floorplan_logs)/initial_fp.log] -netlist_in

	check_floorplan_missing_lef
	check_floorplan_missing_pins

	set die_area_file [open $::env(fp_report_prefix)_die_area.rpt]
	set core_area_file [open $::env(fp_report_prefix)_core_area.rpt]

	set ::env(DIE_AREA) [read $die_area_file]
	set ::env(CORE_AREA) [read $core_area_file]

	close $die_area_file
	close $core_area_file

	set core_width [expr {[lindex $::env(CORE_AREA) 2] - [lindex $::env(CORE_AREA) 0]}]
	set core_height [expr {[lindex $::env(CORE_AREA) 3] - [lindex $::env(CORE_AREA) 1]}]

	puts_verbose "Core area width: $core_width"
	puts_verbose "Core area height: $core_height"

	if { $::env(FP_PDN_AUTO_ADJUST) } {
		if { $core_width <= [expr {$::env(FP_PDN_VOFFSET) + $::env(FP_PDN_VPITCH)}] ||\
			$core_height <= [expr {$::env(FP_PDN_HOFFSET) + $::env(FP_PDN_HPITCH)}]} {
				puts_warn "Current core area is too small for a power grid. The power grid will be minimized."

			set ::env(FP_PDN_VOFFSET) [expr {$core_width/8.0}]
			set ::env(FP_PDN_HOFFSET) [expr {$core_height/8.0}]

			set ::env(FP_PDN_VPITCH) [expr {$core_width/4.0}]
			set ::env(FP_PDN_HPITCH) [expr {$core_height/4.0}]
		}

	}

	puts_verbose "Final Vertical PDN Offset: $::env(FP_PDN_VOFFSET)"
	puts_verbose "Final Horizontal PDN Offset: $::env(FP_PDN_HOFFSET)"

	puts_verbose "Final Vertical PDN Pitch: $::env(FP_PDN_VPITCH)"
	puts_verbose "Final Horizontal PDN Pitch: $::env(FP_PDN_HPITCH)"

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "floorplan initialization - openroad"
	set_def $::env(SAVE_DEF)
	set ::env(CURRENT_SDC) $::env(SAVE_SDC)

	set_core_dims
}


proc place_io_ol {args} {
	increment_index
	puts_info "Running IO Placement..."
	TIMER::timer_start
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
	set flags {-unmatched_error optional}

	parse_key_args "place_io_ol" args arg_values $options flags_map $flags

	set_if_unset arg_values(-lef) $::env(MERGED_LEF)
	set_if_unset arg_values(-def) $::env(CURRENT_DEF)

	set_if_unset arg_values(-cfg) $::env(FP_PIN_ORDER_CFG)

	set_if_unset arg_values(-horizontal_layer) $::env(FP_IO_HLAYER)
	set_if_unset arg_values(-vertical_layer) $::env(FP_IO_VLAYER)

	set_if_unset arg_values(-vertical_mult) $::env(FP_IO_VTHICKNESS_MULT)
	set_if_unset arg_values(-horizontal_mult) $::env(FP_IO_HTHICKNESS_MULT)

	set_if_unset arg_values(-vertical_ext) $::env(FP_IO_VEXTEND)
	set_if_unset arg_values(-horizontal_ext) $::env(FP_IO_HEXTEND)

	set_if_unset arg_values(-length) [expr max($::env(FP_IO_VLENGTH), $::env(FP_IO_HLENGTH))]
	set_if_unset arg_values(-output_def) [index_file $::env(floorplan_tmpfiles)/io.def]

    if { $::env(FP_IO_UNMATCHED_ERROR) } {
        set_if_unset flags_map(-unmatched_error) "--unmatched-error"
    } else {
        set_if_unset flags_map(-unmatched_error) ""
    }
    set_if_unset arg_values(-extra_args) ""

	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/io_place.py\
		--input-lef $arg_values(-lef)\
		--config $arg_values(-cfg)\
		--hor-layer $arg_values(-horizontal_layer)\
		--ver-layer $arg_values(-vertical_layer)\
		--ver-width-mult $arg_values(-vertical_mult)\
		--hor-width-mult $arg_values(-horizontal_mult)\
		--hor-extension $arg_values(-horizontal_ext)\
		--ver-extension $arg_values(-vertical_ext)\
		--length $arg_values(-length)\
        {*}$flags_map(-unmatched_error)\
		-o $arg_values(-output_def)\
		{*}$arg_values(-extra_args)\
		$arg_values(-def) |& tee [index_file $::env(floorplan_logs)/place_io_ol.log] $::env(TERMINAL_OUTPUT)

	set_def $arg_values(-output_def)

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "ioplace - io_place.py"
}

proc place_io {args} {
	increment_index
	puts_info "Running IO Placement..."
	TIMER::timer_start
	set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles)/io.def]

	run_openroad_script $::env(SCRIPTS_DIR)/openroad/ioplacer.tcl -indexed_log [index_file $::env(floorplan_logs)/io.log]
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "ioplace - openroad"
	set_def $::env(SAVE_DEF)
}

proc place_contextualized_io {args} {
	increment_index
	puts_info "Running Contextualized IO Placement..."
	set options {{-lef required} {-def required}}
	set flags {}
	parse_key_args "place_contextualized_io" args arg_values $options flags_map $flags

	if {[file exists $arg_values(-def)] && [file exists $arg_values(-lef)]} {
		TIMER::timer_start

		file copy -force $arg_values(-def) $::env(placement_tmpfiles)/top_level.def
		file copy -force $arg_values(-lef) $::env(placement_tmpfiles)/top_level.lef


		set prev_def $::env(CURRENT_DEF)
		set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles)/io.context.def]
		try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/contextualize.py \
			-md $prev_def                       -ml $::env(MERGED_LEF_UNPADDED) \
			-td $::env(placement_tmpfiles)/top_level.def   -tl $::env(placement_tmpfiles)/top_level.lef \
			-o $::env(SAVE_DEF) |& \
			tee [index_file $::env(floorplan_logs)/io.contextualize.log]
		puts_info "Custom floorplan created"

		set_def $::env(SAVE_DEF)

		set ::env(SAVE_DEF) [index_file $::env(floorplan_tmpfiles)/io.def]

		set old_mode $::env(FP_IO_MODE)
		set ::env(FP_IO_MODE) 0; # set matching mode
		set ::env(CONTEXTUAL_IO_FLAG) 1
		run_openroad_script $::env(SCRIPTS_DIR)/openroad/ioplacer.tcl -indexed_log [index_file $::env(floorplan_logs)/io.log]
		set ::env(FP_IO_MODE) $old_mode

		move_pins -from $::env(SAVE_DEF) -to $prev_def
		set_def $prev_def

		TIMER::timer_stop

		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "ioplace - openroad (contextual)"

	} else {
		puts_err "Contextual IO placement: def/lef files don't exist, exiting"
		return -code error
	}
}

proc tap_decap_or {args} {
	if { $::env(TAP_DECAP_INSERTION) } {
		if {[info exists  ::env(FP_WELLTAP_CELL)] && $::env(FP_WELLTAP_CELL) ne ""} {
			increment_index
			puts_info "Running Tap/Decap Insertion..."
			TIMER::timer_start
			set ::env(SAVE_DEF) $::env(floorplan_results)/$::env(DESIGN_NAME).def
			run_openroad_script $::env(SCRIPTS_DIR)/openroad/tapcell.tcl -indexed_log [index_file $::env(floorplan_logs)/tap.log]
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "tap/decap insertion - openroad"
			set_def $::env(SAVE_DEF)
		} else {
			puts_info "No tap cells found in this library. Skipping Tap/Decap Insertion."
		}
	} else {
		puts_warn "Skipping Tap/Decap Insertion."
	}
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
		set log [index_file $::env(floorplan_logs)/apply_def_template.log]
		set def [index_file $::env(floorplan_tmpfiles)/apply_def_template.def]
		puts_info "Applying DEF template. See log: $log"
		try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/apply_def_template.py\
			--lef $::env(MERGED_LEF) \
			--def-template $::env(FP_DEF_TEMPLATE)\
			--log $log \
			$::env(CURRENT_DEF)
	}

}

proc run_power_grid_generation {args} {
	if { [info exists ::env(VDD_NETS)] || [info exists ::env(GND_NETS)] } {
		# they both must exist and be equal in length
		# current assumption: they cannot have a common ground
		if { ! [info exists ::env(VDD_NETS)] || ! [info exists ::env(GND_NETS)] } {
			puts_err "VDD_NETS and GND_NETS must *both* either be defined or undefined"
			return -code error
		}
		# standard cell power and ground nets are assumed to be the first net
		set ::env(VDD_PIN) [lindex $::env(VDD_NETS) 0]
		set ::env(GND_PIN) [lindex $::env(GND_NETS) 0]
	} elseif { [info exists ::env(SYNTH_USE_PG_PINS_DEFINES)] } {
		set ::env(VDD_NETS) [list]
		set ::env(GND_NETS) [list]
		# get the pins that are in $synthesis_tmpfiles.pg_define.v
		# that are not in $synthesis_results.v
		#
		set full_pins {*}[extract_pins_from_yosys_netlist $::env(synthesis_tmpfiles)/pg_define.v]
		puts_info $full_pins

		set non_pg_pins {*}[extract_pins_from_yosys_netlist $::env(synthesis_results)/$::env(DESIGN_NAME).v]
		puts_info $non_pg_pins

		# assumes the pins are ordered correctly (e.g., vdd1, vss1, vcc1, vss1, ...)
		foreach {vdd gnd} $full_pins {
			if { $vdd ne "" && $vdd ni $non_pg_pins } {
				lappend ::env(VDD_NETS) $vdd
			}
			if { $gnd ne "" && $gnd ni $non_pg_pins } {
				lappend ::env(GND_NETS) $gnd
			}
		}
	} else {
		set ::env(VDD_NETS) $::env(VDD_PIN)
		set ::env(GND_NETS) $::env(GND_PIN)
	}

	puts_info "Power planning with power {$::env(VDD_NETS)} and ground {$::env(GND_NETS)}..."

	if { [llength $::env(VDD_NETS)] != [llength $::env(GND_NETS)] } {
		puts_err "VDD_NETS and GND_NETS must be of equal lengths"
		return -code error
	}

	# check internal macros' power connection definitions
	if {[info exists ::env(FP_PDN_MACRO_HOOKS)]} {
		set macro_hooks [dict create]
		set pdn_hooks [split $::env(FP_PDN_MACRO_HOOKS) ","]
		foreach pdn_hook $pdn_hooks {
			set instance_name [lindex $pdn_hook 0]
			set power_net [lindex $pdn_hook 1]
			set ground_net [lindex $pdn_hook 2]
			dict append macro_hooks $instance_name [subst {$power_net $ground_net}]
		}

		set power_net_indx [lsearch $::env(VDD_NETS) $power_net]
		set ground_net_indx [lsearch $::env(GND_NETS) $ground_net]

		# make sure that the specified power domains exist.
		if { $power_net_indx == -1  || $ground_net_indx == -1 || $power_net_indx != $ground_net_indx } {
			puts_err "Can't find $power_net and $ground_net domain. \
				Make sure that both exist in $::env(VDD_NETS) and $::env(GND_NETS)."
		}
	}

	gen_pdn
}

proc run_floorplan {args} {
	# |----------------------------------------------------|
	# |----------------   2. FLOORPLAN   ------------------|
	# |----------------------------------------------------|
	#
	# intial fp
	init_floorplan

	# check for deprecated io variables
	if { [info exists ::env(FP_IO_HMETAL)]} {
		set ::env(FP_IO_HLAYER) [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_HMETAL) - 1}]]
		puts_warn "You're using FP_IO_HMETAL in your configuration, which is a deprecated variable that will be removed in the future."
		puts_warn "We recommend you update your configuration as follows:"
		puts_warn "\tset ::env(FP_IO_HLAYER) {$::env(FP_IO_HLAYER)}"
	}

	if { [info exists ::env(FP_IO_VMETAL)]} {
		set ::env(FP_IO_VLAYER) [lindex $::env(TECH_METAL_LAYERS) [expr {$::env(FP_IO_VMETAL) - 1}]]
		puts_warn "You're using FP_IO_VMETAL in your configuration, which is a deprecated variable that will be removed in the future."
		puts_warn "We recommend you update your configuration as follows:"
		puts_warn "\tset ::env(FP_IO_VLAYER) {$::env(FP_IO_VLAYER)}"
	}


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
			file copy -force $::env(MACRO_PLACEMENT_CFG) $::env(placement_tmpfiles)/macro_placement.cfg
			manual_macro_placement f
		} else {
			global_placement_or
			basic_macro_placement
		}
	}

	tap_decap_or

	scrot_klayout -layout $::env(CURRENT_DEF) $::env(floorplan_logs)/screenshot.log

	run_power_grid_generation
}

package provide openlane 0.9
