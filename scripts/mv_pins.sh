#!/bin/sh
if [[ $# -lt 2 ]]; then
    echo "usage ./mv_pins.sh from.def to.def"
    exit
fi

from=$1
to=$2
echo "from: $from"
echo "to: $to"

from_pins=$(sed -n '/PINS/,/END PINS/p' $from)
echo "$from_pins" > $to.pins
sed -e "/PINS/,/END PINS/c\${from_pins}" $to | sed -e "/\${from_pins}/r $to.pins" | sed -e "/\${from_pins}/d" > $to.tmp
mv $to.tmp $to
