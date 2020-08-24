if {[catch {read_lef $::env(MERGED_UNPADDED_LEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def -order_wires $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
	exit 1
}

# load layers' antenna rules into ARC
load_antenna_rules

# start checking antennas and generate a detail report
check_antennas -path $::env(REPORTS_DIR)/routing/