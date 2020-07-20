drc off

lef read $::env(TECH_LEF)

if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}

# Read def and load design
def read $::env(CURRENT_DEF)

gds readonly true
gds rescale false
if {  [info exist ::env(EXTRA_GDS_FILES)] } {
       set gds_files_in $::env(EXTRA_GDS_FILES)
       foreach gds_file $gds_files_in {
               gds read $gds_file
       }
}


load $::env(DESIGN_NAME)
select top cell

# padding

if { $::env(MAGIC_PAD) } {
	puts "\[INFO\]: Padding LEFs"
	# assuming scalegrid 1 2
	# use um
	select top cell
	box grow right [expr 100*($::env(PLACE_SITE_WIDTH))]
	box grow left [expr 100*($::env(PLACE_SITE_WIDTH))]
	box grow up [expr 100*($::env(PLACE_SITE_HEIGHT))]
	box grow down [expr 100*($::env(PLACE_SITE_HEIGHT))]
	property FIXED_BBOX [box values]
}
if { $::env(MAGIC_ZEROIZE_ORIGIN) } {
	# assuming scalegrid 1 2
	# makes origin zero based on the selection
	puts "\[INFO\]: Zeroizing Origin"
	set bbox [box values]
	set offset_x [lindex $bbox 0]
	set offset_y [lindex $bbox 1]
	move origin [expr {$offset_x/2}] [expr {$offset_y/2}]
	puts "\[INFO\]: Current Box Values: [box values]"
	property FIXED_BBOX [box values]
}

select top cell

# Write gds
if { $::env(MAGIC_GENERATE_GDS) } {
	cif *hier write disable
	#gds write $::env(DESIGN_NAME).gds
	gds write $::env(magic_result_file_tag).gds
	puts "\[INFO\]: GDS Write Complete"
}

if { $::env(MAGIC_GENERATE_LEF) } {
	lef write $::env(magic_result_file_tag).lef -hide
	# lef write $::env(DESIGN_NAME).full.lef
	puts "\[INFO\]: LEF Write Complete"
}

puts "\[INFO\]: Saving .mag view With BBox Values: [box values]"
# WARNING: changes the name of the cell; keep as last step
save $::env(magic_result_file_tag).mag

puts "\[INFO\]: MAGIC TAPEOUT STEP DONE"
exit 0
