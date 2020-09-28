set ::env(DESIGN_NAME) "y_dct"

set ::env(VERILOG_FILES) "./designs/y_dct/src/y_dct.v"
set ::env(SDC_FILE) "./designs/y_dct/src/$::env(DESIGN_NAME).sdc"

set ::env(CLOCK_PERIOD) "7.000"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
