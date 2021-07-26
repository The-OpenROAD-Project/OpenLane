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


# This Script removes specified input cells ARGV[1] from the lib file input ARGV [0]

use warnings;
use strict;
use feature qw( switch );
no if $] >= 5.018, warnings => qw( experimental::smartmatch );

open (CELLS,'<', $ARGV[1]) or die("Couldn't open $ARGV[1]");

my @cells = ();
while(<CELLS>){ #cells to remove
  next if (/\#/);
  chop($_);
  push @cells, $_;
}
close(CELLS);

my $state = 0;
my $count = 0;
for ($ARGV[0]) {
  for (split) {
    open (LIB, $_) or die("Couldn't open $_");

    while(my $line=<LIB>){
      given ($state) {
        when ($state==0){
          #print $line;
          if ($line =~ /cell\s*\(\"?(.*?)\"?\)/) {
            #print "$1\n";
            if (grep { $_ eq $1 } @cells) {
              $state = 2;
              print "/* removed $1 */\n";
            } else {
              $state = 1;
              print $line;
            }
            $count = 1;
          } else {
            print $line;
          }
        }

        when($state==1){
          $count++ if ($line =~ /\{/);
          $count-- if ($line =~ /\}/);
          $state = 0 if($count==0);
          print $line;
        }


        when($state==2){
          $count++ if ($line =~ /\{/);
          $count-- if ($line =~ /\}/);
          $state = 0 if($count==0);
        }


      }
    }

    close(LIB);
  }
}
