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

#This script removes all occurencies of assignments of a specific environment variable from all default config.tcl of all designs in a directory 
#use: sh removeEnvVar.sh DESIGNS_PATH ENVIRONMENT_VARIABLE_NAME

path=$1
envVar=$2
find ${path}/*/*_config.tcl | xargs grep "${envVar}" | cut -d ':' -f 1 | xargs sed -i -E "s/^.*${envVar}.*$//g"
