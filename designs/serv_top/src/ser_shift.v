`default_nettype none
module ser_shift
  (
   input wire 	    i_clk,
   input wire 	    i_load,
   input wire [4:0] i_shamt,
   input wire 	    i_shamt_msb,
   input wire 	    i_signbit,
   input wire 	    i_right,
   output wire 	    o_done,
   input wire 	    i_d,
   output wire 	    o_q);

   reg 		    signbit;
   reg [5:0] 	    cnt;
   reg 		    wrapped;

   always @(posedge i_clk) begin
      cnt <= cnt + 6'd1;
      if (i_load) begin
         cnt <= 6'd0;
	 signbit <= i_signbit & i_right;
      end
      wrapped <= cnt[5] | (i_shamt_msb & !i_right);
   end

   assign o_done = (cnt[4:0] == i_shamt);
   assign o_q = (i_right^wrapped) ? i_d : signbit;

endmodule
