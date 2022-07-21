set cell_pad_value $::env(CELL_PAD)

if { [info exists ::(DPL_CELL_PAD)] } {
    set cell_pad_value $::env(DPL_CELL_PAD)
}

set cell_pad_side [expr $cell_pad_value / 2]

set_placement_padding -global -right $cell_pad_side -left $cell_pad_side

if { $::env(CELL_PAD_EXCLUDE) != "" } {
    set_placement_padding -masters $::env(CELL_PAD_EXCLUDE) -right 0 -left 0
}