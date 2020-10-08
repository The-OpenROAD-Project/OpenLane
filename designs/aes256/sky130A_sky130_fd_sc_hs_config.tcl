# Regression
set ::env(SYNTH_MAX_FANOUT)  6
set ::env(SYNTH_STRATEGY)    2

set ::env(FP_CORE_UTIL)      45
set ::env(FP_PDN_VPITCH)     153.6
set ::env(FP_PDN_HPITCH)     153.18
set ::env(FP_ASPECT_RATIO)   1
set ::env(GLB_RT_ADJUSTMENT) 0.15 




set ::env(FILL_INSERTION) 1 

#Routing




# Regression
set ::env(SYNTH_MAX_FANOUT) 9

# Extra


# Regression


# Extra

# Regression
set ::env(FP_CORE_UTIL) 35

set ::env(GLB_RT_ADJUSTMENT) 0.05

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]

# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "15.0"
