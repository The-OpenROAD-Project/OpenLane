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

cp $1 ${1}_old
sed -i -e "s/LI1/li1/g" -e "s/MET1/met1/g" -e "s/MET2/met2/g" -e "s/MET3/met3/g" -e "s/MET4/met4/g" -e "s/MET5/met5/g" $1
