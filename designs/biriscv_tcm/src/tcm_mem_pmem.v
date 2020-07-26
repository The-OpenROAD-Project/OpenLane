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

module tcm_mem_pmem
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           axi_awvalid_i
    ,input  [ 31:0]  axi_awaddr_i
    ,input  [  3:0]  axi_awid_i
    ,input  [  7:0]  axi_awlen_i
    ,input  [  1:0]  axi_awburst_i
    ,input           axi_wvalid_i
    ,input  [ 31:0]  axi_wdata_i
    ,input  [  3:0]  axi_wstrb_i
    ,input           axi_wlast_i
    ,input           axi_bready_i
    ,input           axi_arvalid_i
    ,input  [ 31:0]  axi_araddr_i
    ,input  [  3:0]  axi_arid_i
    ,input  [  7:0]  axi_arlen_i
    ,input  [  1:0]  axi_arburst_i
    ,input           axi_rready_i
    ,input           ram_accept_i
    ,input           ram_ack_i
    ,input           ram_error_i
    ,input  [ 31:0]  ram_read_data_i

    // Outputs
    ,output          axi_awready_o
    ,output          axi_wready_o
    ,output          axi_bvalid_o
    ,output [  1:0]  axi_bresp_o
    ,output [  3:0]  axi_bid_o
    ,output          axi_arready_o
    ,output          axi_rvalid_o
    ,output [ 31:0]  axi_rdata_o
    ,output [  1:0]  axi_rresp_o
    ,output [  3:0]  axi_rid_o
    ,output          axi_rlast_o
    ,output [  3:0]  ram_wr_o
    ,output          ram_rd_o
    ,output [  7:0]  ram_len_o
    ,output [ 31:0]  ram_addr_o
    ,output [ 31:0]  ram_write_data_o
);



//-------------------------------------------------------------
// calculate_addr_next
//-------------------------------------------------------------
function [31:0] calculate_addr_next;
    input [31:0] addr;
    input [1:0]  axtype;
    input [7:0]  axlen;

    reg [31:0]   mask;
begin
    mask = 0;

    case (axtype)
`ifdef SUPPORT_FIXED_BURST
    2'd0: // AXI4_BURST_FIXED
    begin
        calculate_addr_next = addr;
    end
`endif
`ifdef SUPPORT_WRAP_BURST
    2'd2: // AXI4_BURST_WRAP
    begin
        case (axlen)
        8'd0:      mask = 32'h03;
        8'd1:      mask = 32'h07;
        8'd3:      mask = 32'h0F;
        8'd7:      mask = 32'h1F;
        8'd15:     mask = 32'h3F;
        default:   mask = 32'h3F;
        endcase

        calculate_addr_next = (addr & ~mask) | ((addr + 4) & mask);
    end
`endif
    default: // AXI4_BURST_INCR
        calculate_addr_next = addr + 4;
    endcase
end
endfunction

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg [7:0]   req_len_q;
reg [31:0]  req_addr_q;
reg         req_rd_q;
reg         req_wr_q;
reg [3:0]   req_id_q;
reg [1:0]   req_axburst_q;
reg [7:0]   req_axlen_q;
reg         req_prio_q;
reg         req_hold_rd_q;
reg         req_hold_wr_q;

wire        req_fifo_accept_w;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    req_len_q     <= 8'b0;
    req_addr_q    <= 32'b0;
    req_wr_q      <= 1'b0;
    req_rd_q      <= 1'b0;
    req_id_q      <= 4'b0;
    req_axburst_q <= 2'b0;
    req_axlen_q   <= 8'b0;
    req_prio_q    <= 1'b0;
end
else
begin
    // Burst continuation
    if ((ram_wr_o != 4'b0 || ram_rd_o) && ram_accept_i)
    begin
        if (req_len_q == 8'd0)
        begin
            req_rd_q   <= 1'b0;
            req_wr_q   <= 1'b0;
        end
        else
        begin
            req_addr_q <= calculate_addr_next(req_addr_q, req_axburst_q, req_axlen_q);
            req_len_q  <= req_len_q - 8'd1;
        end
    end

    // Write command accepted
    if (axi_awvalid_i && axi_awready_o)
    begin
        // Data ready?
        if (axi_wvalid_i && axi_wready_o)
        begin
            req_wr_q      <= !axi_wlast_i;
            req_len_q     <= axi_awlen_i - 8'd1;
            req_id_q      <= axi_awid_i;
            req_axburst_q <= axi_awburst_i;
            req_axlen_q   <= axi_awlen_i;
            req_addr_q    <= calculate_addr_next(axi_awaddr_i, axi_awburst_i, axi_awlen_i);
        end
        // Data not ready
        else
        begin
            req_wr_q      <= 1'b1;
            req_len_q     <= axi_awlen_i;
            req_id_q      <= axi_awid_i;
            req_axburst_q <= axi_awburst_i;
            req_axlen_q   <= axi_awlen_i;
            req_addr_q    <= axi_awaddr_i;
        end
        req_prio_q    <= !req_prio_q;
    end
    // Read command accepted
    else if (axi_arvalid_i && axi_arready_o)
    begin
        req_rd_q      <= (axi_arlen_i != 0);
        req_len_q     <= axi_arlen_i - 8'd1;
        req_addr_q    <= calculate_addr_next(axi_araddr_i, axi_arburst_i, axi_arlen_i);
        req_id_q      <= axi_arid_i;
        req_axburst_q <= axi_arburst_i;
        req_axlen_q   <= axi_arlen_i;
        req_prio_q    <= !req_prio_q;
    end
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    req_hold_rd_q   <= 1'b0;
    req_hold_wr_q   <= 1'b0;
end
else
begin
    if (ram_rd_o && !ram_accept_i)
        req_hold_rd_q   <= 1'b1;
    else if (ram_accept_i)
        req_hold_rd_q   <= 1'b0;

    if ((|ram_wr_o) && !ram_accept_i)
        req_hold_wr_q   <= 1'b1;
    else if (ram_accept_i)
        req_hold_wr_q   <= 1'b0;
end

//-----------------------------------------------------------------
// Request tracking
//-----------------------------------------------------------------
wire       req_push_w = (ram_rd_o || (ram_wr_o != 4'b0)) && ram_accept_i;
reg [5:0]  req_in_r;

wire       req_out_valid_w;
wire [5:0] req_out_w;
wire       resp_accept_w;


always @ *
begin
    req_in_r = 6'b0;

    // First cycle of read burst
    if (axi_arvalid_i && axi_arready_o)
        req_in_r = {1'b1, (axi_arlen_i == 8'd0), axi_arid_i};
    // First cycle of write burst
    else if (axi_awvalid_i && axi_awready_o)
        req_in_r = {1'b0, (axi_awlen_i == 8'd0), axi_awid_i};
    // In burst
    else
        req_in_r = {ram_rd_o, (req_len_q == 8'd0), req_id_q};
end

tcm_mem_pmem_fifo2
#( .WIDTH(1 + 1 + 4) )
u_requests
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input
    .data_in_i(req_in_r),
    .push_i(req_push_w),
    .accept_o(req_fifo_accept_w),

    // Output
    .pop_i(resp_accept_w),
    .data_out_o(req_out_w),
    .valid_o(req_out_valid_w)
);

wire resp_is_write_w = req_out_valid_w ? ~req_out_w[5] : 1'b0;
wire resp_is_read_w  = req_out_valid_w ? req_out_w[5]  : 1'b0;
wire resp_is_last_w  = req_out_w[4];
wire [3:0] resp_id_w = req_out_w[3:0];

//-----------------------------------------------------------------
// Response buffering
//-----------------------------------------------------------------
wire resp_valid_w;

tcm_mem_pmem_fifo2
#( .WIDTH(32) )
u_response
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Input
    .data_in_i(ram_read_data_i),
    .push_i(ram_ack_i),
    .accept_o(),

    // Output
    .pop_i(resp_accept_w),
    .data_out_o(axi_rdata_o),
    .valid_o(resp_valid_w)
);

//-----------------------------------------------------------------
// RAM Request
//-----------------------------------------------------------------

// Round robin priority between read and write
wire write_prio_w   = ((req_prio_q  & !req_hold_rd_q) | req_hold_wr_q);
wire read_prio_w    = ((!req_prio_q & !req_hold_wr_q) | req_hold_rd_q);

wire write_active_w  = (axi_awvalid_i || req_wr_q) && !req_rd_q && req_fifo_accept_w && (write_prio_w || req_wr_q || !axi_arvalid_i);
wire read_active_w   = (axi_arvalid_i || req_rd_q) && !req_wr_q && req_fifo_accept_w && (read_prio_w || req_rd_q || !axi_awvalid_i);

assign axi_awready_o = write_active_w && !req_wr_q && ram_accept_i && req_fifo_accept_w;
assign axi_wready_o  = write_active_w &&              ram_accept_i && req_fifo_accept_w;
assign axi_arready_o = read_active_w  && !req_rd_q && ram_accept_i && req_fifo_accept_w;

wire [31:0] addr_w   = ((req_wr_q || req_rd_q) ? req_addr_q:
                        write_active_w ? axi_awaddr_i : axi_araddr_i);

wire wr_w    = write_active_w && axi_wvalid_i;
wire rd_w    = read_active_w;

// RAM if
assign ram_addr_o       = addr_w;
assign ram_write_data_o = axi_wdata_i;
assign ram_rd_o         = rd_w;
assign ram_wr_o         = wr_w ? axi_wstrb_i : 4'b0;
assign ram_len_o        = 8'b0;

//-----------------------------------------------------------------
// Response
//-----------------------------------------------------------------
assign axi_bvalid_o  = resp_valid_w & resp_is_write_w & resp_is_last_w;
assign axi_bresp_o   = 2'b0;
assign axi_bid_o     = resp_id_w;

assign axi_rvalid_o  = resp_valid_w & resp_is_read_w;
assign axi_rresp_o   = 2'b0;
assign axi_rid_o     = resp_id_w;
assign axi_rlast_o   = resp_is_last_w;

assign resp_accept_w    = (axi_rvalid_o & axi_rready_i) | 
                          (axi_bvalid_o & axi_bready_i) |
                          (resp_valid_w & resp_is_write_w & !resp_is_last_w); // Ignore write resps mid burst

endmodule

//-----------------------------------------------------------------
// FIFO
//-----------------------------------------------------------------
module tcm_mem_pmem_fifo2

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
reg [WIDTH-1:0]         ram [DEPTH-1:0];
reg [ADDR_W-1:0]        rd_ptr;
reg [ADDR_W-1:0]        wr_ptr;
reg [COUNT_W-1:0]       count;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    count   <= {(COUNT_W) {1'b0}};
    rd_ptr  <= {(ADDR_W) {1'b0}};
    wr_ptr  <= {(ADDR_W) {1'b0}};
end
else
begin
    // Push
    if (push_i & accept_o)
    begin
        ram[wr_ptr] <= data_in_i;
        wr_ptr      <= wr_ptr + 1;
    end

    // Pop
    if (pop_i & valid_o)
        rd_ptr      <= rd_ptr + 1;

    // Count up
    if ((push_i & accept_o) & ~(pop_i & valid_o))
        count <= count + 1;
    // Count down
    else if (~(push_i & accept_o) & (pop_i & valid_o))
        count <= count - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign accept_o   = (count != DEPTH);
assign valid_o    = (count != 0);
/* verilator lint_on WIDTH */

assign data_out_o = ram[rd_ptr];



endmodule
