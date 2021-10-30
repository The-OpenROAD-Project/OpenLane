module data_mem_tlul (
	clk_i,
	rst_ni,
	tl_d_i,
	tl_d_o
);
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_d_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_d_o;
	wire we;
	wire req;
	wire [11:0] addr;
	wire [31:0] wdata;
	wire [31:0] wmask;
	reg [31:0] rdata;
	reg rvalid;
	reg rvalid_buf;
	wire [31:0] we_inv;
	wire [3:0] data_we;
	reg [31:0] data_buffer;
	always @(posedge clk_i)
		if (!rst_ni) begin
			rvalid <= 1'b0;
			rvalid_buf <= 1'b0;
		end
		else if (we) begin
			rvalid <= 1'b0;
			rvalid_buf <= 1'b0;
		end
		else begin
			rvalid_buf <= req;
			rvalid <= rvalid_buf;
		end
	assign data_we[1:0] = (wmask[23:16] != 8'd0 ? 2'b11 : 2'b00);
	assign data_we[3:2] = (wmask[31:24] != 8'd0 ? 2'b11 : 2'b00);
	wire [3:0] sel;
	d_2to4_decoder two2four_dec(
		.in(addr[11:10]),
		.out(sel)
	);
	wire [127:0] rdata_out;
	wire [127:0] rdata_dummy;
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : dccm
			sky130_sram_4kbyte_1rw1r_32x1024_8 sky130_sram_4kb(
				.clk0(clk_i),
				.csb0(~(rst_ni && sel[i])),
				.web0(~we),
				.wmask0(data_we),
				.addr0(addr[9:0]),
				.din0(wdata),
				.dout0(rdata_dummy[i * 32+:32]),
				.clk1(clk_i),
				.csb1(~((rst_ni && sel[i]) && ~we)),
				.addr1(addr[9:0]),
				.dout1(rdata_out[i * 32+:32])
			);
		end
	endgenerate
	always @(*)
		case (addr[11:10])
			2'b00: rdata = rdata_out[0+:32];
			2'b01: rdata = rdata_out[32+:32];
			2'b10: rdata = rdata_out[64+:32];
			2'b11: rdata = rdata_out[96+:32];
		endcase
	tlul_sram_adapter #(
		.SramAw(12),
		.SramDw(32),
		.Outstanding(4),
		.ByteAccess(1),
		.ErrOnWrite(0),
		.ErrOnRead(0)
	) data_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_d_i),
		.tl_o(tl_d_o),
		.req_o(req),
		.gnt_i(1'b1),
		.we_o(we),
		.addr_o(addr),
		.wdata_o(wdata),
		.wmask_o(wmask),
		.rdata_i(data_buffer),
		.rvalid_i(rvalid),
		.rerror_i(2'b00)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			data_buffer <= 'b0;
		else
			data_buffer <= rdata;
endmodule
module d_2to4_decoder (
	in,
	out
);
	input wire [1:0] in;
	output reg [3:0] out;
	always @(*)
		case (in)
			2'b00: out = 4'b0001;
			2'b01: out = 4'b0010;
			2'b10: out = 4'b0100;
			2'b11: out = 4'b1000;
		endcase
endmodule
