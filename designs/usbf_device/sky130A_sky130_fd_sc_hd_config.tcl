# SCL Configs
set ::env(CLOCK_PERIOD) "11.82"
set ::env(FP_CORE_UTIL) 50
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
# Regression
set ::env(FP_CORE_UTIL) 45
set ::env(CELL_PAD) 4

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "14.6"
