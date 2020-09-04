# Design

# User config
set ::env(DESIGN_NAME) BM64

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/BM64/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "Clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)



set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}