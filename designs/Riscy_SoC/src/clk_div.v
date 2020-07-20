`ifndef CLK_DIV
`define CLK_DIV

module clk_div #(
    parameter LOG_DIVISOR = 1
) (
    input clk_in,
    output wire clk_out
);
    reg [LOG_DIVISOR-1:0] q;

    always @(posedge clk_in)
        q <= q + 1;

    assign clk_out = q[LOG_DIVISOR-1];
endmodule

`endif
