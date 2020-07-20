
# Design
set ::env(DESIGN_NAME) "CPU"

set ::env(VERILOG_FILES) [glob ./designs/CPU/src/*.v]
set ::env(SDC_FILE) "./designs/CPU/src/CPU.sdc"

set ::env(CLOCK_PERIOD) "15.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
