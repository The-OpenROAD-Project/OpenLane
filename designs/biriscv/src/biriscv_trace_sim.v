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
`include "biriscv_defs.v"

module biriscv_trace_sim
(
     input                        valid_i
    ,input  [31:0]                pc_i
    ,input  [31:0]                opcode_i
);

//-----------------------------------------------------------------
// get_regname_str: Convert register number to string
//-----------------------------------------------------------------
`ifdef verilator
function [79:0] get_regname_str;
    input  [4:0] regnum;
begin
    case (regnum)
        5'd0:  get_regname_str = "zero";
        5'd1:  get_regname_str = "ra";
        5'd2:  get_regname_str = "sp";
        5'd3:  get_regname_str = "gp";
        5'd4:  get_regname_str = "tp";
        5'd5:  get_regname_str = "t0";
        5'd6:  get_regname_str = "t1";
        5'd7:  get_regname_str = "t2";
        5'd8:  get_regname_str = "s0";
        5'd9:  get_regname_str = "s1";
        5'd10: get_regname_str = "a0";
        5'd11: get_regname_str = "a1";
        5'd12: get_regname_str = "a2";
        5'd13: get_regname_str = "a3";
        5'd14: get_regname_str = "a4";
        5'd15: get_regname_str = "a5";
        5'd16: get_regname_str = "a6";
        5'd17: get_regname_str = "a7";
        5'd18: get_regname_str = "s2";
        5'd19: get_regname_str = "s3";
        5'd20: get_regname_str = "s4";
        5'd21: get_regname_str = "s5";
        5'd22: get_regname_str = "s6";
        5'd23: get_regname_str = "s7";
        5'd24: get_regname_str = "s8";
        5'd25: get_regname_str = "s9";
        5'd26: get_regname_str = "s10";
        5'd27: get_regname_str = "s11";
        5'd28: get_regname_str = "t3";
        5'd29: get_regname_str = "t4";
        5'd30: get_regname_str = "t5";
        5'd31: get_regname_str = "t6";
    endcase
end
endfunction

//-------------------------------------------------------------------
// Debug strings
//-------------------------------------------------------------------
reg [79:0] dbg_inst_str;
reg [79:0] dbg_inst_ra;
reg [79:0] dbg_inst_rb;
reg [79:0] dbg_inst_rd;
reg [31:0] dbg_inst_imm;
reg [31:0] dbg_inst_pc;

wire [4:0] ra_idx_w = opcode_i[19:15];
wire [4:0] rb_idx_w = opcode_i[24:20];
wire [4:0] rd_idx_w = opcode_i[11:7];

`define DBG_IMM_IMM20     {opcode_i[31:12], 12'b0}
`define DBG_IMM_IMM12     {{20{opcode_i[31]}}, opcode_i[31:20]}
`define DBG_IMM_BIMM      {{19{opcode_i[31]}}, opcode_i[31], opcode_i[7], opcode_i[30:25], opcode_i[11:8], 1'b0}
`define DBG_IMM_JIMM20    {{12{opcode_i[31]}}, opcode_i[19:12], opcode_i[20], opcode_i[30:25], opcode_i[24:21], 1'b0}
`define DBG_IMM_STOREIMM  {{20{opcode_i[31]}}, opcode_i[31:25], opcode_i[11:7]}
`define DBG_IMM_SHAMT     opcode_i[24:20]

always @ *
begin
    dbg_inst_str = "-";
    dbg_inst_ra  = "-";
    dbg_inst_rb  = "-";
    dbg_inst_rd  = "-";
    dbg_inst_pc  = 32'bx;

    if (valid_i)
    begin
        dbg_inst_pc  = pc_i;
        dbg_inst_ra  = get_regname_str(ra_idx_w);
        dbg_inst_rb  = get_regname_str(rb_idx_w);
        dbg_inst_rd  = get_regname_str(rd_idx_w);

        case (1'b1)
            ((opcode_i & `INST_ANDI_MASK) == `INST_ANDI)   : dbg_inst_str = "andi";
            ((opcode_i & `INST_ADDI_MASK) == `INST_ADDI)   : dbg_inst_str = "addi";
            ((opcode_i & `INST_SLTI_MASK) == `INST_SLTI)   : dbg_inst_str = "slti";
            ((opcode_i & `INST_SLTIU_MASK) == `INST_SLTIU)  : dbg_inst_str = "sltiu";
            ((opcode_i & `INST_ORI_MASK) == `INST_ORI)    : dbg_inst_str = "ori";
            ((opcode_i & `INST_XORI_MASK) == `INST_XORI)   : dbg_inst_str = "xori";
            ((opcode_i & `INST_SLLI_MASK) == `INST_SLLI)   : dbg_inst_str = "slli";
            ((opcode_i & `INST_SRLI_MASK) == `INST_SRLI)   : dbg_inst_str = "srli";
            ((opcode_i & `INST_SRAI_MASK) == `INST_SRAI)   : dbg_inst_str = "srai";
            ((opcode_i & `INST_LUI_MASK) == `INST_LUI)    : dbg_inst_str = "lui";
            ((opcode_i & `INST_AUIPC_MASK) == `INST_AUIPC)  : dbg_inst_str = "auipc";
            ((opcode_i & `INST_ADD_MASK) == `INST_ADD)    : dbg_inst_str = "add";
            ((opcode_i & `INST_SUB_MASK) == `INST_SUB)    : dbg_inst_str = "sub";
            ((opcode_i & `INST_SLT_MASK) == `INST_SLT)    : dbg_inst_str = "slt";
            ((opcode_i & `INST_SLTU_MASK) == `INST_SLTU)   : dbg_inst_str = "sltu";
            ((opcode_i & `INST_XOR_MASK) == `INST_XOR)    : dbg_inst_str = "xor";
            ((opcode_i & `INST_OR_MASK) == `INST_OR)     : dbg_inst_str = "or";
            ((opcode_i & `INST_AND_MASK) == `INST_AND)    : dbg_inst_str = "and";
            ((opcode_i & `INST_SLL_MASK) == `INST_SLL)    : dbg_inst_str = "sll";
            ((opcode_i & `INST_SRL_MASK) == `INST_SRL)    : dbg_inst_str = "srl";
            ((opcode_i & `INST_SRA_MASK) == `INST_SRA)    : dbg_inst_str = "sra";
            ((opcode_i & `INST_JAL_MASK) == `INST_JAL)    : dbg_inst_str = "jal";
            ((opcode_i & `INST_JALR_MASK) == `INST_JALR)   : dbg_inst_str = "jalr";
            ((opcode_i & `INST_BEQ_MASK) == `INST_BEQ)    : dbg_inst_str = "beq";
            ((opcode_i & `INST_BNE_MASK) == `INST_BNE)    : dbg_inst_str = "bne";
            ((opcode_i & `INST_BLT_MASK) == `INST_BLT)    : dbg_inst_str = "blt";
            ((opcode_i & `INST_BGE_MASK) == `INST_BGE)    : dbg_inst_str = "bge";
            ((opcode_i & `INST_BLTU_MASK) == `INST_BLTU)   : dbg_inst_str = "bltu";
            ((opcode_i & `INST_BGEU_MASK) == `INST_BGEU)   : dbg_inst_str = "bgeu";
            ((opcode_i & `INST_LB_MASK) == `INST_LB)     : dbg_inst_str = "lb";
            ((opcode_i & `INST_LH_MASK) == `INST_LH)     : dbg_inst_str = "lh";
            ((opcode_i & `INST_LW_MASK) == `INST_LW)     : dbg_inst_str = "lw";
            ((opcode_i & `INST_LBU_MASK) == `INST_LBU)    : dbg_inst_str = "lbu";
            ((opcode_i & `INST_LHU_MASK) == `INST_LHU)    : dbg_inst_str = "lhu";
            ((opcode_i & `INST_LWU_MASK) == `INST_LWU)    : dbg_inst_str = "lwu";
            ((opcode_i & `INST_SB_MASK) == `INST_SB)     : dbg_inst_str = "sb";
            ((opcode_i & `INST_SH_MASK) == `INST_SH)     : dbg_inst_str = "sh";
            ((opcode_i & `INST_SW_MASK) == `INST_SW)     : dbg_inst_str = "sw";
            ((opcode_i & `INST_ECALL_MASK) == `INST_ECALL)  : dbg_inst_str = "ecall";
            ((opcode_i & `INST_EBREAK_MASK) == `INST_EBREAK) : dbg_inst_str = "ebreak";
            ((opcode_i & `INST_MRET_MASK) == `INST_MRET)   : dbg_inst_str = "eret";
            ((opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW)  : dbg_inst_str = "csrrw";
            ((opcode_i & `INST_CSRRS_MASK) == `INST_CSRRS)  : dbg_inst_str = "csrrs";
            ((opcode_i & `INST_CSRRC_MASK) == `INST_CSRRC)  : dbg_inst_str = "csrrc";
            ((opcode_i & `INST_CSRRWI_MASK) == `INST_CSRRWI) : dbg_inst_str = "csrrwi";
            ((opcode_i & `INST_CSRRSI_MASK) == `INST_CSRRSI) : dbg_inst_str = "csrrsi";
            ((opcode_i & `INST_CSRRCI_MASK) == `INST_CSRRCI) : dbg_inst_str = "csrrci";
            ((opcode_i & `INST_MUL_MASK) == `INST_MUL)    : dbg_inst_str = "mul";
            ((opcode_i & `INST_MULH_MASK) == `INST_MULH)   : dbg_inst_str = "mulh";
            ((opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU) : dbg_inst_str = "mulhsu";
            ((opcode_i & `INST_MULHU_MASK) == `INST_MULHU)  : dbg_inst_str = "mulhu";
            ((opcode_i & `INST_DIV_MASK) == `INST_DIV)    : dbg_inst_str = "div";
            ((opcode_i & `INST_DIVU_MASK) == `INST_DIVU)   : dbg_inst_str = "divu";
            ((opcode_i & `INST_REM_MASK) == `INST_REM)    : dbg_inst_str = "rem";
            ((opcode_i & `INST_REMU_MASK) == `INST_REMU)   : dbg_inst_str = "remu";
            ((opcode_i & `INST_IFENCE_MASK) == `INST_IFENCE)  : dbg_inst_str = "fence.i";
        endcase

        case (1'b1)

            ((opcode_i & `INST_ADDI_MASK) == `INST_ADDI) ,  // addi
            ((opcode_i & `INST_ANDI_MASK) == `INST_ANDI) ,  // andi
            ((opcode_i & `INST_SLTI_MASK) == `INST_SLTI) ,  // slti
            ((opcode_i & `INST_SLTIU_MASK) == `INST_SLTIU) , // sltiu
            ((opcode_i & `INST_ORI_MASK) == `INST_ORI) ,   // ori
            ((opcode_i & `INST_XORI_MASK) == `INST_XORI) ,  // xori
            ((opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) , // csrrw
            ((opcode_i & `INST_CSRRS_MASK) == `INST_CSRRS) , // csrrs
            ((opcode_i & `INST_CSRRC_MASK) == `INST_CSRRC) , // csrrc
            ((opcode_i & `INST_CSRRWI_MASK) == `INST_CSRRWI) ,// csrrwi
            ((opcode_i & `INST_CSRRSI_MASK) == `INST_CSRRSI) ,// csrrsi
            ((opcode_i & `INST_CSRRCI_MASK) == `INST_CSRRCI) :// csrrci
            begin
                dbg_inst_rb  = "-";
                dbg_inst_imm = `DBG_IMM_IMM12;
            end

            ((opcode_i & `INST_SLLI_MASK) == `INST_SLLI) , // slli
            ((opcode_i & `INST_SRLI_MASK) == `INST_SRLI) , // srli
            ((opcode_i & `INST_SRAI_MASK) == `INST_SRAI) : // srai
            begin
                dbg_inst_rb  = "-";
                dbg_inst_imm = {27'b0, `DBG_IMM_SHAMT};
            end

            ((opcode_i & `INST_LUI_MASK) == `INST_LUI) : // lui
            begin
                dbg_inst_ra  = "-";
                dbg_inst_rb  = "-";
                dbg_inst_imm = `DBG_IMM_IMM20;
            end

            ((opcode_i & `INST_AUIPC_MASK) == `INST_AUIPC) : // auipc
            begin
                dbg_inst_ra  = "pc";
                dbg_inst_rb  = "-";
                dbg_inst_imm = `DBG_IMM_IMM20;
            end   

            ((opcode_i & `INST_JAL_MASK) == `INST_JAL) :  // jal
            begin
                dbg_inst_ra  = "-";
                dbg_inst_rb  = "-";
                dbg_inst_imm = pc_i + `DBG_IMM_JIMM20;

                if (rd_idx_w == 5'd1)
                    dbg_inst_str = "call";
            end

            ((opcode_i & `INST_JALR_MASK) == `INST_JALR) : // jalr
            begin
                dbg_inst_rb  = "-";
                dbg_inst_imm = `DBG_IMM_IMM12;

               if (ra_idx_w == 5'd1 && `DBG_IMM_IMM12 == 32'b0)
                    dbg_inst_str = "ret";
               else if (rd_idx_w == 5'd1)
                    dbg_inst_str = "call (R)";
            end

            // lb lh lw lbu lhu lwu
            ((opcode_i & `INST_LB_MASK) == `INST_LB) ,
            ((opcode_i & `INST_LH_MASK) == `INST_LH) ,
            ((opcode_i & `INST_LW_MASK) == `INST_LW) ,
            ((opcode_i & `INST_LBU_MASK) == `INST_LBU) ,
            ((opcode_i & `INST_LHU_MASK) == `INST_LHU) ,
            ((opcode_i & `INST_LWU_MASK) == `INST_LWU) :
            begin
                dbg_inst_rb  = "-";
                dbg_inst_imm = `DBG_IMM_IMM12;
            end 

            // sb sh sw
            ((opcode_i & `INST_SB_MASK) == `INST_SB) ,
            ((opcode_i & `INST_SH_MASK) == `INST_SH) ,
            ((opcode_i & `INST_SW_MASK) == `INST_SW) :
            begin
                dbg_inst_rd  = "-";
                dbg_inst_imm = `DBG_IMM_STOREIMM;
            end
        endcase        
    end
end
`endif

endmodule
