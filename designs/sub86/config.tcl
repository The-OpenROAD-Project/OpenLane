
# Design

# Design
set ::env(DESIGN_NAME) "sub86"

set ::env(VERILOG_FILES) "./designs/sub86/src/sub86.v"
set ::env(SDC_FILE) "./designs/sub86/src/sub86.sdc"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "CLK"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}