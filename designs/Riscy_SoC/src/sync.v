`ifndef SYNC
`define SYNC

module sync #(
    parameter BITS = 1
) (
    input clk,
    input [BITS-1:0] in,
    output reg [BITS-1:0] out
);
    reg [BITS-1:0] metastable;

    always @(posedge clk) begin
        metastable <= in;
        out <= metastable;
    end
endmodule

`endif
