# SCL Configs
set ::env(GLB_RT_ADJUSTMENT) 0.1

set ::env(CLOCK_PERIOD) "20.0"
set ::env(FP_CORE_UTIL) 35
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

