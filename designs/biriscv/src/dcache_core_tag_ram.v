//-----------------------------------------------------------------
//                         biRISC-V CPU
//                            V0.6.0
//                     Ultra-Embedded.com
//                     Copyright 2019-2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

module dcache_core_tag_ram
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [  7:0]  addr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [  7:0]  addr1_i
    ,input  [ 20:0]  data1_i
    ,input           wr1_i

    // Outputs
    ,output [ 20:0]  data0_o
);



//-----------------------------------------------------------------
// Tag RAM 0KB (256 x 21)
// Mode: Write First
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [20:0]   ram [255:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [20:0] ram_read0_q;

always @ (posedge clk1_i)
begin
    if (wr1_i)
        ram[addr1_i] = data1_i;

    ram_read0_q = ram[addr0_i];
end

assign data0_o = ram_read0_q;


endmodule
