
# Design
set ::env(DESIGN_NAME) "cordic"

set ::env(VERILOG_FILES) "./designs/cordic/src/cordic.v"
set ::env(SDC_FILE) "./designs/cordic/src/cordic.sdc"

set ::env(CLOCK_PERIOD) "1.5"
set ::env(CLOCK_PORT) "clock"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}