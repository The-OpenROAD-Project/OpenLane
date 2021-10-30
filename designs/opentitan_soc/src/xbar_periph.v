module xbar_periph (
	clk_i,
	rst_ni,
	tl_if_i,
	tl_if_o,
	tl_lsu_i,
	tl_lsu_o,
	tl_iccm_o,
	tl_iccm_i,
	tl_dccm_o,
	tl_dccm_i,
	tl_gpio_o,
	tl_gpio_i,
	tl_ldo1_o,
	tl_ldo1_i,
	tl_ldo2_o,
	tl_ldo2_i,
	tl_dcdc_o,
	tl_dcdc_i,
	tl_pll1_o,
	tl_pll1_i,
	tl_tsen1_o,
	tl_tsen1_i,
	tl_tsen2_o,
	tl_tsen2_i,
	tl_dap_o,
	tl_dap_i,
	tl_plic_o,
	tl_plic_i,
	tl_uart_o,
	tl_uart_i
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_if_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_if_o;
	input wire [85:0] tl_lsu_i;
	output wire [51:0] tl_lsu_o;
	output wire [85:0] tl_iccm_o;
	input wire [51:0] tl_iccm_i;
	output wire [85:0] tl_dccm_o;
	input wire [51:0] tl_dccm_i;
	output wire [85:0] tl_gpio_o;
	input wire [51:0] tl_gpio_i;
	output wire [85:0] tl_ldo1_o;
	input wire [51:0] tl_ldo1_i;
	output wire [85:0] tl_ldo2_o;
	input wire [51:0] tl_ldo2_i;
	output wire [85:0] tl_dcdc_o;
	input wire [51:0] tl_dcdc_i;
	output wire [85:0] tl_pll1_o;
	input wire [51:0] tl_pll1_i;
	output wire [85:0] tl_tsen1_o;
	input wire [51:0] tl_tsen1_i;
	output wire [85:0] tl_tsen2_o;
	input wire [51:0] tl_tsen2_i;
	output wire [85:0] tl_dap_o;
	input wire [51:0] tl_dap_i;
	output wire [85:0] tl_plic_o;
	input wire [51:0] tl_plic_i;
	output wire [85:0] tl_uart_o;
	input wire [51:0] tl_uart_i;
	assign tl_iccm_o = tl_if_i;
	assign tl_if_o = tl_iccm_i;
	wire [85:0] tl_s1n_10_us_h2d;
	wire [51:0] tl_s1n_10_us_d2h;
	wire [945:0] tl_s1n_10_ds_h2d;
	wire [571:0] tl_s1n_10_ds_d2h;
	reg [3:0] dev_sel_s1n_10;
	assign tl_dccm_o = tl_s1n_10_ds_h2d[860+:86];
	assign tl_s1n_10_ds_d2h[520+:52] = tl_dccm_i;
	assign tl_gpio_o = tl_s1n_10_ds_h2d[774+:86];
	assign tl_s1n_10_ds_d2h[468+:52] = tl_gpio_i;
	assign tl_ldo1_o = tl_s1n_10_ds_h2d[688+:86];
	assign tl_s1n_10_ds_d2h[416+:52] = tl_ldo1_i;
	assign tl_ldo2_o = tl_s1n_10_ds_h2d[602+:86];
	assign tl_s1n_10_ds_d2h[364+:52] = tl_ldo2_i;
	assign tl_dcdc_o = tl_s1n_10_ds_h2d[516+:86];
	assign tl_s1n_10_ds_d2h[312+:52] = tl_dcdc_i;
	assign tl_pll1_o = tl_s1n_10_ds_h2d[430+:86];
	assign tl_s1n_10_ds_d2h[260+:52] = tl_pll1_i;
	assign tl_tsen1_o = tl_s1n_10_ds_h2d[344+:86];
	assign tl_s1n_10_ds_d2h[208+:52] = tl_tsen1_i;
	assign tl_tsen2_o = tl_s1n_10_ds_h2d[258+:86];
	assign tl_s1n_10_ds_d2h[156+:52] = tl_tsen2_i;
	assign tl_dap_o = tl_s1n_10_ds_h2d[172+:86];
	assign tl_s1n_10_ds_d2h[104+:52] = tl_dap_i;
	assign tl_plic_o = tl_s1n_10_ds_h2d[86+:86];
	assign tl_s1n_10_ds_d2h[52+:52] = tl_plic_i;
	assign tl_uart_o = tl_s1n_10_ds_h2d[0+:86];
	assign tl_s1n_10_ds_d2h[0+:52] = tl_uart_i;
	assign tl_s1n_10_us_h2d = tl_lsu_i;
	assign tl_lsu_o = tl_s1n_10_us_d2h;
	localparam [31:0] xbar_pkg_ADDR_MASK_DAP = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_DCCM = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_DCDC = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_GPIO = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_LDO1 = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_LDO2 = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_PLIC = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_PLL1 = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_TSEN1 = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_TSEN2 = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_MASK_UART = 32'h0000ffff;
	localparam [31:0] xbar_pkg_ADDR_SPACE_DAP = 32'h400f0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_DCCM = 32'h10000000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_DCDC = 32'h400b0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_GPIO = 32'h40080000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_LDO1 = 32'h40090000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_LDO2 = 32'h400a0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_PLIC = 32'h40050000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_PLL1 = 32'h400c0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_TSEN1 = 32'h400d0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_TSEN2 = 32'h400e0000;
	localparam [31:0] xbar_pkg_ADDR_SPACE_UART = 32'h40060000;
	always @(*) begin
		dev_sel_s1n_10 = 4'd11;
		if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_DCCM) == xbar_pkg_ADDR_SPACE_DCCM)
			dev_sel_s1n_10 = 4'd0;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_GPIO) == xbar_pkg_ADDR_SPACE_GPIO)
			dev_sel_s1n_10 = 4'd1;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_LDO1) == xbar_pkg_ADDR_SPACE_LDO1)
			dev_sel_s1n_10 = 4'd2;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_LDO2) == xbar_pkg_ADDR_SPACE_LDO2)
			dev_sel_s1n_10 = 4'd3;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_DCDC) == xbar_pkg_ADDR_SPACE_DCDC)
			dev_sel_s1n_10 = 4'd4;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_PLL1) == xbar_pkg_ADDR_SPACE_PLL1)
			dev_sel_s1n_10 = 4'd5;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_TSEN1) == xbar_pkg_ADDR_SPACE_TSEN1)
			dev_sel_s1n_10 = 4'd6;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_TSEN2) == xbar_pkg_ADDR_SPACE_TSEN2)
			dev_sel_s1n_10 = 4'd7;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_DAP) == xbar_pkg_ADDR_SPACE_DAP)
			dev_sel_s1n_10 = 4'd8;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_PLIC) == xbar_pkg_ADDR_SPACE_PLIC)
			dev_sel_s1n_10 = 4'd9;
		else if ((tl_s1n_10_us_h2d[68-:32] & ~xbar_pkg_ADDR_MASK_UART) == xbar_pkg_ADDR_SPACE_UART)
			dev_sel_s1n_10 = 4'd10;
	end
	tlul_socket_1n #(
		.HReqDepth(4'h0),
		.HRspDepth(4'h0),
		.DReqDepth(52'h0000000000000),
		.DRspDepth(52'h0000000000000),
		.N(11)
	) u_s1n_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_h_i(tl_s1n_10_us_h2d),
		.tl_h_o(tl_s1n_10_us_d2h),
		.tl_d_o(tl_s1n_10_ds_h2d),
		.tl_d_i(tl_s1n_10_ds_d2h),
		.dev_select_i(dev_sel_s1n_10)
	);
endmodule
