set ::env(SYNTH_BUFFERING) 0
set ::env(SYNTH_SIZING) 0

set ::env(FP_CORE_UTIL)      50



set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 60

set ::env(SYNTH_MAX_FANOUT) 6


#Routing

# Regression
set ::env(FP_CORE_UTIL) 65


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
