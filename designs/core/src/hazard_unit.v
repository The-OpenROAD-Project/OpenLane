module hazard_unit (
	clk_i,
	rst_ni,
	mem_acc_stall_i,
	mem_read_stall_i,
	pc_src_i,
	csr_mret_i,
	csr_flush_i,
	load_use_stall_i,
	stage_ctrl_ao
);
	parameter DEPTH = 5;
	parameter BC_STAGE = 2;
	parameter EX_STAGE = 2;
	input clk_i;
	input rst_ni;
	input mem_acc_stall_i;
	input mem_read_stall_i;
	input wire pc_src_i;
	input csr_mret_i;
	input csr_flush_i;
	input load_use_stall_i;
	output reg [(DEPTH * 2) - 1:0] stage_ctrl_ao;
	reg [DEPTH - 1:0] flush_mask;
	wire [DEPTH - 1:0] next_flush_mask;
	reg [DEPTH - 1:0] pre_mask_stall;
	reg start_flush;
	always @(*) begin
		start_flush = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < DEPTH; i = i + 1)
				begin
					pre_mask_stall[i] = 1'sb0;
					stage_ctrl_ao[i * 2] = 1'sb0;
					stage_ctrl_ao[(i * 2) + 1] = 1'sb0;
				end
		end
		if ((pc_src_i != 1'd0) || csr_mret_i) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < BC_STAGE; i = i + 1)
				stage_ctrl_ao[(i * 2) + 1] = 'b1;
		end
		if (load_use_stall_i) begin
			begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < (EX_STAGE + 1); i = i + 1)
					pre_mask_stall[i] = 'b1;
			end
			stage_ctrl_ao[(EX_STAGE * 2) + 1] = 'b1;
		end
		if (csr_flush_i) begin
			pre_mask_stall[0] = 'b1;
			start_flush = 'b1;
		end
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < (EX_STAGE + 1); i = i + 1)
				stage_ctrl_ao[i * 2] = flush_mask[i] | pre_mask_stall[i];
		end
		if (mem_acc_stall_i || mem_read_stall_i)
			;
	end
	assign next_flush_mask[DEPTH - 1:1] = flush_mask[DEPTH - 2:0];
	assign next_flush_mask[0] = flush_mask[0];
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			flush_mask <= 'b0;
		else if (flush_mask[EX_STAGE + 1] == 1'b1)
			flush_mask <= 'b0;
		else if (start_flush)
			flush_mask[0] <= 1'b1;
		else
			flush_mask <= next_flush_mask;
endmodule
