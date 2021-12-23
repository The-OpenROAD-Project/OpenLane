#!/bin/bash
# Copyright 2021 The University of Michigan
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

# Handle generated spefs/defs
mkdir -p  $RUN_DIR/results/eco/def
mkdir -p  $RUN_DIR/results/eco/spef
mkdir -p  $RUN_DIR/results/eco/sdf

# Breakpoint to see if dirs are generated
# exit 111
# rsync -av $RUN_DIR/results/routing/*.def  \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/def
# rsync -av $RUN_DIR/results/routing/*.spef \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/spef
# rsync -av $RUN_DIR/results/routing/*.sdf  \
#     $RUN_DIR/results/routing/eco_$ECO_ITER/sdf

