package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

set ::env(CURRENT_GDS) $::env(TEST_DIR)/inverter.gds

run_klayout_drc
