module prim_ram_1p (
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
	localparam integer prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	localparam integer prim_pkg_ImplBadbit = 2;
	generate
		if (Impl == prim_pkg_ImplBadbit) begin : gen_badbit
			prim_badbit_ram_1p #(
				.Depth(Depth),
				.Width(Width),
				.MemInitFile(MemInitFile),
				.DataBitsPerMask(DataBitsPerMask)
			) u_impl_badbit(.*);
		end
		else begin : gen_generic
			prim_generic_ram_1p #(
				.Depth(Depth),
				.Width(Width),
				.MemInitFile(MemInitFile),
				.DataBitsPerMask(DataBitsPerMask)
			) u_impl_generic(.*);
		end
	endgenerate
endmodule
