set ::env(FP_CORE_UTIL) 40

set ::env(GLB_RT_ADJUSTMENT) 0.15

#Routing

# Regression
set ::env(SYNTH_MAX_FANOUT) 10

# Extra

# Regression
set ::env(FP_CORE_UTIL) 30

set ::env(GLB_RT_ADJUSTMENT) 0.1



# Extra


set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "34.27"
