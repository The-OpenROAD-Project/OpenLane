// SPDX-FileCopyrightText: 2020 fabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

//`default_nettype none
// OpenRAM SRAM model
// Words: 256
// Word size: 32
// Write size: 8

module sram #(
  parameter NUM_WMASKS = 4,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 5,
  parameter RAM_DEPTH = 1 << ADDR_WIDTH,
  // FIXME: This delay is arbitrary.
  parameter DELAY = 3,
  parameter IZERO   = 0 , // binary / Initial RAM with zeros (has priority over INITFILE)
  parameter IFILE   = "" 
)
(
/*`ifdef USE_POWER_PINS
	vdd,
	gnd,
`endif */
// Port 0: RW
    clk0,csb0,web0,wmask0,addr0,din0,dout0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );


/*`ifdef USE_POWER_PINS
  inout vdd;
  inout gnd;
`endif
  */
  input  clk0; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [NUM_WMASKS-1:0]   wmask0; // write mask
  input [ADDR_WIDTH-1:0]  addr0;
  input [DATA_WIDTH-1:0]  din0;
  output [DATA_WIDTH-1:0] dout0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [ADDR_WIDTH-1:0]  addr1;
  output [DATA_WIDTH-1:0] dout1;

  reg  csb0_reg;
  reg  web0_reg;
  reg [NUM_WMASKS-1:0]   wmask0_reg;
  reg [ADDR_WIDTH-1:0]  addr0_reg;
  reg [DATA_WIDTH-1:0]  din0_reg;
  reg [DATA_WIDTH-1:0]  dout0;

  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    web0_reg = web0;
    wmask0_reg = wmask0;
    addr0_reg = addr0;
    din0_reg = din0;
    //dout0 = 0;
/*`ifdef DBG
    if ( !csb0_reg && web0_reg ) 
      $display($time," Reading %m addr0=%b dout0=%b",addr0_reg,mem[addr0_reg]);
    if ( !csb0_reg && !web0_reg )
      $display($time," Writing %m addr0=%b din0=%b wmask0=%b",addr0_reg,din0_reg,wmask0_reg);
`endif 
*/   end

  reg  csb1_reg;
  reg [ADDR_WIDTH-1:0]  addr1_reg;
  reg [DATA_WIDTH-1:0]  dout1;

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
//`ifdef DBG
//    if (!csb0 && !web0 && !csb1 && (addr0 == addr1))
//         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
//    dout1 = 32'bx;
//    if ( !csb1_reg ) 
//      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
//`endif  
   end
integer i;
reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];
initial
    if (IZERO)
      for (i=0; i<RAM_DEPTH; i=i+1) mem[i] = {DATA_WIDTH{1'b0}};
    else
      if (IFILE != "") $readmemh({IFILE,".hex"}, mem);

  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if ( !csb0_reg && !web0_reg ) begin
        if (wmask0_reg[0])
                mem[addr0_reg][7:0] = din0_reg[7:0];
        if (wmask0_reg[1])
                mem[addr0_reg][15:8] = din0_reg[15:8];
        if (wmask0_reg[2])
                mem[addr0_reg][23:16] = din0_reg[23:16];
        if (wmask0_reg[3])
                mem[addr0_reg][31:24] = din0_reg[31:24];
    end
  end

  // Memory Read Block Port 0
  // Read Operation : When web0 = 1, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_READ0
    if (!csb0_reg && web0_reg)
       dout0 <= #(DELAY) mem[addr0_reg];
  end

  // Memory Read Block Port 1
  // Read Operation : When web1 = 1, csb1 = 0/ 
 always @ (negedge clk1)
  begin : MEM_READ1
   if (!csb1_reg)
       dout1 <= #(DELAY) mem[addr1_reg];
  end

endmodule
//`default_nettype wire

