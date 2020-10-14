// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "const.vh"

module TagSRAMs #(
  parameter CACHE_SET_BITS = 2,
  parameter CACHE_TAG_BITS = 24
)( 
  input                       clk,
  input                       we,

  input [CACHE_SET_BITS-1:0]  addr,

  input [CACHE_TAG_BITS-1:0]   data_in,
  output [CACHE_TAG_BITS-1:0]  data_out
);

  wire oeb = 1'b0;  // Output enable (bar)
  wire csb = 1'b0;  // Chip select (bar)

  wire [6:0] sram_addr_concat = {{7-CACHE_SET_BITS{1'b0}}, addr};
  wire [5:0] sram_addr = sram_addr_concat[5:0];

  localparam SRAM_WIDTH = 32;
  localparam PAD_BITS = SRAM_WIDTH - CACHE_TAG_BITS;

  wire [SRAM_WIDTH-1:0] din = {{PAD_BITS{1'b0}}, data_in};
  wire [SRAM_WIDTH-1:0] dout;
  assign data_out = dout[CACHE_TAG_BITS-1:0];

  SRAM1RW64x32 tn0(.A(sram_addr),.CE(clk),.WEB(~we),.OEB(oeb),.CSB(csb),.I(din),.O(dout));

endmodule

// This is a fake SRAM1RW64x32 model to enable complete synthesis without the
// Synopsys 32 (educational) PDK's SRAMs.
module SRAM1RW64x32 (
  input [6:0] A,
  input CE,
  input WEB,
  input OEB,
  input CSB,
  input [31:0] I,
  output reg [31:0] O
);

// 64-element array of 128-bit-wide registers.
reg [31:0] ram [63:0];

always @(posedge CE) begin
  if (~CSB) begin
    if (~WEB) begin
      ram[A] <= I;
    end
    if (~OEB) begin
      O <= ram[A];
    end
  end
end

endmodule
