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
set -e
exit_on_no_update=0
if [[ "$TRAVIS_EVENT_TYPE" == "api" || "$TRAVIS_EVENT_TYPE" == "cron" ]]; then
  exit_on_no_update=1
fi

echo "Checking the PDK version against latest pdk..."
echo "RUN ROOT: $RUN_ROOT"
makefile=$RUN_ROOT/Makefile
doc_source=$RUN_ROOT/docs/source/Manual_PDK_installation.md
skywater_commit=$(grep "SKYWATER_COMMIT ?= " $makefile | sed 's/SKYWATER_COMMIT ?= //g')
open_pdks_commit=$(grep "OPEN_PDKS_COMMIT ?= " $makefile | sed 's/OPEN_PDKS_COMMIT ?= //g')
skywater_repo="https://github.com/google/skywater-pdk.git"
open_pdks_repo="git://opencircuitdesign.com/open_pdks"
latest_skywater_commit=$(bash $RUN_ROOT/.travisCI/utils/get_commit.sh $skywater_repo)
latest_open_pdks_commit=$(bash $RUN_ROOT/.travisCI/utils/get_commit.sh $open_pdks_repo)
cd $RUN_ROOT
status=0

if [[ $latest_open_pdks_commit != $open_pdks_commit ]]; then
  sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $makefile;
  sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $doc_source;
  status=1;
else
  echo "latest open_pdks commit identical to current commit";
fi

if [[ $latest_skywater_commit != $skywater_commit ]]; then
  sed -i "s/$skywater_commit/$latest_skywater_commit/" $makefile;
  sed -i "s/$skywater_commit/$latest_skywater_commit/" $doc_source;
  status=1;
else
  echo "latest skywater-pdk commit identical to current commit";
fi

if [[ $exit_on_no_update -eq 1 ]]; then
  if [[ $status -eq 0 ]]; then exit 2; fi
fi

exit 0
