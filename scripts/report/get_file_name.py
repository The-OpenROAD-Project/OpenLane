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

import os
import argparse


def get_name(pathname, output_file, partial_match=False):
    pathname = str(pathname)
    output_file = str(output_file)

    try:
        candidates = []
        for file in os.listdir(pathname):
            if not os.path.isfile(os.path.join(pathname, file)):
                continue  # Directory

            file_components = file.split("-", 1)

            if len(file_components) <= 1:
                continue

            step_index, name = file_components
            step_index = int(step_index)

            if partial_match:
                if output_file not in name:
                    continue
            else:
                if output_file != name:
                    continue

            candidates.append((step_index, name))

        candidates.sort(key=lambda x: x[0], reverse=True)

        file = f"{candidates[0][0]}-{candidates[0][1]}"

        return candidates[0][0], os.path.join(pathname, file)
    except Exception:
        return "", os.path.join(pathname, output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Returns the output_file name with the highest index."
    )

    parser.add_argument("--path", "-p", required=True, help="Path")

    parser.add_argument(
        "--output_file",
        "-o",
        required=True,
        help="File name to search for, i.e. 1.X 2.X 3.X, then the script will return <path>/3.X",
    )

    # This whole thing is a contrived way to say "partial match"
    parser.add_argument(
        "--include_only",
        "-I",
        action="store_true",
        default=False,
        help="If enabled the matching is done for inclusion, i.e. the passed output_file is a string that is included in the file name to be matched. -o exam will return matches like: exam.txt and example.txl.",
    )

    args = parser.parse_args()
    path = args.path
    output_file = args.output_file
    include_only = args.include_only
    print(get_name(path, output_file, include_only))
