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

# cts defaults
set ::env(RUN_CTS) 1
set ::env(CTS_MULTICORNER_LIB) 1
set ::env(CTS_TOLERANCE) 100
set ::env(CTS_SINK_CLUSTERING_SIZE) 25
set ::env(CTS_SINK_CLUSTERING_MAX_DIAMETER) 50
set ::env(CTS_REPORT_TIMING) 1
set ::env(CTS_CLK_MAX_WIRE_LENGTH) 0
set ::env(CTS_DISABLE_POST_PROCESSING) 0
set ::env(CTS_DISTANCE_BETWEEN_BUFFERS) 0
