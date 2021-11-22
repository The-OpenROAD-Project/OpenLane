drc off

lef read $::env(TECH_LEF)

if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}

load $::env(finishing_results)/$::env(DESIGN_NAME).mag -dereference

cellname filepath $::env(DESIGN_NAME) $::env(finishing_results)

# Write LEF
if { $::env(MAGIC_WRITE_FULL_LEF) } {
	puts "\[INFO\]: Writing non-abstract (full) LEF"
	lef write $::env(finishing_results)/$::env(DESIGN_NAME).lef
} else {
	puts "\[INFO\]: Writing abstract LEF"
	if { [info exists ::env(FP_PDN_CORE_RING)] && $::env(FP_PDN_CORE_RING) == 1 } {
		set tolerance 0.3
		lef write $::env(finishing_results)/$::env(DESIGN_NAME).lef -hide
	} else {
		lef write $::env(finishing_results)/$::env(DESIGN_NAME).lef -hide
	}
}
puts "\[INFO\]: LEF Write Complete"
