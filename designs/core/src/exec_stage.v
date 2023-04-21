module exec_stage (
	clk_i,
	rst_ni,
	valid_i,
	decode_state_i,
	reg_meta_i,
	stage_ctrl_i,
	data_fwd_o,
	mem_acc_stall_ao,
	target_sel_o,
	target_addr_o,
	valid_o,
	exec_state_o,
	reg_meta_o,
	mem_ready_i,
	mem_read_ao,
	mem_write_ao,
	mem_strb_ao,
	mem_addr_ao,
	mem_data_ao
);
	input clk_i;
	input rst_ni;
	input valid_i;
	input wire [243:0] decode_state_i;
	input wire [81:0] reg_meta_i;
	input wire [1:0] stage_ctrl_i;
	output reg [39:0] data_fwd_o;
	output wire mem_acc_stall_ao;
	output wire target_sel_o;
	output wire [31:0] target_addr_o;
	output reg valid_o;
	output reg [70:0] exec_state_o;
	output reg [81:0] reg_meta_o;
	input wire mem_ready_i;
	output wire mem_read_ao;
	output wire mem_write_ao;
	output wire [3:0] mem_strb_ao;
	output wire [31:0] mem_addr_ao;
	output wire [31:0] mem_data_ao;
	reg [31:0] alu_a_in;
	always @(*)
		case (decode_state_i[235-:2])
			2'd0: alu_a_in = reg_meta_i[75-:32];
			2'd1: alu_a_in = decode_state_i[135-:32];
			2'd2: alu_a_in = decode_state_i[103-:32];
			2'd3: alu_a_in = decode_state_i[167-:32];
			default: alu_a_in = reg_meta_i[75-:32];
		endcase
	reg [31:0] alu_b_in;
	always @(*)
		case (decode_state_i[233-:2])
			2'd0: alu_b_in = reg_meta_i[37-:32];
			2'd1: alu_b_in = decode_state_i[231-:32];
			2'd2: alu_b_in = decode_state_i[199-:32];
			2'd3: alu_b_in = decode_state_i[71-:32];
			default: alu_b_in = reg_meta_i[37-:32];
		endcase
	wire [31:0] alu_out;
	alu i_alu(
		.op_i(decode_state_i[239-:4]),
		.a_i(alu_a_in),
		.b_i(alu_b_in),
		.out_o(alu_out)
	);
	wire branch_taken;
	branch_gen i_branch_gen(
		.op_i(decode_state_i[242-:3]),
		.rs1_data_i(reg_meta_i[75-:32]),
		.rs2_data_i(reg_meta_i[37-:32]),
		.taken_o(branch_taken)
	);
	assign target_sel_o = (decode_state_i[243] | branch_taken) & valid_i;
	assign target_addr_o = alu_out;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_strb;
	wire mem_read;
	wire mem_write;
	wire mem_illegal;
	assign mem_read = ((decode_state_i[4] & ~stage_ctrl_i[1]) & ~stage_ctrl_i[0]) & valid_i;
	assign mem_write = ((decode_state_i[3] & ~stage_ctrl_i[1]) & ~stage_ctrl_i[0]) & valid_i;
	mem_prep i_mem_prep(
		.mem_width_i(decode_state_i[1-:2]),
		.mem_data_i(reg_meta_i[37-:32]),
		.mem_addr_i(alu_out),
		.mem_read_i(mem_read),
		.mem_write_i(mem_write),
		.mem_word_addr_ao(mem_addr),
		.mem_write_data_ao(mem_wdata),
		.mem_strobe_ao(mem_strb),
		.mem_illegal_ao(mem_illegal)
	);
	assign mem_read_ao = mem_read;
	assign mem_write_ao = mem_write;
	assign mem_strb_ao = mem_strb;
	assign mem_addr_ao = mem_addr;
	assign mem_data_ao = mem_wdata;
	assign mem_acc_stall_ao = !mem_ready_i;
	wire valid;
	assign valid = valid_i & ~stage_ctrl_i[1];
	//always @(posedge clk_i or negedge rst_ni) begin
	always @(posedge clk_i) begin
		if (!rst_ni) begin
			valid_o <= 1'sb0;
			exec_state_o <= 1'sb0;
			reg_meta_o <= 1'sb0;
		end
		else if (!stage_ctrl_i[0]) begin
			exec_state_o[38-:32] <= alu_out;
			exec_state_o[70-:32] <= decode_state_i[39-:32];
			exec_state_o[6] <= decode_state_i[7];
			exec_state_o[5-:2] <= decode_state_i[6-:2];
			exec_state_o[3] <= mem_read;
			exec_state_o[2] <= decode_state_i[2];
			exec_state_o[1-:2] <= decode_state_i[1-:2];
			reg_meta_o[81] <= reg_meta_i[81];
			reg_meta_o[80-:5] <= reg_meta_i[80-:5];
			reg_meta_o[75-:32] <= reg_meta_i[75-:32];
			reg_meta_o[43] <= reg_meta_i[43];
			reg_meta_o[42-:5] <= reg_meta_i[42-:5];
			reg_meta_o[37-:32] <= reg_meta_i[37-:32];
			reg_meta_o[5] <= reg_meta_i[5];
			reg_meta_o[4-:5] <= reg_meta_i[4-:5];
		end
		valid_o <= valid & ~stage_ctrl_i[1];
		data_fwd_o[39] <= decode_state_i[7];
		data_fwd_o[37-:5] <= reg_meta_i[4-:5];
		data_fwd_o[32-:32] <= alu_out;
		data_fwd_o[0] <= valid;
		data_fwd_o[38] <= mem_read;
	end
endmodule
