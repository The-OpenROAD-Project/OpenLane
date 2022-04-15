#!/bin/sh
# Copyright 2022 Efabless Corporation
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
<<DOC
# What is this?
A script to manually update the includedyaml file from pyyaml upstream.

# Why?
These scripts are used in an environment where PIP may not be available,
and obligatory submodules are a layer of complexity we could really do without.

---

Requires curl, GNU Tar and black.
DOC

GTAR_BIN=gtar
if ! [ -x "$(command -v $GTAR_BIN)" ]; then
  GTAR_BIN=tar
fi

rm -rf ./includedyaml
mkdir -p ./includedyaml
curl -L https://github.com/yaml/pyyaml/tarball/master | $GTAR_BIN --wildcards --strip-components=3 -xvz -C ./includedyaml '*/lib/yaml'
curl -L https://raw.githubusercontent.com/yaml/pyyaml/master/LICENSE > ./includedyaml/LICENSE
black ./includedyaml