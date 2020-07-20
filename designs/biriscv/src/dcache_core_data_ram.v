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

module dcache_core_data_ram
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [ 10:0]  addr0_i
    ,input  [ 31:0]  data0_i
    ,input  [  3:0]  wr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [ 10:0]  addr1_i
    ,input  [ 31:0]  data1_i
    ,input  [  3:0]  wr1_i

    // Outputs
    ,output [ 31:0]  data0_o
    ,output [ 31:0]  data1_o
);



//-----------------------------------------------------------------
// Dual Port RAM 8KB
// Mode: Read First
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [31:0]   ram [2047:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [31:0] ram_read0_q;
reg [31:0] ram_read1_q;


// Synchronous write
always @ (posedge clk0_i)
begin
    if (wr0_i[0])
        ram[addr0_i][7:0] <= data0_i[7:0];
    if (wr0_i[1])
        ram[addr0_i][15:8] <= data0_i[15:8];
    if (wr0_i[2])
        ram[addr0_i][23:16] <= data0_i[23:16];
    if (wr0_i[3])
        ram[addr0_i][31:24] <= data0_i[31:24];

    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    if (wr1_i[0])
        ram[addr1_i][7:0] <= data1_i[7:0];
    if (wr1_i[1])
        ram[addr1_i][15:8] <= data1_i[15:8];
    if (wr1_i[2])
        ram[addr1_i][23:16] <= data1_i[23:16];
    if (wr1_i[3])
        ram[addr1_i][31:24] <= data1_i[31:24];

    ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;



endmodule
