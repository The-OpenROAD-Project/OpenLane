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
import sys
import glob
import base64
import traceback
from typing import Callable
from gh import gh

def upload_log_tarballs():
    log_upload_info = os.getenv("LOG_UPLOAD_INFO")
    if log_upload_info is None or log_upload_info.strip() == "":
        print("No upload key was provided. Log tarballs will not be uploaded.", file=sys.stderr)
        exit(0)

    platform, bucket_name, encoded_data = log_upload_info.split(":")

    upload: Callable[[str, str], None] = None
    cleanup = lambda x: None

    if platform == "gcp":
        from google.cloud import storage
        
        json = base64.b64decode(encoded_data).decode("utf8")
        with open("/tmp/gcp_credentials.json", "w") as f:
            f.write(json)

        gcs_client = storage.Client.from_service_account_json(
            "/tmp/gcp_credentials.json"
        )
        bucket = gcs_client.get_bucket(bucket_name)


        def gcp_upload(key, file):
            blob = bucket.blob(key)
            blob.upload_from_filename(file)

        def gcp_cleanup():
            os.remove("/tmp/gcp_credentials.json")

        upload = gcp_upload
        cleanup = gcp_cleanup
    else:
        print("Platform not supported. Ensure your key is formatted correctly as {platform}:{bucket_name}:{encoded_data}.", file=sys.stderr)
        exit(os.EX_CONFIG)

    tarball_glob = os.path.join(gh.root, "designs", "*", "runs", "*.tar.gz")
    for tarball in glob.glob(tarball_glob):
        design_name = os.path.basename(os.path.dirname(os.path.dirname(tarball)))
        tarball_name = f"{design_name}.tar.gz"
        final_key = os.path.join(gh.run_id, tarball_name)
        
        try:
            upload(final_key, tarball)
            print(f"Uploaded {design_name}'s tarball to {final_key}.")
        except Exception as e:
            print(e, file=sys.stderr)
            print(traceback.format_exc(), file=sys.stderr)
            print(f"Failed to upload tarball for {design_name}, skipping…", file=sys.stderr)

    cleanup()
    print("Done.")

if __name__ == "__main__":
    try:
        upload_log_tarballs()
    except:
        print("An unhandled exception has occurred while uploading log tarballs.", file=sys.stderr)
        exit(os.EX_UNAVAILABLE)