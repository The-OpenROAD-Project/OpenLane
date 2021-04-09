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
if [[ "$GITHUB_EVENT_NAME" == "schedule" ]]; then
  exit_on_no_update=1
fi

echo "Checking the PDK version against latest pdk..."
echo "RUN ROOT: $GITHUB_WORKSPACE"
makefile=$GITHUB_WORKSPACE/Makefile
doc_source=$GITHUB_WORKSPACE/docs/source/Manual_PDK_installation.md
skywater_commit=$(grep "SKYWATER_COMMIT ?= " $makefile | sed 's/SKYWATER_COMMIT ?= //g')
open_pdks_commit=$(grep "OPEN_PDKS_COMMIT ?= " $makefile | sed 's/OPEN_PDKS_COMMIT ?= //g')
skywater_repo="https://github.com/google/skywater-pdk.git"
open_pdks_repo="git://opencircuitdesign.com/open_pdks"
latest_skywater_commit=$(bash $GITHUB_WORKSPACE/.github/scripts/utils/get_commit.sh $skywater_repo)
latest_open_pdks_commit=$(bash $GITHUB_WORKSPACE/.github/scripts/utils/get_commit.sh $open_pdks_repo)
cd $GITHUB_WORKSPACE
status=0
echo "SKYWATER_COMMIT_HASH=$latest_skywater_commit" >> $GITHUB_ENV
echo "OPEN_PDKS_COMMIT_HASH=$latest_open_pdks_commit" >> $GITHUB_ENV

if [[ $latest_open_pdks_commit != $open_pdks_commit ]]; then
  latest_cid_open_pdks_branch_commit=$(git ls-remote --heads $REPO_URL | grep "refs/heads/CID-latest-pdk-" | tail -n1 | awk '{ print $NF }' | cut -d"/" -f3 | cut -d"-" -f5 )
  if [[ $latest_cid_open_pdks_branch_commit ]]; then
    if [[ $latest_open_pdks_commit != $latest_cid_open_pdks_branch_commit ]]; then
      sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $makefile;
      sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $doc_source;
      status=1;
    else
      echo "latest open_pdks commit identical to current CID-latest-pdk commit";
    fi
  else
    sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $makefile;
    sed -i "s/$open_pdks_commit/$latest_open_pdks_commit/" $doc_source;
    status=1;
  fi
else
  echo "latest open_pdks commit identical to current commit";
fi

if [[ $latest_skywater_commit != $skywater_commit ]]; then
  latest_cid_skywater_branch_commit=$(git ls-remote --heads $REPO_URL | grep "refs/heads/CID-latest-pdk-" | tail -n1 | awk '{ print $NF }' | cut -d"/" -f3 | cut -d"-" -f4 )
  if [[ $latest_cid_skywater_branch_commit ]]; then
    if [[ $latest_skywater_commit != $latest_cid_skywater_branch_commit ]]; then
      sed -i "s/$skywater_commit/$latest_skywater_commit/" $makefile;
      sed -i "s/$skywater_commit/$latest_skywater_commit/" $doc_source;
      status=1;
    else
      echo "latest skywater-pdk commit identical to current CID-latest-pdk commit";
    fi
  else
    sed -i "s/$skywater_commit/$latest_skywater_commit/" $makefile;
    sed -i "s/$skywater_commit/$latest_skywater_commit/" $doc_source;
    status=1;
  fi
else
  echo "latest skywater-pdk commit identical to current commit";
fi

if [[ $exit_on_no_update -eq 1 ]]; then
  if [[ $status -eq 0 ]]; then exit 2; fi
fi

if [[ $status -eq 0 ]]; then
  echo "NO_UPDATE=true" >> $GITHUB_ENV
else
  echo "NO_UPDATE=false" >> $GITHUB_ENV
fi

exit 0
