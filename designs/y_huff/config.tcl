
# Design
set ::env(DESIGN_NAME) "y_huff"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/y_huff.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# design has a lot of pins, needs an absolute size
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) {0 0 700 700}

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
} else {
	puts_err "can't find $::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl file in $::env(DESIGN_DIR)"
	exit 1
}