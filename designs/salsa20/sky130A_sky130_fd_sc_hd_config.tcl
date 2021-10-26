# SCL Configs
set ::env(CLOCK_PERIOD) "38"
set ::env(FP_CORE_UTIL) 20
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.15
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
