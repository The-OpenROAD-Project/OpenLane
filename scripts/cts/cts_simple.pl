#!/usr/bin/perl
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


# simple Clock Tree Syntheizer 
#   By: M. Shalan, Dec 2019
#   
#   usage: ./cts.pl <netlist.v> <fanout> <clock_net_name> 
#   
#   You need to set the following variables based on the PDK/CSL
#       root_clkbuf :   CT root buffer type
#       clkbuf      :   CT branching buffer type
#       clkbuf_in   :   Buffer input pin name
#       clkbuf_out  :   Buffer output pin name
#
#
use POSIX;
use Switch;
my $leaves;# = $ARGV[0];
my $vlg_fn = $ARGV[0];
my $fanout = $ARGV[1];
my $clk_net = $ARGV[2];
my $root_clkbuf = $ARGV[3];
my $clkbuf = $ARGV[4];
my $clkbuf_in = $ARGV[5];
my $clkbuf_out = $ARGV[6];
my $clk_port = $ARGV[7];
unless (-e $vlg_fn) {
    print "$vlg_fn File Doesn't Exist!";
    exit 0;
}
my $clk_net_grep_pattern = $clk_net;
my $clk_net_perl_pattern = $clk_net;
$clk_net_perl_pattern =~ s/\./\\./;
$clk_net_perl_pattern =~ s/\\/\\\\/;
$clk_net_grep_pattern =~ s/\\/\\\\\\/;

$leaves = `grep "$clk_port(\\s*$clk_net_grep_pattern\\s*)" $vlg_fn | wc -l`;
my $levels = logb($leaves, $fanout); 
# This array holds the number of buffers @ each level
#@buffs = (0) x ($levels + 1); 
@buffs = (0) x 20;
$buffs[0] = $leaves;
@vlg_wires = ();
@vlg_cells = ();
%def_nets;
@def_comp = ();
# Verilog o/p
my $cell_cnt = 0;
for my $l (1..$levels-1) {
    $l1 = $l - 1;
    $inst = "_CTS_buf_".$l."_";   
    $owire = "clk_$l1"."_";   
    $iwire = "clk_$l"."_";   
    for(my $i = 0; $i < $leaves; $i+=($fanout**$l)){
        $ii = floor($i/($fanout**($l+1))) * ($fanout**($l+1));
        my $cell_nm = "$inst".$i;
        push @vlg_cells, "$clkbuf $cell_nm ( \n\t.$clkbuf_in($iwire$ii),\n\t.$clkbuf_out($owire$i)\n);\n";
        push @vlg_wires, "wire $owire$i;\n";
        $buffs[$l]++;
        $cell_cnt++;
    }
    print "\n";
}
my $root_net = "clk_".($levels-1)."_0";
push @vlg_cells, "$root_clkbuf _CTS_root (\n\t.$clkbuf_in($clk_net ),\n\t.$clkbuf_out($root_net)\n);\n"; 
push @vlg_wires, "wire clk_".($levels-1)."_0;\n";
# Insert the newly created wires and buufers into the netlist
open(FH, '<', $vlg_fn) or die $!;
my $flag = 0; 
my $ff_cnt = 0;
while(<FH>){
   switch ($flag){
       case 0   { $flag = 1 if($_ =~ /wire/); print $_}
       case 1   { 
                    if(!($_ =~ /wire/) && !($_ =~ /input/) && !($_ =~ /output/)) { 
                        $flag = 2;
                        print "\n// CTS added wires\n";
                        print @vlg_wires;
                        print "\n// CTS added buffers\n";
                        print @vlg_cells;
                        print "\n"; 
                        print $_;
                    } else {
                        print $_;
                    }
                }
        case 2  {
                    if($_ =~ /$clk_port\(\s*$clk_net_perl_pattern\s*\)/) {
                        my $clk_wire_name = "clk_0_".int($ff_cnt / $fanout) * $fanout; 
                        #print "$clk_wire_name \n";
                        $_ =~ s/$clk_net_perl_pattern/$clk_wire_name/g;
                        #print $_;
                        $ff_cnt++; 
                    } 
                    print $_;
                }
   }
}
close(FH);
sub logb {
        my $n = shift;
        my $b = shift;
        return ceil(log($n)/log($b));
}

