set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(SYNTH_STRATEGY) 3

#Routing

# Regression

set ::env(SYNTH_STRATEGY) 2
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(CLOCK_PERIOD) "20.000"


# Regression

set ::env(GLB_RT_ADJUSTMENT) 0.1

# Extra

# Regression
set ::env(FP_CORE_UTIL) 30


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 
