`timescale 1ns/1ps
`include "pipe_regs.svh"
`include "defs.svh"

module wb_stage (
    // From Memory Stage
    input               valid_i,
    input mem_state_t   mem_state_i,
    input reg_meta_t    reg_meta_i,

    // Stage Control
    input stage_ctrl_t  stage_ctrl_i,

    // To Forwarding
    output data_fwd_t   data_fwd_oa,
    // To Register File
    output logic        rf_wr_en_oa,
    output logic [4:0]  rf_wr_reg_oa,
    output logic [31:0] rf_wr_data_oa  
);
    logic [31:0] rf_wr_data;

    always_comb begin
        rf_wr_data = '0;
        unique case (mem_state_i.rf_wr_src)
            ALU:          rf_wr_data = mem_state_i.alu_out;
            MEM:          rf_wr_data = mem_state_i.mem_dout;
            CSR:          rf_wr_data = '0;
            PC_PLUS_4:    rf_wr_data = mem_state_i.next_pc;
            default:      rf_wr_data = '0;
        endcase
    end

    assign data_fwd_oa.rf_wr_en = mem_state_i.rf_wr_en;
    assign data_fwd_oa.mem_read = mem_state_i.mem_read;
    assign data_fwd_oa.rd       = reg_meta_i.rd;
    assign data_fwd_oa.rd_data  = rf_wr_data;
    assign data_fwd_oa.valid    = valid_i;
    
    assign rf_wr_reg_oa  = reg_meta_i.rd;
    assign rf_wr_data_oa = rf_wr_data;
    assign rf_wr_en_oa   = mem_state_i.rf_wr_en && valid_i && !stage_ctrl_i.squash
        && !stage_ctrl_i.stall;
    

`ifdef VERILATOR
    wire _unused = &{1'b0, mem_state_i.mem_sign, mem_state_i.mem_width, reg_meta_i[81:5]};
`endif

endmodule

