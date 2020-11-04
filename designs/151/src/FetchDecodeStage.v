// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

// Stage #1: Fetch and Decode.

`include "const.vh"

module FetchDecodeStage #(
  parameter ADDR_LEN = `CPU_ADDR_BITS
)(
  input wire clk,
  input wire reset,
  // This is the address presented to the instruction memory. We expect it to
  // take 1 cycle to read.
  output wire [ADDR_LEN-1:0] s1_imem_addr,
  // This is the address associated with the instruction presented to s1_inst,
  // since it took 1 cycle to read.
  output wire [ADDR_LEN-1:0] s1_pc,
  input wire [ADDR_LEN-1:0] s3_pc,
  input wire [ADDR_LEN-1:0] override_pc,

  // Select source for next PC.
  input wire [1:0] s1_pc_sel,

  // Instruction from memory.
  input wire [`CPU_INST_BITS-1:0] s1_inst,

  // Decoded instruction parts.
  output wire [4:0] s1_rs1,
  output wire [4:0] s1_rs2,
  output wire [4:0] s1_rd,
  output wire [11:0] s1_imm_i,
  output wire [19:0] s1_imm_uj,
  output wire [11:0] s1_imm_bs,

  output wire [6:0] s1_opcode,
  output wire [2:0] s1_func,
  output wire s1_add_rshift_type
);
  reg [ADDR_LEN-1:0] pc;
  reg [ADDR_LEN-1:0] next_pc;

  always @(*) begin
    case (s1_pc_sel)
      `S1_PC_SEL_OVERRIDE: next_pc = override_pc;
      `S1_PC_SEL_S3: next_pc = s3_pc;
      `S1_PC_SEL_STALL: next_pc = pc;
      default: next_pc = pc + 4;
    endcase
  end

  assign s1_imem_addr = next_pc;

  // NOTE(aryap): Tragedy. Instruction fetch takes a whole cycle. We need to
  // associate the previous pc value with the current instruction.

  // Set next cycle's PC value.
  always @(posedge clk) begin
    if (reset) pc <= 0;
    // NOTE(aryap): No explicitly stall here; controller has to hold
    // s1_pc_sel.
    else pc <= next_pc;
  end

  // Decode instruction.
  // TODO(aryap): These indices can be `defined in a header.
  assign s1_rs1 = s1_inst[19:15];
  assign s1_rs2 = s1_inst[24:20];
  assign s1_rd = s1_inst[11:7];
  assign s1_imm_i = s1_inst[31:20];
  assign s1_imm_uj = s1_inst[31:12];
  assign s1_imm_bs = {s1_inst[31:25], s1_inst[11:7]};

  assign s1_opcode = s1_inst[6:0];
  assign s1_func = s1_inst[14:12];
  assign s1_add_rshift_type = s1_inst[30];

  assign s1_pc = pc;

endmodule
