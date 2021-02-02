#!/bin/bash

: ${1?"Usage: $0 file.gds llx lly urx ury"}
: ${2?"Usage: $0 file.gds llx lly urx ury"}
: ${3?"Usage: $0 file.gds llx lly urx ury"}
: ${4?"Usage: $0 file.gds llx lly urx ury"}
: ${5?"Usage: $0 file.gds llx lly urx ury"}
: ${PDK_ROOT?"You need to export PDK_ROOT"}


export PDK=sky130A

export MAGIC_MAGICRC=$PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc

MAGTYPE=mag magic -rcfile $MAGIC_MAGICRC -dnull -noconsole  <<EOF
echo $MAGTYPE
tech unlock *
gds read $1
box $2um $3um $4um $5um
erase
select area
delete
#### REVISE THIS:
select top cell
erase labels
####
gds write ${1%.*}_erased.gds
EOF
ls ${1%.*}_erased.gds
