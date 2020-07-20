### PDN Config. All units in micrometer (um)
## The values used in this config are for reference only and do not correspond to any specific foundry
## design name to be used in DEF
set ::design $::env(DESIGN_NAME)

## DEF DBU
set ::def_units $::env(DEF_UNITS_PER_MICRON)

##Input DEF with macros packed
set ::FpOutDef $::env(CURRENT_DEF)

#### input tech lef path
#set ::techLef $::env(TECH_LEF)

#### input cell lef path
set ::cellLef [list $::env(MERGED_LEF)]

#### input flat lef path. FLAT LEF that contains physical views of all standard cells and macros in the design
# Ensure that the file ends with END LIBRARY
set ::flatLef $::env(MERGED_LEF)

set ::macro_power_pins "$::env(VDD_PIN) vnb"
set ::macro_ground_pins "$::env(GND_PIN) vgnd"

#### placement SITE name from LEF
set ::site_name $::env(PLACE_SITE)
set ::site_width $::env(PLACE_SITE_WIDTH)

# Floorplan information - core boundary coordinates, std. cell row height,
# minimum track pitch as defined in LEF
#

set coreinfo [join [exec $::env(SCRIPTS_DIR)/extract_coreinfo.sh $::FpOutDef] " "]
# DIEAREA ( 0 0 ) ( 93930 93930 ) ;
# ROW ROW_0 unit 0 0 FS DO 195 by 1 STEP 480 0 ;
# ROW ROW_27 unit 0 89910 N DO 195 by 1 STEP 480 0 ;
# 0 0 93930 93930 ///    0 0 0 89910 195 480
set sites_per_row [lindex $coreinfo 8]
set step [lindex $coreinfo 9]

set ::core_area_llx [expr { [lindex $coreinfo 4]/double($::def_units) }]
set ::core_area_lly [expr { [lindex $coreinfo 5]/double($::def_units) }]
set ::core_area_urx [expr { ([lindex $coreinfo 6]+$step*$sites_per_row)/double($::def_units) }]
set ::core_area_ury [expr { [lindex $coreinfo 7]/double($::def_units) }]

set ::die_area_llx [expr { [lindex $coreinfo 0]/double($::def_units) }]
set ::die_area_lly [expr { [lindex $coreinfo 1]/double($::def_units) }]
set ::die_area_urx [expr { [lindex $coreinfo 2]/double($::def_units) }]
set ::die_area_ury [expr { [lindex $coreinfo 3]/double($::def_units) }]

set ::row_height $::env(PLACE_SITE_HEIGHT)

# Power nets
set ::power_nets "VDD"
set ::ground_nets "VSS"

set ::macro_blockage_layer_list ""

# Details from techlef (BEOL LEF)
set ::met_layer_list "met1 met2 met3 met4 met5"  ;#From met1 and upwards
set ::met_layer_dir  "hor ver hor ver hor"

# Ensure pitches will make the stripes fall on track
# Ensure offsets will make the stripes fall on track

pdn specify_grid stdcell [list \
    layers    "met1" \
    dir       "hor" \
    widths    "1.25" \
    pitches   "$::row_height" \
    loffset   "0" \
    boffset   "0" \
    connect   "" \
    vias      "M1M2_PR M2M3_PR M3M4_PR M4M5_PR" \
]

#pdn specify_grid macro [list \
#    layers    "M6" \
#    dir       "ver" \
#    widths    "0.93" \
#    pitches   "40" \
#    loffset   2 \
#    boffset   0 \
#    min_pitch 0.2 \
#    connect   "{M4_PIN_hor M6} {M6 M7}" \
#    vias      "VIA1_RULE_1 VIA2_RULE_1 VIA3_RULE_1 VIA4_RULE_293 VIA5_RULE_360 VIA6_RULE_21 VIA7_RULE_18 VIA8_RULE_1" \
#]
#set ::halo 4

# Metal layer for rails on every row
set ::rails_mlayer "met1" ;

# POWER or GROUND #Std. cell rails starting with power or ground rails at the bottom of the core area
set ::rails_start_with "GROUND" ;

# POWER or GROUND #Upper metal stripes starting with power or ground rails at the left/bottom of the core area
set ::stripes_start_with "GROUND" ;

proc generate_viarules {} {
}

cd $::env(TMP_DIR)/floorplan
