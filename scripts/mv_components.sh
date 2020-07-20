#!/bin/sh
if [[ $# -lt 2 ]]; then
    echo "usage ./mv_components.sh from.def to.def"
    exit
fi

from=$1
to=$2
echo "from: $from"
echo "to: $to"

from_components=$(sed -n '/COMPONENTS/,/COMPONENTS/p' $from)
echo "$from_components" > $to.comps
sed -e "/COMPONENTS/,/COMPONENTS/c\${from_components}" $to | sed -e "/\${from_components}/r $to.comps" | sed -e "/\${from_components}/d" > $to.tmp
mv $to.tmp $to
rm $to.comps
