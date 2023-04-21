`timescale 1ns/1ps

module immed_gen(
    input [31:0] inst_i,
    
    output logic [31:0] i_immed_o,
    output logic [31:0] s_immed_o,
    output logic [31:0] b_immed_o,
    output logic [31:0] u_immed_o,
    output logic [31:0] j_immed_o
);
    assign i_immed_o = 32'(signed'(inst_i[31:20]));

    assign s_immed_o = 32'(signed'({inst_i[31:25], inst_i[11:7]}));

    assign b_immed_o = 32'(signed'({inst_i[31], inst_i[7], inst_i[30:25], 
                            inst_i[11:8], 1'b0}));

    assign u_immed_o = 32'(signed'({inst_i[31:12], 12'b0}));

    assign j_immed_o = 32'(signed'({inst_i[31], inst_i[19:12], inst_i[20], 
                            inst_i[30:21], 1'b0}));

    ////////////////////
    // Unused Signals //
    ////////////////////
    logic inst_unused = &{1'b0,
                          inst_i[6:0],
                          1'b0};

endmodule
