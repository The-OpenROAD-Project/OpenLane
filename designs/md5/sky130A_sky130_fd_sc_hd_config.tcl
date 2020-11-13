# SCL Configs
set ::env(CLOCK_PERIOD) "30.0"
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(FP_CORE_UTIL) 50
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
# Regression
set ::env(FP_CORE_UTIL) 40
set ::env(CELL_PAD) 6

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]


# Suggested Clock Period:
 set ::env(CLOCK_PERIOD) "37.05"
# Regression
set ::env(FP_CORE_UTIL) 35
set ::env(CELL_PAD) 4

# Extra
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

