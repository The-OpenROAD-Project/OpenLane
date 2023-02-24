module OTTER_registerFile (
	Read1,
	Read2,
	WriteReg,
	WriteData,
	RegWrite,
	Data1,
	Data2,
	clock
);
	input [4:0] Read1;
	input [4:0] Read2;
	input [4:0] WriteReg;
	input [31:0] WriteData;
	input RegWrite;
	input clock;
	output reg [31:0] Data1;
	output reg [31:0] Data2;
	reg [31:0] RF [31:0];
	always @(*)
		if (Read1 == 0)
			Data1 = 0;
		else
			Data1 = RF[Read1];
	always @(*)
		if (Read2 == 0)
			Data2 = 0;
		else
			Data2 = RF[Read2];
	always @(negedge clock)
		if (RegWrite && (WriteReg != 0))
			RF[WriteReg] <= WriteData;
endmodule
