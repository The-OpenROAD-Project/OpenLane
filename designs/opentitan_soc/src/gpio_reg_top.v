module gpio_reg_top (
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
	output wire [458:0] reg2hw;
	input wire [245:0] hw2reg;
	input devmode_i;
	localparam signed [31:0] AW = 6;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] DBW = 4;
	wire reg_we;
	wire reg_re;
	wire [5:0] reg_addr;
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
	wire [31:0] intr_state_qs;
	wire [31:0] intr_state_wd;
	wire intr_state_we;
	wire [31:0] intr_enable_qs;
	wire [31:0] intr_enable_wd;
	wire intr_enable_we;
	wire [31:0] intr_test_wd;
	wire intr_test_we;
	wire [31:0] data_in_qs;
	wire [31:0] direct_out_qs;
	wire [31:0] direct_out_wd;
	wire direct_out_we;
	wire direct_out_re;
	wire [9:0] masked_out_lower_data_qs;
	wire [5:0] masked_out_lower_data_qs_ext;
	wire [9:0] masked_out_lower_data_wd;
	wire masked_out_lower_data_we;
	wire masked_out_lower_data_re;
	wire [15:0] masked_out_lower_mask_wd;
	wire masked_out_lower_mask_we;
	wire [15:0] masked_out_upper_data_qs;
	wire [15:0] masked_out_upper_data_wd;
	wire masked_out_upper_data_we;
	wire masked_out_upper_data_re;
	wire [15:0] masked_out_upper_mask_wd;
	wire masked_out_upper_mask_we;
	wire [31:0] direct_oe_qs;
	wire [31:0] direct_oe_wd;
	wire direct_oe_we;
	wire direct_oe_re;
	wire [15:0] masked_oe_lower_data_qs;
	wire [15:0] masked_oe_lower_data_wd;
	wire masked_oe_lower_data_we;
	wire masked_oe_lower_data_re;
	wire [15:0] masked_oe_lower_mask_qs;
	wire [15:0] masked_oe_lower_mask_wd;
	wire masked_oe_lower_mask_we;
	wire masked_oe_lower_mask_re;
	wire [15:0] masked_oe_upper_data_qs;
	wire [15:0] masked_oe_upper_data_wd;
	wire masked_oe_upper_data_we;
	wire masked_oe_upper_data_re;
	wire [15:0] masked_oe_upper_mask_qs;
	wire [15:0] masked_oe_upper_mask_wd;
	wire masked_oe_upper_mask_we;
	wire masked_oe_upper_mask_re;
	wire [31:0] intr_ctrl_en_rising_qs;
	wire [31:0] intr_ctrl_en_rising_wd;
	wire intr_ctrl_en_rising_we;
	wire [31:0] intr_ctrl_en_falling_qs;
	wire [31:0] intr_ctrl_en_falling_wd;
	wire intr_ctrl_en_falling_we;
	wire [31:0] intr_ctrl_en_lvlhigh_qs;
	wire [31:0] intr_ctrl_en_lvlhigh_wd;
	wire intr_ctrl_en_lvlhigh_we;
	wire [31:0] intr_ctrl_en_lvllow_qs;
	wire [31:0] intr_ctrl_en_lvllow_wd;
	wire intr_ctrl_en_lvllow_we;
	wire [31:0] ctrl_en_input_filter_qs;
	wire [31:0] ctrl_en_input_filter_wd;
	wire ctrl_en_input_filter_we;
	prim_subreg #(
		.DW(32),
		.SWACCESS("W1C"),
		.RESVAL(32'h00000000)
	) u_intr_state(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_we),
		.wd(intr_state_wd),
		.de(hw2reg[213]),
		.d(hw2reg[245-:32]),
		.qe(),
		.q(reg2hw[458-:32]),
		.qs(intr_state_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_enable(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_we),
		.wd(intr_enable_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[426-:32]),
		.qs(intr_enable_qs)
	);
	prim_subreg_ext #(.DW(32)) u_intr_test(
		.re(1'b0),
		.we(intr_test_we),
		.wd(intr_test_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[362]),
		.q(reg2hw[394-:32]),
		.qs()
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RO"),
		.RESVAL(32'h00000000)
	) u_data_in(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(1'b0),
		.wd('0),
		.de(hw2reg[180]),
		.d(hw2reg[212-:32]),
		.qe(),
		.q(),
		.qs(data_in_qs)
	);
	prim_subreg_ext #(.DW(32)) u_direct_out(
		.re(direct_out_re),
		.we(direct_out_we),
		.wd(direct_out_wd),
		.d(hw2reg[179-:32]),
		.qre(),
		.qe(reg2hw[329]),
		.q(reg2hw[361-:32]),
		.qs(direct_out_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_data(
		.re(masked_out_lower_data_re),
		.we(masked_out_lower_data_we),
		.wd({6'b000000, masked_out_lower_data_wd}),
		.d({6'b000000, hw2reg[147-:10]}),
		.qre(),
		.qe(reg2hw[312]),
		.q(reg2hw[328-:16]),
		.qs({masked_out_lower_data_qs_ext, masked_out_lower_data_qs})
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_lower_mask(
		.re(1'b0),
		.we(masked_out_lower_mask_we),
		.wd(masked_out_lower_mask_wd),
		.d({6'b000000, hw2reg[137-:10]}),
		.qre(),
		.qe(reg2hw[295]),
		.q(reg2hw[311-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_data(
		.re(masked_out_upper_data_re),
		.we(masked_out_upper_data_we),
		.wd(masked_out_upper_data_wd),
		.d(hw2reg[127-:16]),
		.qre(),
		.qe(reg2hw[278]),
		.q(reg2hw[294-:16]),
		.qs(masked_out_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_out_upper_mask(
		.re(1'b0),
		.we(masked_out_upper_mask_we),
		.wd(masked_out_upper_mask_wd),
		.d(hw2reg[111-:16]),
		.qre(),
		.qe(reg2hw[261]),
		.q(reg2hw[277-:16]),
		.qs()
	);
	prim_subreg_ext #(.DW(32)) u_direct_oe(
		.re(direct_oe_re),
		.we(direct_oe_we),
		.wd(direct_oe_wd),
		.d(hw2reg[95-:32]),
		.qre(),
		.qe(reg2hw[228]),
		.q(reg2hw[260-:32]),
		.qs(direct_oe_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_data(
		.re(masked_oe_lower_data_re),
		.we(masked_oe_lower_data_we),
		.wd(masked_oe_lower_data_wd),
		.d(hw2reg[63-:16]),
		.qre(),
		.qe(reg2hw[211]),
		.q(reg2hw[227-:16]),
		.qs(masked_oe_lower_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_lower_mask(
		.re(masked_oe_lower_mask_re),
		.we(masked_oe_lower_mask_we),
		.wd(masked_oe_lower_mask_wd),
		.d(hw2reg[47-:16]),
		.qre(),
		.qe(reg2hw[194]),
		.q(reg2hw[210-:16]),
		.qs(masked_oe_lower_mask_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_data(
		.re(masked_oe_upper_data_re),
		.we(masked_oe_upper_data_we),
		.wd(masked_oe_upper_data_wd),
		.d(hw2reg[31-:16]),
		.qre(),
		.qe(reg2hw[177]),
		.q(reg2hw[193-:16]),
		.qs(masked_oe_upper_data_qs)
	);
	prim_subreg_ext #(.DW(16)) u_masked_oe_upper_mask(
		.re(masked_oe_upper_mask_re),
		.we(masked_oe_upper_mask_we),
		.wd(masked_oe_upper_mask_wd),
		.d(hw2reg[15-:16]),
		.qre(),
		.qe(reg2hw[160]),
		.q(reg2hw[176-:16]),
		.qs(masked_oe_upper_mask_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_rising(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_rising_we),
		.wd(intr_ctrl_en_rising_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[159-:32]),
		.qs(intr_ctrl_en_rising_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_falling(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_falling_we),
		.wd(intr_ctrl_en_falling_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[127-:32]),
		.qs(intr_ctrl_en_falling_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvlhigh(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvlhigh_we),
		.wd(intr_ctrl_en_lvlhigh_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[95-:32]),
		.qs(intr_ctrl_en_lvlhigh_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_intr_ctrl_en_lvllow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_ctrl_en_lvllow_we),
		.wd(intr_ctrl_en_lvllow_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[63-:32]),
		.qs(intr_ctrl_en_lvllow_qs)
	);
	prim_subreg #(
		.DW(32),
		.SWACCESS("RW"),
		.RESVAL(32'h00000000)
	) u_ctrl_en_input_filter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_en_input_filter_we),
		.wd(ctrl_en_input_filter_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[31-:32]),
		.qs(ctrl_en_input_filter_qs)
	);
	reg [14:0] addr_hit;
	localparam [5:0] gpio_reg_pkg_GPIO_CTRL_EN_INPUT_FILTER_OFFSET = 6'h38;
	localparam [5:0] gpio_reg_pkg_GPIO_DATA_IN_OFFSET = 6'h0c;
	localparam [5:0] gpio_reg_pkg_GPIO_DIRECT_OE_OFFSET = 6'h1c;
	localparam [5:0] gpio_reg_pkg_GPIO_DIRECT_OUT_OFFSET = 6'h10;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_FALLING_OFFSET = 6'h2c;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET = 6'h30;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLLOW_OFFSET = 6'h34;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_CTRL_EN_RISING_OFFSET = 6'h28;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] gpio_reg_pkg_GPIO_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OE_LOWER_OFFSET = 6'h20;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OE_UPPER_OFFSET = 6'h24;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OUT_LOWER_OFFSET = 6'h14;
	localparam [5:0] gpio_reg_pkg_GPIO_MASKED_OUT_UPPER_OFFSET = 6'h18;
	always @(*) begin
		addr_hit = {15 {1'sb0}};
		addr_hit[0] = reg_addr == gpio_reg_pkg_GPIO_INTR_STATE_OFFSET;
		addr_hit[1] = reg_addr == gpio_reg_pkg_GPIO_INTR_ENABLE_OFFSET;
		addr_hit[2] = reg_addr == gpio_reg_pkg_GPIO_INTR_TEST_OFFSET;
		addr_hit[3] = reg_addr == gpio_reg_pkg_GPIO_DATA_IN_OFFSET;
		addr_hit[4] = reg_addr == gpio_reg_pkg_GPIO_DIRECT_OUT_OFFSET;
		addr_hit[5] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OUT_LOWER_OFFSET;
		addr_hit[6] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OUT_UPPER_OFFSET;
		addr_hit[7] = reg_addr == gpio_reg_pkg_GPIO_DIRECT_OE_OFFSET;
		addr_hit[8] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OE_LOWER_OFFSET;
		addr_hit[9] = reg_addr == gpio_reg_pkg_GPIO_MASKED_OE_UPPER_OFFSET;
		addr_hit[10] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_RISING_OFFSET;
		addr_hit[11] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_FALLING_OFFSET;
		addr_hit[12] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLHIGH_OFFSET;
		addr_hit[13] = reg_addr == gpio_reg_pkg_GPIO_INTR_CTRL_EN_LVLLOW_OFFSET;
		addr_hit[14] = reg_addr == gpio_reg_pkg_GPIO_CTRL_EN_INPUT_FILTER_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [59:0] gpio_reg_pkg_GPIO_PERMIT = 60'b111111111111111111111111111111111111111111111111111111111111;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[56+:4] != (gpio_reg_pkg_GPIO_PERMIT[56+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[52+:4] != (gpio_reg_pkg_GPIO_PERMIT[52+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[48+:4] != (gpio_reg_pkg_GPIO_PERMIT[48+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[44+:4] != (gpio_reg_pkg_GPIO_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[40+:4] != (gpio_reg_pkg_GPIO_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[36+:4] != (gpio_reg_pkg_GPIO_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[32+:4] != (gpio_reg_pkg_GPIO_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[28+:4] != (gpio_reg_pkg_GPIO_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[24+:4] != (gpio_reg_pkg_GPIO_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[20+:4] != (gpio_reg_pkg_GPIO_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[16+:4] != (gpio_reg_pkg_GPIO_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[12+:4] != (gpio_reg_pkg_GPIO_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[12] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[8+:4] != (gpio_reg_pkg_GPIO_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[13] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[4+:4] != (gpio_reg_pkg_GPIO_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[14] && reg_we) && (gpio_reg_pkg_GPIO_PERMIT[0+:4] != (gpio_reg_pkg_GPIO_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
		if (reg_wdata > 32'h000fffff)
			wr_err = 1'b1;
	end
	assign intr_state_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_wd = reg_wdata[31:0];
	assign intr_enable_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_wd = reg_wdata[31:0];
	assign intr_test_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_wd = reg_wdata[31:0];
	assign direct_out_we = (addr_hit[4] & reg_we) & ~wr_err;
	assign direct_out_wd = reg_wdata[31:0];
	assign direct_out_re = addr_hit[4] && reg_re;
	assign masked_out_lower_data_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_data_wd = reg_wdata[9:0];
	assign masked_out_lower_data_re = addr_hit[5] && reg_re;
	assign masked_out_lower_mask_we = (addr_hit[5] & reg_we) & ~wr_err;
	assign masked_out_lower_mask_wd = {12'b111111111111, reg_wdata[19:10]};
	assign masked_out_upper_data_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_data_wd = reg_wdata[15:0];
	assign masked_out_upper_data_re = addr_hit[6] && reg_re;
	assign masked_out_upper_mask_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign masked_out_upper_mask_wd = reg_wdata[31:16];
	assign direct_oe_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign direct_oe_wd = reg_wdata[31:0];
	assign direct_oe_re = addr_hit[7] && reg_re;
	assign masked_oe_lower_data_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_data_wd = reg_wdata[15:0];
	assign masked_oe_lower_data_re = addr_hit[8] && reg_re;
	assign masked_oe_lower_mask_we = (addr_hit[8] & reg_we) & ~wr_err;
	assign masked_oe_lower_mask_wd = reg_wdata[31:16];
	assign masked_oe_lower_mask_re = addr_hit[8] && reg_re;
	assign masked_oe_upper_data_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_data_wd = reg_wdata[15:0];
	assign masked_oe_upper_data_re = addr_hit[9] && reg_re;
	assign masked_oe_upper_mask_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign masked_oe_upper_mask_wd = reg_wdata[31:16];
	assign masked_oe_upper_mask_re = addr_hit[9] && reg_re;
	assign intr_ctrl_en_rising_we = (addr_hit[10] & reg_we) & ~wr_err;
	assign intr_ctrl_en_rising_wd = reg_wdata[31:0];
	assign intr_ctrl_en_falling_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign intr_ctrl_en_falling_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvlhigh_we = (addr_hit[12] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvlhigh_wd = reg_wdata[31:0];
	assign intr_ctrl_en_lvllow_we = (addr_hit[13] & reg_we) & ~wr_err;
	assign intr_ctrl_en_lvllow_wd = reg_wdata[31:0];
	assign ctrl_en_input_filter_we = (addr_hit[14] & reg_we) & ~wr_err;
	assign ctrl_en_input_filter_wd = reg_wdata[31:0];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: reg_rdata_next[31:0] = intr_state_qs;
			addr_hit[1]: reg_rdata_next[31:0] = intr_enable_qs;
			addr_hit[2]: reg_rdata_next[31:0] = {32 {1'sb0}};
			addr_hit[3]: reg_rdata_next[31:0] = data_in_qs;
			addr_hit[4]: reg_rdata_next[31:0] = direct_out_qs;
			addr_hit[5]: begin
				reg_rdata_next[9:0] = masked_out_lower_data_qs;
				reg_rdata_next[31:10] = 22'b1111111111110000000000;
			end
			addr_hit[6]: begin
				reg_rdata_next[15:0] = masked_out_upper_data_qs;
				reg_rdata_next[31:16] = {16 {1'sb0}};
			end
			addr_hit[7]: reg_rdata_next[31:0] = direct_oe_qs;
			addr_hit[8]: begin
				reg_rdata_next[15:0] = masked_oe_lower_data_qs;
				reg_rdata_next[31:16] = masked_oe_lower_mask_qs;
			end
			addr_hit[9]: begin
				reg_rdata_next[15:0] = masked_oe_upper_data_qs;
				reg_rdata_next[31:16] = masked_oe_upper_mask_qs;
			end
			addr_hit[10]: reg_rdata_next[31:0] = intr_ctrl_en_rising_qs;
			addr_hit[11]: reg_rdata_next[31:0] = intr_ctrl_en_falling_qs;
			addr_hit[12]: reg_rdata_next[31:0] = intr_ctrl_en_lvlhigh_qs;
			addr_hit[13]: reg_rdata_next[31:0] = intr_ctrl_en_lvllow_qs;
			addr_hit[14]: reg_rdata_next[31:0] = ctrl_en_input_filter_qs;
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
