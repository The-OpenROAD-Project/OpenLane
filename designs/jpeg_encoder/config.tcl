
# Design
# Design
set ::env(DESIGN_NAME) "jpeg_encoder"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/jpeg.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}