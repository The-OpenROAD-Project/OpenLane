
# Design

# User config
set ::env(DESIGN_NAME) gt

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/gt/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "1.5"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 60
set ::env(PL_TARGET_DENSITY) 0.65
set ::env(SYNTH_MAX_FANOUT) 6

# Regression
set ::env(FP_CORE_UTIL) 70
set ::env(PL_TARGET_DENSITY) 0.70

# Extra

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}