#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.
if [[ $# -lt 1 ]]; then
    echo "usage ./remove_pins.sh file.def"
    exit
fi

file=$1

# remove the PINS section
sed -ie "/PINS.*;/,/END PINS/d" $file
# remove extra \ characters
sed -ie "s/[\\]//g" $file
# remove ( PIN xxx ) in the nets section
sed -ie "s/(\sPIN\s[^[:space:]]*\s)\s//g" $file
# remove empty nets
sed -ie "/NETS/,/END NETS/ s/^-\s.[^[:space:]]\+\s\+;$//g" $file

