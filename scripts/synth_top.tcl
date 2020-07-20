# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
set vtop $::env(DESIGN_NAME)
#set sdc_file $::env(SDC_FILE)
set sclib $::env(LIB_SYNTH)
yosys -import

set stat_ext    ".stat.rpt"
set chk_ext    ".chk.rpt"
set gl_ext      ".gl.v"
set timing_ext  ".timing.txt"
set abc_ext     ".abc"

if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		verilog_defines -D$define
	}
}

if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -lib $verilog_file
	}
}
if { $::env(SYNTH_READ_BLACKBOX_LIB) } {
	read_liberty -lib -ignore_miss_dir -setattr blackbox $::env(LIB_SYNTH_COMPLETE)
}


for { set i 0 } { $i < [llength $::env(VERILOG_FILES)] } { incr i } {
  read_verilog  [lindex $::env(VERILOG_FILES) $i]
}

hierarchy -check -top $vtop
#setattr -set keep 1
#synth -top $vtop
tee -o "$::env(yosys_report_file_tag)_synth.stat" stat
#debug opt_clean -purge
#setundef -zero
#splitnets
tee -o "$::env(yosys_report_file_tag)_$chk_ext" check
tee -o "$::env(yosys_report_file_tag)$stat_ext" stat -top $vtop -liberty $sclib
write_verilog -noattr -noexpr -nohex -nodec "$::env(yosys_result_file_tag).v"
