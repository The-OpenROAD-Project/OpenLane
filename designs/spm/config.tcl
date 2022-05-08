# Design
set ::env(DESIGN_NAME) "spm"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"

set ::env(FP_PDN_AUTO_ADJUST) 0
set ::env(FP_PDN_VOFFSET) 7.0
set ::env(FP_PDN_HOFFSET) 7.0

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
