module ibex_icache (
	clk_i,
	rst_ni,
	req_i,
	branch_i,
	branch_spec_i,
	addr_i,
	ready_i,
	valid_o,
	rdata_o,
	addr_o,
	err_o,
	err_plus2_o,
	instr_req_o,
	instr_gnt_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	instr_pmp_err_i,
	instr_rvalid_i,
	icache_enable_i,
	icache_inval_i,
	busy_o
);
	parameter [31:0] BusWidth = 32;
	parameter [31:0] CacheSizeBytes = 4096;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [31:0] LineSize = 64;
	parameter [31:0] NumWays = 2;
	parameter [0:0] SpecRequest = 1'b0;
	parameter [0:0] BranchCache = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire req_i;
	input wire branch_i;
	input wire branch_spec_i;
	input wire [31:0] addr_i;
	input wire ready_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire [31:0] addr_o;
	output wire err_o;
	output wire err_plus2_o;
	output wire instr_req_o;
	input wire instr_gnt_i;
	output wire [31:0] instr_addr_o;
	input wire [BusWidth - 1:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	input wire instr_rvalid_i;
	input wire icache_enable_i;
	input wire icache_inval_i;
	output wire busy_o;
	localparam [31:0] ADDR_W = 32;
	localparam [31:0] NUM_FB = 4;
	localparam [31:0] FB_THRESHOLD = NUM_FB - 2;
	localparam [31:0] LINE_SIZE_ECC = (ICacheECC ? LineSize + 8 : LineSize);
	localparam [31:0] LINE_SIZE_BYTES = LineSize / 8;
	localparam [31:0] LINE_W = $clog2(LINE_SIZE_BYTES);
	localparam [31:0] BUS_BYTES = BusWidth / 8;
	localparam [31:0] BUS_W = $clog2(BUS_BYTES);
	localparam [31:0] LINE_BEATS = LINE_SIZE_BYTES / BUS_BYTES;
	localparam [31:0] LINE_BEATS_W = $clog2(LINE_BEATS);
	localparam [31:0] NUM_LINES = (CacheSizeBytes / NumWays) / LINE_SIZE_BYTES;
	localparam [31:0] INDEX_W = $clog2(NUM_LINES);
	localparam [31:0] INDEX_HI = (INDEX_W + LINE_W) - 1;
	localparam [31:0] TAG_SIZE = ((ADDR_W - INDEX_W) - LINE_W) + 1;
	localparam [31:0] TAG_SIZE_ECC = (ICacheECC ? TAG_SIZE + 6 : TAG_SIZE);
	localparam [31:0] OUTPUT_BEATS = BUS_BYTES / 2;
	wire [ADDR_W - 1:0] lookup_addr_aligned;
	wire [ADDR_W - 1:0] prefetch_addr_d;
	reg [ADDR_W - 1:0] prefetch_addr_q;
	wire prefetch_addr_en;
	wire branch_suppress;
	wire lookup_throttle;
	wire lookup_req_ic0;
	wire [ADDR_W - 1:0] lookup_addr_ic0;
	wire [INDEX_W - 1:0] lookup_index_ic0;
	wire fill_req_ic0;
	wire [INDEX_W - 1:0] fill_index_ic0;
	wire [TAG_SIZE - 1:0] fill_tag_ic0;
	wire [LineSize - 1:0] fill_wdata_ic0;
	wire lookup_grant_ic0;
	wire lookup_actual_ic0;
	wire fill_grant_ic0;
	wire tag_req_ic0;
	wire [INDEX_W - 1:0] tag_index_ic0;
	wire [NumWays - 1:0] tag_banks_ic0;
	wire tag_write_ic0;
	wire [TAG_SIZE_ECC - 1:0] tag_wdata_ic0;
	wire data_req_ic0;
	wire [INDEX_W - 1:0] data_index_ic0;
	wire [NumWays - 1:0] data_banks_ic0;
	wire data_write_ic0;
	wire [LINE_SIZE_ECC - 1:0] data_wdata_ic0;
	wire [TAG_SIZE_ECC - 1:0] tag_rdata_ic1 [0:NumWays - 1];
	wire [LINE_SIZE_ECC - 1:0] data_rdata_ic1 [0:NumWays - 1];
	reg [LINE_SIZE_ECC - 1:0] hit_data_ic1;
	reg lookup_valid_ic1;
	reg [ADDR_W - 1:INDEX_HI + 1] lookup_addr_ic1;
	wire [NumWays - 1:0] tag_match_ic1;
	wire tag_hit_ic1;
	wire [NumWays - 1:0] tag_invalid_ic1;
	wire [NumWays - 1:0] lowest_invalid_way_ic1;
	wire [NumWays - 1:0] round_robin_way_ic1;
	reg [NumWays - 1:0] round_robin_way_q;
	wire [NumWays - 1:0] sel_way_ic1;
	wire ecc_err_ic1;
	wire ecc_write_req;
	wire [NumWays - 1:0] ecc_write_ways;
	wire [INDEX_W - 1:0] ecc_write_index;
	wire gnt_or_pmp_err;
	wire gnt_not_pmp_err;
	reg [1:0] fb_fill_level;
	wire fill_cache_new;
	wire fill_new_alloc;
	wire fill_spec_req;
	wire fill_spec_done;
	wire fill_spec_hold;
	wire [(NUM_FB * NUM_FB) - 1:0] fill_older_d;
	reg [(NUM_FB * NUM_FB) - 1:0] fill_older_q;
	wire [NUM_FB - 1:0] fill_alloc_sel;
	wire [NUM_FB - 1:0] fill_alloc;
	wire [NUM_FB - 1:0] fill_busy_d;
	reg [NUM_FB - 1:0] fill_busy_q;
	wire [NUM_FB - 1:0] fill_done;
	reg [NUM_FB - 1:0] fill_in_ic1;
	wire [NUM_FB - 1:0] fill_stale_d;
	reg [NUM_FB - 1:0] fill_stale_q;
	wire [NUM_FB - 1:0] fill_cache_d;
	reg [NUM_FB - 1:0] fill_cache_q;
	wire [NUM_FB - 1:0] fill_hit_ic1;
	wire [NUM_FB - 1:0] fill_hit_d;
	reg [NUM_FB - 1:0] fill_hit_q;
	wire [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_ext_cnt_d;
	reg [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_ext_cnt_q;
	wire [NUM_FB - 1:0] fill_ext_hold_d;
	reg [NUM_FB - 1:0] fill_ext_hold_q;
	wire [NUM_FB - 1:0] fill_ext_done;
	wire [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_rvd_cnt_d;
	reg [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_rvd_cnt_q;
	wire [NUM_FB - 1:0] fill_rvd_done;
	wire [NUM_FB - 1:0] fill_ram_done_d;
	reg [NUM_FB - 1:0] fill_ram_done_q;
	wire [NUM_FB - 1:0] fill_out_grant;
	wire [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_out_cnt_d;
	reg [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_out_cnt_q;
	wire [NUM_FB - 1:0] fill_out_done;
	wire [NUM_FB - 1:0] fill_ext_req;
	wire [NUM_FB - 1:0] fill_rvd_exp;
	wire [NUM_FB - 1:0] fill_ram_req;
	wire [NUM_FB - 1:0] fill_out_req;
	wire [NUM_FB - 1:0] fill_data_sel;
	wire [NUM_FB - 1:0] fill_data_reg;
	wire [NUM_FB - 1:0] fill_data_hit;
	wire [NUM_FB - 1:0] fill_data_rvd;
	wire [(NUM_FB * LINE_BEATS_W) - 1:0] fill_ext_off;
	wire [(NUM_FB * LINE_BEATS_W) - 1:0] fill_rvd_off;
	wire [(LINE_BEATS_W >= 0 ? (NUM_FB * (LINE_BEATS_W + 1)) - 1 : (NUM_FB * (1 - LINE_BEATS_W)) + (LINE_BEATS_W - 1)):(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W)] fill_rvd_beat;
	wire [NUM_FB - 1:0] fill_ext_arb;
	wire [NUM_FB - 1:0] fill_ram_arb;
	wire [NUM_FB - 1:0] fill_out_arb;
	wire [NUM_FB - 1:0] fill_rvd_arb;
	wire [NUM_FB - 1:0] fill_entry_en;
	wire [NUM_FB - 1:0] fill_addr_en;
	wire [NUM_FB - 1:0] fill_way_en;
	wire [(NUM_FB * LINE_BEATS) - 1:0] fill_data_en;
	wire [(NUM_FB * LINE_BEATS) - 1:0] fill_err_d;
	reg [(NUM_FB * LINE_BEATS) - 1:0] fill_err_q;
	reg [ADDR_W - 1:0] fill_addr_q [0:NUM_FB - 1];
	reg [NumWays - 1:0] fill_way_q [0:NUM_FB - 1];
	wire [LineSize - 1:0] fill_data_d [0:NUM_FB - 1];
	reg [LineSize - 1:0] fill_data_q [0:NUM_FB - 1];
	reg [ADDR_W - 1:BUS_W] fill_ext_req_addr;
	reg [ADDR_W - 1:0] fill_ram_req_addr;
	reg [NumWays - 1:0] fill_ram_req_way;
	reg [LineSize - 1:0] fill_ram_req_data;
	reg [LineSize - 1:0] fill_out_data;
	reg [LINE_BEATS - 1:0] fill_out_err;
	wire instr_req;
	wire [ADDR_W - 1:BUS_W] instr_addr;
	wire skid_complete_instr;
	wire skid_ready;
	wire output_compressed;
	wire skid_valid_d;
	reg skid_valid_q;
	wire skid_en;
	wire [15:0] skid_data_d;
	reg [15:0] skid_data_q;
	reg skid_err_q;
	wire output_valid;
	wire addr_incr_two;
	wire output_addr_en;
	wire [ADDR_W - 1:1] output_addr_d;
	reg [ADDR_W - 1:1] output_addr_q;
	reg [15:0] output_data_lo;
	reg [15:0] output_data_hi;
	wire data_valid;
	wire output_ready;
	wire [LineSize - 1:0] line_data;
	wire [LINE_BEATS - 1:0] line_err;
	reg [31:0] line_data_muxed;
	reg line_err_muxed;
	wire [31:0] output_data;
	wire output_err;
	wire start_inval;
	wire inval_done;
	reg reset_inval_q;
	wire inval_prog_d;
	reg inval_prog_q;
	wire [INDEX_W - 1:0] inval_index_d;
	reg [INDEX_W - 1:0] inval_index_q;
	assign lookup_addr_aligned = {lookup_addr_ic0[ADDR_W - 1:LINE_W], {LINE_W {1'b0}}};
	assign prefetch_addr_d = (lookup_grant_ic0 ? lookup_addr_aligned + {{(ADDR_W - LINE_W) - 1 {1'b0}}, 1'b1, {LINE_W {1'b0}}} : addr_i);
	assign prefetch_addr_en = branch_i | lookup_grant_ic0;
	always @(posedge clk_i)
		if (prefetch_addr_en)
			prefetch_addr_q <= prefetch_addr_d;
	assign lookup_throttle = fb_fill_level > FB_THRESHOLD[1:0];
	assign lookup_req_ic0 = ((req_i & ~&fill_busy_q) & (branch_i | ~lookup_throttle)) & ~ecc_write_req;
	assign lookup_addr_ic0 = (branch_spec_i ? addr_i : prefetch_addr_q);
	assign lookup_index_ic0 = lookup_addr_ic0[INDEX_HI:LINE_W];
	assign fill_req_ic0 = |fill_ram_req;
	assign fill_index_ic0 = fill_ram_req_addr[INDEX_HI:LINE_W];
	assign fill_tag_ic0 = {~inval_prog_q & ~ecc_write_req, fill_ram_req_addr[ADDR_W - 1:INDEX_HI + 1]};
	assign fill_wdata_ic0 = fill_ram_req_data;
	assign branch_suppress = branch_spec_i & ~branch_i;
	assign lookup_grant_ic0 = lookup_req_ic0 & ~branch_suppress;
	assign fill_grant_ic0 = ((fill_req_ic0 & (~lookup_req_ic0 | branch_suppress)) & ~inval_prog_q) & ~ecc_write_req;
	assign lookup_actual_ic0 = ((lookup_grant_ic0 & icache_enable_i) & ~inval_prog_q) & ~start_inval;
	assign tag_req_ic0 = ((lookup_req_ic0 | fill_req_ic0) | inval_prog_q) | ecc_write_req;
	assign tag_index_ic0 = (inval_prog_q ? inval_index_q : (ecc_write_req ? ecc_write_index : (fill_grant_ic0 ? fill_index_ic0 : lookup_index_ic0)));
	assign tag_banks_ic0 = (ecc_write_req ? ecc_write_ways : (fill_grant_ic0 ? fill_ram_req_way : {NumWays {1'b1}}));
	assign tag_write_ic0 = (fill_grant_ic0 | inval_prog_q) | ecc_write_req;
	assign data_req_ic0 = lookup_req_ic0 | fill_req_ic0;
	assign data_index_ic0 = tag_index_ic0;
	assign data_banks_ic0 = tag_banks_ic0;
	assign data_write_ic0 = tag_write_ic0;
	generate
		if (ICacheECC) begin : gen_ecc_wdata
			wire [21:0] tag_ecc_input_padded;
			wire [27:0] tag_ecc_output_padded;
			wire [22 - TAG_SIZE:0] tag_ecc_output_unused;
			assign tag_ecc_input_padded = {{22 - TAG_SIZE {1'b0}}, fill_tag_ic0};
			assign tag_ecc_output_unused = tag_ecc_output_padded[21:TAG_SIZE - 1];
			prim_secded_28_22_enc tag_ecc_enc(
				.in(tag_ecc_input_padded),
				.out(tag_ecc_output_padded)
			);
			assign tag_wdata_ic0 = {tag_ecc_output_padded[27:22], tag_ecc_output_padded[TAG_SIZE - 1:0]};
			prim_secded_72_64_enc data_ecc_enc(
				.in(fill_wdata_ic0),
				.out(data_wdata_ic0)
			);
		end
		else begin : gen_noecc_wdata
			assign tag_wdata_ic0 = fill_tag_ic0;
			assign data_wdata_ic0 = fill_wdata_ic0;
		end
	endgenerate
	generate
		genvar way;
		for (way = 0; way < NumWays; way = way + 1) begin : gen_rams
			prim_ram_1p #(
				.Width(TAG_SIZE_ECC),
				.Depth(NUM_LINES),
				.DataBitsPerMask(TAG_SIZE_ECC)
			) tag_bank(
				.clk_i(clk_i),
				.req_i(tag_req_ic0 & tag_banks_ic0[way]),
				.write_i(tag_write_ic0),
				.wmask_i({TAG_SIZE_ECC {1'b1}}),
				.addr_i(tag_index_ic0),
				.wdata_i(tag_wdata_ic0),
				.rdata_o(tag_rdata_ic1[way])
			);
			prim_ram_1p #(
				.Width(LINE_SIZE_ECC),
				.Depth(NUM_LINES),
				.DataBitsPerMask(LINE_SIZE_ECC)
			) data_bank(
				.clk_i(clk_i),
				.req_i(data_req_ic0 & data_banks_ic0[way]),
				.write_i(data_write_ic0),
				.wmask_i({LINE_SIZE_ECC {1'b1}}),
				.addr_i(data_index_ic0),
				.wdata_i(data_wdata_ic0),
				.rdata_o(data_rdata_ic1[way])
			);
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			lookup_valid_ic1 <= 1'b0;
		else
			lookup_valid_ic1 <= lookup_actual_ic0;
	always @(posedge clk_i)
		if (lookup_grant_ic0) begin
			lookup_addr_ic1 <= lookup_addr_ic0[ADDR_W - 1:INDEX_HI + 1];
			fill_in_ic1 <= fill_alloc_sel;
		end
	generate
		for (way = 0; way < NumWays; way = way + 1) begin : gen_tag_match
			assign tag_match_ic1[way] = tag_rdata_ic1[way][TAG_SIZE - 1:0] == {1'b1, lookup_addr_ic1[ADDR_W - 1:INDEX_HI + 1]};
			assign tag_invalid_ic1[way] = ~tag_rdata_ic1[way][TAG_SIZE - 1];
		end
	endgenerate
	assign tag_hit_ic1 = |tag_match_ic1;
	always @(*) begin
		hit_data_ic1 = 'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] way;
			for (way = 0; way < NumWays; way = way + 1)
				if (tag_match_ic1[way])
					hit_data_ic1 = hit_data_ic1 | data_rdata_ic1[way];
		end
	end
	assign lowest_invalid_way_ic1[0] = tag_invalid_ic1[0];
	assign round_robin_way_ic1[0] = round_robin_way_q[NumWays - 1];
	generate
		for (way = 1; way < NumWays; way = way + 1) begin : gen_lowest_way
			assign lowest_invalid_way_ic1[way] = tag_invalid_ic1[way] & ~|tag_invalid_ic1[way - 1:0];
			assign round_robin_way_ic1[way] = round_robin_way_q[way - 1];
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			round_robin_way_q <= {{NumWays - 1 {1'b0}}, 1'b1};
		else if (lookup_valid_ic1)
			round_robin_way_q <= round_robin_way_ic1;
	assign sel_way_ic1 = (|tag_invalid_ic1 ? lowest_invalid_way_ic1 : round_robin_way_q);
	generate
		if (ICacheECC) begin : gen_data_ecc_checking
			wire [NumWays - 1:0] tag_err_ic1;
			wire [1:0] data_err_ic1;
			wire ecc_correction_write_d;
			reg ecc_correction_write_q;
			wire [NumWays - 1:0] ecc_correction_ways_d;
			reg [NumWays - 1:0] ecc_correction_ways_q;
			reg [INDEX_W - 1:0] lookup_index_ic1;
			reg [INDEX_W - 1:0] ecc_correction_index_q;
			for (way = 0; way < NumWays; way = way + 1) begin : gen_tag_ecc
				wire [1:0] tag_err_bank_ic1;
				wire [27:0] tag_rdata_padded_ic1;
				assign tag_rdata_padded_ic1 = {tag_rdata_ic1[way][TAG_SIZE_ECC - 1-:6], {22 - TAG_SIZE {1'b0}}, tag_rdata_ic1[way][TAG_SIZE - 1:0]};
				prim_secded_28_22_dec data_ecc_dec(
					.in(tag_rdata_padded_ic1),
					.d_o(),
					.syndrome_o(),
					.err_o(tag_err_bank_ic1)
				);
				assign tag_err_ic1[way] = |tag_err_bank_ic1;
			end
			prim_secded_72_64_dec data_ecc_dec(
				.in(hit_data_ic1),
				.d_o(),
				.syndrome_o(),
				.err_o(data_err_ic1)
			);
			assign ecc_err_ic1 = lookup_valid_ic1 & (|data_err_ic1 | |tag_err_ic1);
			assign ecc_correction_ways_d = {NumWays {|tag_err_ic1}} | (tag_match_ic1 & {NumWays {|data_err_ic1}});
			assign ecc_correction_write_d = ecc_err_ic1;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					ecc_correction_write_q <= 1'b0;
				else
					ecc_correction_write_q <= ecc_correction_write_d;
			always @(posedge clk_i)
				if (lookup_grant_ic0)
					lookup_index_ic1 <= lookup_addr_ic0[INDEX_HI-:INDEX_W];
			always @(posedge clk_i)
				if (ecc_err_ic1) begin
					ecc_correction_ways_q <= ecc_correction_ways_d;
					ecc_correction_index_q <= lookup_index_ic1;
				end
			assign ecc_write_req = ecc_correction_write_q;
			assign ecc_write_ways = ecc_correction_ways_q;
			assign ecc_write_index = ecc_correction_index_q;
		end
		else begin : gen_no_data_ecc
			assign ecc_err_ic1 = 1'b0;
			assign ecc_write_req = 1'b0;
			assign ecc_write_ways = {NumWays {1'sb0}};
			assign ecc_write_index = {INDEX_W {1'sb0}};
		end
	endgenerate
	generate
		if (BranchCache) begin : gen_caching_logic
			localparam [31:0] CACHE_AHEAD = 2;
			localparam [31:0] CACHE_CNT_W = (CACHE_AHEAD == 1 ? 1 : 2);
			wire cache_cnt_dec;
			wire [CACHE_CNT_W - 1:0] cache_cnt_d;
			reg [CACHE_CNT_W - 1:0] cache_cnt_q;
			assign cache_cnt_dec = lookup_grant_ic0 & |cache_cnt_q;
			assign cache_cnt_d = (branch_i ? CACHE_AHEAD[CACHE_CNT_W - 1:0] : cache_cnt_q - {{CACHE_CNT_W - 1 {1'b0}}, cache_cnt_dec});
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					cache_cnt_q <= {CACHE_CNT_W {1'sb0}};
				else
					cache_cnt_q <= cache_cnt_d;
			assign fill_cache_new = (((branch_i | |cache_cnt_q) & icache_enable_i) & ~icache_inval_i) & ~inval_prog_q;
		end
		else begin : gen_cache_all
			assign fill_cache_new = (icache_enable_i & ~start_inval) & ~inval_prog_q;
		end
	endgenerate
	always @(*) begin
		fb_fill_level = {2 {1'sb0}};
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_busy_q[i] & ~fill_stale_q[i])
					fb_fill_level = fb_fill_level + {1'b0, 1'b1};
		end
	end
	assign gnt_or_pmp_err = instr_gnt_i | instr_pmp_err_i;
	assign gnt_not_pmp_err = instr_gnt_i & ~instr_pmp_err_i;
	assign fill_new_alloc = lookup_grant_ic0;
	assign fill_spec_req = (SpecRequest | branch_i) & ~|fill_ext_req;
	assign fill_spec_done = fill_spec_req & gnt_not_pmp_err;
	assign fill_spec_hold = fill_spec_req & ~gnt_or_pmp_err;
	generate
		genvar fb;
		for (fb = 0; fb < NUM_FB; fb = fb + 1) begin : gen_fbs
			if (fb == 0) begin : gen_fb_zero
				assign fill_alloc_sel[fb] = ~fill_busy_q[fb];
			end
			else begin : gen_fb_rest
				assign fill_alloc_sel[fb] = ~fill_busy_q[fb] & &fill_busy_q[fb - 1:0];
			end
			assign fill_alloc[fb] = fill_alloc_sel[fb] & fill_new_alloc;
			assign fill_busy_d[fb] = fill_alloc[fb] | (fill_busy_q[fb] & ~fill_done[fb]);
			assign fill_older_d[fb * NUM_FB+:NUM_FB] = (fill_alloc[fb] ? fill_busy_q : fill_older_q[fb * NUM_FB+:NUM_FB]) & ~fill_done;
			assign fill_done[fb] = ((((fill_ram_done_q[fb] | fill_hit_q[fb]) | ~fill_cache_q[fb]) | |fill_err_q[fb * LINE_BEATS+:LINE_BEATS]) & ((fill_out_done[fb] | fill_stale_q[fb]) | branch_i)) & fill_rvd_done[fb];
			assign fill_stale_d[fb] = fill_busy_q[fb] & (branch_i | fill_stale_q[fb]);
			assign fill_cache_d[fb] = (fill_alloc[fb] & fill_cache_new) | (((fill_cache_q[fb] & fill_busy_q[fb]) & icache_enable_i) & ~icache_inval_i);
			assign fill_hit_ic1[fb] = ((lookup_valid_ic1 & fill_in_ic1[fb]) & tag_hit_ic1) & ~ecc_err_ic1;
			assign fill_hit_d[fb] = fill_hit_ic1[fb] | (fill_hit_q[fb] & fill_busy_q[fb]);
			assign fill_ext_req[fb] = fill_busy_q[fb] & ~fill_ext_done[fb];
			assign fill_ext_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] = (fill_alloc[fb] ? {{LINE_BEATS_W {1'b0}}, fill_spec_done} : fill_ext_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] + {{LINE_BEATS_W {1'b0}}, fill_ext_arb[fb] & gnt_not_pmp_err});
			assign fill_ext_hold_d[fb] = (fill_alloc[fb] & fill_spec_hold) | (fill_ext_arb[fb] & ~gnt_or_pmp_err);
			assign fill_ext_done[fb] = ((((fill_ext_cnt_q[(fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W : LINE_BEATS_W - LINE_BEATS_W)] | fill_hit_ic1[fb]) | fill_hit_q[fb]) | fill_err_q[(fb * LINE_BEATS) + fill_ext_off[fb * LINE_BEATS_W+:LINE_BEATS_W]]) | (~fill_cache_q[fb] & (branch_i | fill_stale_q[fb]))) & ~fill_ext_hold_q[fb];
			assign fill_rvd_exp[fb] = fill_busy_q[fb] & ~fill_rvd_done[fb];
			assign fill_rvd_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] = (fill_alloc[fb] ? {(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W) {1'sb0}} : fill_rvd_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] + {{LINE_BEATS_W {1'b0}}, fill_rvd_arb[fb]});
			assign fill_rvd_done[fb] = fill_ext_done[fb] & (fill_rvd_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] == fill_ext_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)]);
			assign fill_out_req[fb] = ((fill_busy_q[fb] & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & ((((fill_hit_ic1[fb] | fill_hit_q[fb]) | fill_err_q[(fb * LINE_BEATS) + fill_out_cnt_q[(LINE_BEATS_W >= 0 ? (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1)) : (((fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1))) + LINE_BEATS_W) - 1)-:LINE_BEATS_W]]) | (fill_rvd_beat[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] > fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)])) | fill_rvd_arb[fb]);
			assign fill_out_grant[fb] = fill_out_arb[fb] & output_ready;
			assign fill_out_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] = (fill_alloc[fb] ? {1'b0, lookup_addr_ic0[LINE_W - 1:BUS_W]} : fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] + {{LINE_BEATS_W {1'b0}}, fill_out_grant[fb]});
			assign fill_out_done[fb] = fill_out_cnt_q[(fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W : LINE_BEATS_W - LINE_BEATS_W)];
			assign fill_ram_req[fb] = ((((fill_busy_q[fb] & fill_rvd_cnt_q[(fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W : LINE_BEATS_W - LINE_BEATS_W)]) & ~fill_hit_q[fb]) & fill_cache_q[fb]) & ~|fill_err_q[fb * LINE_BEATS+:LINE_BEATS]) & ~fill_ram_done_q[fb];
			assign fill_ram_done_d[fb] = fill_ram_arb[fb] | (fill_ram_done_q[fb] & fill_busy_q[fb]);
			assign fill_rvd_beat[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] = {1'b0, fill_addr_q[fb][LINE_W - 1:BUS_W]} + fill_rvd_cnt_q[(LINE_BEATS_W >= 0 ? (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? (LINE_BEATS_W >= 0 ? LINE_BEATS_W : (LINE_BEATS_W + (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) - 1) : LINE_BEATS_W - (LINE_BEATS_W >= 0 ? LINE_BEATS_W : (LINE_BEATS_W + (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) - 1)) : (((fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? (LINE_BEATS_W >= 0 ? LINE_BEATS_W : (LINE_BEATS_W + (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) - 1) : LINE_BEATS_W - (LINE_BEATS_W >= 0 ? LINE_BEATS_W : (LINE_BEATS_W + (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) - 1))) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) - 1)-:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)];
			assign fill_ext_off[fb * LINE_BEATS_W+:LINE_BEATS_W] = fill_addr_q[fb][LINE_W - 1:BUS_W] + fill_ext_cnt_q[(LINE_BEATS_W >= 0 ? (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1)) : (((fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1))) + LINE_BEATS_W) - 1)-:LINE_BEATS_W];
			assign fill_rvd_off[fb * LINE_BEATS_W+:LINE_BEATS_W] = fill_rvd_beat[(LINE_BEATS_W >= 0 ? (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1)) : (((fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)) + (LINE_BEATS_W >= 0 ? LINE_BEATS_W - 1 : LINE_BEATS_W - (LINE_BEATS_W - 1))) + LINE_BEATS_W) - 1)-:LINE_BEATS_W];
			assign fill_ext_arb[fb] = fill_ext_req[fb] & ~|(fill_ext_req & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_ram_arb[fb] = (fill_ram_req[fb] & fill_grant_ic0) & ~|(fill_ram_req & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_data_sel[fb] = ~|(((fill_busy_q & ~fill_out_done) & ~fill_stale_q) & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_out_arb[fb] = fill_out_req[fb] & fill_data_sel[fb];
			assign fill_rvd_arb[fb] = (instr_rvalid_i & fill_rvd_exp[fb]) & ~|(fill_rvd_exp & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_data_reg[fb] = (((fill_busy_q[fb] & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & fill_data_sel[fb]) & (((fill_rvd_beat[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] > fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)]) | fill_hit_q[fb]) | |fill_err_q[fb * LINE_BEATS+:LINE_BEATS]);
			assign fill_data_hit[fb] = (fill_busy_q[fb] & fill_hit_ic1[fb]) & fill_data_sel[fb];
			assign fill_data_rvd[fb] = ((((((fill_busy_q[fb] & fill_rvd_arb[fb]) & ~fill_hit_q[fb]) & ~fill_hit_ic1[fb]) & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & (fill_rvd_beat[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] == fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)])) & fill_data_sel[fb];
			assign fill_entry_en[fb] = fill_alloc[fb] | fill_busy_q[fb];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					fill_busy_q[fb] <= 1'b0;
					fill_older_q[fb * NUM_FB+:NUM_FB] <= {NUM_FB {1'sb0}};
					fill_stale_q[fb] <= 1'b0;
					fill_cache_q[fb] <= 1'b0;
					fill_hit_q[fb] <= 1'b0;
					fill_ext_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= {(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W) {1'sb0}};
					fill_ext_hold_q[fb] <= 1'b0;
					fill_rvd_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= {(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W) {1'sb0}};
					fill_ram_done_q[fb] <= 1'b0;
					fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= {(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W) {1'sb0}};
				end
				else if (fill_entry_en[fb]) begin
					fill_busy_q[fb] <= fill_busy_d[fb];
					fill_older_q[fb * NUM_FB+:NUM_FB] <= fill_older_d[fb * NUM_FB+:NUM_FB];
					fill_stale_q[fb] <= fill_stale_d[fb];
					fill_cache_q[fb] <= fill_cache_d[fb];
					fill_hit_q[fb] <= fill_hit_d[fb];
					fill_ext_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= fill_ext_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)];
					fill_ext_hold_q[fb] <= fill_ext_hold_d[fb];
					fill_rvd_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= fill_rvd_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)];
					fill_ram_done_q[fb] <= fill_ram_done_d[fb];
					fill_out_cnt_q[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)] <= fill_out_cnt_d[(LINE_BEATS_W >= 0 ? 0 : LINE_BEATS_W) + (fb * (LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W))+:(LINE_BEATS_W >= 0 ? LINE_BEATS_W + 1 : 1 - LINE_BEATS_W)];
				end
			assign fill_addr_en[fb] = fill_alloc[fb];
			assign fill_way_en[fb] = lookup_valid_ic1 & fill_in_ic1[fb];
			always @(posedge clk_i)
				if (fill_addr_en[fb])
					fill_addr_q[fb] <= lookup_addr_ic0;
			always @(posedge clk_i)
				if (fill_way_en[fb])
					fill_way_q[fb] <= sel_way_ic1;
			assign fill_data_d[fb] = (fill_hit_ic1[fb] ? hit_data_ic1[LineSize - 1:0] : {LINE_BEATS {instr_rdata_i}});
			genvar b;
			for (b = 0; b < LINE_BEATS; b = b + 1) begin : gen_data_buf
				assign fill_err_d[(fb * LINE_BEATS) + b] = (((((instr_pmp_err_i & fill_alloc[fb]) & fill_spec_req) & (lookup_addr_ic0[LINE_W - 1:BUS_W] == b[LINE_BEATS_W - 1:0])) | ((instr_pmp_err_i & fill_ext_arb[fb]) & (fill_ext_off[fb * LINE_BEATS_W+:LINE_BEATS_W] == b[LINE_BEATS_W - 1:0]))) | ((fill_rvd_arb[fb] & instr_err_i) & (fill_rvd_off[fb * LINE_BEATS_W+:LINE_BEATS_W] == b[LINE_BEATS_W - 1:0]))) | (fill_busy_q[fb] & fill_err_q[(fb * LINE_BEATS) + b]);
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						fill_err_q[(fb * LINE_BEATS) + b] <= 1'b0;
					else if (fill_entry_en[fb])
						fill_err_q[(fb * LINE_BEATS) + b] <= fill_err_d[(fb * LINE_BEATS) + b];
				assign fill_data_en[(fb * LINE_BEATS) + b] = fill_hit_ic1[fb] | ((fill_rvd_arb[fb] & ~fill_hit_q[fb]) & (fill_rvd_off[fb * LINE_BEATS_W+:LINE_BEATS_W] == b[LINE_BEATS_W - 1:0]));
				always @(posedge clk_i)
					if (fill_data_en[(fb * LINE_BEATS) + b])
						fill_data_q[fb][b * BusWidth+:BusWidth] <= fill_data_d[fb][b * BusWidth+:BusWidth];
			end
		end
	endgenerate
	always @(*) begin
		fill_ext_req_addr = {((ADDR_W - 1) >= BUS_W ? ((ADDR_W - 1) - BUS_W) + 1 : (BUS_W - (ADDR_W - 1)) + 1) {1'sb0}};
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_ext_arb[i])
					fill_ext_req_addr = fill_ext_req_addr | {fill_addr_q[i][ADDR_W - 1:LINE_W], fill_ext_off[i * LINE_BEATS_W+:LINE_BEATS_W]};
		end
	end
	always @(*) begin
		fill_ram_req_addr = {ADDR_W {1'sb0}};
		fill_ram_req_way = {NumWays {1'sb0}};
		fill_ram_req_data = {LineSize {1'sb0}};
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_ram_arb[i]) begin
					fill_ram_req_addr = fill_ram_req_addr | fill_addr_q[i];
					fill_ram_req_way = fill_ram_req_way | fill_way_q[i];
					fill_ram_req_data = fill_ram_req_data | fill_data_q[i];
				end
		end
	end
	always @(*) begin
		fill_out_data = {LineSize {1'sb0}};
		fill_out_err = {LINE_BEATS {1'sb0}};
		begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_data_reg[i]) begin
					fill_out_data = fill_out_data | fill_data_q[i];
					fill_out_err = fill_out_err | (fill_err_q[i * LINE_BEATS+:LINE_BEATS] & ~{LINE_BEATS {fill_hit_q[i]}});
				end
		end
	end
	assign instr_req = ((SpecRequest | branch_i) & lookup_grant_ic0) | |fill_ext_req;
	assign instr_addr = (|fill_ext_req ? fill_ext_req_addr : lookup_addr_ic0[ADDR_W - 1:BUS_W]);
	assign instr_req_o = instr_req;
	assign instr_addr_o = {instr_addr[ADDR_W - 1:BUS_W], {BUS_W {1'b0}}};
	assign line_data = (|fill_data_hit ? hit_data_ic1[LineSize - 1:0] : fill_out_data);
	assign line_err = (|fill_data_hit ? {LINE_BEATS {1'b0}} : fill_out_err);
	always @(*) begin
		line_data_muxed = {32 {1'sb0}};
		line_err_muxed = 1'b0;
		begin : sv2v_autoblock_6
			reg signed [31:0] i;
			for (i = 0; i < LINE_BEATS; i = i + 1)
				if ((output_addr_q[LINE_W - 1:BUS_W] + {{LINE_BEATS_W - 1 {1'b0}}, skid_valid_q}) == i[LINE_BEATS_W - 1:0]) begin
					line_data_muxed = line_data_muxed | line_data[i * 32+:32];
					line_err_muxed = line_err_muxed | line_err[i];
				end
		end
	end
	assign output_data = (|fill_data_rvd ? instr_rdata_i : line_data_muxed);
	assign output_err = (|fill_data_rvd ? instr_err_i : line_err_muxed);
	assign data_valid = |fill_out_arb;
	assign skid_data_d = output_data[31:16];
	assign skid_en = data_valid & (ready_i | skid_ready);
	always @(posedge clk_i)
		if (skid_en) begin
			skid_data_q <= skid_data_d;
			skid_err_q <= output_err;
		end
	assign skid_complete_instr = skid_valid_q & ((skid_data_q[1:0] != 2'b11) | skid_err_q);
	assign skid_ready = (output_addr_q[1] & ~skid_valid_q) & (~output_compressed | output_err);
	assign output_ready = (ready_i | skid_ready) & ~skid_complete_instr;
	assign output_compressed = rdata_o[1:0] != 2'b11;
	assign skid_valid_d = (branch_i ? 1'b0 : (skid_valid_q ? ~(ready_i & ((skid_data_q[1:0] != 2'b11) | skid_err_q)) : ((output_addr_q[1] & (~output_compressed | output_err)) | (((~output_addr_q[1] & output_compressed) & ~output_err) & ready_i)) & data_valid));
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			skid_valid_q <= 1'b0;
		else
			skid_valid_q <= skid_valid_d;
	assign output_valid = skid_complete_instr | (data_valid & (((~output_addr_q[1] | skid_valid_q) | output_err) | (output_data[17:16] != 2'b11)));
	assign output_addr_en = branch_i | (ready_i & valid_o);
	assign addr_incr_two = output_compressed & ~err_o;
	assign output_addr_d = (branch_i ? addr_i[31:1] : output_addr_q[31:1] + {29'd0, ~addr_incr_two, addr_incr_two});
	always @(posedge clk_i)
		if (output_addr_en)
			output_addr_q <= output_addr_d;
	always @(*) begin
		output_data_lo = {16 {1'sb0}};
		begin : sv2v_autoblock_7
			reg signed [31:0] i;
			for (i = 0; i < OUTPUT_BEATS; i = i + 1)
				if (output_addr_q[BUS_W - 1:1] == i[BUS_W - 2:0])
					output_data_lo = output_data_lo | output_data[i * 16+:16];
		end
	end
	always @(*) begin
		output_data_hi = {16 {1'sb0}};
		begin : sv2v_autoblock_8
			reg signed [31:0] i;
			for (i = 0; i < (OUTPUT_BEATS - 1); i = i + 1)
				if (output_addr_q[BUS_W - 1:1] == i[BUS_W - 2:0])
					output_data_hi = output_data_hi | output_data[(i + 1) * 16+:16];
		end
		if (&output_addr_q[BUS_W - 1:1])
			output_data_hi = output_data_hi | output_data[15:0];
	end
	assign valid_o = output_valid;
	assign rdata_o = {output_data_hi, (skid_valid_q ? skid_data_q : output_data_lo)};
	assign addr_o = {output_addr_q, 1'b0};
	assign err_o = (skid_valid_q & skid_err_q) | (~skid_complete_instr & output_err);
	assign err_plus2_o = skid_valid_q & ~skid_err_q;
	assign start_inval = (~reset_inval_q | icache_inval_i) & ~inval_prog_q;
	assign inval_prog_d = start_inval | (inval_prog_q & ~inval_done);
	assign inval_done = &inval_index_q;
	assign inval_index_d = (start_inval ? {INDEX_W {1'sb0}} : inval_index_q + {{INDEX_W - 1 {1'b0}}, 1'b1});
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			inval_prog_q <= 1'b0;
			reset_inval_q <= 1'b0;
		end
		else begin
			inval_prog_q <= inval_prog_d;
			reset_inval_q <= 1'b1;
		end
	always @(posedge clk_i)
		if (inval_prog_d)
			inval_index_q <= inval_index_d;
	assign busy_o = inval_prog_q | |(fill_busy_q & ~fill_rvd_done);
endmodule
