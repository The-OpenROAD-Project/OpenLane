#!/usr/bin/env perl

# This script is sourced from Brown (with slight modifications). It merges
# several timing libraries into one.
# ------------------------------------------------------------------------------

use strict;
use warnings;

my $sclname = $ARGV[0];
shift @ARGV;
my $cnt = @ARGV;

if($cnt>0){
  process_header($ARGV[0]);
  my $file;
  foreach my $file (@ARGV) {
      process_cells($file)
  }
  print "\n}\n";
} else {
  print "use: mergeLib.pl new_library_name lib1 lib2 lib3 ....";
}


sub process_header {
  my $filename  = shift;
  open(my $fh, '<', $filename) or die "Could not open file $filename $!";
  while (<$fh>) {
    if(/library\s*\(/) {
      print "library ($sclname) {\n";
      next;
    }
    last if(/^[\t\s]*cell\s*\(/);
    print $_;
  }
  close($fh)
}

sub process_cells {
  my $filename  = shift;

  open(my $fh, '<', $filename) or die "Could not open file $filename $!";

  my $flag = 0;
  # cut the cells
  while (<$fh>) {
    #chomp $_;
    if(/^[\t\s]*cell\s*\(/) {#&& $flag==0){
      die "Error! new cell before finishing the previous one!\n" if($flag!=0);
      print "\n$_";
      $flag=1;
    } elsif($flag > 0){
        $flag++ if(/\{/);
        $flag-- if(/\}/);
        #print "...}\n" if($flag==0);
        print "$_";
    }
  }
  close($fh)
}
