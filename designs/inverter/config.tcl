# User config
set ::env(DESIGN_NAME) inverter

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# turn off clock
set ::env(CLOCK_TREE_SYNTH) 0
set ::env(CLOCK_PORT) ""

set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 34.5 57.12"
set ::env(PL_TARGET_DENSITY) 0.75

set ::env(FP_PDN_AUTO_ADJUST) 0
set ::env(FP_PDN_VPITCH) 25.0
set ::env(FP_PDN_HPITCH) 25.0
set ::env(FP_PDN_VOFFSET) 5.0
set ::env(FP_PDN_HOFFSET) 5.0

set ::env(DIODE_INSERTION_STRATEGY) 3

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
