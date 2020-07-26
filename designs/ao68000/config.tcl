# Design
set ::env(DESIGN_NAME) "ao68000"

set ::env(VERILOG_FILES) "./designs/ao68000/src/ao68000.v"
# set ::env(SDC_FILE) "./designs/ao68000/src/ao68000.sdc"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
