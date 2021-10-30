module ibex_icache (
	clk_i,
	rst_ni,
	req_i,
	branch_i,
	branch_spec_i,
	predicted_branch_i,
	branch_mispredict_i,
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
	ic_tag_req_o,
	ic_tag_write_o,
	ic_tag_addr_o,
	ic_tag_wdata_o,
	ic_tag_rdata_i,
	ic_data_req_o,
	ic_data_write_o,
	ic_data_addr_o,
	ic_data_wdata_o,
	ic_data_rdata_i,
	icache_enable_i,
	icache_inval_i,
	busy_o
);
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	localparam [31:0] ibex_pkg_BUS_SIZE = 32;
	parameter [31:0] BusSizeECC = ibex_pkg_BUS_SIZE;
	localparam [31:0] ibex_pkg_ADDR_W = 32;
	localparam [31:0] ibex_pkg_IC_LINE_SIZE = 64;
	localparam [31:0] ibex_pkg_IC_LINE_BYTES = 8;
	localparam [31:0] ibex_pkg_IC_NUM_WAYS = 2;
	localparam [31:0] ibex_pkg_IC_SIZE_BYTES = 4096;
	localparam [31:0] ibex_pkg_IC_NUM_LINES = 256;
	localparam [31:0] ibex_pkg_IC_INDEX_W = 8;
	localparam [31:0] ibex_pkg_IC_LINE_W = 3;
	localparam [31:0] ibex_pkg_IC_TAG_SIZE = 22;
	parameter [31:0] TagSizeECC = ibex_pkg_IC_TAG_SIZE;
	parameter [31:0] LineSizeECC = ibex_pkg_IC_LINE_SIZE;
	parameter [0:0] BranchCache = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire req_i;
	input wire branch_i;
	input wire branch_spec_i;
	input wire predicted_branch_i;
	input wire branch_mispredict_i;
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
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	input wire instr_pmp_err_i;
	input wire instr_rvalid_i;
	output wire [1:0] ic_tag_req_o;
	output wire ic_tag_write_o;
	output wire [7:0] ic_tag_addr_o;
	output wire [TagSizeECC - 1:0] ic_tag_wdata_o;
	input wire [(ibex_pkg_IC_NUM_WAYS * TagSizeECC) - 1:0] ic_tag_rdata_i;
	output wire [1:0] ic_data_req_o;
	output wire ic_data_write_o;
	output wire [7:0] ic_data_addr_o;
	output wire [LineSizeECC - 1:0] ic_data_wdata_o;
	input wire [(ibex_pkg_IC_NUM_WAYS * LineSizeECC) - 1:0] ic_data_rdata_i;
	input wire icache_enable_i;
	input wire icache_inval_i;
	output wire busy_o;
	localparam [31:0] NUM_FB = 4;
	localparam [31:0] FB_THRESHOLD = 2;
	wire [31:0] lookup_addr_aligned;
	wire [31:0] branch_mispredict_addr;
	wire [31:0] prefetch_addr_d;
	reg [31:0] prefetch_addr_q;
	wire prefetch_addr_en;
	wire branch_or_mispredict;
	wire branch_suppress;
	wire lookup_throttle;
	wire lookup_req_ic0;
	wire [31:0] lookup_addr_ic0;
	wire [7:0] lookup_index_ic0;
	wire fill_req_ic0;
	wire [7:0] fill_index_ic0;
	wire [21:0] fill_tag_ic0;
	wire [63:0] fill_wdata_ic0;
	wire lookup_grant_ic0;
	wire lookup_actual_ic0;
	wire fill_grant_ic0;
	wire tag_req_ic0;
	wire [7:0] tag_index_ic0;
	wire [1:0] tag_banks_ic0;
	wire tag_write_ic0;
	wire [TagSizeECC - 1:0] tag_wdata_ic0;
	wire data_req_ic0;
	wire [7:0] data_index_ic0;
	wire [1:0] data_banks_ic0;
	wire data_write_ic0;
	wire [LineSizeECC - 1:0] data_wdata_ic0;
	wire [(ibex_pkg_IC_NUM_WAYS * TagSizeECC) - 1:0] tag_rdata_ic1;
	wire [(ibex_pkg_IC_NUM_WAYS * LineSizeECC) - 1:0] data_rdata_ic1;
	reg [LineSizeECC - 1:0] hit_data_ecc_ic1;
	wire [63:0] hit_data_ic1;
	reg lookup_valid_ic1;
	localparam [31:0] ibex_pkg_IC_INDEX_HI = 10;
	reg [31:11] lookup_addr_ic1;
	wire [1:0] tag_match_ic1;
	wire tag_hit_ic1;
	wire [1:0] tag_invalid_ic1;
	wire [1:0] lowest_invalid_way_ic1;
	wire [1:0] round_robin_way_ic1;
	reg [1:0] round_robin_way_q;
	wire [1:0] sel_way_ic1;
	wire ecc_err_ic1;
	wire ecc_write_req;
	wire [1:0] ecc_write_ways;
	wire [7:0] ecc_write_index;
	wire gnt_or_pmp_err;
	wire gnt_not_pmp_err;
	reg [1:0] fb_fill_level;
	wire fill_cache_new;
	wire fill_new_alloc;
	wire fill_spec_req;
	wire fill_spec_done;
	wire fill_spec_hold;
	wire [15:0] fill_older_d;
	reg [15:0] fill_older_q;
	wire [3:0] fill_alloc_sel;
	wire [3:0] fill_alloc;
	wire [3:0] fill_busy_d;
	reg [3:0] fill_busy_q;
	wire [3:0] fill_done;
	reg [3:0] fill_in_ic1;
	wire [3:0] fill_stale_d;
	reg [3:0] fill_stale_q;
	wire [3:0] fill_cache_d;
	reg [3:0] fill_cache_q;
	wire [3:0] fill_hit_ic1;
	wire [3:0] fill_hit_d;
	reg [3:0] fill_hit_q;
	localparam [31:0] ibex_pkg_BUS_BYTES = 4;
	localparam [31:0] ibex_pkg_IC_LINE_BEATS = 2;
	localparam [31:0] ibex_pkg_IC_LINE_BEATS_W = 1;
	wire [7:0] fill_ext_cnt_d;
	reg [7:0] fill_ext_cnt_q;
	wire [3:0] fill_ext_hold_d;
	reg [3:0] fill_ext_hold_q;
	wire [3:0] fill_ext_done_d;
	reg [3:0] fill_ext_done_q;
	wire [7:0] fill_rvd_cnt_d;
	reg [7:0] fill_rvd_cnt_q;
	wire [3:0] fill_rvd_done;
	wire [3:0] fill_ram_done_d;
	reg [3:0] fill_ram_done_q;
	wire [3:0] fill_out_grant;
	wire [7:0] fill_out_cnt_d;
	reg [7:0] fill_out_cnt_q;
	wire [3:0] fill_out_done;
	wire [3:0] fill_ext_req;
	wire [3:0] fill_rvd_exp;
	wire [3:0] fill_ram_req;
	wire [3:0] fill_out_req;
	wire [3:0] fill_data_sel;
	wire [3:0] fill_data_reg;
	wire [3:0] fill_data_hit;
	wire [3:0] fill_data_rvd;
	wire [3:0] fill_ext_off;
	wire [3:0] fill_rvd_off;
	wire [7:0] fill_ext_beat;
	wire [7:0] fill_rvd_beat;
	wire [3:0] fill_ext_arb;
	wire [3:0] fill_ram_arb;
	wire [3:0] fill_out_arb;
	wire [3:0] fill_rvd_arb;
	wire [3:0] fill_entry_en;
	wire [3:0] fill_addr_en;
	wire [3:0] fill_way_en;
	wire [7:0] fill_data_en;
	wire [7:0] fill_err_d;
	reg [7:0] fill_err_q;
	reg [31:0] fill_addr_q [0:3];
	reg [1:0] fill_way_q [0:3];
	wire [63:0] fill_data_d [0:3];
	reg [63:0] fill_data_q [0:3];
	localparam [31:0] ibex_pkg_BUS_W = 2;
	reg [31:ibex_pkg_BUS_W] fill_ext_req_addr;
	reg [31:0] fill_ram_req_addr;
	reg [1:0] fill_ram_req_way;
	reg [63:0] fill_ram_req_data;
	reg [63:0] fill_out_data;
	reg [1:0] fill_out_err;
	wire instr_req;
	wire [31:ibex_pkg_BUS_W] instr_addr;
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
	wire [31:1] output_addr_incr;
	wire [31:1] output_addr_d;
	reg [31:1] output_addr_q;
	reg [15:0] output_data_lo;
	reg [15:0] output_data_hi;
	wire data_valid;
	wire output_ready;
	wire [63:0] line_data;
	wire [1:0] line_err;
	reg [31:0] line_data_muxed;
	reg line_err_muxed;
	wire [31:0] output_data;
	wire output_err;
	wire start_inval;
	wire inval_done;
	reg reset_inval_q;
	wire inval_prog_d;
	reg inval_prog_q;
	wire [7:0] inval_index_d;
	reg [7:0] inval_index_q;
	generate
		if (BranchPredictor) begin : g_branch_predictor
			reg [31:0] branch_mispredict_addr_q;
			wire branch_mispredict_addr_en;
			assign branch_mispredict_addr_en = branch_i & predicted_branch_i;
			always @(posedge clk_i)
				if (branch_mispredict_addr_en)
					branch_mispredict_addr_q <= {output_addr_incr, 1'b0};
			assign branch_mispredict_addr = branch_mispredict_addr_q;
		end
		else begin : g_no_branch_predictor
			wire unused_predicted_branch;
			assign unused_predicted_branch = predicted_branch_i;
			assign branch_mispredict_addr = {32 {1'sb0}};
		end
	endgenerate
	assign branch_or_mispredict = branch_i | branch_mispredict_i;
	assign lookup_addr_aligned = {lookup_addr_ic0[31:ibex_pkg_IC_LINE_W], {ibex_pkg_IC_LINE_W {1'b0}}};
	assign prefetch_addr_d = (lookup_grant_ic0 ? lookup_addr_aligned + {{28 {1'b0}}, 1'b1, {ibex_pkg_IC_LINE_W {1'b0}}} : (branch_i ? addr_i : branch_mispredict_addr));
	assign prefetch_addr_en = branch_or_mispredict | lookup_grant_ic0;
	always @(posedge clk_i)
		if (prefetch_addr_en)
			prefetch_addr_q <= prefetch_addr_d;
	assign lookup_throttle = fb_fill_level > FB_THRESHOLD[1:0];
	assign lookup_req_ic0 = ((req_i & ~&fill_busy_q) & (branch_or_mispredict | ~lookup_throttle)) & ~ecc_write_req;
	assign lookup_addr_ic0 = (branch_spec_i ? addr_i : (branch_mispredict_i ? branch_mispredict_addr : prefetch_addr_q));
	assign lookup_index_ic0 = lookup_addr_ic0[ibex_pkg_IC_INDEX_HI:ibex_pkg_IC_LINE_W];
	assign fill_req_ic0 = |fill_ram_req;
	assign fill_index_ic0 = fill_ram_req_addr[ibex_pkg_IC_INDEX_HI:ibex_pkg_IC_LINE_W];
	assign fill_tag_ic0 = {~inval_prog_q & ~ecc_write_req, fill_ram_req_addr[31:11]};
	assign fill_wdata_ic0 = fill_ram_req_data;
	assign branch_suppress = branch_spec_i & ~branch_i;
	assign lookup_grant_ic0 = lookup_req_ic0 & ~branch_suppress;
	assign fill_grant_ic0 = ((fill_req_ic0 & (~lookup_req_ic0 | branch_suppress)) & ~inval_prog_q) & ~ecc_write_req;
	assign lookup_actual_ic0 = ((lookup_grant_ic0 & icache_enable_i) & ~inval_prog_q) & ~start_inval;
	assign tag_req_ic0 = ((lookup_req_ic0 | fill_req_ic0) | inval_prog_q) | ecc_write_req;
	assign tag_index_ic0 = (inval_prog_q ? inval_index_q : (ecc_write_req ? ecc_write_index : (fill_grant_ic0 ? fill_index_ic0 : lookup_index_ic0)));
	assign tag_banks_ic0 = (ecc_write_req ? ecc_write_ways : (fill_grant_ic0 ? fill_ram_req_way : {ibex_pkg_IC_NUM_WAYS {1'b1}}));
	assign tag_write_ic0 = (fill_grant_ic0 | inval_prog_q) | ecc_write_req;
	assign data_req_ic0 = lookup_req_ic0 | fill_req_ic0;
	assign data_index_ic0 = tag_index_ic0;
	assign data_banks_ic0 = tag_banks_ic0;
	assign data_write_ic0 = tag_write_ic0;
	generate
		if (ICacheECC) begin : gen_ecc_wdata
			wire [21:0] tag_ecc_input_padded;
			wire [27:0] tag_ecc_output_padded;
			wire [0:0] tag_ecc_output_unused;
			assign tag_ecc_input_padded = {fill_tag_ic0};
			assign tag_ecc_output_unused = tag_ecc_output_padded[21:21];
			prim_secded_28_22_enc tag_ecc_enc(
				.data_i(tag_ecc_input_padded),
				.data_o(tag_ecc_output_padded)
			);
			assign tag_wdata_ic0 = {tag_ecc_output_padded[27:22], tag_ecc_output_padded[21:0]};
			genvar bank;
			for (bank = 0; bank < ibex_pkg_IC_LINE_BEATS; bank = bank + 1) begin : gen_ecc_banks
				prim_secded_39_32_enc data_ecc_enc(
					.data_i(fill_wdata_ic0[bank * ibex_pkg_BUS_SIZE+:ibex_pkg_BUS_SIZE]),
					.data_o(data_wdata_ic0[bank * BusSizeECC+:BusSizeECC])
				);
			end
		end
		else begin : gen_noecc_wdata
			assign tag_wdata_ic0 = fill_tag_ic0;
			assign data_wdata_ic0 = fill_wdata_ic0;
		end
	endgenerate
	assign ic_tag_req_o = {ibex_pkg_IC_NUM_WAYS {tag_req_ic0}} & tag_banks_ic0;
	assign ic_tag_write_o = tag_write_ic0;
	assign ic_tag_addr_o = tag_index_ic0;
	assign ic_tag_wdata_o = tag_wdata_ic0;
	assign tag_rdata_ic1 = ic_tag_rdata_i;
	assign ic_data_req_o = {ibex_pkg_IC_NUM_WAYS {data_req_ic0}} & data_banks_ic0;
	assign ic_data_write_o = data_write_ic0;
	assign ic_data_addr_o = data_index_ic0;
	assign ic_data_wdata_o = data_wdata_ic0;
	assign data_rdata_ic1 = ic_data_rdata_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			lookup_valid_ic1 <= 1'b0;
		else
			lookup_valid_ic1 <= lookup_actual_ic0;
	always @(posedge clk_i)
		if (lookup_grant_ic0) begin
			lookup_addr_ic1 <= lookup_addr_ic0[31:11];
			fill_in_ic1 <= fill_alloc_sel;
		end
	generate
		genvar way;
		for (way = 0; way < ibex_pkg_IC_NUM_WAYS; way = way + 1) begin : gen_tag_match
			assign tag_match_ic1[way] = tag_rdata_ic1[((1 - way) * TagSizeECC) + 21-:22] == {1'b1, lookup_addr_ic1[31:11]};
			assign tag_invalid_ic1[way] = ~tag_rdata_ic1[((1 - way) * TagSizeECC) + 21];
		end
	endgenerate
	assign tag_hit_ic1 = |tag_match_ic1;
	always @(*) begin
		hit_data_ecc_ic1 = 'b0;
		begin : sv2v_autoblock_4
			reg signed [31:0] way;
			for (way = 0; way < ibex_pkg_IC_NUM_WAYS; way = way + 1)
				if (tag_match_ic1[way])
					hit_data_ecc_ic1 = hit_data_ecc_ic1 | data_rdata_ic1[(1 - way) * LineSizeECC+:LineSizeECC];
		end
	end
	assign lowest_invalid_way_ic1[0] = tag_invalid_ic1[0];
	assign round_robin_way_ic1[0] = round_robin_way_q[1];
	generate
		for (way = 1; way < ibex_pkg_IC_NUM_WAYS; way = way + 1) begin : gen_lowest_way
			assign lowest_invalid_way_ic1[way] = tag_invalid_ic1[way] & ~|tag_invalid_ic1[way - 1:0];
			assign round_robin_way_ic1[way] = round_robin_way_q[way - 1];
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			round_robin_way_q <= 2'b01;
		else if (lookup_valid_ic1)
			round_robin_way_q <= round_robin_way_ic1;
	assign sel_way_ic1 = (|tag_invalid_ic1 ? lowest_invalid_way_ic1 : round_robin_way_q);
	generate
		if (ICacheECC) begin : gen_data_ecc_checking
			wire [1:0] tag_err_ic1;
			wire [3:0] data_err_ic1;
			wire ecc_correction_write_d;
			reg ecc_correction_write_q;
			wire [1:0] ecc_correction_ways_d;
			reg [1:0] ecc_correction_ways_q;
			reg [7:0] lookup_index_ic1;
			reg [7:0] ecc_correction_index_q;
			for (way = 0; way < ibex_pkg_IC_NUM_WAYS; way = way + 1) begin : gen_tag_ecc
				wire [1:0] tag_err_bank_ic1;
				wire [27:0] tag_rdata_padded_ic1;
				assign tag_rdata_padded_ic1 = {tag_rdata_ic1[((1 - way) * TagSizeECC) + (TagSizeECC - 1)-:6], tag_rdata_ic1[((1 - way) * TagSizeECC) + 21-:22]};
				prim_secded_28_22_dec data_ecc_dec(
					.data_i(tag_rdata_padded_ic1),
					.data_o(),
					.syndrome_o(),
					.err_o(tag_err_bank_ic1)
				);
				assign tag_err_ic1[way] = |tag_err_bank_ic1;
			end
			genvar bank;
			for (bank = 0; bank < ibex_pkg_IC_LINE_BEATS; bank = bank + 1) begin : gen_ecc_banks
				prim_secded_39_32_dec data_ecc_dec(
					.data_i(hit_data_ecc_ic1[bank * BusSizeECC+:BusSizeECC]),
					.data_o(),
					.syndrome_o(),
					.err_o(data_err_ic1[bank * 2+:2])
				);
				assign hit_data_ic1[bank * ibex_pkg_BUS_SIZE+:ibex_pkg_BUS_SIZE] = hit_data_ecc_ic1[bank * BusSizeECC+:ibex_pkg_BUS_SIZE];
			end
			assign ecc_err_ic1 = lookup_valid_ic1 & (|data_err_ic1 | |tag_err_ic1);
			assign ecc_correction_ways_d = {ibex_pkg_IC_NUM_WAYS {|tag_err_ic1}} | (tag_match_ic1 & {ibex_pkg_IC_NUM_WAYS {|data_err_ic1}});
			assign ecc_correction_write_d = ecc_err_ic1;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					ecc_correction_write_q <= 1'b0;
				else
					ecc_correction_write_q <= ecc_correction_write_d;
			always @(posedge clk_i)
				if (lookup_grant_ic0)
					lookup_index_ic1 <= lookup_addr_ic0[ibex_pkg_IC_INDEX_HI-:ibex_pkg_IC_INDEX_W];
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
			assign ecc_write_ways = {2 {1'sb0}};
			assign ecc_write_index = {8 {1'sb0}};
			assign hit_data_ic1 = hit_data_ecc_ic1;
		end
	endgenerate
	generate
		if (BranchCache) begin : gen_caching_logic
			localparam [31:0] CACHE_AHEAD = 2;
			localparam [31:0] CACHE_CNT_W = 2;
			wire cache_cnt_dec;
			wire [1:0] cache_cnt_d;
			reg [1:0] cache_cnt_q;
			assign cache_cnt_dec = lookup_grant_ic0 & |cache_cnt_q;
			assign cache_cnt_d = (branch_i ? CACHE_AHEAD[1:0] : cache_cnt_q - {1'b0, cache_cnt_dec});
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					cache_cnt_q <= {2 {1'sb0}};
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
		begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_busy_q[i] & ~fill_stale_q[i])
					fb_fill_level = fb_fill_level + 2'b01;
		end
	end
	assign gnt_or_pmp_err = instr_gnt_i | instr_pmp_err_i;
	assign gnt_not_pmp_err = instr_gnt_i & ~instr_pmp_err_i;
	assign fill_new_alloc = lookup_grant_ic0;
	assign fill_spec_req = (~icache_enable_i | branch_or_mispredict) & ~|fill_ext_req;
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
			assign fill_done[fb] = ((((fill_ram_done_q[fb] | fill_hit_q[fb]) | ~fill_cache_q[fb]) | |fill_err_q[fb * ibex_pkg_IC_LINE_BEATS+:ibex_pkg_IC_LINE_BEATS]) & ((fill_out_done[fb] | fill_stale_q[fb]) | branch_or_mispredict)) & fill_rvd_done[fb];
			assign fill_stale_d[fb] = fill_busy_q[fb] & (branch_or_mispredict | fill_stale_q[fb]);
			assign fill_cache_d[fb] = (fill_alloc[fb] & fill_cache_new) | (((fill_cache_q[fb] & fill_busy_q[fb]) & icache_enable_i) & ~icache_inval_i);
			assign fill_hit_ic1[fb] = ((lookup_valid_ic1 & fill_in_ic1[fb]) & tag_hit_ic1) & ~ecc_err_ic1;
			assign fill_hit_d[fb] = fill_hit_ic1[fb] | (fill_hit_q[fb] & fill_busy_q[fb]);
			assign fill_ext_req[fb] = fill_busy_q[fb] & ~fill_ext_done_d[fb];
			assign fill_ext_cnt_d[fb * 2+:2] = (fill_alloc[fb] ? {{ibex_pkg_IC_LINE_BEATS_W {1'b0}}, fill_spec_done} : fill_ext_cnt_q[fb * 2+:2] + {{ibex_pkg_IC_LINE_BEATS_W {1'b0}}, fill_ext_arb[fb] & gnt_not_pmp_err});
			assign fill_ext_hold_d[fb] = (fill_alloc[fb] & fill_spec_hold) | (fill_ext_arb[fb] & ~gnt_or_pmp_err);
			assign fill_ext_done_d[fb] = (((((fill_ext_cnt_q[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W] | fill_hit_ic1[fb]) | fill_hit_q[fb]) | fill_err_q[(fb * ibex_pkg_IC_LINE_BEATS) + fill_ext_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W]]) | (~fill_cache_q[fb] & ((branch_or_mispredict | fill_stale_q[fb]) | fill_ext_beat[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W]))) & ~fill_ext_hold_q[fb]) & fill_busy_q[fb];
			assign fill_rvd_exp[fb] = fill_busy_q[fb] & ~fill_rvd_done[fb];
			assign fill_rvd_cnt_d[fb * 2+:2] = (fill_alloc[fb] ? {2 {1'sb0}} : fill_rvd_cnt_q[fb * 2+:2] + {{ibex_pkg_IC_LINE_BEATS_W {1'b0}}, fill_rvd_arb[fb]});
			assign fill_rvd_done[fb] = (fill_ext_done_q[fb] & ~fill_ext_hold_q[fb]) & (fill_rvd_cnt_q[fb * 2+:2] == fill_ext_cnt_q[fb * 2+:2]);
			assign fill_out_req[fb] = ((fill_busy_q[fb] & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & ((((fill_hit_ic1[fb] | fill_hit_q[fb]) | fill_err_q[(fb * ibex_pkg_IC_LINE_BEATS) + fill_out_cnt_q[fb * 2-:1]]) | (fill_rvd_beat[fb * 2+:2] > fill_out_cnt_q[fb * 2+:2])) | fill_rvd_arb[fb]);
			assign fill_out_grant[fb] = fill_out_arb[fb] & output_ready;
			assign fill_out_cnt_d[fb * 2+:2] = (fill_alloc[fb] ? {1'b0, lookup_addr_ic0[2:ibex_pkg_BUS_W]} : fill_out_cnt_q[fb * 2+:2] + {{ibex_pkg_IC_LINE_BEATS_W {1'b0}}, fill_out_grant[fb]});
			assign fill_out_done[fb] = fill_out_cnt_q[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W];
			assign fill_ram_req[fb] = ((((fill_busy_q[fb] & fill_rvd_cnt_q[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W]) & ~fill_hit_q[fb]) & fill_cache_q[fb]) & ~|fill_err_q[fb * ibex_pkg_IC_LINE_BEATS+:ibex_pkg_IC_LINE_BEATS]) & ~fill_ram_done_q[fb];
			assign fill_ram_done_d[fb] = fill_ram_arb[fb] | (fill_ram_done_q[fb] & fill_busy_q[fb]);
			assign fill_ext_beat[fb * 2+:2] = {1'b0, fill_addr_q[fb][2:ibex_pkg_BUS_W]} + fill_ext_cnt_q[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W-:2];
			assign fill_ext_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W] = fill_ext_beat[fb * 2-:1];
			assign fill_rvd_beat[fb * 2+:2] = {1'b0, fill_addr_q[fb][2:ibex_pkg_BUS_W]} + fill_rvd_cnt_q[(fb * 2) + ibex_pkg_IC_LINE_BEATS_W-:2];
			assign fill_rvd_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W] = fill_rvd_beat[fb * 2-:1];
			assign fill_ext_arb[fb] = fill_ext_req[fb] & ~|(fill_ext_req & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_ram_arb[fb] = (fill_ram_req[fb] & fill_grant_ic0) & ~|(fill_ram_req & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_data_sel[fb] = ~|(((fill_busy_q & ~fill_out_done) & ~fill_stale_q) & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_out_arb[fb] = fill_out_req[fb] & fill_data_sel[fb];
			assign fill_rvd_arb[fb] = (instr_rvalid_i & fill_rvd_exp[fb]) & ~|(fill_rvd_exp & fill_older_q[fb * NUM_FB+:NUM_FB]);
			assign fill_data_reg[fb] = (((fill_busy_q[fb] & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & fill_data_sel[fb]) & (((fill_rvd_beat[fb * 2+:2] > fill_out_cnt_q[fb * 2+:2]) | fill_hit_q[fb]) | |fill_err_q[fb * ibex_pkg_IC_LINE_BEATS+:ibex_pkg_IC_LINE_BEATS]);
			assign fill_data_hit[fb] = (fill_busy_q[fb] & fill_hit_ic1[fb]) & fill_data_sel[fb];
			assign fill_data_rvd[fb] = ((((((fill_busy_q[fb] & fill_rvd_arb[fb]) & ~fill_hit_q[fb]) & ~fill_hit_ic1[fb]) & ~fill_stale_q[fb]) & ~fill_out_done[fb]) & (fill_rvd_beat[fb * 2+:2] == fill_out_cnt_q[fb * 2+:2])) & fill_data_sel[fb];
			assign fill_entry_en[fb] = fill_alloc[fb] | fill_busy_q[fb];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					fill_busy_q[fb] <= 1'b0;
					fill_older_q[fb * NUM_FB+:NUM_FB] <= {4 {1'sb0}};
					fill_stale_q[fb] <= 1'b0;
					fill_cache_q[fb] <= 1'b0;
					fill_hit_q[fb] <= 1'b0;
					fill_ext_cnt_q[fb * 2+:2] <= {2 {1'sb0}};
					fill_ext_hold_q[fb] <= 1'b0;
					fill_ext_done_q[fb] <= 1'b0;
					fill_rvd_cnt_q[fb * 2+:2] <= {2 {1'sb0}};
					fill_ram_done_q[fb] <= 1'b0;
					fill_out_cnt_q[fb * 2+:2] <= {2 {1'sb0}};
				end
				else if (fill_entry_en[fb]) begin
					fill_busy_q[fb] <= fill_busy_d[fb];
					fill_older_q[fb * NUM_FB+:NUM_FB] <= fill_older_d[fb * NUM_FB+:NUM_FB];
					fill_stale_q[fb] <= fill_stale_d[fb];
					fill_cache_q[fb] <= fill_cache_d[fb];
					fill_hit_q[fb] <= fill_hit_d[fb];
					fill_ext_cnt_q[fb * 2+:2] <= fill_ext_cnt_d[fb * 2+:2];
					fill_ext_hold_q[fb] <= fill_ext_hold_d[fb];
					fill_ext_done_q[fb] <= fill_ext_done_d[fb];
					fill_rvd_cnt_q[fb * 2+:2] <= fill_rvd_cnt_d[fb * 2+:2];
					fill_ram_done_q[fb] <= fill_ram_done_d[fb];
					fill_out_cnt_q[fb * 2+:2] <= fill_out_cnt_d[fb * 2+:2];
				end
			assign fill_addr_en[fb] = fill_alloc[fb];
			assign fill_way_en[fb] = lookup_valid_ic1 & fill_in_ic1[fb];
			always @(posedge clk_i)
				if (fill_addr_en[fb])
					fill_addr_q[fb] <= lookup_addr_ic0;
			always @(posedge clk_i)
				if (fill_way_en[fb])
					fill_way_q[fb] <= sel_way_ic1;
			assign fill_data_d[fb] = (fill_hit_ic1[fb] ? hit_data_ic1 : {ibex_pkg_IC_LINE_BEATS {instr_rdata_i}});
			genvar b;
			for (b = 0; b < ibex_pkg_IC_LINE_BEATS; b = b + 1) begin : gen_data_buf
				assign fill_err_d[(fb * ibex_pkg_IC_LINE_BEATS) + b] = (((((instr_pmp_err_i & fill_alloc[fb]) & fill_spec_req) & (lookup_addr_ic0[2:ibex_pkg_BUS_W] == b[0:0])) | ((instr_pmp_err_i & fill_ext_arb[fb]) & (fill_ext_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W] == b[0:0]))) | ((fill_rvd_arb[fb] & instr_err_i) & (fill_rvd_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W] == b[0:0]))) | (fill_busy_q[fb] & fill_err_q[(fb * ibex_pkg_IC_LINE_BEATS) + b]);
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						fill_err_q[(fb * ibex_pkg_IC_LINE_BEATS) + b] <= 1'b0;
					else if (fill_entry_en[fb])
						fill_err_q[(fb * ibex_pkg_IC_LINE_BEATS) + b] <= fill_err_d[(fb * ibex_pkg_IC_LINE_BEATS) + b];
				assign fill_data_en[(fb * ibex_pkg_IC_LINE_BEATS) + b] = fill_hit_ic1[fb] | ((fill_rvd_arb[fb] & ~fill_hit_q[fb]) & (fill_rvd_off[fb * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W] == b[0:0]));
				always @(posedge clk_i)
					if (fill_data_en[(fb * ibex_pkg_IC_LINE_BEATS) + b])
						fill_data_q[fb][b * ibex_pkg_BUS_SIZE+:ibex_pkg_BUS_SIZE] <= fill_data_d[fb][b * ibex_pkg_BUS_SIZE+:ibex_pkg_BUS_SIZE];
			end
		end
	endgenerate
	always @(*) begin
		fill_ext_req_addr = {30 {1'sb0}};
		begin : sv2v_autoblock_6
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_ext_arb[i])
					fill_ext_req_addr = fill_ext_req_addr | {fill_addr_q[i][31:ibex_pkg_IC_LINE_W], fill_ext_off[i * ibex_pkg_IC_LINE_BEATS_W+:ibex_pkg_IC_LINE_BEATS_W]};
		end
	end
	always @(*) begin
		fill_ram_req_addr = {32 {1'sb0}};
		fill_ram_req_way = {2 {1'sb0}};
		fill_ram_req_data = {64 {1'sb0}};
		begin : sv2v_autoblock_7
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
		fill_out_data = {64 {1'sb0}};
		fill_out_err = {2 {1'sb0}};
		begin : sv2v_autoblock_8
			reg signed [31:0] i;
			for (i = 0; i < NUM_FB; i = i + 1)
				if (fill_data_reg[i]) begin
					fill_out_data = fill_out_data | fill_data_q[i];
					fill_out_err = fill_out_err | (fill_err_q[i * ibex_pkg_IC_LINE_BEATS+:ibex_pkg_IC_LINE_BEATS] & ~{ibex_pkg_IC_LINE_BEATS {fill_hit_q[i]}});
				end
		end
	end
	assign instr_req = ((~icache_enable_i | branch_or_mispredict) & lookup_grant_ic0) | |fill_ext_req;
	assign instr_addr = (|fill_ext_req ? fill_ext_req_addr : lookup_addr_ic0[31:ibex_pkg_BUS_W]);
	assign instr_req_o = instr_req;
	assign instr_addr_o = {instr_addr[31:ibex_pkg_BUS_W], {ibex_pkg_BUS_W {1'b0}}};
	assign line_data = (|fill_data_hit ? hit_data_ic1 : fill_out_data);
	assign line_err = (|fill_data_hit ? {ibex_pkg_IC_LINE_BEATS {1'b0}} : fill_out_err);
	always @(*) begin
		line_data_muxed = {32 {1'sb0}};
		line_err_muxed = 1'b0;
		begin : sv2v_autoblock_9
			reg signed [31:0] i;
			for (i = 0; i < ibex_pkg_IC_LINE_BEATS; i = i + 1)
				if ((output_addr_q[2:ibex_pkg_BUS_W] + {skid_valid_q}) == i[0:0]) begin
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
	assign skid_valid_d = (branch_or_mispredict ? 1'b0 : (skid_valid_q ? ~(ready_i & ((skid_data_q[1:0] != 2'b11) | skid_err_q)) : data_valid & ((output_addr_q[1] & (~output_compressed | output_err)) | (((~output_addr_q[1] & output_compressed) & ~output_err) & ready_i))));
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			skid_valid_q <= 1'b0;
		else
			skid_valid_q <= skid_valid_d;
	assign output_valid = skid_complete_instr | (data_valid & (((~output_addr_q[1] | skid_valid_q) | output_err) | (output_data[17:16] != 2'b11)));
	assign output_addr_en = branch_or_mispredict | (ready_i & valid_o);
	assign addr_incr_two = output_compressed & ~err_o;
	assign output_addr_incr = output_addr_q[31:1] + {29'd0, ~addr_incr_two, addr_incr_two};
	assign output_addr_d = (branch_i ? addr_i[31:1] : (branch_mispredict_i ? branch_mispredict_addr[31:1] : output_addr_incr));
	always @(posedge clk_i)
		if (output_addr_en)
			output_addr_q <= output_addr_d;
	localparam [31:0] ibex_pkg_IC_OUTPUT_BEATS = 2;
	always @(*) begin
		output_data_lo = {16 {1'sb0}};
		begin : sv2v_autoblock_10
			reg signed [31:0] i;
			for (i = 0; i < ibex_pkg_IC_OUTPUT_BEATS; i = i + 1)
				if (output_addr_q[1:1] == i[0:0])
					output_data_lo = output_data_lo | output_data[i * 16+:16];
		end
	end
	always @(*) begin
		output_data_hi = {16 {1'sb0}};
		begin : sv2v_autoblock_11
			reg signed [31:0] i;
			for (i = 0; i < 1; i = i + 1)
				if (output_addr_q[1:1] == i[0:0])
					output_data_hi = output_data_hi | output_data[(i + 1) * 16+:16];
		end
		if (&output_addr_q[1:1])
			output_data_hi = output_data_hi | output_data[15:0];
	end
	assign valid_o = output_valid & ~branch_mispredict_i;
	assign rdata_o = {output_data_hi, (skid_valid_q ? skid_data_q : output_data_lo)};
	assign addr_o = {output_addr_q, 1'b0};
	assign err_o = (skid_valid_q & skid_err_q) | (~skid_complete_instr & output_err);
	assign err_plus2_o = skid_valid_q & ~skid_err_q;
	assign start_inval = (~reset_inval_q | icache_inval_i) & ~inval_prog_q;
	assign inval_prog_d = start_inval | (inval_prog_q & ~inval_done);
	assign inval_done = &inval_index_q;
	assign inval_index_d = (start_inval ? {8 {1'sb0}} : inval_index_q + {{7 {1'b0}}, 1'b1});
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
	initial begin : size_param_legal
		
	end
	initial begin : ecc_tag_param_legal
		
	end
	initial begin : ecc_data_param_legal
		
	end
endmodule
