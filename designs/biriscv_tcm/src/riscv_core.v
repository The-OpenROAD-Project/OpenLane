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

module riscv_core
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_BRANCH_PREDICTION = 1
    ,parameter SUPPORT_MULDIV   = 1
    ,parameter SUPPORT_SUPER    = 0
    ,parameter SUPPORT_MMU      = 0
    ,parameter SUPPORT_DUAL_ISSUE = 1
    ,parameter SUPPORT_LOAD_BYPASS = 1
    ,parameter SUPPORT_MUL_BYPASS = 1
    ,parameter SUPPORT_REGFILE_XILINX = 0
    ,parameter EXTRA_DECODE_STAGE = 0
    ,parameter MEM_CACHE_ADDR_MIN = 32'h80000000
    ,parameter MEM_CACHE_ADDR_MAX = 32'h8fffffff
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
    ,input  [ 31:0]  mem_d_data_rd_i
    ,input           mem_d_accept_i
    ,input           mem_d_ack_i
    ,input           mem_d_error_i
    ,input  [ 10:0]  mem_d_resp_tag_i
    ,input           mem_i_accept_i
    ,input           mem_i_valid_i
    ,input           mem_i_error_i
    ,input  [ 63:0]  mem_i_inst_i
    ,input           intr_i
    ,input  [ 31:0]  reset_vector_i
    ,input  [ 31:0]  cpu_id_i

    // Outputs
    ,output [ 31:0]  mem_d_addr_o
    ,output [ 31:0]  mem_d_data_wr_o
    ,output          mem_d_rd_o
    ,output [  3:0]  mem_d_wr_o
    ,output          mem_d_cacheable_o
    ,output [ 10:0]  mem_d_req_tag_o
    ,output          mem_d_invalidate_o
    ,output          mem_d_writeback_o
    ,output          mem_d_flush_o
    ,output          mem_i_rd_o
    ,output          mem_i_flush_o
    ,output          mem_i_invalidate_o
    ,output [ 31:0]  mem_i_pc_o
);

wire           mmu_lsu_writeback_w;
wire  [  4:0]  csr_opcode_rd_idx_w;
wire  [  4:0]  mul_opcode_rd_idx_w;
wire           fetch1_instr_csr_w;
wire           branch_d_exec1_request_w;
wire           mmu_flush_w;
wire  [ 31:0]  lsu_opcode_pc_w;
wire  [ 31:0]  branch_exec0_source_w;
wire  [  1:0]  fetch_in_priv_w;
wire  [ 31:0]  csr_opcode_rb_operand_w;
wire  [ 31:0]  writeback_mem_value_w;
wire  [ 31:0]  writeback_div_value_w;
wire           csr_opcode_valid_w;
wire           branch_csr_request_w;
wire  [ 63:0]  mmu_ifetch_inst_w;
wire           mmu_lsu_error_w;
wire  [ 31:0]  fetch0_pc_w;
wire           branch_exec0_is_call_w;
wire           mul_opcode_valid_w;
wire           branch_exec0_request_w;
wire           mmu_mxr_w;
wire  [ 31:0]  branch_exec0_pc_w;
wire  [ 31:0]  opcode0_pc_w;
wire  [ 31:0]  opcode0_ra_operand_w;
wire           mmu_ifetch_valid_w;
wire           csr_opcode_invalid_w;
wire  [  5:0]  csr_writeback_exception_w;
wire           branch_exec1_is_call_w;
wire           branch_exec1_is_not_taken_w;
wire  [  1:0]  branch_d_exec0_priv_w;
wire           branch_exec1_is_taken_w;
wire  [  4:0]  opcode1_rd_idx_w;
wire  [ 31:0]  opcode0_rb_operand_w;
wire  [ 31:0]  fetch1_instr_w;
wire  [ 31:0]  csr_writeback_exception_addr_w;
wire           fetch1_instr_invalid_w;
wire  [  3:0]  mmu_lsu_wr_w;
wire           fetch_in_fault_w;
wire           fetch0_instr_rd_valid_w;
wire           branch_request_w;
wire  [ 31:0]  csr_opcode_pc_w;
wire           mmu_lsu_ack_w;
wire           writeback_mem_valid_w;
wire  [  5:0]  csr_result_e1_exception_w;
wire           fetch0_instr_div_w;
wire           fetch0_fault_fetch_w;
wire  [ 31:0]  branch_info_pc_w;
wire           fetch1_fault_page_w;
wire  [ 31:0]  mmu_lsu_data_wr_w;
wire  [ 10:0]  mmu_lsu_resp_tag_w;
wire  [ 10:0]  mmu_lsu_req_tag_w;
wire           fetch1_instr_div_w;
wire  [ 31:0]  branch_exec1_source_w;
wire  [ 31:0]  mul_opcode_opcode_w;
wire  [ 31:0]  branch_d_exec0_pc_w;
wire  [ 31:0]  branch_pc_w;
wire  [  4:0]  mul_opcode_ra_idx_w;
wire  [  4:0]  csr_opcode_rb_idx_w;
wire           lsu_stall_w;
wire  [ 31:0]  opcode1_pc_w;
wire           branch_info_is_not_taken_w;
wire  [ 31:0]  branch_csr_pc_w;
wire  [  4:0]  opcode0_ra_idx_w;
wire           branch_info_is_taken_w;
wire  [ 31:0]  mul_opcode_pc_w;
wire  [ 31:0]  mul_opcode_rb_operand_w;
wire           branch_info_is_ret_w;
wire           branch_exec0_is_taken_w;
wire  [ 31:0]  mul_opcode_ra_operand_w;
wire           fetch1_instr_exec_w;
wire           fetch0_instr_exec_w;
wire           exec1_hold_w;
wire           exec0_opcode_valid_w;
wire  [ 31:0]  writeback_exec1_value_w;
wire           branch_info_is_jmp_w;
wire  [ 31:0]  opcode1_rb_operand_w;
wire           fetch1_instr_lsu_w;
wire           branch_exec1_request_w;
wire           lsu_opcode_invalid_w;
wire  [ 31:0]  mmu_lsu_addr_w;
wire           mul_hold_w;
wire           mmu_ifetch_accept_w;
wire           branch_exec1_is_jmp_w;
wire           mmu_ifetch_invalidate_w;
wire  [  1:0]  branch_csr_priv_w;
wire  [ 31:0]  lsu_opcode_ra_operand_w;
wire           mmu_lsu_rd_w;
wire           fetch0_instr_mul_w;
wire           fetch0_accept_w;
wire  [  1:0]  branch_priv_w;
wire           div_opcode_valid_w;
wire           fetch0_instr_lsu_w;
wire           interrupt_inhibit_w;
wire           mmu_ifetch_error_w;
wire  [ 31:0]  branch_exec1_pc_w;
wire           fetch0_instr_csr_w;
wire  [  5:0]  writeback_mem_exception_w;
wire           fetch1_instr_branch_w;
wire           fetch0_valid_w;
wire           csr_result_e1_write_w;
wire  [ 31:0]  csr_opcode_ra_operand_w;
wire  [ 31:0]  opcode0_opcode_w;
wire  [  1:0]  branch_d_exec1_priv_w;
wire           branch_exec0_is_not_taken_w;
wire           branch_exec1_is_ret_w;
wire           writeback_div_valid_w;
wire  [ 31:0]  opcode1_ra_operand_w;
wire  [  4:0]  mul_opcode_rb_idx_w;
wire  [ 31:0]  mmu_ifetch_pc_w;
wire           mmu_ifetch_rd_w;
wire           fetch0_fault_page_w;
wire           mmu_ifetch_flush_w;
wire  [ 31:0]  opcode1_opcode_w;
wire  [  4:0]  lsu_opcode_rd_idx_w;
wire  [ 31:0]  lsu_opcode_opcode_w;
wire           mmu_load_fault_w;
wire  [ 31:0]  mmu_satp_w;
wire  [ 31:0]  csr_result_e1_wdata_w;
wire  [  4:0]  opcode1_ra_idx_w;
wire           mmu_lsu_invalidate_w;
wire  [ 31:0]  writeback_exec0_value_w;
wire  [  4:0]  csr_opcode_ra_idx_w;
wire           ifence_w;
wire           exec1_opcode_valid_w;
wire           branch_exec0_is_jmp_w;
wire  [ 31:0]  fetch1_pc_w;
wire  [ 31:0]  csr_writeback_wdata_w;
wire           fetch1_accept_w;
wire           csr_writeback_write_w;
wire           take_interrupt_w;
wire  [ 31:0]  csr_result_e1_value_w;
wire  [  4:0]  opcode1_rb_idx_w;
wire           fetch0_instr_invalid_w;
wire  [ 11:0]  csr_writeback_waddr_w;
wire           fetch1_fault_fetch_w;
wire           fetch1_valid_w;
wire  [ 31:0]  fetch0_instr_w;
wire           mmu_lsu_cacheable_w;
wire           branch_d_exec0_request_w;
wire           opcode1_invalid_w;
wire           exec0_hold_w;
wire  [  4:0]  opcode0_rb_idx_w;
wire           opcode0_invalid_w;
wire           lsu_opcode_valid_w;
wire           branch_info_request_w;
wire  [  1:0]  mmu_priv_d_w;
wire  [ 31:0]  csr_opcode_opcode_w;
wire           fetch0_instr_branch_w;
wire           mul_opcode_invalid_w;
wire           branch_exec0_is_ret_w;
wire  [ 31:0]  mmu_lsu_data_rd_w;
wire  [ 31:0]  writeback_mul_value_w;
wire           mmu_lsu_flush_w;
wire  [  4:0]  lsu_opcode_rb_idx_w;
wire           mmu_lsu_accept_w;
wire           fetch1_instr_rd_valid_w;
wire  [ 31:0]  lsu_opcode_rb_operand_w;
wire           mmu_sum_w;
wire  [ 31:0]  branch_info_source_w;
wire           branch_info_is_call_w;
wire  [  4:0]  opcode0_rd_idx_w;
wire  [ 31:0]  branch_d_exec1_pc_w;
wire  [  4:0]  lsu_opcode_ra_idx_w;
wire  [ 31:0]  csr_writeback_exception_pc_w;
wire           fetch1_instr_mul_w;
wire           mmu_store_fault_w;


biriscv_frontend
#(
     .SUPPORT_BRANCH_PREDICTION(SUPPORT_BRANCH_PREDICTION)
    ,.SUPPORT_MULDIV(SUPPORT_MULDIV)
    ,.SUPPORT_MMU(SUPPORT_MMU)
    ,.EXTRA_DECODE_STAGE(EXTRA_DECODE_STAGE)
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
u_frontend
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.icache_accept_i(mmu_ifetch_accept_w)
    ,.icache_valid_i(mmu_ifetch_valid_w)
    ,.icache_error_i(mmu_ifetch_error_w)
    ,.icache_inst_i(mmu_ifetch_inst_w)
    ,.icache_page_fault_i(fetch_in_fault_w)
    ,.fetch0_accept_i(fetch0_accept_w)
    ,.fetch1_accept_i(fetch1_accept_w)
    ,.fetch_invalidate_i(ifence_w)
    ,.branch_request_i(branch_request_w)
    ,.branch_pc_i(branch_pc_w)
    ,.branch_priv_i(branch_priv_w)
    ,.branch_info_request_i(branch_info_request_w)
    ,.branch_info_is_taken_i(branch_info_is_taken_w)
    ,.branch_info_is_not_taken_i(branch_info_is_not_taken_w)
    ,.branch_info_source_i(branch_info_source_w)
    ,.branch_info_is_call_i(branch_info_is_call_w)
    ,.branch_info_is_ret_i(branch_info_is_ret_w)
    ,.branch_info_is_jmp_i(branch_info_is_jmp_w)
    ,.branch_info_pc_i(branch_info_pc_w)

    // Outputs
    ,.icache_rd_o(mmu_ifetch_rd_w)
    ,.icache_flush_o(mmu_ifetch_flush_w)
    ,.icache_invalidate_o(mmu_ifetch_invalidate_w)
    ,.icache_pc_o(mmu_ifetch_pc_w)
    ,.icache_priv_o(fetch_in_priv_w)
    ,.fetch0_valid_o(fetch0_valid_w)
    ,.fetch0_instr_o(fetch0_instr_w)
    ,.fetch0_pc_o(fetch0_pc_w)
    ,.fetch0_fault_fetch_o(fetch0_fault_fetch_w)
    ,.fetch0_fault_page_o(fetch0_fault_page_w)
    ,.fetch0_instr_exec_o(fetch0_instr_exec_w)
    ,.fetch0_instr_lsu_o(fetch0_instr_lsu_w)
    ,.fetch0_instr_branch_o(fetch0_instr_branch_w)
    ,.fetch0_instr_mul_o(fetch0_instr_mul_w)
    ,.fetch0_instr_div_o(fetch0_instr_div_w)
    ,.fetch0_instr_csr_o(fetch0_instr_csr_w)
    ,.fetch0_instr_rd_valid_o(fetch0_instr_rd_valid_w)
    ,.fetch0_instr_invalid_o(fetch0_instr_invalid_w)
    ,.fetch1_valid_o(fetch1_valid_w)
    ,.fetch1_instr_o(fetch1_instr_w)
    ,.fetch1_pc_o(fetch1_pc_w)
    ,.fetch1_fault_fetch_o(fetch1_fault_fetch_w)
    ,.fetch1_fault_page_o(fetch1_fault_page_w)
    ,.fetch1_instr_exec_o(fetch1_instr_exec_w)
    ,.fetch1_instr_lsu_o(fetch1_instr_lsu_w)
    ,.fetch1_instr_branch_o(fetch1_instr_branch_w)
    ,.fetch1_instr_mul_o(fetch1_instr_mul_w)
    ,.fetch1_instr_div_o(fetch1_instr_div_w)
    ,.fetch1_instr_csr_o(fetch1_instr_csr_w)
    ,.fetch1_instr_rd_valid_o(fetch1_instr_rd_valid_w)
    ,.fetch1_instr_invalid_o(fetch1_instr_invalid_w)
);


biriscv_mmu
#(
     .SUPPORT_MMU(SUPPORT_MMU)
    ,.MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
    ,.MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX)
)
u_mmu
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.priv_d_i(mmu_priv_d_w)
    ,.sum_i(mmu_sum_w)
    ,.mxr_i(mmu_mxr_w)
    ,.flush_i(mmu_flush_w)
    ,.satp_i(mmu_satp_w)
    ,.fetch_in_rd_i(mmu_ifetch_rd_w)
    ,.fetch_in_flush_i(mmu_ifetch_flush_w)
    ,.fetch_in_invalidate_i(mmu_ifetch_invalidate_w)
    ,.fetch_in_pc_i(mmu_ifetch_pc_w)
    ,.fetch_in_priv_i(fetch_in_priv_w)
    ,.fetch_out_accept_i(mem_i_accept_i)
    ,.fetch_out_valid_i(mem_i_valid_i)
    ,.fetch_out_error_i(mem_i_error_i)
    ,.fetch_out_inst_i(mem_i_inst_i)
    ,.lsu_in_addr_i(mmu_lsu_addr_w)
    ,.lsu_in_data_wr_i(mmu_lsu_data_wr_w)
    ,.lsu_in_rd_i(mmu_lsu_rd_w)
    ,.lsu_in_wr_i(mmu_lsu_wr_w)
    ,.lsu_in_cacheable_i(mmu_lsu_cacheable_w)
    ,.lsu_in_req_tag_i(mmu_lsu_req_tag_w)
    ,.lsu_in_invalidate_i(mmu_lsu_invalidate_w)
    ,.lsu_in_writeback_i(mmu_lsu_writeback_w)
    ,.lsu_in_flush_i(mmu_lsu_flush_w)
    ,.lsu_out_data_rd_i(mem_d_data_rd_i)
    ,.lsu_out_accept_i(mem_d_accept_i)
    ,.lsu_out_ack_i(mem_d_ack_i)
    ,.lsu_out_error_i(mem_d_error_i)
    ,.lsu_out_resp_tag_i(mem_d_resp_tag_i)

    // Outputs
    ,.fetch_in_accept_o(mmu_ifetch_accept_w)
    ,.fetch_in_valid_o(mmu_ifetch_valid_w)
    ,.fetch_in_error_o(mmu_ifetch_error_w)
    ,.fetch_in_inst_o(mmu_ifetch_inst_w)
    ,.fetch_out_rd_o(mem_i_rd_o)
    ,.fetch_out_flush_o(mem_i_flush_o)
    ,.fetch_out_invalidate_o(mem_i_invalidate_o)
    ,.fetch_out_pc_o(mem_i_pc_o)
    ,.fetch_in_fault_o(fetch_in_fault_w)
    ,.lsu_in_data_rd_o(mmu_lsu_data_rd_w)
    ,.lsu_in_accept_o(mmu_lsu_accept_w)
    ,.lsu_in_ack_o(mmu_lsu_ack_w)
    ,.lsu_in_error_o(mmu_lsu_error_w)
    ,.lsu_in_resp_tag_o(mmu_lsu_resp_tag_w)
    ,.lsu_out_addr_o(mem_d_addr_o)
    ,.lsu_out_data_wr_o(mem_d_data_wr_o)
    ,.lsu_out_rd_o(mem_d_rd_o)
    ,.lsu_out_wr_o(mem_d_wr_o)
    ,.lsu_out_cacheable_o(mem_d_cacheable_o)
    ,.lsu_out_req_tag_o(mem_d_req_tag_o)
    ,.lsu_out_invalidate_o(mem_d_invalidate_o)
    ,.lsu_out_writeback_o(mem_d_writeback_o)
    ,.lsu_out_flush_o(mem_d_flush_o)
    ,.lsu_in_load_fault_o(mmu_load_fault_w)
    ,.lsu_in_store_fault_o(mmu_store_fault_w)
);


biriscv_lsu
#(
     .MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
    ,.MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX)
)
u_lsu
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.opcode_valid_i(lsu_opcode_valid_w)
    ,.opcode_opcode_i(lsu_opcode_opcode_w)
    ,.opcode_pc_i(lsu_opcode_pc_w)
    ,.opcode_invalid_i(lsu_opcode_invalid_w)
    ,.opcode_rd_idx_i(lsu_opcode_rd_idx_w)
    ,.opcode_ra_idx_i(lsu_opcode_ra_idx_w)
    ,.opcode_rb_idx_i(lsu_opcode_rb_idx_w)
    ,.opcode_ra_operand_i(lsu_opcode_ra_operand_w)
    ,.opcode_rb_operand_i(lsu_opcode_rb_operand_w)
    ,.mem_data_rd_i(mmu_lsu_data_rd_w)
    ,.mem_accept_i(mmu_lsu_accept_w)
    ,.mem_ack_i(mmu_lsu_ack_w)
    ,.mem_error_i(mmu_lsu_error_w)
    ,.mem_resp_tag_i(mmu_lsu_resp_tag_w)
    ,.mem_load_fault_i(mmu_load_fault_w)
    ,.mem_store_fault_i(mmu_store_fault_w)

    // Outputs
    ,.mem_addr_o(mmu_lsu_addr_w)
    ,.mem_data_wr_o(mmu_lsu_data_wr_w)
    ,.mem_rd_o(mmu_lsu_rd_w)
    ,.mem_wr_o(mmu_lsu_wr_w)
    ,.mem_cacheable_o(mmu_lsu_cacheable_w)
    ,.mem_req_tag_o(mmu_lsu_req_tag_w)
    ,.mem_invalidate_o(mmu_lsu_invalidate_w)
    ,.mem_writeback_o(mmu_lsu_writeback_w)
    ,.mem_flush_o(mmu_lsu_flush_w)
    ,.writeback_valid_o(writeback_mem_valid_w)
    ,.writeback_value_o(writeback_mem_value_w)
    ,.writeback_exception_o(writeback_mem_exception_w)
    ,.stall_o(lsu_stall_w)
);


biriscv_csr
#(
     .SUPPORT_MULDIV(SUPPORT_MULDIV)
    ,.SUPPORT_SUPER(SUPPORT_SUPER)
)
u_csr
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.intr_i(intr_i)
    ,.opcode_valid_i(csr_opcode_valid_w)
    ,.opcode_opcode_i(csr_opcode_opcode_w)
    ,.opcode_pc_i(csr_opcode_pc_w)
    ,.opcode_invalid_i(csr_opcode_invalid_w)
    ,.opcode_rd_idx_i(csr_opcode_rd_idx_w)
    ,.opcode_ra_idx_i(csr_opcode_ra_idx_w)
    ,.opcode_rb_idx_i(csr_opcode_rb_idx_w)
    ,.opcode_ra_operand_i(csr_opcode_ra_operand_w)
    ,.opcode_rb_operand_i(csr_opcode_rb_operand_w)
    ,.csr_writeback_write_i(csr_writeback_write_w)
    ,.csr_writeback_waddr_i(csr_writeback_waddr_w)
    ,.csr_writeback_wdata_i(csr_writeback_wdata_w)
    ,.csr_writeback_exception_i(csr_writeback_exception_w)
    ,.csr_writeback_exception_pc_i(csr_writeback_exception_pc_w)
    ,.csr_writeback_exception_addr_i(csr_writeback_exception_addr_w)
    ,.cpu_id_i(cpu_id_i)
    ,.reset_vector_i(reset_vector_i)
    ,.interrupt_inhibit_i(interrupt_inhibit_w)

    // Outputs
    ,.csr_result_e1_value_o(csr_result_e1_value_w)
    ,.csr_result_e1_write_o(csr_result_e1_write_w)
    ,.csr_result_e1_wdata_o(csr_result_e1_wdata_w)
    ,.csr_result_e1_exception_o(csr_result_e1_exception_w)
    ,.branch_csr_request_o(branch_csr_request_w)
    ,.branch_csr_pc_o(branch_csr_pc_w)
    ,.branch_csr_priv_o(branch_csr_priv_w)
    ,.take_interrupt_o(take_interrupt_w)
    ,.ifence_o(ifence_w)
    ,.mmu_priv_d_o(mmu_priv_d_w)
    ,.mmu_sum_o(mmu_sum_w)
    ,.mmu_mxr_o(mmu_mxr_w)
    ,.mmu_flush_o(mmu_flush_w)
    ,.mmu_satp_o(mmu_satp_w)
);


biriscv_multiplier
u_mul
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.opcode_valid_i(mul_opcode_valid_w)
    ,.opcode_opcode_i(mul_opcode_opcode_w)
    ,.opcode_pc_i(mul_opcode_pc_w)
    ,.opcode_invalid_i(mul_opcode_invalid_w)
    ,.opcode_rd_idx_i(mul_opcode_rd_idx_w)
    ,.opcode_ra_idx_i(mul_opcode_ra_idx_w)
    ,.opcode_rb_idx_i(mul_opcode_rb_idx_w)
    ,.opcode_ra_operand_i(mul_opcode_ra_operand_w)
    ,.opcode_rb_operand_i(mul_opcode_rb_operand_w)
    ,.hold_i(mul_hold_w)

    // Outputs
    ,.writeback_value_o(writeback_mul_value_w)
);


biriscv_divider
u_div
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.opcode_valid_i(div_opcode_valid_w)
    ,.opcode_opcode_i(opcode0_opcode_w)
    ,.opcode_pc_i(opcode0_pc_w)
    ,.opcode_invalid_i(opcode0_invalid_w)
    ,.opcode_rd_idx_i(opcode0_rd_idx_w)
    ,.opcode_ra_idx_i(opcode0_ra_idx_w)
    ,.opcode_rb_idx_i(opcode0_rb_idx_w)
    ,.opcode_ra_operand_i(opcode0_ra_operand_w)
    ,.opcode_rb_operand_i(opcode0_rb_operand_w)

    // Outputs
    ,.writeback_valid_o(writeback_div_valid_w)
    ,.writeback_value_o(writeback_div_value_w)
);


biriscv_issue
#(
     .SUPPORT_MULDIV(SUPPORT_MULDIV)
    ,.SUPPORT_DUAL_ISSUE(SUPPORT_DUAL_ISSUE)
    ,.SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS)
    ,.SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
    ,.SUPPORT_REGFILE_XILINX(SUPPORT_REGFILE_XILINX)
)
u_issue
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.fetch0_valid_i(fetch0_valid_w)
    ,.fetch0_instr_i(fetch0_instr_w)
    ,.fetch0_pc_i(fetch0_pc_w)
    ,.fetch0_fault_fetch_i(fetch0_fault_fetch_w)
    ,.fetch0_fault_page_i(fetch0_fault_page_w)
    ,.fetch0_instr_exec_i(fetch0_instr_exec_w)
    ,.fetch0_instr_lsu_i(fetch0_instr_lsu_w)
    ,.fetch0_instr_branch_i(fetch0_instr_branch_w)
    ,.fetch0_instr_mul_i(fetch0_instr_mul_w)
    ,.fetch0_instr_div_i(fetch0_instr_div_w)
    ,.fetch0_instr_csr_i(fetch0_instr_csr_w)
    ,.fetch0_instr_rd_valid_i(fetch0_instr_rd_valid_w)
    ,.fetch0_instr_invalid_i(fetch0_instr_invalid_w)
    ,.fetch1_valid_i(fetch1_valid_w)
    ,.fetch1_instr_i(fetch1_instr_w)
    ,.fetch1_pc_i(fetch1_pc_w)
    ,.fetch1_fault_fetch_i(fetch1_fault_fetch_w)
    ,.fetch1_fault_page_i(fetch1_fault_page_w)
    ,.fetch1_instr_exec_i(fetch1_instr_exec_w)
    ,.fetch1_instr_lsu_i(fetch1_instr_lsu_w)
    ,.fetch1_instr_branch_i(fetch1_instr_branch_w)
    ,.fetch1_instr_mul_i(fetch1_instr_mul_w)
    ,.fetch1_instr_div_i(fetch1_instr_div_w)
    ,.fetch1_instr_csr_i(fetch1_instr_csr_w)
    ,.fetch1_instr_rd_valid_i(fetch1_instr_rd_valid_w)
    ,.fetch1_instr_invalid_i(fetch1_instr_invalid_w)
    ,.branch_exec0_request_i(branch_exec0_request_w)
    ,.branch_exec0_is_taken_i(branch_exec0_is_taken_w)
    ,.branch_exec0_is_not_taken_i(branch_exec0_is_not_taken_w)
    ,.branch_exec0_source_i(branch_exec0_source_w)
    ,.branch_exec0_is_call_i(branch_exec0_is_call_w)
    ,.branch_exec0_is_ret_i(branch_exec0_is_ret_w)
    ,.branch_exec0_is_jmp_i(branch_exec0_is_jmp_w)
    ,.branch_exec0_pc_i(branch_exec0_pc_w)
    ,.branch_d_exec0_request_i(branch_d_exec0_request_w)
    ,.branch_d_exec0_pc_i(branch_d_exec0_pc_w)
    ,.branch_d_exec0_priv_i(branch_d_exec0_priv_w)
    ,.branch_exec1_request_i(branch_exec1_request_w)
    ,.branch_exec1_is_taken_i(branch_exec1_is_taken_w)
    ,.branch_exec1_is_not_taken_i(branch_exec1_is_not_taken_w)
    ,.branch_exec1_source_i(branch_exec1_source_w)
    ,.branch_exec1_is_call_i(branch_exec1_is_call_w)
    ,.branch_exec1_is_ret_i(branch_exec1_is_ret_w)
    ,.branch_exec1_is_jmp_i(branch_exec1_is_jmp_w)
    ,.branch_exec1_pc_i(branch_exec1_pc_w)
    ,.branch_d_exec1_request_i(branch_d_exec1_request_w)
    ,.branch_d_exec1_pc_i(branch_d_exec1_pc_w)
    ,.branch_d_exec1_priv_i(branch_d_exec1_priv_w)
    ,.branch_csr_request_i(branch_csr_request_w)
    ,.branch_csr_pc_i(branch_csr_pc_w)
    ,.branch_csr_priv_i(branch_csr_priv_w)
    ,.writeback_exec0_value_i(writeback_exec0_value_w)
    ,.writeback_exec1_value_i(writeback_exec1_value_w)
    ,.writeback_mem_valid_i(writeback_mem_valid_w)
    ,.writeback_mem_value_i(writeback_mem_value_w)
    ,.writeback_mem_exception_i(writeback_mem_exception_w)
    ,.writeback_mul_value_i(writeback_mul_value_w)
    ,.writeback_div_valid_i(writeback_div_valid_w)
    ,.writeback_div_value_i(writeback_div_value_w)
    ,.csr_result_e1_value_i(csr_result_e1_value_w)
    ,.csr_result_e1_write_i(csr_result_e1_write_w)
    ,.csr_result_e1_wdata_i(csr_result_e1_wdata_w)
    ,.csr_result_e1_exception_i(csr_result_e1_exception_w)
    ,.lsu_stall_i(lsu_stall_w)
    ,.take_interrupt_i(take_interrupt_w)

    // Outputs
    ,.fetch0_accept_o(fetch0_accept_w)
    ,.fetch1_accept_o(fetch1_accept_w)
    ,.branch_request_o(branch_request_w)
    ,.branch_pc_o(branch_pc_w)
    ,.branch_priv_o(branch_priv_w)
    ,.branch_info_request_o(branch_info_request_w)
    ,.branch_info_is_taken_o(branch_info_is_taken_w)
    ,.branch_info_is_not_taken_o(branch_info_is_not_taken_w)
    ,.branch_info_source_o(branch_info_source_w)
    ,.branch_info_is_call_o(branch_info_is_call_w)
    ,.branch_info_is_ret_o(branch_info_is_ret_w)
    ,.branch_info_is_jmp_o(branch_info_is_jmp_w)
    ,.branch_info_pc_o(branch_info_pc_w)
    ,.exec0_opcode_valid_o(exec0_opcode_valid_w)
    ,.exec1_opcode_valid_o(exec1_opcode_valid_w)
    ,.lsu_opcode_valid_o(lsu_opcode_valid_w)
    ,.csr_opcode_valid_o(csr_opcode_valid_w)
    ,.mul_opcode_valid_o(mul_opcode_valid_w)
    ,.div_opcode_valid_o(div_opcode_valid_w)
    ,.opcode0_opcode_o(opcode0_opcode_w)
    ,.opcode0_pc_o(opcode0_pc_w)
    ,.opcode0_invalid_o(opcode0_invalid_w)
    ,.opcode0_rd_idx_o(opcode0_rd_idx_w)
    ,.opcode0_ra_idx_o(opcode0_ra_idx_w)
    ,.opcode0_rb_idx_o(opcode0_rb_idx_w)
    ,.opcode0_ra_operand_o(opcode0_ra_operand_w)
    ,.opcode0_rb_operand_o(opcode0_rb_operand_w)
    ,.opcode1_opcode_o(opcode1_opcode_w)
    ,.opcode1_pc_o(opcode1_pc_w)
    ,.opcode1_invalid_o(opcode1_invalid_w)
    ,.opcode1_rd_idx_o(opcode1_rd_idx_w)
    ,.opcode1_ra_idx_o(opcode1_ra_idx_w)
    ,.opcode1_rb_idx_o(opcode1_rb_idx_w)
    ,.opcode1_ra_operand_o(opcode1_ra_operand_w)
    ,.opcode1_rb_operand_o(opcode1_rb_operand_w)
    ,.lsu_opcode_opcode_o(lsu_opcode_opcode_w)
    ,.lsu_opcode_pc_o(lsu_opcode_pc_w)
    ,.lsu_opcode_invalid_o(lsu_opcode_invalid_w)
    ,.lsu_opcode_rd_idx_o(lsu_opcode_rd_idx_w)
    ,.lsu_opcode_ra_idx_o(lsu_opcode_ra_idx_w)
    ,.lsu_opcode_rb_idx_o(lsu_opcode_rb_idx_w)
    ,.lsu_opcode_ra_operand_o(lsu_opcode_ra_operand_w)
    ,.lsu_opcode_rb_operand_o(lsu_opcode_rb_operand_w)
    ,.mul_opcode_opcode_o(mul_opcode_opcode_w)
    ,.mul_opcode_pc_o(mul_opcode_pc_w)
    ,.mul_opcode_invalid_o(mul_opcode_invalid_w)
    ,.mul_opcode_rd_idx_o(mul_opcode_rd_idx_w)
    ,.mul_opcode_ra_idx_o(mul_opcode_ra_idx_w)
    ,.mul_opcode_rb_idx_o(mul_opcode_rb_idx_w)
    ,.mul_opcode_ra_operand_o(mul_opcode_ra_operand_w)
    ,.mul_opcode_rb_operand_o(mul_opcode_rb_operand_w)
    ,.csr_opcode_opcode_o(csr_opcode_opcode_w)
    ,.csr_opcode_pc_o(csr_opcode_pc_w)
    ,.csr_opcode_invalid_o(csr_opcode_invalid_w)
    ,.csr_opcode_rd_idx_o(csr_opcode_rd_idx_w)
    ,.csr_opcode_ra_idx_o(csr_opcode_ra_idx_w)
    ,.csr_opcode_rb_idx_o(csr_opcode_rb_idx_w)
    ,.csr_opcode_ra_operand_o(csr_opcode_ra_operand_w)
    ,.csr_opcode_rb_operand_o(csr_opcode_rb_operand_w)
    ,.csr_writeback_write_o(csr_writeback_write_w)
    ,.csr_writeback_waddr_o(csr_writeback_waddr_w)
    ,.csr_writeback_wdata_o(csr_writeback_wdata_w)
    ,.csr_writeback_exception_o(csr_writeback_exception_w)
    ,.csr_writeback_exception_pc_o(csr_writeback_exception_pc_w)
    ,.csr_writeback_exception_addr_o(csr_writeback_exception_addr_w)
    ,.exec0_hold_o(exec0_hold_w)
    ,.exec1_hold_o(exec1_hold_w)
    ,.mul_hold_o(mul_hold_w)
    ,.interrupt_inhibit_o(interrupt_inhibit_w)
);


biriscv_exec
u_exec0
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.opcode_valid_i(exec0_opcode_valid_w)
    ,.opcode_opcode_i(opcode0_opcode_w)
    ,.opcode_pc_i(opcode0_pc_w)
    ,.opcode_invalid_i(opcode0_invalid_w)
    ,.opcode_rd_idx_i(opcode0_rd_idx_w)
    ,.opcode_ra_idx_i(opcode0_ra_idx_w)
    ,.opcode_rb_idx_i(opcode0_rb_idx_w)
    ,.opcode_ra_operand_i(opcode0_ra_operand_w)
    ,.opcode_rb_operand_i(opcode0_rb_operand_w)
    ,.hold_i(exec0_hold_w)

    // Outputs
    ,.branch_request_o(branch_exec0_request_w)
    ,.branch_is_taken_o(branch_exec0_is_taken_w)
    ,.branch_is_not_taken_o(branch_exec0_is_not_taken_w)
    ,.branch_source_o(branch_exec0_source_w)
    ,.branch_is_call_o(branch_exec0_is_call_w)
    ,.branch_is_ret_o(branch_exec0_is_ret_w)
    ,.branch_is_jmp_o(branch_exec0_is_jmp_w)
    ,.branch_pc_o(branch_exec0_pc_w)
    ,.branch_d_request_o(branch_d_exec0_request_w)
    ,.branch_d_pc_o(branch_d_exec0_pc_w)
    ,.branch_d_priv_o(branch_d_exec0_priv_w)
    ,.writeback_value_o(writeback_exec0_value_w)
);


biriscv_exec
u_exec1
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.opcode_valid_i(exec1_opcode_valid_w)
    ,.opcode_opcode_i(opcode1_opcode_w)
    ,.opcode_pc_i(opcode1_pc_w)
    ,.opcode_invalid_i(opcode1_invalid_w)
    ,.opcode_rd_idx_i(opcode1_rd_idx_w)
    ,.opcode_ra_idx_i(opcode1_ra_idx_w)
    ,.opcode_rb_idx_i(opcode1_rb_idx_w)
    ,.opcode_ra_operand_i(opcode1_ra_operand_w)
    ,.opcode_rb_operand_i(opcode1_rb_operand_w)
    ,.hold_i(exec1_hold_w)

    // Outputs
    ,.branch_request_o(branch_exec1_request_w)
    ,.branch_is_taken_o(branch_exec1_is_taken_w)
    ,.branch_is_not_taken_o(branch_exec1_is_not_taken_w)
    ,.branch_source_o(branch_exec1_source_w)
    ,.branch_is_call_o(branch_exec1_is_call_w)
    ,.branch_is_ret_o(branch_exec1_is_ret_w)
    ,.branch_is_jmp_o(branch_exec1_is_jmp_w)
    ,.branch_pc_o(branch_exec1_pc_w)
    ,.branch_d_request_o(branch_d_exec1_request_w)
    ,.branch_d_pc_o(branch_d_exec1_pc_w)
    ,.branch_d_priv_o(branch_d_exec1_priv_w)
    ,.writeback_value_o(writeback_exec1_value_w)
);



endmodule
