set ::env(SYNTH_MAX_FANOUT) 6


#Routing

# Regression
set ::env(FP_CORE_UTIL) 65


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "15.8"
