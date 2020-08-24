set ::env(FP_CORE_UTIL) 5
set ::env(SYNTH_STRATEGY) 2




#Routing


# Regression

set ::env(FP_CORE_UTIL) 20

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
