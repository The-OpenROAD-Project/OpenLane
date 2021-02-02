
# Design
set ::env(DESIGN_NAME) "aes128"

set ::env(VERILOG_FILES) "./designs/aes128/src/aes128.v"
set ::env(SDC_FILE) "./designs/aes128/src/aes128.sdc"

set ::env(CLOCK_PERIOD) "18.0"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
