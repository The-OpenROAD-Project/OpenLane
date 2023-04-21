module mem_slice_stage (
	clk_i,
	rst_ni,
	valid_i,
	exec_state_i,
	reg_meta_i,
	stage_ctrl_i,
	mem_req_complete_i,
	dmem_rdata_i,
	valid_o,
	mem_state_o,
	reg_meta_o,
	mem_readwait_oa
);
	input clk_i;
	input rst_ni;
	input valid_i;
	input wire [70:0] exec_state_i;
	input wire [81:0] reg_meta_i;
	input wire [1:0] stage_ctrl_i;
	input mem_req_complete_i;
	input [31:0] dmem_rdata_i;
	output reg valid_o;
	output reg [102:0] mem_state_o;
	output reg [81:0] reg_meta_o;
	output wire mem_readwait_oa;
	wire [1:0] byte_offset;
	reg [31:0] pre_data;
	wire mem_read_active;
	reg sign;
	reg sign_ext;
	assign byte_offset = exec_state_i[8:7];
	assign mem_read_active = exec_state_i[3] && valid_i;
	assign mem_readwait_oa = mem_read_active && !mem_req_complete_i;
	wire [7:0] bytes [0:3];
	wire [15:0] halfs [0:1];
	assign bytes[0] = dmem_rdata_i[7:0];
	assign bytes[1] = dmem_rdata_i[15:8];
	assign bytes[2] = dmem_rdata_i[23:16];
	assign bytes[3] = dmem_rdata_i[31:24];
	assign halfs[0] = dmem_rdata_i[15:0];
	assign halfs[1] = dmem_rdata_i[31:16];
	always @(*) begin
		sign = exec_state_i[2] == 1'b0;
		sign_ext = 0;
		case (exec_state_i[1-:2])
			2'b00: begin
				sign_ext = sign && bytes[byte_offset][7];
				pre_data = {{24 {sign_ext}}, bytes[byte_offset]};
			end
			2'b01: begin
				sign_ext = sign && halfs[byte_offset[1]][15];
				pre_data = {{16 {sign_ext}}, halfs[byte_offset[1]]};
			end
			2'b10: pre_data = dmem_rdata_i;
			default: pre_data = 1'sb0;
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			valid_o <= 1'b0;
			mem_state_o <= 1'sb0;
			reg_meta_o <= 1'sb0;
		end
		else if (!stage_ctrl_i[0]) begin
			valid_o <= valid_i & ~stage_ctrl_i[1];
			mem_state_o[102-:32] <= exec_state_i[70-:32];
			mem_state_o[70-:32] <= exec_state_i[38-:32];
			mem_state_o[38] <= exec_state_i[6];
			mem_state_o[37-:2] <= exec_state_i[5-:2];
			mem_state_o[35] <= exec_state_i[3];
			mem_state_o[34] <= exec_state_i[2];
			mem_state_o[33-:2] <= exec_state_i[1-:2];
			mem_state_o[31-:32] <= pre_data;
			reg_meta_o[81] <= reg_meta_i[81];
			reg_meta_o[80-:5] <= reg_meta_i[80-:5];
			reg_meta_o[75-:32] <= reg_meta_i[75-:32];
			reg_meta_o[43] <= reg_meta_i[43];
			reg_meta_o[42-:5] <= reg_meta_i[42-:5];
			reg_meta_o[37-:32] <= reg_meta_i[37-:32];
			reg_meta_o[5] <= reg_meta_i[5];
			reg_meta_o[4-:5] <= reg_meta_i[4-:5];
		end
endmodule
