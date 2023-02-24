module OTTER_CU_Decoder (
	CU_OPCODE,
	CU_FUNC3,
	CU_FUNC7,
	CU_BR_EQ,
	CU_BR_LT,
	CU_BR_LTU,
	CU_ALU_SRCA,
	CU_ALU_SRCB,
	CU_ALU_FUN,
	CU_RF_WR_SEL
);
	input [6:0] CU_OPCODE;
	input [2:0] CU_FUNC3;
	input [6:0] CU_FUNC7;
	input CU_BR_EQ;
	input CU_BR_LT;
	input CU_BR_LTU;
	output wire CU_ALU_SRCA;
	output reg [1:0] CU_ALU_SRCB;
	output reg [3:0] CU_ALU_FUN;
	output reg [1:0] CU_RF_WR_SEL;
	wire [6:0] OPCODE;
	assign OPCODE = CU_OPCODE;
	reg brn_cond;
	always @(*)
		case (CU_OPCODE)
			7'b0010011: CU_ALU_FUN = (CU_FUNC3 == 3'b101 ? {CU_FUNC7[5], CU_FUNC3} : {1'b0, CU_FUNC3});
			7'b0110111, 7'b1110011: CU_ALU_FUN = 4'b1001;
			7'b0110011: CU_ALU_FUN = {CU_FUNC7[5], CU_FUNC3};
			default: CU_ALU_FUN = 4'b0000;
		endcase
	always @(*)
		case (CU_FUNC3)
			3'b000: brn_cond = CU_BR_EQ;
			3'b001: brn_cond = ~CU_BR_EQ;
			3'b100: brn_cond = CU_BR_LT;
			3'b101: brn_cond = ~CU_BR_LT;
			3'b110: brn_cond = CU_BR_LTU;
			3'b111: brn_cond = ~CU_BR_LTU;
			default: brn_cond = 0;
		endcase
	always @(*)
		case (CU_OPCODE)
			7'b1101111: CU_RF_WR_SEL = 0;
			7'b1100111: CU_RF_WR_SEL = 0;
			7'b0000011: CU_RF_WR_SEL = 2;
			7'b1110011: CU_RF_WR_SEL = 1;
			default: CU_RF_WR_SEL = 3;
		endcase
	always @(*)
		case (CU_OPCODE)
			7'b0100011: CU_ALU_SRCB = 2;
			7'b0000011: CU_ALU_SRCB = 1;
			7'b1101111: CU_ALU_SRCB = 1;
			7'b0010011: CU_ALU_SRCB = 1;
			7'b0010111: CU_ALU_SRCB = 3;
			default: CU_ALU_SRCB = 0;
		endcase
	assign CU_ALU_SRCA = ((CU_OPCODE == 7'b0110111) || (CU_OPCODE == 7'b0010111) ? 1 : 0);
endmodule
