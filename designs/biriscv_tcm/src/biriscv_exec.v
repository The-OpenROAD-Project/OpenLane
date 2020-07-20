//-----------------------------------------------------------------
//                         biRISC-V CPU
//                            V0.8.0
//                     Ultra-Embedded.com
//                     Copyright 2019-2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

module biriscv_exec
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           opcode_valid_i
    ,input  [ 31:0]  opcode_opcode_i
    ,input  [ 31:0]  opcode_pc_i
    ,input           opcode_invalid_i
    ,input  [  4:0]  opcode_rd_idx_i
    ,input  [  4:0]  opcode_ra_idx_i
    ,input  [  4:0]  opcode_rb_idx_i
    ,input  [ 31:0]  opcode_ra_operand_i
    ,input  [ 31:0]  opcode_rb_operand_i
    ,input           hold_i

    // Outputs
    ,output          branch_request_o
    ,output          branch_is_taken_o
    ,output          branch_is_not_taken_o
    ,output [ 31:0]  branch_source_o
    ,output          branch_is_call_o
    ,output          branch_is_ret_o
    ,output          branch_is_jmp_o
    ,output [ 31:0]  branch_pc_o
    ,output          branch_d_request_o
    ,output [ 31:0]  branch_d_pc_o
    ,output [  1:0]  branch_d_priv_o
    ,output [ 31:0]  writeback_value_o
);



//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "biriscv_defs.v"

//-------------------------------------------------------------
// Opcode decode
//-------------------------------------------------------------
reg [31:0]  imm20_r;
reg [31:0]  imm12_r;
reg [31:0]  bimm_r;
reg [31:0]  jimm20_r;
reg [4:0]   shamt_r;

always @ *
begin
    imm20_r     = {opcode_opcode_i[31:12], 12'b0};
    imm12_r     = {{20{opcode_opcode_i[31]}}, opcode_opcode_i[31:20]};
    bimm_r      = {{19{opcode_opcode_i[31]}}, opcode_opcode_i[31], opcode_opcode_i[7], opcode_opcode_i[30:25], opcode_opcode_i[11:8], 1'b0};
    jimm20_r    = {{12{opcode_opcode_i[31]}}, opcode_opcode_i[19:12], opcode_opcode_i[20], opcode_opcode_i[30:25], opcode_opcode_i[24:21], 1'b0};
    shamt_r     = opcode_opcode_i[24:20];
end

//-------------------------------------------------------------
// Execute - ALU operations
//-------------------------------------------------------------
reg [3:0]  alu_func_r;
reg [31:0] alu_input_a_r;
reg [31:0] alu_input_b_r;

always @ *
begin
    alu_func_r     = `ALU_NONE;
    alu_input_a_r  = 32'b0;
    alu_input_b_r  = 32'b0;

    if ((opcode_opcode_i & `INST_ADD_MASK) == `INST_ADD) // add
    begin
        alu_func_r     = `ALU_ADD;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_AND_MASK) == `INST_AND) // and
    begin
        alu_func_r     = `ALU_AND;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_OR_MASK) == `INST_OR) // or
    begin
        alu_func_r     = `ALU_OR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SLL_MASK) == `INST_SLL) // sll
    begin
        alu_func_r     = `ALU_SHIFTL;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SRA_MASK) == `INST_SRA) // sra
    begin
        alu_func_r     = `ALU_SHIFTR_ARITH;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SRL_MASK) == `INST_SRL) // srl
    begin
        alu_func_r     = `ALU_SHIFTR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SUB_MASK) == `INST_SUB) // sub
    begin
        alu_func_r     = `ALU_SUB;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_XOR_MASK) == `INST_XOR) // xor
    begin
        alu_func_r     = `ALU_XOR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SLT_MASK) == `INST_SLT) // slt
    begin
        alu_func_r     = `ALU_LESS_THAN_SIGNED;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_SLTU_MASK) == `INST_SLTU) // sltu
    begin
        alu_func_r     = `ALU_LESS_THAN;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = opcode_rb_operand_i;
    end
    else if ((opcode_opcode_i & `INST_ADDI_MASK) == `INST_ADDI) // addi
    begin
        alu_func_r     = `ALU_ADD;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_ANDI_MASK) == `INST_ANDI) // andi
    begin
        alu_func_r     = `ALU_AND;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_SLTI_MASK) == `INST_SLTI) // slti
    begin
        alu_func_r     = `ALU_LESS_THAN_SIGNED;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_SLTIU_MASK) == `INST_SLTIU) // sltiu
    begin
        alu_func_r     = `ALU_LESS_THAN;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_ORI_MASK) == `INST_ORI) // ori
    begin
        alu_func_r     = `ALU_OR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_XORI_MASK) == `INST_XORI) // xori
    begin
        alu_func_r     = `ALU_XOR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = imm12_r;
    end
    else if ((opcode_opcode_i & `INST_SLLI_MASK) == `INST_SLLI) // slli
    begin
        alu_func_r     = `ALU_SHIFTL;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = {27'b0, shamt_r};
    end
    else if ((opcode_opcode_i & `INST_SRLI_MASK) == `INST_SRLI) // srli
    begin
        alu_func_r     = `ALU_SHIFTR;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = {27'b0, shamt_r};
    end
    else if ((opcode_opcode_i & `INST_SRAI_MASK) == `INST_SRAI) // srai
    begin
        alu_func_r     = `ALU_SHIFTR_ARITH;
        alu_input_a_r  = opcode_ra_operand_i;
        alu_input_b_r  = {27'b0, shamt_r};
    end
    else if ((opcode_opcode_i & `INST_LUI_MASK) == `INST_LUI) // lui
    begin
        alu_input_a_r  = imm20_r;
    end
    else if ((opcode_opcode_i & `INST_AUIPC_MASK) == `INST_AUIPC) // auipc
    begin
        alu_func_r     = `ALU_ADD;
        alu_input_a_r  = opcode_pc_i;
        alu_input_b_r  = imm20_r;
    end     
    else if (((opcode_opcode_i & `INST_JAL_MASK) == `INST_JAL) || ((opcode_opcode_i & `INST_JALR_MASK) == `INST_JALR)) // jal, jalr
    begin
        alu_func_r     = `ALU_ADD;
        alu_input_a_r  = opcode_pc_i;
        alu_input_b_r  = 32'd4;
    end
end


//-------------------------------------------------------------
// ALU
//-------------------------------------------------------------
wire [31:0]  alu_p_w;
biriscv_alu
u_alu
(
    .alu_op_i(alu_func_r),
    .alu_a_i(alu_input_a_r),
    .alu_b_i(alu_input_b_r),
    .alu_p_o(alu_p_w)
);

//-------------------------------------------------------------
// Flop ALU output
//-------------------------------------------------------------
reg [31:0] result_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    result_q  <= 32'b0;
else if (~hold_i)
    result_q <= alu_p_w;

assign writeback_value_o  = result_q;

//-----------------------------------------------------------------
// less_than_signed: Less than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x < (int)y
//-----------------------------------------------------------------
function [0:0] less_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if (x[31] != y[31])
        less_than_signed = x[31];
    else
        less_than_signed = v[31];
end
endfunction

//-----------------------------------------------------------------
// greater_than_signed: Greater than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x > (int)y
//-----------------------------------------------------------------
function [0:0] greater_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if (x[31] != y[31])
        greater_than_signed = y[31];
    else
        greater_than_signed = v[31];
end
endfunction

//-------------------------------------------------------------
// Execute - Branch operations
//-------------------------------------------------------------
reg        branch_r;
reg        branch_taken_r;
reg [31:0] branch_target_r;
reg        branch_call_r;
reg        branch_ret_r;
reg        branch_jmp_r;

always @ *
begin
    branch_r        = 1'b0;
    branch_taken_r  = 1'b0;
    branch_call_r   = 1'b0;
    branch_ret_r    = 1'b0;
    branch_jmp_r    = 1'b0;

    // Default branch_r target is relative to current PC
    branch_target_r = opcode_pc_i + bimm_r;

    if ((opcode_opcode_i & `INST_JAL_MASK) == `INST_JAL) // jal
    begin
        branch_r        = 1'b1;
        branch_taken_r  = 1'b1;
        branch_target_r = opcode_pc_i + jimm20_r;
        branch_call_r   = (opcode_rd_idx_i == 5'd1); // RA
        branch_jmp_r    = 1'b1;
    end
    else if ((opcode_opcode_i & `INST_JALR_MASK) == `INST_JALR) // jalr
    begin
        branch_r            = 1'b1;
        branch_taken_r      = 1'b1;
        branch_target_r     = opcode_ra_operand_i + imm12_r;
        branch_target_r[0]  = 1'b0;
        branch_ret_r        = (opcode_ra_idx_i == 5'd1 && imm12_r[11:0] == 12'b0); // RA
        branch_call_r       = ~branch_ret_r && (opcode_rd_idx_i == 5'd1); // RA
        branch_jmp_r        = ~(branch_call_r | branch_ret_r);
    end
    else if ((opcode_opcode_i & `INST_BEQ_MASK) == `INST_BEQ) // beq
    begin
        branch_r      = 1'b1;
        branch_taken_r= (opcode_ra_operand_i == opcode_rb_operand_i);
    end
    else if ((opcode_opcode_i & `INST_BNE_MASK) == `INST_BNE) // bne
    begin
        branch_r      = 1'b1;    
        branch_taken_r= (opcode_ra_operand_i != opcode_rb_operand_i);
    end
    else if ((opcode_opcode_i & `INST_BLT_MASK) == `INST_BLT) // blt
    begin
        branch_r      = 1'b1;
        branch_taken_r= less_than_signed(opcode_ra_operand_i, opcode_rb_operand_i);
    end
    else if ((opcode_opcode_i & `INST_BGE_MASK) == `INST_BGE) // bge
    begin
        branch_r      = 1'b1;    
        branch_taken_r= greater_than_signed(opcode_ra_operand_i,opcode_rb_operand_i) | (opcode_ra_operand_i == opcode_rb_operand_i);
    end
    else if ((opcode_opcode_i & `INST_BLTU_MASK) == `INST_BLTU) // bltu
    begin
        branch_r      = 1'b1;    
        branch_taken_r= (opcode_ra_operand_i < opcode_rb_operand_i);
    end
    else if ((opcode_opcode_i & `INST_BGEU_MASK) == `INST_BGEU) // bgeu
    begin
        branch_r      = 1'b1;
        branch_taken_r= (opcode_ra_operand_i >= opcode_rb_operand_i);
    end
end

reg        branch_taken_q;
reg        branch_ntaken_q;
reg [31:0] pc_x_q;
reg [31:0] pc_m_q;
reg        branch_call_q;
reg        branch_ret_q;
reg        branch_jmp_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    branch_taken_q   <= 1'b0;
    branch_ntaken_q  <= 1'b0;
    pc_x_q           <= 32'b0;
    pc_m_q           <= 32'b0;
    branch_call_q    <= 1'b0;
    branch_ret_q     <= 1'b0;
    branch_jmp_q     <= 1'b0;
end
else if (opcode_valid_i)
begin
    branch_taken_q   <= branch_r && opcode_valid_i & branch_taken_r;
    branch_ntaken_q  <= branch_r && opcode_valid_i & ~branch_taken_r;
    pc_x_q           <= branch_taken_r ? branch_target_r : opcode_pc_i + 32'd4;
    branch_call_q    <= branch_r && opcode_valid_i && branch_call_r;
    branch_ret_q     <= branch_r && opcode_valid_i && branch_ret_r;
    branch_jmp_q     <= branch_r && opcode_valid_i && branch_jmp_r;
    pc_m_q           <= opcode_pc_i;
end

assign branch_request_o   = branch_taken_q | branch_ntaken_q;
assign branch_is_taken_o  = branch_taken_q;
assign branch_is_not_taken_o = branch_ntaken_q;
assign branch_source_o    = pc_m_q;
assign branch_pc_o        = pc_x_q;
assign branch_is_call_o   = branch_call_q;
assign branch_is_ret_o    = branch_ret_q;
assign branch_is_jmp_o    = branch_jmp_q;

assign branch_d_request_o = (branch_r && opcode_valid_i && branch_taken_r);
assign branch_d_pc_o      = branch_target_r;
assign branch_d_priv_o    = 2'b0; // don't care



endmodule
