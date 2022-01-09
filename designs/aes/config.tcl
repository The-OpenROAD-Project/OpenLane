
# Design
set ::env(DESIGN_NAME) "aes"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/aes.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(FP_CORE_UTIL) {15}

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) {1}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
