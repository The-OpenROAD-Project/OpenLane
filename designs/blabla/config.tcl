set ::env(DESIGN_NAME) "blabla"

set ::env(VERILOG_FILES) "./designs/blabla/src/blabla.v"
set ::env(SDC_FILE) "./designs/blabla/src/blabla.sdc"

set ::env(CLOCK_PERIOD) "65.0"
set ::env(CLOCK_PORT) "clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}