module tlul_fifo_async (
	clk_h_i,
	rst_h_ni,
	clk_d_i,
	rst_d_ni,
	tl_h_i,
	tl_h_o,
	tl_d_o,
	tl_d_i
);
	parameter [31:0] ReqDepth = 3;
	parameter [31:0] RspDepth = 3;
	input clk_h_i;
	input rst_h_ni;
	input clk_d_i;
	input rst_d_ni;
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
	localparam [31:0] REQFIFO_WIDTH = 84;
	fifo_async #(
		.Width(REQFIFO_WIDTH),
		.Depth(ReqDepth)
	) reqfifo(
		.clk_wr_i(clk_h_i),
		.rst_wr_ni(rst_h_ni),
		.clk_rd_i(clk_d_i),
		.rst_rd_ni(rst_d_ni),
		.wvalid_i(tl_h_i[85]),
		.wready_o(tl_h_o[0]),
		.wdata_i({tl_h_i[84-:3], tl_h_i[81-:3], tl_h_i[78-:2], tl_h_i[76-:8], tl_h_i[68-:32], tl_h_i[36-:4], tl_h_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW]}),
		.rvalid_o(tl_d_o[85]),
		.rready_i(tl_d_i[0]),
		.rdata_o({tl_d_o[84-:3], tl_d_o[81-:3], tl_d_o[78-:2], tl_d_o[76-:8], tl_d_o[68-:32], tl_d_o[36-:4], tl_d_o[tlul_pkg_TL_DW-:tlul_pkg_TL_DW]}),
		.wdepth_o(),
		.rdepth_o()
	);
	localparam [31:0] RSPFIFO_WIDTH = 50;
	fifo_async #(
		.Width(RSPFIFO_WIDTH),
		.Depth(RspDepth)
	) rspfifo(
		.clk_wr_i(clk_d_i),
		.rst_wr_ni(rst_d_ni),
		.clk_rd_i(clk_h_i),
		.rst_rd_ni(rst_h_ni),
		.wvalid_i(tl_d_i[51]),
		.wready_o(tl_d_o[0]),
		.wdata_i({tl_d_i[50-:3], tl_d_i[47-:3], tl_d_i[44-:2], tl_d_i[42-:8], tl_d_i[34-:1], tl_d_i[33-:tlul_pkg_TL_DW], tl_d_i[1]}),
		.rvalid_o(tl_h_o[51]),
		.rready_i(tl_h_i[0]),
		.rdata_o({tl_h_o[50-:3], tl_h_o[47-:3], tl_h_o[44-:2], tl_h_o[42-:8], tl_h_o[34-:1], tl_h_o[33-:tlul_pkg_TL_DW], tl_h_o[1]}),
		.wdepth_o(),
		.rdepth_o()
	);
endmodule
