
# Design

# User config
set ::env(DESIGN_NAME) striVe_spi

# Change if needed
set ::env(VERILOG_FILES) ./designs/striVe_spi/src/striVe_spi.v

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "SCK"


set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(RUN_MAGIC) 1

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}