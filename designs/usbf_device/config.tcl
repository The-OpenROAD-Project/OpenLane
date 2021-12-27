set ::env(DESIGN_NAME) "usbf_device"

set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/usbf_device.v"

set ::env(CLOCK_PORT) "clk_i"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}