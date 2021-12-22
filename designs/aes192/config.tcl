# Design
set ::env(DESIGN_NAME) "aes192"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/aes192.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}