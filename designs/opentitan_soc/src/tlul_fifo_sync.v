module tlul_fifo_sync (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i,
	spare_req_i,
	spare_req_o,
	spare_rsp_i,
	spare_rsp_o
);
	parameter [0:0] ReqPass = 1'b1;
	parameter [0:0] RspPass = 1'b1;
	parameter [31:0] ReqDepth = 0;
	parameter [31:0] RspDepth = 0;
	parameter [31:0] SpareReqW = 1;
	parameter [31:0] SpareRspW = 1;
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
	output wire [85:0] tl_d_o;
	input wire [51:0] tl_d_i;
	input [SpareReqW - 1:0] spare_req_i;
	output [SpareReqW - 1:0] spare_req_o;
	input [SpareRspW - 1:0] spare_rsp_i;
	output [SpareRspW - 1:0] spare_rsp_o;
	localparam [31:0] REQFIFO_WIDTH = 84 + SpareReqW;
	fifo_sync #(
		.Width(REQFIFO_WIDTH),
		.Pass(ReqPass),
		.Depth(ReqDepth)
	) reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_h_i[85]),
		.wready_o(tl_h_o[0]),
		.wdata_i({tl_h_i[84-:3], tl_h_i[81-:3], tl_h_i[78-:2], tl_h_i[76-:8], tl_h_i[68-:32], tl_h_i[36-:4], tl_h_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW], spare_req_i}),
		.depth_o(),
		.rvalid_o(tl_d_o[85]),
		.rready_i(tl_d_i[0]),
		.rdata_o({tl_d_o[84-:3], tl_d_o[81-:3], tl_d_o[78-:2], tl_d_o[76-:8], tl_d_o[68-:32], tl_d_o[36-:4], tl_d_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW], spare_req_o})
	);
	localparam [31:0] RSPFIFO_WIDTH = 50 + SpareRspW;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	fifo_sync #(
		.Width(RSPFIFO_WIDTH),
		.Pass(RspPass),
		.Depth(RspDepth)
	) rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(tl_d_i[51]),
		.wready_o(tl_d_o[0]),
		.wdata_i({tl_d_i[50-:3], tl_d_i[47-:3], tl_d_i[44-:2], tl_d_i[42-:8], tl_d_i[34-:1], (tl_d_i[50-:3] == tlul_pkg_AccessAckData ? tl_d_i[33-:tlul_pkg_TL_DW] : {tlul_pkg_TL_DW {1'b0}}), tl_d_i[1], spare_rsp_i}),
		.depth_o(),
		.rvalid_o(tl_h_o[51]),
		.rready_i(tl_h_i[0]),
		.rdata_o({tl_h_o[50-:3], tl_h_o[47-:3], tl_h_o[44-:2], tl_h_o[42-:8], tl_h_o[34-:1], tl_h_o[33-:tlul_pkg_TL_DW], tl_h_o[1], spare_rsp_o})
	);
endmodule
