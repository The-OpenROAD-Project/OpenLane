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

set -e

: ${1?"Usage: $0 tech_file input.gds output.txt"}
: ${2?"Usage: $0 tech_file input.gds output.txt"}
: ${3?"Usage: $0 tech_file input.gds output.txt"}

echo "Using Techfile: $1"
echo "Using GDS file: $2"
echo "Output Report File: $3"
# The -a here is necessary to handle race conditions.
# This limits the max number of possible jobs to 100.
klayout -b \
    -rd input=$2 \
    -rd report=$3 \
    -r $1

exit 0
