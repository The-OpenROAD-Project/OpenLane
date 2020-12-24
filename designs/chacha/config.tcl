
# Design

# Design

# Design
set ::env(DESIGN_NAME) "chacha"

set ::env(VERILOG_FILES) "./designs/chacha/src/chacha.v"
set ::env(SDC_FILE) "./designs/chacha/src/chacha.sdc"

set ::env(CLOCK_PERIOD) "25.0"
set ::env(CLOCK_PORT) "clk"



set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}