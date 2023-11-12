package require openlane;

prep -design $::env(TEST_DIR) {*}$argv
check_assign_statements $::env(TEST_DIR)/inverter.v
