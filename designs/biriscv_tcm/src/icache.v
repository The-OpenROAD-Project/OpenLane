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

module icache
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
    ,input           req_rd_i
    ,input           req_flush_i
    ,input           req_invalidate_i
    ,input  [ 31:0]  req_pc_i
    ,input           axi_awready_i
    ,input           axi_wready_i
    ,input           axi_bvalid_i
    ,input  [  1:0]  axi_bresp_i
    ,input  [  3:0]  axi_bid_i
    ,input           axi_arready_i
    ,input           axi_rvalid_i
    ,input  [ 31:0]  axi_rdata_i
    ,input  [  1:0]  axi_rresp_i
    ,input  [  3:0]  axi_rid_i
    ,input           axi_rlast_i

    // Outputs
    ,output          req_accept_o
    ,output          req_valid_o
    ,output          req_error_o
    ,output [ 63:0]  req_inst_o
    ,output          axi_awvalid_o
    ,output [ 31:0]  axi_awaddr_o
    ,output [  3:0]  axi_awid_o
    ,output [  7:0]  axi_awlen_o
    ,output [  1:0]  axi_awburst_o
    ,output          axi_wvalid_o
    ,output [ 31:0]  axi_wdata_o
    ,output [  3:0]  axi_wstrb_o
    ,output          axi_wlast_o
    ,output          axi_bready_o
    ,output          axi_arvalid_o
    ,output [ 31:0]  axi_araddr_o
    ,output [  3:0]  axi_arid_o
    ,output [  7:0]  axi_arlen_o
    ,output [  1:0]  axi_arburst_o
    ,output          axi_rready_o
);



//-----------------------------------------------------------------
// This cache instance is 2 way set associative.
// The total size is 16KB.
// The replacement policy is a limited pseudo random scheme
// (between lines, toggling on line thrashing).
//-----------------------------------------------------------------
// Number of ways
localparam ICACHE_NUM_WAYS           = 2;

// Number of cache lines
localparam ICACHE_NUM_LINES          = 256;
localparam ICACHE_LINE_ADDR_W        = 8;

// Line size (e.g. 32-bytes)
localparam ICACHE_LINE_SIZE_W        = 5;
localparam ICACHE_LINE_SIZE          = 32;
localparam ICACHE_LINE_WORDS         = 8;

localparam ICACHE_DATA_W             = 64;

// Request -> tag address mapping
localparam ICACHE_TAG_REQ_LINE_L     = 5;  // ICACHE_LINE_SIZE_W
localparam ICACHE_TAG_REQ_LINE_H     = 12; // ICACHE_LINE_ADDR_W+ICACHE_LINE_SIZE_W-1
localparam ICACHE_TAG_REQ_LINE_W     = 8;  // ICACHE_LINE_ADDR_W
`define ICACHE_TAG_REQ_RNG          ICACHE_TAG_REQ_LINE_H:ICACHE_TAG_REQ_LINE_L

// Tag fields
`define CACHE_TAG_ADDR_RNG          18:0
localparam CACHE_TAG_ADDR_BITS       = 19;
localparam CACHE_TAG_VALID_BIT       = CACHE_TAG_ADDR_BITS;
localparam CACHE_TAG_DATA_W          = CACHE_TAG_VALID_BIT + 1;

// Tag compare bits
localparam ICACHE_TAG_CMP_ADDR_L     = ICACHE_TAG_REQ_LINE_H + 1;
localparam ICACHE_TAG_CMP_ADDR_H     = 32-1;
localparam ICACHE_TAG_CMP_ADDR_W     = ICACHE_TAG_CMP_ADDR_H - ICACHE_TAG_CMP_ADDR_L + 1;
`define   ICACHE_TAG_CMP_ADDR_RNG   31:13

// Address mapping example:
//  31          16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
// |--------------|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
//  +--------------------+  +--------------------+   +------------+
//  |  Tag address.      |  |   Line address     |      Address 
//  |                    |  |                    |      within line
//  |                    |  |                    |
//  |                    |  |                    |- ICACHE_TAG_REQ_LINE_L
//  |                    |  |- ICACHE_TAG_REQ_LINE_H
//  |                    |- ICACHE_TAG_CMP_ADDR_L
//  |- ICACHE_TAG_CMP_ADDR_H

// Tag addressing and match value
wire [ICACHE_TAG_REQ_LINE_W-1:0] req_line_addr_w  = req_pc_i[`ICACHE_TAG_REQ_RNG];

// Data addressing
localparam CACHE_DATA_ADDR_W = ICACHE_LINE_ADDR_W+ICACHE_LINE_SIZE_W-3;
wire [CACHE_DATA_ADDR_W-1:0] req_data_addr_w = req_pc_i[CACHE_DATA_ADDR_W+3-1:3];

//-----------------------------------------------------------------
// States
//-----------------------------------------------------------------
localparam STATE_W           = 2;
localparam STATE_FLUSH       = 2'd0;
localparam STATE_LOOKUP      = 2'd1;
localparam STATE_REFILL      = 2'd2;
localparam STATE_RELOOKUP    = 2'd3;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// States
reg [STATE_W-1:0]           next_state_r;
reg [STATE_W-1:0]           state_q;

reg                         invalidate_q;

reg [0:0]  replace_way_q;

//-----------------------------------------------------------------
// Lookup validation
//-----------------------------------------------------------------
reg lookup_valid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    lookup_valid_q <= 1'b0;
else if (req_rd_i && req_accept_o)
    lookup_valid_q <= 1'b1;
else if (req_valid_o)
    lookup_valid_q <= 1'b0;

//-----------------------------------------------------------------
// Lookup address
//-----------------------------------------------------------------
reg [31:0] lookup_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    lookup_addr_q <= 32'b0;
else if (req_rd_i && req_accept_o)
    lookup_addr_q <= req_pc_i;

wire [ICACHE_TAG_CMP_ADDR_W-1:0] req_pc_tag_cmp_w = lookup_addr_q[`ICACHE_TAG_CMP_ADDR_RNG];

//-----------------------------------------------------------------
// TAG RAMS
//-----------------------------------------------------------------
reg [ICACHE_TAG_REQ_LINE_W-1:0] tag_addr_r;

// Tag RAM address
always @ *
begin
    tag_addr_r = flush_addr_q;

    // Cache flush
    if (state_q == STATE_FLUSH)
        tag_addr_r = flush_addr_q;
    // Line refill
    else if (state_q == STATE_REFILL || state_q == STATE_RELOOKUP)
        tag_addr_r = lookup_addr_q[`ICACHE_TAG_REQ_RNG];
    // Lookup
    else
        tag_addr_r = req_line_addr_w;
end

// Tag RAM write data
reg [CACHE_TAG_DATA_W-1:0] tag_data_in_r;
always @ *
begin
    tag_data_in_r = {(CACHE_TAG_DATA_W){1'b0}};

    // Cache flush
    if (state_q == STATE_FLUSH)
        tag_data_in_r = {(CACHE_TAG_DATA_W){1'b0}};
    // Line refill
    else if (state_q == STATE_REFILL)
    begin
        tag_data_in_r[CACHE_TAG_VALID_BIT] = 1'b1;
        tag_data_in_r[`CACHE_TAG_ADDR_RNG] = lookup_addr_q[`ICACHE_TAG_CMP_ADDR_RNG];
    end
end

// Tag RAM write enable (way 0)
reg tag0_write_r;
always @ *
begin
    tag0_write_r = 1'b0;

    // Cache flush
    if (state_q == STATE_FLUSH)
        tag0_write_r = 1'b1;
    // Line refill
    else if (state_q == STATE_REFILL)
        tag0_write_r = axi_rvalid_i && axi_rlast_i && (replace_way_q == 0);
end

wire [CACHE_TAG_DATA_W-1:0] tag0_data_out_w;

icache_tag_ram
u_tag0
(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .addr_i(tag_addr_r),
  .data_i(tag_data_in_r),
  .wr_i(tag0_write_r),
  .data_o(tag0_data_out_w)
);

wire                           tag0_valid_w     = tag0_data_out_w[CACHE_TAG_VALID_BIT];
wire [CACHE_TAG_ADDR_BITS-1:0] tag0_addr_bits_w = tag0_data_out_w[`CACHE_TAG_ADDR_RNG];

// Tag hit?
wire                           tag0_hit_w = tag0_valid_w ? (tag0_addr_bits_w == req_pc_tag_cmp_w) : 1'b0;

// Tag RAM write enable (way 1)
reg tag1_write_r;
always @ *
begin
    tag1_write_r = 1'b0;

    // Cache flush
    if (state_q == STATE_FLUSH)
        tag1_write_r = 1'b1;
    // Line refill
    else if (state_q == STATE_REFILL)
        tag1_write_r = axi_rvalid_i && axi_rlast_i && (replace_way_q == 1);
end

wire [CACHE_TAG_DATA_W-1:0] tag1_data_out_w;

icache_tag_ram
u_tag1
(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .addr_i(tag_addr_r),
  .data_i(tag_data_in_r),
  .wr_i(tag1_write_r),
  .data_o(tag1_data_out_w)
);

wire                           tag1_valid_w     = tag1_data_out_w[CACHE_TAG_VALID_BIT];
wire [CACHE_TAG_ADDR_BITS-1:0] tag1_addr_bits_w = tag1_data_out_w[`CACHE_TAG_ADDR_RNG];

// Tag hit?
wire                           tag1_hit_w = tag1_valid_w ? (tag1_addr_bits_w == req_pc_tag_cmp_w) : 1'b0;


wire tag_hit_any_w = 1'b0
                   | tag0_hit_w
                   | tag1_hit_w
                    ;

//-----------------------------------------------------------------
// DATA RAMS
//-----------------------------------------------------------------
reg [CACHE_DATA_ADDR_W-1:0] data_addr_r;
reg [CACHE_DATA_ADDR_W-1:0] data_write_addr_q;
reg [2:0]  refill_word_idx_q;
reg [31:0] refill_lower_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    refill_word_idx_q <= 3'b0;
else if (axi_rvalid_i && axi_rlast_i)
    refill_word_idx_q <= 3'b0;
else if (axi_rvalid_i)
    refill_word_idx_q <= refill_word_idx_q + 3'd1;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    refill_lower_q <= 32'b0;
else if (axi_rvalid_i)
    refill_lower_q <= axi_rdata_i;

// Data RAM refill write address
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_write_addr_q <= {(CACHE_DATA_ADDR_W){1'b0}};
else if (state_q == STATE_LOOKUP && next_state_r == STATE_REFILL)
    data_write_addr_q <= axi_araddr_o[CACHE_DATA_ADDR_W+3-1:3];
else if (state_q == STATE_REFILL && axi_rvalid_i && refill_word_idx_q[0])
    data_write_addr_q <= data_write_addr_q + 1;

// Data RAM address
always @ *
begin
    data_addr_r = req_data_addr_w;

    // Line refill
    if (state_q == STATE_REFILL)
        data_addr_r = data_write_addr_q;
    // Lookup after refill
    else if (state_q == STATE_RELOOKUP)
        data_addr_r = lookup_addr_q[CACHE_DATA_ADDR_W+3-1:3];
    // Lookup
    else
        data_addr_r = req_data_addr_w;
end


// Data RAM write enable (way 0)
reg data0_write_r;
always @ *
begin
    data0_write_r = axi_rvalid_i && replace_way_q == 0;
end

wire [ICACHE_DATA_W-1:0] data0_data_out_w;

icache_data_ram
u_data0
(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .addr_i(data_addr_r),
  .data_i({axi_rdata_i, refill_lower_q}),
  .wr_i(data0_write_r),
  .data_o(data0_data_out_w)
);

// Data RAM write enable (way 1)
reg data1_write_r;
always @ *
begin
    data1_write_r = axi_rvalid_i && replace_way_q == 1;
end

wire [ICACHE_DATA_W-1:0] data1_data_out_w;

icache_data_ram
u_data1
(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .addr_i(data_addr_r),
  .data_i({axi_rdata_i, refill_lower_q}),
  .wr_i(data1_write_r),
  .data_o(data1_data_out_w)
);

//-----------------------------------------------------------------
// Flush counter
//-----------------------------------------------------------------
reg [ICACHE_TAG_REQ_LINE_W-1:0] flush_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    flush_addr_q <= {(ICACHE_TAG_REQ_LINE_W){1'b0}};
else if (state_q == STATE_FLUSH)
    flush_addr_q <= flush_addr_q + 1;
// Invalidate specified line
else if (req_invalidate_i && req_accept_o)
    flush_addr_q <= req_line_addr_w;
else
    flush_addr_q <= {(ICACHE_TAG_REQ_LINE_W){1'b0}};

//-----------------------------------------------------------------
// Replacement Policy
//----------------------------------------------------------------- 
// Using random replacement policy - this way we cycle through the ways
// when needing to replace a line.
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    replace_way_q <= 0;
else if (axi_rvalid_i && axi_rlast_i)
    replace_way_q <= replace_way_q + 1;

//-----------------------------------------------------------------
// Instruction Output
//-----------------------------------------------------------------
assign req_valid_o = lookup_valid_q && ((state_q == STATE_LOOKUP) ? tag_hit_any_w : 1'b0);

// Data output mux
reg [ICACHE_DATA_W-1:0] inst_r;
always @ *
begin
    inst_r = data0_data_out_w;

    case (1'b1)
    tag0_hit_w: inst_r = data0_data_out_w;
    tag1_hit_w: inst_r = data1_data_out_w;
    endcase
end

assign req_inst_o    = inst_r;

//-----------------------------------------------------------------
// Next State Logic
//-----------------------------------------------------------------
always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_FLUSH
    //-----------------------------------------
    STATE_FLUSH :
    begin
        if (invalidate_q)
            next_state_r = STATE_LOOKUP;
        else if (flush_addr_q == {(ICACHE_TAG_REQ_LINE_W){1'b1}})
            next_state_r = STATE_LOOKUP;
    end
    //-----------------------------------------
    // STATE_LOOKUP
    //-----------------------------------------
    STATE_LOOKUP :
    begin
        // Tried a lookup but no match found
        if (lookup_valid_q && !tag_hit_any_w)
            next_state_r = STATE_REFILL;
        // Invalidate a line / flush cache
        else if (req_invalidate_i || req_flush_i)
            next_state_r = STATE_FLUSH;
    end
    //-----------------------------------------
    // STATE_REFILL
    //-----------------------------------------
    STATE_REFILL :
    begin
        // End of refill
        if (axi_rvalid_i && axi_rlast_i)
            next_state_r = STATE_RELOOKUP;
    end
    //-----------------------------------------
    // STATE_RELOOKUP
    //-----------------------------------------
    STATE_RELOOKUP :
    begin
        next_state_r = STATE_LOOKUP;
    end
    default:
        ;
   endcase
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q   <= STATE_FLUSH;
else
    state_q   <= next_state_r;

assign req_accept_o = (state_q == STATE_LOOKUP && next_state_r != STATE_REFILL);

//-----------------------------------------------------------------
// Invalidate
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    invalidate_q   <= 1'b0;
else if (req_invalidate_i && req_accept_o)
    invalidate_q   <= 1'b1;
else
    invalidate_q   <= 1'b0;

//-----------------------------------------------------------------
// AXI Request Hold
//-----------------------------------------------------------------
reg axi_arvalid_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    axi_arvalid_q   <= 1'b0;
else if (axi_arvalid_o && !axi_arready_i)
    axi_arvalid_q   <= 1'b1;
else
    axi_arvalid_q   <= 1'b0;

//-----------------------------------------------------------------
// AXI Error Handling
//-----------------------------------------------------------------
reg axi_error_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    axi_error_q   <= 1'b0;
else if (axi_rvalid_i && axi_rready_o && axi_rresp_i != 2'b0)
    axi_error_q   <= 1'b1;
else if (req_valid_o)
    axi_error_q   <= 1'b0;

assign req_error_o = axi_error_q;

//-----------------------------------------------------------------
// AXI
//-----------------------------------------------------------------
// AXI Write channel (unused)
assign axi_awvalid_o = 1'b0;
assign axi_awaddr_o  = 32'b0;
assign axi_awid_o    = 4'b0;
assign axi_awlen_o   = 8'b0;
assign axi_awburst_o = 2'b0;
assign axi_wvalid_o  = 1'b0;
assign axi_wdata_o   = 32'b0;
assign axi_wstrb_o   = 4'b0;
assign axi_wlast_o   = 1'b0;
assign axi_bready_o  = 1'b0;

// AXI Read channel
assign axi_arvalid_o = (state_q == STATE_LOOKUP && next_state_r == STATE_REFILL) || axi_arvalid_q;
assign axi_araddr_o  = {lookup_addr_q[31:ICACHE_LINE_SIZE_W], {(ICACHE_LINE_SIZE_W){1'b0}}};
assign axi_arburst_o = 2'd1; // INCR
assign axi_arid_o    = AXI_ID;
assign axi_arlen_o   = 8'd7;
assign axi_rready_o  = 1'b1;



endmodule
