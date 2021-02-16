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
scriptDir=$3
# This assumes that all these files exist
tritonRoute_log=$(python3 $3/get_file_name.py -p ${path}/logs/routing/ -o tritonRoute.log 2>&1)
tritonRoute_drc=$(python3 $3/get_file_name.py -p ${path}/reports/routing/ -o tritonRoute.drc 2>&1)
yosys_rprt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o .stat.rpt -io 2>&1)
routed_runtime_rpt=${path}/reports/routed_runtime.txt
total_runtime_rpt=${path}/reports/total_runtime.txt
wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_wns.rpt 2>&1)
pl_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/placement/ -o replace.log 2>&1)
opt_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_openphysyn_wns.rpt 2>&1)
if ! [ -f $opt_wns_rpt ]; then
        opt_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_resizer_timing_wns.rpt 2>&1)
fi
fr_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/logs/routing/ -o fastroute.log 2>&1)
spef_wns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_spef_wns.rpt 2>&1)
tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_tns.rpt 2>&1)
pl_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/placement/ -o replace.log 2>&1)
opt_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_openphysyn_tns.rpt 2>&1)
if ! [ -f $opt_tns_rpt ]; then
        opt_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_post_resizer_timing_tns.rpt 2>&1)
fi
fr_tns_rpt=$(python3 $3/get_file_name.py -p  ${path}/reports/routing/ -o fastroute.log 2>&1)
spef_tns_rpt=$(python3 $3/get_file_name.py -p ${path}/reports/synthesis/ -o opensta_spef_tns.rpt 2>&1)
HPWL_rpt=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o replace.log 2>&1)
yosys_log=$(python3 $3/get_file_name.py -p ${path}/logs/synthesis/ -o yosys.log 2>&1)
magic_drc=$(python3 $3/get_file_name.py -p ${path}/reports/magic/ -o magic.drc 2>&1)
klayout_drc=$(python3 $3/get_file_name.py -p ${path}/reports/klayout/ -o magic.lydrc -io 2>&1)
tapcell_log=$(python3 $3/get_file_name.py -p ${path}/logs/floorplan/ -o tapcell.log 2>&1)
diodes_log=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o diodes.log 2>&1)
magic_antenna_report=$(python3 $3/get_file_name.py -p ${path}/reports/magic/ -o magic.antenna_violators.rpt 2>&1)
arc_antenna_report=$(python3 $3/get_file_name.py -p ${path}/reports/routing/ -o antenna.rpt 2>&1)
fr_log=${path}/logs/routing/fastroute.log
cvc_log=$(python3 $3/get_file_name.py -p ${path}/logs/cvc/ -o cvc_screen.log 2>&1)
tritonRoute_def="${path}/results/routing/${designName}.def"
openDP_log=$(python3 $3/get_file_name.py -p ${path}/logs/placement/ -o opendp.log 2>&1)
lvs_report=${path}/results/lvs/${designName}.lvs_parsed.*.log
# Extracting info from Yosys
cell_count=$(grep "cells" $yosys_rprt -s | tail -1 | sed -r 's/.*[^0-9]//')
if ! [[ $cell_count ]]; then cell_count=-1; fi

#Extracting routed_runtime info
if [ -f $routed_runtime_rpt ]; then
        routed_runtime=$(sed 's/.*in //' $routed_runtime_rpt)
        if ! [[ $routed_runtime ]]; then routed_runtime=-1; fi
else
        routed_runtime=-1;
fi

#Extracting total_runtime info
if [ -f $total_runtime_rpt ]; then
        total_runtime=$(sed 's/.*in //' $total_runtime_rpt)
        if ! [[ $total_runtime ]]; then total_runtime=-1; fi
        flow_status=$(sed 's/ for .*//' $total_runtime_rpt)
        if ! [[ $flow_status ]]; then
                flow_status="unknown_no_content_in_file"; 
        else
                flow_status="${flow_status// /_}"
        fi
else
        total_runtime=-1;
        flow_status="unknown_no_total_runtime_file";
fi

#Extracting Die Area info
if [ -f $tritonRoute_def ]; then
        tmpa=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 1)
        tmpb=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 2)
        tmpc=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 3)
        tmpd=$(awk  '/DIEAREA/ {print $3, $4, $7, $8; exit}' $tritonRoute_def | cut -d' ' -f 4)
        diearea=$(( (($tmpc-$tmpa)/1000)*(($tmpd-$tmpb)/1000) ))
        if ! [[ $diearea ]]; then diearea=-1;fi
else
        diearea=-1;
fi

#Place Holder for cell per um
cellperum=-1
#if ! [[ $cellperum ]]; then cellperum=-1;fi

#Extracting OpenDP Reported Utilization
opendpUtil=$(grep "utilization" $openDP_log -s | head -1 | sed -E 's/.* (\S+).*%/\1/')
if ! [[ $opendpUtil ]]; then opendpUtil=-1; fi

#Extracting TritonRoute memory usage peak
tritonRoute_memoryPeak=$(grep ", peak = " $tritonRoute_log -s | tail -1 | sed -E 's/.*peak = (\S+).*/\1/')
if ! [[ $tritonRoute_memoryPeak ]]; then tritonRoute_memoryPeak=-1; fi

#Extracting TritonRoute Violations Information
tritonRoute_violations=$(grep "number of violations" $tritonRoute_log -s | tail -1 | sed -r 's/.*[^0-9]//')
if ! [[ $tritonRoute_violations ]]; then tritonRoute_violations=-1; fi
Other_violations=$tritonRoute_violations;

if [ -f $tritonRoute_drc ]; then
        Short_violations=$(grep "Short" $tritonRoute_drc -s | wc -l)
        if ! [[ $Short_violations ]]; then Short_violations=-1; fi
        Other_violations=$((Other_violations-Short_violations));

        MetSpc_violations=$(grep "MetSpc" $tritonRoute_drc -s | wc -l)
        if ! [[ $MetSpc_violations ]]; then MetSpc_violations=-1; fi
        Other_violations=$((Other_violations-MetSpc_violations));

        OffGrid_violations=$(grep "OffGrid" $tritonRoute_drc -s | wc -l)
        if ! [[ $OffGrid_violations ]]; then OffGrid_violations=-1; fi
        Other_violations=$((Other_violations-OffGrid_violations));

        MinHole_violations=$(grep "MinHole" $tritonRoute_drc -s | wc -l)
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
        Magic_violations=$(grep "^ [0-9]" $magic_drc -s | wc -l)
        if ! [[ $Magic_violations ]]; then Magic_violations=-1; fi
        if [ $Magic_violations -ne -1 ]; then Magic_violations=$(((Magic_violations+3)/4)); fi
else
        Magic_violations=-1;
fi


#Extracting Klayout DRC Violations from magic.lydrc
if [ -f "$klayout_drc" ]; then
        klayout_violations=$(grep "<item>" $klayout_drc -s | wc -l)
        if ! [[ $klayout_violations ]]; then klayout_violations=0; fi
else
        klayout_violations=-1;
fi

# Extracting Antenna Violations
if [ -f $arc_antenna_report ]; then
        #arc check
        antenna_violations=$(grep "Number of pins violated:" $arc_antenna_report -s | tail -1 | sed -r 's/.*[^0-9]//')
        if ! [[ $antenna_violations ]]; then antenna_violations=-1; fi
else
        if [ -f $magic_antenna_report ]; then
                #old magic check
                antenna_violations=$(wc $magic_antenna_report -l | cut -d ' ' -f 1)
                if ! [[ $antenna_violations ]]; then antenna_violations=-1; fi
        else

                antenna_violations=-1;
        fi
fi

#Extracting Other information from TritonRoute Logs
wire_length=$(grep "total wire length =" $tritonRoute_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $wire_length ]]; then wire_length=-1; fi
vias=$(grep "total number of vias =" $tritonRoute_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $vias ]]; then vias=-1; fi

#Extracting Info from OpenSTA
wns=$(grep "wns" $wns_rpt -s | sed -r 's/wns //')
if ! [[ $wns ]]; then wns=-1; fi

#Extracting info from OpenSTA post global placement using estimate parasitics
pl_wns=$(grep "wns" $pl_wns_rpt -s | tail -1 |sed -r 's/wns //')
if ! [[ $pl_wns ]]; then pl_wns=$wns; fi

#Extracting Info from OpenPhySyn
opt_wns=$(grep "wns" $opt_wns_rpt -s | tail -1 |sed -r 's/wns //')
if ! [[ $opt_wns ]]; then opt_wns=$pl_wns; fi

#Extracting info from OpenSTA post global routing using estimate parasitics
fr_wns=$(grep "wns" $fr_wns_rpt -s | sed -r 's/wns //')
if ! [[ $fr_wns ]]; then fr_wns=$opt_wns; fi

#Extracting info from OpenSTA post SPEF extraction
spef_wns=$(grep "wns" $spef_wns_rpt -s | sed -r 's/wns //')
if ! [[ $spef_wns ]]; then spef_wns=$fr_wns; fi

#Extracting Info from OpenSTA
tns=$(grep "tns" $tns_rpt -s | sed -r 's/tns //')
if ! [[ $tns ]]; then tns=-1; fi

#Extracting info from OpenSTA post global placement using estimate parasitics
pl_tns=$(grep "tns" $pl_tns_rpt -s | tail -1 |sed -r 's/tns //')
if ! [[ $pl_tns ]]; then pl_tns=$tns; fi

#Extracting Info from OpenPhySyn
opt_tns=$(grep "tns" $opt_tns_rpt -s | tail -1 |sed -r 's/tns //')
if ! [[ $opt_tns ]]; then opt_tns=$pl_tns; fi

#Extracting info from FR:estimate_parasitics
fr_tns=$(grep "tns" $fr_tns_rpt -s | sed -r 's/tns //')
if ! [[ $fr_tns ]]; then fr_tns=$opt_tns; fi

#Extracting info from OpenSTA post SPEF extraction
spef_tns=$(grep "tns" $spef_tns_rpt -s | sed -r 's/tns //')
if ! [[ $spef_tns ]]; then spef_tns=$opt_tns; fi


#Extracting Info from RePlace
#standalone replace extraction
#hpwl=$(cat $HPWL_rpt)

#openroad replace extraction
hpwl=$(grep " HPWL: " $HPWL_rpt -s | tail -1 | sed -E 's/.*HPWL: (\S+).*/\1/')
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
        val=$(grep " \+${metric}[^0-9]\+ \+[0-9]\+" $yosys_log -s | tail -1 | sed -r 's/.*[^0-9]([0-9]+)$/\1/')
        if ! [[ $val ]]; then val=0; fi
        metrics_vals+=("$val")
done

#Extracting info from yosys logs
input_output=$(grep -e "ABC: netlist" $yosys_log -s | tail -1 | sed -r 's/ABC: netlist[^0-9]*([0-9]+)\/ *([0-9]+).*/\1 \2/')
if ! [[ $input_output ]]; then input_output="-1 -1"; fi
level=$(grep -e "ABC: netlist" $yosys_log -s | tail -1 | sed -r 's/.*lev.*[^0-9]([0-9]+)$/\1/')
if ! [[ $level ]]; then level=-1; fi

#Extracting layer usage percentage
layer1=$(grep "Layer 1 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 1 use percentage: (\S+)%/\1/')
if ! [[ $layer1 ]]; then layer1=-1; fi
layer2=$(grep "Layer 2 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 2 use percentage: (\S+)%/\1/')
if ! [[ $layer2 ]]; then layer2=-1; fi
layer3=$(grep "Layer 3 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 3 use percentage: (\S+)%/\1/')
if ! [[ $layer3 ]]; then layer3=-1; fi
layer4=$(grep "Layer 4 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 4 use percentage: (\S+)%/\1/')
if ! [[ $layer4 ]]; then layer4=-1; fi
layer5=$(grep "Layer 5 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 5 use percentage: (\S+)%/\1/')
if ! [[ $layer5 ]]; then layer5=-1; fi
layer6=$(grep "Layer 6 use percentage:" $fr_log -s | tail -1 | sed -E 's/Layer 6 use percentage: (\S+)%/\1/')
if ! [[ $layer6 ]]; then layer6=-1; fi

#Extracting Endcaps and TapCells
endcaps=$(grep "Endcaps inserted:" $tapcell_log -s | tail -1 | sed -E 's/.*Endcaps inserted: (\S+)/\1/')
if ! [[ $endcaps ]]; then endcaps=0; fi

tapcells=$(grep "Tapcells inserted:" $tapcell_log -s | tail -1 | sed -E 's/.*Tapcells inserted: (\S+)/\1/')
if ! [[ $tapcells ]]; then tapcells=0; fi


#Extracting Diodes
diodes=$(grep "inserted!" $diodes_log -s | tail -1 | sed -E 's/.* (\S+) of .* inserted!/\1/')
if ! [[ $diodes ]]; then
        diodes=$(grep "diodes inserted" $fr_log -s | tail -1 | sed -E 's/.* (\S+) diodes inserted/\1/')
        if ! [[ $diodes ]]; then diodes=0; fi
fi

#Summing the number of Endcaps, Tapcells, and Diodes
physical_cells=$(((endcaps+tapcells)+diodes));

#Extracting the total number of lvs errors
if ! [[ -f "$lvs_report" ]]; then
        lvs_total_errors=$(grep "Total errors =" $lvs_report -s | tail -1 | sed -r 's/[^0-9]*//g')
        if ! [[ $lvs_total_errors ]]; then lvs_total_errors=0; fi
else
        lvs_total_errors=-1;
fi


#Extracting the total number of cvc errors
cvc_total_errors=$(grep "CVC: Total: " $cvc_log -s | tail -1 | sed -r 's/[^0-9]*//g')
if ! [[ $cvc_total_errors ]]; then cvc_total_errors=-1; fi


result="$flow_status $total_runtime $routed_runtime $diearea $cellperum $opendpUtil $tritonRoute_memoryPeak $cell_count $tritonRoute_violations $Short_violations $MetSpc_violations $OffGrid_violations $MinHole_violations $Other_violations $Magic_violations $antenna_violations $lvs_total_errors $cvc_total_errors $klayout_violations $wire_length $vias $wns $pl_wns $opt_wns $fr_wns $spef_wns $tns $pl_tns $opt_tns $fr_tns $spef_tns $hpwl $layer1 $layer2 $layer3 $layer4 $layer5 $layer6"
for val in "${metrics_vals[@]}"; do
	result+=" $val"
done
result+=" $input_output"
result+=" $level"
result+=" $endcaps $tapcells $diodes $physical_cells"
echo "$result"
