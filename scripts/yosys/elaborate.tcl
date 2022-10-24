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
yosys -import

set vtop $::env(DESIGN_NAME)
set sclib $::env(LIB_SYNTH)

set stat_ext    ".stat.rpt"
set chk_ext    ".chk.rpt"
set gl_ext      ".gl.v"
set timing_ext  ".timing.txt"
set abc_ext     ".abc"

if { $::env(SYNTH_READ_BLACKBOX_LIB) } {
	foreach lib $::env(LIB_SYNTH_COMPLETE_NO_PG) {
		read_liberty -lib -ignore_miss_dir -setattr blackbox $lib
	}
}

if { [info exists ::env(EXTRA_LIBS) ] } {
	foreach lib $::env(EXTRA_LIBS) {
		read_liberty -lib -ignore_miss_dir -setattr blackbox $lib
	}
}


if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		verilog_defines -D$define
	}
}

set vIdirsArgs ""
if {[info exist ::env(VERILOG_INCLUDE_DIRS)]} {
	foreach dir $::env(VERILOG_INCLUDE_DIRS) {
		lappend vIdirsArgs "-I$dir"
	}
	set vIdirsArgs [join $vIdirsArgs]
}

if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -lib {*}$vIdirsArgs $verilog_file
	}
}


for { set i 0 } { $i < [llength $::env(VERILOG_FILES)] } { incr i } {
	read_verilog {*}$vIdirsArgs [lindex $::env(VERILOG_FILES) $i]
}

if { [info exists ::env(SYNTH_PARAMETERS) ] } {
	foreach define $::env(SYNTH_PARAMETERS) {
		set param_and_value [split $define "="]
		lassign $param_and_value param value
		chparam -set $param $value $vtop
	}
}

select -module $vtop
show -format dot -prefix $::env(synthesis_tmpfiles)/hierarchy
select -clear

hierarchy -check -top $vtop
if { $::env(SYNTH_FLAT_TOP) } {
	flatten
}

setattr -set keep 1
#synth -top $vtop
tee -o "$::env(synth_report_prefix).stat" stat


#debug opt_clean -purge
#setundef -zero
splitnets
opt_clean -purge
tee -o "$::env(synth_report_prefix)$chk_ext" check
tee -o "$::env(synth_report_prefix)$stat_ext" stat -top $vtop -liberty $sclib
write_verilog -noattr -noexpr -nohex -nodec -defparam "$::env(SAVE_NETLIST)"
