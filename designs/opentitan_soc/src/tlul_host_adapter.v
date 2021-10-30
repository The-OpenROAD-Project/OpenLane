module tlul_host_adapter (
	clk_i,
	rst_ni,
	req_i,
	gnt_o,
	addr_i,
	we_i,
	wdata_i,
	be_i,
	valid_o,
	rdata_o,
	err_o,
	tl_h_c_a,
	tl_h_c_d
);
	parameter [31:0] MAX_REQS = 1;
	input clk_i;
	input rst_ni;
	input req_i;
	output wire gnt_o;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	input wire [31:0] addr_i;
	input wire we_i;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	input wire [31:0] wdata_i;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	input wire [3:0] be_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire err_o;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	output wire [85:0] tl_h_c_a;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	input wire [51:0] tl_h_c_d;
	localparam signed [31:0] WordSize = 2;
	wire [7:0] tl_source;
	wire [3:0] tl_be;
	generate
		if (MAX_REQS == 1) begin
			assign tl_source = {8 {1'sb0}};
		end
		else begin
			localparam signed [31:0] ReqNumW = $clog2(MAX_REQS);
			reg [ReqNumW - 1:0] source_d;
			reg [ReqNumW - 1:0] source_q;
			always @(posedge clk_i)
				if (!rst_ni)
					source_q <= {ReqNumW {1'sb0}};
				else
					source_q <= source_d;
			always @(*) begin
				source_d = source_q;
				if (req_i && gnt_o)
					if (source_q == (MAX_REQS - 1))
						source_d = {ReqNumW {1'sb0}};
					else
						source_d = source_q + 1;
			end
			function automatic [7:0] sv2v_cast_8;
				input reg [7:0] inp;
				sv2v_cast_8 = inp;
			endfunction
			assign tl_source = sv2v_cast_8(source_q);
		end
	endgenerate
	assign tl_be = (~we_i ? {tlul_pkg_TL_DBW {1'b1}} : be_i);
	localparam [2:0] tlul_pkg_Get = 3'h4;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	function automatic signed [1:0] sv2v_cast_6CB2A_signed;
		input reg signed [1:0] inp;
		sv2v_cast_6CB2A_signed = inp;
	endfunction
	function automatic [1:0] sv2v_cast_C1DF5;
		input reg [1:0] inp;
		sv2v_cast_C1DF5 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_FABF2;
		input reg [31:0] inp;
		sv2v_cast_FABF2 = inp;
	endfunction
	assign tl_h_c_a = {req_i, (~we_i ? tlul_pkg_Get : (&be_i ? tlul_pkg_PutFullData : tlul_pkg_PutPartialData)), 3'h0, sv2v_cast_C1DF5(sv2v_cast_6CB2A_signed(WordSize)), tl_source, sv2v_cast_FABF2({addr_i[31:WordSize], {WordSize {1'b0}}}), tl_be, wdata_i, 1'b1};
	assign gnt_o = tl_h_c_d[0];
	assign err_o = tl_h_c_d[1];
	assign valid_o = tl_h_c_d[51];
	wire [31:0] rddata;
	assign rddata = tl_h_c_d[33-:tlul_pkg_TL_DW];
	assign rdata_o = rddata;
endmodule
