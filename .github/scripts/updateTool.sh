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

echo "Checking the tool version against latest tool..."
echo "RUN ROOT: $GITHUB_WORKSPACE"
echo "TOOL: $TOOL"
docker_file=$GITHUB_WORKSPACE/docker_build/docker/$TOOL/Dockerfile
echo "Dockerfile: $docker_file"
tool_repo=$(grep "ARG ${TOOL^^}_REPO=" $docker_file | sed "s/ARG ${TOOL^^}_REPO=//g")
tool_commit=$(grep "ARG ${TOOL^^}_COMMIT=" $docker_file | sed "s/ARG ${TOOL^^}_COMMIT=//g")
echo "$tool_repo"
echo "$tool_commit"
latest_commit=$(bash $GITHUB_WORKSPACE/.travisCI/utils/get_commit.sh $tool_repo)
echo "TOOL_COMMIT_HASH=$latest_commit" >> $GITHUB_ENV

if [[ $latest_commit != $tool_commit ]]; then
  latest_cid_branch_commit=$(git ls-remote --heads git://github.com/agorararmard/openlane.git | grep "refs/heads/CID-latest-tools-$TOOL-" | tail -n1 | awk '{ print $NF }' | cut -d"/" -f3 | cut -d"-" -f5 )
  if [[ $latest_cid_branch_commit ]]; then
    if [[ $latest_commit != $latest_cid_branch_commit ]]; then
      sed -i "s/$tool_commit/$latest_commit/" $docker_file;
      echo "NO_UPDATE='false'" >> $GITHUB_ENV
      exit 0
    else
      echo "latest $TOOL commit is identical to the current CID-latest-tools-$TOOL- commit";
      if [[ $exit_on_no_update -eq 1 ]]; then
        echo "NO_UPDATE='true'" >> $GITHUB_ENV
        exit 0;
      fi
    fi
  fi
  sed -i "s/$tool_commit/$latest_commit/" $docker_file;
  echo "NO_UPDATE='false'" >> $GITHUB_ENV
  exit 0
else
  echo "latest $TOOL commit is identical to the current commit";
  if [[ $exit_on_no_update -eq 1 ]]; then
    echo "NO_UPDATE='true'" >> $GITHUB_ENV
    exit 0;
  fi
fi


echo "NO_UPDATE='true'" >> $GITHUB_ENV
