`ifndef UART
`define UART

`define UART_REG_CLK_DIV 4'b0000
`define UART_REG_STATUS  4'b0101
`define UART_REG_DATA    4'b1010

module uart (
    input clk,
    input reset,

    input rx_in,
    output wire tx_out,

    input [63:0] address_in,
    input sel_in,
    input read_in,
    output reg [63:0] read_value_out,
    input [3:0] write_mask_in,
    input [63:0] write_value_in
);
    reg [31:0] clk_div;

    reg [31:0] rx_clks;
    reg [7:0] rx_bits;
    reg [15:0] rx_buf;

    reg [15:0] rx_read_buf;
    reg rx_read_ready;

    reg [31:0] tx_clks;
    reg [7:0] tx_bits;
    reg [19:0] tx_buf;

    wire tx_write_ready;

    initial
        tx_buf[0] = 1;

    assign tx_out = tx_buf[0];
    assign tx_write_ready = ~|tx_bits;

    always @* begin
        if (sel_in) begin
            case (address_in[3:2])
                `UART_REG_CLK_DIV: begin
                    read_value_out = {32'b0, clk_div};
                end
                `UART_REG_STATUS: begin
                    read_value_out = {60'b0, rx_read_ready, tx_write_ready};
                end
                `UART_REG_DATA: begin
                    read_value_out = {{48{~rx_read_ready}}, rx_read_ready ? rx_read_buf : 16'b0};
                end
            endcase
        end else begin
            read_value_out = 0;
        end
    end
    always @(posedge clk) begin
        if (sel_in) begin
            case (address_in[3:2])
                `UART_REG_CLK_DIV: begin
                    if (write_mask_in[1])
                        clk_div[31:16] <= write_value_in[31:16];

                    if (write_mask_in[0])
                        clk_div[15:0] <= write_value_in[15:0];
                end
                `UART_REG_DATA: begin
                    if (read_in)
                        rx_read_ready <= 0;

                    if (write_mask_in[0] && !tx_bits) begin
                        tx_clks <= clk_div;
                        tx_bits <= 20;
                        tx_buf <= {1'b1, write_value_in[15:0], 1'b0};
                    end
                end
            endcase
        end

        if (rx_bits) begin
            if (rx_clks) begin
                rx_clks <= rx_clks - 1;
            end else begin
                rx_clks <= clk_div;
                rx_bits <= rx_bits - 1;

                case (rx_bits)
                    20: begin
                        if (rx_in)
                            rx_bits <= 0;
                    end
                    1: begin
                        if (rx_in) begin
                            rx_read_ready <= 1;
                            rx_read_buf <= rx_buf;
                        end
                    end
                endcase
            end
        end else if (!rx_in) begin
            rx_clks <= clk_div[31:1];
            rx_bits <= 20;
        end

        if (tx_bits) begin
            if (tx_clks) begin
                tx_clks <= tx_clks - 1;
            end else begin
                tx_clks <= clk_div;
                tx_bits <= tx_bits - 1;
                tx_buf <= {1'b1, tx_buf[19:1]};
            end
        end

        if (reset) begin
            rx_bits <= 0;

            tx_bits <= 0;
            tx_buf[0] <= 1;
        end
    end
endmodule

`endif
