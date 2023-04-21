module decoder (
	inst_i,
	pc_src_o,
	branch_op_o,
	alu_op_o,
	alu_a_src_o,
	alu_b_src_o,
	rs1_valid_o,
	rs2_valid_o,
	rd_valid_o,
	rf_wr_en_o,
	rf_wr_src_o,
	mem_write_o,
	mem_read_o,
	mem_sign_o,
	mem_width_o
);
	input [31:0] inst_i;
	output reg pc_src_o;
	output reg [2:0] branch_op_o;
	output reg [3:0] alu_op_o;
	output reg [1:0] alu_a_src_o;
	output reg [1:0] alu_b_src_o;
	output wire rs1_valid_o;
	output wire rs2_valid_o;
	output wire rd_valid_o;
	output wire rf_wr_en_o;
	output reg [1:0] rf_wr_src_o;
	output wire mem_write_o;
	output wire mem_read_o;
	output wire mem_sign_o;
	output wire [1:0] mem_width_o;
	wire [6:0] opcode;
	wire [2:0] func3;
	wire [6:0] func7;
	assign opcode = inst_i[6:0];
	assign func3 = inst_i[14:12];
	assign func7 = inst_i[31:25];
	always @(*)
		case (opcode)
			7'b1101111: pc_src_o = 1'd1;
			7'b1100111: pc_src_o = 1'd1;
			default: pc_src_o = 1'd0;
		endcase
	always @(*)
		case (opcode)
			7'b1100011: branch_op_o = func3;
			default: branch_op_o = 3'b010;
		endcase
	always @(*)
		case (opcode)
			7'b0010011:
				if (func3 == 'b101)
					alu_op_o = {func7[5], func3};
				else
					alu_op_o = {1'b0, func3};
			7'b0110011: alu_op_o = {func7[5], func3};
			7'b0110111: alu_op_o = 4'b1111;
			default: alu_op_o = 4'b0000;
		endcase
	always @(*)
		case (opcode)
			7'b0110111: alu_a_src_o = 2'd1;
			7'b0010111: alu_a_src_o = 2'd1;
			7'b1101111: alu_a_src_o = 2'd2;
			7'b1100011: alu_a_src_o = 2'd3;
			default: alu_a_src_o = 2'd0;
		endcase
	always @(*)
		case (opcode)
			7'b0010111: alu_b_src_o = 2'd3;
			7'b1101111: alu_b_src_o = 2'd3;
			7'b1100111: alu_b_src_o = 2'd1;
			7'b1100011: alu_b_src_o = 2'd3;
			7'b0000011: alu_b_src_o = 2'd1;
			7'b0100011: alu_b_src_o = 2'd2;
			7'b0010011: alu_b_src_o = 2'd1;
			default: alu_b_src_o = 2'd0;
		endcase
	assign rf_wr_en_o = (opcode != 7'b0100011) && (opcode != 7'b1100011);
	always @(*)
		case (opcode)
			7'b1101111: rf_wr_src_o = 2'd3;
			7'b1100111: rf_wr_src_o = 2'd3;
			7'b0000011: rf_wr_src_o = 2'd1;
			7'b1110011: rf_wr_src_o = 2'd2;
			default: rf_wr_src_o = 2'd0;
		endcase
	assign rs1_valid_o = ((opcode != 7'b0110111) && (opcode != 7'b0010111)) && (opcode != 7'b1101111);
	assign rs2_valid_o = ((opcode == 7'b1100011) || (opcode == 7'b0100011)) || (opcode == 7'b0110011);
	assign rd_valid_o = (opcode != 7'b1100011) && (opcode != 7'b0100011);
	assign mem_write_o = opcode == 7'b0100011;
	assign mem_read_o = opcode == 7'b0000011;
	assign mem_sign_o = func3[2];
	assign mem_width_o = func3[1:0];
	reg inst_unused = &{1'b0, inst_i[24:15], inst_i[11:7], 1'b0};
	reg func7_unused = &{1'b0, func7[6], func7[4:0], 1'b0};
endmodule
