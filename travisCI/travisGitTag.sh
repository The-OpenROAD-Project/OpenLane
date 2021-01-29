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
echo "Getting Date & Month..."
dateAndMonth=`date "+%b %Y"`
echo "Configureing git info..."
git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

echo "Adding remote tracker..."
git remote add origin-ci https://${MY_GITHUB_TOKEN}@github.com/efabless/openlane.git > /dev/null 2>&1

latest_tag=$(git ls-remote --tags --sort="v:refname" git://github.com/efabless/openlane.git | tail -n1 | awk '{ print $NF }' | cut -d"/" -f3)
if ! [[ $latest_tag ]]; then 
    new_tag="v0.0";
else
    if [[ $latest_tag != v* ]]; then
        echo "last tag: $latest_tag"
        new_tag="v0.0";
    else
        p1=$(echo "$latest_tag" | cut -d"." -f1 )
        p2=$(echo "$latest_tag" | cut -d"." -f2 )
        n_p2=$((${p2} + 1))
        new_tag="$p1.$p_d2"
    fi
fi

if ! [[ $new_tag ]]; then 
    echo "No new tag to push!";
    exit 2;
fi
echo "Commiting new tag $new_tag"
git tag -a $new_tag -m "Travis update: $dateAndMonth (Build $TRAVIS_BUILD_NUMBER) Creating New Soft Tag"
echo "Pushing to Github..."
git push --set-upstream origin-ci --tags

echo "Push successful"
exit 0