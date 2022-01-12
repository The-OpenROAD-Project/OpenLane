# SCL Configs
set ::env(CLOCK_PERIOD) "65.0"
set ::env(FP_CORE_UTIL) 11
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

