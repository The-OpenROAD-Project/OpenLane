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
echo "Getting Latest Release Index..."
latest_release_idx=$(git ls-remote --tags --sort="v:refname" git://github.com/efabless/openlane.git | grep "refs/tags/release-" | tail -n1 | awk '{ print $NF }' | cut -d"/" -f3 | cut -d"-" -f2 | cut -d"." -f1)

if [[ $latest_release_idx ]]; then
    prefix="v$latest_release_idx";
else
    prefix="v0";
fi
echo "Tag prefix is $prefix"
echo "Getting latest tag with the same prefix..."
latest_tag_line=$(git ls-remote --tags --sort="v:refname" git://github.com/efabless/openlane.git | grep "refs/tags/$prefix" | tail -n1)
latest_tag=$(echo "$latest_tag_line" | awk '{ print $NF }' | cut -d"/" -f3)
latest_tag_commit=$(echo "$latest_tag_line" | awk '{print $1;}')
current_commit=$(git rev-parse HEAD)
if [[ $latest_tag_commit ]]; then
    if [[ $current_commit == $latest_tag_commit ]]; then
        echo "The current commit is already tagged. We won't tag it again."
        exit 0
    else
        commit_cnt=$(git rev-list --count $latest_tag_commit..$current_commit)
        if [[ $commit_cnt ]]; then
            if [[ $commit_cnt -eq 1 ]]; then
                echo "The difference between this tag and the previous one is only 1. We won't create a tag for a single commit."
                exit 0
            fi
        fi
    fi
fi

if ! [[ $latest_tag ]]; then
    echo "No tag with prefix $prefix found. Resetting the tag IDs to 1."
    new_tag="$prefix.1";
else
    if [[ $latest_tag != v* ]]; then
        echo "last tag: $latest_tag"
        new_tag="$prefix.1";
    else
        cur_idx=$(echo "$latest_tag" | cut -d"." -f2 )
        new_idx=$((${cur_idx} + 1))
        new_tag="$prefix.$new_idx"
    fi
fi
if ! [[ $new_tag ]]; then
    echo "No new tag to push!";
    exit 2;
fi
echo "Commiting new tag $new_tag"
git tag $new_tag
echo "Pushing to Github..."
git push --set-upstream origin-ci --tags > /dev/null 2>&1

echo "Push successful"
exit 0