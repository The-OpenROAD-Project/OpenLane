module prim_intr_hw (
	clk_i,
	rst_ni,
	event_intr_i,
	reg2hw_intr_enable_q_i,
	reg2hw_intr_test_q_i,
	reg2hw_intr_test_qe_i,
	reg2hw_intr_state_q_i,
	hw2reg_intr_state_de_o,
	hw2reg_intr_state_d_o,
	intr_o
);
	parameter [31:0] Width = 1;
	parameter [0:0] FlopOutput = 1;
	input clk_i;
	input rst_ni;
	input [Width - 1:0] event_intr_i;
	input [Width - 1:0] reg2hw_intr_enable_q_i;
	input [Width - 1:0] reg2hw_intr_test_q_i;
	input reg2hw_intr_test_qe_i;
	input [Width - 1:0] reg2hw_intr_state_q_i;
	output hw2reg_intr_state_de_o;
	output [Width - 1:0] hw2reg_intr_state_d_o;
	output reg [Width - 1:0] intr_o;
	wire [Width - 1:0] new_event;
	assign new_event = ({Width {reg2hw_intr_test_qe_i}} & reg2hw_intr_test_q_i) | event_intr_i;
	assign hw2reg_intr_state_de_o = |new_event;
	assign hw2reg_intr_state_d_o = new_event | reg2hw_intr_state_q_i;
	generate
		if (FlopOutput == 1) begin : gen_flop_intr_output
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					intr_o <= {Width {1'sb0}};
				else
					intr_o <= reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
		end
		else begin : gen_intr_passthrough_output
			wire unused_clk;
			wire unused_rst_n;
			assign unused_clk = clk_i;
			assign unused_rst_n = rst_ni;
			wire [Width:1] sv2v_tmp_BA45F;
			assign sv2v_tmp_BA45F = reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
			always @(*) intr_o = sv2v_tmp_BA45F;
		end
	endgenerate
endmodule
