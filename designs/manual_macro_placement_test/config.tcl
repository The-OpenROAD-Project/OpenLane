# User config
set ::env(DESIGN_NAME) manual_macro_placement_test

set ::env(FP_CORE_UTIL) 35
set ::env(FP_PDN_VOFFSET) 0
set ::env(FP_PDN_VPITCH) 30

# OpenROAD reports unconnected nodes as a warning.
# OpenLane typically treats unconnected node warnings 
# as a critical issue, and simply quits.
#
# We'll be leaving it up to the designer's discretion to
# enable/disable this: if LVS passes you're probably fine
# with this option being turned off.
set ::env(FP_PDN_CHECK_NODES) 0

set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro_placement.cfg
set ::env(BASE_SDC_FILE) $::env(DESIGN_DIR)/base.sdc

set ::env(PL_TARGET_DENSITY) 0.35
set ::env(PL_BASIC_PLACEMENT) 1
set ::env(CELL_PAD) 0

set ::env(CLOCK_PERIOD) "100"
set ::env(CLOCK_PORT) "clk1 clk2"
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(DIODE_INSERTION_STRATEGY) 0

set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/macros/lef/*.lef]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/macros/gds/*.gds]

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
