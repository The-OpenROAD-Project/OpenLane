module instr_mem_top (
	clk_i,
	rst_ni,
	req,
	we,
	addr,
	wdata,
	rdata,
	rvalid,
	wen,
	wmask
);
	input clk_i;
	input rst_ni;
	input wire req;
	input wire we;
	input wire [11:0] addr;
	input wire [31:0] wdata;
	output reg [31:0] rdata;
	output reg rvalid;
	input wire wen;
	input wire [3:0] wmask;
	always @(posedge clk_i)
		if (!rst_ni)
			rvalid <= 1'b0;
		else if (we)
			rvalid <= 1'b0;
		else
			rvalid <= req;
	wire [3:0] sel;
	i_2to4_decoder two2four_dec(
		.in(addr[11:10]),
		.out(sel)
	);
	wire [127:0] rdata_out;
	wire [127:0] rdata_dummy;
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : iccm
			sky130_sram_4kbyte_1rw1r_32x1024_8 sky130_sram_4kb(
				.clk0(clk_i),
				.csb0(rst_ni || ~sel[i]),
				.web0(wen),
				.wmask0(wmask),
				.addr0(addr[9:0]),
				.din0(wdata),
				.dout0(rdata_dummy[i * 32+:32]),
				.clk1(clk_i),
				.csb1(~rst_ni && sel[i]),
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
endmodule
module i_2to4_decoder (
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
