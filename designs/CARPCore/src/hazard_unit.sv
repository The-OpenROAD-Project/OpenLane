`timescale 1ns/1ps
`include "pipe_regs.svh"

module hazard_unit #(parameter DEPTH = 5,       // number of pipeline stages
                     parameter BC_STAGE = 2,    // index of branch control stage
                     parameter EX_STAGE = 2) (  // index of execute stage
            input clk_i,
            input rst_ni,

            // Hazard signals
            input          imem_gnt_i,
            input          imem_rvalid_i,
            input          dmem_gnt_i,
            input          dmem_rvalid_i,
            input pc_src_e pc_src_i,
            input          csr_mret_i,
            input          csr_flush_i,
            input          load_use_stall_i,

            // Stage Controls
            output stage_ctrl_t[4:0] stage_ctrl_ao
);
    logic [DEPTH-1:0] flush_mask;
    logic [DEPTH-1:0] next_flush_mask;
    logic [DEPTH-1:0] pre_mask_stall;
    logic start_flush;

    always_comb begin
        // Initial assignments
        start_flush = '0;
        for (int i = 0; i < DEPTH; i = i + 1) begin
            pre_mask_stall[i] = '0;
            stage_ctrl_ao[i].stall = '0;
            stage_ctrl_ao[i].squash = '0;
        end
        
        // Control Hazard: Squash all stages prior to branch control stage
        if (pc_src_i != PLUS_4 || csr_mret_i) begin
            for (int i = 0; i < BC_STAGE; i = i + 1)
                stage_ctrl_ao[i].squash = 'b1;
        end

        // Load-Use: Stall All stages up to (and including) execute and squash execute
        if (load_use_stall_i) begin
            for (int i = 0; i < EX_STAGE + 1; i = i + 1)
                pre_mask_stall[i] = 'b1;
            
            stage_ctrl_ao[EX_STAGE].squash = 'b1;
        end

        // Interrupt: Flush all stages up to execute (handled in synchronous block)
        if (csr_flush_i) begin
            pre_mask_stall[0] = 'b1;
            start_flush = 'b1;
        end

        // OR the stall signals with the flush mask
        for (int i = 0; i < EX_STAGE + 1; i = i + 1)
            stage_ctrl_ao[i].stall = flush_mask[i] | pre_mask_stall[i];

        // dmem Memory Miss: stall whole pipeline
        if (!dmem_gnt_i || dmem_rvalid_i) begin
            for (int i = 0; i < DEPTH; i = i + 1)
                 stage_ctrl_ao[i].stall = 'b1;
        end

        // imem Memory Miss: Stall all stages before execute and squash prior stage
        if (!imem_gnt_i || !imem_rvalid_i) begin
            for (int i = 0; i < EX_STAGE; i = i + 1)
                pre_mask_stall[i] = 'b1;
            
            stage_ctrl_ao[EX_STAGE-1].squash = 'b1;
        end

    end

    //////////////////////////////
    // Interrupt flushing logic //
    //////////////////////////////

    assign next_flush_mask[DEPTH-1:1] = flush_mask[DEPTH-2:0];
    assign next_flush_mask[0] = flush_mask[0];

    always_ff @(posedge clk_i or negedge rst_ni) begin

        // If flush mask has passed execute, clear flush mask
        if (!rst_ni) begin
            flush_mask <= 'b0;
        end else if (flush_mask[EX_STAGE + 1] == 1'b1) begin
            flush_mask <= 'b0;
        end else if(start_flush) begin
            flush_mask[0] <= 1'b1;
        end else begin
            flush_mask <= next_flush_mask;
        end
        // This logic assumes we cannot be interrupted again during a flush!
    end

endmodule // hazard_unit
