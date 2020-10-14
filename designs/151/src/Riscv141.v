// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

module Riscv141(
  input clk,
  input reset,

  // Memory system ports
  output [31:0] dcache_addr,
  output [31:0] icache_addr,
  output [3:0] dcache_we,
  output dcache_re,
  output icache_re,
  output [31:0] dcache_din,
  input dcache_val,
  input [31:0] dcache_dout,
  input [31:0] icache_dout,
  input stall,
  output [31:0] csr
);
  wire [1:0]    s1_pc_sel;
  wire          s3_csr_we;
  wire [4:0]    s1_rs1;
  wire [4:0]    s1_rs2;
  wire [4:0]    s1_rd;
  wire [6:0]    s1_opcode;
  wire [2:0]    s1_func;
  wire          s1_fwd_s3_rs1;
  wire          s1_fwd_s3_rs2;

  wire [1:0]    s2_alu_a_sel;
  wire [2:0]    s2_alu_b_sel;
  wire [1:0]    s2_adder_a_sel;
  wire          s2_adder_b_sel;
  wire          s2_pc_out_sel;
  wire [1:0]    s2_dmem_we;
  wire          s2_dmem_re;
  wire          s2_fwd_s3_rs1;
  wire          s2_fwd_s3_rs2;
  wire [4:0]    s2_rs1;
  wire [4:0]    s2_rs2;
  wire [4:0]    s2_rd;
  wire [6:0]    s2_opcode;
  wire [2:0]    s2_func;

  wire [2:0]    s3_rdata_sel;
  wire [1:0]    s3_reg_wdata_sel;
  wire          s3_reg_we;
  wire [4:0]    s3_rs1;
  wire [4:0]    s3_rs2;
  wire [4:0]    s3_rd;
  wire [6:0]    s3_opcode;
  wire [2:0]    s3_func;
  wire          s3_branch;
  wire          s3_csr_new_data_sel;

  controller ctrl(
    .clk(clk),
    .reset(reset),
    .hard_stall(stall),
    .dcache_val(dcache_val),
    .s1_opcode(s1_opcode),
    .s2_opcode(s2_opcode),
    .s3_opcode(s3_opcode),
    .s1_rs1(s1_rs1),
    .s2_rs1(s2_rs1),
    .s3_rs1(s3_rs1),
    .s1_rs2(s1_rs2),
    .s2_rs2(s2_rs2),
    .s3_rs2(s3_rs2),
    .s1_rd(s1_rd),
    .s2_rd(s2_rd),
    .s3_rd(s3_rd),
    .s1_func(s1_func),
    .s2_func(s2_func),
    .s3_func(s3_func),
    .s3_branch(s3_branch),
    .s1_pc_sel(s1_pc_sel),
    .s1_imem_re(icache_re),
    .s1_fwd_s3_rs1(s1_fwd_s3_rs1),
    .s1_fwd_s3_rs2(s1_fwd_s3_rs2),
    .s2_alu_a_sel(s2_alu_a_sel),
    .s2_alu_b_sel(s2_alu_b_sel),
    .s2_adder_a_sel(s2_adder_a_sel),
    .s2_adder_b_sel(s2_adder_b_sel),
    .s2_pc_out_sel(s2_pc_out_sel),
    .s2_dmem_we(s2_dmem_we),
    .s2_dmem_re(s2_dmem_re),
    .s2_fwd_s3_rs1(s2_fwd_s3_rs1),
    .s2_fwd_s3_rs2(s2_fwd_s3_rs2),
    .s3_rdata_sel(s3_rdata_sel),
    .s3_reg_wdata_sel(s3_reg_wdata_sel),
    .s3_reg_we(s3_reg_we),
    .s3_csr_we(s3_csr_we),
    .s3_csr_new_data_sel(s3_csr_new_data_sel)
  );


  datapath dpath(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .s1_pc_sel(s1_pc_sel),
    .s3_csr_we(s3_csr_we),
    .s1_fwd_s3_rs1(s1_fwd_s3_rs1),
    .s1_fwd_s3_rs2(s1_fwd_s3_rs2),
    .s1_rs1(s1_rs1),
    .s1_rs2(s1_rs2),
    .s1_rd(s1_rd),
    .s1_opcode(s1_opcode),
    .s1_func(s1_func),
    .s2_alu_a_sel(s2_alu_a_sel),
    .s2_alu_b_sel(s2_alu_b_sel),
    .s2_adder_a_sel(s2_adder_a_sel),
    .s2_adder_b_sel(s2_adder_b_sel),
    .s2_pc_out_sel(s2_pc_out_sel),
    .s2_dmem_we(s2_dmem_we),
    .s2_dmem_re(s2_dmem_re),
    .s2_fwd_s3_rs1(s2_fwd_s3_rs1),
    .s2_fwd_s3_rs2(s2_fwd_s3_rs2),
    .s2_rs1(s2_rs1),
    .s2_rs2(s2_rs2),
    .s2_rd(s2_rd),
    .s2_opcode(s2_opcode),
    .s2_func(s2_func),
    .s3_rdata_sel(s3_rdata_sel),
    .s3_reg_wdata_sel(s3_reg_wdata_sel),
    .s3_reg_we(s3_reg_we),
    .s3_rs1(s3_rs1),
    .s3_rs2(s3_rs2),
    .s3_rd(s3_rd),
    .s3_opcode(s3_opcode),
    .s3_func(s3_func),
    .s3_branch(s3_branch),
    .s3_csr_new_data_sel(s3_csr_new_data_sel),

    .dcache_addr(dcache_addr),
    .icache_addr(icache_addr),
    .dcache_we(dcache_we),
    .dcache_re(dcache_re),
    .dcache_din(dcache_din),
    .dcache_dout(dcache_dout),
    .icache_dout(icache_dout),
    .csr_tohost(csr)
  );
endmodule
