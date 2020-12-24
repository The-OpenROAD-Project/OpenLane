
# Design
set ::env(DESIGN_NAME) "md5"

set ::env(VERILOG_FILES) "./designs/md5/src/md5.v"
set ::env(SDC_FILE) "./designs/md5/src/md5.sdc"

set ::env(CLOCK_PERIOD) "14"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}