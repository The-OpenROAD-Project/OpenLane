module prim_filter (
	clk_i,
	rst_ni,
	enable_i,
	filter_i,
	filter_o
);
	parameter signed [31:0] Cycles = 4;
	input clk_i;
	input rst_ni;
	input enable_i;
	input filter_i;
	output filter_o;
	reg [Cycles - 1:0] stored_vector_q;
	wire [Cycles - 1:0] stored_vector_d;
	reg stored_value_q;
	wire update_stored_value;
	wire unused_stored_vector_q_msb;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			stored_value_q <= 1'b0;
		else if (update_stored_value)
			stored_value_q <= filter_i;
	assign stored_vector_d = {stored_vector_q[Cycles - 2:0], filter_i};
	assign unused_stored_vector_q_msb = stored_vector_q[Cycles - 1];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			stored_vector_q <= {Cycles {1'b0}};
		else
			stored_vector_q <= stored_vector_d;
	assign update_stored_value = (stored_vector_d == {Cycles {1'b0}}) | (stored_vector_d == {Cycles {1'b1}});
	assign filter_o = (enable_i ? stored_value_q : filter_i);
endmodule
