#!/bin/sh
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


perl -0ne 'print "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11" if /DIEAREA.*\s(\d+)\s(\d+).*\s(\d+)\s(\d+)\s.*\n[\S\s]*ROW_0 $ENV{'PLACE_SITE'}\s*(\d+)\s*(\d+)[\S\s]*ROW_\d+ $ENV{'PLACE_SITE'}\s*(\d+)\s*(\d+).*DO (\d+).*STEP (\d+).*\n/' $1
