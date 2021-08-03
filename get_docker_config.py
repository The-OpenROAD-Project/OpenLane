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
import sys
import json
import getpass
import subprocess
from enum import Enum

class Engine(Enum):
    docker = 0b0000

    misc_conmon = 0b1000
    podman = 0b1001

engine = Engine.docker

uid = subprocess.check_output([ "id", "-u", getpass.getuser() ]).decode("utf8").strip()
gid = subprocess.check_output([ "id", "-g", getpass.getuser() ]).decode("utf8").strip()

try:
    info = ""
    try:
        info = subprocess.check_output([ "docker", "info", "--format", "{{json .}}"]).decode("utf8")
    except:
        raise Exception("Could not execute docker info.")

    try:
        info = json.loads(info)
    except:
        raise Exception("Docker info was not valid JSON.")

    if info.get("Name") is not None and "docker" in info["Name"]:
        engine = Engine.docker
        # Maybe TODO: Check for rootless setups?
    elif info.get("host") is not None and info["host"].get("conmon") is not None:
        engine = Engine.misc_conmon
        if info["host"].get("remoteSocket") is not None and "podman" in info["host"]["remoteSocket"]["path"]:
            engine = Engine.podman

    if engine == Engine.docker:
        raise Exception("") # Output UID/GID Info

    # Else, print nothing… Podman (and possibly other conmon-based solutions) do not handle the -u options in a similar manner.
except Exception as e:
    if e.__str__() != "":
        print(f"{e} Assuming a standard Docker installation.", file=sys.stderr)
    print(f"-u {uid}:{gid}", end="")
    exit(0)
