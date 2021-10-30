module prim_subreg_arb (
	we,
	wd,
	de,
	d,
	q,
	wr_en,
	wr_data
);
	parameter signed [31:0] DW = 32;
	parameter SWACCESS = "RW";
	input we;
	input [DW - 1:0] wd;
	input de;
	input [DW - 1:0] d;
	input [DW - 1:0] q;
	output wire wr_en;
	output wire [DW - 1:0] wr_data;
	generate
		if ((SWACCESS == "RW") || (SWACCESS == "WO")) begin : gen_w
			assign wr_en = we | de;
			assign wr_data = (we == 1'b1 ? wd : d);
			wire [DW - 1:0] unused_q;
			assign unused_q = q;
		end
		else if (SWACCESS == "RO") begin : gen_ro
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
		else if (SWACCESS == "W1S") begin : gen_w1s
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) | (we ? wd : {DW {1'sb0}});
		end
		else if (SWACCESS == "W1C") begin : gen_w1c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? ~wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "W0C") begin : gen_w0c
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? wd : {DW {1'sb1}});
		end
		else if (SWACCESS == "RC") begin : gen_rc
			assign wr_en = we | de;
			assign wr_data = (de ? d : q) & (we ? {DW {1'sb0}} : {DW {1'sb1}});
			wire [DW - 1:0] unused_wd;
			assign unused_wd = wd;
		end
		else begin : gen_hw
			assign wr_en = de;
			assign wr_data = d;
			wire unused_we;
			wire [DW - 1:0] unused_wd;
			wire [DW - 1:0] unused_q;
			assign unused_we = we;
			assign unused_wd = wd;
			assign unused_q = q;
		end
	endgenerate
endmodule
