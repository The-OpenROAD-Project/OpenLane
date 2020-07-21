
if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}


set_placement_padding -global -right $::env(CELL_PAD)
detailed_placement

if { [check_placement -verbose] } {
	exit 1
}

write_def $::env(SAVE_DEF)
