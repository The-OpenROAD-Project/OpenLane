#!/bin/bash
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

echo "Running the tool prebuild step installation process..."
echo "RUN ROOT: $RUN_ROOT"
echo "Modifying Docker for $TOOL"
bash $RUN_ROOT/travisCI/utils/remove_line_from_file.sh $RUN_ROOT/docker_build/docker/$TOOL/Dockerfile  "RUN git checkout"
cd $RUN_ROOT/docker_build
echo "Re-building $TOOL"
make build-$TOOL
echo "done pre-build"
cd $RUN_ROOT
exit 0
