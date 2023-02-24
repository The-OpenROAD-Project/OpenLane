module OTTER_ALU (
	ALU_fun,
	P,
	B,
	ALUOut
);
	input [3:0] ALU_fun;
	input [31:0] P;
	input [31:0] B;
	output reg [31:0] ALUOut;
	always @(*)
		case (ALU_fun)
			0: ALUOut = P + B;
			8: ALUOut = P - B;
			6: ALUOut = P | B;
			7: ALUOut = P & B;
			4: ALUOut = P ^ B;
			5: ALUOut = P >> B[4:0];
			1: ALUOut = P << B[4:0];
			13: ALUOut = $signed(P) >>> B[4:0];
			2: ALUOut = ($signed(P) < $signed(B) ? 1 : 0);
			3: ALUOut = (P < B ? 1 : 0);
			9: ALUOut = P;
			10: ALUOut = P * B;
			default: ALUOut = 0;
		endcase
endmodule
