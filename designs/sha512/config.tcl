
# Design

# Design
set ::env(DESIGN_NAME) "sha512"

set ::env(VERILOG_FILES) "./designs/sha512/src/sha512.v"
set ::env(SDC_FILE) "./designs/sha512/src/$::env(DESIGN_NAME).sdc"

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"



set ::env(CTS_TOLERANCE) 500
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}