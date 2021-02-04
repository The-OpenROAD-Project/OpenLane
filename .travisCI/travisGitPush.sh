#!/bin/sh
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
echo "RUN ROOT: $RUN_ROOT"
cd $RUN_ROOT
echo "Configureing git info..."
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

echo "Adding remote tracker..."
git remote add origin-ci https://${MY_GITHUB_TOKEN}@github.com/efabless/openlane.git > /dev/null 2>&1
echo "Pushing to Github..."
git push --force --set-upstream origin-ci HEAD:${TRAVIS_BRANCH} > /dev/null 2>&1

echo "Push successful"
exit 0