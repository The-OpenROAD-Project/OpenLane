# SCL Configs
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(SYNTH_STRATEGY) 3
set ::env(FP_CORE_UTIL) 20
set ::env(PL_TARGET_DENSITY) 0.15
set ::env(CLOCK_PERIOD) "65.0"
# Regression
set ::env(FP_CORE_UTIL) 20
set ::env(CELL_PAD) 6

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

