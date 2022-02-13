set ::env(CLOCK_PERIOD) "2.4"

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 279.96 280.128"
set ::env(PLACE_DENSITY) 0.35

set ::env(LEFT_MARGIN_MULT)  20
set ::env(RIGHT_MARGIN_MULT) 20

# hs generates '[ERROR GRT-0069] Diode not found.'
# remove once fixed
set ::env(DIODE_INSERTION_STRATEGY) 0
