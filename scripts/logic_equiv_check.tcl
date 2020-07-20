# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

yosys -import
set vtop $::env(DESIGN_NAME)
#set sdc_file $::env(SDC_FILE)
set sclib $::env(LIB_SYNTH)

if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}


read_verilog $::env(LEC_LHS_NETLIST); splitnets -ports;;; hierarchy -auto-top; renames -top gold; design -stash gold; 

read_verilog $::env(LEC_RHS_NETLIST); splitnets -ports;;; hierarchy -auto-top; renames -top gate; design -stash gate; 

read_liberty -lib  $::env(LIB_SYNTH_COMPLETE)

design -copy-from gold -as gold gold; design -copy-from gate -as gate gate; 

equiv_make gold gate equiv
hierarchy -generate \\scs8hd_tapvpwrvgnd_1
prep -flatten -top equiv;
equiv_simple -seq 10 -v; equiv_status;


# miter -equiv -make_assert -make_outputs -ignore_gold_x  ${vtop}_lhs ${vtop}_rhs miter

# write_verilog $::env(yosys_tmp_file_tag).miter.h

# flatten miter

# sat -seq 10 -prove-asserts -set-init-undef -show-inputs -show-outputs -enable_undef -ignore_unknown_cells miter 
