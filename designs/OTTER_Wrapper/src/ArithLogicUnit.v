module OTTER_ALU (
	ALU_fun,
	A,
	B,
	ALUOut
);
	input [3:0] ALU_fun;
	input [31:0] A;
	input [31:0] B;
	output reg [31:0] ALUOut;
	always @(*)
		case (ALU_fun)
			0: ALUOut = A + B;
			8: ALUOut = A - B;
			6: ALUOut = A | B;
			7: ALUOut = A & B;
			4: ALUOut = A ^ B;
			5: ALUOut = A >> B[4:0];
			1: ALUOut = A << B[4:0];
			13: ALUOut = $signed(A) >>> B[4:0];
			2: ALUOut = ($signed(A) < $signed(B) ? 1 : 0);
			3: ALUOut = (A < B ? 1 : 0);
			9: ALUOut = A;
			10: ALUOut = A * B;
			default: ALUOut = 0;
		endcase
endmodule
