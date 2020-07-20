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

module dcache_core
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



//-----------------------------------------------------------------
// This cache instance is 2 way set associative.
// The total size is 16KB.
// The replacement policy is a limited pseudo random scheme
// (between lines, toggling on line thrashing).
// The cache is a write back cache, with allocate on read and write.
//-----------------------------------------------------------------
// Number of ways
localparam DCACHE_NUM_WAYS           = 2;

// Number of cache lines
localparam DCACHE_NUM_LINES          = 256;
localparam DCACHE_LINE_ADDR_W        = 8;

// Line size (e.g. 32-bytes)
localparam DCACHE_LINE_SIZE_W        = 5;
localparam DCACHE_LINE_SIZE          = 32;
localparam DCACHE_LINE_WORDS         = 8;

// Request -> tag address mapping
localparam DCACHE_TAG_REQ_LINE_L     = 5;  // DCACHE_LINE_SIZE_W
localparam DCACHE_TAG_REQ_LINE_H     = 12; // DCACHE_LINE_ADDR_W+DCACHE_LINE_SIZE_W-1
localparam DCACHE_TAG_REQ_LINE_W     = 8;  // DCACHE_LINE_ADDR_W
`define DCACHE_TAG_REQ_RNG          DCACHE_TAG_REQ_LINE_H:DCACHE_TAG_REQ_LINE_L

// Tag fields
`define CACHE_TAG_ADDR_RNG          18:0
localparam CACHE_TAG_ADDR_BITS       = 19;
localparam CACHE_TAG_DIRTY_BIT       = CACHE_TAG_ADDR_BITS + 0;
localparam CACHE_TAG_VALID_BIT       = CACHE_TAG_ADDR_BITS + 1;
localparam CACHE_TAG_DATA_W          = CACHE_TAG_ADDR_BITS + 2;

// Tag compare bits
localparam DCACHE_TAG_CMP_ADDR_L     = DCACHE_TAG_REQ_LINE_H + 1;
localparam DCACHE_TAG_CMP_ADDR_H     = 32-1;
localparam DCACHE_TAG_CMP_ADDR_W     = DCACHE_TAG_CMP_ADDR_H - DCACHE_TAG_CMP_ADDR_L + 1;
`define   DCACHE_TAG_CMP_ADDR_RNG   31:13

// Address mapping example:
//  31          16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
// |--------------|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
//  +--------------------+  +--------------------+   +------------+
//  |  Tag address.      |  |   Line address     |      Address 
//  |                    |  |                    |      within line
//  |                    |  |                    |
//  |                    |  |                    |- DCACHE_TAG_REQ_LINE_L
//  |                    |  |- DCACHE_TAG_REQ_LINE_H
//  |                    |- DCACHE_TAG_CMP_ADDR_L
//  |- DCACHE_TAG_CMP_ADDR_H

//-----------------------------------------------------------------
// States
//-----------------------------------------------------------------
localparam STATE_W           = 4;
localparam STATE_RESET       = 4'd0;
localparam STATE_FLUSH_ADDR  = 4'd1;
localparam STATE_FLUSH       = 4'd2;
localparam STATE_LOOKUP      = 4'd3;
localparam STATE_READ        = 4'd4;
localparam STATE_WRITE       = 4'd5;
localparam STATE_REFILL      = 4'd6;
localparam STATE_EVICT       = 4'd7;
localparam STATE_EVICT_WAIT  = 4'd8;
localparam STATE_INVALIDATE  = 4'd9;
localparam STATE_WRITEBACK   = 4'd10;

// States
reg [STATE_W-1:0]           next_state_r;
reg [STATE_W-1:0]           state_q;

//-----------------------------------------------------------------
// Request buffer
//-----------------------------------------------------------------
reg [31:0] mem_addr_m_q;
reg [31:0] mem_data_m_q;
reg [3:0]  mem_wr_m_q;
reg        mem_rd_m_q;
reg [10:0] mem_tag_m_q;
reg        mem_inval_m_q;
reg        mem_writeback_m_q;
reg        mem_flush_m_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    mem_addr_m_q      <= 32'b0;
    mem_data_m_q      <= 32'b0;
    mem_wr_m_q        <= 4'b0;
    mem_rd_m_q        <= 1'b0;
    mem_tag_m_q       <= 11'b0;
    mem_inval_m_q     <= 1'b0;
    mem_writeback_m_q <= 1'b0;
    mem_flush_m_q     <= 1'b0;
end
else if (mem_accept_o)
begin
    mem_addr_m_q      <= mem_addr_i;
    mem_data_m_q      <= mem_data_wr_i;
    mem_wr_m_q        <= mem_wr_i;
    mem_rd_m_q        <= mem_rd_i;
    mem_tag_m_q       <= mem_req_tag_i;
    mem_inval_m_q     <= mem_invalidate_i;
    mem_writeback_m_q <= mem_writeback_i;
    mem_flush_m_q     <= mem_flush_i;
end
else if (mem_ack_o)
begin
    mem_addr_m_q      <= 32'b0;
    mem_data_m_q      <= 32'b0;
    mem_wr_m_q        <= 4'b0;
    mem_rd_m_q        <= 1'b0;
    mem_tag_m_q       <= 11'b0;
    mem_inval_m_q     <= 1'b0;
    mem_writeback_m_q <= 1'b0;
    mem_flush_m_q     <= 1'b0;
end

reg mem_accept_r;

always @ *
begin
    mem_accept_r = 1'b0;

    if (state_q == STATE_LOOKUP)
    begin
        // Previous access missed - do not accept new requests
        if ((mem_rd_m_q || (mem_wr_m_q != 4'b0)) && !tag_hit_any_m_w)
            mem_accept_r = 1'b0;
        // Write followed by read - detect writes to the same line, or addresses which alias in tag lookups
        else if ((|mem_wr_m_q) && mem_rd_i && mem_addr_i[31:2] == mem_addr_m_q[31:2])
            mem_accept_r = 1'b0;
        else
            mem_accept_r = 1'b1;
    end
end

assign mem_accept_o = mem_accept_r;

// Tag comparison address
wire [DCACHE_TAG_CMP_ADDR_W-1:0] req_addr_tag_cmp_m_w = mem_addr_m_q[`DCACHE_TAG_CMP_ADDR_RNG];

assign mem_resp_tag_o = mem_tag_m_q;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg [0:0]  replace_way_q;

wire  [  3:0]  pmem_wr_w;
wire           pmem_rd_w;
wire  [  7:0]  pmem_len_w;
wire           pmem_last_w;
wire  [ 31:0]  pmem_addr_w;
wire  [ 31:0]  pmem_write_data_w;
wire           pmem_accept_w;
wire           pmem_ack_w;
wire           pmem_error_w;
wire [ 31:0]   pmem_read_data_w;

wire           evict_way_w;
wire           tag_dirty_any_m_w;
wire           tag_hit_and_dirty_m_w;

reg            flushing_q;

//-----------------------------------------------------------------
// TAG RAMS
//-----------------------------------------------------------------
reg [DCACHE_TAG_REQ_LINE_W-1:0] tag_addr_x_r;
reg [DCACHE_TAG_REQ_LINE_W-1:0] tag_addr_m_r;

// Tag RAM address
always @ *
begin
    // Read Port
    tag_addr_x_r = mem_addr_i[`DCACHE_TAG_REQ_RNG];

    // Lookup
    if (state_q == STATE_LOOKUP && (next_state_r == STATE_LOOKUP || next_state_r == STATE_WRITEBACK))
        tag_addr_x_r = mem_addr_i[`DCACHE_TAG_REQ_RNG];
    // Cache flush
    else if (flushing_q)
        tag_addr_x_r = flush_addr_q;
    else
        tag_addr_x_r = mem_addr_m_q[`DCACHE_TAG_REQ_RNG];        

    // Write Port
    tag_addr_m_r = flush_addr_q;

    // Cache flush
    if (flushing_q || state_q == STATE_RESET)
        tag_addr_m_r = flush_addr_q;
    // Line refill / write
    else
        tag_addr_m_r = mem_addr_m_q[`DCACHE_TAG_REQ_RNG];
end

// Tag RAM write data
reg [CACHE_TAG_DATA_W-1:0] tag_data_in_m_r;
always @ *
begin
    tag_data_in_m_r = {(CACHE_TAG_DATA_W){1'b0}};

    // Cache flush
    if (state_q == STATE_FLUSH || state_q == STATE_RESET || flushing_q)
        tag_data_in_m_r = {(CACHE_TAG_DATA_W){1'b0}};
    // Line refill
    else if (state_q == STATE_REFILL)
    begin
        tag_data_in_m_r[CACHE_TAG_VALID_BIT] = 1'b1;
        tag_data_in_m_r[CACHE_TAG_DIRTY_BIT] = 1'b0;
        tag_data_in_m_r[`CACHE_TAG_ADDR_RNG] = mem_addr_m_q[`DCACHE_TAG_CMP_ADDR_RNG];
    end
    // Invalidate - mark entry (if matching line) not valid (even if dirty...)
    else if (state_q == STATE_INVALIDATE)
    begin
        tag_data_in_m_r[CACHE_TAG_VALID_BIT] = 1'b0;
        tag_data_in_m_r[CACHE_TAG_DIRTY_BIT] = 1'b0;
        tag_data_in_m_r[`CACHE_TAG_ADDR_RNG] = mem_addr_m_q[`DCACHE_TAG_CMP_ADDR_RNG];
    end
    // Evict completion
    else if (state_q == STATE_EVICT_WAIT)
    begin
        tag_data_in_m_r[CACHE_TAG_VALID_BIT] = 1'b1;
        tag_data_in_m_r[CACHE_TAG_DIRTY_BIT] = 1'b0;
        tag_data_in_m_r[`CACHE_TAG_ADDR_RNG] = mem_addr_m_q[`DCACHE_TAG_CMP_ADDR_RNG];
    end
    // Write - mark entry as dirty
    else if (state_q == STATE_WRITE || (state_q == STATE_LOOKUP && (|mem_wr_m_q)))
    begin
        tag_data_in_m_r[CACHE_TAG_VALID_BIT] = 1'b1;
        tag_data_in_m_r[CACHE_TAG_DIRTY_BIT] = 1'b1;
        tag_data_in_m_r[`CACHE_TAG_ADDR_RNG] = mem_addr_m_q[`DCACHE_TAG_CMP_ADDR_RNG];
    end
end

// Tag RAM write enable (way 0)
reg tag0_write_m_r;
always @ *
begin
    tag0_write_m_r = 1'b0;

    // Cache flush (reset)
    if (state_q == STATE_RESET)
        tag0_write_m_r = 1'b1;
    // Cache flush
    else if (state_q == STATE_FLUSH)
        tag0_write_m_r = !tag_dirty_any_m_w;
    // Write - hit, mark as dirty
    else if (state_q == STATE_LOOKUP && (|mem_wr_m_q))
        tag0_write_m_r = tag0_hit_m_w;
    // Write - write after refill
    else if (state_q == STATE_WRITE)
        tag0_write_m_r = (replace_way_q == 0);
    // Write - mark entry as dirty
    else if (state_q == STATE_EVICT_WAIT && pmem_ack_w)
        tag0_write_m_r = (replace_way_q == 0);
    // Line refill
    else if (state_q == STATE_REFILL)
        tag0_write_m_r = pmem_ack_w && pmem_last_w && (replace_way_q == 0);
    // Invalidate - line matches address - invalidate
    else if (state_q == STATE_INVALIDATE)
        tag0_write_m_r = tag0_hit_m_w;
end

wire [CACHE_TAG_DATA_W-1:0] tag0_data_out_m_w;

dcache_core_tag_ram
u_tag0
(
  .clk0_i(clk_i),
  .rst0_i(rst_i),
  .clk1_i(clk_i),
  .rst1_i(rst_i),

  // Read
  .addr0_i(tag_addr_x_r),
  .data0_o(tag0_data_out_m_w),

  // Write
  .addr1_i(tag_addr_m_r),
  .data1_i(tag_data_in_m_r),
  .wr1_i(tag0_write_m_r)
);

wire                           tag0_valid_m_w     = tag0_data_out_m_w[CACHE_TAG_VALID_BIT];
wire                           tag0_dirty_m_w     = tag0_data_out_m_w[CACHE_TAG_DIRTY_BIT];
wire [CACHE_TAG_ADDR_BITS-1:0] tag0_addr_bits_m_w = tag0_data_out_m_w[`CACHE_TAG_ADDR_RNG];

// Tag hit?
wire                           tag0_hit_m_w = tag0_valid_m_w ? (tag0_addr_bits_m_w == req_addr_tag_cmp_m_w) : 1'b0;

// Tag RAM write enable (way 1)
reg tag1_write_m_r;
always @ *
begin
    tag1_write_m_r = 1'b0;

    // Cache flush (reset)
    if (state_q == STATE_RESET)
        tag1_write_m_r = 1'b1;
    // Cache flush
    else if (state_q == STATE_FLUSH)
        tag1_write_m_r = !tag_dirty_any_m_w;
    // Write - hit, mark as dirty
    else if (state_q == STATE_LOOKUP && (|mem_wr_m_q))
        tag1_write_m_r = tag1_hit_m_w;
    // Write - write after refill
    else if (state_q == STATE_WRITE)
        tag1_write_m_r = (replace_way_q == 1);
    // Write - mark entry as dirty
    else if (state_q == STATE_EVICT_WAIT && pmem_ack_w)
        tag1_write_m_r = (replace_way_q == 1);
    // Line refill
    else if (state_q == STATE_REFILL)
        tag1_write_m_r = pmem_ack_w && pmem_last_w && (replace_way_q == 1);
    // Invalidate - line matches address - invalidate
    else if (state_q == STATE_INVALIDATE)
        tag1_write_m_r = tag1_hit_m_w;
end

wire [CACHE_TAG_DATA_W-1:0] tag1_data_out_m_w;

dcache_core_tag_ram
u_tag1
(
  .clk0_i(clk_i),
  .rst0_i(rst_i),
  .clk1_i(clk_i),
  .rst1_i(rst_i),

  // Read
  .addr0_i(tag_addr_x_r),
  .data0_o(tag1_data_out_m_w),

  // Write
  .addr1_i(tag_addr_m_r),
  .data1_i(tag_data_in_m_r),
  .wr1_i(tag1_write_m_r)
);

wire                           tag1_valid_m_w     = tag1_data_out_m_w[CACHE_TAG_VALID_BIT];
wire                           tag1_dirty_m_w     = tag1_data_out_m_w[CACHE_TAG_DIRTY_BIT];
wire [CACHE_TAG_ADDR_BITS-1:0] tag1_addr_bits_m_w = tag1_data_out_m_w[`CACHE_TAG_ADDR_RNG];

// Tag hit?
wire                           tag1_hit_m_w = tag1_valid_m_w ? (tag1_addr_bits_m_w == req_addr_tag_cmp_m_w) : 1'b0;


wire tag_hit_any_m_w = 1'b0
                   | tag0_hit_m_w
                   | tag1_hit_m_w
                    ;

assign tag_hit_and_dirty_m_w = 1'b0
                   | (tag0_hit_m_w & tag0_dirty_m_w)
                   | (tag1_hit_m_w & tag1_dirty_m_w)
                    ;

assign tag_dirty_any_m_w = 1'b0
                   | (tag0_valid_m_w & tag0_dirty_m_w)
                   | (tag1_valid_m_w & tag1_dirty_m_w)
                    ;

localparam EVICT_ADDR_W = 32 - DCACHE_LINE_SIZE_W;
reg        evict_way_r;
reg [31:0] evict_data_r;
reg [EVICT_ADDR_W-1:0] evict_addr_r;
always @ *
begin
    evict_way_r  = 1'b0;
    evict_addr_r = flushing_q ? {tag0_addr_bits_m_w, flush_addr_q} :
                                {tag0_addr_bits_m_w, mem_addr_m_q[`DCACHE_TAG_REQ_RNG]};
    evict_data_r = data0_data_out_m_w;

    case (replace_way_q)
        1'd0:
        begin
            evict_way_r  = tag0_valid_m_w && tag0_dirty_m_w;
            evict_addr_r = flushing_q ? {tag0_addr_bits_m_w, flush_addr_q} :
                                        {tag0_addr_bits_m_w, mem_addr_m_q[`DCACHE_TAG_REQ_RNG]};
            evict_data_r = data0_data_out_m_w;
        end
        1'd1:
        begin
            evict_way_r  = tag1_valid_m_w && tag1_dirty_m_w;
            evict_addr_r = flushing_q ? {tag1_addr_bits_m_w, flush_addr_q} :
                                        {tag1_addr_bits_m_w, mem_addr_m_q[`DCACHE_TAG_REQ_RNG]};
            evict_data_r = data1_data_out_m_w;
        end
    endcase
end
assign                  evict_way_w  = (flushing_q || !tag_hit_any_m_w) && evict_way_r;
wire [EVICT_ADDR_W-1:0] evict_addr_w = evict_addr_r;
wire [31:0]             evict_data_w = evict_data_r;

//-----------------------------------------------------------------
// DATA RAMS
//-----------------------------------------------------------------
// Data addressing
localparam CACHE_DATA_ADDR_W = DCACHE_LINE_ADDR_W+DCACHE_LINE_SIZE_W-2;


reg [CACHE_DATA_ADDR_W-1:0] data_addr_x_r;
reg [CACHE_DATA_ADDR_W-1:0] data_addr_m_r;
reg [CACHE_DATA_ADDR_W-1:0] data_write_addr_q;

// Data RAM refill write address
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_write_addr_q <= {(CACHE_DATA_ADDR_W){1'b0}};
else if (state_q != STATE_REFILL && next_state_r == STATE_REFILL)
    data_write_addr_q <= pmem_addr_w[CACHE_DATA_ADDR_W+2-1:2];
else if (state_q != STATE_EVICT && next_state_r == STATE_EVICT)
    data_write_addr_q <= data_addr_m_r + 1;
else if (state_q == STATE_REFILL && pmem_ack_w)
    data_write_addr_q <= data_write_addr_q + 1;
else if (state_q == STATE_EVICT && pmem_accept_w)
    data_write_addr_q <= data_write_addr_q + 1;

// Data RAM address
always @ *
begin
    data_addr_x_r = mem_addr_i[CACHE_DATA_ADDR_W+2-1:2];
    data_addr_m_r = mem_addr_m_q[CACHE_DATA_ADDR_W+2-1:2];

    // Line refill / evict
    if (state_q == STATE_REFILL || state_q == STATE_EVICT)
    begin
        data_addr_x_r = data_write_addr_q;
        data_addr_m_r = data_addr_x_r;
    end
    else if (state_q == STATE_FLUSH || state_q == STATE_RESET)
    begin
        data_addr_x_r = {flush_addr_q, {(DCACHE_LINE_SIZE_W-2){1'b0}}};
        data_addr_m_r = data_addr_x_r;
    end
    else if (state_q != STATE_EVICT && next_state_r == STATE_EVICT)
    begin
        data_addr_x_r = {mem_addr_m_q[`DCACHE_TAG_REQ_RNG], {(DCACHE_LINE_SIZE_W-2){1'b0}}};
        data_addr_m_r = data_addr_x_r;
    end
    // Lookup post refill
    else if (state_q == STATE_READ)
    begin
        data_addr_x_r = mem_addr_m_q[CACHE_DATA_ADDR_W+2-1:2];
    end
    // Possible line update on write
    else
        data_addr_m_r = mem_addr_m_q[CACHE_DATA_ADDR_W+2-1:2];
end


// Data RAM write enable (way 0)
reg [3:0] data0_write_m_r;
always @ *
begin
    data0_write_m_r = 4'b0;

    if (state_q == STATE_REFILL)
        data0_write_m_r = (pmem_ack_w && replace_way_q == 0) ? 4'b1111 : 4'b0000;
    else if (state_q == STATE_WRITE || state_q == STATE_LOOKUP)
        data0_write_m_r = mem_wr_m_q & {4{tag0_hit_m_w}};
end

wire [31:0] data0_data_out_m_w;
wire [31:0] data0_data_in_m_w = (state_q == STATE_REFILL) ? pmem_read_data_w : mem_data_m_q;

dcache_core_data_ram
u_data0
(
  .clk0_i(clk_i),
  .rst0_i(rst_i),
  .clk1_i(clk_i),
  .rst1_i(rst_i),

  // Read
  .addr0_i(data_addr_x_r),
  .data0_i(32'b0),
  .wr0_i(4'b0),
  .data0_o(data0_data_out_m_w),

  // Write
  .addr1_i(data_addr_m_r),
  .data1_i(data0_data_in_m_w),
  .wr1_i(data0_write_m_r),
  .data1_o()
);


// Data RAM write enable (way 1)
reg [3:0] data1_write_m_r;
always @ *
begin
    data1_write_m_r = 4'b0;

    if (state_q == STATE_REFILL)
        data1_write_m_r = (pmem_ack_w && replace_way_q == 1) ? 4'b1111 : 4'b0000;
    else if (state_q == STATE_WRITE || state_q == STATE_LOOKUP)
        data1_write_m_r = mem_wr_m_q & {4{tag1_hit_m_w}};
end

wire [31:0] data1_data_out_m_w;
wire [31:0] data1_data_in_m_w = (state_q == STATE_REFILL) ? pmem_read_data_w : mem_data_m_q;

dcache_core_data_ram
u_data1
(
  .clk0_i(clk_i),
  .rst0_i(rst_i),
  .clk1_i(clk_i),
  .rst1_i(rst_i),

  // Read
  .addr0_i(data_addr_x_r),
  .data0_i(32'b0),
  .wr0_i(4'b0),
  .data0_o(data1_data_out_m_w),

  // Write
  .addr1_i(data_addr_m_r),
  .data1_i(data1_data_in_m_w),
  .wr1_i(data1_write_m_r),
  .data1_o()
);


//-----------------------------------------------------------------
// Flush counter
//-----------------------------------------------------------------
reg [DCACHE_TAG_REQ_LINE_W-1:0] flush_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    flush_addr_q <= {(DCACHE_TAG_REQ_LINE_W){1'b0}};
else if ((state_q == STATE_RESET) || (state_q == STATE_FLUSH && next_state_r == STATE_FLUSH_ADDR))
    flush_addr_q <= flush_addr_q + 1;
else if (state_q == STATE_LOOKUP)
    flush_addr_q <= {(DCACHE_TAG_REQ_LINE_W){1'b0}};

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    flushing_q <= 1'b0;
else if (state_q == STATE_LOOKUP && next_state_r == STATE_FLUSH_ADDR)
    flushing_q <= 1'b1;
else if (state_q == STATE_FLUSH && next_state_r == STATE_LOOKUP)
    flushing_q <= 1'b0;

reg flush_last_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    flush_last_q <= 1'b0;
else if (state_q == STATE_LOOKUP)
    flush_last_q <= 1'b0;
else if (flush_addr_q == {(DCACHE_TAG_REQ_LINE_W){1'b1}})
    flush_last_q <= 1'b1;

//-----------------------------------------------------------------
// Replacement Policy
//----------------------------------------------------------------- 
// Using random replacement policy - this way we cycle through the ways
// when needing to replace a line.
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    replace_way_q <= 0;
else if (state_q == STATE_WRITE || state_q == STATE_READ)
    replace_way_q <= replace_way_q + 1;
else if (flushing_q && tag_dirty_any_m_w && !evict_way_w && state_q != STATE_FLUSH_ADDR)
    replace_way_q <= replace_way_q + 1;
else if (state_q == STATE_EVICT_WAIT && next_state_r == STATE_FLUSH_ADDR)
    replace_way_q <= 0;
else if (state_q == STATE_FLUSH && next_state_r == STATE_LOOKUP)
    replace_way_q <= 0;
else if (state_q == STATE_LOOKUP && next_state_r == STATE_FLUSH_ADDR)
    replace_way_q <= 0;
else if (state_q == STATE_WRITEBACK)
begin
    case (1'b1)
    tag0_hit_m_w: replace_way_q <= 0;
    tag1_hit_m_w: replace_way_q <= 1;
    endcase
end

//-----------------------------------------------------------------
// Output Result
//-----------------------------------------------------------------
// Data output mux
reg [31:0] data_r;
always @ *
begin
    data_r = data0_data_out_m_w;

    case (1'b1)
    tag0_hit_m_w: data_r = data0_data_out_m_w;
    tag1_hit_m_w: data_r = data1_data_out_m_w;
    endcase
end

assign mem_data_rd_o  = data_r;

//-----------------------------------------------------------------
// Next State Logic
//-----------------------------------------------------------------
always @ *
begin
    next_state_r = state_q;

    case (state_q)
    //-----------------------------------------
    // STATE_RESET
    //-----------------------------------------
    STATE_RESET :
    begin
        // Final line checked
        if (flush_last_q)
            next_state_r = STATE_LOOKUP;
    end
    //-----------------------------------------
    // STATE_FLUSH_ADDR
    //-----------------------------------------
    STATE_FLUSH_ADDR : next_state_r = STATE_FLUSH;
    //-----------------------------------------
    // STATE_FLUSH
    //-----------------------------------------
    STATE_FLUSH :
    begin
        // Dirty line detected - evict unless initial cache reset cycle
        if (tag_dirty_any_m_w)
        begin
            // Evict dirty line - else wait for dirty way to be selected
            if (evict_way_w)
                next_state_r = STATE_EVICT;
        end
        // Final line checked, nothing dirty
        else if (flush_last_q)
            next_state_r = STATE_LOOKUP;
        else
            next_state_r = STATE_FLUSH_ADDR;
    end
    //-----------------------------------------
    // STATE_LOOKUP
    //-----------------------------------------
    STATE_LOOKUP :
    begin
        // Previous access missed in the cache
        if ((mem_rd_m_q || (mem_wr_m_q != 4'b0)) && !tag_hit_any_m_w)
        begin
            // Evict dirty line first
            if (evict_way_w)
                next_state_r = STATE_EVICT;
            // Allocate line and fill
            else
                next_state_r = STATE_REFILL;
        end
        // Writeback a single line
        else if (mem_writeback_i && mem_accept_o)
            next_state_r = STATE_WRITEBACK;
        // Flush whole cache
        else if (mem_flush_i && mem_accept_o)
            next_state_r = STATE_FLUSH_ADDR;
        // Invalidate line (even if dirty)
        else if (mem_invalidate_i && mem_accept_o)
            next_state_r = STATE_INVALIDATE;
    end
    //-----------------------------------------
    // STATE_REFILL
    //-----------------------------------------
    STATE_REFILL :
    begin
        // End of refill
        if (pmem_ack_w && pmem_last_w)
        begin
            // Refill reason was write
            if (mem_wr_m_q != 4'b0)
                next_state_r = STATE_WRITE;
            // Refill reason was read
            else
                next_state_r = STATE_READ;
        end
    end
    //-----------------------------------------
    // STATE_WRITE/READ
    //-----------------------------------------
    STATE_WRITE, STATE_READ :
    begin
        next_state_r = STATE_LOOKUP;
    end
    //-----------------------------------------
    // STATE_EVICT
    //-----------------------------------------
    STATE_EVICT :
    begin
        // End of evict, wait for write completion
        if (pmem_accept_w && pmem_last_w)
            next_state_r = STATE_EVICT_WAIT;
    end
    //-----------------------------------------
    // STATE_EVICT_WAIT
    //-----------------------------------------
    STATE_EVICT_WAIT :
    begin
        // Single line writeback
        if (pmem_ack_w && mem_writeback_m_q)
            next_state_r = STATE_LOOKUP;
        // Evict due to flush
        else if (pmem_ack_w && flushing_q)
            next_state_r = STATE_FLUSH_ADDR;
        // Write ack, start re-fill now
        else if (pmem_ack_w)
            next_state_r = STATE_REFILL;
    end
    //-----------------------------------------
    // STATE_WRITEBACK: Writeback a cache line
    //-----------------------------------------
    STATE_WRITEBACK:
    begin
        // Line is dirty - write back to memory
        if (tag_hit_and_dirty_m_w)
            next_state_r = STATE_EVICT;
        // Line not dirty, carry on
        else
            next_state_r = STATE_LOOKUP;
    end
    //-----------------------------------------
    // STATE_INVALIDATE: Invalidate a cache line
    //-----------------------------------------
    STATE_INVALIDATE:
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
    state_q   <= STATE_RESET;
else
    state_q   <= next_state_r;

reg mem_ack_r;

always @ *
begin
    mem_ack_r = 1'b0;

    if (state_q == STATE_LOOKUP)
    begin
        // Normal hit - read or write
        if ((mem_rd_m_q || (mem_wr_m_q != 4'b0)) && tag_hit_any_m_w)
            mem_ack_r = 1'b1;
        // Flush, invalidate or writeback
        else if (mem_flush_m_q || mem_inval_m_q || mem_writeback_m_q)
            mem_ack_r = 1'b1;
    end
end

assign mem_ack_o = mem_ack_r;

//-----------------------------------------------------------------
// AXI Request
//-----------------------------------------------------------------
reg pmem_rd_q;
reg pmem_wr0_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_rd_q   <= 1'b0;
else if (pmem_rd_w)
    pmem_rd_q   <= ~pmem_accept_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_wr0_q   <= 1'b0;
else if (state_q != STATE_EVICT && next_state_r == STATE_EVICT)
    pmem_wr0_q   <= 1'b1;
else if (pmem_accept_w)
    pmem_wr0_q   <= 1'b0;

reg [7:0] pmem_len_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_len_q   <= 8'b0;
else if (state_q != STATE_EVICT && next_state_r == STATE_EVICT)
    pmem_len_q   <= 8'd7;
else if (pmem_rd_w && pmem_accept_w)
    pmem_len_q   <= pmem_len_w;
else if (state_q == STATE_REFILL && pmem_ack_w)
    pmem_len_q   <= pmem_len_q - 8'd1;
else if (state_q == STATE_EVICT && pmem_accept_w)
    pmem_len_q   <= pmem_len_q - 8'd1;

assign pmem_last_w = (pmem_len_q == 8'd0);

reg [31:0] pmem_addr_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_addr_q   <= 32'b0;
else if (|pmem_len_w && pmem_accept_w)
    pmem_addr_q   <= pmem_addr_w + 32'd4;
else if (pmem_accept_w)
    pmem_addr_q   <= pmem_addr_q + 32'd4;

//-----------------------------------------------------------------
// Skid buffer for write data
//-----------------------------------------------------------------
reg [3:0]  pmem_wr_q;
reg [31:0] pmem_write_data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_wr_q <= 4'b0;
else if ((|pmem_wr_w) && !pmem_accept_w)
    pmem_wr_q <= pmem_wr_w;
else if (pmem_accept_w)
    pmem_wr_q <= 4'b0;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pmem_write_data_q <= 32'b0;
else if (!pmem_accept_w)
    pmem_write_data_q <= pmem_write_data_w;

//-----------------------------------------------------------------
// AXI Error Handling
//-----------------------------------------------------------------
reg error_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    error_q   <= 1'b0;
else if (pmem_ack_w && pmem_error_w)
    error_q   <= 1'b1;
else if (mem_ack_o)
    error_q   <= 1'b0;

assign mem_error_o = error_q;

//-----------------------------------------------------------------
// Outport
//-----------------------------------------------------------------
wire refill_request_w   = (state_q != STATE_REFILL && next_state_r == STATE_REFILL);
wire evict_request_w    = (state_q == STATE_EVICT) && (evict_way_w || mem_writeback_m_q);

// AXI Read channel
assign pmem_rd_w         = (refill_request_w || pmem_rd_q);
assign pmem_wr_w         = (evict_request_w || (|pmem_wr_q)) ? 4'hF : 4'b0;
assign pmem_addr_w       = (|pmem_len_w) ? 
                           pmem_rd_w ? {mem_addr_m_q[31:DCACHE_LINE_SIZE_W], {(DCACHE_LINE_SIZE_W){1'b0}}} :
                           {evict_addr_w, {(DCACHE_LINE_SIZE_W){1'b0}}} :
                           pmem_addr_q;

assign pmem_len_w        = (refill_request_w || pmem_rd_q || (state_q == STATE_EVICT && pmem_wr0_q)) ? 8'd7 : 8'd0;
assign pmem_write_data_w = (|pmem_wr_q) ? pmem_write_data_q : evict_data_w;

assign outport_wr_o         = pmem_wr_w;
assign outport_rd_o         = pmem_rd_w;
assign outport_len_o        = pmem_len_w;
assign outport_addr_o       = pmem_addr_w;
assign outport_write_data_o = pmem_write_data_w;

assign pmem_accept_w        = outport_accept_i;
assign pmem_ack_w           = outport_ack_i;
assign pmem_error_w         = outport_error_i;
assign pmem_read_data_w     = outport_read_data_i;

//-------------------------------------------------------------------
// Debug
//-------------------------------------------------------------------
`ifdef verilator
/* verilator lint_off WIDTH */
reg [79:0] dbg_state;
always @ *
begin
    dbg_state = "-";

    case (state_q)
    STATE_RESET:
        dbg_state = "RESET";
    STATE_FLUSH_ADDR:
        dbg_state = "FLUSH_ADDR";
    STATE_FLUSH:
        dbg_state = "FLUSH";
    STATE_LOOKUP:
        dbg_state = "LOOKUP";
    STATE_READ:
        dbg_state = "READ";
    STATE_WRITE:
        dbg_state = "WRITE";
    STATE_REFILL:
        dbg_state = "REFILL";
    STATE_EVICT:
        dbg_state = "EVICT";
    STATE_EVICT_WAIT:
        dbg_state = "EVICT_WAIT";
    STATE_INVALIDATE:
        dbg_state = "INVAL";
    STATE_WRITEBACK:
        dbg_state = "WRITEBACK";
    default:
        ;
    endcase
end
/* verilator lint_on WIDTH */
`endif


endmodule
