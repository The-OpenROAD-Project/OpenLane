module rv_plic_gateway (
	clk_i,
	rst_ni,
	src_i,
	le_i,
	claim_i,
	complete_i,
	ip_o
);
	parameter signed [31:0] N_SOURCE = 32;
	input clk_i;
	input rst_ni;
	input [N_SOURCE - 1:0] src_i;
	input [N_SOURCE - 1:0] le_i;
	input [N_SOURCE - 1:0] claim_i;
	input [N_SOURCE - 1:0] complete_i;
	output reg [N_SOURCE - 1:0] ip_o;
	reg [N_SOURCE - 1:0] ia;
	reg [N_SOURCE - 1:0] set;
	reg [N_SOURCE - 1:0] src_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			src_q <= {N_SOURCE {1'sb0}};
		else
			src_q <= src_i;
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] i;
		for (i = 0; i < N_SOURCE; i = i + 1)
			set[i] = (le_i[i] ? src_i[i] & ~src_q[i] : src_i[i]);
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ip_o <= {N_SOURCE {1'sb0}};
		else
			ip_o <= (ip_o | ((set & ~ia) & ~ip_o)) & ~(ip_o & claim_i);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ia <= {N_SOURCE {1'sb0}};
		else
			ia <= (ia | (set & ~ia)) & ~((ia & complete_i) & ~ip_o);
endmodule
