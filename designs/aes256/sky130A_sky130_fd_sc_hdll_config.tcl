# SCL Configs
set ::env(SYNTH_MAX_FANOUT) 9

set ::env(FP_CORE_UTIL) 30
set ::env(GLB_RT_ADJUSTMENT) 0.05
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "15.0"
