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
set ::env(QUIT_ON_ASSIGN_STATEMENTS) 0
set ::env(QUIT_ON_UNMAPPED_CELLS) 1
set ::env(QUIT_ON_SYNTH_CHECKS) 1
set ::env(SYNTH_CHECKS_ALLOW_TRISTATE) 1
set ::env(LINTER_RELATIVE_INCLUDES) 1
set ::env(LINTER_INCLUDE_PDK_MODELS) 0
set ::env(QUIT_ON_LINTER_WARNINGS) 0
set ::env(QUIT_ON_LINTER_ERRORS) 1

# STA
set ::env(QUIT_ON_TIMING_VIOLATIONS) 1
set ::env(QUIT_ON_HOLD_VIOLATIONS) 1
set ::env(QUIT_ON_SETUP_VIOLATIONS) 1


# Routing
set ::env(QUIT_ON_TR_DRC) 1
set ::env(QUIT_ON_LONG_WIRE) 0

# Magic
set ::env(QUIT_ON_MAGIC_DRC) 1
set ::env(QUIT_ON_ILLEGAL_OVERLAPS) 1

# Netgen
set ::env(QUIT_ON_LVS_ERROR) 1

# Klayout
set ::env(QUIT_ON_XOR_ERROR) 1
