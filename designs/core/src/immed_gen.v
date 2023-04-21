module immed_gen (
	inst_i,
	i_immed_o,
	s_immed_o,
	b_immed_o,
	u_immed_o,
	j_immed_o
);
	input [31:0] inst_i;
	output wire [31:0] i_immed_o;
	output wire [31:0] s_immed_o;
	output wire [31:0] b_immed_o;
	output wire [31:0] u_immed_o;
	output wire [31:0] j_immed_o;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	assign i_immed_o = sv2v_cast_32_signed($signed(inst_i[31:20]));
	assign s_immed_o = sv2v_cast_32_signed($signed({inst_i[31:25], inst_i[11:7]}));
	assign b_immed_o = sv2v_cast_32_signed($signed({inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}));
	assign u_immed_o = sv2v_cast_32_signed($signed({inst_i[31:12], 12'b000000000000}));
	assign j_immed_o = sv2v_cast_32_signed($signed({inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0}));
	reg inst_unused = &{1'b0, inst_i[6:0], 1'b0};
endmodule
