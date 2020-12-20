
# Design

# Design

# Design
set ::env(DESIGN_NAME) "genericfir"

set ::env(VERILOG_FILES) "./designs/genericfir/src/genericfir.v"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}