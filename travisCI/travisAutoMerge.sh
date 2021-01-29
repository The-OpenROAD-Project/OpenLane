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
echo "Merging Branches"
echo "Current branch is $TRAVIS_BRANCH"
MERGE_BRANCH=develop-restructure
echo "Merge branch is $MERGE_BRANCH"
git remote set-branches --add origin $MERGE_BRANCH
git fetch
echo "Current branch is $TRAVIS_BRANCH"
git merge origin/$MERGE_BRANCH --no-commit
