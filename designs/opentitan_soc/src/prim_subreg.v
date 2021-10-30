module prim_subreg (
	clk_i,
	rst_ni,
	we,
	wd,
	de,
	d,
	qe,
	q,
	qs
);
	parameter signed [31:0] DW = 32;
	parameter SWACCESS = "RW";
	parameter [DW - 1:0] RESVAL = 1'sb0;
	input clk_i;
	input rst_ni;
	input we;
	input [DW - 1:0] wd;
	input de;
	input [DW - 1:0] d;
	output reg qe;
	output reg [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	wire wr_en;
	wire [DW - 1:0] wr_data;
	prim_subreg_arb #(
		.DW(DW),
		.SWACCESS(SWACCESS)
	) wr_en_data_arb(
		.we(we),
		.wd(wd),
		.de(de),
		.d(d),
		.q(q),
		.wr_en(wr_en),
		.wr_data(wr_data)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			qe <= 1'b0;
		else
			qe <= we;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			q <= RESVAL;
		else if (wr_en)
			q <= wr_data;
	assign qs = q;
endmodule
