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
yosys -import

if { [info exists ::env(FP_WELLTAP_CELL)] && $::env(FP_WELLTAP_CELL) ne ""} {
	set well_tap_cell "$::env(FP_WELLTAP_CELL)"
}
set decap_cell_wildcard "$::env(DECAP_CELL)*"
set fill_cell_wildcard "$::env(FILL_CELL)*"

set vtop $::env(DESIGN_NAME)
#set sdc_file $::env(SDC_FILE)

# LHS
if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}
if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -lib $verilog_file
	}
}
foreach lib $::env(LIB_SYNTH_COMPLETE_NO_PG) {
	read_liberty -nooverwrite -lib -ignore_miss_dir -setattr blackbox $lib
}

read_verilog $::env(LEC_LHS_NETLIST)
rmports
if { [info exists well_tap_cell] } {
	hierarchy -generate $well_tap_cell
}
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
splitnets -ports;;
hierarchy -auto-top
if { $::env(SYNTH_FLAT_TOP) } {
	flatten
}
setattr -set keep 1
stat
renames -top gold
design -stash gold


# RHS
# Rebuild the database due to -stash
if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}
if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -lib $verilog_file
	}
}
foreach lib $::env(LIB_SYNTH_COMPLETE_NO_PG) {
	read_liberty -nooverwrite -lib -ignore_miss_dir -setattr blackbox $lib
}

read_verilog $::env(LEC_RHS_NETLIST)
rmports
if { [info exists well_tap_cell] } {
	hierarchy -generate $well_tap_cell
}
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
splitnets -ports;;
hierarchy -auto-top
if { $::env(SYNTH_FLAT_TOP) } {
	flatten
}
setattr -set keep 1
stat
renames -top gate
design -stash gate


design -copy-from gold -as gold gold
design -copy-from gate -as gate gate

# Rebuild the database due to -stash
if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}
if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -lib $verilog_file
	}
}
foreach lib $::env(LIB_SYNTH_COMPLETE_NO_PG) {
	read_liberty -nooverwrite -lib -ignore_miss_dir -setattr blackbox $lib
}

equiv_make gold gate equiv
if { [info exists well_tap_cell] } {
	hierarchy -generate $well_tap_cell
}
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
setattr -set keep 1
prep -flatten -top equiv
equiv_simple -seq 10 -v
equiv_status -assert
