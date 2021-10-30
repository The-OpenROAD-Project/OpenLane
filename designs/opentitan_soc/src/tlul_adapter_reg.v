module tlul_adapter_reg (
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
	error_i
);
	parameter signed [31:0] RegAw = 8;
	parameter signed [31:0] RegDw = 32;
	localparam signed [31:0] RegBw = RegDw / 8;
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
	assign a_ack = tl_i[85] & tl_o[0];
	assign d_ack = tl_o[51] & tl_i[0];
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	assign wr_req = a_ack & ((tl_i[84-:3] == tlul_pkg_PutFullData) | (tl_i[84-:3] == tlul_pkg_PutPartialData));
	localparam [2:0] tlul_pkg_Get = 3'h4;
	assign rd_req = a_ack & (tl_i[84-:3] == tlul_pkg_Get);
	assign we_o = wr_req & ~err_internal;
	assign re_o = rd_req & ~err_internal;
	assign addr_o = {tl_i[36 + RegAw:39], 2'b00};
	assign wdata_o = tl_i[tlul_pkg_TL_DW-:tlul_pkg_TL_DW];
	assign be_o = tl_i[36-:4];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			outstanding <= 1'b0;
		else if (a_ack)
			outstanding <= 1'b1;
		else if (d_ack)
			outstanding <= 1'b0;
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
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			rdata <= {RegDw {1'sb0}};
			error <= 1'b0;
		end
		else if (a_ack) begin
			rdata <= (err_internal ? {RegDw {1'sb1}} : rdata_i);
			error <= error_i | err_internal;
		end
	function automatic [1:0] sv2v_cast_87F6B;
		input reg [1:0] inp;
		sv2v_cast_87F6B = inp;
	endfunction
	function automatic [7:0] sv2v_cast_89DD5;
		input reg [7:0] inp;
		sv2v_cast_89DD5 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_4D96F;
		input reg [0:0] inp;
		sv2v_cast_4D96F = inp;
	endfunction
	function automatic [31:0] sv2v_cast_F21A2;
		input reg [31:0] inp;
		sv2v_cast_F21A2 = inp;
	endfunction
	assign tl_o = {outstanding, rspop, 3'b000, sv2v_cast_87F6B(reqsz), sv2v_cast_89DD5(reqid), sv2v_cast_4D96F(1'sb0), sv2v_cast_F21A2(rdata), error, ~outstanding};
	assign err_internal = addr_align_err | tl_err;
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
