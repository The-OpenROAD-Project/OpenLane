# Design
set ::env(DESIGN_NAME) "aes192"

set ::env(VERILOG_FILES) "./designs/aes192/src/aes192.v"
set ::env(SDC_FILE) "./designs/aes192/src/aes192.sdc"

set ::env(CLOCK_PERIOD) "15.0"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}