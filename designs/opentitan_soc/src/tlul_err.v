module tlul_err (
	clk_i,
	rst_ni,
	tl_i,
	err_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	output wire err_o;
	localparam signed [31:0] IW = 8;
	localparam signed [31:0] SZW = 2;
	localparam signed [31:0] DW = 32;
	localparam signed [31:0] MW = 4;
	localparam signed [31:0] SubAW = 2;
	wire opcode_allowed;
	wire a_config_allowed;
	wire op_full;
	wire op_partial;
	wire op_get;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	assign op_full = tl_i[84-:3] == tlul_pkg_PutFullData;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	assign op_partial = tl_i[84-:3] == tlul_pkg_PutPartialData;
	localparam [2:0] tlul_pkg_Get = 3'h4;
	assign op_get = tl_i[84-:3] == tlul_pkg_Get;
	assign err_o = ~(opcode_allowed & a_config_allowed);
	assign opcode_allowed = ((tl_i[84-:3] == tlul_pkg_PutFullData) | (tl_i[84-:3] == tlul_pkg_PutPartialData)) | (tl_i[84-:3] == tlul_pkg_Get);
	reg addr_sz_chk;
	reg mask_chk;
	reg fulldata_chk;
	wire [3:0] mask;
	assign mask = 1 << tl_i[38:37];
	always @(*) begin
		addr_sz_chk = 1'b0;
		mask_chk = 1'b0;
		fulldata_chk = 1'b0;
		if (tl_i[85])
			case (tl_i[78-:2])
				'h0: begin
					addr_sz_chk = 1'b1;
					mask_chk = ~|(tl_i[36-:4] & ~mask);
					fulldata_chk = |(tl_i[36-:4] & mask);
				end
				'h1: begin
					addr_sz_chk = ~tl_i[37];
					mask_chk = (tl_i[38] ? ~|(tl_i[36-:4] & 4'b0011) : ~|(tl_i[36-:4] & 4'b1100));
					fulldata_chk = (tl_i[38] ? &tl_i[36:35] : &tl_i[34:33]);
				end
				'h2: begin
					addr_sz_chk = ~|tl_i[38:37];
					mask_chk = 1'b1;
					fulldata_chk = &tl_i[36:33];
				end
				default: begin
					addr_sz_chk = 1'b0;
					mask_chk = 1'b0;
					fulldata_chk = 1'b0;
				end
			endcase
		else begin
			addr_sz_chk = 1'b0;
			mask_chk = 1'b0;
			fulldata_chk = 1'b0;
		end
	end
	assign a_config_allowed = (addr_sz_chk & mask_chk) & ((op_get | op_partial) | fulldata_chk);
endmodule
