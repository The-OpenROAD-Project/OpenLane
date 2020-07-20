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

module icache_data_ram
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [  9:0]  addr_i
    ,input  [ 63:0]  data_i
    ,input           wr_i

    // Outputs
    ,output [ 63:0]  data_o
);




//-----------------------------------------------------------------
// Single Port RAM 8KB
// Mode: Read First
//-----------------------------------------------------------------
reg [63:0]   ram [1023:0] /*verilator public*/;
reg [63:0]   ram_read_q;

// Synchronous write
always @ (posedge clk_i)
begin
    if (wr_i)
        ram[addr_i] <= data_i;
    ram_read_q <= ram[addr_i];
end

assign data_o = ram_read_q;



endmodule
