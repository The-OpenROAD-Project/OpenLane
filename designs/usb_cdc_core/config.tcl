
# Design

# User config
set ::env(DESIGN_NAME) usb_cdc_core

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/usb_cdc_core/src/*.v]


set ::env(CLOCK_PERIOD) "16.000"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}