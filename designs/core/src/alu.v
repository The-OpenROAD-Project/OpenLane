module alu (
	op_i,
	a_i,
	b_i,
	out_o
);
	localparam signed [31:0] Width = 32;
	input wire [3:0] op_i;
	input [31:0] a_i;
	input [31:0] b_i;
	output reg [31:0] out_o;
	always @(*)
		case (op_i)
			4'b0000: out_o = a_i + b_i;
			4'b1000: out_o = a_i - b_i;
			4'b0110: out_o = a_i | b_i;
			4'b0111: out_o = a_i & b_i;
			4'b0100: out_o = a_i ^ b_i;
			4'b0101: out_o = a_i >> b_i[4:0];
			4'b0001: out_o = a_i << b_i[4:0];
			4'b1101: out_o = $signed(a_i) >>> b_i[4:0];
			4'b0010: out_o = ($signed(a_i) < $signed(b_i) ? 32'd1 : {32 {1'sb0}});
			4'b0011: out_o = (a_i < b_i ? 32'd1 : {32 {1'sb0}});
			4'b1111: out_o = a_i;
			default: out_o = 1'sb0;
		endcase
endmodule
