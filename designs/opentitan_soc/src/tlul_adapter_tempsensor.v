module tlul_adapter_tempsensor (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	re_o,
	we_o,
	addr_o,
	wdata_o,
	be_o,
	rdata_i,
	error_i,
	CLK_REF,
	CLK_OUT
);
	parameter [0:0] EnableDataIntgGen = 1'b0;
	parameter signed [31:0] RegAw = 12;
	parameter signed [31:0] RegDw = 32;
	localparam signed [31:0] RegBw = RegDw / 8;
	parameter signed [31:0] DataIntgWidth = 7;
	parameter signed [31:0] DataMaxWidth = 57;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	output wire re_o;
	output wire we_o;
	output wire [RegAw - 1:0] addr_o;
	output wire [RegDw - 1:0] wdata_o;
	output wire [RegBw - 1:0] be_o;
	input [RegDw - 1:0] rdata_i;
	input error_i;
	input CLK_REF;
	output reg CLK_OUT;
	localparam signed [31:0] IW = 8;
	localparam signed [31:0] SZW = 2;
	reg outstanding;
	wire a_ack;
	wire d_ack;
	reg [RegDw - 1:0] rdata;
	reg error;
	wire err_internal;
	reg addr_align_err;
	wire tl_err;
	reg [7:0] reqid;
	reg [1:0] reqsz;
	reg [2:0] rspop;
	wire rd_req;
	wire wr_req;
	reg RESET_REGn;
	reg [3:0] SEL_CONV_TIME_REG;
	reg en_REG;
	reg [23:0] DOUT_REG1;
	reg DONE_REG1;
	reg [23:0] DOUT_REG2;
	reg DONE_REG2;
	reg [23:0] DOUT_REG3;
	reg DONE_REG3;
	reg [23:0] DOUT_REG4;
	reg DONE_REG4;
	reg [1:0] CLK_SEL_REG;
	wire [23:0] DOUT1;
	wire DONE1;
	wire [23:0] DOUT2;
	wire DONE2;
	wire [23:0] DOUT3;
	wire DONE3;
	wire [23:0] DOUT4;
	wire DONE4;
	wire CLK_LC1;
	wire CLK_LC2;
	wire CLK_LC3;
	wire CLK_LC4;
	assign a_ack = tl_i[85] & tl_o[0];
	assign d_ack = tl_o[51] & tl_i[0];
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	assign wr_req = a_ack & ((tl_i[84-:3] == tlul_pkg_PutFullData) | (tl_i[84-:3] == tlul_pkg_PutPartialData));
	localparam [2:0] tlul_pkg_Get = 3'h4;
	assign rd_req = a_ack & (tl_i[84-:3] == tlul_pkg_Get);
	assign we_o = wr_req & ~err_internal;
	assign re_o = rd_req & ~err_internal;
	assign wdata_o = tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
	assign be_o = tl_i[36-:4];
	generate
		if (RegAw <= 2) begin : gen_only_one_reg
			assign addr_o = {RegAw {1'sb0}};
		end
		else begin : gen_more_regs
			assign addr_o = {tl_i[36 + RegAw:39], 2'b00};
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			RESET_REGn <= 1'b1;
			SEL_CONV_TIME_REG <= 4'b0000;
			en_REG <= 1'b0;
			CLK_SEL_REG <= 1'b0;
		end
		else begin
			DOUT_REG1 <= DOUT1;
			DONE_REG1 <= DONE1;
			DOUT_REG2 <= DOUT2;
			DONE_REG2 <= DONE2;
			DOUT_REG3 <= DOUT3;
			DONE_REG3 <= DONE3;
			DOUT_REG4 <= DOUT4;
			DONE_REG4 <= DONE4;
			if (wr_req)
				case (addr_o)
					8'h04: RESET_REGn <= tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
					8'h08: SEL_CONV_TIME_REG <= tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
					8'h0c: en_REG <= tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
					8'h10: CLK_SEL_REG <= tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
				endcase
		end
	tempsenseInst_error_inv6_head9 u_tempsenseInst1(
		.CLK_REF(CLK_REF),
		.RESET_COUNTERn(RESET_REGn),
		.SEL_CONV_TIME(SEL_CONV_TIME_REG),
		.en(en_REG),
		.DOUT(DOUT1),
		.DONE(DONE1),
		.out(),
		.outb(),
		.lc_out(CLK_LC1)
	);
	tempsenseInst_error_inv8_head3 u_tempsenseInst2(
		.CLK_REF(CLK_REF),
		.RESET_COUNTERn(RESET_REGn),
		.SEL_CONV_TIME(SEL_CONV_TIME_REG),
		.en(en_REG),
		.DOUT(DOUT2),
		.DONE(DONE2),
		.out(),
		.outb(),
		.lc_out(CLK_LC2)
	);
	tempsenseInst_error_inv8_head5 u_tempsenseInst3(
		.CLK_REF(CLK_REF),
		.RESET_COUNTERn(RESET_REGn),
		.SEL_CONV_TIME(SEL_CONV_TIME_REG),
		.en(en_REG),
		.DOUT(DOUT3),
		.DONE(DONE3),
		.out(),
		.outb(),
		.lc_out(CLK_LC3)
	);
	tempsenseInst_error_inv8_head7 u_tempsenseInst4(
		.CLK_REF(CLK_REF),
		.RESET_COUNTERn(RESET_REGn),
		.SEL_CONV_TIME(SEL_CONV_TIME_REG),
		.en(en_REG),
		.DOUT(DOUT4),
		.DONE(DONE4),
		.out(),
		.outb(),
		.lc_out(CLK_LC4)
	);
	always @(*)
		case (CLK_SEL_REG)
			2'b00: CLK_OUT = CLK_LC1;
			2'b01: CLK_OUT = CLK_LC2;
			2'b10: CLK_OUT = CLK_LC3;
			2'b11: CLK_OUT = CLK_LC4;
		endcase
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			outstanding <= 1'b0;
		else if (a_ack)
			outstanding <= 1'b1;
		else if (d_ack)
			outstanding <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata <= {RegDw {1'sb0}};
			error <= 1'b0;
		end
		else begin
			error <= 1'b0;
			if (a_ack)
				case (addr_o)
					8'h04: rdata <= RESET_REGn;
					8'h08: rdata <= SEL_CONV_TIME_REG;
					8'h0c: rdata <= en_REG;
					8'h10: rdata <= DOUT_REG1;
					8'h14: rdata <= DONE_REG1;
					8'h18: rdata <= DOUT_REG2;
					8'h1c: rdata <= DONE_REG2;
					8'h20: rdata <= DOUT_REG3;
					8'h24: rdata <= DONE_REG3;
					8'h28: rdata <= DOUT_REG4;
					8'h2c: rdata <= DONE_REG4;
				endcase
		end
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			reqid <= {8 {1'sb0}};
			reqsz <= {2 {1'sb0}};
			rspop <= tlul_pkg_AccessAck;
		end
		else if (a_ack) begin
			reqid <= tl_i[76-:8];
			reqsz <= tl_i[78-:2];
			rspop <= (rd_req ? tlul_pkg_AccessAckData : tlul_pkg_AccessAck);
		end
	wire [DataIntgWidth - 1:0] data_intg;
	generate
		if (EnableDataIntgGen) begin : gen_data_intg
			wire [DataMaxWidth - 1:0] unused_data;
			function automatic [DataMaxWidth - 1:0] sv2v_cast_98604;
				input reg [DataMaxWidth - 1:0] inp;
				sv2v_cast_98604 = inp;
			endfunction
			prim_secded_64_57_enc u_data_gen(
				.in(sv2v_cast_98604(rdata)),
				.out({data_intg, unused_data})
			);
		end
		else begin : gen_tieoff_data_intg
			assign data_intg = {DataIntgWidth {1'sb0}};
		end
	endgenerate
	function automatic [1:0] sv2v_cast_D8E7C;
		input reg [1:0] inp;
		sv2v_cast_D8E7C = inp;
	endfunction
	function automatic [7:0] sv2v_cast_42655;
		input reg [7:0] inp;
		sv2v_cast_42655 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_618DC;
		input reg [0:0] inp;
		sv2v_cast_618DC = inp;
	endfunction
	function automatic [31:0] sv2v_cast_54652;
		input reg [31:0] inp;
		sv2v_cast_54652 = inp;
	endfunction
	assign tl_o = {outstanding, rspop, 3'b000, sv2v_cast_D8E7C(reqsz), sv2v_cast_42655(reqid), sv2v_cast_618DC(1'sb0), sv2v_cast_54652(rdata), error, ~outstanding};
	assign err_internal = 1'b0;
	always @(*)
		if (wr_req)
			addr_align_err = |tl_i[38:37];
		else
			addr_align_err = 1'b0;
	tlul_err u_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.err_o(tl_err)
	);
endmodule
module tempsenseInst_error_inv6_head9 (
	CLK_REF,
	RESET_COUNTERn,
	SEL_CONV_TIME,
	en,
	DOUT,
	DONE,
	out,
	outb,
	lc_out
);
	input CLK_REF;
	input RESET_COUNTERn;
	input [3:0] SEL_CONV_TIME;
	input en;
	output [23:0] DOUT;
	output DONE;
	output out;
	output outb;
	output lc_out;
	assign DONE = 1'b1;
	assign DOUT = {24 {1'sb1}};
	assign lc_out = 1'b0;
endmodule
module tempsenseInst_error_inv8_head3 (
	CLK_REF,
	RESET_COUNTERn,
	SEL_CONV_TIME,
	en,
	DOUT,
	DONE,
	out,
	outb,
	lc_out
);
	input CLK_REF;
	input RESET_COUNTERn;
	input [3:0] SEL_CONV_TIME;
	input en;
	output [23:0] DOUT;
	output DONE;
	output out;
	output outb;
	output lc_out;
	assign DONE = 1'b1;
	assign DOUT = {24 {1'sb0}};
	assign lc_out = 1'b1;
endmodule
module tempsenseInst_error_inv8_head5 (
	CLK_REF,
	RESET_COUNTERn,
	SEL_CONV_TIME,
	en,
	DOUT,
	DONE,
	out,
	outb,
	lc_out
);
	input CLK_REF;
	input RESET_COUNTERn;
	input [3:0] SEL_CONV_TIME;
	input en;
	output [23:0] DOUT;
	output DONE;
	output out;
	output outb;
	output lc_out;
	assign DONE = 1'b1;
	assign DOUT = {24 {1'sb1}};
	assign lc_out = 1'b0;
endmodule
module tempsenseInst_error_inv8_head7 (
	CLK_REF,
	RESET_COUNTERn,
	SEL_CONV_TIME,
	en,
	DOUT,
	DONE,
	out,
	outb,
	lc_out
);
	input CLK_REF;
	input RESET_COUNTERn;
	input [3:0] SEL_CONV_TIME;
	input en;
	output [23:0] DOUT;
	output DONE;
	output out;
	output outb;
	output lc_out;
	assign DONE = 1'b1;
	assign DOUT = {24 {1'sb0}};
	assign lc_out = 1'b1;
endmodule
