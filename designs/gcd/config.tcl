# Design
set ::env(DESIGN_NAME) "gcd"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/*.v]

set ::env(CLOCK_PORT) "clk"

# Use OR defaults
set ::env(FP_IO_VLENGTH) ""
set ::env(FP_IO_HLENGTH) ""
set ::env(FP_IO_VTHICKNESS_MULT) ""
set ::env(FP_IO_HTHICKNESS_MULT) ""
set ::env(FP_IO_MIN_DISTANCE) ""

set filename ./designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
