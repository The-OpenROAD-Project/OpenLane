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
echo "Pushing The Docker Image..."
echo "TRAVIS BRANCH: $TRAVIS_BRANCH"
echo "TRAVIS PULL REQUEST: $TRAVIS_PULL_REQUEST"
export PDK_ROOT=$(pwd)/pdks
export RUN_ROOT=$(pwd)
echo "IMAGE NAME: $IMAGE_NAME"
echo $PDK_ROOT
echo $RUN_ROOT
if [[ -z "$TRAVIS_TEST_RESULT" ]]; then
    echo "Script Status $TRAVIS_TEST_RESULT"
    if [[ $TRAVIS_TEST_RESULT -eq 0 ]]; then
        docker push $IMAGE_NAME
    else
        echo "TRAVIS_TEST_RESULT indicates test failure. The Image won't be pushed."
        exit 2
    fi
else
    echo "TRAVIS_TEST_RESULT isn't defined. The Image won't be pushed."
    exit 2
fi


exit 0