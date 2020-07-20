`timescale 1ns / 1ps

module K4N4_test_modes (
	clk,
	a,
	b,
	c,
	XOR,
	XNOR,
	AND,
	NAND,
	OR,
	NOR,
	XOR_sync,
	XNOR_sync,
	AND_sync,
	NAND_sync,
	OR_sync,
	NOR_sync );

	input  wire clk;
	input  wire a;
	input  wire b;
	input  wire c;
	output wire XOR;
	output wire XNOR;
	output wire AND;
	output wire NAND;
	output wire OR;
	output wire NOR;
	output reg  XOR_sync;
	output reg  XNOR_sync;
	output reg  AND_sync;
	output reg  NAND_sync;
	output reg  OR_sync;
	output reg  NOR_sync;

	assign XOR = a ^ b ^ c;
	assign XNOR = !XOR;
	assign OR = a || b || c;
	assign NOR = !( a || b || c);
	assign AND = a && b && c;
	assign NAND = !(a && b && c);

	always @(posedge clk) begin
		XOR_sync = XOR;
		XNOR_sync = XNOR;
		OR_sync = OR;
		NOR_sync = NOR;
		AND_sync = AND;
		NAND_sync = NAND;
	end

endmodule
