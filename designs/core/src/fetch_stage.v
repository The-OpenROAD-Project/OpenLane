module fetch_stage (
	clk_i,
	rst_ni,
	target_sel_i,
	target_addr_i,
	stage_ctrl_i,
	mem_rd_o,
	mem_addr_o,
	mem_gnt_i,
	valid_o,
	fetch_state_o
);
	input clk_i;
	input rst_ni;
	input target_sel_i;
	input [31:0] target_addr_i;
	input wire [1:0] stage_ctrl_i;
	output wire mem_rd_o;
	output wire [31:0] mem_addr_o;
	input wire mem_gnt_i;
	output reg valid_o;
	output reg [63:0] fetch_state_o;
	wire pc_ld;
	reg [31:0] pc_data;
	wire [31:0] pc_out;
	wire [31:0] pc_plus_4;
	assign pc_ld = ~stage_ctrl_i[0] & mem_gnt_i;
	assign pc_plus_4 = pc_out + 4;
	always @(*)
		case (target_sel_i)
			1'd0: pc_data = pc_plus_4;
			1'd1: pc_data = target_addr_i;
			default: pc_data = pc_plus_4;
		endcase
	prog_cntr i_prog_cntr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.ld_i(pc_ld),
		.data_i(pc_data),
		.count_o(pc_out)
	);
	assign mem_addr_o = pc_out;
	assign mem_rd_o = ~stage_ctrl_i[0];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			valid_o <= 1'sb0;
			fetch_state_o[63-:32] <= 1'sb0;
			fetch_state_o[31-:32] <= 1'sb0;
		end
		else if (!stage_ctrl_i[0]) begin
			valid_o <= ~stage_ctrl_i[1] && mem_gnt_i;
			fetch_state_o[63-:32] <= pc_out;
			fetch_state_o[31-:32] <= pc_plus_4;
		end
endmodule
