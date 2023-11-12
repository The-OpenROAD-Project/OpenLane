package require openlane;

prep -design $::env(TEST_DIR) {*}$argv

set ::env(signoff_results) $::env(TEST_DIR)
run_klayout_gds_xor
