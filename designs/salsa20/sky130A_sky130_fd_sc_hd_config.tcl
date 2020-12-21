# SCL Configs
set ::env(FP_CORE_UTIL) 30
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "36.73"
