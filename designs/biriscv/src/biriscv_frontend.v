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

module biriscv_frontend
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_BRANCH_PREDICTION = 1
    ,parameter SUPPORT_MULDIV   = 1
    ,parameter SUPPORT_MMU      = 1
    ,parameter EXTRA_DECODE_STAGE = 0
    ,parameter NUM_BTB_ENTRIES  = 32
    ,parameter NUM_BTB_ENTRIES_W = 5
    ,parameter NUM_BHT_ENTRIES  = 512
    ,parameter NUM_BHT_ENTRIES_W = 9
    ,parameter RAS_ENABLE       = 1
    ,parameter GSHARE_ENABLE    = 0
    ,parameter BHT_ENABLE       = 1
    ,parameter NUM_RAS_ENTRIES  = 8
    ,parameter NUM_RAS_ENTRIES_W = 3
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           icache_accept_i
    ,input           icache_valid_i
    ,input           icache_error_i
    ,input  [ 63:0]  icache_inst_i
    ,input           icache_page_fault_i
    ,input           fetch0_accept_i
    ,input           fetch1_accept_i
    ,input           fetch_invalidate_i
    ,input           branch_request_i
    ,input  [ 31:0]  branch_pc_i
    ,input  [  1:0]  branch_priv_i
    ,input           branch_info_request_i
    ,input           branch_info_is_taken_i
    ,input           branch_info_is_not_taken_i
    ,input  [ 31:0]  branch_info_source_i
    ,input           branch_info_is_call_i
    ,input           branch_info_is_ret_i
    ,input           branch_info_is_jmp_i
    ,input  [ 31:0]  branch_info_pc_i

    // Outputs
    ,output          icache_rd_o
    ,output          icache_flush_o
    ,output          icache_invalidate_o
    ,output [ 31:0]  icache_pc_o
    ,output [  1:0]  icache_priv_o
    ,output          fetch0_valid_o
    ,output [ 31:0]  fetch0_instr_o
    ,output [ 31:0]  fetch0_pc_o
    ,output          fetch0_fault_fetch_o
    ,output          fetch0_fault_page_o
    ,output          fetch0_instr_exec_o
    ,output          fetch0_instr_lsu_o
    ,output          fetch0_instr_branch_o
    ,output          fetch0_instr_mul_o
    ,output          fetch0_instr_div_o
    ,output          fetch0_instr_csr_o
    ,output          fetch0_instr_rd_valid_o
    ,output          fetch0_instr_invalid_o
    ,output          fetch1_valid_o
    ,output [ 31:0]  fetch1_instr_o
    ,output [ 31:0]  fetch1_pc_o
    ,output          fetch1_fault_fetch_o
    ,output          fetch1_fault_page_o
    ,output          fetch1_instr_exec_o
    ,output          fetch1_instr_lsu_o
    ,output          fetch1_instr_branch_o
    ,output          fetch1_instr_mul_o
    ,output          fetch1_instr_div_o
    ,output          fetch1_instr_csr_o
    ,output          fetch1_instr_rd_valid_o
    ,output          fetch1_instr_invalid_o
);

wire           fetch_valid_w;
wire  [ 63:0]  fetch_instr_w;
wire           fetch_fault_page_w;
wire  [ 31:0]  next_pc_f_w;
wire  [  1:0]  next_taken_f_w;
wire  [ 31:0]  fetch_pc_f_w;
wire           fetch_accept_w;
wire  [  1:0]  fetch_pred_branch_w;
wire  [ 31:0]  fetch_pc_w;
wire           fetch_fault_fetch_w;
wire           fetch_pc_accept_w;


biriscv_npc
#(
     .SUPPORT_BRANCH_PREDICTION(SUPPORT_BRANCH_PREDICTION)
    ,.NUM_BTB_ENTRIES(NUM_BTB_ENTRIES)
    ,.NUM_BTB_ENTRIES_W(NUM_BTB_ENTRIES_W)
    ,.NUM_BHT_ENTRIES(NUM_BHT_ENTRIES)
    ,.NUM_BHT_ENTRIES_W(NUM_BHT_ENTRIES_W)
    ,.RAS_ENABLE(RAS_ENABLE)
    ,.GSHARE_ENABLE(GSHARE_ENABLE)
    ,.BHT_ENABLE(BHT_ENABLE)
    ,.NUM_RAS_ENTRIES(NUM_RAS_ENTRIES)
    ,.NUM_RAS_ENTRIES_W(NUM_RAS_ENTRIES_W)
)
u_npc
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.invalidate_i(1'b0)
    ,.branch_request_i(branch_info_request_i)
    ,.branch_is_taken_i(branch_info_is_taken_i)
    ,.branch_is_not_taken_i(branch_info_is_not_taken_i)
    ,.branch_source_i(branch_info_source_i)
    ,.branch_is_call_i(branch_info_is_call_i)
    ,.branch_is_ret_i(branch_info_is_ret_i)
    ,.branch_is_jmp_i(branch_info_is_jmp_i)
    ,.branch_pc_i(branch_info_pc_i)
    ,.pc_f_i(fetch_pc_f_w)
    ,.pc_accept_i(fetch_pc_accept_w)

    // Outputs
    ,.next_pc_f_o(next_pc_f_w)
    ,.next_taken_f_o(next_taken_f_w)
);


biriscv_decode
#(
     .SUPPORT_MULDIV(SUPPORT_MULDIV)
    ,.EXTRA_DECODE_STAGE(EXTRA_DECODE_STAGE)
)
u_decode
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.fetch_in_valid_i(fetch_valid_w)
    ,.fetch_in_instr_i(fetch_instr_w)
    ,.fetch_in_pred_branch_i(fetch_pred_branch_w)
    ,.fetch_in_fault_fetch_i(fetch_fault_fetch_w)
    ,.fetch_in_fault_page_i(fetch_fault_page_w)
    ,.fetch_in_pc_i(fetch_pc_w)
    ,.fetch_out0_accept_i(fetch0_accept_i)
    ,.fetch_out1_accept_i(fetch1_accept_i)
    ,.branch_request_i(branch_request_i)
    ,.branch_pc_i(branch_pc_i)
    ,.branch_priv_i(branch_priv_i)

    // Outputs
    ,.fetch_in_accept_o(fetch_accept_w)
    ,.fetch_out0_valid_o(fetch0_valid_o)
    ,.fetch_out0_instr_o(fetch0_instr_o)
    ,.fetch_out0_pc_o(fetch0_pc_o)
    ,.fetch_out0_fault_fetch_o(fetch0_fault_fetch_o)
    ,.fetch_out0_fault_page_o(fetch0_fault_page_o)
    ,.fetch_out0_instr_exec_o(fetch0_instr_exec_o)
    ,.fetch_out0_instr_lsu_o(fetch0_instr_lsu_o)
    ,.fetch_out0_instr_branch_o(fetch0_instr_branch_o)
    ,.fetch_out0_instr_mul_o(fetch0_instr_mul_o)
    ,.fetch_out0_instr_div_o(fetch0_instr_div_o)
    ,.fetch_out0_instr_csr_o(fetch0_instr_csr_o)
    ,.fetch_out0_instr_rd_valid_o(fetch0_instr_rd_valid_o)
    ,.fetch_out0_instr_invalid_o(fetch0_instr_invalid_o)
    ,.fetch_out1_valid_o(fetch1_valid_o)
    ,.fetch_out1_instr_o(fetch1_instr_o)
    ,.fetch_out1_pc_o(fetch1_pc_o)
    ,.fetch_out1_fault_fetch_o(fetch1_fault_fetch_o)
    ,.fetch_out1_fault_page_o(fetch1_fault_page_o)
    ,.fetch_out1_instr_exec_o(fetch1_instr_exec_o)
    ,.fetch_out1_instr_lsu_o(fetch1_instr_lsu_o)
    ,.fetch_out1_instr_branch_o(fetch1_instr_branch_o)
    ,.fetch_out1_instr_mul_o(fetch1_instr_mul_o)
    ,.fetch_out1_instr_div_o(fetch1_instr_div_o)
    ,.fetch_out1_instr_csr_o(fetch1_instr_csr_o)
    ,.fetch_out1_instr_rd_valid_o(fetch1_instr_rd_valid_o)
    ,.fetch_out1_instr_invalid_o(fetch1_instr_invalid_o)
);


biriscv_fetch
#(
     .SUPPORT_MMU(SUPPORT_MMU)
)
u_fetch
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.fetch_accept_i(fetch_accept_w)
    ,.icache_accept_i(icache_accept_i)
    ,.icache_valid_i(icache_valid_i)
    ,.icache_error_i(icache_error_i)
    ,.icache_inst_i(icache_inst_i)
    ,.icache_page_fault_i(icache_page_fault_i)
    ,.fetch_invalidate_i(fetch_invalidate_i)
    ,.branch_request_i(branch_request_i)
    ,.branch_pc_i(branch_pc_i)
    ,.branch_priv_i(branch_priv_i)
    ,.next_pc_f_i(next_pc_f_w)
    ,.next_taken_f_i(next_taken_f_w)

    // Outputs
    ,.fetch_valid_o(fetch_valid_w)
    ,.fetch_instr_o(fetch_instr_w)
    ,.fetch_pred_branch_o(fetch_pred_branch_w)
    ,.fetch_fault_fetch_o(fetch_fault_fetch_w)
    ,.fetch_fault_page_o(fetch_fault_page_w)
    ,.fetch_pc_o(fetch_pc_w)
    ,.icache_rd_o(icache_rd_o)
    ,.icache_flush_o(icache_flush_o)
    ,.icache_invalidate_o(icache_invalidate_o)
    ,.icache_pc_o(icache_pc_o)
    ,.icache_priv_o(icache_priv_o)
    ,.pc_f_o(fetch_pc_f_w)
    ,.pc_accept_o(fetch_pc_accept_w)
);



endmodule
