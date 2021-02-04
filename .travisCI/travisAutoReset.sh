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
echo "Resetting Branch"
echo "Current branch is $TRAVIS_BRANCH"
RESET_BRANCH=master
echo "Merge branch is $RESET_BRANCH"
git remote set-branches --add origin $RESET_BRANCH
git fetch
echo "Current branch is $TRAVIS_BRANCH"
echo "Configureing git info..."
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
echo "Reseting branch to $RESET_BRANCH"
git reset --hard origin/$RESET_BRANCH
