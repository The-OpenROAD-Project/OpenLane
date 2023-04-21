`timescale 1ns / 1ps
`include "defs.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 01/27/2019 09:22:55 AM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module decoder (
    input [31:0] inst_i,

    // PC Control Signals
    output logic pc_src_o,

    // Branch Cond. Control Signals
    output logic [2:0] branch_op_o,

    // ALU Control Signals
    output logic [3:0] alu_op_o,
    output logic [1:0] alu_a_src_o,
    output logic [1:0] alu_b_src_o,

    // Register Information
    output logic rs1_valid_o,
    output logic rs2_valid_o,
    output logic rd_valid_o,

    // Register File Control Signals
    output logic        rf_wr_en_o,
    output rf_wr_src_e  rf_wr_src_o,

    // Memory Control Signals
    output logic       mem_write_o,
    output logic       mem_read_o,
    output logic       mem_sign_o,
    output logic [1:0] mem_width_o

    // TODO: CSR Control Signals
);

    // Instruction Mapping
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    assign opcode = inst_i[6:0];
    assign func3 =  inst_i[14:12];
    assign func7 =  inst_i[31:25];

    ////////////////
    // PC Control //
    ////////////////
    always_comb begin
        unique case (opcode)
            JAL:     pc_src_o = TARGET;
            JALR:    pc_src_o = TARGET;
            default: pc_src_o = PLUS_4;
        endcase
    end

    //////////////////////////
    // Branch Cond. Control //
    //////////////////////////
    always_comb begin
        unique case (opcode)
            BRANCH:  branch_op_o = func3;
            default: branch_op_o = NO_BRANCH;
        endcase
    end

    /////////////////
    // ALU Control //
    /////////////////
    
    // Selects the function of the ALU
    always_comb begin
        unique case (opcode)
            OP_IMM: begin
                if (func3 == 'b101)
                    alu_op_o = {func7[5], func3};
                else 
                    alu_op_o = {1'b0, func3};
            end
            OP:      alu_op_o = {func7[5], func3};
            LUI:     alu_op_o = PASS;
            default: alu_op_o = ADD;
        endcase
    end 
    
    // Selects the source for the ALU A Input
    always_comb begin
        unique case (opcode)
            LUI:     alu_a_src_o = U_IMMED;
            AUIPC:   alu_a_src_o = U_IMMED;
            JAL:     alu_a_src_o = J_IMMED;
            BRANCH:  alu_a_src_o = B_IMMED;
            default: alu_a_src_o = RS1;
        endcase
    end

    // Selects the source for the ALU B Input
    always_comb begin
        unique case (opcode)
            AUIPC:   alu_b_src_o = PC;
            JAL:     alu_b_src_o = PC;
            JALR:    alu_b_src_o = I_IMMED;
            BRANCH:  alu_b_src_o = PC;
            LOAD:    alu_b_src_o = I_IMMED;
            STORE:   alu_b_src_o = S_IMMED;
            OP_IMM:  alu_b_src_o = I_IMMED; 
            default: alu_b_src_o = RS2;
        endcase
    end

    ///////////////////////////
    // Register File Control //
    ///////////////////////////
    assign rf_wr_en_o = (opcode != STORE) && (opcode != BRANCH);
    
    // Source for Register File Write 
    always_comb begin
        case (opcode)
            JAL:     rf_wr_src_o = PC_PLUS_4;
            JALR:    rf_wr_src_o = PC_PLUS_4;
            LOAD:    rf_wr_src_o = MEM;
            SYSTEM:  rf_wr_src_o = CSR;
            default: rf_wr_src_o = ALU; 
        endcase
    end

    //////////////////////////
    // Register Information //
    //////////////////////////
    
    // Determines if RS1 is valid
    assign rs1_valid_o = (opcode != LUI) && 
                         (opcode != AUIPC) && 
                         (opcode != JAL);

    // Determines if RS2 is valid
    assign rs2_valid_o = (opcode == BRANCH) ||
                         (opcode == STORE) ||
                         (opcode == OP);

    // Determines if
    assign rd_valid_o = (opcode != BRANCH) &&
                        (opcode != STORE);

    ////////////////////
    // Memory Control //
    ////////////////////
    assign mem_write_o = (opcode == STORE);
    assign mem_read_o  = (opcode == LOAD);
    assign mem_sign_o  = func3[2];
    assign mem_width_o = func3[1:0];

    ///////////////////////
    // TODO: CSR Control //
    ///////////////////////


    ////////////////////
    // Unused Signals //
    ////////////////////
    logic inst_unused = &{1'b0,
                          inst_i[24:15],
                          inst_i[11:7],
                          1'b0};

    logic func7_unused = &{1'b0,
                           func7[6],
                           func7[4:0],
                           1'b0};
    
endmodule
