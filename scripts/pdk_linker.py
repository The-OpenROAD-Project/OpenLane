#!/usr/bin/env python3

###############################################################################
## BSD 3-Clause License
##
## Copyright (c) 2022, The Regents of the University of California
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
## * Redistributions of source code must retain the above copyright notice, this
##   list of conditions and the following disclaimer.
##
## * Redistributions in binary form must reproduce the above copyright notice,
##   this list of conditions and the following disclaimer in the documentation
##   and/or other materials provided with the distribution.
##
## * Neither the name of the copyright holder nor the names of its
##   contributors may be used to endorse or promote products derived from
##   this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

# The purpose of this script is to build a symbolic link farm from a
# source PDK according to a JSON mapping file.  This is to adapt a PDK
# from a vendor into the form expected by OpenLane without actually
# modifying the source PDK.  This is in opposition to the open_pdks
# approach which modifies the vendor PDK to fit.

import argparse
import glob
import json
import os

parser = argparse.ArgumentParser(
    description="""Builds a link farm from <source> in <dest> according to <mappings>"""
)
parser.add_argument("-s", "--source", required=True)
parser.add_argument("-d", "--destination", required=True)
parser.add_argument("-m", "--mappings", required=True)
parser.add_argument("-v", "--verbose", action="store_true")

args = parser.parse_args()


def link_files(source_path, destination_path):
    """Create a link from source_path to destination path unless
    one already exists.  If it exists but is different then the
    arguments imply an exception is raised."""

    destination_dir = os.path.dirname(destination_path)
    if not os.path.isdir(destination_dir):
        os.makedirs(destination_dir)
    if os.path.exists(destination_path):
        if (
            os.path.islink(destination_path)
            and os.path.realpath(destination_path) == source_path
        ):
            if args.verbose:
                print(f"  Skip {source_path} -> {destination_path}")
            return
        else:
            raise Exception(f"File {destination_path} already exists")
    os.symlink(source_path, destination_path)
    if args.verbose:
        print(f"  Link {source_path} -> {destination_path}")


with open(args.mappings) as f:
    mappings = json.load(f)

if not os.path.isdir(args.source):
    raise Exception(f"{args.source} is not a directory")

source = os.path.abspath(f"{args.source}")
destination = os.path.abspath(f"{args.destination}")

for category, mapping in mappings.items():
    print(f"Linking {category}")
    pdk = mapping["pdk"]
    openlane = mapping["openlane"]
    for pattern in mapping["files"]:
        pattern = f"{source}/{pdk}/{pattern}"
        paths = glob.glob(pattern)
        if len(paths) == 0:
            raise Exception(f"No matches for {pattern}")
        for source_path in paths:
            file_name = os.path.basename(source_path)
            destination_path = f"{destination}/{openlane}/{file_name}"
            link_files(source_path, destination_path)
