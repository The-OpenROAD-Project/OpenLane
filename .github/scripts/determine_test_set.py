#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020-2021 Efabless Corporation
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

from gh import gh
import os
import json

github_event_name = os.environ["EVENT_NAME"]

if github_event_name in ["schedule", "workflow_dispatch"]:
    gh.export_env("USE_ETS", "1")
elif github_event_name == "pull_request":
    gh_event_str = open(os.environ["GITHUB_EVENT_PATH"]).read()
    gh_event = json.loads(gh_event_str)
    pr_body = gh_event["pull_request"]["body"] or ""

    if "[ci ets]" in pr_body:
        gh.export_env("USE_ETS", "1")
    else:
        gh.export_env("USE_ETS", "0")
else:
    gh.export_env("USE_ETS", "0")
