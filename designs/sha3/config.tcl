
# Design
# Design
set ::env(DESIGN_NAME) "sha3"

set ::env(VERILOG_FILES) "./designs/sha3/src/sha3.v"
set ::env(SDC_FILE) "./designs/sha3/src/sha3.sdc"

set ::env(CLOCK_PERIOD) "3.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}