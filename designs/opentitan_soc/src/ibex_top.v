module ibex_top (
	clk_i,
	rst_ni,
	test_en_i,
	ram_cfg_i,
	hart_id_i,
	boot_addr_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	data_err_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	debug_req_i,
	crash_dump_o,
	fetch_enable_i,
	alert_minor_o,
	alert_major_o,
	core_sleep_o,
	scan_rst_ni
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	parameter [0:0] RV32E = 1'b0;
	localparam integer ibex_pkg_RV32MFast = 2;
	parameter integer RV32M = ibex_pkg_RV32MFast;
	localparam integer ibex_pkg_RV32BNone = 0;
	parameter integer RV32B = ibex_pkg_RV32BNone;
	localparam integer ibex_pkg_RegFileFF = 0;
	parameter integer RegFile = ibex_pkg_RegFileFF;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] SecureIbex = 1'b0;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [9:0] ram_cfg_i;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire data_err_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	output wire [127:0] crash_dump_o;
	input wire fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_o;
	output wire core_sleep_o;
	input wire scan_rst_ni;
	localparam [0:0] Lockstep = SecureIbex;
	localparam [0:0] DummyInstructions = SecureIbex;
	localparam [0:0] RegFileECC = SecureIbex;
	localparam [31:0] RegFileDataWidth = (RegFileECC ? 39 : 32);
	localparam [31:0] ibex_pkg_BUS_SIZE = 32;
	localparam [31:0] BusSizeECC = (ICacheECC ? 39 : ibex_pkg_BUS_SIZE);
	localparam [31:0] ibex_pkg_BUS_BYTES = 4;
	localparam [31:0] ibex_pkg_IC_LINE_SIZE = 64;
	localparam [31:0] ibex_pkg_IC_LINE_BYTES = 8;
	localparam [31:0] ibex_pkg_IC_LINE_BEATS = 2;
	localparam [31:0] LineSizeECC = BusSizeECC * ibex_pkg_IC_LINE_BEATS;
	localparam [31:0] ibex_pkg_ADDR_W = 32;
	localparam [31:0] ibex_pkg_IC_NUM_WAYS = 2;
	localparam [31:0] ibex_pkg_IC_SIZE_BYTES = 4096;
	localparam [31:0] ibex_pkg_IC_NUM_LINES = 256;
	localparam [31:0] ibex_pkg_IC_INDEX_W = 8;
	localparam [31:0] ibex_pkg_IC_LINE_W = 3;
	localparam [31:0] ibex_pkg_IC_TAG_SIZE = 22;
	localparam [31:0] TagSizeECC = (ICacheECC ? 28 : ibex_pkg_IC_TAG_SIZE);
	wire clk;
	wire core_busy_d;
	reg core_busy_q;
	wire clock_en;
	wire irq_pending;
	wire dummy_instr_id;
	wire [4:0] rf_raddr_a;
	wire [4:0] rf_raddr_b;
	wire [4:0] rf_waddr_wb;
	wire rf_we_wb;
	wire [RegFileDataWidth - 1:0] rf_wdata_wb_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_a_ecc;
	wire [RegFileDataWidth - 1:0] rf_rdata_b_ecc;
	wire [1:0] ic_tag_req;
	wire ic_tag_write;
	wire [7:0] ic_tag_addr;
	wire [TagSizeECC - 1:0] ic_tag_wdata;
	wire [(ibex_pkg_IC_NUM_WAYS * TagSizeECC) - 1:0] ic_tag_rdata;
	wire [1:0] ic_data_req;
	wire ic_data_write;
	wire [7:0] ic_data_addr;
	wire [LineSizeECC - 1:0] ic_data_wdata;
	wire [(ibex_pkg_IC_NUM_WAYS * LineSizeECC) - 1:0] ic_data_rdata;
	wire core_alert_major;
	wire core_alert_minor;
	wire lockstep_alert_major;
	wire lockstep_alert_minor;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			core_busy_q <= 1'b0;
		else
			core_busy_q <= core_busy_d;
	assign clock_en = ((core_busy_q | debug_req_i) | irq_pending) | irq_nm_i;
	assign core_sleep_o = ~clock_en;
	prim_clock_gating core_clock_gate_i(
		.clk_i(clk_i),
		.en_i(clock_en),
		.test_en_i(test_en_i),
		.clk_o(clk)
	);
	ibex_core #(
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.BranchTargetALU(BranchTargetALU),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BusSizeECC(BusSizeECC),
		.TagSizeECC(TagSizeECC),
		.LineSizeECC(LineSizeECC),
		.BranchPredictor(BranchPredictor),
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.WritebackStage(WritebackStage),
		.SecureIbex(SecureIbex),
		.DummyInstructions(DummyInstructions),
		.RegFileECC(RegFileECC),
		.RegFileDataWidth(RegFileDataWidth),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr)
	) u_ibex_core(
		.clk_i(clk),
		.rst_ni(rst_ni),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_addr_o(instr_addr_o),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_i(instr_err_i),
		.data_req_o(data_req_o),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_addr_o(data_addr_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.data_err_i(data_err_i),
		.dummy_instr_id_o(dummy_instr_id),
		.rf_raddr_a_o(rf_raddr_a),
		.rf_raddr_b_o(rf_raddr_b),
		.rf_waddr_wb_o(rf_waddr_wb),
		.rf_we_wb_o(rf_we_wb),
		.rf_wdata_wb_ecc_o(rf_wdata_wb_ecc),
		.rf_rdata_a_ecc_i(rf_rdata_a_ecc),
		.rf_rdata_b_ecc_i(rf_rdata_b_ecc),
		.ic_tag_req_o(ic_tag_req),
		.ic_tag_write_o(ic_tag_write),
		.ic_tag_addr_o(ic_tag_addr),
		.ic_tag_wdata_o(ic_tag_wdata),
		.ic_tag_rdata_i(ic_tag_rdata),
		.ic_data_req_o(ic_data_req),
		.ic_data_write_o(ic_data_write),
		.ic_data_addr_o(ic_data_addr),
		.ic_data_wdata_o(ic_data_wdata),
		.ic_data_rdata_i(ic_data_rdata),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.irq_nm_i(irq_nm_i),
		.irq_pending_o(irq_pending),
		.debug_req_i(debug_req_i),
		.crash_dump_o(crash_dump_o),
		.fetch_enable_i(fetch_enable_i),
		.alert_minor_o(core_alert_minor),
		.alert_major_o(core_alert_major),
		.core_busy_o(core_busy_d)
	);
	localparam integer ibex_pkg_RegFileFPGA = 1;
	localparam integer ibex_pkg_RegFileLatch = 2;
	generate
		if (RegFile == ibex_pkg_RegFileFF) begin : gen_regfile_ff
			ibex_register_file_ff #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
		else if (RegFile == ibex_pkg_RegFileFPGA) begin : gen_regfile_fpga
			ibex_register_file_fpga #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
		else if (RegFile == ibex_pkg_RegFileLatch) begin : gen_regfile_latch
			ibex_register_file_latch #(
				.RV32E(RV32E),
				.DataWidth(RegFileDataWidth),
				.DummyInstructions(DummyInstructions)
			) register_file_i(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.dummy_instr_id_i(dummy_instr_id),
				.raddr_a_i(rf_raddr_a),
				.rdata_a_o(rf_rdata_a_ecc),
				.raddr_b_i(rf_raddr_b),
				.rdata_b_o(rf_rdata_b_ecc),
				.waddr_a_i(rf_waddr_wb),
				.wdata_a_i(rf_wdata_wb_ecc),
				.we_a_i(rf_we_wb)
			);
		end
	endgenerate
	generate
		if (ICache) begin : gen_rams
			genvar way;
			for (way = 0; way < ibex_pkg_IC_NUM_WAYS; way = way + 1) begin : gen_rams_inner
				prim_ram_1p #(
					.Width(TagSizeECC),
					.Depth(ibex_pkg_IC_NUM_LINES),
					.DataBitsPerMask(TagSizeECC)
				) tag_bank(
					.clk_i(clk_i),
					.req_i(ic_tag_req[way]),
					.cfg_i(ram_cfg_i),
					.write_i(ic_tag_write),
					.wmask_i({TagSizeECC {1'b1}}),
					.addr_i(ic_tag_addr),
					.wdata_i(ic_tag_wdata),
					.rdata_o(ic_tag_rdata[(1 - way) * TagSizeECC+:TagSizeECC])
				);
				prim_ram_1p #(
					.Width(LineSizeECC),
					.Depth(ibex_pkg_IC_NUM_LINES),
					.DataBitsPerMask(LineSizeECC)
				) data_bank(
					.clk_i(clk_i),
					.req_i(ic_data_req[way]),
					.cfg_i(ram_cfg_i),
					.write_i(ic_data_write),
					.wmask_i({LineSizeECC {1'b1}}),
					.addr_i(ic_data_addr),
					.wdata_i(ic_data_wdata),
					.rdata_o(ic_data_rdata[(1 - way) * LineSizeECC+:LineSizeECC])
				);
			end
		end
		else begin : gen_norams
			wire [9:0] unused_ram_cfg;
			wire unused_ram_inputs;
			assign unused_ram_cfg = ram_cfg_i;
			assign unused_ram_inputs = ((((((|ic_tag_req & ic_tag_write) & |ic_tag_addr) & |ic_tag_wdata) & |ic_data_req) & ic_data_write) & |ic_data_addr) & |ic_data_wdata;
			function automatic [TagSizeECC - 1:0] sv2v_cast_B79A2;
				input reg [TagSizeECC - 1:0] inp;
				sv2v_cast_B79A2 = inp;
			endfunction
			assign ic_tag_rdata = {ibex_pkg_IC_NUM_WAYS {sv2v_cast_B79A2('b0)}};
			function automatic [LineSizeECC - 1:0] sv2v_cast_528D9;
				input reg [LineSizeECC - 1:0] inp;
				sv2v_cast_528D9 = inp;
			endfunction
			assign ic_data_rdata = {ibex_pkg_IC_NUM_WAYS {sv2v_cast_528D9('b0)}};
		end
	endgenerate
	generate
		if (Lockstep) begin : gen_lockstep
			localparam signed [31:0] NumBufferBits = (((((((254 + RegFileDataWidth) + RegFileDataWidth) + RegFileDataWidth) + 11) + TagSizeECC) + 11) + LineSizeECC) + 151;
			wire [NumBufferBits - 1:0] buf_in;
			wire [NumBufferBits - 1:0] buf_out;
			wire [31:0] hart_id_local;
			wire [31:0] boot_addr_local;
			wire instr_req_local;
			wire instr_gnt_local;
			wire instr_rvalid_local;
			wire [31:0] instr_addr_local;
			wire [31:0] instr_rdata_local;
			wire instr_err_local;
			wire data_req_local;
			wire data_gnt_local;
			wire data_rvalid_local;
			wire data_we_local;
			wire [3:0] data_be_local;
			wire [31:0] data_addr_local;
			wire [31:0] data_wdata_local;
			wire [31:0] data_rdata_local;
			wire data_err_local;
			wire dummy_instr_id_local;
			wire [4:0] rf_raddr_a_local;
			wire [4:0] rf_raddr_b_local;
			wire [4:0] rf_waddr_wb_local;
			wire rf_we_wb_local;
			wire [RegFileDataWidth - 1:0] rf_wdata_wb_ecc_local;
			wire [RegFileDataWidth - 1:0] rf_rdata_a_ecc_local;
			wire [RegFileDataWidth - 1:0] rf_rdata_b_ecc_local;
			wire [1:0] ic_tag_req_local;
			wire ic_tag_write_local;
			wire [7:0] ic_tag_addr_local;
			wire [TagSizeECC - 1:0] ic_tag_wdata_local;
			wire [1:0] ic_data_req_local;
			wire ic_data_write_local;
			wire [7:0] ic_data_addr_local;
			wire [LineSizeECC - 1:0] ic_data_wdata_local;
			wire irq_software_local;
			wire irq_timer_local;
			wire irq_external_local;
			wire [14:0] irq_fast_local;
			wire irq_nm_local;
			wire irq_pending_local;
			wire debug_req_local;
			wire [127:0] crash_dump_local;
			wire fetch_enable_local;
			wire core_busy_local;
			assign buf_in = {hart_id_i, boot_addr_i, instr_req_o, instr_gnt_i, instr_rvalid_i, instr_addr_o, instr_rdata_i, instr_err_i, data_req_o, data_gnt_i, data_rvalid_i, data_we_o, data_be_o, data_addr_o, data_wdata_o, data_rdata_i, data_err_i, dummy_instr_id, rf_raddr_a, rf_raddr_b, rf_waddr_wb, rf_we_wb, rf_wdata_wb_ecc, rf_rdata_a_ecc, rf_rdata_b_ecc, ic_tag_req, ic_tag_write, ic_tag_addr, ic_tag_wdata, ic_data_req, ic_data_write, ic_data_addr, ic_data_wdata, irq_software_i, irq_timer_i, irq_external_i, irq_fast_i, irq_nm_i, irq_pending, debug_req_i, crash_dump_o, fetch_enable_i, core_busy_d};
			assign {hart_id_local, boot_addr_local, instr_req_local, instr_gnt_local, instr_rvalid_local, instr_addr_local, instr_rdata_local, instr_err_local, data_req_local, data_gnt_local, data_rvalid_local, data_we_local, data_be_local, data_addr_local, data_wdata_local, data_rdata_local, data_err_local, dummy_instr_id_local, rf_raddr_a_local, rf_raddr_b_local, rf_waddr_wb_local, rf_we_wb_local, rf_wdata_wb_ecc_local, rf_rdata_a_ecc_local, rf_rdata_b_ecc_local, ic_tag_req_local, ic_tag_write_local, ic_tag_addr_local, ic_tag_wdata_local, ic_data_req_local, ic_data_write_local, ic_data_addr_local, ic_data_wdata_local, irq_software_local, irq_timer_local, irq_external_local, irq_fast_local, irq_nm_local, irq_pending_local, debug_req_local, crash_dump_local, fetch_enable_local, core_busy_local} = buf_out;
			genvar k;
			for (k = 0; k < NumBufferBits; k = k + 1) begin : gen_buffers
				prim_buf u_prim_buf(
					.in_i(buf_in[k]),
					.out_o(buf_out[k])
				);
			end
			wire [(ibex_pkg_IC_NUM_WAYS * TagSizeECC) - 1:0] ic_tag_rdata_local;
			wire [(ibex_pkg_IC_NUM_WAYS * LineSizeECC) - 1:0] ic_data_rdata_local;
			for (k = 0; k < ibex_pkg_IC_NUM_WAYS; k = k + 1) begin : gen_ways
				genvar j;
				for (j = 0; j < TagSizeECC; j = j + 1) begin : gen_tag_bufs
					prim_buf u_prim_buf(
						.in_i(ic_tag_rdata[((1 - k) * TagSizeECC) + j]),
						.out_o(ic_tag_rdata_local[((1 - k) * TagSizeECC) + j])
					);
				end
				for (j = 0; j < LineSizeECC; j = j + 1) begin : gen_data_bufs
					prim_buf u_prim_buf(
						.in_i(ic_data_rdata[((1 - k) * LineSizeECC) + j]),
						.out_o(ic_data_rdata_local[((1 - k) * LineSizeECC) + j])
					);
				end
			end
			wire lockstep_alert_minor_local;
			wire lockstep_alert_major_local;
			ibex_lockstep #(
				.PMPEnable(PMPEnable),
				.PMPGranularity(PMPGranularity),
				.PMPNumRegions(PMPNumRegions),
				.MHPMCounterNum(MHPMCounterNum),
				.MHPMCounterWidth(MHPMCounterWidth),
				.RV32E(RV32E),
				.RV32M(RV32M),
				.RV32B(RV32B),
				.BranchTargetALU(BranchTargetALU),
				.ICache(ICache),
				.ICacheECC(ICacheECC),
				.BusSizeECC(BusSizeECC),
				.TagSizeECC(TagSizeECC),
				.LineSizeECC(LineSizeECC),
				.BranchPredictor(BranchPredictor),
				.DbgTriggerEn(DbgTriggerEn),
				.DbgHwBreakNum(DbgHwBreakNum),
				.WritebackStage(WritebackStage),
				.SecureIbex(SecureIbex),
				.DummyInstructions(DummyInstructions),
				.RegFileECC(RegFileECC),
				.RegFileDataWidth(RegFileDataWidth),
				.DmHaltAddr(DmHaltAddr),
				.DmExceptionAddr(DmExceptionAddr)
			) u_ibex_lockstep(
				.clk_i(clk),
				.rst_ni(rst_ni),
				.hart_id_i(hart_id_local),
				.boot_addr_i(boot_addr_local),
				.instr_req_i(instr_req_local),
				.instr_gnt_i(instr_gnt_local),
				.instr_rvalid_i(instr_rvalid_local),
				.instr_addr_i(instr_addr_local),
				.instr_rdata_i(instr_rdata_local),
				.instr_err_i(instr_err_local),
				.data_req_i(data_req_local),
				.data_gnt_i(data_gnt_local),
				.data_rvalid_i(data_rvalid_local),
				.data_we_i(data_we_local),
				.data_be_i(data_be_local),
				.data_addr_i(data_addr_local),
				.data_wdata_i(data_wdata_local),
				.data_rdata_i(data_rdata_local),
				.data_err_i(data_err_local),
				.dummy_instr_id_i(dummy_instr_id_local),
				.rf_raddr_a_i(rf_raddr_a_local),
				.rf_raddr_b_i(rf_raddr_b_local),
				.rf_waddr_wb_i(rf_waddr_wb_local),
				.rf_we_wb_i(rf_we_wb_local),
				.rf_wdata_wb_ecc_i(rf_wdata_wb_ecc_local),
				.rf_rdata_a_ecc_i(rf_rdata_a_ecc_local),
				.rf_rdata_b_ecc_i(rf_rdata_b_ecc_local),
				.ic_tag_req_i(ic_tag_req_local),
				.ic_tag_write_i(ic_tag_write_local),
				.ic_tag_addr_i(ic_tag_addr_local),
				.ic_tag_wdata_i(ic_tag_wdata_local),
				.ic_tag_rdata_i(ic_tag_rdata_local),
				.ic_data_req_i(ic_data_req_local),
				.ic_data_write_i(ic_data_write_local),
				.ic_data_addr_i(ic_data_addr_local),
				.ic_data_wdata_i(ic_data_wdata_local),
				.ic_data_rdata_i(ic_data_rdata_local),
				.irq_software_i(irq_software_local),
				.irq_timer_i(irq_timer_local),
				.irq_external_i(irq_external_local),
				.irq_fast_i(irq_fast_local),
				.irq_nm_i(irq_nm_local),
				.irq_pending_i(irq_pending_local),
				.debug_req_i(debug_req_local),
				.crash_dump_i(crash_dump_local),
				.fetch_enable_i(fetch_enable_local),
				.alert_minor_o(lockstep_alert_minor_local),
				.alert_major_o(lockstep_alert_major_local),
				.core_busy_i(core_busy_local),
				.test_en_i(test_en_i),
				.scan_rst_ni(scan_rst_ni)
			);
			prim_buf u_prim_buf_alert_minor(
				.in_i(lockstep_alert_minor_local),
				.out_o(lockstep_alert_minor)
			);
			prim_buf u_prim_buf_alert_major(
				.in_i(lockstep_alert_major_local),
				.out_o(lockstep_alert_major)
			);
		end
		else begin : gen_no_lockstep
			assign lockstep_alert_major = 1'b0;
			assign lockstep_alert_minor = 1'b0;
			wire unused_scan;
			assign unused_scan = scan_rst_ni;
		end
	endgenerate
	wire unused_lockstep_alert_major;
	assign unused_lockstep_alert_major = lockstep_alert_major;
	assign alert_major_o = core_alert_major;
	assign alert_minor_o = core_alert_minor | lockstep_alert_minor;
endmodule
