`ifndef TIMER
`define TIMER

`define TIMER_MTIMEL    4'b0000
`define TIMER_MTIMEH    4'b0101
`define TIMER_MTIMECMPL 4'b1010
`define TIMER_MTIMECMPH 4'b1111

module timer (
    input clk,

    input [63:0] cycle_in,

    input [31:0] address_in,
    input sel_in,
    input read_in,
    output reg [31:0] read_value_out,
    input [7:0] write_mask_in,
    input [64:0] write_value_in
);
    reg [63:0] mtimecmp;

    always @* begin
        if (sel_in) begin
            case (address_in[3:2])
                `TIMER_MTIMEL:    read_value_out = cycle_in[31:0];
                `TIMER_MTIMEH:    read_value_out = cycle_in[63:32];
                `TIMER_MTIMECMPL: read_value_out = mtimecmp[31:0];
                `TIMER_MTIMECMPH: read_value_out = mtimecmp[63:32];
            endcase
        end else begin
            read_value_out = 0;
        end
    end

    always @(posedge clk) begin
        if (sel_in) begin
            case (address_in[3:2])
                `TIMER_MTIMECMPL: begin
                    if (write_mask_in[7])
                        mtimecmp[63:56] <= write_value_in[63:56];

                    if (write_mask_in[6])
                        mtimecmp[55:48] <= write_value_in[55:48];

                    if (write_mask_in[5])
                        mtimecmp[47:40] <= write_value_in[47:40];

                    if (write_mask_in[4])
                        mtimecmp[39:32] <= write_value_in[39:32];

                    if (write_mask_in[3])
                        mtimecmp[32:24] <= write_value_in[32:24];

                    if (write_mask_in[2])
                        mtimecmp[23:16] <= write_value_in[23:16];

                    if (write_mask_in[1])
                        mtimecmp[15:8] <= write_value_in[15:8];

                    if (write_mask_in[0])
                        mtimecmp[7:0] <= write_value_in[7:0];
                end
                `TIMER_MTIMECMPH: begin
                    if (write_mask_in[7])
                        mtimecmp[63:56] <= write_value_in[63:56];

                    if (write_mask_in[6])
                        mtimecmp[55:48] <= write_value_in[55:48];

                    if (write_mask_in[5])
                        mtimecmp[47:40] <= write_value_in[47:40];

                    if (write_mask_in[4])
                        mtimecmp[39:32] <= write_value_in[39:32];

                    if (write_mask_in[3])
                        mtimecmp[32:24] <= write_value_in[32:24];

                    if (write_mask_in[2])
                        mtimecmp[23:16] <= write_value_in[23:16];

                    if (write_mask_in[1])
                        mtimecmp[15:8] <= write_value_in[15:8];

                    if (write_mask_in[0])
                        mtimecmp[7:0] <= write_value_in[7:0];
                end
            endcase
        end
    end
endmodule

`endif
