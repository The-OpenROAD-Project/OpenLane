`timescale 1ns/1ps
// CARP test memory
// Adapted from "bytewrite_tdp_ram_rf.v"

module test_memory #(
    //----------------------------------------------------------------------
    parameter NUM_COL = 4,
    parameter COL_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    // Addr Width in bits: 2*ADDR_WIDTH = RAM Depth
    parameter DATA_WIDTH = NUM_COL*COL_WIDTH // Data Width in bits
    //----------------------------------------------------------------------
) (
    input                       clk_i,
    input                       pA_en_i,
    input [NUM_COL-1:0]         pA_strobe_i,
    input [ADDR_WIDTH-1:0]      pA_addr_i,
    input [DATA_WIDTH-1:0]      pA_data_i,

    input                       pB_en_i,
    input [NUM_COL-1:0]         pB_strobe_i,
    input [ADDR_WIDTH-1:0]      pB_addr_i,
    input [DATA_WIDTH-1:0]      pB_data_i,

    output reg [DATA_WIDTH-1:0] pA_data_o,
    output reg [DATA_WIDTH-1:0] pB_data_o
);

// Core Memory
//reg [DATA_WIDTH-1:0] ram_block [(2**ADDR_WIDTH)-1:0];

(* rom_style="{distributed | block}" *) 
(* ram_decomp = "power" *) logic [DATA_WIDTH-1:0] ram_block [0:2**ADDR_WIDTH-1];

initial begin
    $readmemh("carp_memory.mem", ram_block, 0, 2**ADDR_WIDTH-1);
end 

integer i;

// Port-A Operation
always @(posedge clk_i) begin
    if (pA_en_i) begin
        for (i=0; i<NUM_COL; i=i+1) begin
            if (pA_strobe_i[i]) begin
                ram_block[pA_addr_i][i*COL_WIDTH +: COL_WIDTH] <= pA_data_i[i*COL_WIDTH +: COL_WIDTH];
            end
        end
        pA_data_o <= ram_block[pA_addr_i];
    end
end

// Port-B Operation:
always @(posedge clk_i) begin
    if (pB_en_i) begin
        for (i=0; i<NUM_COL; i=i+1) begin
            if (pB_strobe_i[i]) begin
                ram_block[pB_addr_i][i*COL_WIDTH +: COL_WIDTH] <= pB_data_i[i*COL_WIDTH +: COL_WIDTH];
            end
        end
        pB_data_o <= ram_block[pB_addr_i];
    end
end

endmodule // bytewrite_tdp_ram_rf
