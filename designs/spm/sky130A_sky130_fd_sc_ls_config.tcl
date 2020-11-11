# SCL Configs
set ::env(CLOCK_PERIOD) "10"
set ::env(FP_CORE_UTIL) 65
set ::env(SYNTH_MAX_FANOUT) 5
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
