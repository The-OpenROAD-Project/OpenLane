
set ::env(GLB_RT_ADJUSTMENT) 0.15
set ::env(SYNTH_STRATEGY) 2

set ::env(CLOCK_PERIOD) "10"

set ::env(SYNTH_MAX_FANOUT) 6

#Routing

# Regression
set ::env(FP_CORE_UTIL) 55


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "12.29"
