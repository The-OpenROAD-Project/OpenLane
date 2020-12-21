drc off

lef read $::env(TECH_LEF)

if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}

load $::env(magic_result_file_tag).mag -dereference

cellname filepath $::env(DESIGN_NAME) $::env(RESULTS_DIR)/magic

# Write LEF
if { $::env(MAGIC_WRITE_FULL_LEF) } {
	puts "\[INFO\]: Writing non-abstract (full) LEF"
	lef write $::env(magic_result_file_tag).lef
} else {
	puts "\[INFO\]: Writing abstract LEF"
	if { [info exists ::env(FP_PDN_CORE_RING)] && $::env(FP_PDN_CORE_RING) == 1 } {
		set tolerance 0.3
		# set cr_offset [expr max($::env(FP_PDN_CORE_RING_HOFFSET), $::env(FP_PDN_CORE_RING_VOFFSET))/2]
		# set cr_spacing [expr max($::env(FP_PDN_CORE_RING_HSPACING), $::env(FP_PDN_CORE_RING_VSPACING))]
		# set cr_width [expr max($::env(FP_PDN_CORE_RING_HWIDTH), $::env(FP_PDN_CORE_RING_VWIDTH))]
		# set cr_distance [expr $cr_offset + $cr_spacing + 2 * [llength $::env(VDD_NETS)] * ($cr_width - $tolerance)]
		# lef write $::env(magic_result_file_tag).lef -hide [expr $cr_distance - $tolerance]um
		# lef write $::env(magic_result_file_tag).lef -hide ${tolerance}um
		lef write $::env(magic_result_file_tag).lef -hide
	} else {
		lef write $::env(magic_result_file_tag).lef -hide
	}
}
puts "\[INFO\]: LEF Write Complete"
