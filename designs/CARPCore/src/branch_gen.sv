`timescale 1ns/1ps
`include "defs.svh"

module branch_gen ( 
    input branch_op_e op_i,

    input [31:0] rs1_data_i,
    input [31:0] rs2_data_i,

    output logic taken_o
);

    // Base conditionals
    logic eq,lt,ltu;
    assign eq = rs1_data_i == rs2_data_i;
    assign lt = signed'(rs1_data_i) < signed'(rs2_data_i);
    assign ltu = rs1_data_i < rs2_data_i;
    
    always_comb begin
        unique case (op_i)
            BEQ:  taken_o = eq;
            BNE:  taken_o = ~eq;
            BLT:  taken_o = lt;
            BGE:  taken_o = ~lt;
            BLTU: taken_o = ltu;
            BGEU: taken_o = ~ltu;
            default: taken_o = '0;
        endcase
    end

endmodule
