# Regression
set ::env(SYNTH_MAX_FANOUT)  7
set ::env(SYNTH_STRATEGY)    2

set ::env(FP_CORE_UTIL)      40
set ::env(FP_PDN_VPITCH)     153.6
set ::env(FP_PDN_HPITCH)     153.18
set ::env(FP_ASPECT_RATIO)   1
set ::env(GLB_RT_ADJUSTMENT) 0.2




set ::env(FILL_INSERTION) 1 

#Routing



# Regression
set ::env(SYNTH_MAX_FANOUT) 10

# Regression


# Extra


# Regression
set ::env(FP_CORE_UTIL) 35

set ::env(SYNTH_STRATEGY) 2
set ::env(SYNTH_MAX_FANOUT) 7
set ::env(CLOCK_PERIOD) "10.000"

# Extra

# Regression
set ::env(FP_CORE_UTIL) 30

set ::env(GLB_RT_ADJUSTMENT) 0.1
# Regression
set ::env(FP_CORE_UTIL) 20


# Extra


set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
