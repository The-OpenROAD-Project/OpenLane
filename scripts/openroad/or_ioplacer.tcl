if { [file exists $::env(TMP_DIR)/top_level.lef] } {
	read_lef $::env(TMP_DIR)/top_level.lef
	ioPlacer::set_num_slots 2
}

read_lef $::env(MERGED_LEF)
read_def $::env(CURRENT_DEF)

ioPlacer::set_hor_metal_layer [expr $::env(FP_IO_HMETAL) + 1]
ioPlacer::set_ver_metal_layer [expr $::env(FP_IO_VMETAL) + 1]

puts "\[INFO\]: Vertical Metal Layer: [ioPlacer::get_ver_metal_layer]"
puts "\[INFO\]: Horizontal Metal Layer: [ioPlacer::get_hor_metal_layer]"

ioPlacer::set_rand_seed 42
if { $::env(FP_IO_MODE) == 1 } {
	ioPlacer::set_random_mode 2; # 1 and 3 have different groupings
} else {
	ioPlacer::set_random_mode 0
}
ioPlacer::set_hor_length $::env(FP_IO_HLENGTH)
ioPlacer::set_ver_length $::env(FP_IO_VLENGTH)
ioPlacer::set_hor_length_extend $::env(FP_IO_VEXTEND)
ioPlacer::set_ver_length_extend $::env(FP_IO_HEXTEND)
ioPlacer::set_ver_thick_multiplier $::env(FP_IO_VTHICKNESS_MULT)
ioPlacer::set_hor_thick_multiplier $::env(FP_IO_HTHICKNESS_MULT)

ioPlacer::run_io_placement

write_def $::env(SAVE_DEF)
