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

proc run_klayout {args} {
    if {[info exists ::env(RUN_KLAYOUT)] && $::env(RUN_KLAYOUT)} {
		TIMER::timer_start
		set ::env(CURRENT_STAGE) klayout
		puts_info "Running Klayout to re-generate GDS-II..."
		if {[ info exists ::env(KLAYOUT_TECH)] } {
			puts_info "Streaming out GDS II..."
			set gds_files_in ""
			if {  [info exist ::env(EXTRA_GDS_FILES)] } {
				set gds_files_in $::env(EXTRA_GDS_FILES)
			}
			try_catch bash $::env(SCRIPTS_DIR)/klayout/def2gds.sh $::env(KLAYOUT_TECH) $::env(CURRENT_DEF) $::env(DESIGN_NAME) $::env(klayout_result_file_tag).gds "$::env(GDS_FILES) $gds_files_in" |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).log]
			if {[info exists ::env(KLAYOUT_PROPERTIES)]} {
				file copy -force $::env(KLAYOUT_PROPERTIES) $::env(klayout_result_file_tag).lyp
			} else {
				puts_warn "::env(KLAYOUT_PROPERTIES) is not defined. So, it won't be copied to the run directory."
			}
			puts_info "Back-up GDS-II streamed out."
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" >> [index_file $::env(klayout_log_file_tag)_runtime.txt 0]
			scrot_klayout -layout $::env(klayout_result_file_tag).gds
			if { [info exists ::env(KLAYOUT_DRC_KLAYOUT_GDS)] && $::env(KLAYOUT_DRC_KLAYOUT_GDS) } {
				set conf_save $::env(RUN_KLAYOUT_DRC)
				set ::env(RUN_KLAYOUT_DRC) 1
				run_klayout_drc -gds $::env(klayout_result_file_tag).gds -stage klayout
				set ::env(RUN_KLAYOUT_DRC) $conf_save
			}
		} else {
			puts_warn "::env(KLAYOUT_TECH) is not defined for the current PDK. So, GDS-II streaming out using Klayout will be skipped."
			puts_warn "Magic is the main source of streaming-out GDS-II, extraction, and DRC. So, this is not a major issue."
			puts_warn "This warning can be turned off by setting ::env(RUN_KLAYOUT) to 0, or defining a tech file."
		}
    }
}

proc scrot_klayout {args} {
    if {[info exists ::env(TAKE_LAYOUT_SCROT)] && $::env(TAKE_LAYOUT_SCROT)} {
		TIMER::timer_start
		puts_info "Taking a Screenshot of the Layout Using Klayout..."
		if {[ info exists ::env(KLAYOUT_TECH)] } {
			set options {
				{-layout optional}
			}
			parse_key_args "scrot_klayout" args arg_values $options
			if {[info exists ::env(CURRENT_GDS)]} {
				set_if_unset arg_values(-layout) $::env(CURRENT_GDS)
			}
			try_catch bash $::env(SCRIPTS_DIR)/klayout/scrotLayout.sh $::env(KLAYOUT_TECH) $arg_values(-layout) |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).scrot.log]
			puts_info "Screenshot taken."
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" >> [index_file $::env(klayout_log_file_tag)_scrot_runtime.txt 0]
		} else {
			puts_warn "::env(KLAYOUT_TECH) is not defined for the current PDK. So, we won't be able to take a PNG screenshot of the Layout."
			puts_warn "Magic is the main source of streaming-out GDS-II, extraction, and DRC. So, this is not a major issue."
			puts_warn "This warning can be turned off by setting ::env(TAKE_LAYOUT_SCROT) to 0, or defining a tech file."
		}
	}
}

proc run_klayout_drc {args} {
    if {[info exists ::env(RUN_KLAYOUT_DRC)] && $::env(RUN_KLAYOUT_DRC)} {
		TIMER::timer_start
		puts_info "Running DRC on the layout using Klayout..."
		if {[ info exists ::env(KLAYOUT_DRC_TECH_SCRIPT)] } {
			set options {
				{-gds optional}
				{-stage optional}
			}
			parse_key_args "run_klayout_drc" args arg_values $options
			if {[info exists ::env(CURRENT_GDS)]} {
				set_if_unset arg_values(-gds) $::env(CURRENT_GDS)
			}
			set_if_unset arg_values(-stage) magic
			try_catch bash $::env(SCRIPTS_DIR)/klayout/run_drc.sh $::env(KLAYOUT_DRC_TECH_SCRIPT) $arg_values(-gds) $arg_values(-gds).lydrc |& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).$arg_values(-stage).drc.log]
			file copy -force $arg_values(-gds).lydrc [index_file $::env(klayout_report_file_tag).$arg_values(-stage).lydrc 0]
			puts_info "Klayout DRC Complete"
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" >> [index_file $::env(klayout_log_file_tag)_$arg_values(-stage)\_drc_runtime.txt 0]
		} else {
			puts_warn "::env(KLAYOUT_DRC_TECH_SCRIPT) is not defined for the current PDK. So, we won't be able to run klayout drc on the GDS-II."
			puts_warn "Magic is the main source of streaming-out GDS-II, extraction, and DRC. So, this is not a major issue."
			puts_warn "This warning can be turned off by setting ::env(RUN_KLAYOUT_DRC) to 0, or defining a tech file."
		}
	}
}

proc run_klayout_gds_xor {args} {
    if {[info exists ::env(RUN_KLAYOUT_XOR)] && $::env(RUN_KLAYOUT_XOR)} {
		TIMER::timer_start
		puts_info "Running XOR on the layouts using Klayout..."
			set options {
				{-layout1 optional}
				{-layout2 optional}
				{-output_xml optional}
				{-output_gds optional}
			}
			parse_key_args "run_klayout_gds_xor" args arg_values $options
			set_if_unset arg_values(-layout1) $::env(magic_result_file_tag).gds
			set_if_unset arg_values(-layout2) $::env(klayout_result_file_tag).gds
			set_if_unset arg_values(-output_xml) $::env(klayout_result_file_tag).xor.xml
			set_if_unset arg_values(-output_gds) $::env(klayout_result_file_tag).xor.gds
			if { [file exists $arg_values(-layout1)]} {
				if { [file exists $arg_values(-layout2)] } {

					if { $::env(KLAYOUT_XOR_GDS) } {
						try_catch bash $::env(SCRIPTS_DIR)/klayout/xor.sh \
							$arg_values(-layout1) $arg_values(-layout2) $::env(DESIGN_NAME) \
							$arg_values(-output_gds) \
							|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).xor.log]
						try_catch python3 $::env(SCRIPTS_DIR)/parse_klayout_xor_log.py \
							-l [index_file $::env(klayout_log_file_tag).xor.log 0] \
							-o [index_file $::env(klayout_report_file_tag).xor.rpt 0]
						scrot_klayout -layout $arg_values(-output_gds)
					}

					if { $::env(KLAYOUT_XOR_XML) } {
						try_catch bash $::env(SCRIPTS_DIR)/klayout/xor.sh \
							$arg_values(-layout1) $arg_values(-layout2) $::env(DESIGN_NAME) \
							$arg_values(-output_xml) \
							|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(klayout_log_file_tag).xor.log]
						try_catch python3 $::env(SCRIPTS_DIR)/parse_klayout_xor_log.py \
							-l [index_file $::env(klayout_log_file_tag).xor.log 0] \
							-o [index_file $::env(klayout_report_file_tag).xor.rpt 0]
					}

					puts_info "Klayout XOR Complete"
				} else {
					puts_warn "$arg_values(-layout2) wasn't found. Skipping GDS XOR."
				}
			} else {
				puts_warn "$arg_values(-layout1) wasn't found. Skipping GDS XOR."
			}
			TIMER::timer_stop
			exec echo "[TIMER::get_runtime]" >> [index_file $::env(klayout_log_file_tag)_xor_runtime.txt 0]
	}
}

package provide openlane 0.9
