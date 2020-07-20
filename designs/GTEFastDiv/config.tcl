
# Design

# Design

# User config
set ::env(DESIGN_NAME) GTEFastDiv

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/GTEFastDiv/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) ""
set ::env(RUN_SIMPLE_CTS) 0
set ::env(CLOCK_TREE_SYNTH) 0



set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}