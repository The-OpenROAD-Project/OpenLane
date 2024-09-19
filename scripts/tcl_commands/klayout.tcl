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

proc run_klayout {args} {
	if {[ info exists ::env(KLAYOUT_TECH)] } {
		increment_index
		set log [index_file $::env(signoff_logs)/gdsii-klayout.log]
		TIMER::timer_start
		puts_info "Streaming out GDSII with KLayout (log: [relpath . $log])..."
		set gds_files_in ""
		if {  [info exist ::env(EXTRA_GDS_FILES)] } {
			set gds_files_in $::env(EXTRA_GDS_FILES)
		}
		if { $::env(STD_CELL_LIBRARY_OPT) != $::env(STD_CELL_LIBRARY) } {
			set cells_gds "$::env(GDS_FILES) $::env(GDS_FILES_OPT)"
		} else {
			set cells_gds $::env(GDS_FILES)
		}

		set gds_file_arg ""
		foreach gds_file "$cells_gds $gds_files_in" {
			set gds_file_arg "$gds_file_arg --with-gds-file $gds_file"
		}
		set klayout_out $::env(signoff_results)/$::env(DESIGN_NAME).klayout.gds
		try_exec python3 $::env(SCRIPTS_DIR)/klayout/stream_out.py\
			--output $klayout_out\
			--lyt $::env(KLAYOUT_TECH)\
			--lym $::env(KLAYOUT_DEF_LAYER_MAP)\
			--lyp $::env(KLAYOUT_PROPERTIES)\
			--top $::env(DESIGN_NAME)\
			{*}$gds_file_arg \
			--input-lef $::env(MERGED_LEF)\
			$::env(CURRENT_DEF)\
			|& tee $::env(TERMINAL_OUTPUT) $log


		if {[info exists ::env(KLAYOUT_PROPERTIES)]} {
			file copy -force $::env(KLAYOUT_PROPERTIES) $::env(signoff_results)/$::env(DESIGN_NAME).lyp
		} else {
			puts_warn "::env(KLAYOUT_PROPERTIES) is not defined. So, it won't be copied to the run directory."
		}


		if { $::env(PRIMARY_SIGNOFF_TOOL) == "klayout" } {
			set ::env(CURRENT_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).gds
			file copy -force $klayout_out $::env(CURRENT_GDS)
		}

		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "gdsii - klayout"
		scrot_klayout -layout $::env(signoff_results)/$::env(DESIGN_NAME).gds -log $::env(signoff_logs)/screenshot.klayout.log
	} elseif { $::env(PRIMARY_SIGNOFF_TOOL) != "klayout" } {
		puts_warn "::env(KLAYOUT_TECH) is not defined for the current PDK. So, GDSII streaming out using KLayout will be skipped."
		puts_warn "This warning can be turned off by setting ::env(RUN_KLAYOUT) to 0, or defining a tech file."
	} else {
		puts_err "::env(KLAYOUT_TECH) is not defined for the current PDK, however KLayout is set as the primary signoff tool. This is a critical error."
		throw_error
	}

}

proc scrot_klayout {args} {
	if {$::env(TAKE_LAYOUT_SCROT)} {
		if {[ info exists ::env(KLAYOUT_TECH)] } {
			set options {
				{-log required}
				{-layout optional}
			}
			parse_key_args "scrot_klayout" args arg_values $options
			if {[info exists ::env(CURRENT_GDS)]} {
				set_if_unset arg_values(-layout) $::env(CURRENT_GDS)
			}
			increment_index
			TIMER::timer_start
			set log [index_file $arg_values(-log)]
			puts_info "Creating a screenshot using KLayout (log: [relpath . $log])..."

			try_exec bash $::env(SCRIPTS_DIR)/klayout/scrotLayout.sh $::env(KLAYOUT_TECH) $arg_values(-layout) |& tee $::env(TERMINAL_OUTPUT) $log
			puts_info "Screenshot taken."
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "screenshot - klayout"
		} elseif { $::env(PRIMARY_SIGNOFF_TOOL) != "klayout" } {
			puts_warn "::env(KLAYOUT_DRC_TECH_SCRIPT) is not defined for the current PDK. So, GDSII streaming out using KLayout will be skipped."
			puts_warn "This warning can be turned off by setting ::env(RUN_KLAYOUT_DRC) to 0, or designating a tech file."
		} else {
			puts_err "::env(KLAYOUT_DRC_TECH_SCRIPT) is not defined for the current PDK, however KLayout is set as the primary signoff tool. This is a critical error."
			throw_error
		}
	}
}

proc run_klayout_drc {args} {
	if {[ info exists ::env(KLAYOUT_DRC_TECH_SCRIPT)] && [file exists $::env(KLAYOUT_DRC_TECH_SCRIPT)]} {
		set options {
			{-gds optional}
			{-stage optional}
		}
		parse_key_args "run_klayout_drc" args arg_values $options
		if {[info exists ::env(CURRENT_GDS)]} {
			set_if_unset arg_values(-gds) $::env(CURRENT_GDS)
		}
		set_if_unset arg_values(-stage) magic

		increment_index
		TIMER::timer_start
		set log [index_file $::env(signoff_logs)/$arg_values(-stage).drc.log]
		puts_info "Running DRC on the layout using KLayout (log: [relpath . $log])..."

		try_exec bash $::env(SCRIPTS_DIR)/klayout/run_drc.sh $::env(KLAYOUT_DRC_TECH_SCRIPT) $arg_values(-gds) $arg_values(-gds).lydrc |& tee $::env(TERMINAL_OUTPUT) $log
		file copy -force $arg_values(-gds).lydrc [index_file $::env(signoff_reports)/$arg_values(-stage).lydrc]
		puts_info "KLayout DRC Complete"
		TIMER::timer_stop
		exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "drc - klayout"
	} elseif { $::env(PRIMARY_SIGNOFF_TOOL) != "klayout" } {
		puts_warn "::env(KLAYOUT_DRC_TECH_SCRIPT) is not defined or doesn't exist for the current PDK. So, GDSII streaming out using KLayout will be skipped."
		puts_warn "This warning can be turned off by setting ::env(RUN_KLAYOUT_DRC) to 0, or designating a tech file."
	} else {
		puts_err "::env(KLAYOUT_DRC_TECH_SCRIPT) is not defined or doesn't exist for the current PDK, however KLayout is set as the primary signoff tool. This is a critical error."
		throw_error
	}
}

proc run_klayout_gds_xor {args} {
	set options {
		{-layout1 optional}
		{-layout2 optional}
		{-output_xml optional}
		{-output_gds optional}
	}
	parse_key_args "run_klayout_gds_xor" args arg_values $options
	set_if_unset arg_values(-layout1) $::env(signoff_results)/$::env(DESIGN_NAME).gds
	set_if_unset arg_values(-layout2) $::env(signoff_results)/$::env(DESIGN_NAME).klayout.gds
	set_if_unset arg_values(-output_xml) $::env(signoff_reports)/$::env(DESIGN_NAME).xor.xml
	set_if_unset arg_values(-output_gds) $::env(signoff_reports)/$::env(DESIGN_NAME).xor.gds

	if { [file exists $arg_values(-layout1)]} {
		if { [file exists $arg_values(-layout2)] } {

			increment_index
			TIMER::timer_start
			set log [index_file $::env(signoff_logs)/xor.log]
			set report [index_file $::env(signoff_reports)/xor.rpt]
			set db [index_file $::env(signoff_reports)/xor.xml]
			puts_info "Running XOR on the layouts using KLayout (log: [relpath . $log])..."
			try_exec klayout \
				-b \
				-r $::env(SCRIPTS_DIR)/klayout/xor.drc \
				-rd a=$arg_values(-layout1) \
				-rd b=$arg_values(-layout2) \
				-rd jobs=$::env(KLAYOUT_XOR_THREADS) \
				-rd rdb_out=$db \
				-rd ignore=$::env(KLAYOUT_XOR_IGNORE_LAYERS) \
				-rd rpt_out=$report \
				|& tee $::env(TERMINAL_OUTPUT) $log
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "xor - klayout"

			if { [info exists ::env(QUIT_ON_XOR_ERROR)] && $::env(QUIT_ON_XOR_ERROR) } {
				quit_on_xor_error  -log $report
			}
		} else {
			set layout2_rel [relpath . $arg_values(-layout2)]
			puts_warn "'$layout2_rel' wasn't found. Skipping GDS XOR."
		}
	} else {
		set layout1_rel [relpath . $arg_values(-layout1)]
		puts_warn "'$layout1_rel' wasn't found. Skipping GDS XOR."
	}
}

proc open_in_klayout {args} {
	set options {
		{-layout optional}
	}
	parse_key_args "open_in_klayout" args arg_values $options

	set_if_unset arg_values(-layout) $::env(CURRENT_DEF)

	try_exec python3 $::env(SCRIPTS_DIR)/klayout/open_design.py\
		--input-lef $::env(MERGED_LEF)\
		--lyt $::env(KLAYOUT_TECH)\
		--lyp $::env(KLAYOUT_PROPERTIES)\
		--lym $::env(KLAYOUT_DEF_LAYER_MAP)\
		$arg_values(-layout)
}
