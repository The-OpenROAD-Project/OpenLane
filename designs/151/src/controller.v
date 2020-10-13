// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "Opcode.vh"
`include "const.vh"

module controller(
  // This is used to push signals that only control sources and alone uses
  // through the different stages.
  input clk,
  input reset,

  // Stops pipeline registers.
  input hard_stall,

  input dcache_val,

  input wire [6:0]  s1_opcode,
  input wire [6:0]  s2_opcode,
  input wire [6:0]  s3_opcode,

  input wire [4:0]  s1_rs1,
  input wire [4:0]  s2_rs1,
  input wire [4:0]  s3_rs1,

  input wire [4:0]  s1_rs2,
  input wire [4:0]  s2_rs2,
  input wire [4:0]  s3_rs2,

  input wire [4:0]  s1_rd,
  input wire [4:0]  s2_rd,
  input wire [4:0]  s3_rd,

  input wire [2:0]  s1_func,
  input wire [2:0]  s2_func,
  input wire [2:0]  s3_func,

  input wire        s3_branch,

  // Stage 1 controls.
  output reg [1:0]  s1_pc_sel,
  output            s1_imem_re,
  output reg        s1_fwd_s3_rs1,
  output reg        s1_fwd_s3_rs2,

  // Stage 2 controls.
  output reg [1:0]  s2_alu_a_sel,
  output reg [2:0]  s2_alu_b_sel,
  output reg [1:0]  s2_adder_a_sel,
  output reg        s2_adder_b_sel,
  output reg        s2_pc_out_sel,
  output reg [1:0]  s2_dmem_we,
  output reg        s2_dmem_re,
  output reg        s2_fwd_s3_rs1,
  output reg        s2_fwd_s3_rs2,

  // Stage 3 controls.
  output reg [2:0]  s3_rdata_sel,
  output reg [1:0]  s3_reg_wdata_sel,
  output reg        s3_reg_we,
  output reg        s3_csr_we,
  output reg        s3_csr_new_data_sel
);
  // Kill signals propagate with instructions down the pipe. The instructions
  // are made ineffectual if their kill bit is set. The first two are for
  // combinationally set kills in the current cycles. The second two
  // propagate these values to subsequent stages.
  reg s1_kill, s2_kill;
  reg s2_kill_reg, s3_kill_reg;

  // s1_kill kills s1; s2_kill_reg tracks whether the instruction in stage was
  // killed in stage 1. s2_kill kills s2. So we need to combine the signal to
  // know if the instruction in s2 was ever killed (now or in s1):
  wire s2_killed;

  // TODO(aryap): Is it easier to define all signals for all stages once per
  // instruction, in a giant vector? Or will that be a nightmare to debug?

  // TODO(aryap): When isn't this true? On a stall?
  assign s1_imem_re = `CONTROL_TRUE;

  // Hazard detection.

  // The stall signal tells us to spin on our S1 PC select.
  reg s1_stall;

  // TODO(aryap): Wire?
  reg s3_maybe_writes_rd, s1_maybe_uses_rs1, s1_maybe_uses_rs2;
  reg s3_writes_rd;

  always @(*) begin
    s1_maybe_uses_rs1 = `CONTROL_FALSE;
    s1_maybe_uses_rs2 = `CONTROL_FALSE;
    s3_maybe_writes_rd = `CONTROL_FALSE;

    case (s3_opcode)
      `OPC_LUI, `OPC_AUIPC, `OPC_JAL, `OPC_JALR, `OPC_LOAD, `OPC_ARI_RTYPE,
        `OPC_ARI_ITYPE, `OPC_CSR: s3_maybe_writes_rd = `CONTROL_TRUE;
      default: s3_maybe_writes_rd = `CONTROL_FALSE;
    endcase

    case (s1_opcode)
      `OPC_JALR, `OPC_BRANCH, `OPC_STORE, `OPC_LOAD, `OPC_ARI_RTYPE,
        `OPC_ARI_ITYPE, `OPC_CSR: s1_maybe_uses_rs1  = `CONTROL_TRUE;
      default: s1_maybe_uses_rs1  = `CONTROL_FALSE;
    endcase

    case (s1_opcode)
      `OPC_BRANCH, `OPC_STORE, `OPC_ARI_RTYPE:
        s1_maybe_uses_rs2  = `CONTROL_TRUE;
      default: s1_maybe_uses_rs2  = `CONTROL_FALSE;
    endcase

    // S1 only cares about RS1/RS2 if it hasn't been killed.
    s3_writes_rd = !s3_kill_reg && s3_maybe_writes_rd && s3_rd != 0;

    s1_stall = `CONTROL_FALSE;

    s1_fwd_s3_rs1 = `CONTROL_FALSE;
    s1_fwd_s3_rs2 = `CONTROL_FALSE;
    s2_fwd_s3_rs1 = `CONTROL_FALSE;
    s2_fwd_s3_rs2 = `CONTROL_FALSE;

    // RAW
    //
    // add r0, r1, r2
    // add r3, r4, r0 (or) add r3, r0, r4
    // TODO(aryap): Only check for forwarding between instructions that
    // actually write/read registers (though it doesn't matter for
    // forwarding if they don't?)
    if (s3_writes_rd) begin
      if (s2_rs1 == s3_rd) s2_fwd_s3_rs1 = `CONTROL_TRUE;
      if (s2_rs2 == s3_rd) s2_fwd_s3_rs2 = `CONTROL_TRUE;
    end
    // add r0, r1, r2
    // <something unrelated>
    // add r3, r4, r0 (or) add r3, r0, r0, etc
    //
    // Since s3 results won't be available until next cycle, we stall.
    // Otherwise we have to mux in s3_result into the register output fed to
    // s2 (not hard...)
    //
    // TODO(aryap): I don't think we need 's1_maybe_uses_rs1' now...
    if (s3_writes_rd) begin
      // if (s1_maybe_uses_rs1 && s1_rs1 == s3_rd) begin
      //   s1_stall = `CONTROL_TRUE;
      // end
      // if (s1_maybe_uses_rs2 && s1_rs2 == s3_rd) begin
      //   s1_stall = `CONTROL_TRUE;
      // end
      if (s1_maybe_uses_rs1 && s1_rs1 == s3_rd) s1_fwd_s3_rs1 = `CONTROL_TRUE;
      if (s1_maybe_uses_rs2 && s1_rs2 == s3_rd) s1_fwd_s3_rs2 = `CONTROL_TRUE;
    end

    // WAR
    //
    // add r0, r1, r2
    // add r1, r3, r4   (cannot finish before first instr)
    //
    // -> Not a problem. TODO(aryap): Or is it?
    //
    // WAW
    //
    // add r0, r1, r2
    // add r0, r2, r3   (cannot finish before first instr)
    //
    // -> Not a problem.
  end

  //-------------------------------------------------------------------
  // Stage 1
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  // Stage 2
  //-------------------------------------------------------------------
  //
  // Forwarding to repalce RS1 or RS2 data is taken care of in the datapath.

  always @(*) begin
    // TODO(aryap): Can these be don't-cares? X?
    s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
    s2_alu_b_sel = `S2_ALU_B_SEL_CONST_4;
    s2_adder_a_sel = `S2_ADDER_A_SEL_RS1_DATA;
    s2_adder_b_sel = `S2_ADDER_B_SEL_PC;
    s2_pc_out_sel = `S2_PC_OUT_SEL_STRAIGHT;
    s2_dmem_we = `S2_DMEM_WE_OFF;
    s2_dmem_re = `CONTROL_FALSE;

    if (!hard_stall)
      case (s2_opcode)
        `OPC_CSR: /* Nothing to change */;

        `OPC_LUI: begin
          s2_alu_b_sel = `S2_ALU_B_SEL_IMM_U;
        end

        `OPC_AUIPC: begin
          s2_alu_a_sel = `S2_ALU_A_SEL_S2_PC;
          s2_alu_b_sel = `S2_ALU_B_SEL_IMM_U;
        end

        `OPC_JAL: begin
          s2_adder_a_sel = `S2_ADDER_A_SEL_IMM_J;
          s2_adder_b_sel = `S2_ADDER_B_SEL_PC;
          s2_alu_a_sel = `S2_ALU_A_SEL_S2_PC;
          s2_alu_b_sel = `S2_ALU_B_SEL_CONST_4;
          // s2_branch taken care of by combinational logic in
          // FetchExecuteStage. ALUdec sets ALU op to ADD for JAL/JALR.
        end

        `OPC_JALR: begin
          s2_adder_a_sel = `S2_ADDER_A_SEL_RS1_DATA;
          s2_adder_b_sel = `S2_ADDER_B_SEL_IMM_I;
          s2_alu_a_sel = `S2_ALU_A_SEL_S2_PC;
          s2_alu_b_sel = `S2_ALU_B_SEL_CONST_4;
          s2_pc_out_sel = `S2_PC_OUT_SEL_MASKED;
          // s2_branch taken care of by combinational logic in
          // FetchExecuteStage. ALUdec sets ALU op to ADD for JAL/JALR.
        end

        `OPC_BRANCH: begin
          // Adder should add B-type to PC.
          s2_adder_a_sel = `S2_ADDER_A_SEL_IMM_B;
          s2_adder_b_sel = `S2_ADDER_B_SEL_PC;
          // ALU should perform rs1 (op) rs2.
          s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
          s2_alu_b_sel = `S2_ALU_B_SEL_RS2_DATA;
        end

        `OPC_STORE: begin
          s2_dmem_re = `CONTROL_FALSE;
          if (!s2_killed)
            case (s2_func)
              `FNC_SB: s2_dmem_we = `S2_DMEM_WE_BYTE;
              `FNC_SH: s2_dmem_we = `S2_DMEM_WE_HALF_WORD;
              //`FNC_SW
              default: s2_dmem_we = `S2_DMEM_WE_WORD;
            endcase
          s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
          s2_alu_b_sel = `S2_ALU_B_SEL_IMM_S;
        end

        `OPC_LOAD: begin
          s2_dmem_we = `S2_DMEM_WE_OFF;
          if (!s2_killed) s2_dmem_re = `CONTROL_TRUE;
          s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
          s2_alu_b_sel = `S2_ALU_B_SEL_IMM_I;
        end

        `OPC_ARI_RTYPE: begin
          s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
          s2_alu_b_sel = `S2_ALU_B_SEL_RS2_DATA;
        end
        `OPC_ARI_ITYPE: begin
          s2_alu_a_sel = `S2_ALU_A_SEL_RS1_DATA;
          s2_alu_b_sel = `S2_ALU_B_SEL_IMM_I;
        end
        default: /* ERROR */;
      endcase
  end

  //-------------------------------------------------------------------
  // Stage 3
  //-------------------------------------------------------------------

  always @(*) begin
    // TODO(aryap): Can these be don't-cares? X?

    // TODO(aryap): OH SHIT THE IMEM TAKES 1 CYCLE TO READ
    //   so our idea of what each stage's PC is slightly wrong.
    //   s1_pc contains PC of _next_ instruction in that stage.
    //   likewise s2, s3... so we should shift.

    s1_pc_sel = `S1_PC_SEL_INC;
    s1_kill = `CONTROL_FALSE;
    s2_kill = `CONTROL_FALSE;
    // This can be overridden by jumps.
    if (hard_stall) begin
      s1_pc_sel = `S1_PC_SEL_STALL;
    end else if (s1_stall) begin
      s1_pc_sel = `S1_PC_SEL_STALL;
      s1_kill = `CONTROL_TRUE;
    end

    // These are the defaults that amount to a NO-OP.
    // TODO(aryap): Or at least they should be.
    s3_reg_we = `CONTROL_FALSE;
    s3_csr_we = `CONTROL_FALSE;
    // TODO(aryap): Make the default S3_RESULT not S3_RS1, save some lines.
    // Also maybe make s3_reg_we true by default.
    s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_RS1;
    s3_rdata_sel = `S3_RDATA_SEL_PASSTHROUGH;
    s3_csr_new_data_sel = `S3_CSR_NEW_DATA_SEL_RS1_DATA;

    if (!s3_kill_reg) begin
      case (s3_opcode)
        `OPC_CSR:
          case (s3_func)
            `FNC2_CSRRW, `FNC2_CSRRWI: begin
              if (s3_func == `FNC2_CSRRWI)
                s3_csr_new_data_sel = `S3_CSR_NEW_DATA_SEL_IMM_RS1;
              s3_csr_we = `CONTROL_TRUE;
              // No side effects of _reading_ CSR if RD is 0 (i.e. writing its
              // value to a register).
              if (s3_rd != 0) begin
                s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_CSR_DATA;
                s3_reg_we = `CONTROL_TRUE;
              end
            end
            default: /* ERROR */;
          endcase

        `OPC_LUI, `OPC_AUIPC: begin
          s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_RESULT;
          s3_reg_we = `CONTROL_TRUE;
        end

        `OPC_JAL, `OPC_JALR: begin
          s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_RESULT;   // PC + 4
          s1_pc_sel = `S1_PC_SEL_S3;                        // PC + j-immediate
          s3_reg_we = `CONTROL_TRUE;
          // s2_branch taken care of by combinational logic in
          // FetchExecuteStage. ALUdec sets ALU op to ADD for JAL/JALR.
          s1_kill = `CONTROL_TRUE;
          s2_kill = `CONTROL_TRUE;
        end

        `OPC_BRANCH: begin
          // In S3, branches determine the next PC source and whether the
          // pipeline gets flushed.
          s3_reg_we = `CONTROL_TRUE;
          if (s3_branch) begin
            // Take the next PC from branch target.
            s1_pc_sel = `S1_PC_SEL_S3;
            // Kill the current instructions in stages 1 & 2.
            s1_kill = `CONTROL_TRUE;
            s2_kill = `CONTROL_TRUE;
          end
        end

        `OPC_STORE:;

        `OPC_LOAD: begin
          // TODO(arya): Stall pipeline if dcache signal not yet valid?
          s3_reg_we = dcache_val;
          s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_RDATA_OUT;
          case (s3_func)
            `FNC_LB: s3_rdata_sel = `S3_RDATA_SEL_LOW_BYTE_SIGNED;
            `FNC_LBU: s3_rdata_sel = `S3_RDATA_SEL_LOW_BYTE;
            `FNC_LH: s3_rdata_sel = `S3_RDATA_SEL_LOW_HALF_WORD_SIGNED;
            `FNC_LHU: s3_rdata_sel = `S3_RDATA_SEL_LOW_HALF_WORD;
            //`FNC_LW, 
            default: s3_rdata_sel = `S3_RDATA_SEL_PASSTHROUGH;
          endcase
        end

        `OPC_ARI_RTYPE,`OPC_ARI_ITYPE: begin
          // Result should be written back. rd is perma-wired to the regfile
          // waddr.
          s3_reg_wdata_sel = `S3_REG_WDATA_SEL_S3_RESULT;
          s3_reg_we = `CONTROL_TRUE;
        end
        default: /* ERROR */;
      endcase
    end
  end

  assign s2_killed = s2_kill_reg || s2_kill;

  // Propagate S1 -> S2, S2 -> S3.
  always @(posedge clk) begin
    if (!hard_stall) begin
      s2_kill_reg <= s1_kill;
      s3_kill_reg <= s2_killed;
    end
  end

endmodule
