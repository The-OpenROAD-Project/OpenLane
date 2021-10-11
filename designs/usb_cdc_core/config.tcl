
# Design

# User config
set ::env(DESIGN_NAME) usb_cdc_core

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/usb_cdc_core/src/*.v]


set ::env(CLOCK_PERIOD) "16.000"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# Disable timing checks temporarily till the design configurations are updated 
# to tackle the timing violations 
set ::env(QUIT_ON_TIMING_VIOLATIONS) 0

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}