set ::env(DESIGN_NAME) "usbf_device"

set ::env(VERILOG_FILES) "./designs/usbf_device/src/usbf_device.v"

set ::env(CLOCK_PERIOD) "15"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}