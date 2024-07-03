# Copyright 2024 Efabless Corporation
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
import argparse
import subprocess
import sys
import json
import os


def get_submodule_revs(filter, repository, commit):
    api_result = None
    filter = re.compile(filter)

    try:
        api_result = subprocess.check_output(
            [
                "curl",
                "--fail",
                "-s",
                "-L",
                "-H",
                "Accept: application/vnd.github.v3+json",
                f"https://api.github.com/repos/{repository}/git/trees/{commit}?recursive=True",
            ]
        )
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(os.EX_DATAERR)

    api_result_parsed = json.loads(api_result)
    api_result_tree = api_result_parsed["tree"]
    submodules = [element for element in api_result_tree if element["type"] == "commit"]
    return {
        submodule["path"]: submodule["sha"]
        for submodule in submodules
        if filter.search(submodule["path"])
    }


def override_openroad_versions(commit):
    info = {
        "openroad": {
            "rev": commit,
            "repo": "The-OpenROAD-Project/OpenROAD",
        }
    }
    submodule_revs = get_submodule_revs(r"sta|abc", info["openroad"]["repo"], commit)
    info["opensta"] = {
        "rev": submodule_revs["src/sta"],
        "repo": "The-OpenROAD-Project/OpenSTA",
    }
    info["openroad-abc"] = {
        "rev": submodule_revs["third-party/abc"],
        "repo": "The-OpenROAD-Project/abc",
    }
    for derivation, info in info.items():
        prefetch_info = subprocess.check_output(
            [
                "nix",
                "run",
                "github:seppeljordan/nix-prefetch-github",
                "--",
                "--rev",
                info["rev"],
            ]
            + info["repo"].split("/"),
            encoding="utf8",
        )
        prefetch_info_json = json.loads(prefetch_info)
        hash = prefetch_info_json["hash"]
        subprocess.check_call(
            [
                "sed",
                "-i.bak",
                f"s/# {derivation}-rev-sha/rev = \"{info['rev']}\"; sha256 = \"{hash}\";/",
                "flake.nix",
            ]
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Adds overrides for a given OpenROAD commit hash to flake.nix. Requires Nix with Flakes+Nix-Command enabled as well as curl and GNU sed."
    )
    parser.add_argument("commit", help="commit hash")
    args = parser.parse_args()
    override_openroad_versions(args.commit)
