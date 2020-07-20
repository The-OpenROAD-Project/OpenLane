`default_nettype none
module serv_mem_if
  (
   input wire 	      i_clk,
   input wire 	      i_rst,
   input wire 	      i_en,
   input wire 	      i_init,
   input wire 	      i_mem_op,
   input wire 	      i_signed,
   input wire 	      i_word,
   input wire 	      i_half,
   input wire [1:0]   i_bytecnt,
   input wire 	      i_rs2,
   output wire 	      o_rd,
   input wire [1:0]   i_lsb,
   output wire 	      o_misalign,
   //External interface
   output wire [31:0] o_wb_dat,
   output wire [3:0]  o_wb_sel,
   input wire [31:0]  i_wb_rdt,
   input wire 	      i_wb_ack);

   reg           signbit;
   reg 		 misalign;

   reg [7:0] 	 dat0;
   reg [7:0] 	 dat1;
   reg [7:0] 	 dat2;
   reg [7:0] 	 dat3;
   wire 	 dat0_en;
   wire 	 dat1_en;
   wire 	 dat2_en;
   wire 	 dat3_en;

   wire [1:0] dat_sel = i_bytecnt[1] ? i_bytecnt : (i_bytecnt | i_lsb);

   wire 	 dat_cur = (dat_sel == 3) ? dat3[0] :
		 (dat_sel == 2) ? dat2[0] :
		 (dat_sel == 1) ? dat1[0] : dat0[0];

   wire dat_valid = i_word | (i_bytecnt == 2'b00) | (i_half & !i_bytecnt[1]);
   assign o_rd = i_mem_op & (dat_valid ? dat_cur : signbit & i_signed);


   wire       upper_half = i_lsb[1];

   assign o_wb_sel[3] = i_word | (i_half & i_lsb[1]) | (i_lsb == 2'b11);
   assign o_wb_sel[2] = (i_lsb == 2'b10) | i_word;
   assign o_wb_sel[1] = ((i_word | i_half) & !i_lsb[1]) | (i_lsb == 2'b01);
   assign o_wb_sel[0] = (i_lsb == 2'b00);

   wire       wbyte0 = (i_bytecnt == 2'b00);
   wire       wbyte1 = ((i_bytecnt == 2'b01) & !i_lsb[0]);
   wire       wbyte2 = ((i_bytecnt == 2'b10) & !i_lsb[1]);
   wire       wbyte3 = ((i_bytecnt == 2'b11) & !i_lsb[1]);

   assign dat0_en = i_en & (i_init ? wbyte0 : (dat_sel == 2'd0));
   assign dat1_en = i_en & (i_init ? (wbyte0 | wbyte1) : (dat_sel == 2'd1));
   assign dat2_en = i_en & (i_init ? (wbyte0 | wbyte2) : (dat_sel == 2'd2));
   assign dat3_en = i_en & (i_init ? (wbyte0 | wbyte1 | wbyte3) : (dat_sel == 2'd3));

   assign o_wb_dat = {dat3,dat2,dat1,dat0};

   assign o_misalign = misalign & i_mem_op;

   always @(posedge i_clk) begin

      if (dat0_en)
	dat0 <= {i_rs2, dat0[7:1]};
      if (dat1_en)
	dat1 <= {i_rs2, dat1[7:1]};
      if (dat2_en)
	dat2 <= {i_rs2, dat2[7:1]};
      if (dat3_en)
	dat3 <= {i_rs2, dat3[7:1]};

      if (i_wb_ack)
	{dat3,dat2,dat1,dat0} <= i_wb_rdt;

      misalign <= (i_lsb[0] & (i_word | i_half)) | (i_lsb[1] & i_word);
      if (dat_valid)
        signbit <= dat_cur;

   end
endmodule
