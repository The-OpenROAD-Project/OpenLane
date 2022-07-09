# User config
set ::env(DESIGN_NAME) regfile_2r1w

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(VERILOG_FILES_BLACKBOX) [glob $::env(DESIGN_DIR)/bb/*.v]

set ::env(VERILOG_FILES_BLACKBOX) [glob $::env(DESIGN_DIR)/bb/*.v]
set ::env(EXTRA_LEFS) $::env(DESIGN_DIR)/../mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef
set ::env(EXTRA_GDS_FILES) $::env(DESIGN_DIR)/../mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds

set ::env(FP_ASPECT_RATIO) 2

#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) {0 0 1000 1000}

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

