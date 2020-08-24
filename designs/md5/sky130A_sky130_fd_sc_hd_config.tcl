set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 55

set ::env(SYNTH_MAX_FANOUT) 6

# Extra
# Regression
set ::env(FP_CORE_UTIL) 60


set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 
