#!/bin/bash
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



path=$1
designName=$2
# This assumes that all these files exist
tritonRoute_log="${path}/logs/routing/tritonRoute.log"
tritonRoute_drc="${path}/reports/routing/tritonRoute.drc"
yosys_rprt=${path}/reports/synthesis/yosys_*.stat.rpt
runtime_rpt=${path}/reports/runtime.txt
wns_rpt=${path}/reports/synthesis/opensta_wns.rpt
HPWL_rpt=${path}/reports/placement/replace_hpwl.rpt
yosys_log=${path}/logs/synthesis/yosys.log
magic_drc=${path}/logs/magic/magic.drc
tapcell_log=${path}/logs/floorplan/tapcell.log
diodes_log=${path}/logs/placement/diodes.log
antenna_report=${path}/reports/magic/magic.antenna_violators.rpt
tritonRoute_def="${path}/results/routing/${designName}.def"
openDP_log=${path}/logs/placement/opendp.log
# Extracting info from Yosys
cell_count=$(cat ${yosys_rprt} | grep "cells" | sed -r 's/.*[^0-9]//') 
if ! [[ $cell_count ]]; then cell_count=-1; fi

#Extracting runtime info
runtime=$(sed 's/.*in //' $runtime_rpt)
if ! [[ $runtime ]]; then runtime=-1; fi

#Extracting Die Area info
tmpa=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 1)
tmpb=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 2)
tmpc=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 3)
tmpd=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 4)
diearea=$(( (($tmpc-$tmpa)/1000)*(($tmpd-$tmpb)/1000) ))
if ! [[ $diearea ]]; then diearea=-1;fi

#Place Holder for cell per um
cellperum=-1
#if ! [[ $cellperum ]]; then cellperum=-1;fi

#Extracting OpenDP Reported Utilization
opendpUtil=$(grep "design util" $openDP_log | tail -1 | sed -E 's/.*: (\S+).*/\1/')
if ! [[ $opendpUtil ]]; then opendpUtil=-1; fi

#Extracting TritonRoute memory usage peak
tritonRoute_memoryPeak=$(grep ", peak = " $tritonRoute_log | tail -1 | sed -E 's/.*peak = (\S+).*/\1/')
if ! [[ $tritonRoute_memoryPeak ]]; then tritonRoute_memoryPeak=-1; fi

#Extracting TritonRoute Violations Information
tritonRoute_violations=$(grep "number of violations" $tritonRoute_log | tail -1 | sed -r 's/.*[^0-9]//')
if ! [[ $tritonRoute_violations ]]; then tritonRoute_violations=-1; fi
Other_violations=$tritonRoute_violations;

if [ -f $tritonRoute_drc ]; then
        Short_violations=$(grep "Short" $tritonRoute_drc | wc -l)
        if ! [[ $Short_violations ]]; then Short_violations=-1; fi
        Other_violations=$((Other_violations-Short_violations));

        MetSpc_violations=$(grep "MetSpc" $tritonRoute_drc | wc -l)
        if ! [[ $MetSpc_violations ]]; then MetSpc_violations=-1; fi
        Other_violations=$((Other_violations-MetSpc_violations));

        OffGrid_violations=$(grep "OffGrid" $tritonRoute_drc | wc -l)
        if ! [[ $OffGrid_violations ]]; then OffGrid_violations=-1; fi
        Other_violations=$((Other_violations-OffGrid_violations)); 

        MinHole_violations=$(grep "MinHole" $tritonRoute_drc | wc -l)
        if ! [[ $MinHole_violations ]]; then MinHole_violations=-1; fi
        Other_violations=$((Other_violations-MinHole_violations));
else
        Short_violations=-1;
        MetSpc_violations=-1;
        OffGrid_violations=-1;
        MinHole_violations=-1;
fi

#Extracting Magic Violations from Magic drc
if [ -f $magic_drc ]; then
        Magic_violations=$(grep "^ [0-9]" $magic_drc | wc -l)
        if ! [[ $Magic_violations ]]; then Magic_violations=-1; fi
        if [ $Magic_violations -ne -1 ]; then Magic_violations=$(((Magic_violations+3)/4)); fi
else
        Magic_violations=-1;
fi

# Extracting Antenna Violations
if [ -f $antenna_report ]; then
        antenna_violations=$(wc $antenna_report -l | cut -d ' ' -f 1)
        if ! [[ $antenna_violations ]]; then antenna_violations=-1; fi
else
        antenna_violations=-1;
fi

#Extracting Other information from TritonRoute Logs
wire_length=$(grep "total wire length =" $tritonRoute_log | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $wire_length ]]; then wire_length=-1; fi
vias=$(grep "total number of vias =" $tritonRoute_log | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $vias ]]; then vias=-1; fi

#Extracting Info from OpenSTA
wns=$(grep "wns" $wns_rpt | sed -r 's/wns //')
if ! [[ $wns ]]; then wns=-1; fi

#Extracting Info from RePlace
hpwl=$(cat $HPWL_rpt)
if ! [[ $hpwl ]]; then hpwl=-1; fi

#Extracting Info from Yosys logs
declare -a metrics=(
        "Number of wires:"
        "Number of wire bits:"
        "Number of public wires:"
        "Number of public wire bits:"
        "Number of memories:"
        "Number of memory bits:"
        "Number of processes:"
        "Number of cells:"
        "\$_AND_"
        "\$_DFF_"
        "\$_NAND_"
        "\$_NOR_"
        "\$_OR"
        "\$_XOR"
        "\$_XNOR"
        "\$_MUX"
        )

metrics_vals=()
for metric in "${metrics[@]}"; do
        val=$(grep " \+${metric}[^0-9]\+ \+[0-9]\+" $yosys_log | tail -1 | sed -r 's/.*[^0-9]([0-9]+)$/\1/')
        if ! [[ $val ]]; then val=-1; fi
        metrics_vals+=("$val")
done

#Extracting info from yosys logs
input_output=$(grep -e "ABC: netlist" $yosys_log | tail -1 | sed -r 's/ABC: netlist[^0-9]*([0-9]+)\/ *([0-9]+).*/\1 \2/')
if ! [[ $input_output ]]; then input_output="-1 -1"; fi
level=$(grep -e "ABC: netlist" $yosys_log | tail -1 | sed -r 's/.*lev.*[^0-9]([0-9]+)$/\1/')
if ! [[ $level ]]; then level=-1; fi


#Extracting Endcaps and TapCells
endcaps=$(grep "#Endcaps inserted:" $tapcell_log | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $endcaps ]]; then endcaps=-1; fi

tapcells=$(grep "#Tapcells inserted:" $tapcell_log | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $tapcells ]]; then tapcells=-1; fi


#Extracting Diodes
diodes=$(grep "inserted!" $diodes_log | tail -1 | sed -E 's/.* (\S+) of .* inserted!/\1/')
if ! [[ $diodes ]]; then diodes=-1; fi

#Summing the number of Endcaps, Tapcells, and Diodes
physical_cells=$(((endcaps+tapcells)+diodes));




result="$runtime $diearea $cellperum $opendpUtil $tritonRoute_memoryPeak $cell_count $tritonRoute_violations $Short_violations $MetSpc_violations $OffGrid_violations $MinHole_violations $Other_violations $Magic_violations $antenna_violations $wire_length $vias $wns $hpwl"
for val in "${metrics_vals[@]}"; do
	result+=" $val"
done
result+=" $input_output"
result+=" $level"
result+=" $endcaps $tapcells $diodes $physical_cells"
echo "$result"
