#!/bin/bash
: ${1?"Usage: $0 file.gds llx lly urx ury"}
: ${2?"Usage: $0 file.gds llx lly urx ury"}
: ${3?"Usage: $0 file.gds llx lly urx ury"}
: ${4?"Usage: $0 file.gds llx lly urx ury"}
: ${5?"Usage: $0 file.gds llx lly urx ury"}
: ${PDK_ROOT?"You need to export PDK_ROOT"}

cat <<HEREDOC > /dev/stderr
====================
WARNING
====================
erase_box.sh is deprecated and WILL be removed in a future version of OpenLane.

Please update your interactive scripts to use the built-in OpenLane function
"erase_box" instead.
====================
HEREDOC

MAGIC_SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export PDK=sky130A
export MAGIC_MAGICRC=$PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc
export MAGTYPE=mag
export CURRENT_GDS=$1
export _tmp_mag_box_coordinates="$2 $3 $4 $5"
export SAVE_GDS=${1%.*}_erased.gds

magic -rcfile $MAGIC_MAGICRC -dnull -noconsole $MAGIC_SCRIPTS_DIR/gds/erase_box.tcl

ls $SAVE_GDS
