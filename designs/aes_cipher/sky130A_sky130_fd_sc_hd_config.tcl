#Routing

set ::env(FP_CORE_UTIL) 30


# Extra


set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ] 

set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "10.09"
