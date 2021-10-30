module tlul_socket_m1 (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i
);
	parameter [31:0] M = 4;
	parameter [M - 1:0] HReqPass = {M {1'b1}};
	parameter [M - 1:0] HRspPass = {M {1'b1}};
	parameter [(M * 4) - 1:0] HReqDepth = {M {4'h2}};
	parameter [(M * 4) - 1:0] HRspDepth = {M {4'h2}};
	parameter [0:0] DReqPass = 1'b1;
	parameter [0:0] DRspPass = 1'b1;
	parameter [3:0] DReqDepth = 4'h2;
	parameter [3:0] DRspDepth = 4'h2;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [(0 >= (M - 1) ? ((2 - M) * 86) + (((M - 1) * 86) - 1) : (M * 86) - 1):(0 >= (M - 1) ? (M - 1) * 86 : 0)] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [(0 >= (M - 1) ? ((2 - M) * 52) + (((M - 1) * 52) - 1) : (M * 52) - 1):(0 >= (M - 1) ? (M - 1) * 52 : 0)] tl_h_o;
	output wire [85:0] tl_d_o;
	input wire [51:0] tl_d_i;
	localparam [31:0] IDW = tlul_pkg_TL_AIW;
	localparam [31:0] STIDW = $clog2(M);
	wire [(0 >= (M - 1) ? ((2 - M) * 86) + (((M - 1) * 86) - 1) : (M * 86) - 1):(0 >= (M - 1) ? (M - 1) * 86 : 0)] hreq_fifo_o;
	wire [51:0] hrsp_fifo_i [0:M - 1];
	wire [M - 1:0] hrequest;
	wire [M - 1:0] hgrant;
	wire [85:0] dreq_fifo_i;
	wire [51:0] drsp_fifo_o;
	wire arb_valid;
	wire arb_ready;
	wire [85:0] arb_data;
	generate
		genvar i;
		for (i = 0; i < M; i = i + 1) begin : gen_host_fifo
			wire [85:0] hreq_fifo_i;
			wire [STIDW - 1:0] reqid_sub;
			wire [7:0] shifted_id;
			assign reqid_sub = i;
			assign shifted_id = {tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 69+:IDW - STIDW], reqid_sub};
			wire [7:IDW - STIDW] unused_tl_h_source;
			assign unused_tl_h_source = tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 76-:STIDW];
			function automatic [2:0] sv2v_cast_3;
				input reg [2:0] inp;
				sv2v_cast_3 = inp;
			endfunction
			function automatic [1:0] sv2v_cast_539D2;
				input reg [1:0] inp;
				sv2v_cast_539D2 = inp;
			endfunction
			function automatic [7:0] sv2v_cast_F6BCE;
				input reg [7:0] inp;
				sv2v_cast_F6BCE = inp;
			endfunction
			function automatic [31:0] sv2v_cast_C6CCE;
				input reg [31:0] inp;
				sv2v_cast_C6CCE = inp;
			endfunction
			function automatic [3:0] sv2v_cast_45434;
				input reg [3:0] inp;
				sv2v_cast_45434 = inp;
			endfunction
			function automatic [31:0] sv2v_cast_486C6;
				input reg [31:0] inp;
				sv2v_cast_486C6 = inp;
			endfunction
			assign hreq_fifo_i = {tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 85], sv2v_cast_3(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 84-:3]), sv2v_cast_3(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 81-:3]), sv2v_cast_539D2(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 78-:2]), sv2v_cast_F6BCE(shifted_id), sv2v_cast_C6CCE(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 68-:32]), sv2v_cast_45434(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 36-:4]), sv2v_cast_486C6(tl_h_i[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + tlul_pkg_TL_DW-:tlul_pkg_TL_DW]), tl_h_i[(0 >= (M - 1) ? i : (M - 1) - i) * 86]};
			tlul_fifo_sync #(
				.ReqPass(HReqPass[i]),
				.RspPass(HRspPass[i]),
				.ReqDepth(HReqDepth[i * 4+:4]),
				.RspDepth(HRspDepth[i * 4+:4]),
				.SpareReqW(1)
			) u_hostfifo(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tl_h_i(hreq_fifo_i),
				.tl_h_o(tl_h_o[(0 >= (M - 1) ? i : (M - 1) - i) * 52+:52]),
				.tl_d_o(hreq_fifo_o[(0 >= (M - 1) ? i : (M - 1) - i) * 86+:86]),
				.tl_d_i(hrsp_fifo_i[i]),
				.spare_req_i(1'b0),
				.spare_req_o(),
				.spare_rsp_i(1'b0),
				.spare_rsp_o()
			);
		end
	endgenerate
	tlul_fifo_sync #(
		.ReqPass(DReqPass),
		.RspPass(DRspPass),
		.ReqDepth(DReqDepth),
		.RspDepth(DRspDepth),
		.SpareReqW(1)
	) u_devicefifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(dreq_fifo_i),
		.tl_h_o(drsp_fifo_o),
		.tl_d_o(tl_d_o),
		.tl_d_i(tl_d_i),
		.spare_req_i(1'b0),
		.spare_req_o(),
		.spare_rsp_i(1'b0),
		.spare_rsp_o()
	);
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_arbreqgnt
			assign hrequest[i] = hreq_fifo_o[((0 >= (M - 1) ? i : (M - 1) - i) * 86) + 85];
		end
	endgenerate
	assign arb_ready = drsp_fifo_o[0];
	localparam tlul_pkg_ArbiterImpl = "PPC";
	generate
		if (tlul_pkg_ArbiterImpl == "PPC") begin : gen_arb_ppc
			prim_arbiter_ppc #(
				.N(M),
				.DW(86),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
		else if (tlul_pkg_ArbiterImpl == "BINTREE") begin : gen_tree_arb
			prim_arbiter_tree #(
				.N(M),
				.DW(86),
				.EnReqStabA(0)
			) u_reqarb(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.req_i(hrequest),
				.data_i(hreq_fifo_o),
				.gnt_o(hgrant),
				.idx_o(),
				.valid_o(arb_valid),
				.data_o(arb_data),
				.ready_i(arb_ready)
			);
		end
	endgenerate
	wire [M - 1:0] hfifo_rspvalid;
	wire [M - 1:0] dfifo_rspready;
	wire [7:0] hfifo_rspid;
	wire dfifo_rspready_merged;
	assign dfifo_rspready_merged = |dfifo_rspready;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_539D2;
		input reg [1:0] inp;
		sv2v_cast_539D2 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_F6BCE;
		input reg [7:0] inp;
		sv2v_cast_F6BCE = inp;
	endfunction
	function automatic [31:0] sv2v_cast_C6CCE;
		input reg [31:0] inp;
		sv2v_cast_C6CCE = inp;
	endfunction
	function automatic [3:0] sv2v_cast_45434;
		input reg [3:0] inp;
		sv2v_cast_45434 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_486C6;
		input reg [31:0] inp;
		sv2v_cast_486C6 = inp;
	endfunction
	assign dreq_fifo_i = {arb_valid, sv2v_cast_3(arb_data[84-:3]), sv2v_cast_3(arb_data[81-:3]), sv2v_cast_539D2(arb_data[78-:2]), sv2v_cast_F6BCE(arb_data[76-:8]), sv2v_cast_C6CCE(arb_data[68-:32]), sv2v_cast_45434(arb_data[36-:4]), sv2v_cast_486C6(arb_data[tlul_pkg_TL_DW-:tlul_pkg_TL_DW]), dfifo_rspready_merged};
	assign hfifo_rspid = {{STIDW {1'b0}}, drsp_fifo_o[42:35 + STIDW]};
	generate
		for (i = 0; i < M; i = i + 1) begin : gen_idrouting
			assign hfifo_rspvalid[i] = drsp_fifo_o[51] & (drsp_fifo_o[35+:STIDW] == i);
			assign dfifo_rspready[i] = (hreq_fifo_o[(0 >= (M - 1) ? i : (M - 1) - i) * 86] & (drsp_fifo_o[35+:STIDW] == i)) & drsp_fifo_o[51];
			function automatic [2:0] sv2v_cast_3;
				input reg [2:0] inp;
				sv2v_cast_3 = inp;
			endfunction
			function automatic [1:0] sv2v_cast_539D2;
				input reg [1:0] inp;
				sv2v_cast_539D2 = inp;
			endfunction
			function automatic [7:0] sv2v_cast_F6BCE;
				input reg [7:0] inp;
				sv2v_cast_F6BCE = inp;
			endfunction
			function automatic [0:0] sv2v_cast_D8FDD;
				input reg [0:0] inp;
				sv2v_cast_D8FDD = inp;
			endfunction
			function automatic [31:0] sv2v_cast_486C6;
				input reg [31:0] inp;
				sv2v_cast_486C6 = inp;
			endfunction
			assign hrsp_fifo_i[i] = {hfifo_rspvalid[i], sv2v_cast_3(drsp_fifo_o[50-:3]), sv2v_cast_3(drsp_fifo_o[47-:3]), sv2v_cast_539D2(drsp_fifo_o[44-:2]), sv2v_cast_F6BCE(hfifo_rspid), sv2v_cast_D8FDD(drsp_fifo_o[34-:1]), sv2v_cast_486C6(drsp_fifo_o[33-:tlul_pkg_TL_DW]), drsp_fifo_o[1], hgrant[i]};
		end
	endgenerate
endmodule
