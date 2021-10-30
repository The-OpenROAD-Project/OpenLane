module rstmgr (
	clk_i,
	rst_ni,
	iccm_rst_i,
	sys_rst_ni
);
	input clk_i;
	input rst_ni;
	input wire iccm_rst_i;
	output wire sys_rst_ni;
	reg rst_d;
	reg rst_q;
	wire rst_fd;
	reg rst_fq;
	always @(*)
		if (!rst_ni)
			rst_d = 1'b0;
		else if (!iccm_rst_i)
			rst_d = 1'b0;
		else
			rst_d = 1'b1;
	always @(posedge clk_i) rst_q <= rst_d;
	assign rst_fd = rst_q;
	always @(posedge clk_i) rst_fq <= rst_fd;
	assign sys_rst_ni = rst_fq;
endmodule
