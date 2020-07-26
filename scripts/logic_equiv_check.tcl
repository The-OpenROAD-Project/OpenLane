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
#set sdc_file $::env(SDC_FILE)
set sclib $::env(LIB_SYNTH)

set well_tap_cell "$::env(FP_WELLTAP_CELL)"
set decap_cell_wildcard "$::env(DECAP_CELL)*"
set fill_cell_wildcard "$::env(FILL_CELL)*"

if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}

# LHS
read_verilog $::env(LEC_LHS_NETLIST)
rmports
hierarchy -generate $well_tap_cell
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
splitnets -ports;;
hierarchy -auto-top
stat
renames -top gold
design -stash gold

# RHS
read_verilog $::env(LEC_RHS_NETLIST)
rmports
hierarchy -generate $well_tap_cell
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
splitnets -ports;;
hierarchy -auto-top
stat
renames -top gate
design -stash gate

read_liberty -ignore_miss_func $::env(LIB_SYNTH_COMPLETE)

design -copy-from gold -as gold gold
design -copy-from gate -as gate gate

equiv_make gold gate equiv
hierarchy -generate $well_tap_cell
hierarchy -generate $decap_cell_wildcard
hierarchy -generate $fill_cell_wildcard
prep -flatten -top equiv
equiv_simple -seq 10 -v
equiv_status -assert
