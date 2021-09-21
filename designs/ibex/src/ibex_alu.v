module ibex_alu (
	operator_i,
	operand_a_i,
	operand_b_i,
	instr_first_cycle_i,
	multdiv_operand_a_i,
	multdiv_operand_b_i,
	multdiv_sel_i,
	imd_val_q_i,
	imd_val_d_o,
	imd_val_we_o,
	adder_result_o,
	adder_result_ext_o,
	result_o,
	comparison_result_o,
	is_equal_result_o
);
	localparam integer ibex_pkg_RV32BNone = 0;
	parameter integer RV32B = ibex_pkg_RV32BNone;
	input wire [5:0] operator_i;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	input wire instr_first_cycle_i;
	input wire [32:0] multdiv_operand_a_i;
	input wire [32:0] multdiv_operand_b_i;
	input wire multdiv_sel_i;
	input wire [63:0] imd_val_q_i;
	output reg [63:0] imd_val_d_o;
	output reg [1:0] imd_val_we_o;
	output wire [31:0] adder_result_o;
	output wire [33:0] adder_result_ext_o;
	output reg [31:0] result_o;
	output wire comparison_result_o;
	output wire is_equal_result_o;
	wire [31:0] operand_a_rev;
	wire [32:0] operand_b_neg;
	generate
		genvar k;
		for (k = 0; k < 32; k = k + 1) begin : gen_rev_operand_a
			assign operand_a_rev[k] = operand_a_i[31 - k];
		end
	endgenerate
	reg adder_op_b_negate;
	wire [32:0] adder_in_a;
	reg [32:0] adder_in_b;
	wire [31:0] adder_result;
	localparam [5:0] ibex_pkg_ALU_EQ = 23;
	localparam [5:0] ibex_pkg_ALU_GE = 21;
	localparam [5:0] ibex_pkg_ALU_GEU = 22;
	localparam [5:0] ibex_pkg_ALU_LT = 19;
	localparam [5:0] ibex_pkg_ALU_LTU = 20;
	localparam [5:0] ibex_pkg_ALU_MAX = 27;
	localparam [5:0] ibex_pkg_ALU_MAXU = 28;
	localparam [5:0] ibex_pkg_ALU_MIN = 25;
	localparam [5:0] ibex_pkg_ALU_MINU = 26;
	localparam [5:0] ibex_pkg_ALU_NE = 24;
	localparam [5:0] ibex_pkg_ALU_SLT = 37;
	localparam [5:0] ibex_pkg_ALU_SLTU = 38;
	localparam [5:0] ibex_pkg_ALU_SUB = 1;
	always @(*) begin
		adder_op_b_negate = 1'b0;
		case (operator_i)
			ibex_pkg_ALU_SUB, ibex_pkg_ALU_EQ, ibex_pkg_ALU_NE, ibex_pkg_ALU_GE, ibex_pkg_ALU_GEU, ibex_pkg_ALU_LT, ibex_pkg_ALU_LTU, ibex_pkg_ALU_SLT, ibex_pkg_ALU_SLTU, ibex_pkg_ALU_MIN, ibex_pkg_ALU_MINU, ibex_pkg_ALU_MAX, ibex_pkg_ALU_MAXU: adder_op_b_negate = 1'b1;
			default:
				;
		endcase
	end
	assign adder_in_a = (multdiv_sel_i ? multdiv_operand_a_i : {operand_a_i, 1'b1});
	assign operand_b_neg = {operand_b_i, 1'b0} ^ {33 {1'b1}};
	always @(*)
		case (1'b1)
			multdiv_sel_i: adder_in_b = multdiv_operand_b_i;
			adder_op_b_negate: adder_in_b = operand_b_neg;
			default: adder_in_b = {operand_b_i, 1'b0};
		endcase
	assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);
	assign adder_result = adder_result_ext_o[32:1];
	assign adder_result_o = adder_result;
	wire is_equal;
	reg is_greater_equal;
	reg cmp_signed;
	always @(*)
		case (operator_i)
			ibex_pkg_ALU_GE, ibex_pkg_ALU_LT, ibex_pkg_ALU_SLT, ibex_pkg_ALU_MIN, ibex_pkg_ALU_MAX: cmp_signed = 1'b1;
			default: cmp_signed = 1'b0;
		endcase
	assign is_equal = adder_result == 32'b00000000000000000000000000000000;
	assign is_equal_result_o = is_equal;
	always @(*)
		if ((operand_a_i[31] ^ operand_b_i[31]) == 1'b0)
			is_greater_equal = adder_result[31] == 1'b0;
		else
			is_greater_equal = operand_a_i[31] ^ cmp_signed;
	reg cmp_result;
	always @(*)
		case (operator_i)
			ibex_pkg_ALU_EQ: cmp_result = is_equal;
			ibex_pkg_ALU_NE: cmp_result = ~is_equal;
			ibex_pkg_ALU_GE, ibex_pkg_ALU_GEU, ibex_pkg_ALU_MAX, ibex_pkg_ALU_MAXU: cmp_result = is_greater_equal;
			ibex_pkg_ALU_LT, ibex_pkg_ALU_LTU, ibex_pkg_ALU_MIN, ibex_pkg_ALU_MINU, ibex_pkg_ALU_SLT, ibex_pkg_ALU_SLTU: cmp_result = ~is_greater_equal;
			default: cmp_result = is_equal;
		endcase
	assign comparison_result_o = cmp_result;
	reg shift_left;
	wire shift_ones;
	wire shift_arith;
	wire shift_funnel;
	wire shift_sbmode;
	reg [5:0] shift_amt;
	wire [5:0] shift_amt_compl;
	reg [31:0] shift_operand;
	reg [32:0] shift_result_ext;
	reg unused_shift_result_ext;
	reg [31:0] shift_result;
	reg [31:0] shift_result_rev;
	wire bfp_op;
	wire [4:0] bfp_len;
	wire [4:0] bfp_off;
	wire [31:0] bfp_mask;
	wire [31:0] bfp_mask_rev;
	wire [31:0] bfp_result;
	localparam [5:0] ibex_pkg_ALU_BFP = 49;
	assign bfp_op = (RV32B != ibex_pkg_RV32BNone ? operator_i == ibex_pkg_ALU_BFP : 1'b0);
	assign bfp_len = {~(|operand_b_i[27:24]), operand_b_i[27:24]};
	assign bfp_off = operand_b_i[20:16];
	assign bfp_mask = (RV32B != ibex_pkg_RV32BNone ? ~(32'hffffffff << bfp_len) : {32 {1'sb0}});
	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin : gen_rev_bfp_mask
			assign bfp_mask_rev[i] = bfp_mask[31 - i];
		end
	endgenerate
	assign bfp_result = (RV32B != ibex_pkg_RV32BNone ? (~shift_result & operand_a_i) | ((operand_b_i & bfp_mask) << bfp_off) : {32 {1'sb0}});
	wire [1:1] sv2v_tmp_86907;
	assign sv2v_tmp_86907 = operand_b_i[5] & shift_funnel;
	always @(*) shift_amt[5] = sv2v_tmp_86907;
	assign shift_amt_compl = 32 - operand_b_i[4:0];
	always @(*)
		if (bfp_op)
			shift_amt[4:0] = bfp_off;
		else
			shift_amt[4:0] = (instr_first_cycle_i ? (operand_b_i[5] && shift_funnel ? shift_amt_compl[4:0] : operand_b_i[4:0]) : (operand_b_i[5] && shift_funnel ? operand_b_i[4:0] : shift_amt_compl[4:0]));
	localparam [5:0] ibex_pkg_ALU_SBCLR = 44;
	localparam [5:0] ibex_pkg_ALU_SBINV = 45;
	localparam [5:0] ibex_pkg_ALU_SBSET = 43;
	assign shift_sbmode = (RV32B != ibex_pkg_RV32BNone ? ((operator_i == ibex_pkg_ALU_SBSET) | (operator_i == ibex_pkg_ALU_SBCLR)) | (operator_i == ibex_pkg_ALU_SBINV) : 1'b0);
	localparam [5:0] ibex_pkg_ALU_FSL = 41;
	localparam [5:0] ibex_pkg_ALU_FSR = 42;
	localparam [5:0] ibex_pkg_ALU_ROL = 14;
	localparam [5:0] ibex_pkg_ALU_ROR = 13;
	localparam [5:0] ibex_pkg_ALU_SLL = 10;
	localparam [5:0] ibex_pkg_ALU_SLO = 12;
	always @(*) begin
		case (operator_i)
			ibex_pkg_ALU_SLL: shift_left = 1'b1;
			ibex_pkg_ALU_SLO, ibex_pkg_ALU_BFP: shift_left = (RV32B != ibex_pkg_RV32BNone ? 1'b1 : 1'b0);
			ibex_pkg_ALU_ROL: shift_left = (RV32B != ibex_pkg_RV32BNone ? instr_first_cycle_i : 0);
			ibex_pkg_ALU_ROR: shift_left = (RV32B != ibex_pkg_RV32BNone ? ~instr_first_cycle_i : 0);
			ibex_pkg_ALU_FSL: shift_left = (RV32B != ibex_pkg_RV32BNone ? (shift_amt[5] ? ~instr_first_cycle_i : instr_first_cycle_i) : 1'b0);
			ibex_pkg_ALU_FSR: shift_left = (RV32B != ibex_pkg_RV32BNone ? (shift_amt[5] ? instr_first_cycle_i : ~instr_first_cycle_i) : 1'b0);
			default: shift_left = 1'b0;
		endcase
		if (shift_sbmode)
			shift_left = 1'b1;
	end
	localparam [5:0] ibex_pkg_ALU_SRA = 8;
	assign shift_arith = operator_i == ibex_pkg_ALU_SRA;
	localparam [5:0] ibex_pkg_ALU_SRO = 11;
	assign shift_ones = (RV32B != ibex_pkg_RV32BNone ? (operator_i == ibex_pkg_ALU_SLO) | (operator_i == ibex_pkg_ALU_SRO) : 1'b0);
	assign shift_funnel = (RV32B != ibex_pkg_RV32BNone ? (operator_i == ibex_pkg_ALU_FSL) | (operator_i == ibex_pkg_ALU_FSR) : 1'b0);
	always @(*) begin
		if (RV32B == ibex_pkg_RV32BNone)
			shift_operand = (shift_left ? operand_a_rev : operand_a_i);
		else
			case (1'b1)
				bfp_op: shift_operand = bfp_mask_rev;
				shift_sbmode: shift_operand = 32'h80000000;
				default: shift_operand = (shift_left ? operand_a_rev : operand_a_i);
			endcase
		shift_result_ext = $unsigned($signed({shift_ones | (shift_arith & shift_operand[31]), shift_operand}) >>> shift_amt[4:0]);
		shift_result = shift_result_ext[31:0];
		unused_shift_result_ext = shift_result_ext[32];
		begin : sv2v_autoblock_6
			reg [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				shift_result_rev[i] = shift_result[31 - i];
		end
		shift_result = (shift_left ? shift_result_rev : shift_result);
	end
	wire bwlogic_or;
	wire bwlogic_and;
	wire [31:0] bwlogic_operand_b;
	wire [31:0] bwlogic_or_result;
	wire [31:0] bwlogic_and_result;
	wire [31:0] bwlogic_xor_result;
	reg [31:0] bwlogic_result;
	reg bwlogic_op_b_negate;
	localparam [5:0] ibex_pkg_ALU_ANDN = 7;
	localparam [5:0] ibex_pkg_ALU_CMIX = 40;
	localparam [5:0] ibex_pkg_ALU_ORN = 6;
	localparam [5:0] ibex_pkg_ALU_XNOR = 5;
	always @(*)
		case (operator_i)
			ibex_pkg_ALU_XNOR, ibex_pkg_ALU_ORN, ibex_pkg_ALU_ANDN: bwlogic_op_b_negate = (RV32B != ibex_pkg_RV32BNone ? 1'b1 : 1'b0);
			ibex_pkg_ALU_CMIX: bwlogic_op_b_negate = (RV32B != ibex_pkg_RV32BNone ? ~instr_first_cycle_i : 1'b0);
			default: bwlogic_op_b_negate = 1'b0;
		endcase
	assign bwlogic_operand_b = (bwlogic_op_b_negate ? operand_b_neg[32:1] : operand_b_i);
	assign bwlogic_or_result = operand_a_i | bwlogic_operand_b;
	assign bwlogic_and_result = operand_a_i & bwlogic_operand_b;
	assign bwlogic_xor_result = operand_a_i ^ bwlogic_operand_b;
	localparam [5:0] ibex_pkg_ALU_OR = 3;
	assign bwlogic_or = (operator_i == ibex_pkg_ALU_OR) | (operator_i == ibex_pkg_ALU_ORN);
	localparam [5:0] ibex_pkg_ALU_AND = 4;
	assign bwlogic_and = (operator_i == ibex_pkg_ALU_AND) | (operator_i == ibex_pkg_ALU_ANDN);
	always @(*)
		case (1'b1)
			bwlogic_or: bwlogic_result = bwlogic_or_result;
			bwlogic_and: bwlogic_result = bwlogic_and_result;
			default: bwlogic_result = bwlogic_xor_result;
		endcase
	wire [5:0] bitcnt_result;
	wire [31:0] minmax_result;
	reg [31:0] pack_result;
	wire [31:0] sext_result;
	reg [31:0] singlebit_result;
	reg [31:0] rev_result;
	reg [31:0] shuffle_result;
	reg [31:0] butterfly_result;
	reg [31:0] invbutterfly_result;
	reg [31:0] clmul_result;
	reg [31:0] multicycle_result;
	localparam [5:0] ibex_pkg_ALU_BDEP = 48;
	localparam [5:0] ibex_pkg_ALU_BEXT = 47;
	localparam [5:0] ibex_pkg_ALU_CLMULH = 52;
	localparam [5:0] ibex_pkg_ALU_CLMULR = 51;
	localparam [5:0] ibex_pkg_ALU_CLZ = 34;
	localparam [5:0] ibex_pkg_ALU_CMOV = 39;
	localparam [5:0] ibex_pkg_ALU_CRC32C_B = 54;
	localparam [5:0] ibex_pkg_ALU_CRC32C_H = 56;
	localparam [5:0] ibex_pkg_ALU_CRC32C_W = 58;
	localparam [5:0] ibex_pkg_ALU_CRC32_B = 53;
	localparam [5:0] ibex_pkg_ALU_CRC32_H = 55;
	localparam [5:0] ibex_pkg_ALU_CRC32_W = 57;
	localparam [5:0] ibex_pkg_ALU_CTZ = 35;
	localparam [5:0] ibex_pkg_ALU_GORC = 16;
	localparam [5:0] ibex_pkg_ALU_PACKH = 31;
	localparam [5:0] ibex_pkg_ALU_PACKU = 30;
	localparam [5:0] ibex_pkg_ALU_SEXTB = 32;
	localparam [5:0] ibex_pkg_ALU_UNSHFL = 18;
	localparam integer ibex_pkg_RV32BFull = 2;
	generate
		if (RV32B != ibex_pkg_RV32BNone) begin : g_alu_rvb
			wire zbe_op;
			wire bitcnt_ctz;
			wire bitcnt_clz;
			wire bitcnt_cz;
			reg [31:0] bitcnt_bits;
			wire [31:0] bitcnt_mask_op;
			reg [31:0] bitcnt_bit_mask;
			reg [191:0] bitcnt_partial;
			wire [31:0] bitcnt_partial_lsb_d;
			wire [31:0] bitcnt_partial_msb_d;
			assign bitcnt_ctz = operator_i == ibex_pkg_ALU_CTZ;
			assign bitcnt_clz = operator_i == ibex_pkg_ALU_CLZ;
			assign bitcnt_cz = bitcnt_ctz | bitcnt_clz;
			assign bitcnt_result = bitcnt_partial[0+:6];
			assign bitcnt_mask_op = (bitcnt_clz ? operand_a_rev : operand_a_i);
			always @(*) begin
				bitcnt_bit_mask = bitcnt_mask_op;
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 1);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 2);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 4);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 8);
				bitcnt_bit_mask = bitcnt_bit_mask | (bitcnt_bit_mask << 16);
				bitcnt_bit_mask = ~bitcnt_bit_mask;
			end
			assign zbe_op = (operator_i == ibex_pkg_ALU_BEXT) | (operator_i == ibex_pkg_ALU_BDEP);
			always @(*)
				case (1'b1)
					zbe_op: bitcnt_bits = operand_b_i;
					bitcnt_cz: bitcnt_bits = bitcnt_bit_mask & ~bitcnt_mask_op;
					default: bitcnt_bits = operand_a_i;
				endcase
			always @(*) begin
				bitcnt_partial = {32 {6'b000000}};
				begin : sv2v_autoblock_7
					reg [31:0] i;
					for (i = 1; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = {5'h00, bitcnt_bits[i]} + {5'h00, bitcnt_bits[i - 1]};
				end
				begin : sv2v_autoblock_8
					reg [31:0] i;
					for (i = 3; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_9
					reg [31:0] i;
					for (i = 7; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_10
					reg [31:0] i;
					for (i = 15; i < 32; i = i + 16)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(39 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[0+:6] = bitcnt_partial[96+:6] + bitcnt_partial[0+:6];
				bitcnt_partial[48+:6] = bitcnt_partial[96+:6] + bitcnt_partial[48+:6];
				begin : sv2v_autoblock_11
					reg [31:0] i;
					for (i = 11; i < 32; i = i + 8)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(35 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				begin : sv2v_autoblock_12
					reg [31:0] i;
					for (i = 5; i < 32; i = i + 4)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(33 - i) * 6+:6] + bitcnt_partial[(31 - i) * 6+:6];
				end
				bitcnt_partial[186+:6] = {5'h00, bitcnt_bits[0]};
				begin : sv2v_autoblock_13
					reg [31:0] i;
					for (i = 2; i < 32; i = i + 2)
						bitcnt_partial[(31 - i) * 6+:6] = bitcnt_partial[(32 - i) * 6+:6] + {5'h00, bitcnt_bits[i]};
				end
			end
			assign minmax_result = (cmp_result ? operand_a_i : operand_b_i);
			wire packu;
			wire packh;
			assign packu = operator_i == ibex_pkg_ALU_PACKU;
			assign packh = operator_i == ibex_pkg_ALU_PACKH;
			always @(*)
				case (1'b1)
					packu: pack_result = {operand_b_i[31:16], operand_a_i[31:16]};
					packh: pack_result = {16'h0000, operand_b_i[7:0], operand_a_i[7:0]};
					default: pack_result = {operand_b_i[15:0], operand_a_i[15:0]};
				endcase
			assign sext_result = (operator_i == ibex_pkg_ALU_SEXTB ? {{24 {operand_a_i[7]}}, operand_a_i[7:0]} : {{16 {operand_a_i[15]}}, operand_a_i[15:0]});
			always @(*)
				case (operator_i)
					ibex_pkg_ALU_SBSET: singlebit_result = operand_a_i | shift_result;
					ibex_pkg_ALU_SBCLR: singlebit_result = operand_a_i & ~shift_result;
					ibex_pkg_ALU_SBINV: singlebit_result = operand_a_i ^ shift_result;
					default: singlebit_result = {31'h00000000, shift_result[0]};
				endcase
			wire [4:0] zbp_shift_amt;
			wire gorc_op;
			assign gorc_op = operator_i == ibex_pkg_ALU_GORC;
			assign zbp_shift_amt[2:0] = (RV32B == ibex_pkg_RV32BFull ? shift_amt[2:0] : {3 {&shift_amt[2:0]}});
			assign zbp_shift_amt[4:3] = (RV32B == ibex_pkg_RV32BFull ? shift_amt[4:3] : {2 {&shift_amt[4:3]}});
			always @(*) begin
				rev_result = operand_a_i;
				if (zbp_shift_amt[0])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h55555555) << 1)) | ((rev_result & 32'haaaaaaaa) >> 1);
				if (zbp_shift_amt[1])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h33333333) << 2)) | ((rev_result & 32'hcccccccc) >> 2);
				if (zbp_shift_amt[2])
					rev_result = ((gorc_op ? rev_result : 32'h00000000) | ((rev_result & 32'h0f0f0f0f) << 4)) | ((rev_result & 32'hf0f0f0f0) >> 4);
				if (zbp_shift_amt[3])
					rev_result = ((gorc_op & (RV32B == ibex_pkg_RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h00ff00ff) << 8)) | ((rev_result & 32'hff00ff00) >> 8);
				if (zbp_shift_amt[4])
					rev_result = ((gorc_op & (RV32B == ibex_pkg_RV32BFull) ? rev_result : 32'h00000000) | ((rev_result & 32'h0000ffff) << 16)) | ((rev_result & 32'hffff0000) >> 16);
			end
			wire crc_hmode;
			wire crc_bmode;
			wire [31:0] clmul_result_rev;
			if (RV32B == ibex_pkg_RV32BFull) begin : gen_alu_rvb_full
				localparam [127:0] SHUFFLE_MASK_L = {32'h00ff0000, 32'h0f000f00, 32'h30303030, 32'h44444444};
				localparam [127:0] SHUFFLE_MASK_R = {32'h0000ff00, 32'h00f000f0, 32'h0c0c0c0c, 32'h22222222};
				localparam [127:0] FLIP_MASK_L = {32'h22001100, 32'h00440000, 32'h44110000, 32'h11000000};
				localparam [127:0] FLIP_MASK_R = {32'h00880044, 32'h00002200, 32'h00008822, 32'h00000088};
				wire [31:0] SHUFFLE_MASK_NOT [0:3];
				for (i = 0; i < 4; i = i + 1) begin : gen_shuffle_mask_not
					assign SHUFFLE_MASK_NOT[i] = ~(SHUFFLE_MASK_L[(3 - i) * 32+:32] | SHUFFLE_MASK_R[(3 - i) * 32+:32]);
				end
				wire shuffle_flip;
				assign shuffle_flip = operator_i == ibex_pkg_ALU_UNSHFL;
				reg [3:0] shuffle_mode;
				always @(*) begin
					shuffle_result = operand_a_i;
					if (shuffle_flip) begin
						shuffle_mode[3] = shift_amt[0];
						shuffle_mode[2] = shift_amt[1];
						shuffle_mode[1] = shift_amt[2];
						shuffle_mode[0] = shift_amt[3];
					end
					else
						shuffle_mode = shift_amt[3:0];
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
					if (shuffle_mode[3])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[0]) | (((shuffle_result << 8) & SHUFFLE_MASK_L[96+:32]) | ((shuffle_result >> 8) & SHUFFLE_MASK_R[96+:32]));
					if (shuffle_mode[2])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[1]) | (((shuffle_result << 4) & SHUFFLE_MASK_L[64+:32]) | ((shuffle_result >> 4) & SHUFFLE_MASK_R[64+:32]));
					if (shuffle_mode[1])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[2]) | (((shuffle_result << 2) & SHUFFLE_MASK_L[32+:32]) | ((shuffle_result >> 2) & SHUFFLE_MASK_R[32+:32]));
					if (shuffle_mode[0])
						shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[3]) | (((shuffle_result << 1) & SHUFFLE_MASK_L[0+:32]) | ((shuffle_result >> 1) & SHUFFLE_MASK_R[0+:32]));
					if (shuffle_flip)
						shuffle_result = ((((((((shuffle_result & 32'h88224411) | ((shuffle_result << 6) & FLIP_MASK_L[96+:32])) | ((shuffle_result >> 6) & FLIP_MASK_R[96+:32])) | ((shuffle_result << 9) & FLIP_MASK_L[64+:32])) | ((shuffle_result >> 9) & FLIP_MASK_R[64+:32])) | ((shuffle_result << 15) & FLIP_MASK_L[32+:32])) | ((shuffle_result >> 15) & FLIP_MASK_R[32+:32])) | ((shuffle_result << 21) & FLIP_MASK_L[0+:32])) | ((shuffle_result >> 21) & FLIP_MASK_R[0+:32]);
				end
				reg [191:0] bitcnt_partial_q;
				for (i = 0; i < 32; i = i + 1) begin : gen_bitcnt_reg_in_lsb
					assign bitcnt_partial_lsb_d[i] = bitcnt_partial[(31 - i) * 6];
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_bitcnt_reg_in_b1
					assign bitcnt_partial_msb_d[i] = bitcnt_partial[((31 - ((2 * i) + 1)) * 6) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_bitcnt_reg_in_b2
					assign bitcnt_partial_msb_d[16 + i] = bitcnt_partial[((31 - ((4 * i) + 3)) * 6) + 2];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_bitcnt_reg_in_b3
					assign bitcnt_partial_msb_d[24 + i] = bitcnt_partial[((31 - ((8 * i) + 7)) * 6) + 3];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_bitcnt_reg_in_b4
					assign bitcnt_partial_msb_d[28 + i] = bitcnt_partial[((31 - ((16 * i) + 15)) * 6) + 4];
				end
				assign bitcnt_partial_msb_d[30] = bitcnt_partial[5];
				assign bitcnt_partial_msb_d[31] = 1'b0;
				always @(*) begin
					bitcnt_partial_q = {32 {6'b000000}};
					begin : sv2v_autoblock_14
						reg [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							begin : gen_bitcnt_reg_out_lsb
								bitcnt_partial_q[(31 - i) * 6] = imd_val_q_i[32 + i];
							end
					end
					begin : sv2v_autoblock_15
						reg [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin : gen_bitcnt_reg_out_b1
								bitcnt_partial_q[((31 - ((2 * i) + 1)) * 6) + 1] = imd_val_q_i[i];
							end
					end
					begin : sv2v_autoblock_16
						reg [31:0] i;
						for (i = 0; i < 8; i = i + 1)
							begin : gen_bitcnt_reg_out_b2
								bitcnt_partial_q[((31 - ((4 * i) + 3)) * 6) + 2] = imd_val_q_i[16 + i];
							end
					end
					begin : sv2v_autoblock_17
						reg [31:0] i;
						for (i = 0; i < 4; i = i + 1)
							begin : gen_bitcnt_reg_out_b3
								bitcnt_partial_q[((31 - ((8 * i) + 7)) * 6) + 3] = imd_val_q_i[24 + i];
							end
					end
					begin : sv2v_autoblock_18
						reg [31:0] i;
						for (i = 0; i < 2; i = i + 1)
							begin : gen_bitcnt_reg_out_b4
								bitcnt_partial_q[((31 - ((16 * i) + 15)) * 6) + 4] = imd_val_q_i[28 + i];
							end
					end
					bitcnt_partial_q[5] = imd_val_q_i[30];
				end
				wire [31:0] butterfly_mask_l [0:4];
				wire [31:0] butterfly_mask_r [0:4];
				wire [31:0] butterfly_mask_not [0:4];
				wire [31:0] lrotc_stage [0:4];
				genvar stg;
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_ctrl_stage
					genvar seg;
					for (seg = 0; seg < (2 ** stg); seg = seg + 1) begin : gen_butterfly_ctrl
						assign lrotc_stage[stg][((2 * (16 >> stg)) * (seg + 1)) - 1:(2 * (16 >> stg)) * seg] = {{16 >> stg {1'b0}}, {16 >> stg {1'b1}}} << bitcnt_partial_q[((32 - ((16 >> stg) * ((2 * seg) + 1))) * 6) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) : ($clog2(16 >> stg) + ($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))) - 1)-:($clog2(16 >> stg) >= 0 ? $clog2(16 >> stg) + 1 : 1 - $clog2(16 >> stg))];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = ~lrotc_stage[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)];
						assign butterfly_mask_l[stg][((16 >> stg) * ((2 * seg) + 1)) - 1:(16 >> stg) * (2 * seg)] = {((((16 >> stg) * ((2 * seg) + 1)) - 1) >= ((16 >> stg) * (2 * seg)) ? ((((16 >> stg) * ((2 * seg) + 1)) - 1) - ((16 >> stg) * (2 * seg))) + 1 : (((16 >> stg) * (2 * seg)) - (((16 >> stg) * ((2 * seg) + 1)) - 1)) + 1) {1'sb0}};
						assign butterfly_mask_r[stg][((16 >> stg) * ((2 * seg) + 2)) - 1:(16 >> stg) * ((2 * seg) + 1)] = {((((16 >> stg) * ((2 * seg) + 2)) - 1) >= ((16 >> stg) * ((2 * seg) + 1)) ? ((((16 >> stg) * ((2 * seg) + 2)) - 1) - ((16 >> stg) * ((2 * seg) + 1))) + 1 : (((16 >> stg) * ((2 * seg) + 1)) - (((16 >> stg) * ((2 * seg) + 2)) - 1)) + 1) {1'sb0}};
					end
				end
				for (stg = 0; stg < 5; stg = stg + 1) begin : gen_butterfly_not
					assign butterfly_mask_not[stg] = ~(butterfly_mask_l[stg] | butterfly_mask_r[stg]);
				end
				always @(*) begin
					butterfly_result = operand_a_i;
					butterfly_result = ((butterfly_result & butterfly_mask_not[0]) | ((butterfly_result & butterfly_mask_l[0]) >> 16)) | ((butterfly_result & butterfly_mask_r[0]) << 16);
					butterfly_result = ((butterfly_result & butterfly_mask_not[1]) | ((butterfly_result & butterfly_mask_l[1]) >> 8)) | ((butterfly_result & butterfly_mask_r[1]) << 8);
					butterfly_result = ((butterfly_result & butterfly_mask_not[2]) | ((butterfly_result & butterfly_mask_l[2]) >> 4)) | ((butterfly_result & butterfly_mask_r[2]) << 4);
					butterfly_result = ((butterfly_result & butterfly_mask_not[3]) | ((butterfly_result & butterfly_mask_l[3]) >> 2)) | ((butterfly_result & butterfly_mask_r[3]) << 2);
					butterfly_result = ((butterfly_result & butterfly_mask_not[4]) | ((butterfly_result & butterfly_mask_l[4]) >> 1)) | ((butterfly_result & butterfly_mask_r[4]) << 1);
					butterfly_result = butterfly_result & operand_b_i;
				end
				always @(*) begin
					invbutterfly_result = operand_a_i & operand_b_i;
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[4]) | ((invbutterfly_result & butterfly_mask_l[4]) >> 1)) | ((invbutterfly_result & butterfly_mask_r[4]) << 1);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[3]) | ((invbutterfly_result & butterfly_mask_l[3]) >> 2)) | ((invbutterfly_result & butterfly_mask_r[3]) << 2);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[2]) | ((invbutterfly_result & butterfly_mask_l[2]) >> 4)) | ((invbutterfly_result & butterfly_mask_r[2]) << 4);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[1]) | ((invbutterfly_result & butterfly_mask_l[1]) >> 8)) | ((invbutterfly_result & butterfly_mask_r[1]) << 8);
					invbutterfly_result = ((invbutterfly_result & butterfly_mask_not[0]) | ((invbutterfly_result & butterfly_mask_l[0]) >> 16)) | ((invbutterfly_result & butterfly_mask_r[0]) << 16);
				end
				wire clmul_rmode;
				wire clmul_hmode;
				reg [31:0] clmul_op_a;
				reg [31:0] clmul_op_b;
				wire [31:0] operand_b_rev;
				wire [31:0] clmul_and_stage [0:31];
				wire [31:0] clmul_xor_stage1 [0:15];
				wire [31:0] clmul_xor_stage2 [0:7];
				wire [31:0] clmul_xor_stage3 [0:3];
				wire [31:0] clmul_xor_stage4 [0:1];
				wire [31:0] clmul_result_raw;
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_operand_b
					assign operand_b_rev[i] = operand_b_i[31 - i];
				end
				assign clmul_rmode = operator_i == ibex_pkg_ALU_CLMULR;
				assign clmul_hmode = operator_i == ibex_pkg_ALU_CLMULH;
				localparam [31:0] CRC32_POLYNOMIAL = 32'h04c11db7;
				localparam [31:0] CRC32_MU_REV = 32'hf7011641;
				localparam [31:0] CRC32C_POLYNOMIAL = 32'h1edc6f41;
				localparam [31:0] CRC32C_MU_REV = 32'hdea713f1;
				wire crc_op;
				wire crc_cpoly;
				reg [31:0] crc_operand;
				wire [31:0] crc_poly;
				wire [31:0] crc_mu_rev;
				assign crc_op = (((((operator_i == ibex_pkg_ALU_CRC32C_W) | (operator_i == ibex_pkg_ALU_CRC32_W)) | (operator_i == ibex_pkg_ALU_CRC32C_H)) | (operator_i == ibex_pkg_ALU_CRC32_H)) | (operator_i == ibex_pkg_ALU_CRC32C_B)) | (operator_i == ibex_pkg_ALU_CRC32_B);
				assign crc_cpoly = ((operator_i == ibex_pkg_ALU_CRC32C_W) | (operator_i == ibex_pkg_ALU_CRC32C_H)) | (operator_i == ibex_pkg_ALU_CRC32C_B);
				assign crc_hmode = (operator_i == ibex_pkg_ALU_CRC32_H) | (operator_i == ibex_pkg_ALU_CRC32C_H);
				assign crc_bmode = (operator_i == ibex_pkg_ALU_CRC32_B) | (operator_i == ibex_pkg_ALU_CRC32C_B);
				assign crc_poly = (crc_cpoly ? CRC32C_POLYNOMIAL : CRC32_POLYNOMIAL);
				assign crc_mu_rev = (crc_cpoly ? CRC32C_MU_REV : CRC32_MU_REV);
				always @(*)
					case (1'b1)
						crc_bmode: crc_operand = {operand_a_i[7:0], 24'h000000};
						crc_hmode: crc_operand = {operand_a_i[15:0], 16'h0000};
						default: crc_operand = operand_a_i;
					endcase
				always @(*)
					if (crc_op) begin
						clmul_op_a = (instr_first_cycle_i ? crc_operand : imd_val_q_i[32+:32]);
						clmul_op_b = (instr_first_cycle_i ? crc_mu_rev : crc_poly);
					end
					else begin
						clmul_op_a = (clmul_rmode | clmul_hmode ? operand_a_rev : operand_a_i);
						clmul_op_b = (clmul_rmode | clmul_hmode ? operand_b_rev : operand_b_i);
					end
				for (i = 0; i < 32; i = i + 1) begin : gen_clmul_and_op
					assign clmul_and_stage[i] = (clmul_op_b[i] ? clmul_op_a << i : {32 {1'sb0}});
				end
				for (i = 0; i < 16; i = i + 1) begin : gen_clmul_xor_op_l1
					assign clmul_xor_stage1[i] = clmul_and_stage[2 * i] ^ clmul_and_stage[(2 * i) + 1];
				end
				for (i = 0; i < 8; i = i + 1) begin : gen_clmul_xor_op_l2
					assign clmul_xor_stage2[i] = clmul_xor_stage1[2 * i] ^ clmul_xor_stage1[(2 * i) + 1];
				end
				for (i = 0; i < 4; i = i + 1) begin : gen_clmul_xor_op_l3
					assign clmul_xor_stage3[i] = clmul_xor_stage2[2 * i] ^ clmul_xor_stage2[(2 * i) + 1];
				end
				for (i = 0; i < 2; i = i + 1) begin : gen_clmul_xor_op_l4
					assign clmul_xor_stage4[i] = clmul_xor_stage3[2 * i] ^ clmul_xor_stage3[(2 * i) + 1];
				end
				assign clmul_result_raw = clmul_xor_stage4[0] ^ clmul_xor_stage4[1];
				for (i = 0; i < 32; i = i + 1) begin : gen_rev_clmul_result
					assign clmul_result_rev[i] = clmul_result_raw[31 - i];
				end
				always @(*)
					case (1'b1)
						clmul_rmode: clmul_result = clmul_result_rev;
						clmul_hmode: clmul_result = {1'b0, clmul_result_rev[31:1]};
						default: clmul_result = clmul_result_raw;
					endcase
			end
			else begin : gen_alu_rvb_notfull
				wire [31:0] unused_imd_val_q_1;
				assign unused_imd_val_q_1 = imd_val_q_i[0+:32];
				wire [32:1] sv2v_tmp_8C42B;
				assign sv2v_tmp_8C42B = {32 {1'sb0}};
				always @(*) shuffle_result = sv2v_tmp_8C42B;
				wire [32:1] sv2v_tmp_B0AD4;
				assign sv2v_tmp_B0AD4 = {32 {1'sb0}};
				always @(*) butterfly_result = sv2v_tmp_B0AD4;
				wire [32:1] sv2v_tmp_AFC2C;
				assign sv2v_tmp_AFC2C = {32 {1'sb0}};
				always @(*) invbutterfly_result = sv2v_tmp_AFC2C;
				wire [32:1] sv2v_tmp_3A741;
				assign sv2v_tmp_3A741 = {32 {1'sb0}};
				always @(*) clmul_result = sv2v_tmp_3A741;
				assign bitcnt_partial_lsb_d = {32 {1'sb0}};
				assign bitcnt_partial_msb_d = {32 {1'sb0}};
				assign clmul_result_rev = {32 {1'sb0}};
				assign crc_bmode = 1'b0;
				assign crc_hmode = 1'b0;
			end
			always @(*)
				case (operator_i)
					ibex_pkg_ALU_CMOV: begin
						multicycle_result = (operand_b_i == 32'h00000000 ? operand_a_i : imd_val_q_i[32+:32]);
						imd_val_d_o = {operand_a_i, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ibex_pkg_ALU_CMIX: begin
						multicycle_result = imd_val_q_i[32+:32] | bwlogic_and_result;
						imd_val_d_o = {bwlogic_and_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ibex_pkg_ALU_FSR, ibex_pkg_ALU_FSL, ibex_pkg_ALU_ROL, ibex_pkg_ALU_ROR: begin
						if (shift_amt[4:0] == 5'h00)
							multicycle_result = (shift_amt[5] ? operand_a_i : imd_val_q_i[32+:32]);
						else
							multicycle_result = imd_val_q_i[32+:32] | shift_result;
						imd_val_d_o = {shift_result, 32'h00000000};
						if (instr_first_cycle_i)
							imd_val_we_o = 2'b01;
						else
							imd_val_we_o = 2'b00;
					end
					ibex_pkg_ALU_CRC32_W, ibex_pkg_ALU_CRC32C_W, ibex_pkg_ALU_CRC32_H, ibex_pkg_ALU_CRC32C_H, ibex_pkg_ALU_CRC32_B, ibex_pkg_ALU_CRC32C_B:
						if (RV32B == ibex_pkg_RV32BFull) begin
							case (1'b1)
								crc_bmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 8);
								crc_hmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 16);
								default: multicycle_result = clmul_result_rev;
							endcase
							imd_val_d_o = {clmul_result_rev, 32'h00000000};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b01;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					ibex_pkg_ALU_BEXT, ibex_pkg_ALU_BDEP:
						if (RV32B == ibex_pkg_RV32BFull) begin
							multicycle_result = (operator_i == ibex_pkg_ALU_BDEP ? butterfly_result : invbutterfly_result);
							imd_val_d_o = {bitcnt_partial_lsb_d, bitcnt_partial_msb_d};
							if (instr_first_cycle_i)
								imd_val_we_o = 2'b11;
							else
								imd_val_we_o = 2'b00;
						end
						else begin
							imd_val_d_o = {operand_a_i, 32'h00000000};
							imd_val_we_o = 2'b00;
							multicycle_result = {32 {1'sb0}};
						end
					default: begin
						imd_val_d_o = {operand_a_i, 32'h00000000};
						imd_val_we_o = 2'b00;
						multicycle_result = {32 {1'sb0}};
					end
				endcase
		end
		else begin : g_no_alu_rvb
			wire [63:0] unused_imd_val_q;
			assign unused_imd_val_q = imd_val_q_i;
			wire [31:0] unused_butterfly_result;
			assign unused_butterfly_result = butterfly_result;
			wire [31:0] unused_invbutterfly_result;
			assign unused_invbutterfly_result = invbutterfly_result;
			assign bitcnt_result = {6 {1'sb0}};
			assign minmax_result = {32 {1'sb0}};
			wire [32:1] sv2v_tmp_68181;
			assign sv2v_tmp_68181 = {32 {1'sb0}};
			always @(*) pack_result = sv2v_tmp_68181;
			assign sext_result = {32 {1'sb0}};
			wire [32:1] sv2v_tmp_D756E;
			assign sv2v_tmp_D756E = {32 {1'sb0}};
			always @(*) singlebit_result = sv2v_tmp_D756E;
			wire [32:1] sv2v_tmp_BAAB3;
			assign sv2v_tmp_BAAB3 = {32 {1'sb0}};
			always @(*) rev_result = sv2v_tmp_BAAB3;
			wire [32:1] sv2v_tmp_8C42B;
			assign sv2v_tmp_8C42B = {32 {1'sb0}};
			always @(*) shuffle_result = sv2v_tmp_8C42B;
			wire [32:1] sv2v_tmp_B0AD4;
			assign sv2v_tmp_B0AD4 = {32 {1'sb0}};
			always @(*) butterfly_result = sv2v_tmp_B0AD4;
			wire [32:1] sv2v_tmp_AFC2C;
			assign sv2v_tmp_AFC2C = {32 {1'sb0}};
			always @(*) invbutterfly_result = sv2v_tmp_AFC2C;
			wire [32:1] sv2v_tmp_3A741;
			assign sv2v_tmp_3A741 = {32 {1'sb0}};
			always @(*) clmul_result = sv2v_tmp_3A741;
			wire [32:1] sv2v_tmp_172E8;
			assign sv2v_tmp_172E8 = {32 {1'sb0}};
			always @(*) multicycle_result = sv2v_tmp_172E8;
			wire [64:1] sv2v_tmp_CAB3F;
			assign sv2v_tmp_CAB3F = {2 {32'b00000000000000000000000000000000}};
			always @(*) imd_val_d_o = sv2v_tmp_CAB3F;
			wire [2:1] sv2v_tmp_B65CC;
			assign sv2v_tmp_B65CC = {2 {1'b0}};
			always @(*) imd_val_we_o = sv2v_tmp_B65CC;
		end
	endgenerate
	localparam [5:0] ibex_pkg_ALU_ADD = 0;
	localparam [5:0] ibex_pkg_ALU_CLMUL = 50;
	localparam [5:0] ibex_pkg_ALU_GREV = 15;
	localparam [5:0] ibex_pkg_ALU_PACK = 29;
	localparam [5:0] ibex_pkg_ALU_PCNT = 36;
	localparam [5:0] ibex_pkg_ALU_SBEXT = 46;
	localparam [5:0] ibex_pkg_ALU_SEXTH = 33;
	localparam [5:0] ibex_pkg_ALU_SHFL = 17;
	localparam [5:0] ibex_pkg_ALU_SRL = 9;
	localparam [5:0] ibex_pkg_ALU_XOR = 2;
	always @(*) begin
		result_o = {32 {1'sb0}};
		case (operator_i)
			ibex_pkg_ALU_XOR, ibex_pkg_ALU_XNOR, ibex_pkg_ALU_OR, ibex_pkg_ALU_ORN, ibex_pkg_ALU_AND, ibex_pkg_ALU_ANDN: result_o = bwlogic_result;
			ibex_pkg_ALU_ADD, ibex_pkg_ALU_SUB: result_o = adder_result;
			ibex_pkg_ALU_SLL, ibex_pkg_ALU_SRL, ibex_pkg_ALU_SRA, ibex_pkg_ALU_SLO, ibex_pkg_ALU_SRO: result_o = shift_result;
			ibex_pkg_ALU_SHFL, ibex_pkg_ALU_UNSHFL: result_o = shuffle_result;
			ibex_pkg_ALU_EQ, ibex_pkg_ALU_NE, ibex_pkg_ALU_GE, ibex_pkg_ALU_GEU, ibex_pkg_ALU_LT, ibex_pkg_ALU_LTU, ibex_pkg_ALU_SLT, ibex_pkg_ALU_SLTU: result_o = {31'h00000000, cmp_result};
			ibex_pkg_ALU_MIN, ibex_pkg_ALU_MAX, ibex_pkg_ALU_MINU, ibex_pkg_ALU_MAXU: result_o = minmax_result;
			ibex_pkg_ALU_CLZ, ibex_pkg_ALU_CTZ, ibex_pkg_ALU_PCNT: result_o = {26'h0000000, bitcnt_result};
			ibex_pkg_ALU_PACK, ibex_pkg_ALU_PACKH, ibex_pkg_ALU_PACKU: result_o = pack_result;
			ibex_pkg_ALU_SEXTB, ibex_pkg_ALU_SEXTH: result_o = sext_result;
			ibex_pkg_ALU_CMIX, ibex_pkg_ALU_CMOV, ibex_pkg_ALU_FSL, ibex_pkg_ALU_FSR, ibex_pkg_ALU_ROL, ibex_pkg_ALU_ROR, ibex_pkg_ALU_CRC32_W, ibex_pkg_ALU_CRC32C_W, ibex_pkg_ALU_CRC32_H, ibex_pkg_ALU_CRC32C_H, ibex_pkg_ALU_CRC32_B, ibex_pkg_ALU_CRC32C_B, ibex_pkg_ALU_BEXT, ibex_pkg_ALU_BDEP: result_o = multicycle_result;
			ibex_pkg_ALU_SBSET, ibex_pkg_ALU_SBCLR, ibex_pkg_ALU_SBINV, ibex_pkg_ALU_SBEXT: result_o = singlebit_result;
			ibex_pkg_ALU_GREV, ibex_pkg_ALU_GORC: result_o = rev_result;
			ibex_pkg_ALU_BFP: result_o = bfp_result;
			ibex_pkg_ALU_CLMUL, ibex_pkg_ALU_CLMULR, ibex_pkg_ALU_CLMULH: result_o = clmul_result;
			default:
				;
		endcase
	end
	wire unused_shift_amt_compl;
	assign unused_shift_amt_compl = shift_amt_compl[5];
endmodule
