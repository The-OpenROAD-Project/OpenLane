
# Design

# Design
set ::env(DESIGN_NAME) "xtea"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/xtea.v"
set ::env(SDC_FILE) "$::env(DESIGN_DIR)/src/xtea.sdc"

set ::env(CLOCK_PORT) "clock"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
} else {
	puts_err "can't find $::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl file in $::env(DESIGN_DIR)"
	exit 1
}