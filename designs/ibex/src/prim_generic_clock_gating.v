module prim_generic_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input clk_i;
	input en_i;
	input test_en_i;
	output wire clk_o;
	reg en_latch;
	always @(*)
		if (!clk_i)
			en_latch = en_i | test_en_i;
	assign clk_o = en_latch & clk_i;
endmodule
