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

module dcache_if_pmem
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
    ,input           outport_accept_i
    ,input           outport_ack_i
    ,input           outport_error_i
    ,input  [ 31:0]  outport_read_data_i

    // Outputs
    ,output [ 31:0]  mem_data_rd_o
    ,output          mem_accept_o
    ,output          mem_ack_o
    ,output          mem_error_o
    ,output [ 10:0]  mem_resp_tag_o
    ,output [  3:0]  outport_wr_o
    ,output          outport_rd_o
    ,output [  7:0]  outport_len_o
    ,output [ 31:0]  outport_addr_o
    ,output [ 31:0]  outport_write_data_o
);





//-------------------------------------------------------------
// Description:
// Bridges between dcache_if -> AXI4/AXI4-Lite.
// Allows 1 outstanding transaction, but can buffer upto 
// REQUEST_BUFFER dcache_if requests before back-pressuring.
//-------------------------------------------------------------

//-------------------------------------------------------------
// Request FIFO
//-------------------------------------------------------------
// Accepts from both FIFOs
wire          res_accept_w;
wire          req_accept_w;

// Output accept
wire          request_complete_w;

wire          req_pop_w   = request_complete_w;
wire          req_valid_w;
wire [70-1:0] req_w;

// Cache requests are dropped
// NOTE: Should not actually end up here if configured correctly.
wire          drop_req_w   = mem_invalidate_i || mem_writeback_i || mem_flush_i;
wire          request_w    = drop_req_w || mem_rd_i || mem_wr_i != 4'b0;

// Push on transaction and other FIFO not full
wire          req_push_w   = request_w && res_accept_w;

dcache_if_pmem_fifo
#( 
    .WIDTH(32+32+4+1+1),
    .DEPTH(2),
    .ADDR_W(1)
)
u_req
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input side
    .data_in_i({drop_req_w, mem_rd_i, mem_wr_i, mem_data_wr_i, mem_addr_i}),
    .push_i(req_push_w),
    .accept_o(req_accept_w),

    // Outputs
    .valid_o(req_valid_w),
    .data_out_o(req_w),
    .pop_i(req_pop_w)
);

assign mem_accept_o = req_accept_w & res_accept_w;

//-------------------------------------------------------------
// Response Tracking FIFO
//-------------------------------------------------------------
// Push on transaction and other FIFO not full
wire res_push_w = request_w && req_accept_w;

dcache_if_pmem_fifo
#( 
    .WIDTH(11),
    .DEPTH(2),
    .ADDR_W(1)
)
u_resp
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input side
    .data_in_i(mem_req_tag_i),
    .push_i(res_push_w),
    .accept_o(res_accept_w),

    // Outputs
    .valid_o(), // UNUSED
    .data_out_o(mem_resp_tag_o),
    .pop_i(mem_ack_o)
);

//-------------------------------------------------------------
// Request
//-------------------------------------------------------------
reg  request_pending_q;
wire request_in_progress_w  = request_pending_q & !mem_ack_o;

wire req_is_read_w          = ((req_valid_w & !request_in_progress_w) ? req_w[68] : 1'b0);
wire req_is_write_w         = ((req_valid_w & !request_in_progress_w) ? ~req_w[68] : 1'b0);
wire req_is_drop_w          = ((req_valid_w & !request_in_progress_w) ? req_w[69] : 1'b0);

assign outport_wr_o         = req_is_write_w ? req_w[67:64] : 4'b0;
assign outport_rd_o         = req_is_read_w;
assign outport_len_o        = 8'd0;
assign outport_addr_o       = {req_w[31:2], 2'b0};
assign outport_write_data_o = req_w[63:32];

assign request_complete_w   = req_is_drop_w || ((outport_rd_o || outport_wr_o != 4'b0) && outport_accept_i);

// Outstanding Request Tracking
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    request_pending_q <= 1'b0;
else if (request_complete_w)
    request_pending_q <= 1'b1;
else if (mem_ack_o)
    request_pending_q <= 1'b0;

//-------------------------------------------------------------
// Response
//-------------------------------------------------------------
reg dropped_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    dropped_q <= 1'b0;
else if (req_is_drop_w)
    dropped_q <= 1'b1;
else
    dropped_q <= 1'b0;

assign mem_ack_o     = dropped_q || outport_ack_i;
assign mem_data_rd_o = outport_read_data_i;
assign mem_error_o   = outport_error_i;


endmodule

module dcache_if_pmem_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 8,
    parameter DEPTH   = 4,
    parameter ADDR_W  = 2
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input               clk_i
    ,input               rst_i
    ,input  [WIDTH-1:0]  data_in_i
    ,input               push_i
    ,input               pop_i

    // Outputs
    ,output [WIDTH-1:0]  data_out_o
    ,output              accept_o
    ,output              valid_o
);

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]   ram_q[DEPTH-1:0];
reg [ADDR_W-1:0]  rd_ptr_q;
reg [ADDR_W-1:0]  wr_ptr_q;
reg [COUNT_W-1:0] count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
end
else
begin
    // Push
    if (push_i & accept_o)
    begin
        ram_q[wr_ptr_q] <= data_in_i;
        wr_ptr_q        <= wr_ptr_q + 1;
    end

    // Pop
    if (pop_i & valid_o)
        rd_ptr_q      <= rd_ptr_q + 1;

    // Count up
    if ((push_i & accept_o) & ~(pop_i & valid_o))
        count_q <= count_q + 1;
    // Count down
    else if (~(push_i & accept_o) & (pop_i & valid_o))
        count_q <= count_q - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign valid_o       = (count_q != 0);
assign accept_o      = (count_q != DEPTH);
/* verilator lint_on WIDTH */

assign data_out_o    = ram_q[rd_ptr_q];



endmodule
