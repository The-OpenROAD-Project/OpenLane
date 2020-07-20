
# Design

# Design
set ::env(DESIGN_NAME) "TEA"

set ::env(VERILOG_FILES) "./designs/TEA/src/tea.v"
set ::env(SDC_FILE) "./designs/TEA/src/tea.sdc"

set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)



set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}