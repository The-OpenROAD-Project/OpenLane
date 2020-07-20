# User config
set ::env(DESIGN_NAME) doublepll

# Change if needed
set ::env(VERILOG_FILES) [glob "./designs/doublepll/src/*.v" ]

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
set ::env(RUN_SIMPLE_CTS) 0
set ::env(CLOCK_TREE_SYNTH) 0

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}