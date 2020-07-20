module serv_bufreg
  (
   input wire 	      i_clk,
   input wire 	      i_rst,
   input wire [4:2]   i_cnt,
   input wire [1:0]   i_cnt_r,
   input wire 	      i_en,
   input wire 	      i_init,
   input wire 	      i_loop,
   input wire 	      i_rs1,
   input wire 	      i_rs1_en,
   input wire 	      i_imm,
   input wire 	      i_imm_en,
   input wire 	      i_clr_lsb,
   output reg [1:0]   o_lsb,
   output wire [31:0] o_reg,
   output wire 	      o_q);

   wire 	      c, q;
   reg 		      c_r;
   reg [31:0] 	      data;

   wire 	      clr_lsb = (i_cnt[4:2] == 3'd0) & i_cnt_r[0] & i_clr_lsb;

   assign {c,q} = {1'b0,(i_rs1 & i_rs1_en)} + {1'b0,(i_imm & i_imm_en & !clr_lsb)} + c_r;

   always @(posedge i_clk) begin
      //Clear carry when not in INIT state
      c_r <= c & i_init;

      if (i_rst)
	data <= 32'd0;
      else if (i_en)
	data <= {(i_loop & !i_init) ? o_q : q, data[31:1]};

      if ((i_cnt[4:2] == 3'd0) & i_cnt_r[0] & i_init)
	o_lsb[0] <= q;
      if ((i_cnt[4:2] == 3'd0) & i_cnt_r[1] & i_init)
	o_lsb[1] <= q;
   end

   assign o_q = data[0];
   assign o_reg = data;

endmodule
