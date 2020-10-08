set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 50

set ::env(SYNTH_MAX_FANOUT) 6
#Routing

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "11.82"
