module test_memory (
	clk_i,
	pA_en_i,
	pA_strobe_i,
	pA_addr_i,
	pA_data_i,
	pB_en_i,
	pB_strobe_i,
	pB_addr_i,
	pB_data_i,
	pA_data_o,
	pB_data_o
);
	parameter NUM_COL = 4;
	parameter COL_WIDTH = 8;
	parameter ADDR_WIDTH = 10;
	parameter DATA_WIDTH = NUM_COL * COL_WIDTH;
	input clk_i;
	input pA_en_i;
	input [NUM_COL - 1:0] pA_strobe_i;
	input [ADDR_WIDTH - 1:0] pA_addr_i;
	input [DATA_WIDTH - 1:0] pA_data_i;
	input pB_en_i;
	input [NUM_COL - 1:0] pB_strobe_i;
	input [ADDR_WIDTH - 1:0] pB_addr_i;
	input [DATA_WIDTH - 1:0] pB_data_i;
	output reg [DATA_WIDTH - 1:0] pA_data_o;
	output reg [DATA_WIDTH - 1:0] pB_data_o;
	(* rom_style = "{distributed | block}" *) (* ram_decomp = "power" *) reg [DATA_WIDTH - 1:0] ram_block [0:(2 ** ADDR_WIDTH) - 1];
	initial $readmemh("carp_memory.mem", ram_block, 0, (2 ** ADDR_WIDTH) - 1);
	integer i;
	always @(posedge clk_i)
		if (pA_en_i) begin
			for (i = 0; i < NUM_COL; i = i + 1)
				if (pA_strobe_i[i])
					ram_block[pA_addr_i][i * COL_WIDTH+:COL_WIDTH] <= pA_data_i[i * COL_WIDTH+:COL_WIDTH];
			pA_data_o <= ram_block[pA_addr_i];
		end
	always @(posedge clk_i)
		if (pB_en_i) begin
			for (i = 0; i < NUM_COL; i = i + 1)
				if (pB_strobe_i[i])
					ram_block[pB_addr_i][i * COL_WIDTH+:COL_WIDTH] <= pB_data_i[i * COL_WIDTH+:COL_WIDTH];
			pB_data_o <= ram_block[pB_addr_i];
		end
endmodule
