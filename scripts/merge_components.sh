#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
# merges COMPONENTS of file1.def and file2.def into the existing to.def file
if [[ $# -lt 3 ]]; then
    echo "usage ./merge_components.sh file1.def file2.def to.def"
    exit
fi

file1=$1
file2=$2
to=$3

if [[ ! -f $to ]]; then
    echo "$to doesn't exist!"
    exit
fi

comps1=$(sed -n "/COMPONENTS/,/COMPONENTS/p" $file1)
ncomps1=$(echo "$comps1" | grep -om1 "[0-9]\+")

comps2=$(sed -n "/COMPONENTS/,/COMPONENTS/p" $file2)
ncomps2=$(echo "$comps2" | grep -om1 "[0-9]\+")

ncomps3=$(( $ncomps1 + $ncomps2 ))
echo "COMPONENTS $ncomps3 ;" > $to.merged_comps
echo "$comps1" | head -n -1 | tail -n +2 >> $to.merged_comps
echo "$comps2" | head -n -1 | tail -n +2 >> $to.merged_comps
echo "END COMPONENTS" >> $to.merged_comps
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/mv_components.sh $to.merged_comps $to
# rm $to.merged_comps

