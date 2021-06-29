#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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
import re
from gh import gh

def process_update_on_repos(repos, files):
    changed = False
    for repo in repos:
        print("Processing %s…" % repo.name)
        if not repo.out_of_date():
            print("%s's commit is already on latest. No action required." % repo.name)
            continue
        
        # print("Checking if branch was already created…")
        # branch_commit = None
        # for branch in gh.openlane.branches:
        #     _, name = branch
        #     branch_commit = repo.match_branch(name) or branch_commit
        
        # if branch_commit is not None and branch_commit == repo.latest_commit:
        #     print("Branch was already created for the latest commit. No update required.")
        #     continue

        # if branch_commit is not None:
        #     print("Branch is out of date. Updating…")
        # else:
        #     print("No matching branch found. Updating…")
        
        changed = True

        for file in files:
            fstr = open(file).read()
            new_fstr = re.sub(repo.commit, repo.latest_commit, fstr)
            with open(file, 'w') as f:
                f.write(new_fstr)
    return changed
