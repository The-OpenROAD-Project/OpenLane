
# User config
set ::env(DESIGN_NAME) sound

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/sound/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "120"
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(SYNTH_NO_FLAT) 1

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}