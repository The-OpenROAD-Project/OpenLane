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

# Synthesis
set ::env(CHECK_ASSIGN_STATEMENTS) 0
set ::env(CHECK_UNMAPPED_CELLS) 1

# Floor Planning


# Placement


# Routing
set ::env(QUIT_ON_TR_DRC) 1

# Magic
# This is disabled by default for now until we are 100% sure we want to make this
# shift in flow dynamics, as it will affect the current benchmarks.
set ::env(QUIT_ON_MAGIC_DRC) 1
set ::env(QUIT_ON_ILLEGAL_OVERLAPS) 1

# NetGen
# This is disabled by default as it's the stage before the last, so why not do the last stage anyways.
set ::env(QUIT_ON_LVS_ERROR) 1
