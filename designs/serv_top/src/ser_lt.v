`default_nettype none
module ser_lt
  (
   input wire  i_clk,
   input wire  i_a,
   input wire  i_b,
   input wire  i_clr,
   input wire  i_sign,
   output wire o_q);

   reg        lt_r;

   wire       lt = (i_sign ? (i_a & ~i_b) : (~i_a & i_b)) | ((i_a == i_b) & lt_r);
   assign o_q = lt;

   always @(posedge i_clk) begin
      lt_r <= lt & ~i_clr;
   end

endmodule
