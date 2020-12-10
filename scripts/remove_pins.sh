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

if [[ $# -lt 1 ]]; then
    echo "usage ./remove_pins.sh file.def"
    exit
fi

file=$1

# remove the PINS section
sed -i "/PINS.*;/,/END PINS/d" $file
# remove ( PIN xxx ) in the nets section
sed -i "s/(\sPIN\s[^[:space:]]*\s)\s//g" $file
# remove empty nets
sed -i "/NETS/,/END NETS/ s/^-\s.[^[:space:]]\+\s\+;$//g" $file

