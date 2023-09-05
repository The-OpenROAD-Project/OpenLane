# Copyright 2020-2023 Efabless Corporation
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
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read

source $::env(SCRIPTS_DIR)/openroad/common/grt.tcl
source $::env(SCRIPTS_DIR)/openroad/common/dpl_cell_pad.tcl ; # just in case
repair_antennas "$::env(DIODE_CELL)" -iterations $::env(GRT_ANT_ITERS) -ratio_margin $::env(GRT_ANT_MARGIN)
source $::env(SCRIPTS_DIR)/openroad/common/dpl.tcl
source $::env(SCRIPTS_DIR)/openroad/common/grt.tcl

write

