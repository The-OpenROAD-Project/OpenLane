# Design
set ::env(DESIGN_NAME) "aes_cipher"

set ::env(VERILOG_FILES) [glob ./designs/aes_cipher/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(FP_CORE_UTIL) {10}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
