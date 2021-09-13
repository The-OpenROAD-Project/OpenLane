set ::env(DESIGN_NAME) "APU"

set ::env(VERILOG_FILES) "./designs/APU/src/APU.v"

set ::env(CLOCK_PERIOD) "17.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(FP_PDN_IRDROP) 1

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}