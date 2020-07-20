`default_nettype none
module serv_decode
  (
   input wire 	     clk,
   //Input
   input wire 	     i_cnt_en,
   input wire 	     i_cnt_done,
   input wire [31:0] i_wb_rdt,
   input wire 	     i_wb_en,
   input wire 	     i_alu_cmp,
   //To state
   output wire 	     o_take_branch,
   output wire 	     o_e_op,
   output wire 	     o_ebreak,
   output wire 	     o_branch_op,
   output wire 	     o_mem_op,
   output wire 	     o_shift_op,
   output wire 	     o_slt_op,
   //To bufreg
   output wire 	     o_bufreg_loop,
   output wire 	     o_bufreg_rs1_en,
   output wire 	     o_bufreg_imm_en,
   output wire 	     o_bufreg_clr_lsb,
   //To ctrl
   output wire 	     o_ctrl_jal_or_jalr,
   output wire 	     o_ctrl_utype,
   output wire 	     o_ctrl_pc_rel,
   output wire 	     o_ctrl_mret,
   //To alu
   output wire 	     o_alu_sub,
   output wire [1:0] o_alu_bool_op,
   output wire 	     o_alu_cmp_eq,
   output wire 	     o_alu_cmp_uns,
   output wire 	     o_alu_sh_signed,
   output wire 	     o_alu_sh_right,
   output reg [1:0]  o_alu_rd_sel,
   //To RF
   output wire 	     o_rf_rd_en,
   output reg [4:0]  o_rf_rd_addr,
   output reg [4:0]  o_rf_rs1_addr,
   output reg [4:0]  o_rf_rs2_addr,
   //To mem IF
   output wire 	     o_mem_signed,
   output wire 	     o_mem_word,
   output wire 	     o_mem_half,
   output wire 	     o_mem_cmd,
   //To CSR
   output wire 	     o_csr_en,
   output wire [1:0] o_csr_addr,
   output wire 	     o_csr_mstatus_en,
   output wire 	     o_csr_mie_en,
   output wire 	     o_csr_mcause_en,
   output wire [1:0] o_csr_source,
   output wire 	     o_csr_d_sel,
   //To top
   output wire 	     o_imm,
   output wire 	     o_op_b_source,
   output wire 	     o_rd_csr_en,
   output wire 	     o_rd_alu_en);

`include "serv_params.vh"

   reg [4:0] opcode;
   reg [2:0] funct3;
   reg 	      op20;
   reg 	      op21;
   reg 	      op22;
   reg 	      op26;

   reg       imm30;

   wire      op_or_opimm = (!opcode[4] & opcode[2] & !opcode[0]);

   assign o_mem_op   = !opcode[4] & !opcode[2] & !opcode[0];
   assign o_shift_op = op_or_opimm & (funct3[1:0] == 2'b01);
   assign o_slt_op   = op_or_opimm & (funct3[2:1] == 2'b01);
   assign o_branch_op = opcode[4] & !opcode[2];

   //Matches system opcodes except CSR accesses (funct3 == 0)
   //No idea anymore why the !op21 condition is needed here
   assign o_e_op = opcode[4] & opcode[2] & !op21 & !(|funct3);

   assign o_ebreak = op20;

   //jal,branch =     imm
   //jalr       = rs1+imm
   //mem        = rs1+imm
   //shift      = rs1
   assign o_bufreg_rs1_en = !opcode[4] | (!opcode[1] & opcode[0]);
   assign o_bufreg_imm_en = !opcode[2];

   //Loop bufreg contents for shift operations
   assign o_bufreg_loop   = op_or_opimm;

   //Clear LSB of immediate for BRANCH and JAL ops
   //True for BRANCH and JAL
   //False for JALR/LOAD/STORE/OP/OPIMM?
   assign o_bufreg_clr_lsb = opcode[4] & ((opcode[1:0] == 2'b00) | (opcode[1:0] == 2'b11));

   //Take branch for jump or branch instructions (opcode == 1x0xx) if
   //a) It's an unconditional branch (opcode[0] == 1)
   //b) It's a conditional branch (opcode[0] == 0) of type beq,blt,bltu (funct3[0] == 0) and ALU compare is true
   //c) It's a conditional branch (opcode[0] == 0) of type bne,bge,bgeu (funct3[0] == 1) and ALU compare is false
   //Only valid during the last cycle of INIT, when the branch condition has
   //been calculated.
   assign o_take_branch = opcode[4] & !opcode[2] & (opcode[0] | (i_alu_cmp^funct3[0]));

   assign o_ctrl_utype       = !opcode[4] & opcode[2] & opcode[0];
   assign o_ctrl_jal_or_jalr = opcode[4] & opcode[0];

   //True for jal, b* auipc
   //False for jalr, lui
   assign o_ctrl_pc_rel = (opcode[2:0] == 3'b000) |
			  (opcode[1:0] == 2'b11) |
			  (opcode[4:3] == 2'b00);

   assign o_ctrl_mret = (opcode[4] & opcode[2] & op21 & !(|funct3));

   assign o_rf_rd_en = (opcode[2] |
			(!opcode[2] & opcode[4] & opcode[0]) |
			(!opcode[2] & !opcode[3] & !opcode[0]));

   assign o_alu_sub = opcode[3] & imm30/*alu_sub_r*/;

   /*
    300 0_000 mstatus RWSC
    304 0_100 mie SCWi
    305 0_101 mtvec RW
    340 1_000 mscratch
    341 1_001 mepc  RW
    342 1_010 mcause R
    343 1_011 mtval
    344 1_100 mip CWi
    */

   //true  for mtvec,mscratch,mepc and mtval
   //false for mstatus, mie, mcause, mip
   wire csr_valid = op20 | (op26 & !op22 & !op21);

   //Matches system ops except eceall/ebreak
   wire csr_op = opcode[4] & opcode[2] & (|funct3);
   assign o_rd_csr_en = csr_op;

   assign o_csr_en         = csr_op & csr_valid;
   assign o_csr_mstatus_en = csr_op & !op26 & !op22;
   assign o_csr_mie_en     = csr_op & !op26 &  op22 & !op20;
   assign o_csr_mcause_en  = csr_op         &  op21 & !op20;

   assign o_csr_source = funct3[1:0];
   assign o_csr_d_sel = funct3[2];

   assign o_csr_addr = (op26 & !op20) ? CSR_MSCRATCH :
		       (op26 & !op21) ? CSR_MEPC :
		       (op26)         ? CSR_MTVAL :
		       CSR_MTVEC;

   assign o_alu_cmp_eq = funct3[2:1] == 2'b00;

   assign o_alu_cmp_uns = (funct3[0] & funct3[1]) | (funct3[1] & funct3[2]);
   assign o_alu_sh_signed = imm30;
   assign o_alu_sh_right = funct3[2];

   assign o_mem_cmd  = opcode[3];
   assign o_mem_signed = ~funct3[2];
   assign o_mem_word   = funct3[1];
   assign o_mem_half   = funct3[0];

   assign o_alu_bool_op = funct3[1:0];

   reg 	      signbit;

   reg [8:0]  imm19_12_20;
   reg 	      imm7;
   reg [5:0]  imm30_25;
   reg [4:0]  imm24_20;
   reg [4:0]  imm11_7;

   always @(funct3)
      casez(funct3)
        3'b000  : o_alu_rd_sel = ALU_RESULT_ADD;
        3'b001  : o_alu_rd_sel = ALU_RESULT_SR;
        3'b01?  : o_alu_rd_sel = ALU_RESULT_LT;
        3'b100  : o_alu_rd_sel = ALU_RESULT_BOOL;
        3'b101  : o_alu_rd_sel = ALU_RESULT_SR;
        3'b11?  : o_alu_rd_sel = ALU_RESULT_BOOL;
      endcase

   always @(posedge clk) begin
      if (i_wb_en) begin
         o_rf_rd_addr  <= i_wb_rdt[11:7];
         o_rf_rs1_addr <= i_wb_rdt[19:15];
         o_rf_rs2_addr <= i_wb_rdt[24:20];
         funct3        <= i_wb_rdt[14:12];
         imm30         <= i_wb_rdt[30];
         opcode        <= i_wb_rdt[6:2];
	 op20 <= i_wb_rdt[20];
	 op21 <= i_wb_rdt[21];
	 op22 <= i_wb_rdt[22];
	 op26 <= i_wb_rdt[26];

	 //Immediate decoder
	 signbit     <= i_wb_rdt[31];
	 imm19_12_20 <= {i_wb_rdt[19:12],i_wb_rdt[20]};
	 imm7        <= i_wb_rdt[7];
	 imm30_25    <= i_wb_rdt[30:25];
	 imm24_20    <= i_wb_rdt[24:20];
	 imm11_7     <= i_wb_rdt[11:7];
      end
      if (i_cnt_en) begin
	 imm19_12_20 <= {m3 ? signbit : imm24_20[0], imm19_12_20[8:1]};
	 imm7        <= signbit;
	 imm30_25    <= {m2[1] ? imm7 : m2[0] ? signbit : imm19_12_20[0], imm30_25[5:1]};
	 imm24_20    <= {imm30_25[0], imm24_20[4:1]};
	 imm11_7     <= {imm30_25[0], imm11_7[4:1]};
      end
   end

   //True for S (STORE) or B (BRANCH) type instructions
   //False for J type instructions
   wire m1 = opcode[3:0] == 4'b1000;

   wire [1:0] m2;
   assign m2[1] = opcode[4] & !opcode[0];

   //True for OP-IMM, LOAD, STORE, JALR
   //False for LUI, AUIPC, JAL
   assign m2[0] = (opcode[1:0] == 2'b00) | (opcode[2:1] == 2'b00);
   wire m3 = opcode[4];

   assign o_imm = i_cnt_done ? signbit : m1 ? imm11_7[0] : imm24_20[0];

   //0 (OP_B_SOURCE_IMM) when OPIMM
   //1 (OP_B_SOURCE_RS2) when BRANCH or OP
   assign o_op_b_source = opcode[3];

   assign o_rd_alu_en  = !opcode[0] & opcode[2] & !opcode[4];


endmodule
