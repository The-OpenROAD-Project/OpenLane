package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

set ::env(CURRENT_DEF) $::env(TEST_DIR)/inverter.def
run_magic_spice_export
