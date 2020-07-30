# Design
set ::env(DESIGN_NAME) "xgate_risc"

set ::env(VERILOG_FILES) "./designs/xgate_risc/src/xgate_risc.v"
# set ::env(SDC_FILE) "./designs/aes/src/aes.sdc"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}