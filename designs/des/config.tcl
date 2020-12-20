
# Design
set ::env(DESIGN_NAME) "des"

set ::env(VERILOG_FILES) [glob ./designs/des/src/*.v]

set ::env(CLOCK_PERIOD) "2.000"
set ::env(CLOCK_PORT) "clk"



set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
