module ProgCount (
	PC_CLK,
	PC_RST,
	PC_LD,
	PC_DIN,
	PC_COUNT
);
	input PC_CLK;
	input PC_RST;
	input PC_LD;
	input wire [31:0] PC_DIN;
	output reg [31:0] PC_COUNT = 0;
	always @(posedge PC_CLK)
		if (PC_RST == 1'b1)
			PC_COUNT <= 1'sb0;
		else if (PC_LD == 1'b1)
			PC_COUNT <= PC_DIN;
endmodule
