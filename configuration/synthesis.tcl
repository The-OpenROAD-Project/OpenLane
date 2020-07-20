# Synth defaults
set ::env(SYNTH_BIN) yosys
set ::env(SYNTH_SCRIPT) $::env(SCRIPTS_DIR)/synth.tcl
set ::env(SYNTH_NO_FLAT) 0
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 0
set ::env(SYNTH_MAX_FANOUT) 5
set ::env(SYNTH_STRATEGY) 2
set ::env(CLOCK_BUFFER_FANOUT) 16
set ::env(SYNTH_READ_BLACKBOX_LIB) 0
set ::env(SYNTH_TOP_LEVEL) 0

set ::env(BASE_SDC_FILE) $::env(OPENLANE_ROOT)/scripts/base.sdc