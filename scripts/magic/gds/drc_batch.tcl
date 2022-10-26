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

if { [info exists ::env(TECH)] } {
    tech load $::env(TECH)
}

gds read $::env(GDS_INPUT)

proc custom_drc_save_report {{cellname ""} {outfile ""}} {
    if {$outfile == ""} {set outfile "drc.out"}

    set fout [open $outfile w]
    set oscale [cif scale out]

    # magic::suspendall

    if {$cellname == ""} {
        select top cell
        set cellname [cellname list self]
        set origname ""
    } else {
        set origname [cellname list self]
        puts stdout "\[INFO\]: Loading $cellname\n"
        flush stdout

        load $cellname
        select top cell
    }

    drc check
    set count [drc list count]

    puts $fout "$cellname count: $count"
    puts $fout "----------------------------------------"
    set drcresult [drc listall why]
    foreach {errtype coordlist} $drcresult {
        puts $fout $errtype
        puts $fout "----------------------------------------"
        foreach coord $coordlist {
            set bllx [expr {$oscale * [lindex $coord 0]}]
            set blly [expr {$oscale * [lindex $coord 1]}]
            set burx [expr {$oscale * [lindex $coord 2]}]
            set bury [expr {$oscale * [lindex $coord 3]}]
            set coords [format " %.3fum %.3fum %.3fum %.3fum" $bllx $blly $burx $bury]
            puts $fout "$coords"
        }
        puts $fout "----------------------------------------"
    }
    puts $fout ""

    if {$origname != ""} {
        load $origname
    }

    # magic::resumeall

    close $fout
    puts "\[INFO\]: DONE with $outfile\n"
    #flush stdout
}

custom_drc_save_report $::env(DESIGN_NAME) $::env(REPORT_OUTPUT)
