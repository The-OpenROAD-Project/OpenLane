module prog_cntr (
	clk_i,
	rst_ni,
	ld_i,
	data_i,
	count_o
);
	input clk_i;
	input rst_ni;
	input ld_i;
	input [31:0] data_i;
	output reg [31:0] count_o;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			count_o <= 1'sb0;
		else if (ld_i)
			count_o <= data_i;
endmodule
