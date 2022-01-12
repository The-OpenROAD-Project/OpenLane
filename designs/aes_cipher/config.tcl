# Design
set ::env(DESIGN_NAME) "aes_cipher"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(FP_CORE_UTIL) {10}

set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) {70}
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) {70}

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) {1}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
