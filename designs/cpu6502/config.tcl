
# Design
set ::env(DESIGN_NAME) "cpu6502"

set ::env(VERILOG_FILES) "./designs/cpu6502/src/cpu6502.v"
set ::env(SDC_FILE) "./designs/cpu6502/src/cpu6502.sdc"

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}