module register_file (
	clk_i,
	rst_ni,
	read1_i,
	read2_i,
	wr_reg_i,
	wr_data_i,
	wr_en_i,
	data1_ao,
	data2_a0
);
	input clk_i;
	input rst_ni;
	input [4:0] read1_i;
	input [4:0] read2_i;
	input [4:0] wr_reg_i;
	input [31:0] wr_data_i;
	input wr_en_i;
	output reg [31:0] data1_ao;
	output reg [31:0] data2_a0;
	reg [31:0] RF [31:0];
	always @(*)
		if (read1_i == 0)
			data1_ao = 0;
		else
			data1_ao = RF[read1_i];
	always @(*)
		if (read2_i == 0)
			data2_a0 = 0;
		else
			data2_a0 = RF[read2_i];
	always @(negedge clk_i) begin : sv2v_autoblock_1
		reg signed [31:0] i;
		if (~rst_ni) begin
			for (i = 0; i < 32; i = i + 1)
				RF[i] <= 'hdeadbeef;
		end
		else if (wr_en_i && (wr_reg_i != 0))
			RF[wr_reg_i] <= wr_data_i;
	end
endmodule
