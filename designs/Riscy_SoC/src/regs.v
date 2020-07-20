`ifndef REGS
`define REGS

module regs (
    input clk,
    input stall_in,

    input [8:0] rs1_in,
    input [8:0] rs2_in,
    input [8:0] rd_in,
    input rd_write_in,

    input [63:0] rd_value_in,

    output reg [63:0] rs1_value_out,
    output reg [63:0] rs2_value_out
);
    reg [63:0] regs [63:0];

    generate
        genvar i;
        for (i = 0; i < 64; i = i+1) begin
            initial
                regs[i] <= 0;
        end
    endgenerate

    always @(posedge clk) begin
        if (!stall_in) begin
            rs1_value_out <= regs[rs1_in];
            rs2_value_out <= regs[rs2_in];
        end

        if (rd_write_in && |rd_in)
            regs[rd_in] <= rd_value_in;
    end
endmodule

`endif
