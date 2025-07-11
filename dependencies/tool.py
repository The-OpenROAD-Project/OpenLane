#!/usr/bin/env python3
# Copyright 2021-2022 Efabless Corporation
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
import os
import sys
from typing import Dict, List, Optional

sys.path.append(os.path.dirname(__file__))
import includedyaml as yaml  # noqa: E402


class Tool(object):
    by_name: Dict[str, "Tool"]

    def __init__(
        self,
        name,
        repo,
        commit,
        build_script="",
        default_branch=None,
        in_install=True,
        in_container=True,
        pdk=False,
    ):
        self.name = name
        self.repo = repo
        self.commit = commit
        self.build_script = build_script
        self.default_branch = default_branch
        self.in_install = in_install
        self.in_container = in_container
        self.pdk = pdk

    def __repr__(self) -> str:
        return f"<Tool {self.name} (using {self.repo_pretty or 'None'}@{self.commit or 'None'})>"

    @property
    def repo_pretty(self):
        gh_prefix = "https://github.com/"
        repo = self.repo
        if repo is not None and repo.startswith(gh_prefix):
            return repo[len(gh_prefix) :]
        return repo

    @property
    def version_string(self) -> str:
        return f"{self.repo or 'None'}:{self.commit or 'None'}"

    def get_docker_tag(self, for_os: str, arch: Optional[str] = None) -> str:
        tag = f"{self.name}-{self.commit}-{for_os}"
        if arch is not None:
            tag += f"-{arch}"
        return tag

    @property
    def docker_args(self) -> List[str]:
        return [
            "--build-arg",
            f"{self.name.upper()}_REPO={self.repo}",
            "--build-arg",
            f"{self.name.upper()}_COMMIT={self.commit}",
        ]

    @staticmethod
    def from_metadata_yaml(metadata_yaml: str) -> Dict[str, "Tool"]:
        final_dict = {}
        tool_list = yaml.load(metadata_yaml, Loader=yaml.SafeLoader)
        for tool in tool_list:
            final_dict[tool["name"]] = Tool(
                name=tool["name"],
                repo=tool["repo"],
                commit=tool["commit"],
                build_script=tool.get("build") or "",
                default_branch=tool.get("default_branch") or None,
                in_container=(
                    tool["in_container"]
                    if tool.get("in_container") is not None
                    else True
                ),
                in_install=(
                    tool["in_install"] if tool.get("in_install") is not None else True
                ),
                pdk=tool.get("pdk") or False,
            )
        return final_dict


Tool.by_name = Tool.from_metadata_yaml(
    open(os.path.join(os.path.dirname(__file__), "tool_metadata.yml")).read()
)


def main():
    import os
    import argparse

    parser = argparse.ArgumentParser(description="Get Tool Info")
    parser.add_argument("--containerized", action="store_true")
    parser.add_argument("--docker-args", action="store_true")
    parser.add_argument("--no-pdks", action="store_true")
    parser.add_argument("--docker-tag-for-os", default=None)
    parser.add_argument("--docker-arch", default=None)
    parser.add_argument("--field", "-f")
    parser.add_argument("tool")
    args = parser.parse_args()

    if args.no_pdks:
        pdk_keys = []
        for key, value in Tool.by_name.items():
            if value.pdk:
                pdk_keys.append(key)

        for key in pdk_keys:
            del Tool.by_name[key]

    if args.containerized:
        for tool in Tool.by_name.values():
            if tool.in_container:
                print(tool.name, end=" ")
        exit(0)

    try:
        tool = Tool.by_name[args.tool]
    except Exception:
        print(f"Unknown tool {args.tool}.", file=sys.stderr)
        exit(os.EX_DATAERR)

    if args.docker_tag_for_os:
        print(tool.get_docker_tag(for_os=args.docker_tag_for_os, arch=args.docker_arch))
    elif args.docker_args:
        arg_list = tool.docker_args
        print(" ".join(arg_list), end="")
    elif args.field:
        field = tool.__dict__[args.field]
        print(field, end="")
    else:
        parser.print_help(file=sys.stderr)
        exit(os.EX_USAGE)


if __name__ == "__main__":
    main()
