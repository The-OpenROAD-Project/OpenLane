#Routing


set ::env(FP_CORE_UTIL) 30


set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "6.31"
