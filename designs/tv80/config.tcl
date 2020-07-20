
# Design

# Design
set ::env(DESIGN_NAME) "tv80"

set ::env(VERILOG_FILES) "./designs/tv80/src/tv80.v"
set ::env(SDC_FILE) "./designs/tv80/src/tv80.sdc"

set ::env(CLOCK_PERIOD) "20.0"
set ::env(CLOCK_PORT) "clk"




set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
