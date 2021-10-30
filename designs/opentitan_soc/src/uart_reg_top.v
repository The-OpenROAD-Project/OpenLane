module uart_reg_top (
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
	output wire [124:0] reg2hw;
	input wire [64:0] hw2reg;
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
	wire intr_state_tx_watermark_qs;
	wire intr_state_tx_watermark_wd;
	wire intr_state_tx_watermark_we;
	wire intr_state_rx_watermark_qs;
	wire intr_state_rx_watermark_wd;
	wire intr_state_rx_watermark_we;
	wire intr_state_tx_empty_qs;
	wire intr_state_tx_empty_wd;
	wire intr_state_tx_empty_we;
	wire intr_state_rx_overflow_qs;
	wire intr_state_rx_overflow_wd;
	wire intr_state_rx_overflow_we;
	wire intr_state_rx_frame_err_qs;
	wire intr_state_rx_frame_err_wd;
	wire intr_state_rx_frame_err_we;
	wire intr_state_rx_break_err_qs;
	wire intr_state_rx_break_err_wd;
	wire intr_state_rx_break_err_we;
	wire intr_state_rx_timeout_qs;
	wire intr_state_rx_timeout_wd;
	wire intr_state_rx_timeout_we;
	wire intr_state_rx_parity_err_qs;
	wire intr_state_rx_parity_err_wd;
	wire intr_state_rx_parity_err_we;
	wire intr_enable_tx_watermark_qs;
	wire intr_enable_tx_watermark_wd;
	wire intr_enable_tx_watermark_we;
	wire intr_enable_rx_watermark_qs;
	wire intr_enable_rx_watermark_wd;
	wire intr_enable_rx_watermark_we;
	wire intr_enable_tx_empty_qs;
	wire intr_enable_tx_empty_wd;
	wire intr_enable_tx_empty_we;
	wire intr_enable_rx_overflow_qs;
	wire intr_enable_rx_overflow_wd;
	wire intr_enable_rx_overflow_we;
	wire intr_enable_rx_frame_err_qs;
	wire intr_enable_rx_frame_err_wd;
	wire intr_enable_rx_frame_err_we;
	wire intr_enable_rx_break_err_qs;
	wire intr_enable_rx_break_err_wd;
	wire intr_enable_rx_break_err_we;
	wire intr_enable_rx_timeout_qs;
	wire intr_enable_rx_timeout_wd;
	wire intr_enable_rx_timeout_we;
	wire intr_enable_rx_parity_err_qs;
	wire intr_enable_rx_parity_err_wd;
	wire intr_enable_rx_parity_err_we;
	wire intr_test_tx_watermark_wd;
	wire intr_test_tx_watermark_we;
	wire intr_test_rx_watermark_wd;
	wire intr_test_rx_watermark_we;
	wire intr_test_tx_empty_wd;
	wire intr_test_tx_empty_we;
	wire intr_test_rx_overflow_wd;
	wire intr_test_rx_overflow_we;
	wire intr_test_rx_frame_err_wd;
	wire intr_test_rx_frame_err_we;
	wire intr_test_rx_break_err_wd;
	wire intr_test_rx_break_err_we;
	wire intr_test_rx_timeout_wd;
	wire intr_test_rx_timeout_we;
	wire intr_test_rx_parity_err_wd;
	wire intr_test_rx_parity_err_we;
	wire ctrl_tx_qs;
	wire ctrl_tx_wd;
	wire ctrl_tx_we;
	wire ctrl_rx_qs;
	wire ctrl_rx_wd;
	wire ctrl_rx_we;
	wire ctrl_nf_qs;
	wire ctrl_nf_wd;
	wire ctrl_nf_we;
	wire ctrl_slpbk_qs;
	wire ctrl_slpbk_wd;
	wire ctrl_slpbk_we;
	wire ctrl_llpbk_qs;
	wire ctrl_llpbk_wd;
	wire ctrl_llpbk_we;
	wire ctrl_parity_en_qs;
	wire ctrl_parity_en_wd;
	wire ctrl_parity_en_we;
	wire ctrl_parity_odd_qs;
	wire ctrl_parity_odd_wd;
	wire ctrl_parity_odd_we;
	wire [1:0] ctrl_rxblvl_qs;
	wire [1:0] ctrl_rxblvl_wd;
	wire ctrl_rxblvl_we;
	wire [15:0] ctrl_nco_qs;
	wire [15:0] ctrl_nco_wd;
	wire ctrl_nco_we;
	wire status_txfull_qs;
	wire status_txfull_re;
	wire status_rxfull_qs;
	wire status_rxfull_re;
	wire status_txempty_qs;
	wire status_txempty_re;
	wire status_txidle_qs;
	wire status_txidle_re;
	wire status_rxidle_qs;
	wire status_rxidle_re;
	wire status_rxempty_qs;
	wire status_rxempty_re;
	wire [7:0] rdata_qs;
	wire rdata_re;
	wire [7:0] wdata_wd;
	wire wdata_we;
	wire fifo_ctrl_rxrst_wd;
	wire fifo_ctrl_rxrst_we;
	wire fifo_ctrl_txrst_wd;
	wire fifo_ctrl_txrst_we;
	wire [2:0] fifo_ctrl_rxilvl_qs;
	wire [2:0] fifo_ctrl_rxilvl_wd;
	wire fifo_ctrl_rxilvl_we;
	wire [1:0] fifo_ctrl_txilvl_qs;
	wire [1:0] fifo_ctrl_txilvl_wd;
	wire fifo_ctrl_txilvl_we;
	wire [5:0] fifo_status_txlvl_qs;
	wire fifo_status_txlvl_re;
	wire [5:0] fifo_status_rxlvl_qs;
	wire fifo_status_rxlvl_re;
	wire ovrd_txen_qs;
	wire ovrd_txen_wd;
	wire ovrd_txen_we;
	wire ovrd_txval_qs;
	wire ovrd_txval_wd;
	wire ovrd_txval_we;
	wire [15:0] val_qs;
	wire val_re;
	wire [23:0] timeout_ctrl_val_qs;
	wire [23:0] timeout_ctrl_val_wd;
	wire timeout_ctrl_val_we;
	wire timeout_ctrl_en_qs;
	wire timeout_ctrl_en_wd;
	wire timeout_ctrl_en_we;
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_tx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_tx_watermark_we),
		.wd(intr_state_tx_watermark_wd),
		.de(hw2reg[63]),
		.d(hw2reg[64]),
		.qe(),
		.q(reg2hw[124]),
		.qs(intr_state_tx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_watermark_we),
		.wd(intr_state_rx_watermark_wd),
		.de(hw2reg[61]),
		.d(hw2reg[62]),
		.qe(),
		.q(reg2hw[123]),
		.qs(intr_state_rx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_tx_empty(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_tx_empty_we),
		.wd(intr_state_tx_empty_wd),
		.de(hw2reg[59]),
		.d(hw2reg[60]),
		.qe(),
		.q(reg2hw[122]),
		.qs(intr_state_tx_empty_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_overflow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_overflow_we),
		.wd(intr_state_rx_overflow_wd),
		.de(hw2reg[57]),
		.d(hw2reg[58]),
		.qe(),
		.q(reg2hw[121]),
		.qs(intr_state_rx_overflow_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_frame_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_frame_err_we),
		.wd(intr_state_rx_frame_err_wd),
		.de(hw2reg[55]),
		.d(hw2reg[56]),
		.qe(),
		.q(reg2hw[120]),
		.qs(intr_state_rx_frame_err_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_break_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_break_err_we),
		.wd(intr_state_rx_break_err_wd),
		.de(hw2reg[53]),
		.d(hw2reg[54]),
		.qe(),
		.q(reg2hw[119]),
		.qs(intr_state_rx_break_err_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_timeout(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_timeout_we),
		.wd(intr_state_rx_timeout_wd),
		.de(hw2reg[51]),
		.d(hw2reg[52]),
		.qe(),
		.q(reg2hw[118]),
		.qs(intr_state_rx_timeout_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("W1C"),
		.RESVAL(1'h0)
	) u_intr_state_rx_parity_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_state_rx_parity_err_we),
		.wd(intr_state_rx_parity_err_wd),
		.de(hw2reg[49]),
		.d(hw2reg[50]),
		.qe(),
		.q(reg2hw[117]),
		.qs(intr_state_rx_parity_err_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_tx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_tx_watermark_we),
		.wd(intr_enable_tx_watermark_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[116]),
		.qs(intr_enable_tx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_watermark(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_watermark_we),
		.wd(intr_enable_rx_watermark_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[115]),
		.qs(intr_enable_rx_watermark_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_tx_empty(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_tx_empty_we),
		.wd(intr_enable_tx_empty_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[114]),
		.qs(intr_enable_tx_empty_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_overflow(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_overflow_we),
		.wd(intr_enable_rx_overflow_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[113]),
		.qs(intr_enable_rx_overflow_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_frame_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_frame_err_we),
		.wd(intr_enable_rx_frame_err_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[112]),
		.qs(intr_enable_rx_frame_err_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_break_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_break_err_we),
		.wd(intr_enable_rx_break_err_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[111]),
		.qs(intr_enable_rx_break_err_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_timeout(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_timeout_we),
		.wd(intr_enable_rx_timeout_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[110]),
		.qs(intr_enable_rx_timeout_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_intr_enable_rx_parity_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(intr_enable_rx_parity_err_we),
		.wd(intr_enable_rx_parity_err_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[109]),
		.qs(intr_enable_rx_parity_err_qs)
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_tx_watermark(
		.re(1'b0),
		.we(intr_test_tx_watermark_we),
		.wd(intr_test_tx_watermark_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[107]),
		.q(reg2hw[108]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_watermark(
		.re(1'b0),
		.we(intr_test_rx_watermark_we),
		.wd(intr_test_rx_watermark_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[105]),
		.q(reg2hw[106]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_tx_empty(
		.re(1'b0),
		.we(intr_test_tx_empty_we),
		.wd(intr_test_tx_empty_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[103]),
		.q(reg2hw[104]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_overflow(
		.re(1'b0),
		.we(intr_test_rx_overflow_we),
		.wd(intr_test_rx_overflow_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[101]),
		.q(reg2hw[102]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_frame_err(
		.re(1'b0),
		.we(intr_test_rx_frame_err_we),
		.wd(intr_test_rx_frame_err_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[99]),
		.q(reg2hw[100]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_break_err(
		.re(1'b0),
		.we(intr_test_rx_break_err_we),
		.wd(intr_test_rx_break_err_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[97]),
		.q(reg2hw[98]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_timeout(
		.re(1'b0),
		.we(intr_test_rx_timeout_we),
		.wd(intr_test_rx_timeout_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[95]),
		.q(reg2hw[96]),
		.qs()
	);
	prim_subreg_ext #(.DW(1)) u_intr_test_rx_parity_err(
		.re(1'b0),
		.we(intr_test_rx_parity_err_we),
		.wd(intr_test_rx_parity_err_wd),
		.d('0),
		.qre(),
		.qe(reg2hw[93]),
		.q(reg2hw[94]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_tx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_tx_we),
		.wd(ctrl_tx_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[92]),
		.qs(ctrl_tx_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_rx(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_rx_we),
		.wd(ctrl_rx_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[91]),
		.qs(ctrl_rx_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_nf(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_nf_we),
		.wd(ctrl_nf_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[90]),
		.qs(ctrl_nf_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_slpbk(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_slpbk_we),
		.wd(ctrl_slpbk_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[89]),
		.qs(ctrl_slpbk_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_llpbk(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_llpbk_we),
		.wd(ctrl_llpbk_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[88]),
		.qs(ctrl_llpbk_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_parity_en(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_parity_en_we),
		.wd(ctrl_parity_en_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[87]),
		.qs(ctrl_parity_en_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ctrl_parity_odd(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_parity_odd_we),
		.wd(ctrl_parity_odd_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[86]),
		.qs(ctrl_parity_odd_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_ctrl_rxblvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_rxblvl_we),
		.wd(ctrl_rxblvl_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[85-:2]),
		.qs(ctrl_rxblvl_qs)
	);
	prim_subreg #(
		.DW(16),
		.SWACCESS("RW"),
		.RESVAL(16'h0000)
	) u_ctrl_nco(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ctrl_nco_we),
		.wd(ctrl_nco_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[83-:16]),
		.qs(ctrl_nco_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txfull(
		.re(status_txfull_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[48]),
		.qre(reg2hw[66]),
		.qe(),
		.q(reg2hw[67]),
		.qs(status_txfull_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxfull(
		.re(status_rxfull_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[47]),
		.qre(reg2hw[64]),
		.qe(),
		.q(reg2hw[65]),
		.qs(status_rxfull_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txempty(
		.re(status_txempty_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[46]),
		.qre(reg2hw[62]),
		.qe(),
		.q(reg2hw[63]),
		.qs(status_txempty_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_txidle(
		.re(status_txidle_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[45]),
		.qre(reg2hw[60]),
		.qe(),
		.q(reg2hw[61]),
		.qs(status_txidle_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxidle(
		.re(status_rxidle_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[44]),
		.qre(reg2hw[58]),
		.qe(),
		.q(reg2hw[59]),
		.qs(status_rxidle_qs)
	);
	prim_subreg_ext #(.DW(1)) u_status_rxempty(
		.re(status_rxempty_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[43]),
		.qre(reg2hw[56]),
		.qe(),
		.q(reg2hw[57]),
		.qs(status_rxempty_qs)
	);
	prim_subreg_ext #(.DW(8)) u_rdata(
		.re(rdata_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[42-:8]),
		.qre(reg2hw[47]),
		.qe(),
		.q(reg2hw[55-:8]),
		.qs(rdata_qs)
	);
	prim_subreg #(
		.DW(8),
		.SWACCESS("WO"),
		.RESVAL(8'h00)
	) u_wdata(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(wdata_we),
		.wd(wdata_wd),
		.de(1'b0),
		.d('0),
		.qe(reg2hw[38]),
		.q(reg2hw[46-:8]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("WO"),
		.RESVAL(1'h0)
	) u_fifo_ctrl_rxrst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_rxrst_we),
		.wd(fifo_ctrl_rxrst_wd),
		.de(1'b0),
		.d('0),
		.qe(reg2hw[36]),
		.q(reg2hw[37]),
		.qs()
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("WO"),
		.RESVAL(1'h0)
	) u_fifo_ctrl_txrst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_txrst_we),
		.wd(fifo_ctrl_txrst_wd),
		.de(1'b0),
		.d('0),
		.qe(reg2hw[34]),
		.q(reg2hw[35]),
		.qs()
	);
	prim_subreg #(
		.DW(3),
		.SWACCESS("RW"),
		.RESVAL(3'h0)
	) u_fifo_ctrl_rxilvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_rxilvl_we),
		.wd(fifo_ctrl_rxilvl_wd),
		.de(hw2reg[31]),
		.d(hw2reg[34-:3]),
		.qe(reg2hw[30]),
		.q(reg2hw[33-:3]),
		.qs(fifo_ctrl_rxilvl_qs)
	);
	prim_subreg #(
		.DW(2),
		.SWACCESS("RW"),
		.RESVAL(2'h0)
	) u_fifo_ctrl_txilvl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(fifo_ctrl_txilvl_we),
		.wd(fifo_ctrl_txilvl_wd),
		.de(hw2reg[28]),
		.d(hw2reg[30-:2]),
		.qe(reg2hw[27]),
		.q(reg2hw[29-:2]),
		.qs(fifo_ctrl_txilvl_qs)
	);
	prim_subreg_ext #(.DW(6)) u_fifo_status_txlvl(
		.re(fifo_status_txlvl_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[27-:6]),
		.qre(),
		.qe(),
		.q(),
		.qs(fifo_status_txlvl_qs)
	);
	prim_subreg_ext #(.DW(6)) u_fifo_status_rxlvl(
		.re(fifo_status_rxlvl_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[21-:6]),
		.qre(),
		.qe(),
		.q(),
		.qs(fifo_status_rxlvl_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ovrd_txen(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ovrd_txen_we),
		.wd(ovrd_txen_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[26]),
		.qs(ovrd_txen_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_ovrd_txval(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(ovrd_txval_we),
		.wd(ovrd_txval_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[25]),
		.qs(ovrd_txval_qs)
	);
	prim_subreg_ext #(.DW(16)) u_val(
		.re(val_re),
		.we(1'b0),
		.wd('0),
		.d(hw2reg[15-:16]),
		.qre(),
		.qe(),
		.q(),
		.qs(val_qs)
	);
	prim_subreg #(
		.DW(24),
		.SWACCESS("RW"),
		.RESVAL(24'h000000)
	) u_timeout_ctrl_val(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timeout_ctrl_val_we),
		.wd(timeout_ctrl_val_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[24-:24]),
		.qs(timeout_ctrl_val_qs)
	);
	prim_subreg #(
		.DW(1),
		.SWACCESS("RW"),
		.RESVAL(1'h0)
	) u_timeout_ctrl_en(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.we(timeout_ctrl_en_we),
		.wd(timeout_ctrl_en_wd),
		.de(1'b0),
		.d('0),
		.qe(),
		.q(reg2hw[-0]),
		.qs(timeout_ctrl_en_qs)
	);
	reg [11:0] addr_hit;
	localparam signed [31:0] uart_reg_pkg_BlockAw = 6;
	localparam [5:0] uart_reg_pkg_UART_CTRL_OFFSET = 6'h0c;
	localparam [5:0] uart_reg_pkg_UART_FIFO_CTRL_OFFSET = 6'h1c;
	localparam [5:0] uart_reg_pkg_UART_FIFO_STATUS_OFFSET = 6'h20;
	localparam [5:0] uart_reg_pkg_UART_INTR_ENABLE_OFFSET = 6'h04;
	localparam [5:0] uart_reg_pkg_UART_INTR_STATE_OFFSET = 6'h00;
	localparam [5:0] uart_reg_pkg_UART_INTR_TEST_OFFSET = 6'h08;
	localparam [5:0] uart_reg_pkg_UART_OVRD_OFFSET = 6'h24;
	localparam [5:0] uart_reg_pkg_UART_RDATA_OFFSET = 6'h14;
	localparam [5:0] uart_reg_pkg_UART_STATUS_OFFSET = 6'h10;
	localparam [5:0] uart_reg_pkg_UART_TIMEOUT_CTRL_OFFSET = 6'h2c;
	localparam [5:0] uart_reg_pkg_UART_VAL_OFFSET = 6'h28;
	localparam [5:0] uart_reg_pkg_UART_WDATA_OFFSET = 6'h18;
	always @(*) begin
		addr_hit = {12 {1'sb0}};
		addr_hit[0] = reg_addr == uart_reg_pkg_UART_INTR_STATE_OFFSET;
		addr_hit[1] = reg_addr == uart_reg_pkg_UART_INTR_ENABLE_OFFSET;
		addr_hit[2] = reg_addr == uart_reg_pkg_UART_INTR_TEST_OFFSET;
		addr_hit[3] = reg_addr == uart_reg_pkg_UART_CTRL_OFFSET;
		addr_hit[4] = reg_addr == uart_reg_pkg_UART_STATUS_OFFSET;
		addr_hit[5] = reg_addr == uart_reg_pkg_UART_RDATA_OFFSET;
		addr_hit[6] = reg_addr == uart_reg_pkg_UART_WDATA_OFFSET;
		addr_hit[7] = reg_addr == uart_reg_pkg_UART_FIFO_CTRL_OFFSET;
		addr_hit[8] = reg_addr == uart_reg_pkg_UART_FIFO_STATUS_OFFSET;
		addr_hit[9] = reg_addr == uart_reg_pkg_UART_OVRD_OFFSET;
		addr_hit[10] = reg_addr == uart_reg_pkg_UART_VAL_OFFSET;
		addr_hit[11] = reg_addr == uart_reg_pkg_UART_TIMEOUT_CTRL_OFFSET;
	end
	assign addrmiss = (reg_re || reg_we ? ~|addr_hit : 1'b0);
	localparam [47:0] uart_reg_pkg_UART_PERMIT = 48'b000100010001111100010001000100010111000100111111;
	always @(*) begin
		wr_err = 1'b0;
		if ((addr_hit[0] && reg_we) && (uart_reg_pkg_UART_PERMIT[44+:4] != (uart_reg_pkg_UART_PERMIT[44+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[1] && reg_we) && (uart_reg_pkg_UART_PERMIT[40+:4] != (uart_reg_pkg_UART_PERMIT[40+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[2] && reg_we) && (uart_reg_pkg_UART_PERMIT[36+:4] != (uart_reg_pkg_UART_PERMIT[36+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[3] && reg_we) && (uart_reg_pkg_UART_PERMIT[32+:4] != (uart_reg_pkg_UART_PERMIT[32+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[4] && reg_we) && (uart_reg_pkg_UART_PERMIT[28+:4] != (uart_reg_pkg_UART_PERMIT[28+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[5] && reg_we) && (uart_reg_pkg_UART_PERMIT[24+:4] != (uart_reg_pkg_UART_PERMIT[24+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[6] && reg_we) && (uart_reg_pkg_UART_PERMIT[20+:4] != (uart_reg_pkg_UART_PERMIT[20+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[7] && reg_we) && (uart_reg_pkg_UART_PERMIT[16+:4] != (uart_reg_pkg_UART_PERMIT[16+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[8] && reg_we) && (uart_reg_pkg_UART_PERMIT[12+:4] != (uart_reg_pkg_UART_PERMIT[12+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[9] && reg_we) && (uart_reg_pkg_UART_PERMIT[8+:4] != (uart_reg_pkg_UART_PERMIT[8+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[10] && reg_we) && (uart_reg_pkg_UART_PERMIT[4+:4] != (uart_reg_pkg_UART_PERMIT[4+:4] & reg_be)))
			wr_err = 1'b1;
		if ((addr_hit[11] && reg_we) && (uart_reg_pkg_UART_PERMIT[0+:4] != (uart_reg_pkg_UART_PERMIT[0+:4] & reg_be)))
			wr_err = 1'b1;
	end
	assign intr_state_tx_watermark_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_tx_watermark_wd = reg_wdata[0];
	assign intr_state_rx_watermark_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_watermark_wd = reg_wdata[1];
	assign intr_state_tx_empty_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_tx_empty_wd = reg_wdata[2];
	assign intr_state_rx_overflow_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_overflow_wd = reg_wdata[3];
	assign intr_state_rx_frame_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_frame_err_wd = reg_wdata[4];
	assign intr_state_rx_break_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_break_err_wd = reg_wdata[5];
	assign intr_state_rx_timeout_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_timeout_wd = reg_wdata[6];
	assign intr_state_rx_parity_err_we = (addr_hit[0] & reg_we) & ~wr_err;
	assign intr_state_rx_parity_err_wd = reg_wdata[7];
	assign intr_enable_tx_watermark_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_tx_watermark_wd = reg_wdata[0];
	assign intr_enable_rx_watermark_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_watermark_wd = reg_wdata[1];
	assign intr_enable_tx_empty_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_tx_empty_wd = reg_wdata[2];
	assign intr_enable_rx_overflow_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_overflow_wd = reg_wdata[3];
	assign intr_enable_rx_frame_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_frame_err_wd = reg_wdata[4];
	assign intr_enable_rx_break_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_break_err_wd = reg_wdata[5];
	assign intr_enable_rx_timeout_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_timeout_wd = reg_wdata[6];
	assign intr_enable_rx_parity_err_we = (addr_hit[1] & reg_we) & ~wr_err;
	assign intr_enable_rx_parity_err_wd = reg_wdata[7];
	assign intr_test_tx_watermark_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_tx_watermark_wd = reg_wdata[0];
	assign intr_test_rx_watermark_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_watermark_wd = reg_wdata[1];
	assign intr_test_tx_empty_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_tx_empty_wd = reg_wdata[2];
	assign intr_test_rx_overflow_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_overflow_wd = reg_wdata[3];
	assign intr_test_rx_frame_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_frame_err_wd = reg_wdata[4];
	assign intr_test_rx_break_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_break_err_wd = reg_wdata[5];
	assign intr_test_rx_timeout_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_timeout_wd = reg_wdata[6];
	assign intr_test_rx_parity_err_we = (addr_hit[2] & reg_we) & ~wr_err;
	assign intr_test_rx_parity_err_wd = reg_wdata[7];
	assign ctrl_tx_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_tx_wd = reg_wdata[0];
	assign ctrl_rx_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_rx_wd = reg_wdata[1];
	assign ctrl_nf_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_nf_wd = reg_wdata[2];
	assign ctrl_slpbk_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_slpbk_wd = reg_wdata[4];
	assign ctrl_llpbk_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_llpbk_wd = reg_wdata[5];
	assign ctrl_parity_en_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_parity_en_wd = reg_wdata[6];
	assign ctrl_parity_odd_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_parity_odd_wd = reg_wdata[7];
	assign ctrl_rxblvl_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_rxblvl_wd = reg_wdata[9:8];
	assign ctrl_nco_we = (addr_hit[3] & reg_we) & ~wr_err;
	assign ctrl_nco_wd = reg_wdata[31:16];
	assign status_txfull_re = addr_hit[4] && reg_re;
	assign status_rxfull_re = addr_hit[4] && reg_re;
	assign status_txempty_re = addr_hit[4] && reg_re;
	assign status_txidle_re = addr_hit[4] && reg_re;
	assign status_rxidle_re = addr_hit[4] && reg_re;
	assign status_rxempty_re = addr_hit[4] && reg_re;
	assign rdata_re = addr_hit[5] && reg_re;
	assign wdata_we = (addr_hit[6] & reg_we) & ~wr_err;
	assign wdata_wd = reg_wdata[7:0];
	assign fifo_ctrl_rxrst_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_rxrst_wd = reg_wdata[0];
	assign fifo_ctrl_txrst_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_txrst_wd = reg_wdata[1];
	assign fifo_ctrl_rxilvl_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_rxilvl_wd = reg_wdata[4:2];
	assign fifo_ctrl_txilvl_we = (addr_hit[7] & reg_we) & ~wr_err;
	assign fifo_ctrl_txilvl_wd = reg_wdata[6:5];
	assign fifo_status_txlvl_re = addr_hit[8] && reg_re;
	assign fifo_status_rxlvl_re = addr_hit[8] && reg_re;
	assign ovrd_txen_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign ovrd_txen_wd = reg_wdata[0];
	assign ovrd_txval_we = (addr_hit[9] & reg_we) & ~wr_err;
	assign ovrd_txval_wd = reg_wdata[1];
	assign val_re = addr_hit[10] && reg_re;
	assign timeout_ctrl_val_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign timeout_ctrl_val_wd = reg_wdata[23:0];
	assign timeout_ctrl_en_we = (addr_hit[11] & reg_we) & ~wr_err;
	assign timeout_ctrl_en_wd = reg_wdata[31];
	always @(*) begin
		reg_rdata_next = {32 {1'sb0}};
		case (1'b1)
			addr_hit[0]: begin
				reg_rdata_next[0] = intr_state_tx_watermark_qs;
				reg_rdata_next[1] = intr_state_rx_watermark_qs;
				reg_rdata_next[2] = intr_state_tx_empty_qs;
				reg_rdata_next[3] = intr_state_rx_overflow_qs;
				reg_rdata_next[4] = intr_state_rx_frame_err_qs;
				reg_rdata_next[5] = intr_state_rx_break_err_qs;
				reg_rdata_next[6] = intr_state_rx_timeout_qs;
				reg_rdata_next[7] = intr_state_rx_parity_err_qs;
			end
			addr_hit[1]: begin
				reg_rdata_next[0] = intr_enable_tx_watermark_qs;
				reg_rdata_next[1] = intr_enable_rx_watermark_qs;
				reg_rdata_next[2] = intr_enable_tx_empty_qs;
				reg_rdata_next[3] = intr_enable_rx_overflow_qs;
				reg_rdata_next[4] = intr_enable_rx_frame_err_qs;
				reg_rdata_next[5] = intr_enable_rx_break_err_qs;
				reg_rdata_next[6] = intr_enable_rx_timeout_qs;
				reg_rdata_next[7] = intr_enable_rx_parity_err_qs;
			end
			addr_hit[2]: begin
				reg_rdata_next[0] = 1'b0;
				reg_rdata_next[1] = 1'b0;
				reg_rdata_next[2] = 1'b0;
				reg_rdata_next[3] = 1'b0;
				reg_rdata_next[4] = 1'b0;
				reg_rdata_next[5] = 1'b0;
				reg_rdata_next[6] = 1'b0;
				reg_rdata_next[7] = 1'b0;
			end
			addr_hit[3]: begin
				reg_rdata_next[0] = ctrl_tx_qs;
				reg_rdata_next[1] = ctrl_rx_qs;
				reg_rdata_next[2] = ctrl_nf_qs;
				reg_rdata_next[4] = ctrl_slpbk_qs;
				reg_rdata_next[5] = ctrl_llpbk_qs;
				reg_rdata_next[6] = ctrl_parity_en_qs;
				reg_rdata_next[7] = ctrl_parity_odd_qs;
				reg_rdata_next[9:8] = ctrl_rxblvl_qs;
				reg_rdata_next[31:16] = ctrl_nco_qs;
			end
			addr_hit[4]: begin
				reg_rdata_next[0] = status_txfull_qs;
				reg_rdata_next[1] = status_rxfull_qs;
				reg_rdata_next[2] = status_txempty_qs;
				reg_rdata_next[3] = status_txidle_qs;
				reg_rdata_next[4] = status_rxidle_qs;
				reg_rdata_next[5] = status_rxempty_qs;
			end
			addr_hit[5]: reg_rdata_next[7:0] = rdata_qs;
			addr_hit[6]: reg_rdata_next[7:0] = {8 {1'sb0}};
			addr_hit[7]: begin
				reg_rdata_next[0] = 1'b0;
				reg_rdata_next[1] = 1'b0;
				reg_rdata_next[4:2] = fifo_ctrl_rxilvl_qs;
				reg_rdata_next[6:5] = fifo_ctrl_txilvl_qs;
			end
			addr_hit[8]: begin
				reg_rdata_next[5:0] = fifo_status_txlvl_qs;
				reg_rdata_next[21:16] = fifo_status_rxlvl_qs;
			end
			addr_hit[9]: begin
				reg_rdata_next[0] = ovrd_txen_qs;
				reg_rdata_next[1] = ovrd_txval_qs;
			end
			addr_hit[10]: reg_rdata_next[15:0] = val_qs;
			addr_hit[11]: begin
				reg_rdata_next[23:0] = timeout_ctrl_val_qs;
				reg_rdata_next[31] = timeout_ctrl_en_qs;
			end
			default: reg_rdata_next = {32 {1'sb1}};
		endcase
	end
endmodule
