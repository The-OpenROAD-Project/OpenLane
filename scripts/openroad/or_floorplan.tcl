read_liberty $::env(LIB_SYNTH)
read_lef $::env(MERGED_LEF)
read_verilog $::env(yosys_result_file_tag).v
link_design $::env(DESIGN_NAME)
set bottom_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(BOTTOM_MARGIN_MULT)]
set top_margin  [expr $::env(PLACE_SITE_HEIGHT) * $::env(TOP_MARGIN_MULT)]
set left_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(LEFT_MARGIN_MULT)]
set right_margin [expr $::env(PLACE_SITE_WIDTH) * $::env(RIGHT_MARGIN_MULT)]

if {$::env(FP_SIZING) == "absolute"} {
  initialize_floorplan \
    -die_area $::env(DIE_AREA) \
    -core_area $::env(CORE_AREA) \
    -tracks $::env(TRACKS_INFO_FILE) \
    -site $::env(PLACE_SITE)
} else {
  initialize_floorplan \
    -utilization $::env(FP_CORE_UTIL) \
    -aspect_ratio $::env(FP_ASPECT_RATIO) \
    -core_space "$bottom_margin $top_margin $left_margin $right_margin" \
    -tracks $::env(TRACKS_INFO_FILE) \
    -site $::env(PLACE_SITE)
}

write_def $::env(SAVE_DEF)
