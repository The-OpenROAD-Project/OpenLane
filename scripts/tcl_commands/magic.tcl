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

proc run_magic {args} {
	TIMER::timer_start
	increment_index
	puts_info "Running Magic to generate various views..."
	# |----------------------------------------------------|
	# |----------------   6. TAPE-OUT ---------------------|
	# |----------------------------------------------------|
	puts_info "Streaming out GDS-II with Magic..."
	set ::env(CURRENT_STAGE) signoff
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
	# the following MAGTYPE better be mag for clean GDS generation
	# use load -dereference to ignore it later if needed

	set ::env(MAGTYPE) mag
	# Generate GDS and MAG views
	set ::env(MAGIC_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).magic.gds

	try_catch magic \
		-noconsole \
		-dnull \
		-rcfile $::env(MAGIC_MAGICRC) \
		$::env(SCRIPTS_DIR)/magic/mag_gds.tcl \
		</dev/null \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/gdsii.log]

	if { $::env(PRIMARY_SIGNOFF_TOOL) == "magic" } {
		set ::env(CURRENT_GDS) $::env(signoff_results)/$::env(DESIGN_NAME).gds
		file copy -force $::env(MAGIC_GDS) $::env(CURRENT_GDS)
	}

	file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
	# Take a PNG screenshot
	scrot_klayout -log $::env(cts_logs)/screenshot.log

	if { ($::env(MAGIC_GENERATE_LEF) && $::env(MAGIC_GENERATE_MAGLEF)) || $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
		puts_info "Generating MAGLEF views..."

		# Generate mag file that includes GDS pointers
		set ::env(MAGTYPE) mag
		try_catch magic \
			-noconsole \
			-dnull \
			-rcfile $::env(MAGIC_MAGICRC) \
			$::env(SCRIPTS_DIR)/magic/gds_pointers.tcl \
			</dev/null \
			|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/gds_ptrs.log]
		# Only keep the properties section in the file
		try_catch sed -i -n "/^<< properties >>/,/^<< end >>/p" $::env(signoff_tmpfiles)/gds_ptrs.mag
	}

	# If desired, copy GDS_* properties into the mag/ view
	if { $::env(MAGIC_INCLUDE_GDS_POINTERS) } {
		copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).mag
	}

	if { $::env(MAGIC_GENERATE_LEF) } {
		# Generate LEF view
		set ::env(MAGTYPE) maglef
		try_catch magic \
			-noconsole \
			-dnull \
			-rcfile $::env(MAGIC_MAGICRC) \
			$::env(SCRIPTS_DIR)/magic/lef.tcl \
			</dev/null \
			|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/lef.log]
		if { $::env(MAGIC_GENERATE_MAGLEF) } {
			# Generate MAGLEF view
			set ::env(MAGTYPE) maglef
			try_catch magic \
				-noconsole \
				-dnull \
				-rcfile $::env(MAGIC_MAGICRC) \
				$::env(SCRIPTS_DIR)/magic/maglef.tcl \
				</dev/null \
				|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/maglef.log]
			# By default, copy the GDS properties into the maglef/ view
			copy_gds_properties $::env(signoff_tmpfiles)/gds_ptrs.mag $::env(signoff_results)/$::env(DESIGN_NAME).lef.mag
		}
	}
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "gdsii - magic"
}


proc run_magic_drc {args} {
	increment_index
	TIMER::timer_start
	puts_info "Running Magic DRC..."

	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
	set ::env(drc_prefix) $::env(signoff_reports)/drc
	# Has to be maglef for DRC Checking
	set ::env(MAGTYPE) maglef

	try_catch magic \
		-noconsole \
		-dnull \
		-rcfile $::env(MAGIC_MAGICRC) \
		$::env(SCRIPTS_DIR)/magic/drc.tcl \
		</dev/null \
		|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/drc.log]

	puts_info "Converting Magic DRC Violations to Magic Readable Format..."
	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/magic_drc_to_tcl.py \
		-i $::env(drc_prefix).rpt \
		-o $::env(drc_prefix).tcl

	puts_info "Converting Magic DRC Violations to Klayout XML Database..."
	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/magic_drc_to_tr_drc.py \
		-i $::env(drc_prefix).rpt \
		-o $::env(drc_prefix).tr

	puts_info "Converting TritonRoute DRC Violations to Klayout XML Database..."
	try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/tr_drc_to_klayout_drc.py \
		-i $::env(drc_prefix).tr \
		-o $::env(drc_prefix).klayout.xml \
		--design-name $::env(DESIGN_NAME)

	if { $::env(MAGIC_CONVERT_DRC_TO_RDB) == 1 } {
		puts_info "Converting DRC Violations to RDB Format..."
		try_catch $::env(OPENROAD_BIN) -python $::env(SCRIPTS_DIR)/magic_drc_to_rdb.py \
			--magic_drc_in $::env(drc_prefix).rpt \
			--rdb_out $::env(drc_prefix).rdb
	}

	file copy -force $::env(MAGIC_MAGICRC) $::env(signoff_results)/.magicrc
	TIMER::timer_stop
	exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "drc - magic"

	quit_on_magic_drc -log $::env(drc_prefix).tr
}

proc run_magic_spice_export {args} {
	TIMER::timer_start
	increment_index
	if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
		set extract_type "gds.spice"
		puts_info "Running Magic Spice Export from GDS..."
		# GDS extracted file design.gds.spice, log file magic_gds.spice.log
	} else {
		set extract_type "spice"
		puts_info "Running Magic Spice Export from LEF..."
		# LEF extracted file design.spice (copied to design.lef.spice), log file magic_spice.log
	}

	set ::env(magic_extract_prefix) [index_file $::env(signoff_logs)/ext2]

	set ::env(EXT_NETLIST) $::env(signoff_results)/$::env(DESIGN_NAME).$extract_type
	set magic_export $::env(signoff_tmpfiles)/$extract_type.tcl
	set commands \
	"
if { \[info exist ::env(MAGIC_EXT_USE_GDS)\] && \$::env(MAGIC_EXT_USE_GDS) } {
	gds read \$::env(CURRENT_GDS)
} else {
	lef read $::env(TECH_LEF)
	if {  \[info exist ::env(EXTRA_LEFS)\] } {
		set lefs_in \$::env(EXTRA_LEFS)
		foreach lef_file \$lefs_in {
			lef read \$lef_file
		}
	}
	def read $::env(CURRENT_DEF)
}
load $::env(DESIGN_NAME) -dereference
cd $::env(signoff_results)/
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
if { ! $::env(LVS_CONNECT_BY_LABEL) } {
	extract unique
}
# extract warn all
extract

ext2spice lvs
ext2spice -o $::env(EXT_NETLIST) $::env(DESIGN_NAME).ext
feedback save $::env(magic_extract_prefix)$extract_type.feedback.txt
# exec cp $::env(DESIGN_NAME).spice $::env(signoff_results)/$::env(DESIGN_NAME).spice
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
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/$extract_type.log]

if { $extract_type == "spice" } {
	file copy -force $::env(signoff_results)/$::env(DESIGN_NAME).spice $::env(signoff_results)/$::env(DESIGN_NAME).lef.spice
}
file rename -force {*}[glob $::env(signoff_results)/*.ext] $::env(signoff_tmpfiles)
TIMER::timer_stop
exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "$extract_type extraction - magic"

quit_on_illegal_overlaps -log [index_file $::env(signoff_logs)/ext2$extract_type.feedback.txt]
}

proc export_magic_view {args} {
	TIMER::timer_start
	set options {
		{-def required}
		{-output required}
	}
	set flags {}
	parse_key_args "export_magic_views" args arg_values $options flags_map $flags
	set script_dir $::env(signoff_tmpfiles)/magic_mag_save.tcl
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
	|& tee $::env(TERMINAL_OUTPUT) [index_file $::env(signoff_logs)/save_mag.log]
TIMER::timer_stop
exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "mag export - magic"
}

proc run_magic_antenna_check {args} {
	increment_index
	TIMER::timer_start
	puts_info "Running Magic Antenna Checks..."
	set feedback_file [index_file $::env(signoff_logs)/ext2spice.antenna.feedback.txt]
	set magic_export $::env(signoff_tmpfiles)/magic_antenna.tcl
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
cd \$::env(signoff_tmpfiles)
select top cell

# for now, do extraction anyway; can be optimized by reading the maglef ext
# but getting many warnings
if { ! \[file exists \$::env(DESIGN_NAME).ext\] } {
	extract do local
	extract no capacitance
	extract no coupling
	extract no resistance
	extract no adjust
	if { ! $::env(LVS_CONNECT_BY_LABEL) } {
		extract unique
	}
	# extract warn all
	extract
	feedback save $feedback_file
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

set antenna_log [index_file $::env(signoff_logs)/antenna.log]
try_catch magic \
	-noconsole \
	-dnull \
	-rcfile $::env(MAGIC_MAGICRC) \
	$magic_export \
	</dev/null \
	|& tee $::env(TERMINAL_OUTPUT) $antenna_log

# process the log
try_catch awk "/Cell:/ {print \$2}" $antenna_log > $antenna_log

set ::env(ANTENNA_CHECKER_LOG) $antenna_log

TIMER::timer_stop
exec echo "[TIMER::get_runtime]" | python3 $::env(SCRIPTS_DIR)/write_runtime.py "antenna check - magic"

}

proc copy_gds_properties {from to} {
	# copy GDS properties from $from to $to
	set gds_properties [list]
	set fp [open $from r]
	set mag_lines [split [read $fp] "\n"]
	foreach line $mag_lines {
		if { [string first "string GDS_" $line] != -1 } {
			lappend gds_properties $line
		}
	}
	close $fp

	set fp [open $to r]
	set mag_lines [split [read $fp] "\n"]
	set new_mag_lines [list]
	foreach line $mag_lines {
		if { [string first "<< end >>" $line] != -1 } {
			lappend new_mag_lines [join $gds_properties "\n"]
		}
		lappend new_mag_lines $line
	}
	close $fp

	set fp [open $to w]
	puts $fp [join $new_mag_lines "\n"]
	close $fp
}

package provide openlane 0.9
