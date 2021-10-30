module prim_generic_flop_2sync (
	clk_i,
	rst_ni,
	d_i,
	q_o
);
	parameter signed [31:0] Width = 16;
	localparam signed [31:0] WidthSubOne = Width - 1;
	parameter [WidthSubOne:0] ResetValue = 1'sb0;
	input clk_i;
	input rst_ni;
	input [Width - 1:0] d_i;
	output wire [Width - 1:0] q_o;
	wire [Width - 1:0] intq;
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(d_i),
		.q_o(intq)
	);
	prim_generic_flop #(
		.Width(Width),
		.ResetValue(ResetValue)
	) u_sync_2(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.d_i(intq),
		.q_o(q_o)
	);
endmodule
