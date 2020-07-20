read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)


filler_placement "$::env(DECAP_CELL) $::env(FILL_CELL)"

write_def $::env(SAVE_DEF)
