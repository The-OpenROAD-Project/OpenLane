
# Design
set ::env(DESIGN_NAME) "point_scalar_mult"

set ::env(VERILOG_FILES) [glob ./designs/point_scalar_mult/src/*.v]
set ::env(SDC_FILE) "./designs/point_scalar_mult/src/$::env(DESIGN_NAME).sdc"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
