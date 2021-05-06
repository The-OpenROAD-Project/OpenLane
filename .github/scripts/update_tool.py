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
import os
import subprocess
from gh import gh
from update_common import process_update_on_repos

dockerfile = os.path.join(gh.root, "docker_build", "docker", gh.tool, "Dockerfile")
print("Reading Dockerfile %s…" % dockerfile)
repo = None
commit = None
repo_rx = r"ARG\s+(?:\w+?)_REPO\s*=\s*([^\s]+)"
commit_rx = r"ARG\s+(?:\w+?)_COMMIT\s*=\s*([^\s]+)"
with open(dockerfile) as f:
    for line in f:
        repo_match = re.match(repo_rx, line)
        if repo_match is not None:
            repo = repo_match[1]
        commit_match = re.match(commit_rx, line)
        if commit_match is not None:
            commit = commit_match[1]
            
tool = gh.Repo(
    gh.tool, repo, r"refs/heads/CID\-latest\-tools\-%s(?:\-(\w+))?" % gh.tool
)
tool.commit = commit

print("Found %s@%s (latest: %s)." % (tool.url, tool.commit, tool.latest_commit))

changed = process_update_on_repos([tool], [dockerfile])
gh.export_env("TOOL_COMMIT_HASH", tool.latest_commit)
gh.export_env("NO_UPDATE", "false" if changed else "true")
