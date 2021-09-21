# User config
set ::env(DESIGN_NAME) ibex_core

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
#Synthesis
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/constraint.sdc
#Floorplan
set ::env(FP_CORE_UTIL) "20"

set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk_i"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}


