# Design
set ::env(DESIGN_NAME) "ldpc_decoder_802_3an"

set ::env(VERILOG_FILES) "./designs/ldpc_decoder_802_3an/src/*.v"

set ::env(CLOCK_PERIOD) "55.000"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(SYNTH_STRATEGY) "DELAY 0"

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
