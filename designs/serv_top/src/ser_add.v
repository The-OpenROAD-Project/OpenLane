`default_nettype none
module ser_add
  (
   input wire  clk,
   input wire  rst,
   input wire  a,
   input wire  b,
   input wire  clr,
   output wire q,
   output wire o_v);

   reg 	       c_r;

   wire axorb = a^b;

   assign o_v = (axorb & c_r) | (a&b);

   assign q   = axorb ^ c_r;
   always @(posedge clk)
     if (rst)
       c_r <= 1'b0;
     else
       c_r <= !clr & o_v;

endmodule
