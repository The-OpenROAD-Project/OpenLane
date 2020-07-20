#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
if [[ $# -lt 1 ]]; then
    echo "usage $0 file.def"
    exit
fi

file=$1

# remove extra \ characters
sed -ie "s/[\\]//g" $file
# remove empty nets
sed -ie "/NETS/,/END NETS/ s/^\s*-\s\+[^[:space:]]\+\s\+\((\s\+[^[:space:]]\+\s\+[^[:space:]]\+\s\+)\s\+\)\{0,1\}\(+ USE SIGNAL\s\+\)\{0,1\};$//g" $file

