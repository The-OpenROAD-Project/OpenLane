module core (
	clk_i,
	rst_ni,
	imem_gnt_i,
	imem_rd_o,
	imem_addr_o,
	inst_i,
	rf_port1_reg_o,
	rf_port2_reg_o,
	rf_wr_en_o,
	rf_wr_reg_o,
	rf_wr_data_o,
	rf_rs1_i,
	rf_rs2_i,
	dmem_rd_o,
	dmem_wr_o,
	dmem_strobe_o,
	dmem_addr_o,
	dmem_wdata_o,
	dmem_rdata_i,
	dmem_rdata_valid_i,
	dmem_ready_i
);
	input clk_i;
	input rst_ni;
	input wire imem_gnt_i;
	output wire imem_rd_o;
	output wire [31:0] imem_addr_o;
	input wire [31:0] inst_i;
	output wire [4:0] rf_port1_reg_o;
	output wire [4:0] rf_port2_reg_o;
	output wire rf_wr_en_o;
	output wire [4:0] rf_wr_reg_o;
	output wire [31:0] rf_wr_data_o;
	input [31:0] rf_rs1_i;
	input [31:0] rf_rs2_i;
	output wire dmem_rd_o;
	output wire dmem_wr_o;
	output wire [3:0] dmem_strobe_o;
	output wire [31:0] dmem_addr_o;
	output wire [31:0] dmem_wdata_o;
	input wire [31:0] dmem_rdata_i;
	input wire dmem_rdata_valid_i;
	input wire dmem_ready_i;
	wire [63:0] fetch_state;
	wire [243:0] decode_state;
	wire [70:0] exec_state;
	wire [102:0] mem_state;
	wire [1:0] fetch_ctrl;
	wire [1:0] decode_ctrl;
	wire [1:0] exec_ctrl;
	wire [1:0] mem_ctrl;
	wire [1:0] wb_ctrl;
	wire [81:0] decode_reg_meta;
	wire [81:0] decode_reg_meta_updated;
	wire [81:0] exec_reg_meta;
	wire [81:0] mem_reg_meta;
	wire fetch_valid;
	wire decode_valid;
	wire exec_valid;
	wire mem_valid;
	wire mem_acc_stall;
	wire mem_read_stall;
	wire load_use_stall;
	wire [39:0] exec_fwd_data;
	wire [39:0] wb_fwd_data;
	wire pc_target_sel;
	wire [31:0] pc_target_addr;
	fetch_stage i_fetch_stage(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.target_sel_i(pc_target_sel),
		.target_addr_i(pc_target_addr),
		.stage_ctrl_i(fetch_ctrl),
		.mem_rd_o(imem_rd_o),
		.mem_gnt_i(imem_gnt_i),
		.mem_addr_o(imem_addr_o),
		.valid_o(fetch_valid),
		.fetch_state_o(fetch_state)
	);
	decode_stage i_decode_stage(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(fetch_valid),
		.fetch_state_i(fetch_state),
		.inst_i(inst_i),
		.stage_ctrl_i(decode_ctrl),
		.rf_port1_reg_o(rf_port1_reg_o),
		.rf_port2_reg_o(rf_port2_reg_o),
		.rf_rs1_i(rf_rs1_i),
		.rf_rs2_i(rf_rs2_i),
		.valid_o(decode_valid),
		.decode_state_o(decode_state),
		.reg_meta_o(decode_reg_meta)
	);
	exec_stage i_exec_stage(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(decode_valid),
		.decode_state_i(decode_state),
		.reg_meta_i(decode_reg_meta_updated),
		.stage_ctrl_i(exec_ctrl),
		.data_fwd_o(exec_fwd_data),
		.mem_acc_stall_ao(mem_acc_stall),
		.target_sel_o(pc_target_sel),
		.target_addr_o(pc_target_addr),
		.valid_o(exec_valid),
		.exec_state_o(exec_state),
		.reg_meta_o(exec_reg_meta),
		.mem_ready_i(dmem_ready_i),
		.mem_read_ao(dmem_rd_o),
		.mem_write_ao(dmem_wr_o),
		.mem_strb_ao(dmem_strobe_o),
		.mem_addr_ao(dmem_addr_o),
		.mem_data_ao(dmem_wdata_o)
	);
	mem_slice_stage i_mem_slice_stage(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(exec_valid),
		.exec_state_i(exec_state),
		.reg_meta_i(exec_reg_meta),
		.stage_ctrl_i(mem_ctrl),
		.mem_req_complete_i(dmem_rdata_valid_i),
		.dmem_rdata_i(dmem_rdata_i),
		.valid_o(mem_valid),
		.mem_state_o(mem_state),
		.reg_meta_o(mem_reg_meta),
		.mem_readwait_oa(mem_read_stall)
	);
	wb_stage i_wb_stage(
		.valid_i(mem_valid),
		.mem_state_i(mem_state),
		.reg_meta_i(mem_reg_meta),
		.stage_ctrl_i(wb_ctrl),
		.data_fwd_oa(wb_fwd_data),
		.rf_wr_en_oa(rf_wr_en_o),
		.rf_wr_reg_oa(rf_wr_reg_o),
		.rf_wr_data_oa(rf_wr_data_o)
	);
	fwd_unit #(.N_STAGES(2)) i_fwd_unit(
		.data_fwd_i({exec_fwd_data, wb_fwd_data}),
		.dest_meta_i(decode_reg_meta),
		.load_use_stall_ao(load_use_stall),
		.dest_meta_o(decode_reg_meta_updated)
	);
	hazard_unit #(
		.DEPTH(5),
		.BC_STAGE(2),
		.EX_STAGE(2)
	) i_hazard_unit(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.mem_acc_stall_i(mem_acc_stall),
		.mem_read_stall_i(mem_read_stall),
		.pc_src_i(pc_target_sel),
		.csr_mret_i(1'sb0),
		.csr_flush_i(1'sb0),
		.load_use_stall_i(load_use_stall),
		.stage_ctrl_ao({wb_ctrl, mem_ctrl, exec_ctrl, decode_ctrl, fetch_ctrl})
	);
endmodule
