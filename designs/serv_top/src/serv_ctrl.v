`default_nettype none
module serv_ctrl
  (
   input wire 	      clk,
   input wire 	      i_rst,
   //State
   input wire 	      i_pc_en,
   input wire [4:2]   i_cnt,
   input wire [2:1]   i_cnt_r,
   input wire 	      i_cnt_done,
   //Control
   input wire 	      i_jump,
   input wire 	      i_jal_or_jalr,
   input wire 	      i_utype,
   input wire 	      i_pc_rel,
   input wire 	      i_trap,
   //Data
   input wire 	      i_imm,
   input wire 	      i_buf,
   input wire 	      i_csr_pc,
   output wire 	      o_rd,
   output wire 	      o_bad_pc,
   //External
   output wire [31:0] o_ibus_adr,
   output wire 	      o_ibus_cyc,
   input wire 	      i_ibus_ack);

   parameter RESET_PC = 32'd8;

   reg 	      en_pc_r;

   wire       pc_plus_4;
   wire       pc_plus_offset;
   wire       pc_plus_offset_aligned;
   wire       plus_4;

   wire       pc;

   wire       new_pc;

   wire       offset_a;
   wire       offset_b;

   assign plus_4        = i_cnt_r[2] & (i_cnt[4:2] == 3'd0);

   assign o_ibus_adr[0] = pc;
   assign o_bad_pc = pc_plus_offset_aligned;

   ser_add ser_add_pc_plus_4
     (
      .clk (clk),
      .rst (i_rst),
      .a   (pc),
      .b   (plus_4),
      .clr (i_cnt_done),
      .q   (pc_plus_4),
      .o_v ());

   shift_reg
     #(
       .LEN  (32),
       .INIT (RESET_PC))
   pc_reg
     (
      .clk (clk),
      .i_rst (i_rst),
      .i_en (i_pc_en),
      .i_d  (new_pc),
      .o_q  (pc),
      .o_par (o_ibus_adr[31:1])
      );

   assign new_pc = i_trap ? (i_csr_pc & en_pc_r) : i_jump ? pc_plus_offset_aligned : pc_plus_4;
   assign o_rd  = (i_utype & pc_plus_offset_aligned) | (pc_plus_4 & i_jal_or_jalr);

   assign offset_a = i_pc_rel & pc;
   assign offset_b = i_utype ? (i_imm & (i_cnt[4] | (i_cnt[3:2] == 2'b11))): i_buf;

   ser_add ser_add_pc_plus_offset
     (
      .clk (clk),
      .rst (i_rst),
      .a   (offset_a),
      .b   (offset_b),
      .clr (!i_pc_en),
      .q   (pc_plus_offset),
      .o_v ());

   assign pc_plus_offset_aligned = pc_plus_offset & en_pc_r;

   assign o_ibus_cyc = en_pc_r & !i_pc_en;

   always @(posedge clk) begin
      if (i_pc_en)
	en_pc_r <= 1'b1;
      else if (o_ibus_cyc & i_ibus_ack)
        en_pc_r <= 1'b0;

      if (i_rst) begin
	 en_pc_r <= 1'b1;
      end
   end

endmodule
