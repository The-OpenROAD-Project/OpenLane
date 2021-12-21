set ::env(DESIGN_NAME) "blabla"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/blabla.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# design has a lot of pins, needs an absolute size
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) {0 0 1200 1200}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
