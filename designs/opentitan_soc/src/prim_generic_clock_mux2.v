module prim_generic_clock_mux2 (
	clk0_i,
	clk1_i,
	sel_i,
	clk_o
);
	parameter [0:0] NoFpgaBufG = 1'b0;
	input clk0_i;
	input clk1_i;
	input sel_i;
	output wire clk_o;
	assign clk_o = (sel_i ? clk1_i : clk0_i);
endmodule
