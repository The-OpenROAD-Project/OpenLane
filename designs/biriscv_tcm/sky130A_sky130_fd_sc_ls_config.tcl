set ::env(RUN_MAGIC) 1
set ::env(RUN_ROUTING_DETAILED) 1




set ::env(FP_CORE_UTIL) 25
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]
