module opentitan_tlul_wrapper (
	clk_i,
	rst_ni,
	ram_cfg_i,
	scan_rst_ni,
	crash_dump_o,
	tl_i_i,
	tl_i_o,
	tl_d_i,
	tl_d_o,
	test_en_i,
	hart_id_i,
	boot_addr_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	fetch_enable_i,
	alert_minor_o,
	alert_major_o,
	core_sleep_o
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b1;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] SecureIbex = 1'b0;
	parameter [31:0] DmHaltAddr = 0;
	parameter [31:0] DmExceptionAddr = 0;
	input clk_i;
	input rst_ni;
	input wire ram_cfg_i;
	input wire scan_rst_ni;
	output wire [127:0] crash_dump_o;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [51:0] tl_i_i;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	output wire [85:0] tl_i_o;
	input wire [51:0] tl_d_i;
	output wire [85:0] tl_d_o;
	input wire test_en_i;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_o;
	output wire core_sleep_o;
	wire instr_req;
	wire instr_gnt;
	wire instr_rvalid;
	wire [31:0] instr_addr;
	wire [31:0] instr_rdata;
	wire instr_err;
	wire data_req;
	wire data_gnt;
	wire data_rvalid;
	wire data_we;
	wire [3:0] data_be;
	wire [31:0] data_addr;
	wire [31:0] data_wdata;
	wire [31:0] data_rdata;
	wire data_err;
	ibex_top #(
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.RV32E(RV32E),
		.BranchTargetALU(BranchTargetALU),
		.WritebackStage(WritebackStage),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BranchPredictor(BranchPredictor),
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.SecureIbex(SecureIbex),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr)
	) u_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.ram_cfg_i({10 {ram_cfg_i}}),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req),
		.instr_gnt_i(instr_gnt),
		.instr_rvalid_i(instr_rvalid),
		.instr_addr_o(instr_addr),
		.instr_rdata_i(instr_rdata),
		.instr_err_i(instr_err),
		.data_req_o(data_req),
		.data_gnt_i(data_gnt),
		.data_rvalid_i(data_rvalid),
		.data_we_o(data_we),
		.data_be_o(data_be),
		.data_addr_o(data_addr),
		.data_wdata_o(data_wdata),
		.data_rdata_i(data_rdata),
		.data_err_i(data_err),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.irq_nm_i(irq_nm_i),
		.debug_req_i(1'b0),
		.fetch_enable_i(fetch_enable_i),
		.alert_minor_o(alert_minor_o),
		.alert_major_o(alert_major_o),
		.core_sleep_o(core_sleep_o),
		.crash_dump_o(crash_dump_o),
		.scan_rst_ni(scan_rst_ni)
	);
	tlul_host_adapter #(.MAX_REQS(2)) intr_interface(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(instr_req),
		.gnt_o(instr_gnt),
		.addr_i(instr_addr),
		.we_i(1'b0),
		.wdata_i(32'b00000000000000000000000000000000),
		.be_i(4'hf),
		.valid_o(instr_rvalid),
		.rdata_o(instr_rdata),
		.err_o(instr_err),
		.tl_h_c_a(tl_i_o),
		.tl_h_c_d(tl_i_i)
	);
	tlul_host_adapter #(.MAX_REQS(2)) data_interface(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(data_req),
		.gnt_o(data_gnt),
		.addr_i(data_addr),
		.we_i(data_we),
		.wdata_i(data_wdata),
		.be_i(data_be),
		.valid_o(data_rvalid),
		.rdata_o(data_rdata),
		.err_o(data_err),
		.tl_h_c_a(tl_d_o),
		.tl_h_c_d(tl_d_i)
	);
endmodule
