proc move_to_dir {filenames dirname} {
    foreach filename $filenames {
        file rename $filename [file join $dirname [file tail $filename]]
    }
}

if {[catch {read_lef $::env(MERGED_LEF_UNPADDED)} errmsg]} {
    puts stderr $errmsg
    exit 1
}

foreach lib $::env(LIB_CTS) {
    read_liberty $lib
}
puts "ECO: Successfully read liberty!"

set cur_iter [expr $::env(ECO_ITER) == 0 ? \
                   0 : \
                   [expr {$::env(ECO_ITER) -1}] \
             ]

if {[expr {$cur_iter == 0}]} {
    if {[catch {read_def $::env(CURRENT_DEF)} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
    puts "Reading: $::env(CURRENT_NETLIST)"
    read_verilog $::env(CURRENT_NETLIST)
} else {
    if {[catch {read_def \
            $::env(RUN_DIR)/results/eco/def/eco_$cur_iter.def} errmsg]} {
        puts stderr $errmsg
        exit 1
    }
    puts "Reading results/eco/net/eco_$cur_iter.v"
    read_verilog $::env(RUN_DIR)/results/eco/net/eco_$cur_iter.v
}
puts "ECO: Successfully read Verilog!"

read_sdc -echo $::env(CURRENT_SDC)
puts "ECO: Successfully read SDC!"

puts "ECO: Sourcing eco.tcl!"
source $::env(SCRIPTS_DIR)/tcl_commands/eco.tcl


write_verilog $::env(RUN_DIR)/results/eco/net/eco_$::env(ECO_ITER).v
write_def     $::env(RUN_DIR)/results/eco/def/eco_$::env(ECO_ITER).def
set ::env(CURRENT_NETLIST) $::env(RUN_DIR)/results/eco/net/eco_$::env(ECO_ITER).v
set ::env(CURRENT_DEF)     $::env(RUN_DIR)/results/eco/def/eco_$::env(ECO_ITER).def

# File post-processing for pre-eco
if { $::env(ECO_ITER) == 1 } {
    move_to_dir [glob -directory $::env(RUN_DIR)/results/routing *.def]  \
                $::env(RUN_DIR)/results/routing/eco_[expr {$::env(ECO_ITER)-1}]/def
    move_to_dir [glob -directory $::env(RUN_DIR)/results/routing *.spef] \
                $::env(RUN_DIR)/results/routing/eco_[expr {$::env(ECO_ITER)-1}]/spef
    move_to_dir [glob -directory $::env(RUN_DIR)/results/routing *.sdf]  \
                $::env(RUN_DIR)/results/routing/eco_[expr {$::env(ECO_ITER)-1}]/sdf
}
