module reg_file (
	clk_i,
	port1_reg_i,
	port1_data_o,
	port2_reg_i,
	port2_data_o,
	wr_en_i,
	wr_reg_i,
	wr_data_i
);
	input clk_i;
	input [4:0] port1_reg_i;
	output reg [31:0] port1_data_o;
	input [4:0] port2_reg_i;
	output reg [31:0] port2_data_o;
	input wr_en_i;
	input [4:0] wr_reg_i;
	input [31:0] wr_data_i;
	reg [31:0] rf [0:31];
	localparam [4:0] X0 = 1'sb0;
	always @(*)
		if (port1_reg_i == X0)
			port1_data_o = 1'sb0;
		else
			port1_data_o = rf[port1_reg_i];
	always @(*)
		if (port2_reg_i == X0)
			port2_data_o = 1'sb0;
		else
			port2_data_o = rf[port2_reg_i];
	always @(negedge clk_i)
		if (wr_en_i && (wr_reg_i != X0))
			rf[wr_reg_i] <= wr_data_i;
endmodule
