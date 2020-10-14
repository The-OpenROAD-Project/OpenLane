# User config
set ::env(DESIGN_NAME) inverter

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# https://github.com/efabless/openlane/blob/master/configuration/README.md

# Fill this
set ::env(CLOCK_PERIOD) 0
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""

set ::env(FP_CORE_UTIL) 5;
set ::env(PL_TARGET_DENSITY) 0.5

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
