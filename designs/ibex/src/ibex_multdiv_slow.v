module ibex_multdiv_slow (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	mult_sel_i,
	div_sel_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero_i,
	data_ind_timing_i,
	alu_operand_a_o,
	alu_operand_b_o,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	multdiv_ready_id_i,
	multdiv_result_o,
	valid_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire mult_sel_i;
	input wire div_sel_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero_i;
	input wire data_ind_timing_i;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	input wire [67:0] imd_val_q_i;
	output wire [67:0] imd_val_d_o;
	output wire [1:0] imd_val_we_o;
	input wire multdiv_ready_id_i;
	output wire [31:0] multdiv_result_o;
	output wire valid_o;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	wire [32:0] accum_window_q;
	reg [32:0] accum_window_d;
	wire unused_imd_val0;
	wire [1:0] unused_imd_val1;
	wire [32:0] res_adder_l;
	wire [32:0] res_adder_h;
	reg [4:0] multdiv_count_q;
	reg [4:0] multdiv_count_d;
	reg [32:0] op_b_shift_q;
	reg [32:0] op_b_shift_d;
	reg [32:0] op_a_shift_q;
	reg [32:0] op_a_shift_d;
	wire [32:0] op_a_ext;
	wire [32:0] op_b_ext;
	wire [32:0] one_shift;
	wire [32:0] op_a_bw_pp;
	wire [32:0] op_a_bw_last_pp;
	wire [31:0] b_0;
	wire sign_a;
	wire sign_b;
	wire [32:0] next_quotient;
	wire [31:0] next_remainder;
	wire [31:0] op_numerator_q;
	reg [31:0] op_numerator_d;
	wire is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	reg div_by_zero_d;
	reg div_by_zero_q;
	reg multdiv_hold;
	wire multdiv_en;
	assign res_adder_l = alu_adder_ext_i[32:0];
	assign res_adder_h = alu_adder_ext_i[33:1];
	assign imd_val_d_o[34+:34] = {1'b0, accum_window_d};
	assign imd_val_we_o[0] = ~multdiv_hold;
	assign accum_window_q = imd_val_q_i[66-:33];
	assign unused_imd_val0 = imd_val_q_i[67];
	assign imd_val_d_o[0+:34] = {2'b00, op_numerator_d};
	assign imd_val_we_o[1] = multdiv_en;
	assign op_numerator_q = imd_val_q_i[31-:32];
	assign unused_imd_val1 = imd_val_q_i[33-:2];
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_IDLE = 0;
	localparam [2:0] MD_LAST = 4;
	localparam [1:0] ibex_pkg_MD_OP_DIV = 2;
	localparam [1:0] ibex_pkg_MD_OP_MULH = 1;
	localparam [1:0] ibex_pkg_MD_OP_MULL = 0;
	localparam [1:0] ibex_pkg_MD_OP_REM = 3;
	always @(*) begin
		alu_operand_a_o = accum_window_q;
		case (operator_i)
			ibex_pkg_MD_OP_MULL: alu_operand_b_o = op_a_bw_pp;
			ibex_pkg_MD_OP_MULH: alu_operand_b_o = (md_state_q == MD_LAST ? op_a_bw_last_pp : op_a_bw_pp);
			ibex_pkg_MD_OP_DIV, ibex_pkg_MD_OP_REM:
				case (md_state_q)
					MD_IDLE: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_ABS_A: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_a_i, 1'b1};
					end
					MD_ABS_B: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~op_b_i, 1'b1};
					end
					MD_CHANGE_SIGN: begin
						alu_operand_a_o = {32'h00000000, 1'b1};
						alu_operand_b_o = {~accum_window_q[31:0], 1'b1};
					end
					default: begin
						alu_operand_a_o = {accum_window_q[31:0], 1'b1};
						alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
					end
				endcase
			default: begin
				alu_operand_a_o = accum_window_q;
				alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
			end
		endcase
	end
	assign b_0 = {32 {op_b_shift_q[0]}};
	assign op_a_bw_pp = {~(op_a_shift_q[32] & op_b_shift_q[0]), op_a_shift_q[31:0] & b_0};
	assign op_a_bw_last_pp = {op_a_shift_q[32] & op_b_shift_q[0], ~(op_a_shift_q[31:0] & b_0)};
	assign sign_a = op_a_i[31] & signed_mode_i[0];
	assign sign_b = op_b_i[31] & signed_mode_i[1];
	assign op_a_ext = {sign_a, op_a_i};
	assign op_b_ext = {sign_b, op_b_i};
	assign is_greater_equal = (accum_window_q[31] == op_b_shift_q[31] ? ~res_adder_h[31] : accum_window_q[31]);
	assign one_shift = {32'b00000000000000000000000000000000, 1'b1} << multdiv_count_q;
	assign next_remainder = (is_greater_equal ? res_adder_h[31:0] : accum_window_q[31:0]);
	assign next_quotient = (is_greater_equal ? op_a_shift_q | one_shift : op_a_shift_q);
	assign div_change_sign = (sign_a ^ sign_b) & ~div_by_zero_q;
	assign rem_change_sign = sign_a;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_FINISH = 6;
	always @(*) begin
		multdiv_count_d = multdiv_count_q;
		accum_window_d = accum_window_q;
		op_b_shift_d = op_b_shift_q;
		op_a_shift_d = op_a_shift_q;
		op_numerator_d = op_numerator_q;
		md_state_d = md_state_q;
		multdiv_hold = 1'b0;
		div_by_zero_d = div_by_zero_q;
		if (mult_sel_i || div_sel_i)
			case (md_state_q)
				MD_IDLE: begin
					case (operator_i)
						ibex_pkg_MD_OP_MULL: begin
							op_a_shift_d = op_a_ext << 1;
							accum_window_d = {~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:0] & {32 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = (!data_ind_timing_i && ((op_b_ext >> 1) == 0) ? MD_LAST : MD_COMP);
						end
						ibex_pkg_MD_OP_MULH: begin
							op_a_shift_d = op_a_ext;
							accum_window_d = {1'b1, ~(op_a_ext[32] & op_b_i[0]), op_a_ext[31:1] & {31 {op_b_i[0]}}};
							op_b_shift_d = op_b_ext >> 1;
							md_state_d = MD_COMP;
						end
						ibex_pkg_MD_OP_DIV: begin
							accum_window_d = {33 {1'b1}};
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
							div_by_zero_d = equal_to_zero_i;
						end
						ibex_pkg_MD_OP_REM: begin
							accum_window_d = op_a_ext;
							md_state_d = (!data_ind_timing_i && equal_to_zero_i ? MD_FINISH : MD_ABS_A);
						end
						default:
							;
					endcase
					multdiv_count_d = 5'd31;
				end
				MD_ABS_A: begin
					op_a_shift_d = {33 {1'sb0}};
					op_numerator_d = (sign_a ? alu_adder_i : op_a_i);
					md_state_d = MD_ABS_B;
				end
				MD_ABS_B: begin
					accum_window_d = {32'h00000000, op_numerator_q[31]};
					op_b_shift_d = (sign_b ? {1'b0, alu_adder_i} : {1'b0, op_b_i});
					md_state_d = MD_COMP;
				end
				MD_COMP: begin
					multdiv_count_d = multdiv_count_q - 5'h01;
					case (operator_i)
						ibex_pkg_MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							op_a_shift_d = op_a_shift_q << 1;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = ((!data_ind_timing_i && (op_b_shift_d == 0)) || (multdiv_count_q == 5'd1) ? MD_LAST : MD_COMP);
						end
						ibex_pkg_MD_OP_MULH: begin
							accum_window_d = res_adder_h;
							op_a_shift_d = op_a_shift_q;
							op_b_shift_d = op_b_shift_q >> 1;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
						ibex_pkg_MD_OP_DIV, ibex_pkg_MD_OP_REM: begin
							accum_window_d = {next_remainder[31:0], op_numerator_q[multdiv_count_d]};
							op_a_shift_d = next_quotient;
							md_state_d = (multdiv_count_q == 5'd1 ? MD_LAST : MD_COMP);
						end
						default:
							;
					endcase
				end
				MD_LAST:
					case (operator_i)
						ibex_pkg_MD_OP_MULL: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						ibex_pkg_MD_OP_MULH: begin
							accum_window_d = res_adder_l;
							md_state_d = MD_IDLE;
							md_state_d = MD_IDLE;
							multdiv_hold = ~multdiv_ready_id_i;
						end
						ibex_pkg_MD_OP_DIV: begin
							accum_window_d = next_quotient;
							md_state_d = MD_CHANGE_SIGN;
						end
						ibex_pkg_MD_OP_REM: begin
							accum_window_d = {1'b0, next_remainder[31:0]};
							md_state_d = MD_CHANGE_SIGN;
						end
						default:
							;
					endcase
				MD_CHANGE_SIGN: begin
					md_state_d = MD_FINISH;
					case (operator_i)
						ibex_pkg_MD_OP_DIV: accum_window_d = (div_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						ibex_pkg_MD_OP_REM: accum_window_d = (rem_change_sign ? {1'b0, alu_adder_i} : accum_window_q);
						default:
							;
					endcase
				end
				MD_FINISH: begin
					md_state_d = MD_IDLE;
					multdiv_hold = ~multdiv_ready_id_i;
				end
				default: md_state_d = MD_IDLE;
			endcase
	end
	assign multdiv_en = (mult_en_i | div_en_i) & ~multdiv_hold;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			multdiv_count_q <= 5'h00;
			op_b_shift_q <= 33'h000000000;
			op_a_shift_q <= 33'h000000000;
			md_state_q <= MD_IDLE;
			div_by_zero_q <= 1'b0;
		end
		else if (multdiv_en) begin
			multdiv_count_q <= multdiv_count_d;
			op_b_shift_q <= op_b_shift_d;
			op_a_shift_q <= op_a_shift_d;
			md_state_q <= md_state_d;
			div_by_zero_q <= div_by_zero_d;
		end
	assign valid_o = (md_state_q == MD_FINISH) | ((md_state_q == MD_LAST) & ((operator_i == ibex_pkg_MD_OP_MULL) | (operator_i == ibex_pkg_MD_OP_MULH)));
	assign multdiv_result_o = (div_en_i ? accum_window_q[31:0] : res_adder_l[31:0]);
endmodule
