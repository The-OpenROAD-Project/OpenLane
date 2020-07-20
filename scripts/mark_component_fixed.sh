#!/bin/sh
if [[ $# -lt 2 ]]; then
    echo "usage ./mark_component_fixed.sh cell_name file.def"
    exit
fi

sed -ie "/^- [^[:space:]]\+ $1 .\+;$/ s/PLACED/FIXED/g" $2
