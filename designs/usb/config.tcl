
# Design
set ::env(DESIGN_NAME) "usb"

set ::env(VERILOG_FILES) "./designs/usb/src/usb2p0_core.v"

set ::env(CLOCK_PERIOD) "15.000"
set ::env(CLOCK_PORT) "clk_48"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}