if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

filler_placement "$::env(DECAP_CELL) $::env(FILL_CELL)"

write_def $::env(SAVE_DEF)
