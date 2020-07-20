
# Design

# Design
# Design
set ::env(DESIGN_NAME) "fp_multiplier"

set ::env(VERILOG_FILES) "./designs/fp_multiplier/src/fp_multiplier.v"
# set ::env(SDC_FILE) "./designs/aes/src/aes.sdc"

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)



set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}