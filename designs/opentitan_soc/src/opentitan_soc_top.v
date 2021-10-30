module opentitan_soc_top (
	clk_i,
	rst_ni,
	en_i,
	sel,
	spi_ss,
	spi_mosi,
	uart_rx_inst,
	uart_rx,
	uart_tx,
	uart_txen,
	tempsense_clkref,
	tempsense_clkout,
	gpio_o
);
	parameter DATA_WIDTH = 'd32;
	input wire clk_i;
	input wire rst_ni;
	input wire en_i;
	input wire sel;
	input wire spi_ss;
	input wire spi_mosi;
	input wire uart_rx_inst;
	input wire uart_rx;
	output wire uart_tx;
	output wire uart_txen;
	input wire tempsense_clkref;
	output wire tempsense_clkout;
	output wire [7:0] gpio_o;
	wire system_rst_ni;
	wire [7:0] gpio_out;
	wire [23:0] gpio_out_ext;
	assign gpio_o = gpio_out;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	wire [85:0] ifu_to_xbar;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	wire [51:0] xbar_to_ifu;
	wire [85:0] xbar_to_iccm;
	wire [85:0] xbar_to_dccm;
	wire [51:0] iccm_to_xbar;
	wire [51:0] dccm_to_xbar;
	wire [85:0] lsu_to_xbar;
	wire [51:0] xbar_to_lsu;
	wire [85:0] xbar_to_gpio;
	wire [51:0] gpio_to_xbar;
	wire [85:0] xbar_to_ldo1;
	wire [51:0] ldo1_to_xbar;
	wire [85:0] xbar_to_ldo2;
	wire [51:0] ldo2_to_xbar;
	wire [85:0] xbar_to_dcdc;
	wire [51:0] dcdc_to_xbar;
	wire [85:0] xbar_to_pll1;
	wire [51:0] pll1_to_xbar;
	wire [85:0] xbar_to_tsen1;
	wire [51:0] tsen1_to_xbar;
	wire [85:0] xbar_to_tsen2;
	wire [51:0] tsen2_to_xbar;
	wire [85:0] xbar_to_dap;
	wire [51:0] dap_to_xbar;
	wire [85:0] xbar_to_uart;
	wire [51:0] uart_to_xbar;
	wire [85:0] plic_req;
	wire [51:0] plic_resp;
	wire [85:0] xbar_to_dbgrom;
	wire [51:0] dbgrom_to_xbar;
	wire [85:0] dm_to_xbar;
	wire [51:0] xbar_to_dm;
	wire [31:0] intr_vector;
	wire [31:0] intr_gpio;
	wire intr_uart0_tx_watermark;
	wire intr_uart0_rx_watermark;
	wire intr_uart0_tx_empty;
	wire intr_uart0_rx_overflow;
	wire intr_uart0_rx_frame_err;
	wire intr_uart0_rx_break_err;
	wire intr_uart0_rx_timeout;
	wire intr_uart0_rx_parity_err;
	wire intr_req;
	assign intr_vector = {intr_gpio, intr_uart0_rx_parity_err, intr_uart0_rx_timeout, intr_uart0_rx_break_err, intr_uart0_rx_frame_err, intr_uart0_rx_overflow, intr_uart0_tx_empty, intr_uart0_rx_watermark, intr_uart0_tx_watermark, 1'b0};
	wire [31:0] gpio_intr;
	wire instr_valid;
	wire [11:0] tlul_addr;
	wire [31:0] tlul_data;
	wire rx_dv_i;
	wire [7:0] rx_byte_i;
	wire iccm_cntrl_reset;
	wire [1:0] iccm_cntrl_addr_ext;
	wire [11:0] iccm_cntrl_addr;
	wire [31:0] iccm_cntrl_data;
	wire iccm_cntrl_we;
	wire [31:0] rx_spi_inst_i;
	wire rx_spi_valid_i;
	reg [2:0] rst_buf;
	wire rst_sync;
	reg [2:0] en_buf;
	wire en_sync;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rst_buf <= 3'b000;
			en_buf <= 3'b000;
		end
		else begin
			rst_buf <= {rst_ni, rst_buf[2:1]};
			en_buf <= {en_i, en_buf[2:1]};
		end
	assign rst_sync = rst_buf[0];
	assign en_sync = en_buf[0];
	wire enable_rst_ni;
	assign enable_rst_ni = en_sync && system_rst_ni;
	wire intr_timer;
	opentitan_tlul_wrapper u_top(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.ram_cfg_i(1'b1),
		.scan_rst_ni(),
		.crash_dump_o(),
		.tl_i_i(xbar_to_ifu),
		.tl_i_o(ifu_to_xbar),
		.tl_d_i(xbar_to_lsu),
		.tl_d_o(lsu_to_xbar),
		.test_en_i(1'b1),
		.hart_id_i(32'b00000000000000000000000000000000),
		.boot_addr_i(32'h20000000),
		.irq_software_i(1'b0),
		.irq_timer_i(intr_timer),
		.irq_external_i(intr_req),
		.irq_fast_i(15'b000000000000000),
		.irq_nm_i(1'b0),
		.fetch_enable_i(1'b1),
		.alert_minor_o(),
		.alert_major_o(),
		.core_sleep_o()
	);
	xbar_periph periph_switch(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_if_i(ifu_to_xbar),
		.tl_if_o(xbar_to_ifu),
		.tl_lsu_i(lsu_to_xbar),
		.tl_lsu_o(xbar_to_lsu),
		.tl_iccm_o(xbar_to_iccm),
		.tl_iccm_i(iccm_to_xbar),
		.tl_dccm_o(xbar_to_dccm),
		.tl_dccm_i(dccm_to_xbar),
		.tl_gpio_o(xbar_to_gpio),
		.tl_gpio_i(gpio_to_xbar),
		.tl_ldo1_o(),
		.tl_ldo1_i(),
		.tl_ldo2_o(),
		.tl_ldo2_i(),
		.tl_dcdc_o(),
		.tl_dcdc_i(),
		.tl_pll1_o(),
		.tl_pll1_i(),
		.tl_tsen1_o(xbar_to_tsen1),
		.tl_tsen1_i(tsen1_to_xbar),
		.tl_tsen2_o(),
		.tl_tsen2_i(),
		.tl_dap_o(),
		.tl_dap_i(),
		.tl_plic_o(plic_req),
		.tl_plic_i(plic_resp),
		.tl_uart_o(xbar_to_uart),
		.tl_uart_i(uart_to_xbar)
	);
	gpio gpio_32(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_i(xbar_to_gpio),
		.tl_o(gpio_to_xbar),
		.cio_gpio_o({gpio_out_ext, gpio_out}),
		.cio_gpio_en_o(),
		.intr_gpio_o(intr_gpio)
	);
	wire req_i;
	instr_mem_top iccm(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.req(req_i),
		.addr((enable_rst_ni ? tlul_addr : iccm_cntrl_addr)),
		.wdata(iccm_cntrl_data),
		.rdata(tlul_data),
		.rvalid(instr_valid),
		.wen(iccm_cntrl_reset),
		.wmask(4'b1111),
		.we(1'b0)
	);
	reg [31:0] inst_buffer;
	always @(posedge clk_i or negedge enable_rst_ni)
		if (!enable_rst_ni)
			inst_buffer <= 'b0;
		else
			inst_buffer <= tlul_data;
	tlul_sram_adapter #(
		.SramAw(12),
		.SramDw(32),
		.Outstanding(2),
		.ByteAccess(1),
		.ErrOnWrite(0),
		.ErrOnRead(0)
	) inst_mem(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_i(xbar_to_iccm),
		.tl_o(iccm_to_xbar),
		.req_o(req_i),
		.gnt_i(1'b1),
		.we_o(),
		.addr_o(tlul_addr),
		.wdata_o(),
		.wmask_o(),
		.rdata_i((enable_rst_ni ? inst_buffer : '0)),
		.rvalid_i(instr_valid),
		.rerror_i(2'b00)
	);
	data_mem_tlul dccm(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_d_i(xbar_to_dccm),
		.tl_d_o(dccm_to_xbar)
	);
	iccm_controller u_dut(
		.clk_i(clk_i),
		.rst_ni(rst_sync),
		.rx_dv_i((sel ? rx_dv_i : rx_spi_valid_i)),
		.rx_byte_i(rx_byte_i),
		.we_o(iccm_cntrl_we),
		.addr_o({iccm_cntrl_addr_ext, iccm_cntrl_addr}),
		.wdata_o(iccm_cntrl_data),
		.reset_o(iccm_cntrl_reset),
		.rx_spi_i(rx_spi_inst_i),
		.sel(sel)
	);
	SPI_slave #(.DATA_WIDTH(DATA_WIDTH)) u_spi(
		.reset(rst_sync),
		.SS(spi_ss),
		.SCLK(clk_i),
		.MOSI(spi_mosi),
		.REG_DIN(rx_spi_inst_i),
		.valid(rx_spi_valid_i)
	);
	uart_receiver programmer(
		.i_Clock(clk_i),
		.rst_ni(rst_sync),
		.i_Rx_Serial(uart_rx_inst),
		.CLKS_PER_BIT(16'd20834),
		.o_Rx_DV(rx_dv_i),
		.o_Rx_Byte(rx_byte_i)
	);
	rstmgr reset_manager(
		.clk_i(clk_i),
		.rst_ni(rst_sync),
		.iccm_rst_i(iccm_cntrl_reset),
		.sys_rst_ni(system_rst_ni)
	);
	rv_plic intr_controller(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_i(plic_req),
		.tl_o(plic_resp),
		.intr_src_i(intr_vector),
		.irq_o(intr_req),
		.irq_id_o(),
		.msip_o()
	);
	uart u_uart0(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_i(xbar_to_uart),
		.tl_o(uart_to_xbar),
		.cio_rx_i(uart_rx),
		.cio_tx_o(uart_tx),
		.cio_tx_en_o(uart_txen),
		.intr_tx_watermark_o(intr_uart0_tx_watermark),
		.intr_rx_watermark_o(intr_uart0_rx_watermark),
		.intr_tx_empty_o(intr_uart0_tx_empty),
		.intr_rx_overflow_o(intr_uart0_rx_overflow),
		.intr_rx_frame_err_o(intr_uart0_rx_frame_err),
		.intr_rx_break_err_o(intr_uart0_rx_break_err),
		.intr_rx_timeout_o(intr_uart0_rx_timeout),
		.intr_rx_parity_err_o(intr_uart0_rx_parity_err)
	);
	tlul_adapter_tempsensor u_tempsense(
		.clk_i(clk_i),
		.rst_ni(enable_rst_ni),
		.tl_i(xbar_to_tsen1),
		.tl_o(tsen1_to_xbar),
		.re_o(),
		.we_o(),
		.addr_o(),
		.wdata_o(),
		.be_o(),
		.rdata_i(),
		.error_i(),
		.CLK_REF(tempsense_clkref),
		.CLK_OUT(tempsense_clkout)
	);
endmodule
