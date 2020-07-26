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
