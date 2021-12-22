# Design

# User config
set ::env(DESIGN_NAME) BM64

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
set ::env(CLOCK_PORT) "Clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# design has a lot of pins, needs an absolute size
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) {0 0 1000 1000}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}