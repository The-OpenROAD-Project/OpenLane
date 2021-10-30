module fifo_sync (
	clk_i,
	rst_ni,
	clr_i,
	wvalid_i,
	wready_o,
	wdata_i,
	rvalid_o,
	rready_i,
	rdata_o,
	depth_o
);
	parameter [31:0] Width = 16;
	parameter [0:0] Pass = 1'b1;
	parameter [31:0] Depth = 4;
	parameter [0:0] OutputZeroIfEmpty = 1'b1;
	function automatic integer tlul_pkg_vbits;
		input integer value;
		tlul_pkg_vbits = (value == 1 ? 1 : $clog2(value));
	endfunction
	localparam signed [31:0] DepthW = tlul_pkg_vbits(Depth + 1);
	input clk_i;
	input rst_ni;
	input clr_i;
	input wvalid_i;
	output wready_o;
	input [Width - 1:0] wdata_i;
	output rvalid_o;
	input rready_i;
	output [Width - 1:0] rdata_o;
	output [DepthW - 1:0] depth_o;
	generate
		if (Depth == 0) begin : gen_passthru_fifo
			assign depth_o = 1'b0;
			assign rvalid_o = wvalid_i;
			assign rdata_o = wdata_i;
			assign wready_o = rready_i;
			wire unused_clr;
			assign unused_clr = clr_i;
		end
		else begin : gen_normal_fifo
			localparam [31:0] PTRV_W = tlul_pkg_vbits(Depth);
			localparam [31:0] PTR_WIDTH = PTRV_W + 1;
			reg [PTR_WIDTH - 1:0] fifo_wptr;
			reg [PTR_WIDTH - 1:0] fifo_rptr;
			wire fifo_incr_wptr;
			wire fifo_incr_rptr;
			wire fifo_empty;
			wire full;
			wire empty;
			wire wptr_msb;
			wire rptr_msb;
			wire [PTRV_W - 1:0] wptr_value;
			wire [PTRV_W - 1:0] rptr_value;
			assign wptr_msb = fifo_wptr[PTR_WIDTH - 1];
			assign rptr_msb = fifo_rptr[PTR_WIDTH - 1];
			assign wptr_value = fifo_wptr[0+:PTRV_W];
			assign rptr_value = fifo_rptr[0+:PTRV_W];
			function automatic [DepthW - 1:0] sv2v_cast_703F8;
				input reg [DepthW - 1:0] inp;
				sv2v_cast_703F8 = inp;
			endfunction
			assign depth_o = (full ? sv2v_cast_703F8(Depth) : (wptr_msb == rptr_msb ? sv2v_cast_703F8(wptr_value) - sv2v_cast_703F8(rptr_value) : (sv2v_cast_703F8(Depth) - sv2v_cast_703F8(rptr_value)) + sv2v_cast_703F8(wptr_value)));
			assign fifo_incr_wptr = wvalid_i & wready_o;
			assign fifo_incr_rptr = rvalid_o & rready_i;
			assign wready_o = ~full;
			assign rvalid_o = ~empty;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_wptr <= {PTR_WIDTH {1'b0}};
				else if (clr_i)
					fifo_wptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_wptr) begin : sv2v_autoblock_1
					reg [((PTR_WIDTH - 2) >= 0 ? PTR_WIDTH - 1 : 3 - PTR_WIDTH) - 1:0] sv2v_tmp_cast;
					sv2v_tmp_cast = Depth - 1;
					if (fifo_wptr[PTR_WIDTH - 2:0] == sv2v_tmp_cast)
						fifo_wptr <= {~fifo_wptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_wptr <= fifo_wptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
				end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					fifo_rptr <= {PTR_WIDTH {1'b0}};
				else if (clr_i)
					fifo_rptr <= {PTR_WIDTH {1'b0}};
				else if (fifo_incr_rptr) begin : sv2v_autoblock_2
					reg [((PTR_WIDTH - 2) >= 0 ? PTR_WIDTH - 1 : 3 - PTR_WIDTH) - 1:0] sv2v_tmp_cast_1;
					sv2v_tmp_cast_1 = Depth - 1;
					if (fifo_rptr[PTR_WIDTH - 2:0] == sv2v_tmp_cast_1)
						fifo_rptr <= {~fifo_rptr[PTR_WIDTH - 1], {PTR_WIDTH - 1 {1'b0}}};
					else
						fifo_rptr <= fifo_rptr + {{PTR_WIDTH - 1 {1'b0}}, 1'b1};
				end
			assign full = fifo_wptr == (fifo_rptr ^ {1'b1, {PTR_WIDTH - 1 {1'b0}}});
			assign fifo_empty = fifo_wptr == fifo_rptr;
			reg [(Depth * Width) - 1:0] storage;
			wire [Width - 1:0] storage_rdata;
			if (Depth == 1) begin : gen_depth_eq1
				assign storage_rdata = storage[0+:Width];
				always @(posedge clk_i)
					if (fifo_incr_wptr)
						storage[0+:Width] <= wdata_i;
			end
			else begin : gen_depth_gt1
				assign storage_rdata = storage[fifo_rptr[PTR_WIDTH - 2:0] * Width+:Width];
				always @(posedge clk_i)
					if (fifo_incr_wptr)
						storage[fifo_wptr[PTR_WIDTH - 2:0] * Width+:Width] <= wdata_i;
			end
			wire [Width - 1:0] rdata_int;
			if (Pass == 1'b1) begin : gen_pass
				assign rdata_int = (fifo_empty && wvalid_i ? wdata_i : storage_rdata);
				assign empty = fifo_empty & ~wvalid_i;
			end
			else begin : gen_nopass
				assign rdata_int = storage_rdata;
				assign empty = fifo_empty;
			end
			if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
				assign rdata_o = (empty ? 'b0 : rdata_int);
			end
			else begin : gen_no_output_zero
				assign rdata_o = rdata_int;
			end
		end
	endgenerate
endmodule
