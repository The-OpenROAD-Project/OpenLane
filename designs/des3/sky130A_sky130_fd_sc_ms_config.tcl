# SCL Configs
set ::env(GLB_RT_ADJUSTMENT) 0.1
set ::env(SYNTH_STRAT) 2
set ::env(FP_CORE_UTIL) 20
set ::env(SYNTH_MAX_FANOUT) 7
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "7.59"

