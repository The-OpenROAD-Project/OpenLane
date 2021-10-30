module rv_plic_reg_top (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	reg2hw,
	hw2reg,
	devmode_i
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
	output wire [171:0] reg2hw;
	input wire [69:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] AW = 9;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire reg_we;
	wire reg_re;
	wire [8:0] reg_addr;
	wire [31:0] reg_wdata;
	wire [3:0] reg_be;
	wire [31:0] reg_rdata;
	wire reg_error;
	wire addrmiss;
	reg wr_err;
	reg [31:0] reg_rdata_next;
	wire [85:0] tl_reg_h2d;
	wire [51:0] tl_reg_d2h;
	assign tl_reg_h2d = tl_i;
	assign tl_o = tl_reg_d2h;
	tlul_adapter_reg #(
		.RegAw(AW),
		.RegDw(DW)
	) u_reg_if(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_reg_h2d),
		.tl_o(tl_reg_d2h),
		.we_o(reg_we),
		.re_o(reg_re),
		.addr_o(reg_addr),
		.wdata_o(reg_wdata),
		.be_o(reg_be),
		.rdata_i(reg_rdata),
		.error_i(reg_error)
	);
	assign reg_rdata = reg_rdata_next;
	assign reg_error = (devmode_i & addrmiss) | wr_err;
	wire ip_p_0_qs;
	wire ip_p_1_qs;
	wire ip_p_2_qs;
	wire ip_p_3_qs;
	wire ip_p_4_qs;
	wire ip_p_5_qs;
	wire ip_p_6_qs;
	wire ip_p_7_qs;
	wire ip_p_8_qs;
	wire ip_p_9_qs;
	wire ip_p_10_qs;
	wire ip_p_11_qs;
	wire ip_p_12_qs;
	wire ip_p_13_qs;
	wire ip_p_14_qs;
	wire ip_p_15_qs;
	wire ip_p_16_qs;
	wire ip_p_17_qs;
	wire ip_p_18_qs;
	wire ip_p_19_qs;
	wire ip_p_20_qs;
	wire ip_p_21_qs;
	wire ip_p_22_qs;
	wire ip_p_23_qs;
	wire ip_p_24_qs;
	wire ip_p_25_qs;
	wire ip_p_26_qs;
	wire ip_p_27_qs;
	wire ip_p_28_qs;
	wire ip_p_29_qs;
	wire ip_p_30_qs;
	wire ip_p_31_qs;
	wire le_le_0_qs;
	wire le_le_0_wd;
	wire le_le_0_we;
	wire le_le_1_qs;
	wire le_le_1_wd;
	wire le_le_1_we;
	wire le_le_2_qs;
	wire le_le_2_wd;
	wire le_le_2_we;
	wire le_le_3_qs;
	wire le_le_3_wd;
	wire le_le_3_we;
	wire le_le_4_qs;
	wire le_le_4_wd;
	wire le_le_4_we;
	wire le_le_5_qs;
	wire le_le_5_wd;
	wire le_le_5_we;
	wire le_le_6_qs;
	wire le_le_6_wd;
	wire le_le_6_we;
	wire le_le_7_qs;
	wire le_le_7_wd;
	wire le_le_7_we;
	wire le_le_8_qs;
	wire le_le_8_wd;
	wire le_le_8_we;
	wire le_le_9_qs;
	wire le_le_9_wd;
	wire le_le_9_we;
	wire le_le_10_qs;
	wire le_le_10_wd;
	wire le_le_10_we;
	wire le_le_11_qs;
	wire le_le_11_wd;
	wire le_le_11_we;
	wire le_le_12_qs;
	wire le_le_12_wd;
	wire le_le_12_we;
	wire le_le_13_qs;
	wire le_le_13_wd;
	wire le_le_13_we;
	wire le_le_14_qs;
	wire le_le_14_wd;
	wire le_le_14_we;
	wire le_le_15_qs;
	wire le_le_15_wd;
	wire le_le_15_we;
	wire le_le_16_qs;
	wire le_le_16_wd;
	wire le_le_16_we;
	wire le_le_17_qs;
	wire le_le_17_wd;
	wire le_le_17_we;
	wire le_le_18_qs;
	wire le_le_18_wd;
	wire le_le_18_we;
	wire le_le_19_qs;
	wire le_le_19_wd;
	wire le_le_19_we;
	wire le_le_20_qs;
	wire le_le_20_wd;
	wire le_le_20_we;
	wire le_le_21_qs;
	wire le_le_21_wd;
	wire le_le_21_we;
	wire le_le_22_qs;
	wire le_le_22_wd;
	wire le_le_22_we;
	wire le_le_23_qs;
	wire le_le_23_wd;
	wire le_le_23_we;
	wire le_le_24_qs;
	wire le_le_24_wd;
	wire le_le_24_we;
	wire le_le_25_qs;
	wire le_le_25_wd;
	wire le_le_25_we;
	wire le_le_26_qs;
	wire le_le_26_wd;
	wire le_le_26_we;
	wire le_le_27_qs;
	wire le_le_27_wd;
	wire le_le_27_we;
	wire le_le_28_qs;
	wire le_le_28_wd;
	wire le_le_28_we;
	wire le_le_29_qs;
	wire le_le_29_wd;
	wire le_le_29_we;
	wire le_le_30_qs;
	wire le_le_30_wd;
	wire le_le_30_we;
	wire le_le_31_qs;
	wire le_le_31_wd;
	wire le_le_31_we;
	wire [2:0] prio0_qs;
	wire [2:0] prio0_wd;
	wire prio0_we;
	wire [2:0] prio1_qs;
	wire [2:0] prio1_wd;
	wire prio1_we;
	wire [2:0] prio2_qs;
	wire [2:0] prio2_wd;
	wire prio2_we;
	wire [2:0] prio3_qs;
	wire [2:0] prio3_wd;
	wire prio3_we;
	wire [2:0] prio4_qs;
	wire [2:0] prio4_wd;
	wire prio4_we;
	wire [2:0] prio5_qs;
	wire [2:0] prio5_wd;
	wire prio5_we;
	wire [2:0] prio6_qs;
	wire [2:0] prio6_wd;
	wire prio6_we;
	wire [2:0] prio7_qs;
	wire [2:0] prio7_wd;
	wire prio7_we;
	wire [2:0] prio8_qs;
	wire [2:0] prio8_wd;
	wire prio8_we;
	wire [2:0] prio9_qs;
	wire [2:0] prio9_wd;
	wire prio9_we;
	wire [2:0] prio10_qs;
	wire [2:0] prio10_wd;
	wire prio10_we;
	wire [2:0] prio11_qs;
	wire [2:0] prio11_wd;
	wire prio11_we;
	wire [2:0] prio12_qs;
	wire [2:0] prio12_wd;
	wire prio12_we;
	wire [2:0] prio13_qs;
	wire [2:0] prio13_wd;
	wire prio13_we;
	wire [2:0] prio14_qs;
	wire [2:0] prio14_wd;
	wire prio14_we;
	wire [2:0] prio15_qs;
	wire [2:0] prio15_wd;
	wire prio15_we;
	wire [2:0] prio16_qs;
	wire [2:0] prio16_wd;
	wire prio16_we;
	wire [2:0] prio17_qs;
	wire [2:0] prio17_wd;
	wire prio17_we;
	wire [2:0] prio18_qs;
	wire [2:0] prio18_wd;
	wire prio18_we;
	wire [2:0] prio19_qs;
	wire [2:0] prio19_wd;
	wire prio19_we;
	wire [2:0] prio20_qs;
	wire [2:0] prio20_wd;
	wire prio20_we;
	wire [2:0] prio21_qs;
	wire [2:0] prio21_wd;
	wire prio21_we;
	wire [2:0] prio22_qs;
	wire [2:0] prio22_wd;
	wire prio22_we;
	wire [2:0] prio23_qs;
	wire [2:0] prio23_wd;
	wire prio23_we;
	wire [2:0] prio24_qs;
	wire [2:0] prio24_wd;
	wire prio24_we;
	wire [2:0] prio25_qs;
	wire [2:0] prio25_wd;
	wire prio25_we;
	wire [2:0] prio26_qs;
	wire [2:0] prio26_wd;
	wire prio26_we;
	wire [2:0] prio27_qs;
	wire [2:0] prio27_wd;
	wire prio27_we;
	wire [2:0] prio28_qs;
	wire [2:0] prio28_wd;
	wire prio28_we;
	wire [2:0] prio29_qs;
	wire [2:0] prio29_wd;
	wire prio29_we;
	wire [2:0] prio30_qs;
	wire [2:0] prio30_wd;
	wire prio30_we;
	wire [2:0] prio31_qs;
	wire [2:0] prio31_wd;
	wire prio31_we;
	wire ie0_e_0_qs;
	wire ie0_e_0_wd;
	wire ie0_e_0_we;
	wire ie0_e_1_qs;
	wire ie0_e_1_wd;
	wire ie0_e_1_we;
	wire ie0_e_2_qs;
	wire ie0_e_2_wd;
	wire ie0_e_2_we;
	wire ie0_e_3_qs;
	wire ie0_e_3_wd;
	wire ie0_e_3_we;
	wire ie0_e_4_qs;
	wire ie0_e_4_wd;
	wire ie0_e_4_we;
	wire ie0_e_5_qs;
	wire ie0_e_5_wd;
	wire ie0_e_5_we;
	wire ie0_e_6_qs;
	wire ie0_e_6_wd;
	wire ie0_e_6_we;
	wire ie0_e_7_qs;
	wire ie0_e_7_wd;
	wire ie0_e_7_we;
	wire ie0_e_8_qs;
	wire ie0_e_8_wd;
	wire ie0_e_8_we;
	wire ie0_e_9_qs;
	wire ie0_e_9_wd;
	wire ie0_e_9_we;
	wire ie0_e_10_qs;
	wire ie0_e_10_wd;
	wire ie0_e_10_we;
	wire ie0_e_11_qs;
	wire ie0_e_11_wd;
	wire ie0_e_11_we;
	wire ie0_e_12_qs;
	wire ie0_e_12_wd;
	wire ie0_e_12_we;
	wire ie0_e_13_qs;
	wire ie0_e_13_wd;
	wire ie0_e_13_we;
	wire ie0_e_14_qs;
	wire ie0_e_14_wd;
	wire ie0_e_14_we;
	wire ie0_e_15_qs;
	wire ie0_e_15_wd;
	wire ie0_e_15_we;
	wire ie0_e_16_qs;
	wire ie0_e_16_wd;
	wire ie0_e_16_we;
	wire ie0_e_17_qs;
	wire ie0_e_17_wd;
	wire ie0_e_17_we;
	wire ie0_e_18_qs;
	wire ie0_e_18_wd;
	wire ie0_e_18_we;
	wire ie0_e_19_qs;
	wire ie0_e_19_wd;
	wire ie0_e_19_we;
	wire ie0_e_20_qs;
	wire ie0_e_20_wd;
	wire ie0_e_20_we;
	wire ie0_e_21_qs;
	wire ie0_e_21_wd;
	wire ie0_e_21_we;
	wire ie0_e_22_qs;
	wire ie0_e_22_wd;
	wire ie0_e_22_we;
	wire ie0_e_23_qs;
	wire ie0_e_23_wd;
	wire ie0_e_23_we;
	wire ie0_e_24_qs;
	wire ie0_e_24_wd;
	wire ie0_e_24_we;
	wire ie0_e_25_qs;
	wire ie0_e_25_wd;
	wire ie0_e_25_we;
	wire ie0_e_26_qs;
	wire ie0_e_26_wd;
	wire ie0_e_26_we;
	wire ie0_e_27_qs;
	wire ie0_e_27_wd;
	wire ie0_e_27_we;
	wire ie0_e_28_qs;
	wire ie0_e_28_wd;
	wire ie0_e_28_we;
	wire ie0_e_29_qs;
	wire ie0_e_29_wd;
	wire ie0_e_29_we;
	wire ie0_e_30_qs;
	wire ie0_e_30_wd;
	wire ie0_e_30_we;
	wire ie0_e_31_qs;
	wire ie0_e_31_wd;
	wire ie0_e_31_we;
	wire [2:0] threshold0_qs;
	wire [2:0] threshold0_wd;
	wire threshold0_we;
	wire [5:0] cc0_qs;
	wire [5:0] cc0_wd;
	wire cc0_we;
	wire cc0_re;
	wire msip0_qs;
	wire msip0_wd;
	wire msip0_we;
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[6]),
		.d(hw2reg[7]),
		.qe(),
		.q(),
		.qs(ip_p_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[8]),
		.d(hw2reg[9]),
		.qe(),
		.q(),
		.qs(ip_p_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[10]),
		.d(hw2reg[11]),
		.qe(),
		.q(),
		.qs(ip_p_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[12]),
		.d(hw2reg[13]),
		.qe(),
		.q(),
		.qs(ip_p_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[14]),
		.d(hw2reg[15]),
		.qe(),
		.q(),
		.qs(ip_p_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[16]),
		.d(hw2reg[17]),
		.qe(),
		.q(),
		.qs(ip_p_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[18]),
		.d(hw2reg[19]),
		.qe(),
		.q(),
		.qs(ip_p_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[20]),
		.d(hw2reg[21]),
		.qe(),
		.q(),
		.qs(ip_p_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[22]),
		.d(hw2reg[23]),
		.qe(),
		.q(),
		.qs(ip_p_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[24]),
		.d(hw2reg[25]),
		.qe(),
		.q(),
		.qs(ip_p_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[26]),
		.d(hw2reg[27]),
		.qe(),
		.q(),
		.qs(ip_p_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[28]),
		.d(hw2reg[29]),
		.qe(),
		.q(),
		.qs(ip_p_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[30]),
		.d(hw2reg[31]),
		.qe(),
		.q(),
		.qs(ip_p_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[32]),
		.d(hw2reg[33]),
		.qe(),
		.q(),
		.qs(ip_p_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[34]),
		.d(hw2reg[35]),
		.qe(),
		.q(),
		.qs(ip_p_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[36]),
		.d(hw2reg[37]),
		.qe(),
		.q(),
		.qs(ip_p_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[38]),
		.d(hw2reg[39]),
		.qe(),
		.q(),
		.qs(ip_p_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[40]),
		.d(hw2reg[41]),
		.qe(),
		.q(),
		.qs(ip_p_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[42]),
		.d(hw2reg[43]),
		.qe(),
		.q(),
		.qs(ip_p_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[44]),
		.d(hw2reg[45]),
		.qe(),
		.q(),
		.qs(ip_p_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[46]),
		.d(hw2reg[47]),
		.qe(),
		.q(),
		.qs(ip_p_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[48]),
		.d(hw2reg[49]),
		.qe(),
		.q(),
		.qs(ip_p_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[50]),
		.d(hw2reg[51]),
		.qe(),
		.q(),
		.qs(ip_p_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[52]),
		.d(hw2reg[53]),
		.qe(),
		.q(),
		.qs(ip_p_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[54]),
		.d(hw2reg[55]),
		.qe(),
		.q(),
		.qs(ip_p_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[56]),
		.d(hw2reg[57]),
		.qe(),
		.q(),
		.qs(ip_p_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[58]),
		.d(hw2reg[59]),
		.qe(),
		.q(),
		.qs(ip_p_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[60]),
		.d(hw2reg[61]),
		.qe(),
		.q(),
		.qs(ip_p_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[62]),
		.d(hw2reg[63]),
		.qe(),
		.q(),
		.qs(ip_p_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[64]),
		.d(hw2reg[65]),
		.qe(),
		.q(),
		.qs(ip_p_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[66]),
		.d(hw2reg[67]),
		.qe(),
		.q(),
		.qs(ip_p_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RO"),
		.RESVAL(1'h0)
	) u_ip_p_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[68]),
		.d(hw2reg[69]),
		.qe(),
		.q(),
		.qs(ip_p_31_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_0_we),
		.wd(le_le_0_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[140]),
		.qs(le_le_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_1_we),
		.wd(le_le_1_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[141]),
		.qs(le_le_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_2_we),
		.wd(le_le_2_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[142]),
		.qs(le_le_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_3_we),
		.wd(le_le_3_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[143]),
		.qs(le_le_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_4_we),
		.wd(le_le_4_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[144]),
		.qs(le_le_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_5_we),
		.wd(le_le_5_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[145]),
		.qs(le_le_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_6_we),
		.wd(le_le_6_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[146]),
		.qs(le_le_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_7_we),
		.wd(le_le_7_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[147]),
		.qs(le_le_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_8_we),
		.wd(le_le_8_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[148]),
		.qs(le_le_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_9_we),
		.wd(le_le_9_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[149]),
		.qs(le_le_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_10_we),
		.wd(le_le_10_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[150]),
		.qs(le_le_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_11_we),
		.wd(le_le_11_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[151]),
		.qs(le_le_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_12_we),
		.wd(le_le_12_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[152]),
		.qs(le_le_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_13_we),
		.wd(le_le_13_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[153]),
		.qs(le_le_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_14_we),
		.wd(le_le_14_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[154]),
		.qs(le_le_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_15_we),
		.wd(le_le_15_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[155]),
		.qs(le_le_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_16_we),
		.wd(le_le_16_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[156]),
		.qs(le_le_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_17_we),
		.wd(le_le_17_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[157]),
		.qs(le_le_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_18_we),
		.wd(le_le_18_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[158]),
		.qs(le_le_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_19_we),
		.wd(le_le_19_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[159]),
		.qs(le_le_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_20_we),
		.wd(le_le_20_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[160]),
		.qs(le_le_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_21_we),
		.wd(le_le_21_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[161]),
		.qs(le_le_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_22_we),
		.wd(le_le_22_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[162]),
		.qs(le_le_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_23_we),
		.wd(le_le_23_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[163]),
		.qs(le_le_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_24_we),
		.wd(le_le_24_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[164]),
		.qs(le_le_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_25_we),
		.wd(le_le_25_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[165]),
		.qs(le_le_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_26_we),
		.wd(le_le_26_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[166]),
		.qs(le_le_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_27_we),
		.wd(le_le_27_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[167]),
		.qs(le_le_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_28_we),
		.wd(le_le_28_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[168]),
		.qs(le_le_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_29_we),
		.wd(le_le_29_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[169]),
		.qs(le_le_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_30_we),
		.wd(le_le_30_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[170]),
		.qs(le_le_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_le_le_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(le_le_31_we),
		.wd(le_le_31_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[171]),
		.qs(le_le_31_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio0_we),
		.wd(prio0_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[139-:3]),
		.qs(prio0_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio1_we),
		.wd(prio1_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[136-:3]),
		.qs(prio1_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio2_we),
		.wd(prio2_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[133-:3]),
		.qs(prio2_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio3_we),
		.wd(prio3_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[130-:3]),
		.qs(prio3_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio4_we),
		.wd(prio4_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[127-:3]),
		.qs(prio4_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio5_we),
		.wd(prio5_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[124-:3]),
		.qs(prio5_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio6_we),
		.wd(prio6_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[121-:3]),
		.qs(prio6_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[118-:3]),
		.qs(prio7_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio8_we),
		.wd(prio8_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[115-:3]),
		.qs(prio8_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio9_we),
		.wd(prio9_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[112-:3]),
		.qs(prio9_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio10_we),
		.wd(prio10_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[109-:3]),
		.qs(prio10_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio11_we),
		.wd(prio11_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[106-:3]),
		.qs(prio11_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio12_we),
		.wd(prio12_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[103-:3]),
		.qs(prio12_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio13_we),
		.wd(prio13_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[100-:3]),
		.qs(prio13_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio14_we),
		.wd(prio14_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[97-:3]),
		.qs(prio14_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio15_we),
		.wd(prio15_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[94-:3]),
		.qs(prio15_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio16_we),
		.wd(prio16_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[91-:3]),
		.qs(prio16_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio17_we),
		.wd(prio17_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[88-:3]),
		.qs(prio17_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio18_we),
		.wd(prio18_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[85-:3]),
		.qs(prio18_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio19_we),
		.wd(prio19_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[82-:3]),
		.qs(prio19_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio20_we),
		.wd(prio20_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[79-:3]),
		.qs(prio20_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio21_we),
		.wd(prio21_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[76-:3]),
		.qs(prio21_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio22_we),
		.wd(prio22_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[73-:3]),
		.qs(prio22_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio23_we),
		.wd(prio23_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[70-:3]),
		.qs(prio23_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio24_we),
		.wd(prio24_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[67-:3]),
		.qs(prio24_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio25_we),
		.wd(prio25_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[64-:3]),
		.qs(prio25_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio26_we),
		.wd(prio26_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[61-:3]),
		.qs(prio26_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio27_we),
		.wd(prio27_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[58-:3]),
		.qs(prio27_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio28_we),
		.wd(prio28_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[55-:3]),
		.qs(prio28_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio29_we),
		.wd(prio29_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[52-:3]),
		.qs(prio29_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio30_we),
		.wd(prio30_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[49-:3]),
		.qs(prio30_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_prio31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(prio31_we),
		.wd(prio31_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[46-:3]),
		.qs(prio31_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_0_we),
		.wd(ie0_e_0_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[12]),
		.qs(ie0_e_0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_1_we),
		.wd(ie0_e_1_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[13]),
		.qs(ie0_e_1_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_2_we),
		.wd(ie0_e_2_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[14]),
		.qs(ie0_e_2_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_3(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_3_we),
		.wd(ie0_e_3_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[15]),
		.qs(ie0_e_3_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_4(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_4_we),
		.wd(ie0_e_4_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[16]),
		.qs(ie0_e_4_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_5(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_5_we),
		.wd(ie0_e_5_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[17]),
		.qs(ie0_e_5_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_6(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_6_we),
		.wd(ie0_e_6_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[18]),
		.qs(ie0_e_6_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_7(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_7_we),
		.wd(ie0_e_7_wd),
		.de(1'b0),
		.qe(),
		.q(reg2hw[19]),
		.qs(ie0_e_7_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_8(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_8_we),
		.wd(ie0_e_8_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[20]),
		.qs(ie0_e_8_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_9(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_9_we),
		.wd(ie0_e_9_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[21]),
		.qs(ie0_e_9_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_10(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_10_we),
		.wd(ie0_e_10_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[22]),
		.qs(ie0_e_10_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_11(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_11_we),
		.wd(ie0_e_11_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[23]),
		.qs(ie0_e_11_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_12(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_12_we),
		.wd(ie0_e_12_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[24]),
		.qs(ie0_e_12_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_13(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_13_we),
		.wd(ie0_e_13_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[25]),
		.qs(ie0_e_13_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_14(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_14_we),
		.wd(ie0_e_14_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[26]),
		.qs(ie0_e_14_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_15(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_15_we),
		.wd(ie0_e_15_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[27]),
		.qs(ie0_e_15_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_16(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_16_we),
		.wd(ie0_e_16_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[28]),
		.qs(ie0_e_16_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_17(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_17_we),
		.wd(ie0_e_17_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[29]),
		.qs(ie0_e_17_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_18(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_18_we),
		.wd(ie0_e_18_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[30]),
		.qs(ie0_e_18_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_19(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_19_we),
		.wd(ie0_e_19_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[31]),
		.qs(ie0_e_19_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_20(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_20_we),
		.wd(ie0_e_20_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[32]),
		.qs(ie0_e_20_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_21(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_21_we),
		.wd(ie0_e_21_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[33]),
		.qs(ie0_e_21_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_22(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_22_we),
		.wd(ie0_e_22_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[34]),
		.qs(ie0_e_22_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_23(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_23_we),
		.wd(ie0_e_23_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[35]),
		.qs(ie0_e_23_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_24(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_24_we),
		.wd(ie0_e_24_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[36]),
		.qs(ie0_e_24_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_25(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_25_we),
		.wd(ie0_e_25_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[37]),
		.qs(ie0_e_25_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_26(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_26_we),
		.wd(ie0_e_26_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[38]),
		.qs(ie0_e_26_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_27(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_27_we),
		.wd(ie0_e_27_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[39]),
		.qs(ie0_e_27_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_28(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_28_we),
		.wd(ie0_e_28_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[40]),
		.qs(ie0_e_28_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_29(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_29_we),
		.wd(ie0_e_29_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[41]),
		.qs(ie0_e_29_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_30(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_30_we),
		.wd(ie0_e_30_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[42]),
		.qs(ie0_e_30_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ie0_e_31(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ie0_e_31_we),
		.wd(ie0_e_31_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[43]),
		.qs(ie0_e_31_qs)
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_threshold0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(threshold0_we),
		.wd(threshold0_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[11-:3]),
		.qs(threshold0_qs)
	);
	prim_subreg_ext #(.DW(6)) u_cc0(
		.re(cc0_re),
		.we(cc0_we),
		.wd(cc0_wd),
		.d(hw2reg[5-:6]),
		.qre(reg2hw[1]),
		.qe(reg2hw[2]),
		.q(reg2hw[8-:6]),
		.qs(cc0_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_msip0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(msip0_we),
		.wd(msip0_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[-0]),
		.qs(msip0_qs)
	);
	reg [37:0] addr_hit;
	localparam signed [31:0] rv_plic_reg_pkg_BlockAw = 9;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_CC0_OFFSET = 9'h108;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_IE0_OFFSET = 9'h100;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_IP_OFFSET = 9'h000;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_LE_OFFSET = 9'h004;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_MSIP0_OFFSET = 9'h10c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO0_OFFSET = 9'h008;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO10_OFFSET = 9'h030;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO11_OFFSET = 9'h034;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO12_OFFSET = 9'h038;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO13_OFFSET = 9'h03c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO14_OFFSET = 9'h040;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO15_OFFSET = 9'h044;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO16_OFFSET = 9'h048;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO17_OFFSET = 9'h04c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO18_OFFSET = 9'h050;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO19_OFFSET = 9'h054;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO1_OFFSET = 9'h00c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO20_OFFSET = 9'h058;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO21_OFFSET = 9'h05c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO22_OFFSET = 9'h060;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO23_OFFSET = 9'h064;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO24_OFFSET = 9'h068;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO25_OFFSET = 9'h06c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO26_OFFSET = 9'h070;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO27_OFFSET = 9'h074;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO28_OFFSET = 9'h078;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO29_OFFSET = 9'h07c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO2_OFFSET = 9'h010;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO30_OFFSET = 9'h080;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO31_OFFSET = 9'h084;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO3_OFFSET = 9'h014;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO4_OFFSET = 9'h018;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO5_OFFSET = 9'h01c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO6_OFFSET = 9'h020;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO7_OFFSET = 9'h024;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO8_OFFSET = 9'h028;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_PRIO9_OFFSET = 9'h02c;
	localparam [8:0] rv_plic_reg_pkg_RV_PLIC_THRESHOLD0_OFFSET = 9'h104;
	always @(*) begin
		addr_hit = {38 {1'sb0}};
		addr_hit[0] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IP_OFFSET;
		addr_hit[1] = reg_addr == rv_plic_reg_pkg_RV_PLIC_LE_OFFSET;
		addr_hit[2] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO0_OFFSET;
		addr_hit[3] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO1_OFFSET;
		addr_hit[4] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO2_OFFSET;
		addr_hit[5] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO3_OFFSET;
		addr_hit[6] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO4_OFFSET;
		addr_hit[7] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO5_OFFSET;
		addr_hit[8] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO6_OFFSET;
		addr_hit[9] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO7_OFFSET;
		addr_hit[10] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO8_OFFSET;
		addr_hit[11] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO9_OFFSET;
		addr_hit[12] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO10_OFFSET;
		addr_hit[13] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO11_OFFSET;
		addr_hit[14] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO12_OFFSET;
		addr_hit[15] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO13_OFFSET;
		addr_hit[16] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO14_OFFSET;
		addr_hit[17] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO15_OFFSET;
		addr_hit[18] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO16_OFFSET;
		addr_hit[19] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO17_OFFSET;
		addr_hit[20] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO18_OFFSET;
		addr_hit[21] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO19_OFFSET;
		addr_hit[22] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO20_OFFSET;
		addr_hit[23] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO21_OFFSET;
		addr_hit[24] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO22_OFFSET;
		addr_hit[25] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO23_OFFSET;
		addr_hit[26] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO24_OFFSET;
		addr_hit[27] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO25_OFFSET;
		addr_hit[28] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO26_OFFSET;
		addr_hit[29] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO27_OFFSET;
		addr_hit[30] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO28_OFFSET;
		addr_hit[31] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO29_OFFSET;
		addr_hit[32] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO30_OFFSET;
		addr_hit[33] = reg_addr == rv_plic_reg_pkg_RV_PLIC_PRIO31_OFFSET;
		addr_hit[34] = reg_addr == rv_plic_reg_pkg_RV_PLIC_IE0_OFFSET;
		addr_hit[35] = reg_addr == rv_plic_reg_pkg_RV_PLIC_THRESHOLD0_OFFSET;
		addr_hit[36] = reg_addr == rv_plic_reg_pkg_RV_PLIC_CC0_OFFSET;
		addr_hit[37] = reg_addr == rv_plic_reg_pkg_RV_PLIC_MSIP0_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [151:0] rv_plic_reg_pkg_RV_PLIC_PERMIT = 152'b11111111000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100011111000100010001;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[148+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[148+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[144+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[144+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[140+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[140+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[136+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[136+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[132+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[132+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[128+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[128+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[124+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[124+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[120+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[120+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[116+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[116+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[112+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[112+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[108+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[108+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[104+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[104+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[100+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[100+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[96+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[96+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[92+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[92+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[15] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[88+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[88+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[16] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[84+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[84+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[17] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[80+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[80+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[18] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[76+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[76+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[19] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[72+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[72+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[20] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[68+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[68+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[21] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[64+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[64+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[22] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[60+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[60+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[23] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[56+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[24] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[52+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[25] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[48+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[26] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[44+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[27] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[40+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[28] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[36+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[29] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[32+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[30] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[28+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[31] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[24+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[32] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[20+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[33] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[16+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[34] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[12+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[35] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[8+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[36] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[4+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[37] && reg_we) && (rv_plic_reg_pkg_RV_PLIC_PERMIT[0+:4] != (rv_plic_reg_pkg_RV_PLIC_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign le_le_0_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_0_wd = reg_wdata[0];
	assign le_le_1_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_1_wd = reg_wdata[1];
	assign le_le_2_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_2_wd = reg_wdata[2];
	assign le_le_3_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_3_wd = reg_wdata[3];
	assign le_le_4_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_4_wd = reg_wdata[4];
	assign le_le_5_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_5_wd = reg_wdata[5];
	assign le_le_6_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_6_wd = reg_wdata[6];
	assign le_le_7_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_7_wd = reg_wdata[7];
	assign le_le_8_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_8_wd = reg_wdata[8];
	assign le_le_9_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_9_wd = reg_wdata[9];
	assign le_le_10_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_10_wd = reg_wdata[10];
	assign le_le_11_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_11_wd = reg_wdata[11];
	assign le_le_12_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_12_wd = reg_wdata[12];
	assign le_le_13_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_13_wd = reg_wdata[13];
	assign le_le_14_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_14_wd = reg_wdata[14];
	assign le_le_15_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_15_wd = reg_wdata[15];
	assign le_le_16_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_16_wd = reg_wdata[16];
	assign le_le_17_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_17_wd = reg_wdata[17];
	assign le_le_18_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_18_wd = reg_wdata[18];
	assign le_le_19_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_19_wd = reg_wdata[19];
	assign le_le_20_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_20_wd = reg_wdata[20];
	assign le_le_21_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_21_wd = reg_wdata[21];
	assign le_le_22_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_22_wd = reg_wdata[22];
	assign le_le_23_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_23_wd = reg_wdata[23];
	assign le_le_24_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_24_wd = reg_wdata[24];
	assign le_le_25_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_25_wd = reg_wdata[25];
	assign le_le_26_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_26_wd = reg_wdata[26];
	assign le_le_27_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_27_wd = reg_wdata[27];
	assign le_le_28_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_28_wd = reg_wdata[28];
	assign le_le_29_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_29_wd = reg_wdata[29];
	assign le_le_30_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_30_wd = reg_wdata[30];
	assign le_le_31_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign le_le_31_wd = reg_wdata[31];
	assign prio0_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign prio0_wd = reg_wdata[2:0];
	assign prio1_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign prio1_wd = reg_wdata[2:0];
	assign prio2_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign prio2_wd = reg_wdata[2:0];
	assign prio3_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign prio3_wd = reg_wdata[2:0];
	assign prio4_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign prio4_wd = reg_wdata[2:0];
	assign prio5_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign prio5_wd = reg_wdata[2:0];
	assign prio6_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign prio6_wd = reg_wdata[2:0];
	assign prio7_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign prio7_wd = reg_wdata[2:0];
	assign prio8_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign prio8_wd = reg_wdata[2:0];
	assign prio9_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign prio9_wd = reg_wdata[2:0];
	assign prio10_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign prio10_wd = reg_wdata[2:0];
	assign prio11_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign prio11_wd = reg_wdata[2:0];
	assign prio12_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign prio12_wd = reg_wdata[2:0];
	assign prio13_we = (addr_hit[15] & reg_we) & ~wr_err;
	assign prio13_wd = reg_wdata[2:0];
	assign prio14_we = (addr_hit[16] & reg_we) & ~wr_err;
	assign prio14_wd = reg_wdata[2:0];
	assign prio15_we = (addr_hit[17] & reg_we) & ~wr_err;
	assign prio15_wd = reg_wdata[2:0];
	assign prio16_we = (addr_hit[18] & reg_we) & ~wr_err;
	assign prio16_wd = reg_wdata[2:0];
	assign prio17_we = (addr_hit[19] & reg_we) & ~wr_err;
	assign prio17_wd = reg_wdata[2:0];
	assign prio18_we = (addr_hit[20] & reg_we) & ~wr_err;
	assign prio18_wd = reg_wdata[2:0];
	assign prio19_we = (addr_hit[21] & reg_we) & ~wr_err;
	assign prio19_wd = reg_wdata[2:0];
	assign prio20_we = (addr_hit[22] & reg_we) & ~wr_err;
	assign prio20_wd = reg_wdata[2:0];
	assign prio21_we = (addr_hit[23] & reg_we) & ~wr_err;
	assign prio21_wd = reg_wdata[2:0];
	assign prio22_we = (addr_hit[24] & reg_we) & ~wr_err;
	assign prio22_wd = reg_wdata[2:0];
	assign prio23_we = (addr_hit[25] & reg_we) & ~wr_err;
	assign prio23_wd = reg_wdata[2:0];
	assign prio24_we = (addr_hit[26] & reg_we) & ~wr_err;
	assign prio24_wd = reg_wdata[2:0];
	assign prio25_we = (addr_hit[27] & reg_we) & ~wr_err;
	assign prio25_wd = reg_wdata[2:0];
	assign prio26_we = (addr_hit[28] & reg_we) & ~wr_err;
	assign prio26_wd = reg_wdata[2:0];
	assign prio27_we = (addr_hit[29] & reg_we) & ~wr_err;
	assign prio27_wd = reg_wdata[2:0];
	assign prio28_we = (addr_hit[30] & reg_we) & ~wr_err;
	assign prio28_wd = reg_wdata[2:0];
	assign prio29_we = (addr_hit[31] & reg_we) & ~wr_err;
	assign prio29_wd = reg_wdata[2:0];
	assign prio30_we = (addr_hit[32] & reg_we) & ~wr_err;
	assign prio30_wd = reg_wdata[2:0];
	assign prio31_we = (addr_hit[33] & reg_we) & ~wr_err;
	assign prio31_wd = reg_wdata[2:0];
	assign ie0_e_0_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_0_wd = reg_wdata[0];
	assign ie0_e_1_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_1_wd = reg_wdata[1];
	assign ie0_e_2_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_2_wd = reg_wdata[2];
	assign ie0_e_3_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_3_wd = reg_wdata[3];
	assign ie0_e_4_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_4_wd = reg_wdata[4];
	assign ie0_e_5_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_5_wd = reg_wdata[5];
	assign ie0_e_6_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_6_wd = reg_wdata[6];
	assign ie0_e_7_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_7_wd = reg_wdata[7];
	assign ie0_e_8_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_8_wd = reg_wdata[8];
	assign ie0_e_9_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_9_wd = reg_wdata[9];
	assign ie0_e_10_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_10_wd = reg_wdata[10];
	assign ie0_e_11_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_11_wd = reg_wdata[11];
	assign ie0_e_12_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_12_wd = reg_wdata[12];
	assign ie0_e_13_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_13_wd = reg_wdata[13];
	assign ie0_e_14_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_14_wd = reg_wdata[14];
	assign ie0_e_15_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_15_wd = reg_wdata[15];
	assign ie0_e_16_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_16_wd = reg_wdata[16];
	assign ie0_e_17_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_17_wd = reg_wdata[17];
	assign ie0_e_18_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_18_wd = reg_wdata[18];
	assign ie0_e_19_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_19_wd = reg_wdata[19];
	assign ie0_e_20_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_20_wd = reg_wdata[20];
	assign ie0_e_21_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_21_wd = reg_wdata[21];
	assign ie0_e_22_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_22_wd = reg_wdata[22];
	assign ie0_e_23_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_23_wd = reg_wdata[23];
	assign ie0_e_24_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_24_wd = reg_wdata[24];
	assign ie0_e_25_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_25_wd = reg_wdata[25];
	assign ie0_e_26_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_26_wd = reg_wdata[26];
	assign ie0_e_27_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_27_wd = reg_wdata[27];
	assign ie0_e_28_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_28_wd = reg_wdata[28];
	assign ie0_e_29_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_29_wd = reg_wdata[29];
	assign ie0_e_30_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_30_wd = reg_wdata[30];
	assign ie0_e_31_we = (addr_hit[34] & reg_we) & ~wr_err;
	assign ie0_e_31_wd = reg_wdata[31];
	assign threshold0_we = (addr_hit[35] & reg_we) & ~wr_err;
	assign threshold0_wd = reg_wdata[2:0];
	assign cc0_we = (addr_hit[36] & reg_we) & ~wr_err;
	assign cc0_wd = reg_wdata[5:0];
	assign cc0_re = addr_hit[36] && reg_re;
	assign msip0_we = (addr_hit[37] & reg_we) & ~wr_err;
	assign msip0_wd = reg_wdata[0];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: begin
				reg_rdata_next[0] = ip_p_0_qs;
				reg_rdata_next[1] = ip_p_1_qs;
				reg_rdata_next[2] = ip_p_2_qs;
				reg_rdata_next[3] = ip_p_3_qs;
				reg_rdata_next[4] = ip_p_4_qs;
				reg_rdata_next[5] = ip_p_5_qs;
				reg_rdata_next[6] = ip_p_6_qs;
				reg_rdata_next[7] = ip_p_7_qs;
				reg_rdata_next[8] = ip_p_8_qs;
				reg_rdata_next[9] = ip_p_9_qs;
				reg_rdata_next[10] = ip_p_10_qs;
				reg_rdata_next[11] = ip_p_11_qs;
				reg_rdata_next[12] = ip_p_12_qs;
				reg_rdata_next[13] = ip_p_13_qs;
				reg_rdata_next[14] = ip_p_14_qs;
				reg_rdata_next[15] = ip_p_15_qs;
				reg_rdata_next[16] = ip_p_16_qs;
				reg_rdata_next[17] = ip_p_17_qs;
				reg_rdata_next[18] = ip_p_18_qs;
				reg_rdata_next[19] = ip_p_19_qs;
				reg_rdata_next[20] = ip_p_20_qs;
				reg_rdata_next[21] = ip_p_21_qs;
				reg_rdata_next[22] = ip_p_22_qs;
				reg_rdata_next[23] = ip_p_23_qs;
				reg_rdata_next[24] = ip_p_24_qs;
				reg_rdata_next[25] = ip_p_25_qs;
				reg_rdata_next[26] = ip_p_26_qs;
				reg_rdata_next[27] = ip_p_27_qs;
				reg_rdata_next[28] = ip_p_28_qs;
				reg_rdata_next[29] = ip_p_29_qs;
				reg_rdata_next[30] = ip_p_30_qs;
				reg_rdata_next[31] = ip_p_31_qs;
			end
			addr_hit[1]: begin
				reg_rdata_next[0] = le_le_0_qs;
				reg_rdata_next[1] = le_le_1_qs;
				reg_rdata_next[2] = le_le_2_qs;
				reg_rdata_next[3] = le_le_3_qs;
				reg_rdata_next[4] = le_le_4_qs;
				reg_rdata_next[5] = le_le_5_qs;
				reg_rdata_next[6] = le_le_6_qs;
				reg_rdata_next[7] = le_le_7_qs;
				reg_rdata_next[8] = le_le_8_qs;
				reg_rdata_next[9] = le_le_9_qs;
				reg_rdata_next[10] = le_le_10_qs;
				reg_rdata_next[11] = le_le_11_qs;
				reg_rdata_next[12] = le_le_12_qs;
				reg_rdata_next[13] = le_le_13_qs;
				reg_rdata_next[14] = le_le_14_qs;
				reg_rdata_next[15] = le_le_15_qs;
				reg_rdata_next[16] = le_le_16_qs;
				reg_rdata_next[17] = le_le_17_qs;
				reg_rdata_next[18] = le_le_18_qs;
				reg_rdata_next[19] = le_le_19_qs;
				reg_rdata_next[20] = le_le_20_qs;
				reg_rdata_next[21] = le_le_21_qs;
				reg_rdata_next[22] = le_le_22_qs;
				reg_rdata_next[23] = le_le_23_qs;
				reg_rdata_next[24] = le_le_24_qs;
				reg_rdata_next[25] = le_le_25_qs;
				reg_rdata_next[26] = le_le_26_qs;
				reg_rdata_next[27] = le_le_27_qs;
				reg_rdata_next[28] = le_le_28_qs;
				reg_rdata_next[29] = le_le_29_qs;
				reg_rdata_next[30] = le_le_30_qs;
				reg_rdata_next[31] = le_le_31_qs;
			end
			addr_hit[2]: reg_rdata_next[2:0] = prio0_qs;
			addr_hit[3]: reg_rdata_next[2:0] = prio1_qs;
			addr_hit[4]: reg_rdata_next[2:0] = prio2_qs;
			addr_hit[5]: reg_rdata_next[2:0] = prio3_qs;
			addr_hit[6]: reg_rdata_next[2:0] = prio4_qs;
			addr_hit[7]: reg_rdata_next[2:0] = prio5_qs;
			addr_hit[8]: reg_rdata_next[2:0] = prio6_qs;
			addr_hit[9]: reg_rdata_next[2:0] = prio7_qs;
			addr_hit[10]: reg_rdata_next[2:0] = prio8_qs;
			addr_hit[12]: reg_rdata_next[2:0] = prio10_qs;
			addr_hit[13]: reg_rdata_next[2:0] = prio11_qs;
			addr_hit[14]: reg_rdata_next[2:0] = prio12_qs;
			addr_hit[15]: reg_rdata_next[2:0] = prio13_qs;
			addr_hit[16]: reg_rdata_next[2:0] = prio14_qs;
			addr_hit[17]: reg_rdata_next[2:0] = prio15_qs;
			addr_hit[18]: reg_rdata_next[2:0] = prio16_qs;
			addr_hit[19]: reg_rdata_next[2:0] = prio17_qs;
			addr_hit[20]: reg_rdata_next[2:0] = prio18_qs;
			addr_hit[21]: reg_rdata_next[2:0] = prio19_qs;
			addr_hit[22]: reg_rdata_next[2:0] = prio20_qs;
			addr_hit[23]: reg_rdata_next[2:0] = prio21_qs;
			addr_hit[24]: reg_rdata_next[2:0] = prio22_qs;
			addr_hit[25]: reg_rdata_next[2:0] = prio23_qs;
			addr_hit[26]: reg_rdata_next[2:0] = prio24_qs;
			addr_hit[27]: reg_rdata_next[2:0] = prio25_qs;
			addr_hit[28]: reg_rdata_next[2:0] = prio26_qs;
			addr_hit[29]: reg_rdata_next[2:0] = prio27_qs;
			addr_hit[30]: reg_rdata_next[2:0] = prio28_qs;
			addr_hit[31]: reg_rdata_next[2:0] = prio29_qs;
			addr_hit[32]: reg_rdata_next[2:0] = prio30_qs;
			addr_hit[33]: reg_rdata_next[2:0] = prio31_qs;
			addr_hit[34]: begin
				reg_rdata_next[0] = ie0_e_0_qs;
				reg_rdata_next[1] = ie0_e_1_qs;
				reg_rdata_next[2] = ie0_e_2_qs;
				reg_rdata_next[3] = ie0_e_3_qs;
				reg_rdata_next[4] = ie0_e_4_qs;
				reg_rdata_next[5] = ie0_e_5_qs;
				reg_rdata_next[6] = ie0_e_6_qs;
				reg_rdata_next[7] = ie0_e_7_qs;
				reg_rdata_next[8] = ie0_e_8_qs;
				reg_rdata_next[9] = ie0_e_9_qs;
				reg_rdata_next[10] = ie0_e_10_qs;
				reg_rdata_next[11] = ie0_e_11_qs;
				reg_rdata_next[12] = ie0_e_12_qs;
				reg_rdata_next[13] = ie0_e_13_qs;
				reg_rdata_next[14] = ie0_e_14_qs;
				reg_rdata_next[15] = ie0_e_15_qs;
				reg_rdata_next[16] = ie0_e_16_qs;
				reg_rdata_next[17] = ie0_e_17_qs;
				reg_rdata_next[18] = ie0_e_18_qs;
				reg_rdata_next[19] = ie0_e_19_qs;
				reg_rdata_next[20] = ie0_e_20_qs;
				reg_rdata_next[21] = ie0_e_21_qs;
				reg_rdata_next[22] = ie0_e_22_qs;
				reg_rdata_next[23] = ie0_e_23_qs;
				reg_rdata_next[24] = ie0_e_24_qs;
				reg_rdata_next[25] = ie0_e_25_qs;
				reg_rdata_next[26] = ie0_e_26_qs;
				reg_rdata_next[27] = ie0_e_27_qs;
				reg_rdata_next[28] = ie0_e_28_qs;
				reg_rdata_next[29] = ie0_e_29_qs;
				reg_rdata_next[30] = ie0_e_30_qs;
				reg_rdata_next[31] = ie0_e_31_qs;
			end
			addr_hit[35]: reg_rdata_next[2:0] = threshold0_qs;
			addr_hit[36]: reg_rdata_next[5:0] = cc0_qs;
			addr_hit[37]: reg_rdata_next[0] = msip0_qs;
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
