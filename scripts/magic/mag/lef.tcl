drc off

lef read $::env(TECH_LEF)
if {  [info exist ::env(EXTRA_LEFS)] } {
	foreach lef_file $::env(EXTRA_LEFS) {
		lef read $lef_file
	}
}

load $::env(signoff_results)/$::env(DESIGN_NAME).mag -dereference

cellname filepath $::env(DESIGN_NAME) $::env(signoff_results)

# Write LEF
if { $::env(MAGIC_WRITE_FULL_LEF) } {
	puts "\[INFO\]: Writing non-abstract (full) LEF"
	lef write $::env(signoff_results)/$::env(DESIGN_NAME).lef
} else {
	puts "\[INFO\]: Writing abstract LEF"
	lef write $::env(signoff_results)/$::env(DESIGN_NAME).lef -hide
}
puts "\[INFO\]: LEF Write Complete"
