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
echo "Running the standard installation process..."
export PDK_ROOT=$(pwd)/pdks
export RUN_ROOT=$(pwd)
if [ $TRAVIS_BRANCH == "develop-latest_tools_x" ]; then
	export IMAGE_NAME=efabless/openlane:$TRAVIS_BRANCH-$TOOL
else
	export IMAGE_NAME=efabless/openlane:$TRAVIS_BRANCH
fi
echo $PDK_ROOT
echo $RUN_ROOT
if [ -z "$TEST_STATUS" ]; then
    if [ $TEST_STATUS -eq 0]; then
        docker push $IMAGE_NAME
    else
        echo "TEST_STATUS indicates test failure. The Image won't be pushed."
        exit 2
    fi
else
    echo "TEST_STATUS isn't defined. The Image won't be pushed."
    exit 2
fi


exit 0