read_lef $::env(MERGED_LEF_UNPADDED)
read_def $::env(CURRENT_DEF)

write_verilog $::env(SAVE_NETLIST)
