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

# The only purpose of this file is to create a wrapper around report.py and config.py and make them usable by flow.tcl

import argparse
import os

def get_name(run_path, output_file, include_only=False):
    candidates = [
        filename.split('-', 1) for filename in os.listdir(run_path)
        if os.path.isfile(os.path.join(run_path, filename))
    ]
    candidates = filter(lambda name_pair: len(name_pair) > 1 and str(output_file) in name_pair[1], candidates)
    if not include_only:
        candidates = filter(lambda name_pair: name_pair[1] == output_file, candidates)

    candidates = sorted(candidates, reverse=True, key=lambda name_parts: int(name_parts[0]))
    if len(candidates) > 0:
        neededfile = '-'.join(candidates[0])
    elif os.path.isfile(os.path.join(run_path, output_file)):
        neededfile = output_file
    else:
        raise FileNotFoundError(f"Cannot find any file with name matching '{output_file}'")

    return os.path.join(run_path, neededfile)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Returns the output_file name with the highest index.')

    parser.add_argument('--path', '-p', required=True,
                        help='Path')

    parser.add_argument('--output_file', '-o', required=True,
                        help='File name to search for, i.e. 1.X 2.X 3.X, then the script will return <path>/3.X')

    parser.add_argument('--include_only', '-io',action='store_true', default=False,
                       help="If enabled the matching is done for inclusion, i.e. the passed output_file is a string that is included in the file name to be matched. -o exam will return matches like: exam.txt and example.txl.")

    args = parser.parse_args()
    path=args.path
    output_file = args.output_file
    include_only= args.include_only
    print(get_name(path,output_file,include_only))
