//-----------------------------------------------------------------
//                         biRISC-V CPU
//                            V0.6.0
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

module dport_mux
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter TCM_MEM_BASE     = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [ 31:0]  mem_addr_i
    ,input  [ 31:0]  mem_data_wr_i
    ,input           mem_rd_i
    ,input  [  3:0]  mem_wr_i
    ,input           mem_cacheable_i
    ,input  [ 10:0]  mem_req_tag_i
    ,input           mem_invalidate_i
    ,input           mem_writeback_i
    ,input           mem_flush_i
    ,input  [ 31:0]  mem_tcm_data_rd_i
    ,input           mem_tcm_accept_i
    ,input           mem_tcm_ack_i
    ,input           mem_tcm_error_i
    ,input  [ 10:0]  mem_tcm_resp_tag_i
    ,input  [ 31:0]  mem_ext_data_rd_i
    ,input           mem_ext_accept_i
    ,input           mem_ext_ack_i
    ,input           mem_ext_error_i
    ,input  [ 10:0]  mem_ext_resp_tag_i

    // Outputs
    ,output [ 31:0]  mem_data_rd_o
    ,output          mem_accept_o
    ,output          mem_ack_o
    ,output          mem_error_o
    ,output [ 10:0]  mem_resp_tag_o
    ,output [ 31:0]  mem_tcm_addr_o
    ,output [ 31:0]  mem_tcm_data_wr_o
    ,output          mem_tcm_rd_o
    ,output [  3:0]  mem_tcm_wr_o
    ,output          mem_tcm_cacheable_o
    ,output [ 10:0]  mem_tcm_req_tag_o
    ,output          mem_tcm_invalidate_o
    ,output          mem_tcm_writeback_o
    ,output          mem_tcm_flush_o
    ,output [ 31:0]  mem_ext_addr_o
    ,output [ 31:0]  mem_ext_data_wr_o
    ,output          mem_ext_rd_o
    ,output [  3:0]  mem_ext_wr_o
    ,output          mem_ext_cacheable_o
    ,output [ 10:0]  mem_ext_req_tag_o
    ,output          mem_ext_invalidate_o
    ,output          mem_ext_writeback_o
    ,output          mem_ext_flush_o
);



//-----------------------------------------------------------------
// Dcache_if mux
//-----------------------------------------------------------------
wire hold_w;

/* verilator lint_off UNSIGNED */
wire tcm_access_w = (mem_addr_i >= TCM_MEM_BASE && mem_addr_i < (TCM_MEM_BASE + 32'd65536));
/* verilator lint_on UNSIGNED */

reg       tcm_access_q;
reg [4:0] pending_q;

assign mem_tcm_addr_o       = mem_addr_i;
assign mem_tcm_data_wr_o    = mem_data_wr_i;
assign mem_tcm_rd_o         = (tcm_access_w & ~hold_w) ? mem_rd_i : 1'b0;
assign mem_tcm_wr_o         = (tcm_access_w & ~hold_w) ? mem_wr_i : 4'b0;
assign mem_tcm_cacheable_o  = mem_cacheable_i;
assign mem_tcm_req_tag_o    = mem_req_tag_i;
assign mem_tcm_invalidate_o = (tcm_access_w & ~hold_w) ? mem_invalidate_i : 1'b0;
assign mem_tcm_writeback_o  = (tcm_access_w & ~hold_w) ? mem_writeback_i : 1'b0;
assign mem_tcm_flush_o      = (tcm_access_w & ~hold_w) ? mem_flush_i : 1'b0;

assign mem_ext_addr_o       = mem_addr_i;
assign mem_ext_data_wr_o    = mem_data_wr_i;
assign mem_ext_rd_o         = (~tcm_access_w & ~hold_w) ? mem_rd_i : 1'b0;
assign mem_ext_wr_o         = (~tcm_access_w & ~hold_w) ? mem_wr_i : 4'b0;
assign mem_ext_cacheable_o  = mem_cacheable_i;
assign mem_ext_req_tag_o    = mem_req_tag_i;
assign mem_ext_invalidate_o = (~tcm_access_w & ~hold_w) ? mem_invalidate_i : 1'b0;
assign mem_ext_writeback_o  = (~tcm_access_w & ~hold_w) ? mem_writeback_i : 1'b0;
assign mem_ext_flush_o      = (~tcm_access_w & ~hold_w) ? mem_flush_i : 1'b0;

assign mem_accept_o         =(tcm_access_w ? mem_tcm_accept_i   : mem_ext_accept_i) & !hold_w;
assign mem_data_rd_o        = tcm_access_q ? mem_tcm_data_rd_i  : mem_ext_data_rd_i;
assign mem_ack_o            = tcm_access_q ? mem_tcm_ack_i      : mem_ext_ack_i;
assign mem_error_o          = tcm_access_q ? mem_tcm_error_i    : mem_ext_error_i;
assign mem_resp_tag_o       = tcm_access_q ? mem_tcm_resp_tag_i : mem_ext_resp_tag_i;

wire   request_w            = mem_rd_i || mem_wr_i != 4'b0 || mem_flush_i || mem_invalidate_i || mem_writeback_i;

reg [4:0] pending_r;
always @ *
begin
    pending_r = pending_q;

    if ((request_w && mem_accept_o) && !mem_ack_o)
        pending_r = pending_r + 5'd1;
    else if (!(request_w && mem_accept_o) && mem_ack_o)
        pending_r = pending_r - 5'd1;
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pending_q <= 5'b0;
else
    pending_q <= pending_r;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    tcm_access_q <= 1'b0;
else if (request_w && mem_accept_o)
    tcm_access_q <= tcm_access_w;

assign hold_w = (|pending_q) && (tcm_access_q != tcm_access_w);



endmodule
