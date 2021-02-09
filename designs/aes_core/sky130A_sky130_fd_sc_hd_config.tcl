# SCL Configs

set ::env(SYNTH_MAX_FANOUT) 6
set ::env(FP_CORE_UTIL) 25
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "21.28"
