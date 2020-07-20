set ::env(DESIGN_NAME) "KSA32"

set ::env(VERILOG_FILES) "./designs/KSA32/src/KSA32.v"
set ::env(SDC_FILE) "./designs/KSA32/src/KSA32.sdc"

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}