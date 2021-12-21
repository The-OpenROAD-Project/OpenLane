
# Design
set ::env(DESIGN_NAME) "usb"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/usb2p0_core.v"

set ::env(CLOCK_PORT) "clk_48"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}