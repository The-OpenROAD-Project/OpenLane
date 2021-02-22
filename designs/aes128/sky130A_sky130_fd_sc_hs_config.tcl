# SCL Configs
set ::env(SYNTH_MAX_FANOUT) 7

set ::env(FP_CORE_UTIL) 25
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(CLOCK_PERIOD) "11.43"
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
