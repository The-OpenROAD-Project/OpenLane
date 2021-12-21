# Design
set ::env(DESIGN_NAME) "PPU"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/PPU.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}