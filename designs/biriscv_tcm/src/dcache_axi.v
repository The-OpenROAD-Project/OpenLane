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

module dcache_axi
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter AXI_ID           = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           outport_awready_i
    ,input           outport_wready_i
    ,input           outport_bvalid_i
    ,input  [  1:0]  outport_bresp_i
    ,input  [  3:0]  outport_bid_i
    ,input           outport_arready_i
    ,input           outport_rvalid_i
    ,input  [ 31:0]  outport_rdata_i
    ,input  [  1:0]  outport_rresp_i
    ,input  [  3:0]  outport_rid_i
    ,input           outport_rlast_i
    ,input  [  3:0]  inport_wr_i
    ,input           inport_rd_i
    ,input  [  7:0]  inport_len_i
    ,input  [ 31:0]  inport_addr_i
    ,input  [ 31:0]  inport_write_data_i

    // Outputs
    ,output          outport_awvalid_o
    ,output [ 31:0]  outport_awaddr_o
    ,output [  3:0]  outport_awid_o
    ,output [  7:0]  outport_awlen_o
    ,output [  1:0]  outport_awburst_o
    ,output          outport_wvalid_o
    ,output [ 31:0]  outport_wdata_o
    ,output [  3:0]  outport_wstrb_o
    ,output          outport_wlast_o
    ,output          outport_bready_o
    ,output          outport_arvalid_o
    ,output [ 31:0]  outport_araddr_o
    ,output [  3:0]  outport_arid_o
    ,output [  7:0]  outport_arlen_o
    ,output [  1:0]  outport_arburst_o
    ,output          outport_rready_o
    ,output          inport_accept_o
    ,output          inport_ack_o
    ,output          inport_error_o
    ,output [ 31:0]  inport_read_data_o
);




//-------------------------------------------------------------
// Request FIFO
//-------------------------------------------------------------
wire          bvalid_w;
wire          rvalid_w;
wire [1:0]    bresp_w;
wire [1:0]    rresp_w;
wire          accept_w;

// Accepts from both FIFOs
wire          res_accept_w;
wire          req_accept_w;

wire          res_valid_w;
wire          req_valid_w;
wire [77-1:0] req_w;

// Push on transaction and other FIFO not full
wire          req_push_w    = (inport_rd_i || inport_wr_i != 4'b0);
wire [77-1:0] req_data_in_w = {inport_len_i, inport_rd_i, inport_wr_i, inport_write_data_i, inport_addr_i};

dcache_axi_fifo
#( 
    .ADDR_W(1),
    .DEPTH(2),
    .WIDTH(32+32+8+4+1)
)
u_req
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input side
    .data_in_i(req_data_in_w),
    .push_i(req_push_w),
    .accept_o(req_accept_w),

    // Outputs
    .valid_o(req_valid_w),
    .data_out_o(req_w),
    .pop_i(accept_w)
);

wire       req_can_issue_w = req_valid_w & res_accept_w;
wire       req_is_read_w   = (req_can_issue_w ? req_w[68] : 1'b0);
wire       req_is_write_w  = (req_can_issue_w ? ~req_w[68] : 1'b0);
wire [7:0] req_len_w       = req_w[76:69];

assign inport_accept_o = req_accept_w;
assign inport_ack_o    = bvalid_w || rvalid_w;
assign inport_error_o  = bvalid_w ? (bresp_w != 2'b0) : (rresp_w != 2'b0);

//-------------------------------------------------------------
// Write burst tracking
//-------------------------------------------------------------
reg  [7:0] req_cnt_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    req_cnt_q <= 8'b0;
// First cycle of write burst
else if (req_is_write_w && req_cnt_q == 8'd0 && req_len_w != 8'd0 && accept_w)
    req_cnt_q <= req_len_w - 8'd1;
else if (req_cnt_q != 8'd0 && req_is_write_w && accept_w)
    req_cnt_q <= req_cnt_q - 8'd1;

wire req_last_w = (req_is_write_w && req_len_w == 8'd0 && req_cnt_q == 8'd0);

//-------------------------------------------------------------
// Response tracking
//-------------------------------------------------------------
// Push on transaction and other FIFO not full
wire res_push_w = (req_is_write_w && req_last_w && accept_w) || (req_is_read_w && accept_w);

// Pop on last tick of burst
wire resp_pop_w = outport_bvalid_i || (outport_rvalid_i ? outport_rlast_i : 1'b0);

reg  [1:0] resp_outstanding_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    resp_outstanding_q <= 2'b0;
// Count up
else if ((res_push_w & res_accept_w) & ~(resp_pop_w & res_valid_w))
    resp_outstanding_q <= resp_outstanding_q + 2'd1;
// Count down
else if (~(res_push_w & res_accept_w) & (resp_pop_w & res_valid_w))
    resp_outstanding_q <= resp_outstanding_q - 2'd1;

assign res_valid_w   = (resp_outstanding_q != 2'd0);
assign res_accept_w  = (resp_outstanding_q != 2'd2);

//-------------------------------------------------------------
// AXI widget
//-------------------------------------------------------------
dcache_axi_axi
u_axi
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .inport_valid_i(req_can_issue_w),
    .inport_write_i(req_is_write_w),
    .inport_wdata_i(req_w[63:32]),
    .inport_wstrb_i(req_w[67:64]),    
    .inport_addr_i({req_w[31:2], 2'b0}),
    .inport_id_i(AXI_ID),
    .inport_len_i(req_len_w),
    .inport_burst_i(2'b01),
    .inport_accept_o(accept_w),

    .inport_bready_i(1'b1),
    .inport_rready_i(1'b1),
    .inport_bvalid_o(bvalid_w),
    .inport_bresp_o(bresp_w),
    .inport_bid_o(),
    .inport_rvalid_o(rvalid_w),
    .inport_rdata_o(inport_read_data_o),
    .inport_rresp_o(rresp_w),
    .inport_rid_o(),
    .inport_rlast_o(),

    .outport_awvalid_o(outport_awvalid_o),
    .outport_awaddr_o(outport_awaddr_o),
    .outport_awid_o(outport_awid_o),
    .outport_awlen_o(outport_awlen_o),
    .outport_awburst_o(outport_awburst_o),
    .outport_wvalid_o(outport_wvalid_o),
    .outport_wdata_o(outport_wdata_o),
    .outport_wstrb_o(outport_wstrb_o),
    .outport_wlast_o(outport_wlast_o),
    .outport_bready_o(outport_bready_o),
    .outport_arvalid_o(outport_arvalid_o),
    .outport_araddr_o(outport_araddr_o),
    .outport_arid_o(outport_arid_o),
    .outport_arlen_o(outport_arlen_o),
    .outport_arburst_o(outport_arburst_o),
    .outport_rready_o(outport_rready_o),
    .outport_awready_i(outport_awready_i),
    .outport_wready_i(outport_wready_i),
    .outport_bvalid_i(outport_bvalid_i),
    .outport_bresp_i(outport_bresp_i),
    .outport_bid_i(outport_bid_i),
    .outport_arready_i(outport_arready_i),
    .outport_rvalid_i(outport_rvalid_i),
    .outport_rdata_i(outport_rdata_i),
    .outport_rresp_i(outport_rresp_i),
    .outport_rid_i(outport_rid_i),
    .outport_rlast_i(outport_rlast_i)
);

endmodule


module dcache_axi_fifo
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
