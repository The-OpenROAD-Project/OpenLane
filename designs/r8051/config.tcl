
# Design
set ::env(DESIGN_NAME) "r8051"

set ::env(VERILOG_FILES) "./designs/r8051/src/r8051.v"
set ::env(SDC_FILE) "./designs/r8051/src/r8051.sdc"

set ::env(CLOCK_PERIOD) "25.0"
set ::env(CLOCK_PORT) "clk"



set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}