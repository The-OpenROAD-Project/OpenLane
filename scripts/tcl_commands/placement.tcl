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

proc global_placement {args} {
	TIMER::timer_start
	#for {set i 0} {$i < $::env(PL_IO_ITER)} {incr i} {
	try_catch replace < $::env(SCRIPTS_DIR)/replace_gp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log

		#try_catch mv $::env(replaceio_tmp_file_tag)_io.def $::env(replaceio_tmp_file_tag)_io_$i.def

		#try_catch ioPlacer \
			-l $::env(MERGED_LEF) \
			-d $::env(replaceio_tmp_file_tag)_place.def \
			-h $::env(FP_IO_HMETAL) \
			-v $::env(FP_IO_VMETAL) \
			-r $::env(FP_IO_RANDOM) \
			\
			-o $::env(replaceio_tmp_file_tag)_io.def \
			|& tee $::env(TERMINAL_OUTPUT) $::env(ioPlacer_log_file_tag).log

		#try_catch cp $::env(replaceio_tmp_file_tag)_place.def $::env(replaceio_tmp_file_tag)_place_$i.def
	#}
	try_catch cp $::env(replaceio_tmp_file_tag)_place.def $::env(replaceio_tmp_file_tag).def
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(replaceio_log_file_tag)_runtime.txt
	set_def $::env(replaceio_tmp_file_tag).def

}

proc global_placement_or {args} {
	TIMER::timer_start
	set ::env(SAVE_DEF) $::env(replaceio_tmp_file_tag).def
	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_replace.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log
	# sometimes replace fails with a ZERO exit code; the following is a workaround
	# until the cause is found and fixed
	if { ! [file exists $::env(SAVE_DEF)] } {
		puts_err "Failure in global placement"
		return -code error
	}

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(replaceio_log_file_tag)_runtime.txt
	set_def $::env(SAVE_DEF)
}

proc detailed_placement {args} {
	TIMER::timer_start
	try_catch opendp \
		-lef $::env(MERGED_LEF) \
		-def $::env(CURRENT_DEF) \
		-output_def $::env(opendp_result_file_tag).def \
		|& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(opendp_log_file_tag)_runtime.txt
#	if {[catch {exec grep -q "FAIL" $::env(opendp_log_file_tag).log}] == 0}  {
#		puts "Error: Check $::env(opendp_log_file_tag).log"
#		puts stderr "\[ERROR\]: Check $::env(opendp_log_file_tag).log"
#		exit 1
#	}
	set_def $::env(opendp_result_file_tag).def
}
proc add_macro_placement {args} {
	puts_info " Adding Macro Placement..."
	set ori "NONE"
	if { [llength $args] == 4 } {
		set ori [lindex $args 3]
	}
	try_catch echo [lindex $args 0] [lindex $args 1] [lindex $args 2] $ori >> $::env(TMP_DIR)/macro_placements.cfg
}

proc manual_macro_placement {args} {
	puts_info " Manual Macro Placement..."
	set var "f"
	if { [string compare [lindex $args 0] $var] == 0 } {
		try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -i $::env(CURRENT_DEF) -o $::env(CURRENT_DEF).macro_placement -c $::env(TMP_DIR)/macro_placements.cfg -f |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/macro_placement.log
	} else {
		try_catch python3 $::env(SCRIPTS_DIR)/manual_macro_place.py -i $::env(CURRENT_DEF) -o $::env(CURRENT_DEF).macro_placement -c $::env(TMP_DIR)/macro_placements.cfg |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/macro_placement.log
	}	
	file rename -force $::env(CURRENT_DEF).macro_placement $::env(CURRENT_DEF)
}

proc detailed_placement_or {args} {
	TIMER::timer_start
	set ::env(SAVE_DEF) $::env(opendp_result_file_tag).def

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log
	set_def $::env(SAVE_DEF)

	if {[catch {exec grep -q -i "fail" $::env(opendp_log_file_tag).log}] == 0}  {
		puts_info "Error in detailed placement"
		puts_info "Retrying detailed placement"
		set ::env(SAVE_DEF) $::env(opendp_result_file_tag).1.def

		try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_opendp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(opendp_log_file_tag).log

	}

	if {[catch {exec grep -q -i "fail" $::env(opendp_log_file_tag).log}] == 0}  {
		puts "Error: Check $::env(opendp_log_file_tag).log"
		puts stderr "\[ERROR\]: Check $::env(opendp_log_file_tag).log"
		exit 1
	}



	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(opendp_log_file_tag)_runtime.txt
	set_def $::env(SAVE_DEF)
}

proc basic_macro_placement {args} {
	TIMER::timer_start
	set ::env(SAVE_DEF) $::env(CURRENT_DEF)

	try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_basic_mp.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/basic_mp.log

	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" >> $::env(LOG_DIR)/placement/basic_mp_runtime.txt
	set_def $::env(SAVE_DEF)
}

proc run_placement {args} {
	puts "\[INFO\]: Running Placement..."
# |----------------------------------------------------|
# |----------------   3. PLACEMENT   ------------------|
# |----------------------------------------------------|
	set ::env(CURRENT_STAGE) placement

	global_placement_or
	if { $::env(RUN_RESIZER_OVERBUFFER) == 1} {
		repair_wire_length
	}
	#try_catch replace < $::env(SCRIPTS_DIR)/replace_io.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(replaceio_log_file_tag).log
	#try_catch Psn --verbose --file $::env(SCRIPTS_DIR)/psn.tcl |& tee /dev/tty $::env(psn_log_file_tag).log

	# GIFing the result
	#puts "Generating Placement GIF"
	#try_catch convert -delay 20 {*}[lsort [glob $::env(RESULTS_DIR)/4_placement/etc/3_floorplanning/output/cell/*.jpg]] \
		-delay 100 $::env(RESULTS_DIR)/4_placement/etc/3_floorplanning/output/globalPlaceResult.jpg \
		\
		$::env(RESULTS_DIR)/4_placement.gif \
		|& tee $::env(TERMINAL_OUTPUT)

	#try_catch cp $::env(RESULTS_DIR)/4_placement/etc/3_floorplanning/output/3_floorplan_final.def $::env(RESULTS_DIR)/4_1_place_gp.def

	# outputs: 4_1_place_gp.def

	# detailed 4_placement
	detailed_placement
}

proc repair_wire_length {args} {
        set ::env(SAVE_DEF) $::env(CURRENT_DEF)
        try_catch openroad -exit $::env(SCRIPTS_DIR)/openroad/or_wireLengthRepair.tcl |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/resizer.log
}

package provide openlane 0.9
