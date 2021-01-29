
#!/bin/bash
# SPDX-FileCopyrightText: 2020 Efabless Corporation
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
# SPDX-License-Identifier: Apache-2.0

# Abort on Error
set -e
repo=$1
run_root=$(pwd)
cd ..
if [[ -d "tmp_compare_commit_dir/" ]]; then
    rm -rf tmp_compare_commit_dir/;
fi
git clone -q $repo tmp_compare_commit_dir --depth=1
cd tmp_compare_commit_dir
new_commit=$(git rev-parse HEAD)
echo "$new_commit";
