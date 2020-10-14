// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`define ceilLog2(x) ( \
(x) > 2**30 ? 31 : \
(x) > 2**29 ? 30 : \
(x) > 2**28 ? 29 : \
(x) > 2**27 ? 28 : \
(x) > 2**26 ? 27 : \
(x) > 2**25 ? 26 : \
(x) > 2**24 ? 25 : \
(x) > 2**23 ? 24 : \
(x) > 2**22 ? 23 : \
(x) > 2**21 ? 22 : \
(x) > 2**20 ? 21 : \
(x) > 2**19 ? 20 : \
(x) > 2**18 ? 19 : \
(x) > 2**17 ? 18 : \
(x) > 2**16 ? 17 : \
(x) > 2**15 ? 16 : \
(x) > 2**14 ? 15 : \
(x) > 2**13 ? 14 : \
(x) > 2**12 ? 13 : \
(x) > 2**11 ? 12 : \
(x) > 2**10 ? 11 : \
(x) > 2**9 ? 10 : \
(x) > 2**8 ? 9 : \
(x) > 2**7 ? 8 : \
(x) > 2**6 ? 7 : \
(x) > 2**5 ? 6 : \
(x) > 2**4 ? 5 : \
(x) > 2**3 ? 4 : \
(x) > 2**2 ? 3 : \
(x) > 2**1 ? 2 : \
(x) > 2**0 ? 1 : 0)

`include "const.vh"

module cache #
(
  parameter CACHE_SIZE_BYTES = 1024,
  parameter ASSOCIATIVITY = 2,
  parameter LINE_SIZE_BYTES = 64,
  parameter WORD_BITS = `CPU_DATA_BITS,
  parameter NUM_SETS = CACHE_SIZE_BYTES/LINE_SIZE_BYTES/ASSOCIATIVITY,
  parameter LINE_SIZE_WORDS = LINE_SIZE_BYTES/(WORD_BITS/8),
  parameter LINE_SIZE_BITS = LINE_SIZE_BYTES * 8,
  parameter CPU_ADDR_BITS = `CPU_ADDR_BITS,
  // TODO(aryap): Huh?
  parameter WORD_ADDR_BITS = `CPU_ADDR_BITS-`ceilLog2(`CPU_INST_BITS/8),
  // Number of bits needed to select a byte within a word.
  parameter BYTE_OFFSET_BITS = `ceilLog2(`CPU_DATA_BITS/8),
  // Number of bits needed to select a word (block) within a cache line.
  parameter BLOCK_OFFSET_BITS = `ceilLog2(LINE_SIZE_BYTES / (WORD_BITS/8)),
  // Number of bits needed to select between all our cache sets.
  parameter SET_OFFSET_BITS = `ceilLog2(CACHE_SIZE_BYTES / LINE_SIZE_BYTES / ASSOCIATIVITY),
  // Number of bits used for the tag check.
  parameter TAG_BITS = WORD_ADDR_BITS-SET_OFFSET_BITS-BLOCK_OFFSET_BITS,
  // Width of the memory request address bus.
  parameter MEM_ADDR_BITS = `MEM_ADDR_BITS,
  // Number of data bits per memory line.
  parameter MEM_DATA_BITS = `MEM_DATA_BITS,
  // The number of bits required to select a byte from within a memory line.
  // Equivalently, the number of address bits we skip per memory line.
  parameter MEM_PAGE_BITS = `ceilLog2(MEM_DATA_BITS/8),
  parameter FORCE_WRITE_BACK = 0
)
(
  input clk,
  input reset,

  input                             cpu_req_val,
  output reg                        cpu_req_rdy,
  input [WORD_ADDR_BITS-1:0]        cpu_req_addr,
  input [WORD_BITS-1:0]             cpu_req_data,
  input [3:0]                       cpu_req_write,

  output wire                       cpu_resp_val,
  output [WORD_BITS-1:0]            cpu_resp_data,

  output reg                       mem_req_val,
  input                             mem_req_rdy,
  output reg [WORD_ADDR_BITS-1:`ceilLog2(`MEM_DATA_BITS/WORD_BITS)] mem_req_addr,
  output reg                       mem_req_rw,
  output reg                       mem_req_data_valid,
  input                            mem_req_data_ready,
  output [`MEM_DATA_BITS-1:0]      mem_req_data_bits,
  // byte level masking
  output reg [(`MEM_DATA_BITS/8)-1:0]  mem_req_data_mask,

  input                       mem_resp_val,
  input [`MEM_DATA_BITS-1:0]  mem_resp_data
);
  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  // TODO(aryap): Ok we really need a "WRITE" state.
  localparam
    COMP            = 2'd0,
    WRITE_BACK      = 2'd1,
    READ_MEMORY     = 2'd2;

  reg [1:0] current_state;  // An actual register.
  // Latch the CPU requested address.
  reg [WORD_ADDR_BITS-1:0] cpu_req_addr_r;

  // -------------------------------------------------------------------------
  // Index selection from cpu_req_addr
  // -------------------------------------------------------------------------

  localparam BLOCK_OFFSET_HIGH = BLOCK_OFFSET_BITS-1;
  localparam SET_OFFSET_HIGH = BLOCK_OFFSET_BITS+SET_OFFSET_BITS-1;

  // Set & block offsets, tag from the addr presented during *this* cycle;
  // used for hit detection and setting up writes.
  wire [BLOCK_OFFSET_BITS-1:0] block_offset_c =
    cpu_req_addr[BLOCK_OFFSET_HIGH:0];
  wire [SET_OFFSET_BITS-1:0] set_offset_c =
    cpu_req_addr[SET_OFFSET_HIGH:BLOCK_OFFSET_HIGH+1];
  wire [TAG_BITS-1:0] tag_c =
    cpu_req_addr[WORD_ADDR_BITS-1:SET_OFFSET_HIGH+1];

  // Set & block offsets, tag from the addr saved from a previous cycle,
  // usually used after read or write.
  wire [BLOCK_OFFSET_BITS-1:0] block_offset_r =
    cpu_req_addr_r[BLOCK_OFFSET_HIGH:0];
  wire [SET_OFFSET_BITS-1:0] set_offset_r =
    cpu_req_addr_r[SET_OFFSET_HIGH:BLOCK_OFFSET_HIGH+1];
  wire [TAG_BITS-1:0] tag_r =
    cpu_req_addr_r[WORD_ADDR_BITS-1:SET_OFFSET_HIGH+1];

  // -------------------------------------------------------------------------
  // Hit checking, line state bookkeeping
  // -------------------------------------------------------------------------

  // For each set, we need an array of bits per way to indicate whether the
  // corresponding way in that set is valid. We also need a bit for whether
  // the data in a given way of a given set is modified.
  reg [ASSOCIATIVITY-1:0] valid_by_set [NUM_SETS-1:0];
  reg [ASSOCIATIVITY-1:0] modified_by_set [NUM_SETS-1:0];

  // (Verilog sucks.)
  // Resets.
  //genvar i_s;
  //generate
  //  for (i_s = 0; i_s < NUM_SETS; i_s = i_s + 1) begin:RESETS_BY_ASSOC
  //    always @(posedge clk) begin
  //      if (reset) valid_by_set[i_s] <= {ASSOCIATIVITY{1'b0}};
  //      if (reset) modified_by_set[i_s] <= {ASSOCIATIVITY{1'b0}};
  //    end
  //  end
  //endgenerate

  wire [ASSOCIATIVITY-1:0] valid;
  wire [ASSOCIATIVITY-1:0] modified;

  genvar i_b;
  generate
    for (i_b = 0; i_b < ASSOCIATIVITY; i_b = i_b + 1) begin:ASSIGN_BITS
      assign valid[i_b] = valid_by_set[set_offset_r][i_b];
      assign modified[i_b] = modified_by_set[set_offset_r][i_b];
    end
  endgenerate

  // TODO(aryap): Parameterise with generate loop.
  wire [TAG_BITS-1:0] tag_w[ASSOCIATIVITY-1:0];
  wire [ASSOCIATIVITY-1:0] tag_check;
  assign tag_check[0] = (tag_w[0] == tag_r);
  assign tag_check[1] = (tag_w[1] == tag_r);

  wire [ASSOCIATIVITY-1:0] hit;
  assign hit[0] = valid[0] & tag_check[0];
  assign hit[1] = valid[1] & tag_check[1];

  reg [`ceilLog2(ASSOCIATIVITY)-1:0] hit_index;
  always @(*) begin
    case (1'b1)
      hit[1] : hit_index = 1'b1;
      default: hit_index = 1'b0;
    endcase
  end

  // (Verilog sucks.)
  //genvar i_h;
  //generate
  //  for (i_h = 0; i_h < ASSOCIATIVITY; i_h = i_h+1) begin:DETERMINE_HIT_INDEX
  //    always @(*) if (hit[i_h]) hit_index = i_h;
  //  end
  //endgenerate

  wire any_hit = |hit;

  wire write = |cpu_req_write;

  // TODO(aryap): Replace write_r with write depending on cpu_req_write_r
  // instead.
  reg write_r;

  reg response_is_from_memory;
  wire cpu_resp_new = ~write_r & (any_hit | response_is_from_memory);

  // -------------------------------------------------------------------------
  // "LRU" line way selection
  // -------------------------------------------------------------------------

  // A pointer to the way to write to next. This is a number, the index of the
  // way to target.
  // TODO(aryap): I can't for the life of me get this to reset properly:
  // reg [`ceilLog2(ASSOCIATIVITY)-1:0] next_ways [NUM_SETS-1:0];
  reg [ASSOCIATIVITY-1:0] next_ways [NUM_SETS-1:0];

  // Set offset here comes from the latched request addr, not the one
  // presented on the current cycle, since this is used in READ_MEMORY to
  // write to the cache.
  wire [`ceilLog2(ASSOCIATIVITY)-1:0] next_way =
    next_ways[set_offset_r][`ceilLog2(ASSOCIATIVITY)-1:0];

  // (Verilog sucks.)
  //genvar i_r;
  //generate
  //  for (i_r = 0; i_r < NUM_SETS; i_r = i_r + 1) begin:RESETS_BY_SET
  //    always @(posedge clk) begin
  //      if (reset) next_ways[i_r] <= {ASSOCIATIVITY{1'b0}};
  //    end
  //  end
  //endgenerate

  // -------------------------------------------------------------------------
  // Memory request/response
  // -------------------------------------------------------------------------

  // TODO(aryap):
  // Ok so this is how memory actually works: assert req_val when
  // req_rdy and then over the next N cycles you receive N*128 bits of
  // data. Wtf?
  //wire response_valid =
  //  mem_resp_val && (num_mem_resps < NUM_MEM_RESPONSES) && mem_req_in_flight;


  // We can't issue multiple requests to memory, so we have to serialise them
  // on this.
  reg mem_req_in_flight;

  localparam NUM_MEM_RESPONSES = LINE_SIZE_BITS / MEM_DATA_BITS;
  localparam NUM_MEM_WRITE_REQUESTS = NUM_MEM_RESPONSES;
  localparam NUM_MEM_READ_REQUESTS = NUM_MEM_RESPONSES / 4;

  reg [MEM_DATA_BITS-1:0] memory_line_chunks[NUM_MEM_RESPONSES-1:0];
  wire [LINE_SIZE_BITS-1:0] memory_line = {
    memory_line_chunks[3], memory_line_chunks[2],
    memory_line_chunks[1], memory_line_chunks[0]};

  // Each of these has +1 bit to count the overflow state.
  reg [MEM_ADDR_BITS:0] num_mem_reqs;
  reg [MEM_ADDR_BITS:0] num_mem_resps;

  wire all_write_reqs_sent = num_mem_reqs == NUM_MEM_WRITE_REQUESTS;
  wire all_resps_received = num_mem_resps == NUM_MEM_RESPONSES;

  // If 0, use the CPU request address as the memory address source; if 1, use
  // the tag stored for the target cache set/way to recreate the original
  // address.
  reg mem_req_addr_src;

  wire [WORD_ADDR_BITS-1:0] write_back_addr =
    {tag_w[next_way],
    cpu_req_addr_r[WORD_ADDR_BITS-TAG_BITS-1:MEM_PAGE_BITS],
    {MEM_PAGE_BITS{1'b0}}};

  wire [WORD_ADDR_BITS-1:0] read_memory_addr =
    {cpu_req_addr_r[WORD_ADDR_BITS-1:MEM_PAGE_BITS],
    {MEM_PAGE_BITS{1'b0}}};

  // MEM_PAGE_BITS is the LSB to increment at to select the next memory line;
  // but our cpu_req_addr doesn't include the byte offset so we have to adjust
  // for that.
  //
  // The bounds for cpu_req_addr_r come from where it is declared in the input
  // list.
  wire [MEM_ADDR_BITS-1:0] mem_req_addr_base =
    mem_req_addr_src ?
    write_back_addr[WORD_ADDR_BITS-1:MEM_PAGE_BITS-BYTE_OFFSET_BITS] :
    read_memory_addr[WORD_ADDR_BITS-1:MEM_PAGE_BITS-BYTE_OFFSET_BITS];

  //reg [MEM_ADDR_BITS-1:0] mem_req_addr_r;
  always @(*) mem_req_addr = mem_req_addr_base + num_mem_resps;

  // -------------------------------------------------------------------------
  // SRAMs
  // -------------------------------------------------------------------------

  reg [ASSOCIATIVITY-1:0] sram_we; // Comes from next_way
  //reg [ASSOCIATIVITY-1:0] sram_we_r; // Actual reg.

  always @(*) begin
    sram_we = 0;
    if (current_state == COMP && any_hit) begin
      sram_we[hit_index] = write_r;
    end else if (current_state == READ_MEMORY && all_resps_received) begin
      sram_we[next_way] = `CONTROL_TRUE;
    end
  end

  // We need a signal to indicate to WRITE_BACK that the correct tag is
  // available (after one cycle).
  //
  // TODO(aryap): We could just re-use sram_data_valid?
  reg sram_tag_valid_for_write_back;

  wire [SET_OFFSET_BITS-1:0] sram_addr =
    write_r ? set_offset_r :
    current_state == COMP ?  set_offset_c : set_offset_r;
  wire [TAG_BITS-1:0] sram_tag_in =
    write_r ? tag_r :
    current_state == COMP ?  tag_c : tag_r;

  TagSRAMs #(
    .CACHE_SET_BITS(SET_OFFSET_BITS),
    .CACHE_TAG_BITS(TAG_BITS)
  ) tag_srams_w0 (
    .clk(clk),
    .we(sram_we[0]),
    .addr(sram_addr),
    .data_in(sram_tag_in),
    .data_out(tag_w[0]));

  TagSRAMs #(
    .CACHE_SET_BITS(SET_OFFSET_BITS),
    .CACHE_TAG_BITS(TAG_BITS)
  ) tag_srams_w1 (
    .clk(clk),
    .we(sram_we[1]),
    .addr(sram_addr),
    .data_in(sram_tag_in),
    .data_out(tag_w[1]));

  wire [LINE_SIZE_BITS-1:0] dout[ASSOCIATIVITY-1:0];
  wire [LINE_SIZE_BITS-1:0] din;

  DataSRAMs #(
    .CACHE_SET_BITS(SET_OFFSET_BITS),
    .CACHE_LINE_BITS(LINE_SIZE_BITS)
  ) data_srams_w0 (
    .clk(clk),
    .we(sram_we[0]),
    .addr(sram_addr),
    .data_in(din),
    .data_out(dout[0]));

  DataSRAMs #(
    .CACHE_SET_BITS(SET_OFFSET_BITS),
    .CACHE_LINE_BITS(LINE_SIZE_BITS)
  ) data_srams_w1 (
    .clk(clk),
    .we(sram_we[1]),
    .addr(sram_addr),
    .data_in(din),
    .data_out(dout[1]));

  // This is true one cycle after an address is presented to the SRAM whose
  // data we want to read.
  reg sram_data_valid;
 
  // -------------------------------------------------------------------------
  // Busy signal
  // -------------------------------------------------------------------------

  always @(*) begin
    // Ready to receive a new address when the last address hit (so we can
    // just read out the data now) or we didn't have a valid address last
    // time.
    cpu_req_rdy = current_state == COMP && (any_hit || !sram_data_valid)  && !write_r;
  end
 
  // -------------------------------------------------------------------------
  // Line with CPU write req; buffer for newly read data
  // -------------------------------------------------------------------------

  wire [LINE_SIZE_BITS-1:0] existing_line = current_state == COMP ?
    dout[hit_index] : dout[next_way];

  // Either the output from the SRAM or that retrieved from memory.
  //wire line_src = current_state == READ_MEMORY;
  reg line_src;
  wire [LINE_SIZE_BITS-1:0] line = line_src ?  memory_line : existing_line;


  // Merge the desired write data into our value for the current cache line.
  reg [WORD_BITS-1:0] cpu_req_data_r;
  reg [3:0] cpu_req_write_r;

  localparam CACHE_LINE_PAD = LINE_SIZE_BITS - WORD_BITS;

  wire [LINE_SIZE_BITS-1:0] cpu_req_data_in_line =
    ({{CACHE_LINE_PAD{1'b0}}, cpu_req_data_r} << (
        block_offset_r * WORD_BITS));

  wire [LINE_SIZE_BITS-1:0] line_update_bitmask =
    ~({ {CACHE_LINE_PAD{1'b0}},
        {8{cpu_req_write_r[3]}},
        {8{cpu_req_write_r[2]}},
        {8{cpu_req_write_r[1]}},
        {8{cpu_req_write_r[0]}}} << (block_offset_r * WORD_BITS));

  wire [LINE_SIZE_BITS-1:0] line_with_update =
    cpu_req_data_in_line | (line_update_bitmask & line);

  assign din = write_r ? line_with_update : line;

  // TODO: Figure out how to make overwriting a sub-word nicer in PAR and in
  // Verilog.
 
  wire [LINE_SIZE_BITS-1:0] line_shifted_cpu =
    line >> (block_offset_r*WORD_BITS);

  wire [WORD_BITS-1:0] line_shifted_cpu_trunc =
    line_shifted_cpu[WORD_BITS-1:0];

  reg [WORD_BITS-1:0] cpu_resp_data_r;
  always @(posedge clk) begin
    if (cpu_resp_new) cpu_resp_data_r <= line_shifted_cpu_trunc;
  end

  assign cpu_resp_val = cpu_resp_new;
  assign cpu_resp_data = cpu_resp_new ?
    line_shifted_cpu_trunc : cpu_resp_data_r;

  wire [LINE_SIZE_BITS-1:0] line_shifted_mem =
    line >> (num_mem_resps*MEM_DATA_BITS);
  assign mem_req_data_bits = line_shifted_mem[MEM_DATA_BITS-1:0];

  // Sequential logic in each state.
  always @(posedge clk) begin
    if (reset) begin
      // TODO: Maybe fix for associativity > 2. This sets the value _for all
      // sets_ to zero.
      num_mem_reqs <= 0;
      num_mem_resps <= 0;
      mem_req_in_flight <= `CONTROL_FALSE;
      current_state <= COMP;
      response_is_from_memory <= `CONTROL_FALSE;
      sram_data_valid <= `CONTROL_FALSE;
      sram_tag_valid_for_write_back <= `CONTROL_FALSE;
      mem_req_addr_src <= 1'b0;
      line_src <= 1'b0;

      // I hate myself. This sucks.
      // Verilog sucks.
      // TODO(aryap): Can we transpose this?
      valid_by_set[0] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[1] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[2] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[3] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[4] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[5] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[6] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[7] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[8] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[9] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[10] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[11] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[12] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[13] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[14] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[15] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[16] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[17] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[18] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[19] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[20] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[21] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[22] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[23] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[24] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[25] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[26] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[27] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[28] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[29] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[30] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[31] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[32] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[33] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[34] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[35] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[36] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[37] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[38] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[39] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[40] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[41] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[42] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[43] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[44] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[45] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[46] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[47] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[48] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[49] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[50] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[51] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[52] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[53] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[54] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[55] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[56] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[57] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[58] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[59] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[60] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[61] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[62] <= {ASSOCIATIVITY{1'b0}};
      valid_by_set[63] <= {ASSOCIATIVITY{1'b0}};

      modified_by_set[0] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[1] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[2] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[3] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[4] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[5] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[6] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[7] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[8] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[9] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[10] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[11] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[12] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[13] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[14] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[15] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[16] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[17] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[18] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[19] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[20] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[21] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[22] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[23] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[24] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[25] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[26] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[27] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[28] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[29] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[30] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[31] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[32] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[33] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[34] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[35] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[36] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[37] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[38] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[39] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[40] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[41] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[42] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[43] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[44] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[45] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[46] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[47] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[48] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[49] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[50] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[51] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[52] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[53] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[54] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[55] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[56] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[57] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[58] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[59] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[60] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[61] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[62] <= {ASSOCIATIVITY{1'b0}};
      modified_by_set[63] <= {ASSOCIATIVITY{1'b0}};

      // next_ways[0] <= {ASSOCIATIVITY{1'b0}};
      // next_ways[1] <= {ASSOCIATIVITY{1'b0}};
      // next_ways[2] <= {ASSOCIATIVITY{1'b0}};
      // next_ways[3] <= {ASSOCIATIVITY{1'b0}};

    end else begin
      case (current_state)
        COMP: begin
          if (cpu_req_val) begin
            cpu_req_addr_r <= cpu_req_addr;
            cpu_req_data_r <= cpu_req_data;
            cpu_req_write_r <= cpu_req_write;
            write_r <= write;
          end
          sram_data_valid <= cpu_req_val;
          response_is_from_memory <= `CONTROL_FALSE;
          sram_tag_valid_for_write_back <= `CONTROL_FALSE;

          // Every following cycle should use the line from the SRAM output.
          line_src <= 1'b0;

          num_mem_reqs <= 0;
          num_mem_resps <= 0;

          // If in the current cycle we had a read hit, the data available
          // next cycle will be valid.

          if (sram_data_valid && !any_hit) begin
            cpu_req_addr_r <= cpu_req_addr_r;
            cpu_req_data_r <= cpu_req_data_r;
            cpu_req_write_r <= cpu_req_write_r;
            write_r <= write_r;
            sram_data_valid <= `CONTROL_FALSE;
            if (valid[next_way] && modified[next_way]) begin
              current_state <= WRITE_BACK;
            end else begin
              current_state <= READ_MEMORY;
              // READ_MEMORY stages need the line to come from the memory
              // buffer.
              line_src <= 1'b1;
            end
          end

          if (any_hit) begin
            if (write_r) begin
              // This is LRU. TODO(aryap): This only picks between two ways.
              modified_by_set[set_offset_r][hit_index] <= `CONTROL_TRUE;
              current_state <= COMP;
              cpu_req_addr_r <= 0;
              cpu_req_data_r <= 0;
              cpu_req_write_r <= 0;
              write_r <= `CONTROL_FALSE;
            end
          end
        end

        WRITE_BACK: begin
          if (!sram_tag_valid_for_write_back) begin
            // Set up write back starting state and add 1 cycle delay.
            sram_tag_valid_for_write_back <= `CONTROL_TRUE;
            mem_req_rw <= 1'b1;
            mem_req_val <= `CONTROL_TRUE;
            mem_req_data_valid <= `CONTROL_TRUE;
            mem_req_data_mask <= 16'hffff;
            mem_req_addr_src <= 1'b1;

          end else begin

            if (all_write_reqs_sent) begin
              mem_req_rw <= 1'b0;
            end else if (mem_req_rdy) begin
              num_mem_reqs <= num_mem_reqs + 1;
              mem_req_in_flight <= `CONTROL_TRUE;
            end

            if (all_resps_received) begin
              num_mem_resps <= 0;
              mem_req_val <= 1'b0;
              line_src <= 1'b1;
              current_state <= READ_MEMORY;
              sram_tag_valid_for_write_back <= `CONTROL_FALSE;
              mem_req_data_valid <= `CONTROL_FALSE;
              mem_req_data_mask <= 0;
              mem_req_addr_src <= 1'b0;
              // We can reset the # sent requests now.
              num_mem_reqs <= 0;
            end else if (mem_req_data_ready) begin
              num_mem_resps <= num_mem_resps + 1;
              mem_req_in_flight <= `CONTROL_FALSE;
            end 

          end
        end

        READ_MEMORY: begin
          // If in the current cycle we finished our memory read, the data
          // available next cycle will be valid.

          // TODO(aryap): Save a cycle by setting these values before leaving
          // COMP or WRITE_BACK?
          if (mem_req_in_flight && mem_req_val && mem_req_rdy) begin
            // Pulse valid for one cycle.
            mem_req_val <= `CONTROL_FALSE;
          end else if (mem_req_rdy && num_mem_reqs < NUM_MEM_READ_REQUESTS) begin
            // If mem_req_rdy, assume that on this clock cycle we issued a request
            mem_req_in_flight <= `CONTROL_TRUE;

            num_mem_reqs <= num_mem_reqs + 1;

            mem_req_val <= `CONTROL_TRUE;
            // Read, not write.
            mem_req_rw <= 1'b0;
          end

          if (all_resps_received) begin
            num_mem_resps <= 0;
            // Pseudo-LRU:
            next_ways[set_offset_r] <= next_ways[set_offset_r] + 1;
            valid_by_set[set_offset_r][next_way] <= 1'b1;

            // TODO(aryap): This is high for one cycle too many.
            mem_req_in_flight <= `CONTROL_FALSE;

            // The very first instance of COMP after READ_MEMORY should
            // continue to read memory data for the line source.
            line_src <= 1'b1;
            response_is_from_memory <= `CONTROL_TRUE;
            current_state <= COMP;

            modified_by_set[set_offset_r][next_way] <= write_r;
            if (write_r) begin
              cpu_req_addr_r <= 0;
              cpu_req_data_r <= 0;
              cpu_req_write_r <= 0;
              write_r <= `CONTROL_FALSE;
            end

          end else if (mem_req_in_flight && mem_resp_val) begin
            memory_line_chunks[num_mem_resps] <= mem_resp_data;
            num_mem_resps <= num_mem_resps + 1;
          end
        end

        default:;
      endcase
    end
  end

endmodule
