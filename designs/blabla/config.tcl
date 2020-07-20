set ::env(DESIGN_NAME) "blabla"

set ::env(VERILOG_FILES) "./designs/blabla/src/blabla.v"
set ::env(SDC_FILE) "./designs/blabla/src/blabla.sdc"

set ::env(CLOCK_PERIOD) "25.0"
set ::env(CLOCK_PORT) "clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}