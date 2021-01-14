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

: ${1?"Usage: $0 tech_file input.gds"}
: ${2?"Usage: $0 tech_file input.gds"}

echo "Using Techfile: $1"
echo "Using GDS file: $2"


xvfb-run klayout -z \
    -rd input_layout=$2 \
    -rd tech_file=$1 \
    -rm $(dirname $0)/scrotLayout.py
