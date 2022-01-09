# Design
set ::env(DESIGN_NAME) "genericfir"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/genericfir.v"

set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) {1}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}