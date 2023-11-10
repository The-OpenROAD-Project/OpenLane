package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

set ::env(CURRENT_DEF) $::env(TEST_DIR)/inverter.def
set ::env(CURRENT_GDS) $::env(TEST_DIR)/inverter.gds
set ::env(CURRENT_POWERED_NETLIST) $::env(TEST_DIR)/inverter.pnl.v

set ::env(MAGIC_EXT_USE_GDS) 1
run_magic_spice_export
run_lvs