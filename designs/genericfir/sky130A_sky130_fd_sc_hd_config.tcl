
set ::env(FP_CORE_UTIL) 30
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(SYNTH_STRAT) 2


set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 60

set ::env(SYNTH_MAX_FANOUT) 6

#Routing


# Regression
set ::env(FP_CORE_UTIL) 50


# Extra


# Regression
set ::env(SYNTH_MAX_FANOUT) 7

# Extra


# Regression


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 
