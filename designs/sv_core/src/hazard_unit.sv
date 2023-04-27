`timescale 1ns/1ps
`include "pipe_regs.svh"

module hazard_unit (
            input clk_i,
            input rst_ni,

            // Hazard signals
            input          imem_gnt_i,
            input          imem_rvalid_i,
            input          dmem_gnt_i,
            input          dmem_rvalid_i,
            input          dmem_expected_i,
            input pc_src_e pc_src_i,
            input          csr_flush_i,
            input          load_use_stall_i,

            // Stage Controls
            output stage_ctrl_t fetch_ctrl_ao,
            output stage_ctrl_t decode_ctrl_ao,
            output stage_ctrl_t execute_ctrl_ao,
            output stage_ctrl_t memory_ctrl_ao,
            output stage_ctrl_t writeback_ctrl_ao
);
    //////////////////////////
    // Intermediate Signals //
    //////////////////////////

    logic flush_in_progess, imem_stall, dmem_not_ready, dmem_stall, branch;

    assign imem_stall = !(imem_gnt_i && imem_rvalid_i);
    assign dmem_not_ready = !(dmem_gnt_i && dmem_rvalid_i);
    assign dmem_stall = dmem_not_ready && dmem_expected_i;
    assign branch = (pc_src_i != PLUS_4);

    ///////////////////////
    // Output Assignment //
    ///////////////////////

    assign fetch_ctrl_ao.squash = branch;
    assign fetch_ctrl_ao.stall = imem_stall || dmem_stall || flush_in_progess || load_use_stall_i;

    assign decode_ctrl_ao.squash = branch || flush_in_progess;
    assign decode_ctrl_ao.stall = imem_stall || dmem_stall || load_use_stall_i;

    assign execute_ctrl_ao.squash = load_use_stall_i || imem_stall;
    assign execute_ctrl_ao.stall = dmem_stall;

    assign memory_ctrl_ao.squash = '0;
    assign memory_ctrl_ao.stall = dmem_stall;

    assign writeback_ctrl_ao.squash = '0;
    assign writeback_ctrl_ao.stall = dmem_stall;

    ///////////////////
    // CSR Flush FSM //
    ///////////////////

    logic [2:0] PS, NS;

    always_ff @( posedge clk_i or negedge rst_ni ) begin : NS_decoder
        if (!rst_ni) 
            NS <= '0;
        else if (csr_flush_i) 
            NS[1] <= '1;
        else 
            NS <= PS << 1;
        
    end

    always_ff @( posedge clk_i or negedge rst_ni ) begin : PS_reg
        if (!rst_ni)
            PS <= '0;
        else
            PS <= NS;
    end

    always_comb begin : output_decoder
        flush_in_progess = (csr_flush_i || PS != 0);
    end

endmodule // hazard_unit
