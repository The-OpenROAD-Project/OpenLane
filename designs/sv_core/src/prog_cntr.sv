`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Callenes
//
// Create Date: 06/07/2018 04:21:54 PM
// Design Name:
// Module Name: ProgCount
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

module prog_cntr (
    input clk_i,
    input rst_ni,
`ifdef FAILSAFE
    input boot_i, // Failsafe (Start at 0x8000_0000 at reset)
`endif

    input         ld_i,
    input [31:0]  data_i,

    output logic [31:0] count_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
`ifdef FAILSAFE
            count_o <= boot_i ? 32'h80000000 : '0;
`else
            count_o <= '0;
`endif
        else if (ld_i)
            count_o <= data_i;
    end

endmodule
