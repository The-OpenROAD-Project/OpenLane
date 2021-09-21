module ibex_decoder (
	clk_i,
	rst_ni,
	illegal_insn_o,
	ebrk_insn_o,
	mret_insn_o,
	dret_insn_o,
	ecall_insn_o,
	wfi_insn_o,
	jump_set_o,
	branch_taken_i,
	icache_inval_o,
	instr_first_cycle_i,
	instr_rdata_i,
	instr_rdata_alu_i,
	illegal_c_insn_i,
	imm_a_mux_sel_o,
	imm_b_mux_sel_o,
	bt_a_mux_sel_o,
	bt_b_mux_sel_o,
	imm_i_type_o,
	imm_s_type_o,
	imm_b_type_o,
	imm_u_type_o,
	imm_j_type_o,
	zimm_rs1_type_o,
	rf_wdata_sel_o,
	rf_we_o,
	rf_raddr_a_o,
	rf_raddr_b_o,
	rf_waddr_o,
	rf_ren_a_o,
	rf_ren_b_o,
	alu_operator_o,
	alu_op_a_mux_sel_o,
	alu_op_b_mux_sel_o,
	alu_multicycle_o,
	mult_en_o,
	div_en_o,
	mult_sel_o,
	div_sel_o,
	multdiv_operator_o,
	multdiv_signed_mode_o,
	csr_access_o,
	csr_op_o,
	data_req_o,
	data_we_o,
	data_type_o,
	data_sign_extension_o,
	jump_in_dec_o,
	branch_in_dec_o
);
	parameter [0:0] RV32E = 0;
	localparam integer ibex_pkg_RV32MFast = 2;
	parameter integer RV32M = ibex_pkg_RV32MFast;
	localparam integer ibex_pkg_RV32BNone = 0;
	parameter integer RV32B = ibex_pkg_RV32BNone;
	parameter [0:0] BranchTargetALU = 0;
	input wire clk_i;
	input wire rst_ni;
	output wire illegal_insn_o;
	output reg ebrk_insn_o;
	output reg mret_insn_o;
	output reg dret_insn_o;
	output reg ecall_insn_o;
	output reg wfi_insn_o;
	output reg jump_set_o;
	input wire branch_taken_i;
	output reg icache_inval_o;
	input wire instr_first_cycle_i;
	input wire [31:0] instr_rdata_i;
	input wire [31:0] instr_rdata_alu_i;
	input wire illegal_c_insn_i;
	output reg imm_a_mux_sel_o;
	output reg [2:0] imm_b_mux_sel_o;
	output reg [1:0] bt_a_mux_sel_o;
	output reg [2:0] bt_b_mux_sel_o;
	output wire [31:0] imm_i_type_o;
	output wire [31:0] imm_s_type_o;
	output wire [31:0] imm_b_type_o;
	output wire [31:0] imm_u_type_o;
	output wire [31:0] imm_j_type_o;
	output wire [31:0] zimm_rs1_type_o;
	output reg rf_wdata_sel_o;
	output wire rf_we_o;
	output wire [4:0] rf_raddr_a_o;
	output wire [4:0] rf_raddr_b_o;
	output wire [4:0] rf_waddr_o;
	output reg rf_ren_a_o;
	output reg rf_ren_b_o;
	output reg [5:0] alu_operator_o;
	output reg [1:0] alu_op_a_mux_sel_o;
	output reg alu_op_b_mux_sel_o;
	output reg alu_multicycle_o;
	output wire mult_en_o;
	output wire div_en_o;
	output reg mult_sel_o;
	output reg div_sel_o;
	output reg [1:0] multdiv_operator_o;
	output reg [1:0] multdiv_signed_mode_o;
	output reg csr_access_o;
	output reg [1:0] csr_op_o;
	output reg data_req_o;
	output reg data_we_o;
	output reg [1:0] data_type_o;
	output reg data_sign_extension_o;
	output reg jump_in_dec_o;
	output reg branch_in_dec_o;
	reg illegal_insn;
	wire illegal_reg_rv32e;
	reg csr_illegal;
	reg rf_we;
	wire [31:0] instr;
	wire [31:0] instr_alu;
	wire [9:0] unused_instr_alu;
	wire [4:0] instr_rs1;
	wire [4:0] instr_rs2;
	wire [4:0] instr_rs3;
	wire [4:0] instr_rd;
	reg use_rs3_d;
	reg use_rs3_q;
	reg [1:0] csr_op;
	reg [6:0] opcode;
	reg [6:0] opcode_alu;
	assign instr = instr_rdata_i;
	assign instr_alu = instr_rdata_alu_i;
	assign imm_i_type_o = {{20 {instr[31]}}, instr[31:20]};
	assign imm_s_type_o = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
	assign imm_b_type_o = {{19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_u_type_o = {instr[31:12], 12'b000000000000};
	assign imm_j_type_o = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	assign zimm_rs1_type_o = {27'b000000000000000000000000000, instr_rs1};
	generate
		if (RV32B != ibex_pkg_RV32BNone) begin : gen_rs3_flop
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					use_rs3_q <= 1'b0;
				else
					use_rs3_q <= use_rs3_d;
		end
		else begin : gen_no_rs3_flop
			wire [1:1] sv2v_tmp_66FD5;
			assign sv2v_tmp_66FD5 = use_rs3_d;
			always @(*) use_rs3_q = sv2v_tmp_66FD5;
		end
	endgenerate
	assign instr_rs1 = instr[19:15];
	assign instr_rs2 = instr[24:20];
	assign instr_rs3 = instr[31:27];
	assign rf_raddr_a_o = (use_rs3_q & ~instr_first_cycle_i ? instr_rs3 : instr_rs1);
	assign rf_raddr_b_o = instr_rs2;
	assign instr_rd = instr[11:7];
	assign rf_waddr_o = instr_rd;
	localparam [1:0] ibex_pkg_OP_A_REG_A = 0;
	localparam [0:0] ibex_pkg_OP_B_REG_B = 0;
	generate
		if (RV32E) begin : gen_rv32e_reg_check_active
			assign illegal_reg_rv32e = ((rf_raddr_a_o[4] & (alu_op_a_mux_sel_o == ibex_pkg_OP_A_REG_A)) | (rf_raddr_b_o[4] & (alu_op_b_mux_sel_o == ibex_pkg_OP_B_REG_B))) | (rf_waddr_o[4] & rf_we);
		end
		else begin : gen_rv32e_reg_check_inactive
			assign illegal_reg_rv32e = 1'b0;
		end
	endgenerate
	localparam [1:0] ibex_pkg_CSR_OP_CLEAR = 3;
	localparam [1:0] ibex_pkg_CSR_OP_READ = 0;
	localparam [1:0] ibex_pkg_CSR_OP_SET = 2;
	always @(*) begin : csr_operand_check
		csr_op_o = csr_op;
		if (((csr_op == ibex_pkg_CSR_OP_SET) || (csr_op == ibex_pkg_CSR_OP_CLEAR)) && (instr_rs1 == {5 {1'sb0}}))
			csr_op_o = ibex_pkg_CSR_OP_READ;
	end
	localparam [1:0] ibex_pkg_CSR_OP_WRITE = 1;
	localparam [1:0] ibex_pkg_MD_OP_DIV = 2;
	localparam [1:0] ibex_pkg_MD_OP_MULH = 1;
	localparam [1:0] ibex_pkg_MD_OP_MULL = 0;
	localparam [1:0] ibex_pkg_MD_OP_REM = 3;
	localparam [6:0] ibex_pkg_OPCODE_AUIPC = 7'h17;
	localparam [6:0] ibex_pkg_OPCODE_BRANCH = 7'h63;
	localparam [6:0] ibex_pkg_OPCODE_JAL = 7'h6f;
	localparam [6:0] ibex_pkg_OPCODE_JALR = 7'h67;
	localparam [6:0] ibex_pkg_OPCODE_LOAD = 7'h03;
	localparam [6:0] ibex_pkg_OPCODE_LUI = 7'h37;
	localparam [6:0] ibex_pkg_OPCODE_MISC_MEM = 7'h0f;
	localparam [6:0] ibex_pkg_OPCODE_OP = 7'h33;
	localparam [6:0] ibex_pkg_OPCODE_OP_IMM = 7'h13;
	localparam [6:0] ibex_pkg_OPCODE_STORE = 7'h23;
	localparam [6:0] ibex_pkg_OPCODE_SYSTEM = 7'h73;
	localparam [0:0] ibex_pkg_RF_WD_CSR = 1;
	localparam [0:0] ibex_pkg_RF_WD_EX = 0;
	localparam integer ibex_pkg_RV32BBalanced = 1;
	localparam integer ibex_pkg_RV32BFull = 2;
	localparam integer ibex_pkg_RV32MNone = 0;
	always @(*) begin
		jump_in_dec_o = 1'b0;
		jump_set_o = 1'b0;
		branch_in_dec_o = 1'b0;
		icache_inval_o = 1'b0;
		multdiv_operator_o = ibex_pkg_MD_OP_MULL;
		multdiv_signed_mode_o = 2'b00;
		rf_wdata_sel_o = ibex_pkg_RF_WD_EX;
		rf_we = 1'b0;
		rf_ren_a_o = 1'b0;
		rf_ren_b_o = 1'b0;
		csr_access_o = 1'b0;
		csr_illegal = 1'b0;
		csr_op = ibex_pkg_CSR_OP_READ;
		data_we_o = 1'b0;
		data_type_o = 2'b00;
		data_sign_extension_o = 1'b0;
		data_req_o = 1'b0;
		illegal_insn = 1'b0;
		ebrk_insn_o = 1'b0;
		mret_insn_o = 1'b0;
		dret_insn_o = 1'b0;
		ecall_insn_o = 1'b0;
		wfi_insn_o = 1'b0;
		opcode = instr[6:0];
		case (opcode)
			ibex_pkg_OPCODE_JAL: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
			end
			ibex_pkg_OPCODE_JALR: begin
				jump_in_dec_o = 1'b1;
				if (instr_first_cycle_i) begin
					rf_we = BranchTargetALU;
					jump_set_o = 1'b1;
				end
				else
					rf_we = 1'b1;
				if (instr[14:12] != 3'b000)
					illegal_insn = 1'b1;
				rf_ren_a_o = 1'b1;
			end
			ibex_pkg_OPCODE_BRANCH: begin
				branch_in_dec_o = 1'b1;
				case (instr[14:12])
					3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: illegal_insn = 1'b0;
					default: illegal_insn = 1'b1;
				endcase
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
			end
			ibex_pkg_OPCODE_STORE: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				data_req_o = 1'b1;
				data_we_o = 1'b1;
				if (instr[14])
					illegal_insn = 1'b1;
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: data_type_o = 2'b00;
					default: illegal_insn = 1'b1;
				endcase
			end
			ibex_pkg_OPCODE_LOAD: begin
				rf_ren_a_o = 1'b1;
				data_req_o = 1'b1;
				data_type_o = 2'b00;
				data_sign_extension_o = ~instr[14];
				case (instr[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: begin
						data_type_o = 2'b00;
						if (instr[14])
							illegal_insn = 1'b1;
					end
					default: illegal_insn = 1'b1;
				endcase
			end
			ibex_pkg_OPCODE_LUI: rf_we = 1'b1;
			ibex_pkg_OPCODE_AUIPC: rf_we = 1'b1;
			ibex_pkg_OPCODE_OP_IMM: begin
				rf_ren_a_o = 1'b1;
				rf_we = 1'b1;
				case (instr[14:12])
					3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: illegal_insn = 1'b0;
					3'b001:
						case (instr[31:27])
							5'b00000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
							5'b00100, 5'b01001, 5'b00101, 5'b01101: illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
							5'b00001:
								if (instr[26] == 1'b0)
									illegal_insn = (RV32B == ibex_pkg_RV32BFull ? 1'b0 : 1'b1);
								else
									illegal_insn = 1'b1;
							5'b01100:
								case (instr[26:20])
									7'b0000000, 7'b0000001, 7'b0000010, 7'b0000100, 7'b0000101: illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
									7'b0010000, 7'b0010001, 7'b0010010, 7'b0011000, 7'b0011001, 7'b0011010: illegal_insn = (RV32B == ibex_pkg_RV32BFull ? 1'b0 : 1'b1);
									default: illegal_insn = 1'b1;
								endcase
							default: illegal_insn = 1'b1;
						endcase
					3'b101:
						if (instr[26])
							illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
						else
							case (instr[31:27])
								5'b00000, 5'b01000: illegal_insn = (instr[26:25] == 2'b00 ? 1'b0 : 1'b1);
								5'b00100, 5'b01100, 5'b01001: illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
								5'b01101:
									if (RV32B == ibex_pkg_RV32BFull)
										illegal_insn = 1'b0;
									else
										case (instr[24:20])
											5'b11111, 5'b11000: illegal_insn = (RV32B == ibex_pkg_RV32BBalanced ? 1'b0 : 1'b1);
											default: illegal_insn = 1'b1;
										endcase
								5'b00101:
									if (RV32B == ibex_pkg_RV32BFull)
										illegal_insn = 1'b0;
									else if (instr[24:20] == 5'b00111)
										illegal_insn = (RV32B == ibex_pkg_RV32BBalanced ? 1'b0 : 1'b1);
									else
										illegal_insn = 1'b1;
								5'b00001:
									if (instr[26] == 1'b0)
										illegal_insn = (RV32B == ibex_pkg_RV32BFull ? 1'b0 : 1'b1);
									else
										illegal_insn = 1'b1;
								default: illegal_insn = 1'b1;
							endcase
					default: illegal_insn = 1'b1;
				endcase
			end
			ibex_pkg_OPCODE_OP: begin
				rf_ren_a_o = 1'b1;
				rf_ren_b_o = 1'b1;
				rf_we = 1'b1;
				if ({instr[26], instr[13:12]} == {1'b1, 2'b01})
					illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
				else
					case ({instr[31:25], instr[14:12]})
						{7'b0000000, 3'b000}, {7'b0100000, 3'b000}, {7'b0000000, 3'b010}, {7'b0000000, 3'b011}, {7'b0000000, 3'b100}, {7'b0000000, 3'b110}, {7'b0000000, 3'b111}, {7'b0000000, 3'b001}, {7'b0000000, 3'b101}, {7'b0100000, 3'b101}: illegal_insn = 1'b0;
						{7'b0100000, 3'b111}, {7'b0100000, 3'b110}, {7'b0100000, 3'b100}, {7'b0010000, 3'b001}, {7'b0010000, 3'b101}, {7'b0110000, 3'b001}, {7'b0110000, 3'b101}, {7'b0000101, 3'b100}, {7'b0000101, 3'b101}, {7'b0000101, 3'b110}, {7'b0000101, 3'b111}, {7'b0000100, 3'b100}, {7'b0100100, 3'b100}, {7'b0000100, 3'b111}, {7'b0100100, 3'b001}, {7'b0010100, 3'b001}, {7'b0110100, 3'b001}, {7'b0100100, 3'b101}, {7'b0100100, 3'b111}: illegal_insn = (RV32B != ibex_pkg_RV32BNone ? 1'b0 : 1'b1);
						{7'b0100100, 3'b110}, {7'b0000100, 3'b110}, {7'b0110100, 3'b101}, {7'b0010100, 3'b101}, {7'b0000100, 3'b001}, {7'b0000100, 3'b101}, {7'b0000101, 3'b001}, {7'b0000101, 3'b010}, {7'b0000101, 3'b011}: illegal_insn = (RV32B == ibex_pkg_RV32BFull ? 1'b0 : 1'b1);
						{7'b0000001, 3'b000}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_MULL;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b001}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b010}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b01;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b011}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_MULH;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b100}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_DIV;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b101}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_DIV;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b110}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_REM;
							multdiv_signed_mode_o = 2'b11;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						{7'b0000001, 3'b111}: begin
							multdiv_operator_o = ibex_pkg_MD_OP_REM;
							multdiv_signed_mode_o = 2'b00;
							illegal_insn = (RV32M == ibex_pkg_RV32MNone ? 1'b1 : 1'b0);
						end
						default: illegal_insn = 1'b1;
					endcase
			end
			ibex_pkg_OPCODE_MISC_MEM:
				case (instr[14:12])
					3'b000: rf_we = 1'b0;
					3'b001: begin
						jump_in_dec_o = 1'b1;
						rf_we = 1'b0;
						if (instr_first_cycle_i) begin
							jump_set_o = 1'b1;
							icache_inval_o = 1'b1;
						end
					end
					default: illegal_insn = 1'b1;
				endcase
			ibex_pkg_OPCODE_SYSTEM:
				if (instr[14:12] == 3'b000) begin
					case (instr[31:20])
						12'h000: ecall_insn_o = 1'b1;
						12'h001: ebrk_insn_o = 1'b1;
						12'h302: mret_insn_o = 1'b1;
						12'h7b2: dret_insn_o = 1'b1;
						12'h105: wfi_insn_o = 1'b1;
						default: illegal_insn = 1'b1;
					endcase
					if ((instr_rs1 != 5'b00000) || (instr_rd != 5'b00000))
						illegal_insn = 1'b1;
				end
				else begin
					csr_access_o = 1'b1;
					rf_wdata_sel_o = ibex_pkg_RF_WD_CSR;
					rf_we = 1'b1;
					if (~instr[14])
						rf_ren_a_o = 1'b1;
					case (instr[13:12])
						2'b01: csr_op = ibex_pkg_CSR_OP_WRITE;
						2'b10: csr_op = ibex_pkg_CSR_OP_SET;
						2'b11: csr_op = ibex_pkg_CSR_OP_CLEAR;
						default: csr_illegal = 1'b1;
					endcase
					illegal_insn = csr_illegal;
				end
			default: illegal_insn = 1'b1;
		endcase
		if (illegal_c_insn_i)
			illegal_insn = 1'b1;
		if (illegal_insn) begin
			rf_we = 1'b0;
			data_req_o = 1'b0;
			data_we_o = 1'b0;
			jump_in_dec_o = 1'b0;
			jump_set_o = 1'b0;
			branch_in_dec_o = 1'b0;
			csr_access_o = 1'b0;
		end
	end
	localparam [5:0] ibex_pkg_ALU_ADD = 0;
	localparam [5:0] ibex_pkg_ALU_AND = 4;
	localparam [5:0] ibex_pkg_ALU_ANDN = 7;
	localparam [5:0] ibex_pkg_ALU_BDEP = 48;
	localparam [5:0] ibex_pkg_ALU_BEXT = 47;
	localparam [5:0] ibex_pkg_ALU_BFP = 49;
	localparam [5:0] ibex_pkg_ALU_CLMUL = 50;
	localparam [5:0] ibex_pkg_ALU_CLMULH = 52;
	localparam [5:0] ibex_pkg_ALU_CLMULR = 51;
	localparam [5:0] ibex_pkg_ALU_CLZ = 34;
	localparam [5:0] ibex_pkg_ALU_CMIX = 40;
	localparam [5:0] ibex_pkg_ALU_CMOV = 39;
	localparam [5:0] ibex_pkg_ALU_CRC32C_B = 54;
	localparam [5:0] ibex_pkg_ALU_CRC32C_H = 56;
	localparam [5:0] ibex_pkg_ALU_CRC32C_W = 58;
	localparam [5:0] ibex_pkg_ALU_CRC32_B = 53;
	localparam [5:0] ibex_pkg_ALU_CRC32_H = 55;
	localparam [5:0] ibex_pkg_ALU_CRC32_W = 57;
	localparam [5:0] ibex_pkg_ALU_CTZ = 35;
	localparam [5:0] ibex_pkg_ALU_EQ = 23;
	localparam [5:0] ibex_pkg_ALU_FSL = 41;
	localparam [5:0] ibex_pkg_ALU_FSR = 42;
	localparam [5:0] ibex_pkg_ALU_GE = 21;
	localparam [5:0] ibex_pkg_ALU_GEU = 22;
	localparam [5:0] ibex_pkg_ALU_GORC = 16;
	localparam [5:0] ibex_pkg_ALU_GREV = 15;
	localparam [5:0] ibex_pkg_ALU_LT = 19;
	localparam [5:0] ibex_pkg_ALU_LTU = 20;
	localparam [5:0] ibex_pkg_ALU_MAX = 27;
	localparam [5:0] ibex_pkg_ALU_MAXU = 28;
	localparam [5:0] ibex_pkg_ALU_MIN = 25;
	localparam [5:0] ibex_pkg_ALU_MINU = 26;
	localparam [5:0] ibex_pkg_ALU_NE = 24;
	localparam [5:0] ibex_pkg_ALU_OR = 3;
	localparam [5:0] ibex_pkg_ALU_ORN = 6;
	localparam [5:0] ibex_pkg_ALU_PACK = 29;
	localparam [5:0] ibex_pkg_ALU_PACKH = 31;
	localparam [5:0] ibex_pkg_ALU_PACKU = 30;
	localparam [5:0] ibex_pkg_ALU_PCNT = 36;
	localparam [5:0] ibex_pkg_ALU_ROL = 14;
	localparam [5:0] ibex_pkg_ALU_ROR = 13;
	localparam [5:0] ibex_pkg_ALU_SBCLR = 44;
	localparam [5:0] ibex_pkg_ALU_SBEXT = 46;
	localparam [5:0] ibex_pkg_ALU_SBINV = 45;
	localparam [5:0] ibex_pkg_ALU_SBSET = 43;
	localparam [5:0] ibex_pkg_ALU_SEXTB = 32;
	localparam [5:0] ibex_pkg_ALU_SEXTH = 33;
	localparam [5:0] ibex_pkg_ALU_SHFL = 17;
	localparam [5:0] ibex_pkg_ALU_SLL = 10;
	localparam [5:0] ibex_pkg_ALU_SLO = 12;
	localparam [5:0] ibex_pkg_ALU_SLT = 37;
	localparam [5:0] ibex_pkg_ALU_SLTU = 38;
	localparam [5:0] ibex_pkg_ALU_SRA = 8;
	localparam [5:0] ibex_pkg_ALU_SRL = 9;
	localparam [5:0] ibex_pkg_ALU_SRO = 11;
	localparam [5:0] ibex_pkg_ALU_SUB = 1;
	localparam [5:0] ibex_pkg_ALU_UNSHFL = 18;
	localparam [5:0] ibex_pkg_ALU_XNOR = 5;
	localparam [5:0] ibex_pkg_ALU_XOR = 2;
	localparam [0:0] ibex_pkg_IMM_A_Z = 0;
	localparam [0:0] ibex_pkg_IMM_A_ZERO = 1;
	localparam [2:0] ibex_pkg_IMM_B_B = 2;
	localparam [2:0] ibex_pkg_IMM_B_I = 0;
	localparam [2:0] ibex_pkg_IMM_B_INCR_PC = 5;
	localparam [2:0] ibex_pkg_IMM_B_J = 4;
	localparam [2:0] ibex_pkg_IMM_B_S = 1;
	localparam [2:0] ibex_pkg_IMM_B_U = 3;
	localparam [1:0] ibex_pkg_OP_A_CURRPC = 2;
	localparam [1:0] ibex_pkg_OP_A_IMM = 3;
	localparam [0:0] ibex_pkg_OP_B_IMM = 1;
	always @(*) begin
		alu_operator_o = ibex_pkg_ALU_SLTU;
		alu_op_a_mux_sel_o = ibex_pkg_OP_A_IMM;
		alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
		imm_a_mux_sel_o = ibex_pkg_IMM_A_ZERO;
		imm_b_mux_sel_o = ibex_pkg_IMM_B_I;
		bt_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
		bt_b_mux_sel_o = ibex_pkg_IMM_B_I;
		opcode_alu = instr_alu[6:0];
		use_rs3_d = 1'b0;
		alu_multicycle_o = 1'b0;
		mult_sel_o = 1'b0;
		div_sel_o = 1'b0;
		case (opcode_alu)
			ibex_pkg_OPCODE_JAL: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					bt_b_mux_sel_o = ibex_pkg_IMM_B_J;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_b_mux_sel_o = ibex_pkg_IMM_B_J;
					alu_operator_o = ibex_pkg_ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_b_mux_sel_o = ibex_pkg_IMM_B_INCR_PC;
					alu_operator_o = ibex_pkg_ALU_ADD;
				end
			end
			ibex_pkg_OPCODE_JALR: begin
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
					bt_b_mux_sel_o = ibex_pkg_IMM_B_I;
				end
				if (instr_first_cycle_i && !BranchTargetALU) begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_b_mux_sel_o = ibex_pkg_IMM_B_I;
					alu_operator_o = ibex_pkg_ALU_ADD;
				end
				else begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_b_mux_sel_o = ibex_pkg_IMM_B_INCR_PC;
					alu_operator_o = ibex_pkg_ALU_ADD;
				end
			end
			ibex_pkg_OPCODE_BRANCH: begin
				case (instr_alu[14:12])
					3'b000: alu_operator_o = ibex_pkg_ALU_EQ;
					3'b001: alu_operator_o = ibex_pkg_ALU_NE;
					3'b100: alu_operator_o = ibex_pkg_ALU_LT;
					3'b101: alu_operator_o = ibex_pkg_ALU_GE;
					3'b110: alu_operator_o = ibex_pkg_ALU_LTU;
					3'b111: alu_operator_o = ibex_pkg_ALU_GEU;
					default:
						;
				endcase
				if (BranchTargetALU) begin
					bt_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					bt_b_mux_sel_o = (branch_taken_i ? ibex_pkg_IMM_B_B : ibex_pkg_IMM_B_INCR_PC);
				end
				if (instr_first_cycle_i) begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_REG_B;
				end
				else begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_b_mux_sel_o = (branch_taken_i ? ibex_pkg_IMM_B_B : ibex_pkg_IMM_B_INCR_PC);
					alu_operator_o = ibex_pkg_ALU_ADD;
				end
			end
			ibex_pkg_OPCODE_STORE: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_REG_B;
				alu_operator_o = ibex_pkg_ALU_ADD;
				if (!instr_alu[14]) begin
					imm_b_mux_sel_o = ibex_pkg_IMM_B_S;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				end
			end
			ibex_pkg_OPCODE_LOAD: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
				alu_operator_o = ibex_pkg_ALU_ADD;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				imm_b_mux_sel_o = ibex_pkg_IMM_B_I;
			end
			ibex_pkg_OPCODE_LUI: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_IMM;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				imm_a_mux_sel_o = ibex_pkg_IMM_A_ZERO;
				imm_b_mux_sel_o = ibex_pkg_IMM_B_U;
				alu_operator_o = ibex_pkg_ALU_ADD;
			end
			ibex_pkg_OPCODE_AUIPC: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				imm_b_mux_sel_o = ibex_pkg_IMM_B_U;
				alu_operator_o = ibex_pkg_ALU_ADD;
			end
			ibex_pkg_OPCODE_OP_IMM: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				imm_b_mux_sel_o = ibex_pkg_IMM_B_I;
				case (instr_alu[14:12])
					3'b000: alu_operator_o = ibex_pkg_ALU_ADD;
					3'b010: alu_operator_o = ibex_pkg_ALU_SLT;
					3'b011: alu_operator_o = ibex_pkg_ALU_SLTU;
					3'b100: alu_operator_o = ibex_pkg_ALU_XOR;
					3'b110: alu_operator_o = ibex_pkg_ALU_OR;
					3'b111: alu_operator_o = ibex_pkg_ALU_AND;
					3'b001:
						if (RV32B != ibex_pkg_RV32BNone)
							case (instr_alu[31:27])
								5'b00000: alu_operator_o = ibex_pkg_ALU_SLL;
								5'b00100: alu_operator_o = ibex_pkg_ALU_SLO;
								5'b01001: alu_operator_o = ibex_pkg_ALU_SBCLR;
								5'b00101: alu_operator_o = ibex_pkg_ALU_SBSET;
								5'b01101: alu_operator_o = ibex_pkg_ALU_SBINV;
								5'b00001:
									if (instr_alu[26] == 0)
										alu_operator_o = ibex_pkg_ALU_SHFL;
								5'b01100:
									case (instr_alu[26:20])
										7'b0000000: alu_operator_o = ibex_pkg_ALU_CLZ;
										7'b0000001: alu_operator_o = ibex_pkg_ALU_CTZ;
										7'b0000010: alu_operator_o = ibex_pkg_ALU_PCNT;
										7'b0000100: alu_operator_o = ibex_pkg_ALU_SEXTB;
										7'b0000101: alu_operator_o = ibex_pkg_ALU_SEXTH;
										7'b0010000:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0010001:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0010010:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32_W;
												alu_multicycle_o = 1'b1;
											end
										7'b0011000:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32C_B;
												alu_multicycle_o = 1'b1;
											end
										7'b0011001:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32C_H;
												alu_multicycle_o = 1'b1;
											end
										7'b0011010:
											if (RV32B == ibex_pkg_RV32BFull) begin
												alu_operator_o = ibex_pkg_ALU_CRC32C_W;
												alu_multicycle_o = 1'b1;
											end
										default:
											;
									endcase
								default:
									;
							endcase
						else
							alu_operator_o = ibex_pkg_ALU_SLL;
					3'b101:
						if (RV32B != ibex_pkg_RV32BNone) begin
							if (instr_alu[26] == 1'b1) begin
								alu_operator_o = ibex_pkg_ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							else
								case (instr_alu[31:27])
									5'b00000: alu_operator_o = ibex_pkg_ALU_SRL;
									5'b01000: alu_operator_o = ibex_pkg_ALU_SRA;
									5'b00100: alu_operator_o = ibex_pkg_ALU_SRO;
									5'b01001: alu_operator_o = ibex_pkg_ALU_SBEXT;
									5'b01100: begin
										alu_operator_o = ibex_pkg_ALU_ROR;
										alu_multicycle_o = 1'b1;
									end
									5'b01101: alu_operator_o = ibex_pkg_ALU_GREV;
									5'b00101: alu_operator_o = ibex_pkg_ALU_GORC;
									5'b00001:
										if (RV32B == ibex_pkg_RV32BFull)
											if (instr_alu[26] == 1'b0)
												alu_operator_o = ibex_pkg_ALU_UNSHFL;
									default:
										;
								endcase
						end
						else if (instr_alu[31:27] == 5'b00000)
							alu_operator_o = ibex_pkg_ALU_SRL;
						else if (instr_alu[31:27] == 5'b01000)
							alu_operator_o = ibex_pkg_ALU_SRA;
					default:
						;
				endcase
			end
			ibex_pkg_OPCODE_OP: begin
				alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
				alu_op_b_mux_sel_o = ibex_pkg_OP_B_REG_B;
				if (instr_alu[26]) begin
					if (RV32B != ibex_pkg_RV32BNone)
						case ({instr_alu[26:25], instr_alu[14:12]})
							{2'b11, 3'b001}: begin
								alu_operator_o = ibex_pkg_ALU_CMIX;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b11, 3'b101}: begin
								alu_operator_o = ibex_pkg_ALU_CMOV;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b10, 3'b001}: begin
								alu_operator_o = ibex_pkg_ALU_FSL;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							{2'b10, 3'b101}: begin
								alu_operator_o = ibex_pkg_ALU_FSR;
								alu_multicycle_o = 1'b1;
								if (instr_first_cycle_i)
									use_rs3_d = 1'b1;
								else
									use_rs3_d = 1'b0;
							end
							default:
								;
						endcase
				end
				else
					case ({instr_alu[31:25], instr_alu[14:12]})
						{7'b0000000, 3'b000}: alu_operator_o = ibex_pkg_ALU_ADD;
						{7'b0100000, 3'b000}: alu_operator_o = ibex_pkg_ALU_SUB;
						{7'b0000000, 3'b010}: alu_operator_o = ibex_pkg_ALU_SLT;
						{7'b0000000, 3'b011}: alu_operator_o = ibex_pkg_ALU_SLTU;
						{7'b0000000, 3'b100}: alu_operator_o = ibex_pkg_ALU_XOR;
						{7'b0000000, 3'b110}: alu_operator_o = ibex_pkg_ALU_OR;
						{7'b0000000, 3'b111}: alu_operator_o = ibex_pkg_ALU_AND;
						{7'b0000000, 3'b001}: alu_operator_o = ibex_pkg_ALU_SLL;
						{7'b0000000, 3'b101}: alu_operator_o = ibex_pkg_ALU_SRL;
						{7'b0100000, 3'b101}: alu_operator_o = ibex_pkg_ALU_SRA;
						{7'b0010000, 3'b001}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SLO;
						{7'b0010000, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SRO;
						{7'b0110000, 3'b001}:
							if (RV32B != ibex_pkg_RV32BNone) begin
								alu_operator_o = ibex_pkg_ALU_ROL;
								alu_multicycle_o = 1'b1;
							end
						{7'b0110000, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone) begin
								alu_operator_o = ibex_pkg_ALU_ROR;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000101, 3'b100}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_MIN;
						{7'b0000101, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_MAX;
						{7'b0000101, 3'b110}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_MINU;
						{7'b0000101, 3'b111}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_MAXU;
						{7'b0000100, 3'b100}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_PACK;
						{7'b0100100, 3'b100}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_PACKU;
						{7'b0000100, 3'b111}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_PACKH;
						{7'b0100000, 3'b100}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_XNOR;
						{7'b0100000, 3'b110}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_ORN;
						{7'b0100000, 3'b111}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_ANDN;
						{7'b0100100, 3'b001}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SBCLR;
						{7'b0010100, 3'b001}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SBSET;
						{7'b0110100, 3'b001}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SBINV;
						{7'b0100100, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_SBEXT;
						{7'b0100100, 3'b111}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_BFP;
						{7'b0110100, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_GREV;
						{7'b0010100, 3'b101}:
							if (RV32B != ibex_pkg_RV32BNone)
								alu_operator_o = ibex_pkg_ALU_GORC;
						{7'b0000100, 3'b001}:
							if (RV32B == ibex_pkg_RV32BFull)
								alu_operator_o = ibex_pkg_ALU_SHFL;
						{7'b0000100, 3'b101}:
							if (RV32B == ibex_pkg_RV32BFull)
								alu_operator_o = ibex_pkg_ALU_UNSHFL;
						{7'b0000101, 3'b001}:
							if (RV32B == ibex_pkg_RV32BFull)
								alu_operator_o = ibex_pkg_ALU_CLMUL;
						{7'b0000101, 3'b010}:
							if (RV32B == ibex_pkg_RV32BFull)
								alu_operator_o = ibex_pkg_ALU_CLMULR;
						{7'b0000101, 3'b011}:
							if (RV32B == ibex_pkg_RV32BFull)
								alu_operator_o = ibex_pkg_ALU_CLMULH;
						{7'b0100100, 3'b110}:
							if (RV32B == ibex_pkg_RV32BFull) begin
								alu_operator_o = ibex_pkg_ALU_BDEP;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000100, 3'b110}:
							if (RV32B == ibex_pkg_RV32BFull) begin
								alu_operator_o = ibex_pkg_ALU_BEXT;
								alu_multicycle_o = 1'b1;
							end
						{7'b0000001, 3'b000}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							mult_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b001}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							mult_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b010}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							mult_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b011}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							mult_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b100}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							div_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b101}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							div_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b110}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							div_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						{7'b0000001, 3'b111}: begin
							alu_operator_o = ibex_pkg_ALU_ADD;
							div_sel_o = (RV32M == ibex_pkg_RV32MNone ? 1'b0 : 1'b1);
						end
						default:
							;
					endcase
			end
			ibex_pkg_OPCODE_MISC_MEM:
				case (instr_alu[14:12])
					3'b000: begin
						alu_operator_o = ibex_pkg_ALU_ADD;
						alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
						alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					end
					3'b001:
						if (BranchTargetALU) begin
							bt_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
							bt_b_mux_sel_o = ibex_pkg_IMM_B_INCR_PC;
						end
						else begin
							alu_op_a_mux_sel_o = ibex_pkg_OP_A_CURRPC;
							alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
							imm_b_mux_sel_o = ibex_pkg_IMM_B_INCR_PC;
							alu_operator_o = ibex_pkg_ALU_ADD;
						end
					default:
						;
				endcase
			ibex_pkg_OPCODE_SYSTEM:
				if (instr_alu[14:12] == 3'b000) begin
					alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
				end
				else begin
					alu_op_b_mux_sel_o = ibex_pkg_OP_B_IMM;
					imm_a_mux_sel_o = ibex_pkg_IMM_A_Z;
					imm_b_mux_sel_o = ibex_pkg_IMM_B_I;
					if (instr_alu[14])
						alu_op_a_mux_sel_o = ibex_pkg_OP_A_IMM;
					else
						alu_op_a_mux_sel_o = ibex_pkg_OP_A_REG_A;
				end
			default:
				;
		endcase
	end
	assign mult_en_o = (illegal_insn ? 1'b0 : mult_sel_o);
	assign div_en_o = (illegal_insn ? 1'b0 : div_sel_o);
	assign illegal_insn_o = illegal_insn | illegal_reg_rv32e;
	assign rf_we_o = rf_we & ~illegal_reg_rv32e;
	assign unused_instr_alu = {instr_alu[19:15], instr_alu[11:7]};
endmodule
