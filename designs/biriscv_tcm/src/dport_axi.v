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

module dport_axi
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
    ,input           axi_awready_i
    ,input           axi_wready_i
    ,input           axi_bvalid_i
    ,input  [  1:0]  axi_bresp_i
    ,input           axi_arready_i
    ,input           axi_rvalid_i
    ,input  [ 31:0]  axi_rdata_i
    ,input  [  1:0]  axi_rresp_i

    // Outputs
    ,output [ 31:0]  mem_data_rd_o
    ,output          mem_accept_o
    ,output          mem_ack_o
    ,output          mem_error_o
    ,output [ 10:0]  mem_resp_tag_o
    ,output          axi_awvalid_o
    ,output [ 31:0]  axi_awaddr_o
    ,output          axi_wvalid_o
    ,output [ 31:0]  axi_wdata_o
    ,output [  3:0]  axi_wstrb_o
    ,output          axi_bready_o
    ,output          axi_arvalid_o
    ,output [ 31:0]  axi_araddr_o
    ,output          axi_rready_o
);





//-------------------------------------------------------------
// Description:
// Bridges between dcache_if -> AXI4/AXI4-Lite.
// Allows 1 outstanding transaction, but can buffer upto 
// REQUEST_BUFFER dache_if requests before back-pressuring.
//-------------------------------------------------------------

//-------------------------------------------------------------
// Request FIFO
//-------------------------------------------------------------
// Accepts from both FIFOs
wire          res_accept_w;
wire          req_accept_w;

// Output accept
wire          write_complete_w;
wire          read_complete_w;

reg           request_pending_q;

wire          req_pop_w   = read_complete_w | write_complete_w;
wire          req_valid_w;
wire [69-1:0] req_w;

// Push on transaction and other FIFO not full
wire          req_push_w   = (mem_rd_i || mem_wr_i != 4'b0) && res_accept_w;

dport_axi_fifo
#( 
    .WIDTH(32+32+4+1),
    .DEPTH(2),
    .ADDR_W(1)
)
u_req
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input side
    .data_in_i({mem_rd_i, mem_wr_i, mem_data_wr_i, mem_addr_i}),
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
wire res_push_w = (mem_rd_i || mem_wr_i != 4'b0) && req_accept_w;

dport_axi_fifo
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

assign mem_ack_o   = axi_bvalid_i || axi_rvalid_i;
assign mem_error_o = axi_bvalid_i ? (axi_bresp_i != 2'b0) : (axi_rresp_i != 2'b0);

wire request_in_progress_w = request_pending_q & !mem_ack_o;

//-------------------------------------------------------------
// Write Request
//-------------------------------------------------------------
wire req_is_read_w  = ((req_valid_w & !request_in_progress_w) ? req_w[68] : 1'b0);
wire req_is_write_w = ((req_valid_w & !request_in_progress_w) ? ~req_w[68] : 1'b0);

reg awvalid_inhibit_q;
reg wvalid_inhibit_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    awvalid_inhibit_q <= 1'b0;
else if (axi_awvalid_o && axi_awready_i && axi_wvalid_o && !axi_wready_i)
    awvalid_inhibit_q <= 1'b1;
else if (axi_wvalid_o && axi_wready_i)
    awvalid_inhibit_q <= 1'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    wvalid_inhibit_q <= 1'b0;
else if (axi_wvalid_o && axi_wready_i && axi_awvalid_o && !axi_awready_i)
    wvalid_inhibit_q <= 1'b1;
else if (axi_awvalid_o && axi_awready_i)
    wvalid_inhibit_q <= 1'b0;

assign axi_awvalid_o = req_is_write_w && !awvalid_inhibit_q;
assign axi_awaddr_o  = {req_w[31:2], 2'b0};
assign axi_wvalid_o  = req_is_write_w && !wvalid_inhibit_q;
assign axi_wdata_o   = req_w[63:32];
assign axi_wstrb_o   = req_w[67:64];

assign axi_bready_o  = 1'b1;

assign write_complete_w = (awvalid_inhibit_q || axi_awready_i) &&
                          (wvalid_inhibit_q || axi_wready_i) && req_is_write_w;

//-------------------------------------------------------------
// Read Request
//-------------------------------------------------------------
assign axi_arvalid_o = req_is_read_w;
assign axi_araddr_o  = {req_w[31:2], 2'b0};

assign axi_rready_o  = 1'b1;

assign mem_data_rd_o = axi_rdata_i;

assign read_complete_w = axi_arvalid_o && axi_arready_i;

//-------------------------------------------------------------
// Outstanding Request Tracking
//-------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    request_pending_q <= 1'b0;
else if (write_complete_w || read_complete_w)
    request_pending_q <= 1'b1;
else if (mem_ack_o)
    request_pending_q <= 1'b0;

endmodule

//-----------------------------------------------------------------
// dport_axi_fifo: FIFO
//-----------------------------------------------------------------
module dport_axi_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 8,
    parameter DEPTH   = 2,
    parameter ADDR_W  = 1
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
