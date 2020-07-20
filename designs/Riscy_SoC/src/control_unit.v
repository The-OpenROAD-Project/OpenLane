`ifndef CONTROLUNIT
`define CONTROLUNIT

`include "alu.v"
`include "csrs.v"
`include "branch.v"
`include "imm.v"
`include "mem.v"
`include "opcodes.vh"

module control_unit (

    input [63:0] instr_in,

    input [8:0] rs1_in,
    input [8:0] rd_in,

    output reg valid_out,
    output reg rs1_read_out,
    output reg rs2_read_out,
    output reg [4:0] imm_out,
    output reg [4:0] alu_op_out,
    output reg [2:0]alu_sub_sra_out,
    output reg [2:0] alu_src1_out,
    output reg [2:0] alu_src2_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [2:0] mem_width_out,
    output reg [2:0] mem_zero_extend_out,
    output reg mem_fence_out,
    output reg csr_read_out,
    output reg csr_write_out,
    output reg [2:0] csr_write_op_out,
    output reg [2:0]csr_src_out,
    output reg [2:0] branch_op_out,
    output reg [2:0] branch_pc_src_out,
    output reg rd_write_out
);
    always @* begin
        valid_out = 0;
        rs1_read_out = 0;
        rs2_read_out = 0;
        imm_out = 8'bx;
        alu_op_out = 8'bx;
        alu_sub_sra_out = 2'bx;
        alu_src1_out = 4'bx;
        alu_src2_out = 2'bx;
        mem_read_out = 0;
        mem_write_out = 0;
        mem_width_out = 4'bx;
        mem_zero_extend_out = 1'bx;
        mem_fence_out = 0;
        csr_read_out = 0;
        csr_write_out = 0;
        csr_write_op_out = 4'bx;
        csr_src_out = 1'bx;
        branch_op_out = `BRANCH_OP_NEVER;
        branch_pc_src_out = 1'bx;
        rd_write_out = 0;
    casez (instr_in)
            `INSTR_LUI: begin
                valid_out = 1;
                imm_out = `IMM_U;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_ZERO;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_AUIPC: begin
                valid_out = 1;
                imm_out = `IMM_U;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_PC;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_JAL: begin
                valid_out = 1;
                imm_out = `IMM_J;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_PC;
                alu_src2_out = `ALU_SRC2_FOUR;
                branch_op_out = `BRANCH_OP_ALWAYS;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
                rd_write_out = 1;
            end
            `INSTR_JALR: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_PC;
                alu_src2_out = `ALU_SRC2_FOUR;
                branch_op_out = `BRANCH_OP_ALWAYS;
                branch_pc_src_out = `BRANCH_PC_SRC_REG;
                rd_write_out = 1;
            end
            `INSTR_BEQ: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_BNE: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_NON_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_BLT: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_SLT;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_NON_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_BGE: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_SLT;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_BLTU: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_SLTU;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_NON_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_BGEU: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_B;
                alu_op_out = `ALU_OP_SLTU;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                branch_op_out = `BRANCH_OP_ZERO;
                branch_pc_src_out = `BRANCH_PC_SRC_IMM;
            end
            `INSTR_LB: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_read_out = 1;
                mem_width_out = `MEM_WIDTH_BYTE;
                mem_zero_extend_out = 0;
                rd_write_out = 1;
            end
            `INSTR_LH: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_read_out = 1;
                mem_width_out = `MEM_WIDTH_HALF;
                mem_zero_extend_out = 0;
                rd_write_out = 1;
            end
            `INSTR_LW: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_read_out = 1;
                mem_width_out = `MEM_WIDTH_WORD;
                rd_write_out = 1;
            end
            `INSTR_LBU: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_read_out = 1;
                mem_width_out = `MEM_WIDTH_BYTE;
                mem_zero_extend_out = 1;
                rd_write_out = 1;
            end
            `INSTR_LHU: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_read_out = 1;
                mem_width_out = `MEM_WIDTH_HALF;
                mem_zero_extend_out = 1;
                rd_write_out = 1;
            end
            `INSTR_SB: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_S;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_write_out = 1;
                mem_width_out = `MEM_WIDTH_BYTE;
            end
            `INSTR_SH: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_S;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_write_out = 1;
                mem_width_out = `MEM_WIDTH_HALF;
            end
            `INSTR_SW: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 1;
                imm_out = `IMM_S;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                mem_write_out = 1;
                mem_width_out = `MEM_WIDTH_WORD;
            end
            `INSTR_ADDI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_SLTI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_SLT;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_SLTIU: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_SLTU;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_XORI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_XOR;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_ORI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_OR;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_ANDI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_I;
                alu_op_out = `ALU_OP_AND;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_SLLI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_SHAMT;
                alu_op_out = `ALU_OP_SLL;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_SRLI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_SHAMT;
                alu_op_out = `ALU_OP_SRL_SRA;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_SRAI: begin
                valid_out = 1;
                rs1_read_out = 1;
                imm_out = `IMM_SHAMT;
                alu_op_out = `ALU_OP_SRL_SRA;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_IMM;
                rd_write_out = 1;
            end
            `INSTR_ADD: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SUB: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_ADD_SUB;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SLL: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_SLL;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SLT: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_SLT;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SLTU: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_SLTU;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_XOR: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_XOR;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SRL: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_SRL_SRA;
                alu_sub_sra_out = 0;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_SRA: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_SRL_SRA;
                alu_sub_sra_out = 1;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_OR: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_OR;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_AND: begin
                valid_out = 1;
                rs1_read_out = 1;
                rs2_read_out = 2;
                alu_op_out = `ALU_OP_AND;
                alu_src1_out = `ALU_SRC1_REG;
                alu_src2_out = `ALU_SRC2_REG;
                rd_write_out = 1;
            end
            `INSTR_FENCE: begin
                valid_out = 1;
            end
            `INSTR_FENCE_I: begin
                valid_out = 1;
                mem_fence_out = 1;
            end
            `INSTR_ECALL: begin
                valid_out = 1;
                // TODO
            end
            `INSTR_EBREAK: begin
                valid_out = 1;
                // TODO
            end
            `INSTR_MRET: begin
                valid_out = 1;
                // TODO
            end
            `INSTR_WFI: begin
                valid_out = 1;
            end
            `INSTR_CSRRW: begin
                valid_out = 1;
                rs1_read_out = 1;
                csr_read_out = |rd_in;
                csr_write_out = 1;
                csr_write_op_out = `CSR_WRITE_OP_RW;
                csr_src_out = `CSR_SRC_REG;
                rd_write_out = |rd_in;
            end
            `INSTR_CSRRS: begin
                valid_out = 1;
                rs1_read_out = 1;
                csr_read_out = 1;
                csr_write_out = |rs1_in;
                csr_write_op_out = `CSR_WRITE_OP_RS;
                csr_src_out = `CSR_SRC_REG;
                rd_write_out = 1;
            end
            `INSTR_CSRRC: begin
                valid_out = 1;
                rs1_read_out = 1;
                csr_read_out = 1;
                csr_write_out = |rs1_in;
                csr_write_op_out = `CSR_WRITE_OP_RC;
                csr_src_out = `CSR_SRC_REG;
                rd_write_out = 1;
            end
            `INSTR_CSRRWI: begin
                valid_out = 1;
                imm_out = `IMM_ZIMM;
                csr_read_out = |rd_in;
                csr_write_out = 1;
                csr_write_op_out = `CSR_WRITE_OP_RW;
                csr_src_out = `CSR_SRC_IMM;
                rd_write_out = |rd_in;
            end
            `INSTR_CSRRSI: begin
                valid_out = 1;
                imm_out = `IMM_ZIMM;
                csr_read_out = 1;
                csr_write_out = |rs1_in;
                csr_write_op_out = `CSR_WRITE_OP_RS;
                csr_src_out = `CSR_SRC_IMM;
                rd_write_out = 1;
            end
            `INSTR_CSRRCI: begin
                valid_out = 1;
                imm_out = `IMM_ZIMM;
                csr_read_out = 1;
                csr_write_out = |rs1_in;
                csr_write_op_out = `CSR_WRITE_OP_RC;
                csr_src_out = `CSR_SRC_IMM;
                rd_write_out = 1;
            end
        endcase
    end
endmodule

`endif
