module CSR (
	clk,
	rst,
	intTaken,
	intRet,
	addr,
	next_pc,
	wd,
	wr_en,
	rd,
	mepc,
	mtvec,
	mstatus,
	mie
);
	input clk;
	input rst;
	input intTaken;
	input intRet;
	input [11:0] addr;
	input [31:0] next_pc;
	input [31:0] wd;
	input wr_en;
	output reg [31:0] rd;
	output reg [31:0] mepc = 0;
	output reg [31:0] mtvec = 0;
	output reg mstatus;
	output reg mie;
	always @(posedge clk) begin
		if (rst) begin
			mtvec <= 'h0;
			mepc <= 'h0;
			mie <= 'h0;
			mstatus <= 'h0;
		end
		if (wr_en)
			case (addr)
				12'h305: mtvec <= wd;
				12'h341: mepc <= wd;
				12'h304: mie <= wd[0];
				12'h300: mstatus <= wd[0];
			endcase
		if (intTaken) begin
			mepc <= next_pc;
			mstatus <= 1'b0;
		end
		if (intRet)
			mstatus <= 1'b1;
	end
	always @(*)
		case (addr)
			12'h305: rd = mtvec;
			12'h341: rd = mepc;
			12'h304: rd = {{32 {1'b0}}, mie};
			12'h300: rd = {{32 {1'b0}}, mstatus};
			default: rd = 32'd0;
		endcase
endmodule
