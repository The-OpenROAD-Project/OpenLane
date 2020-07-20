proc run_magic {args} {
	puts_info "Running Magic..."
# |----------------------------------------------------|
# |----------------   6. TAPE-OUT ---------------------|
# |----------------------------------------------------|
	puts_info "Streaming out GDS II..."
	set ::env(CURRENT_STAGE) finishing

	set magicrc $::env(TMP_DIR)/magic_gen.magicrc
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
	# the following MAGTYPE better be mag for clean GDS generation
	# use load -dereference to ignore it later if needed
	set ::env(MAGTYPE) mag
	set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
	exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
	exec magic \
	  -noconsole \
	  -dnull \
	  -rcfile $magicrc \
	  $::env(SCRIPTS_DIR)/magic.tcl \
	  </dev/null \
	  |& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).log
	# fix off-grid points
	# if { [file exists $::env(magic_result_file_tag).lef] } {
	# 	try_catch python3 $::env(SCRIPTS_DIR)/lef_enforce_manufacturing_grid.py 0.005 < $::env(magic_result_file_tag).lef > $::env(magic_result_file_tag).discrete.lef
	# 	file rename -force $::env(magic_result_file_tag).discrete.lef $::env(magic_result_file_tag).lef
	# }

#		set PDKPATH $::env(PDK_ROOT)/$::env(PDK)/
#		set tech $PDKPATH/libs.tech/magic/current/EFS8A.tech
#		cd $::env(TMP_DIR)
#		exec /ef/apps/bin/magicGdrc -T $tech $::env(magic_result_file_tag).gds $::env(DESIGN_NAME) \
		|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).drc
}


proc run_magic_drc {args} {
	puts_info "Running Magic DRC..."
	set magicrc $::env(TMP_DIR)/magic_drc.magicrc
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)"
	# the following MAGTYPE has to be maglef for the purpose of DRC checking
	set ::env(MAGTYPE) maglef
	set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
	exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
	exec magic \
	  -noconsole \
	  -dnull \
	  -rcfile $magicrc \
	  $::env(SCRIPTS_DIR)/magic_drc.tcl \
	  </dev/null \
	  |& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag).drc.log
}


proc run_magic_spice_export {args} {
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
extract warn all
extract
ext2spice lvs
ext2spice $::env(DESIGN_NAME).ext
# exec cp $::env(DESIGN_NAME).spice $::env(magic_result_file_tag).spice
"
	set magic_export_file [open $magic_export w]
		puts $magic_export_file $commands
	close $magic_export_file
	set magicrc $::env(TMP_DIR)/tmp.magicrc
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
	# the following MAGTYPE has to be maglef for the purpose of LVS
	# otherwise underlying device circuits would be considered
	set ::env(MAGTYPE) maglef
	set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
	exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
	try_catch magic \
		-noconsole \
		-dnull \
		-rcfile $magicrc \
		$magic_export \
		</dev/null \
		|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_spice.log

}

proc export_magic_view {args} {
	set options {{-def required} \
			{-output required}}
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
	set magicrc $::env(TMP_DIR)/tmp.magicrc
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
	set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/maglef"
	exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
	try_catch magic \
		-noconsole \
		-dnull \
		-rcfile $magicrc \
		$script_dir \
		</dev/null \
		|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_save_mag.log
}

proc run_magic_antenna_check {args} {
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
	extract warn all
	extract
}
antennacheck debug
antennacheck 
"
	set magic_export_file [open $magic_export w]
		puts $magic_export_file $commands
	close $magic_export_file
	set magicrc $::env(TMP_DIR)/magic_antenna.magicrc
	set ::env(PDKPATH) "$::env(PDK_ROOT)/$::env(PDK)/"
	# the following MAGTYPE has to be mag; antennacheck needs to know
	# about the underlying devices, layers, etc.
	set ::env(MAGTYPE) mag
	set ::env(MAGPATH) "$::env(PDKPATH)/libs.ref/$::env(MAGTYPE)"
	exec envsubst < $::env(MAGIC_MAGICRC) > $magicrc
	try_catch magic \
		-noconsole \
		-dnull \
		-rcfile $magicrc \
		$magic_export \
		</dev/null \
		|& tee $::env(TERMINAL_OUTPUT) $::env(magic_log_file_tag)_antenna.log

	# process the log
	try_catch awk "/Cell:/ {print \$2}" $::env(magic_log_file_tag)_antenna.log \
		> $::env(magic_report_file_tag).antenna_violators.rpt
}


package provide openlane 0.9
