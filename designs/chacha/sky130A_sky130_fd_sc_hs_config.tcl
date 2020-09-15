set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(SYNTH_STRATEGY) 3

#Routing

# Regression
set ::env(FP_CORE_UTIL) 55

set ::env(SYNTH_STRATEGY) 2
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(CLOCK_PERIOD) "10.000"


# Regression
set ::env(FP_CORE_UTIL) 50

set ::env(GLB_RT_ADJUSTMENT) 0.1

# Extra

# Regression
set ::env(FP_CORE_UTIL) 40


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
