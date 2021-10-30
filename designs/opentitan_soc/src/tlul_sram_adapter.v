module tlul_sram_adapter (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	req_o,
	gnt_i,
	we_o,
	addr_o,
	wdata_o,
	wmask_o,
	rdata_i,
	rvalid_i,
	rerror_i
);
	parameter signed [31:0] SramAw = 12;
	parameter signed [31:0] SramDw = 32;
	parameter signed [31:0] Outstanding = 1;
	parameter [0:0] ByteAccess = 1;
	parameter [0:0] ErrOnWrite = 0;
	parameter [0:0] ErrOnRead = 0;
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
	output wire req_o;
	input gnt_i;
	output wire we_o;
	output wire [SramAw - 1:0] addr_o;
	output wire [SramDw - 1:0] wdata_o;
	output wire [SramDw - 1:0] wmask_o;
	input [SramDw - 1:0] rdata_i;
	input rvalid_i;
	input [1:0] rerror_i;
	localparam signed [31:0] SramByte = SramDw / 8;
	function automatic integer tlul_pkg_vbits;
		input integer value;
		tlul_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DataBitWidth = tlul_pkg_vbits(SramByte);
	localparam signed [31:0] WidthMult = SramDw / tlul_pkg_TL_DW;
	localparam signed [31:0] WoffsetWidth = (SramByte == tlul_pkg_TL_DBW ? 1 : DataBitWidth - tlul_pkg_vbits(tlul_pkg_TL_DBW));
	localparam signed [31:0] SramReqFifoWidth = tlul_pkg_TL_DBW + WoffsetWidth;
	localparam signed [31:0] ReqFifoWidth = 13;
	localparam signed [31:0] RspFifoWidth = (SramDw >= 0 ? SramDw + 1 : 1 - SramDw);
	wire reqfifo_wvalid;
	wire reqfifo_wready;
	wire reqfifo_rvalid;
	wire reqfifo_rready;
	wire [12:0] reqfifo_wdata;
	wire [12:0] reqfifo_rdata;
	wire sramreqfifo_wvalid;
	wire sramreqfifo_wready;
	wire sramreqfifo_rready;
	wire [(tlul_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_wdata;
	wire [(tlul_pkg_TL_DBW + WoffsetWidth) - 1:0] sramreqfifo_rdata;
	wire rspfifo_wvalid;
	wire rspfifo_wready;
	wire rspfifo_rvalid;
	wire rspfifo_rready;
	wire [SramDw:0] rspfifo_wdata;
	wire [SramDw:0] rspfifo_rdata;
	wire error_internal;
	wire wr_attr_error;
	wire wr_vld_error;
	wire rd_vld_error;
	wire tlul_error;
	wire a_ack;
	wire d_ack;
	wire sram_ack;
	assign a_ack = tl_i[85] & tl_o[0];
	assign d_ack = tl_o[51] & tl_i[0];
	assign sram_ack = req_o & gnt_i;
	reg d_valid;
	reg d_error;
	localparam [1:0] OpRead = 1;
	always @(*) begin
		d_valid = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[10])
				d_valid = 1'b1;
			else if (reqfifo_rdata[12-:2] == OpRead)
				d_valid = rspfifo_rvalid;
			else
				d_valid = 1'b1;
		end
		else
			d_valid = 1'b0;
	end
	always @(*) begin
		d_error = 1'b0;
		if (reqfifo_rvalid) begin
			if (reqfifo_rdata[12-:2] == OpRead)
				d_error = rspfifo_rdata[0] | reqfifo_rdata[10];
			else
				d_error = reqfifo_rdata[10];
		end
		else
			d_error = 1'b0;
	end
	localparam [2:0] tlul_pkg_AccessAck = 3'h0;
	localparam [2:0] tlul_pkg_AccessAckData = 3'h1;
	function automatic [1:0] sv2v_cast_373C7;
		input reg [1:0] inp;
		sv2v_cast_373C7 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_E8620;
		input reg [7:0] inp;
		sv2v_cast_E8620 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_AF840;
		input reg [0:0] inp;
		sv2v_cast_AF840 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_D61D5;
		input reg [31:0] inp;
		sv2v_cast_D61D5 = inp;
	endfunction
	assign tl_o = {d_valid, (d_valid && (reqfifo_rdata[12-:2] != OpRead) ? tlul_pkg_AccessAck : tlul_pkg_AccessAckData), 3'b000, sv2v_cast_373C7((d_valid ? reqfifo_rdata[9-:2] : {2 {1'sb0}})), sv2v_cast_E8620((d_valid ? reqfifo_rdata[7-:8] : {8 {1'sb0}})), sv2v_cast_AF840(1'b0), sv2v_cast_D61D5(((d_valid && rspfifo_rvalid) && (reqfifo_rdata[12-:2] == OpRead) ? rspfifo_rdata[SramDw-:(SramDw >= 1 ? SramDw : 2 - SramDw)] : {(SramDw >= 1 ? SramDw : 2 - SramDw) {1'sb0}})), d_valid && d_error, ((gnt_i | error_internal) & reqfifo_wready) & sramreqfifo_wready};
	assign req_o = (tl_i[85] & reqfifo_wready) & ~error_internal;
	localparam [2:0] tlul_pkg_PutFullData = 3'h0;
	localparam [2:0] tlul_pkg_PutPartialData = 3'h1;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	assign we_o = tl_i[85] & sv2v_cast_1(|{tl_i[84-:3] == tlul_pkg_PutFullData, tl_i[84-:3] == tlul_pkg_PutPartialData});
	assign addr_o = (tl_i[85] ? tl_i[37 + DataBitWidth+:SramAw] : {SramAw {1'sb0}});
	wire [WoffsetWidth - 1:0] woffset;
	generate
		if (tlul_pkg_TL_DW != SramDw) begin : gen_wordwidthadapt
			assign woffset = tl_i[36 + DataBitWidth:37 + tlul_pkg_vbits(tlul_pkg_TL_DBW)];
		end
		else begin : gen_no_wordwidthadapt
			assign woffset = {WoffsetWidth {1'sb0}};
		end
	endgenerate
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] wmask_int;
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] wdata_int;
	always @(*) begin
		wmask_int = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		wdata_int = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		if (tl_i[85]) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				begin
					wmask_int[(woffset * 32) + (8 * i)+:8] = {8 {tl_i[33 + i]}};
					wdata_int[(woffset * 32) + (8 * i)+:8] = (tl_i[33 + i] && we_o ? tl_i[tlul_pkg_TL_DW - (31 - (8 * i))+:8] : {8 {1'sb0}});
				end
		end
	end
	assign wmask_o = wmask_int;
	assign wdata_o = wdata_int;
	assign wr_attr_error = ((tl_i[84-:3] == tlul_pkg_PutFullData) || (tl_i[84-:3] == tlul_pkg_PutPartialData) ? (ByteAccess == 0 ? (tl_i[36-:4] != {4 {1'sb1}}) || (tl_i[78-:2] != 2'h2) : 1'b0) : 1'b0);
	localparam [2:0] tlul_pkg_Get = 3'h4;
	generate
		if (ErrOnWrite == 1) begin : gen_no_writes
			assign wr_vld_error = tl_i[84-:3] != tlul_pkg_Get;
		end
		else begin : gen_writes_allowed
			assign wr_vld_error = 1'b0;
		end
	endgenerate
	generate
		if (ErrOnRead == 1) begin : gen_no_reads
			assign rd_vld_error = tl_i[84-:3] == tlul_pkg_Get;
		end
		else begin : gen_reads_allowed
			assign rd_vld_error = 1'b0;
		end
	endgenerate
	tlul_err u_err(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.err_o(tlul_error)
	);
	assign error_internal = ((wr_attr_error | wr_vld_error) | rd_vld_error) | tlul_error;
	assign reqfifo_wvalid = a_ack;
	localparam [1:0] OpWrite = 0;
	assign reqfifo_wdata = {(tl_i[84-:3] != tlul_pkg_Get ? OpWrite : OpRead), error_internal, sv2v_cast_373C7(tl_i[78-:2]), sv2v_cast_E8620(tl_i[76-:8])};
	assign reqfifo_rready = d_ack;
	function automatic [3:0] sv2v_cast_43A59;
		input reg [3:0] inp;
		sv2v_cast_43A59 = inp;
	endfunction
	assign sramreqfifo_wdata = {sv2v_cast_43A59(tl_i[36-:4]), woffset};
	assign sramreqfifo_wvalid = sram_ack & ~we_o;
	assign sramreqfifo_rready = rspfifo_wvalid;
	assign rspfifo_wvalid = rvalid_i & reqfifo_rvalid;
	wire [(WidthMult * tlul_pkg_TL_DW) - 1:0] rdata;
	reg [(WidthMult * tlul_pkg_TL_DW) - 1:0] rmask;
	wire [31:0] rdata_tlword;
	always @(*) begin
		rmask = {WidthMult * tlul_pkg_TL_DW {1'sb0}};
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				rmask[(sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * 32) + (8 * i)+:8] = {8 {sramreqfifo_rdata[(tlul_pkg_TL_DBW + (WoffsetWidth - 1)) - (3 - i)]}};
		end
	end
	assign rdata = rdata_i & rmask;
	assign rdata_tlword = rdata[sramreqfifo_rdata[WoffsetWidth - 1-:WoffsetWidth] * tlul_pkg_TL_DW+:tlul_pkg_TL_DW];
	function automatic [SramDw - 1:0] sv2v_cast_1F998;
		input reg [SramDw - 1:0] inp;
		sv2v_cast_1F998 = inp;
	endfunction
	assign rspfifo_wdata = {sv2v_cast_1F998(rdata_tlword), rerror_i[1]};
	assign rspfifo_rready = ((reqfifo_rdata[12-:2] == OpRead) & ~reqfifo_rdata[10] ? reqfifo_rready : 1'b0);
	wire unused_rerror;
	assign unused_rerror = rerror_i[0];
	fifo_sync #(
		.Width(ReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_reqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(reqfifo_wvalid),
		.wready_o(reqfifo_wready),
		.wdata_i(reqfifo_wdata),
		.depth_o(),
		.rvalid_o(reqfifo_rvalid),
		.rready_i(reqfifo_rready),
		.rdata_o(reqfifo_rdata)
	);
	fifo_sync #(
		.Width(SramReqFifoWidth),
		.Pass(1'b0),
		.Depth(Outstanding)
	) u_sramreqfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(sramreqfifo_wvalid),
		.wready_o(sramreqfifo_wready),
		.wdata_i(sramreqfifo_wdata),
		.depth_o(),
		.rvalid_o(),
		.rready_i(sramreqfifo_rready),
		.rdata_o(sramreqfifo_rdata)
	);
	fifo_sync #(
		.Width(RspFifoWidth),
		.Pass(1'b1),
		.Depth(Outstanding)
	) u_rspfifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.wvalid_i(rspfifo_wvalid),
		.wready_o(rspfifo_wready),
		.wdata_i(rspfifo_wdata),
		.depth_o(),
		.rvalid_o(rspfifo_rvalid),
		.rready_i(rspfifo_rready),
		.rdata_o(rspfifo_rdata)
	);
endmodule
