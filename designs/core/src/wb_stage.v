module wb_stage (
	valid_i,
	mem_state_i,
	reg_meta_i,
	stage_ctrl_i,
	data_fwd_oa,
	rf_wr_en_oa,
	rf_wr_reg_oa,
	rf_wr_data_oa
);
	input valid_i;
	input wire [102:0] mem_state_i;
	input wire [81:0] reg_meta_i;
	input wire [1:0] stage_ctrl_i;
	output wire [39:0] data_fwd_oa;
	output wire rf_wr_en_oa;
	output wire [4:0] rf_wr_reg_oa;
	output wire [31:0] rf_wr_data_oa;
	reg [31:0] rf_wr_data;
	always @(*) begin
		rf_wr_data = 1'sb0;
		case (mem_state_i[37-:2])
			2'd0: rf_wr_data = mem_state_i[70-:32];
			2'd1: rf_wr_data = mem_state_i[31-:32];
			2'd2: rf_wr_data = 1'sb0;
			2'd3: rf_wr_data = mem_state_i[102-:32];
			default: rf_wr_data = 1'sb0;
		endcase
	end
	assign data_fwd_oa[39] = mem_state_i[38];
	assign data_fwd_oa[38] = mem_state_i[35];
	assign data_fwd_oa[37-:5] = reg_meta_i[4-:5];
	assign data_fwd_oa[32-:32] = rf_wr_data;
	assign data_fwd_oa[0] = valid_i;
	assign rf_wr_reg_oa = reg_meta_i[4-:5];
	assign rf_wr_data_oa = rf_wr_data;
	assign rf_wr_en_oa = ((mem_state_i[38] && valid_i) && !stage_ctrl_i[1]) && !stage_ctrl_i[0];
endmodule
