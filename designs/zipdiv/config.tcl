
# Design
set ::env(DESIGN_NAME) "zipdiv"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/zipdiv.v"

set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
} else {
	puts_err "can't find $::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl file in $::env(DESIGN_DIR)"
	exit 1
}