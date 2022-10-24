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

proc exclude_fills {args} {
	set fills "$::env(CELL_PAD_EXCLUDE)"
	foreach fill_wildcard $fills {
		hierarchy -generate $fill_wildcard
	}
}

proc initialize {args} {
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
	foreach lib $::env(LIB_TYPICAL) {
		read_liberty -ignore_miss_func -ignore_miss_dir $lib
	}
}

proc read_nl {netlist name} {
	initialize
	read_verilog $netlist

	rmports

	exclude_fills

	splitnets -ports
	hierarchy -top $::env(DESIGN_NAME)

	if { $::env(SYNTH_FLAT_TOP) } {
		flatten
	}

	stat
	renames -top $name
	design -stash $name
}

# LHS
read_nl $::env(LEC_LHS_NETLIST) gold

# RHS
read_nl $::env(LEC_RHS_NETLIST) gate

# LEC
design -copy-from gold -as gold gold
design -copy-from gate -as gate gate

initialize
exclude_fills

equiv_make gold gate equiv
prep -flatten -top equiv
equiv_simple -seq 10 -v
equiv_status -assert
