# SCL Configs

set ::env(SYNTH_MAX_FANOUT) 9

# Regression
set ::env(FP_CORE_UTIL) 20

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


# Suggested Clock Period:
set ::env(CLOCK_PERIOD) "136.83"
