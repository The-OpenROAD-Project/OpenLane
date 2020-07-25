# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

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
