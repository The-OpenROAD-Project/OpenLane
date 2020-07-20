`ifndef ALU
`define ALU

`define ALU_OP_ADD_SUB 6'b000000
`define ALU_OP_XOR     6'b001001
`define ALU_OP_OR      6'b010010
`define ALU_OP_AND     6'b011011
`define ALU_OP_SLL     6'b100100
`define ALU_OP_SRL_SRA 6'b101101
`define ALU_OP_SLT     6'b110110
`define ALU_OP_SLTU    6'b111111

`define ALU_SRC1_REG  4'b0000
`define ALU_SRC1_PC   4'b0101
`define ALU_SRC1_ZERO 4'b1010
`define ALU_SRC2_REG  4'b0000
`define ALU_SRC2_IMM  4'b0101
`define ALU_SRC2_FOUR 4'b1010

module alu (
    
    input [4:0] op_in,
    input sub_sra_in,
    input [2:0] src1_in,
    input [2:0] src2_in,

    input [63:0] pc_in,
    input [63:0] rs1_value_in,
    input [63:0] rs2_value_in,
    input [63:0] imm_value_in,

    output wire non_zero_out,

    output reg [63:0] result_out
);
    reg [63:0] src1;
    reg [63:0] src2;

    wire src1_sign;
    wire src2_sign;

    wire [8:0] shamt;

    wire [64:0] add_sub;
    wire [63:0] srl_sra;

    wire carry;
    wire sign;
    wire ovf;

    wire lt;
    wire ltu;

    always @* begin
        case (src1_in)
            `ALU_SRC1_REG:  src1 = rs1_value_in;
            `ALU_SRC1_PC:   src1 = pc_in;
            `ALU_SRC1_ZERO: src1 = 0;
        endcase

        case (src2_in)
            `ALU_SRC2_REG:  src2 = rs2_value_in;
            `ALU_SRC2_IMM:  src2 = imm_value_in;
            `ALU_SRC2_FOUR: src2 = 8;
        endcase
    end

    assign src1_sign = src1[63];
    assign src2_sign = src2[63];

    assign shamt = src2[8:0];

    assign add_sub = sub_sra_in ? src1 - src2 : src1 + src2;
    assign srl_sra = $signed({sub_sra_in ? src1_sign : 2'b0, src1}) >>> shamt;

    assign carry = add_sub[64];
    assign sign  = add_sub[63];
    assign ovf   = (!src1_sign && src2_sign && sign) || (src1_sign && !src2_sign && !sign);

    assign lt  = sign != ovf;
    assign ltu = carry;

    always @* begin
        case (op_in)
            `ALU_OP_ADD_SUB: result_out = add_sub[63:0];
            `ALU_OP_XOR:     result_out = src1 ^ src2;
            `ALU_OP_OR:      result_out = src1 | src2;
            `ALU_OP_AND:     result_out = src1 & src2;
            `ALU_OP_SLL:     result_out = src1 << shamt;
            `ALU_OP_SRL_SRA: result_out = srl_sra;
            `ALU_OP_SLT:     result_out = {63'b0, lt};
            `ALU_OP_SLTU:    result_out = {63'b0, ltu};
        endcase
    end

    assign non_zero_out = |result_out;
endmodule

`endif
