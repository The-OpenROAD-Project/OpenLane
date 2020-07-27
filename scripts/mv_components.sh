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
