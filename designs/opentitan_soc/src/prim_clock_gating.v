module prim_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	reg en_latch;
	always @(*)
		if (!clk_i)
			en_latch = en_i | test_en_i;
	assign clk_o = en_latch & clk_i;
endmodule
