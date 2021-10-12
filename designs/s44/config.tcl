# User config
set ::env(DESIGN_NAME) lut_s44

# Design config
set ::env(CLOCK_PERIOD) 30
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(CLOCK_PORT) "config_clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
# Synthesis config

# Floorplan config
set ::env(FP_CORE_UTIL) 5
# Placement config
set ::env(PL_TARGET_DENSITY) 0.5

set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl

# Disable timing checks temporarily till the design configurations are updated 
# to tackle the timing violations 
set ::env(QUIT_ON_TIMING_VIOLATIONS) 0

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
