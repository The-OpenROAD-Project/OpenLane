module branch_gen (
	op_i,
	rs1_data_i,
	rs2_data_i,
	taken_o
);
	input wire [2:0] op_i;
	input [31:0] rs1_data_i;
	input [31:0] rs2_data_i;
	output reg taken_o;
	wire eq;
	wire lt;
	wire ltu;
	assign eq = rs1_data_i == rs2_data_i;
	assign lt = $signed(rs1_data_i) < $signed(rs2_data_i);
	assign ltu = rs1_data_i < rs2_data_i;
	always @(*)
		case (op_i)
			3'b000: taken_o = eq;
			3'b001: taken_o = ~eq;
			3'b100: taken_o = lt;
			3'b101: taken_o = ~lt;
			3'b110: taken_o = ltu;
			3'b111: taken_o = ~ltu;
			default: taken_o = 1'sb0;
		endcase
endmodule
