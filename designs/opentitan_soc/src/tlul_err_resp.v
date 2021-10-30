module tlul_err_resp (
	clk_i,
	rst_ni,
	tl_h_i,
	tl_h_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_h_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_h_o;
	reg [2:0] err_opcode;
	reg [7:0] err_source;
	reg [1:0] err_size;
	reg err_req_pending;
	reg err_rsp_pending;
	localparam [2:0] tlul_pkg_Get = 3'h4;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			err_req_pending <= 1'b0;
			err_source <= {tlul_pkg_TL_AIW {1'b0}};
			err_opcode <= tlul_pkg_Get;
			err_size <= {2 {1'sb0}};
		end
		else if (tl_h_i[85] && tl_h_o[0]) begin
			err_req_pending <= 1'b1;
			err_source <= tl_h_i[76-:8];
			err_opcode <= tl_h_i[84-:3];
			err_size <= tl_h_i[78-:2];
		end
		else if (!err_rsp_pending)
			err_req_pending <= 1'b0;
	assign tl_h_o[0] = ~err_rsp_pending & ~(err_req_pending & ~tl_h_i[0]);
	assign tl_h_o[51] = err_req_pending | err_rsp_pending;
	assign tl_h_o[33-:tlul_pkg_TL_DW] = {32 {1'sb1}};
	assign tl_h_o[42-:8] = err_source;
	assign tl_h_o[34-:1] = 1'b0;
	assign tl_h_o[47-:3] = {3 {1'sb0}};
	assign tl_h_o[44-:2] = err_size;
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	assign tl_h_o[50-:3] = (err_opcode == tlul_pkg_Get ? tlul_pkg_AccessAckData : tlul_pkg_AccessAck);
	assign tl_h_o[1] = 1'b1;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			err_rsp_pending <= 1'b0;
		else if ((err_req_pending || err_rsp_pending) && !tl_h_i[0])
			err_rsp_pending <= 1'b1;
		else
			err_rsp_pending <= 1'b0;
endmodule
