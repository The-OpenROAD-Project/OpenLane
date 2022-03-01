set ::env(CLOCK_PERIOD) "2.4"

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 279.96 280.128"
set ::env(PLACE_DENSITY) 0.35

set ::env(LEFT_MARGIN_MULT)  22
set ::env(RIGHT_MARGIN_MULT) 22
set ::env(TOP_MARGIN_MULT)    3

set ::env(FP_PDN_VPITCH)  27.14
set ::env(FP_PDN_HPITCH)  27.20
set ::env(FP_PDN_VOFFSET) 13.57
set ::env(FP_PDN_HOFFSET) 13.60

# hs generates '[ERROR GRT-0069] Diode not found.'
# remove once fixed
set ::env(DIODE_INSERTION_STRATEGY) 0
