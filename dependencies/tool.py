# Copyright 2021 Efabless Corporation
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

import yaml
from typing import Dict, List

class Tool(object):
    def __init__(self, name, repo=None, commit=None, build_script="make && make install", clone_depth=None):
        self.name = name
        self.repo = repo
        self.commit = commit
        self.build_script = build_script
        self.clone_depth = str(clone_depth) if clone_depth is not None else None

    @property
    def repo_pretty(self):
        gh_prefix = "https://github.com/"
        repo = self.repo
        if repo is not None and repo.startswith(gh_prefix):
            return repo[len(gh_prefix):]
        return repo

    @property
    def version_string(self) -> str:
        return f"{self.repo or 'None'}:{self.commit or 'None'}"

    def __repr__(self) -> str:
        return f"<Tool {self.name} (using {self.repo_pretty or 'None'}@{self.commit or 'None'})>"

    @staticmethod
    def from_metadata_yaml(metadata_yaml: str) -> Dict[str, 'Tool']:
        final_dict = {}
        tool_list = yaml.load(metadata_yaml, Loader=yaml.SafeLoader)
        for tool in tool_list:
            final_dict[tool['name']] = Tool(
                name=tool['name'],
                repo=tool['repo'],
                commit=tool['commit'],
                build_script=tool['build'],
                clone_depth=tool.get('clone_depth')
            )
        return final_dict

