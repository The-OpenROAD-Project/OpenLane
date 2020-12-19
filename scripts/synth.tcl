# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# inputs expected as env vars
set strategy $::env(SYNTH_STRATEGY)
#set opt $::env(SYNTH_OPT)
set buffering $::env(SYNTH_BUFFERING)
set sizing $::env(SYNTH_SIZING)

yosys -import

set vtop $::env(DESIGN_NAME)
#set sdc_file $::env(SDC_FILE)
set sclib $::env(LIB_SYNTH)

if { [info exists ::env(SYNTH_DEFINES) ] } {
	foreach define $::env(SYNTH_DEFINES) {
		puts "Defining $define"
		verilog_defines -D$define
	}
}

if { $::env(SYNTH_READ_BLACKBOX_LIB) } {
	puts "Reading $::env(LIB_SYNTH_COMPLETE_NO_PG) as a blackbox"
	foreach lib $::env(LIB_SYNTH_COMPLETE_NO_PG) {
		read_liberty -lib -ignore_miss_dir -setattr blackbox $lib
	}
}

if { [info exists ::env(EXTRA_LIBS) ] } {
	foreach lib $::env(EXTRA_LIBS) {
		read_liberty -lib -ignore_miss_dir -setattr blackbox $lib
	}
}

if { [info exists ::env(VERILOG_FILES_BLACKBOX)] } {
	foreach verilog_file $::env(VERILOG_FILES_BLACKBOX) {
		read_verilog -sv -lib $verilog_file
	}
}


# ns expected (in sdc as well)
set clock_period [expr {$::env(CLOCK_PERIOD)*1000}]

set driver  $::env(SYNTH_DRIVING_CELL)
set cload   $::env(SYNTH_CAP_LOAD)
# input pin cap of IN_3VX8
set max_FO $::env(SYNTH_MAX_FANOUT)
if {![info exist ::env(SYNTH_MAX_TRAN)]} {
	set ::env(SYNTH_MAX_TRAN) [expr {0.1*$clock_period}]
} else {
	set ::env(SYNTH_MAX_TRAN) [expr {$::env(SYNTH_MAX_TRAN) * 1000}]
}
set max_Tran $::env(SYNTH_MAX_TRAN)


# Mapping parameters
set A_factor  0.00
set B_factor  0.88
set F_factor  0.00

# Don't change these unless you know what you are doing
set stat_ext    ".stat.rpt"
set chk_ext    ".chk.rpt"
set gl_ext      ".gl.v"
set constr_ext  ".$clock_period.constr"
set timing_ext  ".timing.txt"
set abc_ext     ".abc"


# get old sdc, add library specific stuff for abc scripts
set sdc_file $::env(yosys_tmp_file_tag).sdc
set outfile [open ${sdc_file} w]
#puts $outfile $sdc_data
puts $outfile "set_driving_cell ${driver}"
puts $outfile "set_load ${cload}"
close $outfile


# ABC Scrips
set abc_rs_K    "resub,-K,"
set abc_rs      "resub"
set abc_rsz     "resub,-z"
set abc_rw_K    "rewrite,-K,"
set abc_rw      "rewrite"
set abc_rwz     "rewrite,-z"
set abc_rf      "refactor"
set abc_rfz     "refactor,-z"
set abc_b       "balance"

set abc_resyn2        "${abc_b}; ${abc_rw}; ${abc_rf}; ${abc_b}; ${abc_rw}; ${abc_rwz}; ${abc_b}; ${abc_rfz}; ${abc_rwz}; ${abc_b}"
#set abc_share         "strash; multi,-m; ${abc_resyn2}"

#set abc_resyn2a       "${abc_b};${abc_rw};${abc_b};${abc_rw};${abc_rwz};${abc_b};${abc_rwz};${abc_b}"
#set abc_resyn3        "balance;resub;resub,-K,6;balance;resub,-z;resub,-z,-K,6;balance;resub,-z,-K,5;balance"
#set abc_resyn2rs      "${abc_b};${abc_rs_K},6;${abc_rw};${abc_rs_K},6,-N,2;${abc_rf};${abc_rs_K},8;${abc_rw};${abc_rs_K},10;${abc_rwz};${abc_rs_K},10,-N,2;${abc_b},${abc_rs_K},12;${abc_rfz};${abc_rs_K},12,-N,2;${abc_rwz};${abc_b}"
#set compress2rs       "${abc_b},-l; ${abc_rs_K},6,-l; ${abc_rw},-l; ${abc_rs_K},6,-N,2,-l; ${abc_rf},-l; ${abc_rs_K},8,-l; ${abc_b}, -l; ${abc_rs_K},8,-N,2,-l; ${abc_rw},-l; ${abc_rs_K},10,-l; ${abc_rsz}, -l; ${abc_rs_K},10, -N, 2, -l; ${abc_b}, -l; ${abc_rs_K}, 12, -l; ${abc_rfz}, -l; ${abc_rs_K},12,-N,2,-l; ${abc_rwz}, -l; ${abc_b}, -l"

#set ms_opt            "dch; ${abc_resyn2};dch;${abc_resyn2};dch;${abc_resyn2};dch,-f;${abc_resyn2rs};"

#set ms_opt_           "strash; dch,-f; ${abc_resyn2};retime,-o,{D};"
#set ms_opt2           "${ms_opt};${ms_opt}"
#set ms_opt4           "${ms_opt2};${ms_opt2}"
#set ms_opt8           "${ms_opt4};${ms_opt4}"

#set abc_map_old         "map,-p,-B,0.88,-A,0.0,-M,1,{D},-F,$F_factor,-f"
#set abc_old_opt         "strash; dc2,-b,-l,-p;ifraig"
#set abc_new_opt         "strash;dch,-p;ifraig"
#set abc_retime_area     "retime,-D,{D},-M,5"
#set abc_retime_dly      "retime,-D,{D},-M,6"

#set abc_fine_tune       "buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D}; "
#set abc_map_new       	"amap,-m,-Q,0.2,-F,50,-A,50,-C,1000"
#set abc_map_new_area    "amap,-m,-Q,0.0,-F,20,-A,20,-C,1000, ${abc_retime_area}, ${abc_fine_tune}"
#set abc_map_new_dly     "amap,-i,-Q,1.0,-F,5,-A,5,-C,1000,${abc_retime_dly}, ${abc_fine_tune}"
#set abc_map_new_std     "amap,-m;${abc_retime_dly};${abc_fine_tune}"


set map_old_cnt			    "map,-p,-a,-B,0.2,-A,0.9,-M,0"
set map_old_dly			    "map,-p,-B,0.2,-A,0.9,-M,0"
set abc_retime_area   	"retime,-D,{D},-M,5"
set abc_retime_dly    	"retime,-D,{D},-M,6"
set abc_map_new_area  	"amap,-m,-Q,0.1,-F,20,-A,20,-C,5000"

if {$buffering==1} {
	set abc_fine_tune		"buffer,-N,${max_FO},-S,${max_Tran};upsize,{D};dnsize,{D}"
} elseif {$sizing} {
	set abc_fine_tune       "upsize,{D};dnsize,{D}"
} else {
	set abc_fine_tune       ""
}

set scpt_0        "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${map_old_cnt};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats -m"
set scpt_1        "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_dly};scleanup;${map_old_dly};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats -m"
set scpt_2        "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${abc_map_new_area};retime,-D,{D};${abc_fine_tune};stime,-p;print_stats -m"
set scpt_3        "+read_constr,${sdc_file};strash; ifraig; scorr; dc2; dretime; strash; &get -n; &dch -f; &nf {D}; &put; buffer,-N,${max_FO}; upsize {D}; dnsize {D}; stime -p;print_stats -m"


set scripts(0) $scpt_0
set scripts(1) $scpt_1
set scripts(2) $scpt_2
set scripts(3) $scpt_3

set scriptname(0) "scpt_0"
set scriptname(1) "scpt_1"
set scriptname(2) "scpt_2"
set scriptname(3) "scpt_3"


set vIdirsArgs ""
if {[info exist ::env(VERILOG_INCLUDE_DIRS)]} {
	foreach dir $::env(VERILOG_INCLUDE_DIRS) {
		lappend vIdirsArgs "-I$dir"
	}
	set vIdirsArgs [join $vIdirsArgs]
}

for { set i 0 } { $i < [llength $::env(VERILOG_FILES)] } { incr i } {
	read_verilog -sv {*}$vIdirsArgs [lindex $::env(VERILOG_FILES) $i]
}

select -module $vtop
show -format dot -prefix $::env(TMP_DIR)/synthesis/hierarchy
select -clear

hierarchy -check -top $vtop

# Infer tri-state buffers.
set tbuf_map false
if { [info exists ::env(TRISTATE_BUFFER_MAP)] } {
        if { [file exists $::env(TRISTATE_BUFFER_MAP)] } {
                set tbuf_map true
                tribuf
        } else {
          puts "WARNING: TRISTATE_BUFFER_MAP is defined but could not be found: $::env(TRISTATE_BUFFER_MAP)"
        }
}

if { $::env(SYNTH_NO_FLAT) } {
	synth -top $vtop
} else {
	synth -top $vtop -flatten
}

share -aggressive
opt
opt_clean -purge

tee -o "$::env(yosys_report_file_tag)_pre.stat" stat

# Map tri-state buffers.
if { $tbuf_map } {
        puts {mapping tbuf}
        techmap -map $::env(TRISTATE_BUFFER_MAP)
        simplemap
}

# handle technology mapping of latches
if { [info exists ::env(SYNTH_LATCH_MAP)] && [file exists $::env(SYNTH_LATCH_MAP)] } {
	techmap -map $::env(SYNTH_LATCH_MAP)
	simplemap
}

dfflibmap -liberty $sclib
tee -o "$::env(yosys_report_file_tag)_dff.stat" stat

if { [info exists ::env(SYNTH_EXPLORE)] && $::env(SYNTH_EXPLORE) } {
	design -save myDesign

	for { set index 0 }  { $index < [array size scriptname] }  { incr index } {
		puts "\[INFO\]: ABC: WireLoad : $scriptname($index)"
		design -load myDesign

		abc -D $clock_period \
			-constr "$sdc_file" \
			-liberty $sclib  \
			-script $scripts($index)

		setundef -zero

		hilomap -hicell {*}$::env(SYNTH_TIEHI_PORT) -locell {*}$::env(SYNTH_TIELO_PORT)

		# get rid of the assignments that make verilog2def fail
		splitnets
		opt_clean -purge
		insbuf -buf {*}$::env(SYNTH_MIN_BUF_PORT)

		tee -o "$::env(yosys_report_file_tag)_$index$chk_ext" check
		tee -o "$::env(yosys_report_file_tag)$index$stat_ext" stat -top $vtop -liberty [lindex $::env(LIB_SYNTH_COMPLETE_NO_PG) 0]
		write_verilog -noattr -noexpr -nohex -nodec -defparam "$::env(yosys_result_file_tag)_$index.v"
		design -reset
	}
} else {

	puts "\[INFO\]: ABC: WireLoad : S_$strategy"

	abc -D $clock_period \
		-constr "$sdc_file" \
		-liberty $sclib  \
		-script $scripts($strategy) \
		-showtmp;

	setundef -zero

	hilomap -hicell {*}$::env(SYNTH_TIEHI_PORT) -locell {*}$::env(SYNTH_TIELO_PORT)

	# get rid of the assignments that make verilog2def fail
	splitnets
	opt_clean -purge
	insbuf -buf {*}$::env(SYNTH_MIN_BUF_PORT)

	tee -o "$::env(yosys_report_file_tag)_$strategy$chk_ext" check
	tee -o "$::env(yosys_report_file_tag)_$strategy$stat_ext" stat -top $vtop -liberty [lindex $::env(LIB_SYNTH_COMPLETE_NO_PG) 0]
	write_verilog -noattr -noexpr -nohex -nodec -defparam "$::env(SAVE_NETLIST)"
}

if { $::env(SYNTH_NO_FLAT) } {
	design -reset
	read_liberty -lib -ignore_miss_dir -setattr blackbox $::env(LIB_SYNTH_COMPLETE_NO_PG)
	file copy -force $::env(SAVE_NETLIST) $::env(yosys_tmp_file_tag)_unflat.v
	read_verilog -sv $::env(SAVE_NETLIST)
	synth -top $vtop -flatten
	splitnets
	opt_clean -purge
	insbuf -buf {*}$::env(SYNTH_MIN_BUF_PORT)
	write_verilog -noattr -noexpr -nohex -nodec -defparam "$::env(SAVE_NETLIST)"
	tee -o "$::env(yosys_report_file_tag)_$strategy$chk_ext" check
	tee -o "$::env(yosys_report_file_tag)_$strategy$stat_ext" stat -top $vtop -liberty [lindex $::env(LIB_SYNTH_COMPLETE_NO_PG) 0]
}
