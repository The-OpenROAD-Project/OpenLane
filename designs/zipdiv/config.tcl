
# Design
set ::env(DESIGN_NAME) "zipdiv"

set ::env(VERILOG_FILES) "./designs/zipdiv/src/zipdiv.v"
set ::env(SDC_FILE) "./designs/zipdiv/src/zipdiv.sdc"

set ::env(CLOCK_PERIOD) "2.5"
set ::env(CLOCK_PORT) "i_clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}