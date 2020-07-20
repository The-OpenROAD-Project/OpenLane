read_liberty $::env(LIB_SYNTH_COMPLETE)
read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

#set_wire_rc -layer metal3
estimate_parasitics -placement
repair_design -max_wire_length $::env(MAX_WIRE_LENGTH) -buffer_cell $::env(RE_BUFFER_CELL)
#check_in_core
write_def $::env(SAVE_DEF)
