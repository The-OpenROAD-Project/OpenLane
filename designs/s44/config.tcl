# User config
set ::env(DESIGN_NAME) lut_s44
set ::env(PDK_VARIANT) sky130_fd_sc_hd

# Design config
set ::env(CLOCK_PERIOD) 30
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/s44/src/*.v]
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
#set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/250/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
# Synthesis config
set ::env(SYNTH_STRATEGY) 1
# Floorplan config
set ::env(FP_CORE_UTIL) 5
# Placement config
set ::env(PL_TARGET_DENSITY) 0.5
# CTS config
# Routing config
set ::env(ROUTING_STRATEGY) 14 ;# run TritonRoute14
set ::env(GLB_RT_ADJUSTMENT) 0
# Flow control config

# # threads for supporting tools
set ::env(ROUTING_CORES) 4

set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

#set ::env(GLOBAL_PLACEMENT_ARGS) -skip_initial_place
set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
