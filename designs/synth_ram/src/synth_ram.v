// Copyright 2020 Efabless Corporation
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

module synth_ram #( parameter integer WORDS = 64) (
  input clk,
  input ena,
  input [3:0] wen,
  input [21:0] addr,
  input [31:0] wdata,
  output[31:0] rdata
);

  reg [31:0] rdata;
  reg [31:0] mem [0:WORDS-1];

  always @(posedge clk) begin
          if (ena == 1'b1) begin
                  rdata <= mem[addr];
                  if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
                  if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
                  if (wen[2]) mem[addr][23:16] <= wdata[23:16];
                  if (wen[3]) mem[addr][31:24] <= wdata[31:24];
          end
  end
        
endmodule
