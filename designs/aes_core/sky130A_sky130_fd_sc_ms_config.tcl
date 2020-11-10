set ::env(SYNTH_STRATEGY) 2
set ::env(SYNTH_MAX_FANOUT) 6

# Extra

# Regression
set ::env(FP_CORE_UTIL) 30

# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ] 


# Extra

set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
