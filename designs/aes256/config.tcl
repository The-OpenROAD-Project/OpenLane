# Design
set ::env(DESIGN_NAME) "aes256"

set ::env(VERILOG_FILES) "./designs/aes256/src/aes256.v"
set ::env(SDC_FILE) "./designs/aes256/src/aes256.sdc"

set ::env(CLOCK_PERIOD) "15.0"
set ::env(CLOCK_PORT) "clk"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}