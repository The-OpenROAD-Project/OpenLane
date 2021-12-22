# SCL Configs
set ::env(CLOCK_PERIOD) "10"
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.2
set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 1
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

