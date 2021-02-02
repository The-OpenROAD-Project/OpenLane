
# Design

# Design

# Design
set ::env(DESIGN_NAME) "PPU"

set ::env(VERILOG_FILES) "./designs/PPU/src/PPU.v"

set ::env(CLOCK_PERIOD) "18.0"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}