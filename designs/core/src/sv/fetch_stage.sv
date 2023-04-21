`timescale 1ns/1ps
`include "defs.svh"
`include "pipe_regs.svh"
`include "rvfi.svh"

module fetch_stage (

`ifdef RVFI
    output rvfi_reg_t rvfi_o,
`endif

    input clk_i,
    input rst_ni,

    input target_sel_i,
    input [31:0] target_addr_i,

    // Stage Control
    input stage_ctrl_t stage_ctrl_i,

    // Basic Memory Interface (Read-only)
    output logic        mem_rd_o,
    output logic [31:0] mem_addr_o,
    input  logic        mem_gnt_i,
    
    // To Decode
    output logic         valid_o, 
    output fetch_state_t fetch_state_o
);

    //PC Signals
    logic pc_ld;
    logic [31:0] pc_data, pc_out, pc_plus_4;
    
    assign pc_ld = ~stage_ctrl_i.stall & mem_gnt_i;
    assign pc_plus_4 = pc_out + 4;

    // PC Data MUX
    always_comb begin
        unique case (target_sel_i)
            PLUS_4: pc_data = pc_plus_4;
            TARGET: pc_data = target_addr_i;
            default: pc_data = pc_plus_4;
        endcase
    end

    prog_cntr i_prog_cntr (
        .clk_i,
        .rst_ni,

        .ld_i  (pc_ld),
        .data_i(pc_data),

        .count_o(pc_out)
    );

    // Memory Interface
    assign mem_addr_o = pc_out;
    assign mem_rd_o = ~stage_ctrl_i.stall;
    

    /////////////////
    // Fetch State //
    /////////////////
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            valid_o                 <= '0;
            fetch_state_o.pc        <= '0;
            fetch_state_o.next_pc   <= '0;
        end else if (!stage_ctrl_i.stall) begin
            valid_o                 <= ~stage_ctrl_i.squash && mem_gnt_i;
            fetch_state_o.pc        <= pc_out;
            fetch_state_o.next_pc   <= pc_plus_4;
        end
    end

`ifdef RVFI
    // rvfi_intr support:
    // Register when next PC is an interrupt vector, 
    // Next PC is MTVEC  --> dff --> dff --> rvfi_o.intr
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvfi_o <= '0;
        end else if (!stage_ctrl_i.stall) begin
            rvfi_o.pc_rdata <= pc_out;
            rvfi_o.pc_wdata <= pc_data;
            rvfi_o.intr     <= '0; // TODO: interrupts

        end
    end
`endif

endmodule
