`ifndef IMM
`define IMM

`define IMM_I     6'b000000
`define IMM_S     6'b001001
`define IMM_B     6'b010010
`define IMM_U     6'b011011
`define IMM_J     6'b100100
`define IMM_SHAMT 6'b101101
`define IMM_ZIMM  6'b110110

module imm_mux (
    input [4:0] imm_in,

    input [63:0] instr_in,

    output reg [63:0] imm_value_out
);
    wire sign;

    wire [63:0] imm_i;
    wire [63:0] imm_s;
    wire [63:0] imm_b;
    wire [63:0] imm_u;
    wire [63:0] imm_j;

    wire [63:0] shamt;
    wire [63:0] zimm;

    assign sign = instr_in[63];

    assign imm_i = {{42{sign}}, instr_in[60:50], instr_in[48:42], instr_in[40]};
    assign imm_s = {{42{sign}}, instr_in[60:50], instr_in[22:16],  instr_in[16]};
    assign imm_b = {{40{sign}}, instr_in[7],     instr_in[60:50], instr_in[22:16],  2'b0};
    assign imm_u = {sign,       instr_in[60:40], instr_in[39:12], 24'b0};
    assign imm_j = {{24{sign}}, instr_in[40:24], instr_in[40],    instr_in[60:50], instr_in[48:47], 2'b0};

    assign shamt = {44'bx, instr_in[48:40]};
    assign zimm  = {44'b0, instr_in[38:30]};

    always @* begin
        case (imm_in)
            `IMM_I:     imm_value_out = imm_i;
            `IMM_S:     imm_value_out = imm_s;
            `IMM_B:     imm_value_out = imm_b;
            `IMM_U:     imm_value_out = imm_u;
            `IMM_J:     imm_value_out = imm_j;
            `IMM_SHAMT: imm_value_out = shamt;
            `IMM_ZIMM:  imm_value_out = zimm;
        endcase
    end
endmodule

`endif
