# Design
set ::env(DESIGN_NAME) "gcd"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/*.v]

set ::env(CLOCK_PORT) "clk"

# match ORFS
set ::env(SYNTH_STRATEGY) "DELAY 4"
set ::env(SYNTH_SHARE_RESOURCES) 0

# Use OR defaults
set ::env(FP_IO_VLENGTH) ""
set ::env(FP_IO_HLENGTH) ""
set ::env(FP_IO_VTHICKNESS_MULT) ""
set ::env(FP_IO_HTHICKNESS_MULT) ""
set ::env(FP_IO_MIN_DISTANCE) ""

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
