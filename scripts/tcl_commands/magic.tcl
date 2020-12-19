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

proc run_magic {args} {
		puts_info "Running Magic to generate various views..."
		# |----------------------------------------------------|
		# |----------------   6. TAPE-OUT ---------------------|
		# |----------------------------------------------------|
		puts_info "Streaming out GDS II..."
		set ::env(CURRENT_STAGE) finishing

		set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
		# the following MAGTYPE better be mag for clean GDS generation
		# use load -dereference to ignore it later if needed
		set ::env(MAGTYPE) mag
		# Generate GDS and MAG views
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/mag_gds.tcl \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).log
		set ::env(CURRENT_GDS) $::env(magic_result_file_tag).gds
		file copy -force $::env(MAGIC_MAGICRC) $::env(RESULTS_DIR)/magic/.magicrc

		set ::env(MAGTYPE) maglef
		# Generate LEF view
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/lef.tcl \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).lef.log

		# Generate MAGLEF view
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/maglef.tcl \
			 	</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).maglef.log

		if { [info exists ::env(MAGIC_INCLUDE_GDS_POINTERS)] \
			&& $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
			set ::env(MAGTYPE) mag
			try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/mag.tcl \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).mag.log

			# copy GDS properties from the MAG view into the MAGLEF view
			set gds_properties [list]
			set fp [open $::env(magic_result_file_tag).mag r]
			set mag_lines [split [read $fp] "\n"]
			foreach line $mag_lines {
				if { [string first "string GDS_" $line] != -1 } {
					lappend gds_properties $line
				}
			}
			close $fp

			set fp [open $::env(magic_result_file_tag).lef.mag r]
			set mag_lines [split [read $fp] "\n"]
			set new_mag_lines [list]
			foreach line $mag_lines {
				if { [string first "<< end >>" $line] != -1 } {
					lappend new_mag_lines [join $gds_properties "\n"]
				}
				lappend new_mag_lines $line
			}
			close $fp

			set fp [open $::env(magic_result_file_tag).lef.mag w]
			puts $fp [join $new_mag_lines "\n"]
			close $fp
		}
}


proc run_magic_drc {args} {
		puts_info "Running Magic DRC..."
		set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
		# the following MAGTYPE has to be maglef for the purpose of DRC checking
		set ::env(MAGTYPE) maglef
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/drc.tcl \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).drc.log
		if { $::env(MAGIC_CONVERT_DRC_TO_RDB) == 1 } {
			puts_info "Converting DRC Violations to Klayout RDB Format..."
			try_catch python3 $::env(SCRIPTS_DIR)/magic_drc_to_rdb.py \
				--magic_drc_in $::env(magic_log_file_tag).drc \
				--rdb_out $::env(magic_result_file_tag).drc.rdb
			puts_info "Converted DRC Violations to Klayout RDB Format"
		}
		file copy -force $::env(MAGIC_MAGICRC) $::env(RESULTS_DIR)/magic/.magicrc
}


proc run_magic_spice_export {args} {
		puts_info "Running Magic Spice Export..."
		set magic_export $::env(TMP_DIR)/magic_spice.tcl
		set commands \
"
lef read $::env(TECH_LEF)
if {  \[info exist ::env(EXTRA_LEFS)\] } {
	set lefs_in \$::env(EXTRA_LEFS)
	foreach lef_file \$lefs_in {
		lef read \$lef_file
	}
}
def read $::env(CURRENT_DEF)
load $::env(DESIGN_NAME) -dereference
cd $::env(RESULTS_DIR)/magic/
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
extract unique
# extract warn all
extract

ext2spice lvs
ext2spice $::env(DESIGN_NAME).ext
feedback save $::env(magic_log_file_tag)_ext2spice.feedback.txt
# exec cp $::env(DESIGN_NAME).spice $::env(magic_result_file_tag).spice
"
		set magic_export_file [open $magic_export w]
		puts $magic_export_file $commands
		close $magic_export_file
		set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
		# the following MAGTYPE has to be maglef for the purpose of LVS
		# otherwise underlying device circuits would be considered
		set ::env(MAGTYPE) maglef
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$magic_export \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_spice.log
                file copy -force $::env(magic_result_file_tag).spice $::env(magic_result_file_tag).lef.spice
}

proc export_magic_view {args} {
		set options {
				{-def required}
				{-output required}
		}
		set flags {}
		parse_key_args "export_magic_views" args arg_values $options flags_map $flags
		set script_dir $::env(TMP_DIR)/magic_mag_save.tcl
		set commands \
"
lef read $::env(TECH_LEF)
if {  \[info exist ::env(EXTRA_LEFS)\] } {
	set lefs_in \$::env(EXTRA_LEFS)
	foreach lef_file \$lefs_in {
		lef read \$lef_file
	}
}
def read $arg_values(-def)
save $arg_values(-output)
puts \"\[INFO\]: Done exporting $arg_values(-output)\"
"
		set stream [open $script_dir w]
		puts $stream $commands
		close $stream
		set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$script_dir \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_save_mag.log
}

proc run_magic_antenna_check {args} {
		puts_info "Running Magic Antenna Checks..."
		set magic_export $::env(TMP_DIR)/magic_antenna.tcl
		set commands \
"
lef read \$::env(TECH_LEF)
if {  \[info exist ::env(EXTRA_LEFS)\] } {
	set lefs_in \$::env(EXTRA_LEFS)
	foreach lef_file \$lefs_in {
		lef read \$lef_file
	}
}
def read \$::env(CURRENT_DEF)
load \$::env(DESIGN_NAME) -dereference
cd \$::env(TMP_DIR)/magic/
select top cell

# for now, do extraction anyway; can be optimized by reading the maglef ext
# but getting many warnings
if { ! \[file exists \$::env(DESIGN_NAME).ext\] } {
	extract do local
	extract no capacitance
	extract no coupling
	extract no resistance
	extract no adjust
	extract unique
	# extract warn all
	extract
	feedback save $::env(magic_log_file_tag)_ext2spice.antenna.feedback.txt
}
antennacheck debug
antennacheck
"
		set magic_export_file [open $magic_export w]
		puts $magic_export_file $commands
		close $magic_export_file
		set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
		# the following MAGTYPE has to be mag; antennacheck needs to know
		# about the underlying devices, layers, etc.
		set ::env(MAGTYPE) mag
		try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$magic_export \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_antenna.log

		# process the log
		try_catch awk "/Cell:/ {print \$2}" $::env(magic_log_file_tag)_antenna.log \
				> $::env(magic_report_file_tag).antenna_violators.rpt
}

package provide openlane 0.9
