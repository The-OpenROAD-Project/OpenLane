
# Design

# User config
set ::env(DESIGN_NAME) cmul7p8

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/cmul7p8/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "5.000"
set ::env(CLOCK_PORT) ""

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(RUN_SIMPLE_CTS) 0
set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}