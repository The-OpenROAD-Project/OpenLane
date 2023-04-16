#!/usr/bin/env python3
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
import os
import subprocess
from types import SimpleNamespace


def export_env_default(key, value):
    with open(os.getenv("GITHUB_ENV"), "a") as f:
        f.write("%s=%s\n" % (key, value))


export_env = export_env_default


class Repo(object):
    def __init__(self, name, url, branch_rx=None, extraction_rx=None):
        print("[Repo Object] Initializing repo %s with URL %s…" % (name, url))
        self.name = name
        self.url = url
        self.commit = None
        self.branch_rx = branch_rx
        self.extraction_rx = extraction_rx

        self._latest_commit = None
        self._branches = None
        self._tags = None

    @property
    def latest_commit(self):
        if self._latest_commit is None:
            print("[Repo Object] Fetching latest commit for %s…" % self.name)
            p = subprocess.check_output(["git", "ls-remote", self.url]).decode("utf8")
            for line in p.split("\n"):
                if "HEAD" in line:
                    self._latest_commit = line[:40]
        return self._latest_commit

    @property
    def branches(self):
        if self._branches is None:
            print("[Repo Object] Fetching branches for %s…" % self.name)
            p = subprocess.check_output(
                ["git", "ls-remote", "--heads", self.url]
            ).decode("utf8")
            branches = []
            for line in p.split("\n"):
                if line.strip() == "":
                    continue

                match = line.split()

                hash = match[0]
                name = match[1]

                branches.append((hash, name))
            self._branches = branches
        return self._branches

    @property
    def tags(self):
        if self._tags is None:
            print("[Repo Object] Fetching tags for %s…" % self.name)
            p = subprocess.check_output(
                ["git", "ls-remote", "--tags", "--sort=creatordate", self.url]
            ).decode("utf8")

            tags = []
            for line in p.split("\n"):
                if line.strip() == "":
                    continue

                match = line.split()

                hash = match[0]
                name = match[1].split("/")[2]

                tags.append((hash, name))
            self._tags = tags
        return self._tags

    def out_of_date(self):
        return self.commit != self.latest_commit


if os.getenv("GITHUB_ACTIONS") != "true":
    dn = os.path.dirname
    git_directory = dn(dn(dn(os.path.realpath(__file__))))

    def git_command(*args):
        return subprocess.check_output(["git"] + list(args), cwd=git_directory).decode(
            "utf-8"
        )[:-1]

    repo_url = git_command("remote", "get-url", "origin")
    branch = git_command("rev-parse", "--abbrev-ref", "HEAD")

    os.environ["REPO_URL"] = repo_url
    os.environ["BRANCH_NAME"] = branch
    os.environ["GITHUB_WORKSPACE"] = git_directory
    os.environ["GITHUB_EVENT_NAME"] = "workspace_dispatch"
    os.environ["GITHUB_RUN_ID"] = "mock_gha_run"

    def export_env_alt(key, value):
        os.environ[key] = value
        print("Setting ENV[%s] to %s..." % (key, value))

    export_env = export_env_alt

    if os.getenv("PDK_ROOT") is None:
        print('Environment variables required: "PDK_ROOT"')
        exit(os.EX_CONFIG)

    if os.getenv("OPENLANE_IMAGE_NAME") is None:
        print('Environment variables required: "OPENLANE_IMAGE_NAME"')
        exit(os.EX_CONFIG)

origin = os.getenv("REPO_URL")
repo = Repo("Openlane", origin)

# public
gh = SimpleNamespace(
    **{
        "run_id": os.getenv("GITHUB_RUN_ID"),
        "origin": origin,
        "branch": os.getenv("BRANCH_NAME"),
        "image": os.getenv("OPENLANE_IMAGE_NAME"),
        "root": os.getenv("GITHUB_WORKSPACE"),
        "pdk_root": os.getenv("PDK_ROOT"),
        "pdk": os.getenv("PDK"),
        "scl": os.getenv("STD_CELL_LIBRARY"),
        "tool": os.getenv("TOOL"),
        "event": SimpleNamespace(**{"name": os.getenv("GITHUB_EVENT_NAME")}),
        "export_env": export_env,
        "Repo": Repo,
        "openlane": repo,
    }
)
