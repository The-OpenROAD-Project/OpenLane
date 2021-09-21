module ibex_dummy_instr (
	clk_i,
	rst_ni,
	dummy_instr_en_i,
	dummy_instr_mask_i,
	dummy_instr_seed_en_i,
	dummy_instr_seed_i,
	fetch_valid_i,
	id_in_ready_i,
	insert_dummy_instr_o,
	dummy_instr_data_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire dummy_instr_en_i;
	input wire [2:0] dummy_instr_mask_i;
	input wire dummy_instr_seed_en_i;
	input wire [31:0] dummy_instr_seed_i;
	input wire fetch_valid_i;
	input wire id_in_ready_i;
	output wire insert_dummy_instr_o;
	output wire [31:0] dummy_instr_data_o;
	localparam [31:0] TIMEOUT_CNT_W = 5;
	localparam [31:0] OP_W = 5;
	localparam [31:0] LFSR_OUT_W = ((2 + OP_W) + OP_W) + TIMEOUT_CNT_W;
	wire [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] lfsr_data;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_incr;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_threshold;
	wire [TIMEOUT_CNT_W - 1:0] dummy_cnt_d;
	reg [TIMEOUT_CNT_W - 1:0] dummy_cnt_q;
	wire dummy_cnt_en;
	wire lfsr_en;
	wire [LFSR_OUT_W - 1:0] lfsr_state;
	wire insert_dummy_instr;
	reg [6:0] dummy_set;
	reg [2:0] dummy_opcode;
	wire [31:0] dummy_instr;
	reg [31:0] dummy_instr_seed_q;
	wire [31:0] dummy_instr_seed_d;
	assign lfsr_en = insert_dummy_instr & id_in_ready_i;
	assign dummy_instr_seed_d = dummy_instr_seed_q ^ dummy_instr_seed_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dummy_instr_seed_q <= {32 {1'sb0}};
		else if (dummy_instr_seed_en_i)
			dummy_instr_seed_q <= dummy_instr_seed_d;
	prim_lfsr #(
		.LfsrDw(32),
		.StateOutDw(LFSR_OUT_W)
	) lfsr_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.seed_en_i(dummy_instr_seed_en_i),
		.seed_i(dummy_instr_seed_d),
		.lfsr_en_i(lfsr_en),
		.entropy_i('0),
		.state_o(lfsr_state)
	);
	function automatic [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] sv2v_cast_4AF33;
		input reg [(((2 + OP_W) + OP_W) + TIMEOUT_CNT_W) - 1:0] inp;
		sv2v_cast_4AF33 = inp;
	endfunction
	assign lfsr_data = sv2v_cast_4AF33(lfsr_state);
	assign dummy_cnt_threshold = lfsr_data[TIMEOUT_CNT_W - 1-:TIMEOUT_CNT_W] & {dummy_instr_mask_i, {TIMEOUT_CNT_W - 3 {1'b1}}};
	assign dummy_cnt_incr = dummy_cnt_q + {{TIMEOUT_CNT_W - 1 {1'b0}}, 1'b1};
	assign dummy_cnt_d = (insert_dummy_instr ? {TIMEOUT_CNT_W {1'sb0}} : dummy_cnt_incr);
	assign dummy_cnt_en = (dummy_instr_en_i & id_in_ready_i) & (fetch_valid_i | insert_dummy_instr);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			dummy_cnt_q <= {TIMEOUT_CNT_W {1'sb0}};
		else if (dummy_cnt_en)
			dummy_cnt_q <= dummy_cnt_d;
	assign insert_dummy_instr = dummy_instr_en_i & (dummy_cnt_q == dummy_cnt_threshold);
	localparam [1:0] DUMMY_ADD = 2'b00;
	localparam [1:0] DUMMY_AND = 2'b11;
	localparam [1:0] DUMMY_DIV = 2'b10;
	localparam [1:0] DUMMY_MUL = 2'b01;
	always @(*)
		case (lfsr_data[2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))-:((2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))) >= (OP_W + (OP_W + TIMEOUT_CNT_W)) ? ((2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))) - (OP_W + (OP_W + TIMEOUT_CNT_W))) + 1 : ((OP_W + (OP_W + TIMEOUT_CNT_W)) - (2 + (OP_W + (OP_W + (TIMEOUT_CNT_W - 1))))) + 1)])
			DUMMY_ADD: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b000;
			end
			DUMMY_MUL: begin
				dummy_set = 7'b0000001;
				dummy_opcode = 3'b000;
			end
			DUMMY_DIV: begin
				dummy_set = 7'b0000001;
				dummy_opcode = 3'b100;
			end
			DUMMY_AND: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b111;
			end
			default: begin
				dummy_set = 7'b0000000;
				dummy_opcode = 3'b000;
			end
		endcase
	assign dummy_instr = {dummy_set, lfsr_data[OP_W + (OP_W + (TIMEOUT_CNT_W - 1))-:((OP_W + (OP_W + (TIMEOUT_CNT_W - 1))) >= (OP_W + TIMEOUT_CNT_W) ? ((OP_W + (OP_W + (TIMEOUT_CNT_W - 1))) - (OP_W + TIMEOUT_CNT_W)) + 1 : ((OP_W + TIMEOUT_CNT_W) - (OP_W + (OP_W + (TIMEOUT_CNT_W - 1)))) + 1)], lfsr_data[OP_W + (TIMEOUT_CNT_W - 1)-:((OP_W + (TIMEOUT_CNT_W - 1)) >= TIMEOUT_CNT_W ? ((OP_W + (TIMEOUT_CNT_W - 1)) - TIMEOUT_CNT_W) + 1 : (TIMEOUT_CNT_W - (OP_W + (TIMEOUT_CNT_W - 1))) + 1)], dummy_opcode, 5'h00, 7'h33};
	assign insert_dummy_instr_o = insert_dummy_instr;
	assign dummy_instr_data_o = dummy_instr;
endmodule
