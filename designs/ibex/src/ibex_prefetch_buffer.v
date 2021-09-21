module ibex_prefetch_buffer (
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
	busy_o
);
	parameter [0:0] BranchPredictor = 1'b0;
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
	output wire busy_o;
	localparam [31:0] NUM_REQS = 2;
	wire branch_suppress;
	wire valid_new_req;
	wire valid_req;
	wire valid_req_d;
	reg valid_req_q;
	wire discard_req_d;
	reg discard_req_q;
	wire gnt_or_pmp_err;
	wire rvalid_or_pmp_err;
	wire [NUM_REQS - 1:0] rdata_outstanding_n;
	wire [NUM_REQS - 1:0] rdata_outstanding_s;
	reg [NUM_REQS - 1:0] rdata_outstanding_q;
	wire [NUM_REQS - 1:0] branch_discard_n;
	wire [NUM_REQS - 1:0] branch_discard_s;
	reg [NUM_REQS - 1:0] branch_discard_q;
	wire [NUM_REQS - 1:0] rdata_pmp_err_n;
	wire [NUM_REQS - 1:0] rdata_pmp_err_s;
	reg [NUM_REQS - 1:0] rdata_pmp_err_q;
	wire [NUM_REQS - 1:0] rdata_outstanding_rev;
	wire [31:0] stored_addr_d;
	reg [31:0] stored_addr_q;
	wire stored_addr_en;
	wire [31:0] fetch_addr_d;
	reg [31:0] fetch_addr_q;
	wire fetch_addr_en;
	wire [31:0] branch_mispredict_addr;
	wire [31:0] instr_addr;
	wire [31:0] instr_addr_w_aligned;
	wire instr_or_pmp_err;
	wire fifo_valid;
	wire [31:0] fifo_addr;
	wire fifo_ready;
	wire fifo_clear;
	wire [NUM_REQS - 1:0] fifo_busy;
	wire valid_raw;
	wire [31:0] addr_next;
	wire branch_or_mispredict;
	assign busy_o = |rdata_outstanding_q | instr_req_o;
	assign branch_or_mispredict = branch_i | branch_mispredict_i;
	assign instr_or_pmp_err = instr_err_i | rdata_pmp_err_q[0];
	assign fifo_clear = branch_or_mispredict;
	generate
		genvar i;
		for (i = 0; i < NUM_REQS; i = i + 1) begin : gen_rd_rev
			assign rdata_outstanding_rev[i] = rdata_outstanding_q[(NUM_REQS - 1) - i];
		end
	endgenerate
	assign fifo_ready = ~&(fifo_busy | rdata_outstanding_rev);
	ibex_fetch_fifo #(.NUM_REQS(NUM_REQS)) fifo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(fifo_clear),
		.busy_o(fifo_busy),
		.in_valid_i(fifo_valid),
		.in_addr_i(fifo_addr),
		.in_rdata_i(instr_rdata_i),
		.in_err_i(instr_or_pmp_err),
		.out_valid_o(valid_raw),
		.out_ready_i(ready_i),
		.out_rdata_o(rdata_o),
		.out_addr_o(addr_o),
		.out_addr_next_o(addr_next),
		.out_err_o(err_o),
		.out_err_plus2_o(err_plus2_o)
	);
	assign branch_suppress = branch_spec_i & ~branch_i;
	assign valid_new_req = ((~branch_suppress & req_i) & (fifo_ready | branch_or_mispredict)) & ~rdata_outstanding_q[NUM_REQS - 1];
	assign valid_req = valid_req_q | valid_new_req;
	assign gnt_or_pmp_err = instr_gnt_i | instr_pmp_err_i;
	assign rvalid_or_pmp_err = rdata_outstanding_q[0] & (instr_rvalid_i | rdata_pmp_err_q[0]);
	assign valid_req_d = valid_req & ~gnt_or_pmp_err;
	assign discard_req_d = valid_req_q & (branch_or_mispredict | discard_req_q);
	assign stored_addr_en = (valid_new_req & ~valid_req_q) & ~gnt_or_pmp_err;
	assign stored_addr_d = instr_addr;
	always @(posedge clk_i)
		if (stored_addr_en)
			stored_addr_q <= stored_addr_d;
	generate
		if (BranchPredictor) begin : g_branch_predictor
			reg [31:0] branch_mispredict_addr_q;
			wire branch_mispredict_addr_en;
			assign branch_mispredict_addr_en = branch_i & predicted_branch_i;
			always @(posedge clk_i)
				if (branch_mispredict_addr_en)
					branch_mispredict_addr_q <= addr_next;
			assign branch_mispredict_addr = branch_mispredict_addr_q;
		end
		else begin : g_no_branch_predictor
			wire unused_predicted_branch;
			wire [31:0] unused_addr_next;
			assign unused_predicted_branch = predicted_branch_i;
			assign unused_addr_next = addr_next;
			assign branch_mispredict_addr = {32 {1'sb0}};
		end
	endgenerate
	assign fetch_addr_en = branch_or_mispredict | (valid_new_req & ~valid_req_q);
	assign fetch_addr_d = (branch_i ? addr_i : (branch_mispredict_i ? {branch_mispredict_addr[31:2], 2'b00} : {fetch_addr_q[31:2], 2'b00})) + {{29 {1'b0}}, valid_new_req & ~valid_req_q, 2'b00};
	always @(posedge clk_i)
		if (fetch_addr_en)
			fetch_addr_q <= fetch_addr_d;
	assign instr_addr = (valid_req_q ? stored_addr_q : (branch_spec_i ? addr_i : (branch_mispredict_i ? branch_mispredict_addr : fetch_addr_q)));
	assign instr_addr_w_aligned = {instr_addr[31:2], 2'b00};
	generate
		for (i = 0; i < NUM_REQS; i = i + 1) begin : g_outstanding_reqs
			if (i == 0) begin : g_req0
				assign rdata_outstanding_n[i] = (valid_req & gnt_or_pmp_err) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = (((valid_req & gnt_or_pmp_err) & discard_req_d) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = ((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) | rdata_pmp_err_q[i];
			end
			else begin : g_reqtop
				assign rdata_outstanding_n[i] = ((valid_req & gnt_or_pmp_err) & rdata_outstanding_q[i - 1]) | rdata_outstanding_q[i];
				assign branch_discard_n[i] = ((((valid_req & gnt_or_pmp_err) & discard_req_d) & rdata_outstanding_q[i - 1]) | (branch_or_mispredict & rdata_outstanding_q[i])) | branch_discard_q[i];
				assign rdata_pmp_err_n[i] = (((valid_req & ~rdata_outstanding_q[i]) & instr_pmp_err_i) & rdata_outstanding_q[i - 1]) | rdata_pmp_err_q[i];
			end
		end
	endgenerate
	assign rdata_outstanding_s = (rvalid_or_pmp_err ? {1'b0, rdata_outstanding_n[NUM_REQS - 1:1]} : rdata_outstanding_n);
	assign branch_discard_s = (rvalid_or_pmp_err ? {1'b0, branch_discard_n[NUM_REQS - 1:1]} : branch_discard_n);
	assign rdata_pmp_err_s = (rvalid_or_pmp_err ? {1'b0, rdata_pmp_err_n[NUM_REQS - 1:1]} : rdata_pmp_err_n);
	assign fifo_valid = rvalid_or_pmp_err & ~branch_discard_q[0];
	assign fifo_addr = (branch_mispredict_i ? branch_mispredict_addr : addr_i);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			valid_req_q <= 1'b0;
			discard_req_q <= 1'b0;
			rdata_outstanding_q <= 'b0;
			branch_discard_q <= 'b0;
			rdata_pmp_err_q <= 'b0;
		end
		else begin
			valid_req_q <= valid_req_d;
			discard_req_q <= discard_req_d;
			rdata_outstanding_q <= rdata_outstanding_s;
			branch_discard_q <= branch_discard_s;
			rdata_pmp_err_q <= rdata_pmp_err_s;
		end
	assign instr_req_o = valid_req;
	assign instr_addr_o = instr_addr_w_aligned;
	assign valid_o = valid_raw & ~branch_mispredict_i;
endmodule
