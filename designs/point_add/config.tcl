
# Design

# Design

# Design
set ::env(DESIGN_NAME) "point_add"

set ::env(VERILOG_FILES) [glob ./designs/$::env(DESIGN_NAME)/src/*.v]

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}