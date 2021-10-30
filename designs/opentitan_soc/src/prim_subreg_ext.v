module prim_subreg_ext (
	re,
	we,
	wd,
	d,
	qe,
	qre,
	q,
	qs
);
	parameter [31:0] DW = 32;
	input re;
	input we;
	input [DW - 1:0] wd;
	input [DW - 1:0] d;
	output wire qe;
	output wire qre;
	output wire [DW - 1:0] q;
	output wire [DW - 1:0] qs;
	assign qs = d;
	assign q = wd;
	assign qe = we;
	assign qre = re;
endmodule
