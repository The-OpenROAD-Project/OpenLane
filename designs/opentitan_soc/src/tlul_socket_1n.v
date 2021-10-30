module tlul_socket_1n (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	dev_select_i
);
	parameter [31:0] N = 4;
	parameter [0:0] HReqPass = 1'b1;
	parameter [0:0] HRspPass = 1'b1;
	parameter [N - 1:0] DReqPass = {N {1'b1}};
	parameter [N - 1:0] DRspPass = {N {1'b1}};
	parameter [3:0] HReqDepth = 4'h2;
	parameter [3:0] HRspDepth = 4'h2;
	parameter [(N * 4) - 1:0] DReqDepth = {N {4'h2}};
	parameter [(N * 4) - 1:0] DRspDepth = {N {4'h2}};
	localparam [31:0] NWD = $clog2(N + 1);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_h_o;
	output wire [(0 >= (N - 1) ? ((2 - N) * 86) + (((N - 1) * 86) - 1) : (N * 86) - 1):(0 >= (N - 1) ? (N - 1) * 86 : 0)] tl_d_o;
	input wire [(0 >= (N - 1) ? ((2 - N) * 52) + (((N - 1) * 52) - 1) : (N * 52) - 1):(0 >= (N - 1) ? (N - 1) * 52 : 0)] tl_d_i;
	input [NWD - 1:0] dev_select_i;
	wire [NWD - 1:0] dev_select_t;
	wire [85:0] tl_t_o;
	wire [51:0] tl_t_i;
	tlul_fifo_sync #(
		.ReqPass(HReqPass),
		.RspPass(HRspPass),
		.ReqDepth(HReqDepth),
		.RspDepth(HRspDepth),
		.SpareReqW(NWD)
	) fifo_h(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_h_i),
		.tl_h_o(tl_h_o),
		.tl_d_o(tl_t_o),
		.tl_d_i(tl_t_i),
		.spare_req_i(dev_select_i),
		.spare_req_o(dev_select_t),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	localparam signed [31:0] MaxOutstanding = 65536;
	localparam signed [31:0] OutstandingW = 17;
	reg [16:0] num_req_outstanding;
	reg [NWD - 1:0] dev_select_outstanding;
	wire hold_all_requests;
	wire accept_t_req;
	wire accept_t_rsp;
	assign accept_t_req = tl_t_o[85] & tl_t_i[0];
	assign accept_t_rsp = tl_t_i[51] & tl_t_o[0];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			num_req_outstanding <= {17 {1'sb0}};
			dev_select_outstanding <= {NWD {1'sb0}};
		end
		else if (accept_t_req) begin
			if (!accept_t_rsp)
				num_req_outstanding <= num_req_outstanding + 1'b1;
			dev_select_outstanding <= dev_select_t;
		end
		else if (accept_t_rsp)
			num_req_outstanding <= num_req_outstanding - 1'b1;
	assign hold_all_requests = (num_req_outstanding != {17 {1'sb0}}) & (dev_select_t != dev_select_outstanding);
	wire [85:0] tl_u_o [0:N];
	wire [51:0] tl_u_i [0:N];
	generate
		genvar i;
		for (i = 0; i < N; i = i + 1) begin : gen_u_o
			function automatic signed [NWD - 1:0] sv2v_cast_BB804_signed;
				input reg signed [NWD - 1:0] inp;
				sv2v_cast_BB804_signed = inp;
			endfunction
			assign tl_u_o[i][85] = (tl_t_o[85] & (dev_select_t == sv2v_cast_BB804_signed(i))) & ~hold_all_requests;
			assign tl_u_o[i][84-:3] = tl_t_o[84-:3];
			assign tl_u_o[i][81-:3] = tl_t_o[81-:3];
			assign tl_u_o[i][78-:2] = tl_t_o[78-:2];
			assign tl_u_o[i][76-:8] = tl_t_o[76-:8];
			assign tl_u_o[i][68-:32] = tl_t_o[68-:32];
			assign tl_u_o[i][36-:4] = tl_t_o[36-:4];
			assign tl_u_o[i][tlul_pkg_TL_DW-:tlul_pkg_TL_DW] = tl_t_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
		end
	endgenerate
	reg [51:0] tl_t_p;
	reg hfifo_reqready;
	function automatic signed [NWD - 1:0] sv2v_cast_BB804_signed;
		input reg signed [NWD - 1:0] inp;
		sv2v_cast_BB804_signed = inp;
	endfunction
	always @(*) begin
		hfifo_reqready = tl_u_i[N][0];
		begin : sv2v_autoblock_1
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_t == sv2v_cast_BB804_signed(idx))
					hfifo_reqready = tl_u_i[idx][0];
		end
		if (hold_all_requests)
			hfifo_reqready = 1'b0;
	end
	assign tl_t_i[0] = tl_t_o[85] & hfifo_reqready;
	always @(*) begin
		tl_t_p = tl_u_i[N];
		begin : sv2v_autoblock_2
			reg signed [31:0] idx;
			for (idx = 0; idx < N; idx = idx + 1)
				if (dev_select_outstanding == sv2v_cast_BB804_signed(idx))
					tl_t_p = tl_u_i[idx];
		end
	end
	assign tl_t_i[51] = tl_t_p[51];
	assign tl_t_i[50-:3] = tl_t_p[50-:3];
	assign tl_t_i[47-:3] = tl_t_p[47-:3];
	assign tl_t_i[44-:2] = tl_t_p[44-:2];
	assign tl_t_i[42-:8] = tl_t_p[42-:8];
	assign tl_t_i[34-:1] = tl_t_p[34-:1];
	assign tl_t_i[33-:tlul_pkg_TL_DW] = tl_t_p[33-:tlul_pkg_TL_DW];
	assign tl_t_i[1] = tl_t_p[1];
	generate
		for (i = 0; i < (N + 1); i = i + 1) begin : gen_u_o_d_ready
			assign tl_u_o[i][0] = tl_t_o[0];
		end
	endgenerate
	generate
		for (i = 0; i < N; i = i + 1) begin : gen_dfifo
			tlul_fifo_sync #(
				.ReqPass(DReqPass[i]),
				.RspPass(DRspPass[i]),
				.ReqDepth(DReqDepth[i * 4+:4]),
				.RspDepth(DRspDepth[i * 4+:4])
			) fifo_d(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(tl_u_o[i]),
				.tl_h_o(tl_u_i[i]),
				.tl_d_o(tl_d_o[(0 >= (N - 1) ? i : (N - 1) - i) * 86+:86]),
				.tl_d_i(tl_d_i[(0 >= (N - 1) ? i : (N - 1) - i) * 52+:52]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	function automatic [NWD - 1:0] sv2v_cast_BB804;
		input reg [NWD - 1:0] inp;
		sv2v_cast_BB804 = inp;
	endfunction
	assign tl_u_o[N][85] = (tl_t_o[85] & (dev_select_t == sv2v_cast_BB804(N))) & ~hold_all_requests;
	assign tl_u_o[N][84-:3] = tl_t_o[84-:3];
	assign tl_u_o[N][81-:3] = tl_t_o[81-:3];
	assign tl_u_o[N][78-:2] = tl_t_o[78-:2];
	assign tl_u_o[N][76-:8] = tl_t_o[76-:8];
	assign tl_u_o[N][68-:32] = tl_t_o[68-:32];
	assign tl_u_o[N][36-:4] = tl_t_o[36-:4];
	assign tl_u_o[N][tlul_pkg_TL_DW-:tlul_pkg_TL_DW] = tl_t_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
	tlul_err_resp err_resp(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_u_o[N]),
		.tl_h_o(tl_u_i[N])
	);
endmodule
