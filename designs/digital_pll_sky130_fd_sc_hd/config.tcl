# Design

# User config
set ::env(DESIGN_NAME) digital_pll_sky130_fd_sc_hd

# Change if needed
set ::env(VERILOG_FILES) ./designs/digital_pll_sky130_fd_sc_hd/src/digital_pll.v

# Fill this
set ::env(CLOCK_PERIOD) "100000"
set ::env(CLOCK_PORT) "w"
set ::env(CLOCK_TREE_SYNTH) 0

set ::env(RUN_SIMPLE_CTS) 0

set ::env(RUN_MAGIC) 1
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
