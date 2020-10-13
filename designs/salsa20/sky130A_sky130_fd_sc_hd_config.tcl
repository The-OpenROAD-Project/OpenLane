
set ::env(FP_CORE_UTIL) 40


#Routing


set ::env(CLOCK_PERIOD) "20"
set ::env(FP_CORE_UTIL) 45

set ::env(SYNTH_MAX_FANOUT) 6

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "24.73"
