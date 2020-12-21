
# Design
# Design
set ::env(DESIGN_NAME) "jpeg_encoder"

set ::env(VERILOG_FILES) "./designs/jpeg_encoder/src/jpeg.v"
# set ::env(SDC_FILE) "./designs/aes/src/aes.sdc"

set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}