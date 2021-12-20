
# Design
set ::env(DESIGN_NAME) "aes_core"

set ::env(VERILOG_FILES) "./designs/aes_core/src/aes.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(DIODE_INSERTION_STRATEGY) 4

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
