module ibex_branch_predict (
	clk_i,
	rst_ni,
	fetch_rdata_i,
	fetch_pc_i,
	fetch_valid_i,
	predict_branch_taken_o,
	predict_branch_pc_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire [31:0] fetch_rdata_i;
	input wire [31:0] fetch_pc_i;
	input wire fetch_valid_i;
	output wire predict_branch_taken_o;
	output wire [31:0] predict_branch_pc_o;
	wire [31:0] imm_j_type;
	wire [31:0] imm_b_type;
	wire [31:0] imm_cj_type;
	wire [31:0] imm_cb_type;
	reg [31:0] branch_imm;
	wire [31:0] instr;
	wire instr_j;
	wire instr_b;
	wire instr_cj;
	wire instr_cb;
	wire instr_b_taken;
	assign instr = fetch_rdata_i;
	assign imm_j_type = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	assign imm_b_type = {{19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_cj_type = {{20 {instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0};
	assign imm_cb_type = {{23 {instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0};
	localparam [6:0] ibex_pkg_OPCODE_BRANCH = 7'h63;
	assign instr_b = instr[6:0] == ibex_pkg_OPCODE_BRANCH;
	localparam [6:0] ibex_pkg_OPCODE_JAL = 7'h6f;
	assign instr_j = instr[6:0] == ibex_pkg_OPCODE_JAL;
	assign instr_cb = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
	assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));
	always @(*) begin
		branch_imm = imm_b_type;
		case (1'b1)
			instr_j: branch_imm = imm_j_type;
			instr_b: branch_imm = imm_b_type;
			instr_cj: branch_imm = imm_cj_type;
			instr_cb: branch_imm = imm_cb_type;
			default:
				;
		endcase
	end
	assign instr_b_taken = (instr_b & imm_b_type[31]) | (instr_cb & imm_cb_type[31]);
	assign predict_branch_taken_o = fetch_valid_i & ((instr_j | instr_cj) | instr_b_taken);
	assign predict_branch_pc_o = fetch_pc_i + branch_imm;
endmodule
