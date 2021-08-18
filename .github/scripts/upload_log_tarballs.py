#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 🚧

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
import os
import glob
from gh import gh
from google.cloud import storage

gcs_client = storage.Client()
tarball_glob = os.path.join(gh.root, "designs", "*", "runs", "*.tar.gz")
for tarball in glob.glob(tarball_glob):
    tarball_basename = os.path.basename(tarball)
    final_key = os.path.join(gh.run_id, tarball_basename)
    
    print(final_key)

#for report in glob.glob(os.path.join(results_folder, "%s*.rpt" % test_name)):
