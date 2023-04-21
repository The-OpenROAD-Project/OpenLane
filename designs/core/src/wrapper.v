module wrapper (
	clk_i,
	rst_ni,
	imem_rd_o,
	imem_addr_o,
	inst_o,
	dmem_strobe_o,
	dmem_addr_o,
	dmem_wdata_o,
	dmem_rdata_o,
	rf_port1_reg_o,
	rf_port2_reg_o,
	rf_wr_reg_o,
	rf_wr_data_o,
	rf_wr_en_o,
	rf_rs1_o,
	rf_rs2_o
);
	input clk_i;
	input rst_ni;
	output wire imem_rd_o;
	output wire [31:0] imem_addr_o;
	output wire [31:0] inst_o;
	output wire [3:0] dmem_strobe_o;
	output wire [31:0] dmem_addr_o;
	output wire [31:0] dmem_wdata_o;
	output wire [31:0] dmem_rdata_o;
	output wire [4:0] rf_port1_reg_o;
	output wire [4:0] rf_port2_reg_o;
	output wire [4:0] rf_wr_reg_o;
	output wire [31:0] rf_wr_data_o;
	output wire rf_wr_en_o;
	output wire [31:0] rf_rs1_o;
	output wire [31:0] rf_rs2_o;
	wire imem_rd;
	wire [31:0] imem_addr;
	wire [31:0] inst;
	wire dmem_rd;
	wire dmem_wr;
	wire dmem_rdata_valid;
	wire dmem_ready;
	wire [3:0] dmem_strobe;
	wire [31:0] dmem_addr;
	wire [31:0] dmem_wdata;
	reg [31:0] dmem_rdata;
	wire [31:0] dmem_rdata_internal;
	reg [31:0] dmem_addr_last;
	wire [4:0] rf_port1_reg;
	wire [4:0] rf_port2_reg;
	wire [4:0] rf_wr_reg;
	wire [31:0] rf_rs1;
	wire [31:0] rf_rs2;
	wire [31:0] rf_wr_data;
	wire rf_wr_en;
	wire imem_gnt;
	assign imem_gnt = 1;
	core i_core(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.imem_gnt_i(imem_gnt),
		.imem_rd_o(imem_rd),
		.imem_addr_o(imem_addr),
		.inst_i(inst),
		.dmem_rd_o(dmem_rd),
		.dmem_wr_o(dmem_wr),
		.dmem_strobe_o(dmem_strobe),
		.dmem_addr_o(dmem_addr),
		.dmem_wdata_o(dmem_wdata),
		.dmem_rdata_i(dmem_rdata),
		.dmem_rdata_valid_i(1'sb1),
		.dmem_ready_i(1'sb1),
		.rf_port1_reg_o(rf_port1_reg),
		.rf_port2_reg_o(rf_port2_reg),
		.rf_wr_en_o(rf_wr_en),
		.rf_wr_reg_o(rf_wr_reg),
		.rf_wr_data_o(rf_wr_data),
		.rf_rs1_i(rf_rs1),
		.rf_rs2_i(rf_rs2)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dmem_addr_last <= 1'sb0;
		else
			dmem_addr_last <= dmem_addr;
	always @(*)
		if (dmem_addr_last >= 32'h00004000)
			dmem_rdata = 32'b00000000000000000000000000000000;
		else
			dmem_rdata = dmem_rdata_internal;
	localparam [0:0] sv2v_uu_i_memory_ext_pA_en_i_1 = 1'sb1;
	localparam sv2v_uu_i_memory_NUM_COL = 4;
	localparam [3:0] sv2v_uu_i_memory_ext_pB_strobe_i_0 = 1'sb0;
	localparam sv2v_uu_i_memory_COL_WIDTH = 8;
	localparam sv2v_uu_i_memory_DATA_WIDTH = 32;
	localparam [31:0] sv2v_uu_i_memory_ext_pB_data_i_0 = 1'sb0;
	test_memory #(
		.NUM_COL(4),
		.COL_WIDTH(8),
		.ADDR_WIDTH(12),
		.DATA_WIDTH(32)
	) i_memory(
		.clk_i(clk_i),
		.pA_en_i(sv2v_uu_i_memory_ext_pA_en_i_1),
		.pA_strobe_i(dmem_strobe),
		.pA_addr_i(dmem_addr[13:2]),
		.pA_data_i(dmem_wdata),
		.pA_data_o(dmem_rdata_internal),
		.pB_en_i(imem_rd),
		.pB_strobe_i(sv2v_uu_i_memory_ext_pB_strobe_i_0),
		.pB_addr_i(imem_addr[13:2]),
		.pB_data_i(sv2v_uu_i_memory_ext_pB_data_i_0),
		.pB_data_o(inst)
	);
	register_file i_reg_file(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.read1_i(rf_port1_reg),
		.read2_i(rf_port2_reg),
		.wr_reg_i(rf_wr_reg),
		.wr_data_i(rf_wr_data),
		.wr_en_i(rf_wr_en),
		.data1_ao(rf_rs1),
		.data2_a0(rf_rs2)
	);
	assign dmem_strobe_o = dmem_strobe;
	assign dmem_addr_o = dmem_addr;
	assign dmem_wdata_o = dmem_wdata;
	assign dmem_rdata_o = dmem_rdata;
	assign imem_rd_o = imem_rd;
	assign imem_addr_o = imem_addr;
	assign inst_o = inst;
	assign rf_port1_reg_o = rf_port1_reg;
	assign rf_port2_reg_o = rf_port2_reg;
	assign rf_wr_reg_o = rf_wr_reg;
	assign rf_wr_data_o = rf_wr_data;
	assign rf_wr_en_o = rf_wr_en;
	assign rf_rs1_o = rf_rs1;
	assign rf_rs2_o = rf_rs2;
endmodule
