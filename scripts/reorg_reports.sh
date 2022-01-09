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


# Handle generated timing reports
mkdir -p  $RUN_DIR/reports/routing/eco_$ECO_ITER
rsync -vt $RUN_DIR/reports/routing/* \
          $RUN_DIR/reports/routing/eco_$ECO_ITER
find $RUN_DIR/reports/routing -maxdepth 1 -type f -delete

# if [ $ECO_ITER -ne 0 ]; then
#    mv $RUN_DIR/results/routing/*.def 
# fi
