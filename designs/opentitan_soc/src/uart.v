module uart (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	cio_rx_i,
	cio_tx_o,
	cio_tx_en_o,
	intr_tx_watermark_o,
	intr_rx_watermark_o,
	intr_tx_empty_o,
	intr_rx_overflow_o,
	intr_rx_frame_err_o,
	intr_rx_break_err_o,
	intr_rx_timeout_o,
	intr_rx_parity_err_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	input cio_rx_i;
	output wire cio_tx_o;
	output wire cio_tx_en_o;
	output wire intr_tx_watermark_o;
	output wire intr_rx_watermark_o;
	output wire intr_tx_empty_o;
	output wire intr_rx_overflow_o;
	output wire intr_rx_frame_err_o;
	output wire intr_rx_break_err_o;
	output wire intr_rx_timeout_o;
	output wire intr_rx_parity_err_o;
	wire [124:0] reg2hw;
	wire [64:0] hw2reg;
	uart_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
	uart_core uart_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.rx(cio_rx_i),
		.tx(cio_tx_o),
		.intr_tx_watermark_o(intr_tx_watermark_o),
		.intr_rx_watermark_o(intr_rx_watermark_o),
		.intr_tx_empty_o(intr_tx_empty_o),
		.intr_rx_overflow_o(intr_rx_overflow_o),
		.intr_rx_frame_err_o(intr_rx_frame_err_o),
		.intr_rx_break_err_o(intr_rx_break_err_o),
		.intr_rx_timeout_o(intr_rx_timeout_o),
		.intr_rx_parity_err_o(intr_rx_parity_err_o)
	);
	assign cio_tx_en_o = 1'b1;
endmodule
