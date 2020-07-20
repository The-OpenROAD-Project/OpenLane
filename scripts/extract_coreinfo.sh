#!/bin/sh
# Copyright (c) Efabless Corporation. All rights reserved.
# See LICENSE file in the project root for full license information.

perl -0ne 'print "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11" if /DIEAREA.*\s(\d+)\s(\d+).*\s(\d+)\s(\d+)\s.*\n[\S\s]*ROW_0 $ENV{'PLACE_SITE'}\s*(\d+)\s*(\d+)[\S\s]*ROW_\d+ $ENV{'PLACE_SITE'}\s*(\d+)\s*(\d+).*DO (\d+).*STEP (\d+).*\n/' $1
