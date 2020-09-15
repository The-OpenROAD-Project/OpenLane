
# Design
set ::env(DESIGN_NAME) "wb_conbus_top"

set ::env(VERILOG_FILES) [glob ./designs/wb_conbus_top/src/*.v]

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk_i"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
