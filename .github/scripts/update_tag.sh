
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

old_predicted_tag=$(grep 'IMAGE_NAME ?= efabless/openlane:' Makefile | sed 's/IMAGE_NAME ?= efabless\/openlane://g')
old_tag=$(grep 'git clone https://github.com/efabless/openlane.git --branch' README.md | head -1 | sed 's/.*--branch //g')
git fetch --prune --unshallow
new_tag=$(git tag --list 'v*.*' | tail -1)

if [[ $new_tag ]]; then
    prefix=$(echo "$new_tag" | cut -d"." -f1 )
    cur_idx=$(echo "$new_tag" | cut -d"." -f2 )
    new_idx=$((${cur_idx} + 1))
    predicted_new_tag="$prefix.$new_idx"
    echo "Old Tag $old_tag"
    echo "New Tag $new_tag"
    echo "Old predicted tag $old_predicted_tag"
    echo "Predicted next tag $predicted_new_tag"
    echo "Updating documentation referenced tag"
    sed -i "s/${old_tag}/${new_tag}/" README.md;
    echo "Updating Makefiles"
    for f in Makefile docker_build/Makefile
    do
        sed -i "s/${old_predicted_tag}/${predicted_new_tag}/" $f;
    done
fi
