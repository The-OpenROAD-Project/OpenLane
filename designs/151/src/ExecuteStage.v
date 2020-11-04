// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

// Stage #2: Execute stage.

`include "Opcode.vh"
`include "const.vh"

module ExecuteStage #(
)(
  input clk, reset,

  input wire [`CPU_DATA_BITS-1:0] s2_rs1_data,
  input wire [`CPU_DATA_BITS-1:0] s2_rs2_data,
  input wire [11:0] s2_imm_i,
  input wire [19:0] s2_imm_uj,
  input wire [11:0] s2_imm_bs,
  input wire [`CPU_ADDR_BITS-1:0] s2_pc,

  input wire [6:0] s2_opcode,
  input wire [2:0] s2_func,
  input wire s2_add_rshift_type,

  input wire [1:0] s2_alu_a_sel,
  input wire [2:0] s2_alu_b_sel,
  input wire [1:0] s2_adder_a_sel,
  input wire s2_adder_b_sel,
  input wire s2_pc_out_sel,
  //input wire [1:0] s2_rs2_data_mask_sel,

  output wire [`CPU_DATA_BITS-1:0] s2_imm_i_out,
  output wire [`CPU_DATA_BITS-1:0] s2_alu_out,
  output reg [`CPU_ADDR_BITS-1:0] s2_pc_out,
  output wire [`CPU_DATA_BITS-1:0] s2_rs2_data_out,

  output wire s2_branch
);
  // Calculate constants for various masks and concatenations.
  localparam IMM_I_EXTEND_BITS = `CPU_DATA_BITS - 12;
  localparam IMM_J_EXTEND_BITS = `CPU_DATA_BITS - (20 + 1);
  localparam IMM_B_PAD_BITS = `CPU_DATA_BITS - (12 + 1);
  localparam IMM_S_PAD_BITS = `CPU_DATA_BITS - 12;
  localparam CONST_4_PAD_BITS = `CPU_DATA_BITS - 3;

  //always @(*) begin
  //  case (s2_rs2_data_mask_sel) begin
  //    `S2_RS2_DATA_MASK_SEL_LOW_BYTE: s2_rs2_data_out = s2_rs2_data & 8'hFF;
  //    `S2_RS2_DATA_MASK_SEL_LOW_HALF_WORD: s2_rs2_data_out = s2_rs2_data & 16'hFFFF;
  //    `S2_RS2_DATA_MASK_SEL_WORD: s2_rs2_data_out = s2_rs2_data;
  //    default: s2_rs2_data_out = s2_rs2_data;
  //  end
  //end
  assign s2_rs2_data_out = s2_rs2_data;

  // Shift and sign extend the immediates:
  //    TODO(aryap): Which syntax? $signed() or {8{s2_imm_i[11]}, s2_imm_i}?
  //                 e.g. = $signed(s2_imm_i)?
  //    TODO(aryap): Do this in Fetch and Decode?
  wire [`CPU_DATA_BITS-1:0] s2_imm_i_ext = {{IMM_I_EXTEND_BITS{s2_imm_i[11]}},
                                            s2_imm_i};
  wire [`CPU_DATA_BITS-1:0] s2_imm_j = {{IMM_J_EXTEND_BITS{s2_imm_uj[19]}},
                                        s2_imm_uj[19],
                                        s2_imm_uj[7:0],
                                        s2_imm_uj[8],
                                        s2_imm_uj[18:9],
                                        1'b0};
  wire [`CPU_DATA_BITS-1:0] s2_imm_u = s2_imm_uj << 12;
  wire [`CPU_DATA_BITS-1:0] s2_imm_b = {{IMM_B_PAD_BITS{s2_imm_bs[11]}},
                                        s2_imm_bs[11],
                                        s2_imm_bs[0],
                                        s2_imm_bs[10:5],
                                        s2_imm_bs[4:1], 1'b0};
  wire [`CPU_DATA_BITS-1:0] s2_imm_s = {{IMM_S_PAD_BITS{s2_imm_bs[11]}},
                                        s2_imm_bs};

  assign s2_imm_i_out = s2_imm_i_ext;

  wire [4:0] alu_op;
  reg [`CPU_DATA_BITS-1:0] A;
  reg [`CPU_DATA_BITS-1:0] B;

  // Choose A, B ALU inputs and instantiate the ALU to do the work.
  always @(*) begin
    case (s2_alu_a_sel)
      `S2_ALU_A_SEL_RS1_DATA: A = s2_rs1_data;
      `S2_ALU_A_SEL_S2_PC: A = s2_pc;
      `S2_ALU_A_SEL_IMM_J: A = s2_imm_j;
      default: A = s2_rs1_data;
    endcase
  end

  always @(*) begin
    case (s2_alu_b_sel)
      `S2_ALU_B_SEL_IMM_I: B = s2_imm_i_ext;
      `S2_ALU_B_SEL_IMM_U: B = s2_imm_u;
      `S2_ALU_B_SEL_IMM_S: B = s2_imm_s;
      `S2_ALU_B_SEL_CONST_4: B = {{CONST_4_PAD_BITS{1'b0}}, 3'h4};
      default: B = s2_rs2_data; // `S2_ALU_B_SEL_RS2_DATA
    endcase
  end

  // ALU decoder and the ALU itself do most of the heavy lifting here.
  ALUdec alu_decoder (
    .opcode(s2_opcode),
    .funct(s2_func),
    .add_rshift_type(s2_add_rshift_type),
    .ALUop(alu_op));

  ALU alu(
    .A(A),
    .B(B),
    .ALUop(alu_op),
    .Out(s2_alu_out));

  // Take the first bit of ALU output as the branch flag.
  //
  // This signal is only an indication of the branch condition, not whether
  // the branch should be taken. For that, we must also be sure that we're
  // completing a valid branch/jump instruction.
  assign s2_branch = s2_opcode == `OPC_BRANCH ?
      s2_alu_out[0] : (s2_opcode == `OPC_JAL | s2_opcode == `OPC_JALR);

  // A second adder deals with incrementing the PC for branches.
  // TODO(aryap): when CPU_ADDR_BITS != CPU_DATA_BITS, we have to sign extend
  // the inputs to the adder separately to those to the ALU.
  reg [`CPU_ADDR_BITS-1:0] adder_a;
  reg [`CPU_ADDR_BITS-1:0] adder_b;
  wire [`CPU_ADDR_BITS-1:0] adder_out;
  localparam PC_MASK_1_BITS = `CPU_ADDR_BITS - 1;

  // Choose A, B PC computation inputs and use a simple adder to do the work.
  always @(*) begin
    case (s2_adder_a_sel)
      `S2_ADDER_A_SEL_IMM_J: adder_a = s2_imm_j;
      `S2_ADDER_A_SEL_IMM_B: adder_a = s2_imm_b;
      default: adder_a = s2_rs1_data; // `S2_ADDER_A_SEL_RS1_DATA
    endcase
  end

  always @(*) begin
    case (s2_adder_b_sel)
      `S2_ADDER_B_SEL_IMM_I: adder_b = s2_imm_i_ext;
      default: adder_b = s2_pc; // `S2_ADDER_B_SEL_PC
    endcase
  end

  assign adder_out = $signed(adder_a) + $signed(adder_b);

  always @(*) begin
    case (s2_pc_out_sel)
      `S2_PC_OUT_SEL_MASKED: s2_pc_out = adder_out & {{PC_MASK_1_BITS{1'b1}}, 1'b0};
      default: s2_pc_out = adder_out; // `S2_PC_OUT_SEL_STRAIGHT
    endcase
  end

endmodule
