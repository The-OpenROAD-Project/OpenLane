# Design
set ::env(DESIGN_NAME) "spm"

set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/spm/src/*.v]

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"

set ::env(RUN_MAGIC) 1
set ::env(RUN_ROUTING_DETAILED) 1

set ::env(CLOCK_NET) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
