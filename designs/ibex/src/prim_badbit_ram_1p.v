module prim_badbit_ram_1p (
	clk_i,
	req_i,
	write_i,
	addr_i,
	wdata_i,
	wmask_i,
	rdata_o
);
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	parameter signed [31:0] DataBitsPerMask = 1;
	parameter _sv2v_width_MemInitFile = 1;
	parameter [_sv2v_width_MemInitFile - 1:0] MemInitFile = "";
	localparam signed [31:0] Aw = $clog2(Depth);
	input wire clk_i;
	input wire req_i;
	input wire write_i;
	input wire [Aw - 1:0] addr_i;
	input wire [Width - 1:0] wdata_i;
	input wire [Width - 1:0] wmask_i;
	output wire [Width - 1:0] rdata_o;
	wire [Width - 1:0] sram_rdata;
	prim_generic_ram_1p #(
		.Width(Width),
		.Depth(Depth),
		.DataBitsPerMask(DataBitsPerMask),
		.MemInitFile(MemInitFile)
	) u_mem(
		.clk_i(clk_i),
		.req_i(req_i),
		.write_i(write_i),
		.addr_i(addr_i),
		.wdata_i(wdata_i),
		.wmask_i(wmask_i),
		.rdata_o(sram_rdata)
	);
	wire [31:0] width;
	assign width = Width;
	wire [31:0] addr;
	wire [127:0] wdata;
	wire [127:0] wmask;
	wire [127:0] rdata;
	assign addr = {{32 - Aw {1'b0}}, addr_i};
	assign wdata = {{128 - Width {1'b0}}, wdata_i};
	assign wmask = {{128 - Width {1'b0}}, wmask_i};
	assign rdata = {{128 - Width {1'b0}}, sram_rdata};
	wor [127:0] bad_bit_mask;
	assign bad_bit_mask = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	assign rdata_o = sram_rdata ^ bad_bit_mask;
endmodule
