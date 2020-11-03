// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "const.vh"

module DataSRAMs #(
  parameter CACHE_SET_BITS = 2,
  parameter CACHE_LINE_BITS = 512
)( 
  input                         clk,
  input                         we,

  input [CACHE_SET_BITS-1:0]    addr,

  input [CACHE_LINE_BITS-1:0]   data_in,
  output [CACHE_LINE_BITS-1:0]  data_out
);

  wire oeb = 1'b0;  // Output enable (bar)
  wire csb = 1'b0;  // Chip select (bar)

  // We have 2-6 bits of address but need to provide 6. To handle
  // having 6 cache set bits, without verilog spewing a warning and munging
  // it, we add one bit here that we then ignore when passing data.
  wire [6:0] sram_addr_concat = {{7-CACHE_SET_BITS{1'b0}}, addr};
  wire [5:0] sram_addr = sram_addr_concat[5:0];

  wire [127:0] din0 = data_in[127:0];
  wire [127:0] din1 = data_in[255:128];
  wire [127:0] din2 = data_in[383:256];
  wire [127:0] din3 = data_in[511:384];

  wire [127:0] dout0, dout1, dout2, dout3;
  assign data_out = {dout3, dout2, dout1, dout0};

  // Data for way 0, sets 0 - 64, should that many every exist.
  SRAM1RW64x128 dn0(.A(sram_addr),.CE(clk),.WEB(~we),.OEB(oeb),.CSB(csb),.I(din0),.O(dout0));
  SRAM1RW64x128 dn1(.A(sram_addr),.CE(clk),.WEB(~we),.OEB(oeb),.CSB(csb),.I(din1),.O(dout1));
  SRAM1RW64x128 dn2(.A(sram_addr),.CE(clk),.WEB(~we),.OEB(oeb),.CSB(csb),.I(din2),.O(dout2));
  SRAM1RW64x128 dn3(.A(sram_addr),.CE(clk),.WEB(~we),.OEB(oeb),.CSB(csb),.I(din3),.O(dout3));

endmodule

// This is a fake SRAM1RW64x128 model to enable complete synthesis without the
// Synopsys 32 (educational) PDK's SRAMs.
module SRAM1RW64x128 (
  input [6:0] A,
  input CE,
  input WEB,
  input OEB,
  input CSB,
  input [127:0] I,
  output reg [127:0] O
);

// 64-element array of 128-bit-wide registers.
reg [127:0] ram [63:0];

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
