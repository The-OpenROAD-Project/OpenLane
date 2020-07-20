`include "defines.v"
`include "bus_arbiter.v"
`include "ram.v"
`include "cpu.v"
`include "sync.v"
`include "timer.v"
`include "uart.v"

module Riscy_SoC (
`ifndef INTERNAL_OSC
    input clk,
`endif


    output [15:0] leds,

    input uart_rx,
    output uart_tx
);


`ifdef INTERNAL_OSC
    reg clk;
    SB_HFOSC inthosc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
`endif

    sync sync (
        .clk(pll_clk),
        .in(pll_locked_async),
        .out(pll_locked)
    );

    reg [63:0] instr_address;
    reg instr_read;
    reg [63:0] instr_read_value;
    reg instr_ready;

    reg[63:0] data_address;
    reg data_read;
    reg data_write;
    reg [63:0] data_read_value;
    reg [3:0] data_write_mask;
    reg [63:0] data_write_value;
    reg data_ready;

    reg [63:0] mem_address;
    wire mem_read;
    reg mem_write;
    wire [63:0] mem_read_value;
    reg [3:0] mem_write_mask;
    reg [63:0] mem_write_value;

    assign mem_read_value = ram_read_value | leds_read_value | uart_read_value | timer_read_value;

    bus_arbiter bus_arbiter (
        .instr_address_in(instr_address),
        .instr_read_in(instr_read),
        .instr_read_value_out(instr_read_value),
        .instr_ready(instr_ready),

        .data_address_in(data_address),
        .data_read_in(data_read),
        .data_write_in(data_write),
        .data_read_value_out(data_read_value),
        .data_write_mask_in(data_write_mask),
        .data_write_value_in(data_write_value),
        .data_ready(data_ready),

        .address_out(mem_address),
        .read_out(mem_read),
        .write_out(mem_write),
        .read_value_in(mem_read_value),
        .write_mask_out(mem_write_mask),
        .write_value_out(mem_write_value)
    );

    reg [63:0] cycle;

    cpu cpu (
        .clk(pll_clk),

        .instr_address_out(instr_address),
        .instr_read_out(instr_read),
        .instr_read_value_in(instr_read_value),
        .instr_ready_in(instr_ready),

        .data_address_out(data_address),
        .data_read_out(data_read),
        .data_write_out(data_write),
        .data_read_value_in(data_read_value),
        .data_write_mask_out(data_write_mask),
        .data_write_value_out(data_write_value),
        .data_ready_in(data_ready),

        .cycle_out(cycle)
    );

    reg ram_sel;
    reg leds_sel;
    reg uart_sel;
    reg timer_sel;

    always @* begin
        ram_sel = 0;
        leds_sel = 0;
        uart_sel = 0;
        timer_sel = 0;

        casez (mem_address)
            64'b00000000_00000000_????????_????????: ram_sel = 1;
            64'b00000000_00000001_00000000_000000??: leds_sel = 1;
            64'b00000000_00000010_00000000_0000????: uart_sel = 1;
            64'b00000000_00000011_00000000_0000????: timer_sel = 1;
        endcase
    end


    ram ram (
        .clk(pll_clk),

        .address_in(mem_address),
        .sel_in(ram_sel),
        .read_value_out(ram_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value)
    );

    wire [63:0] leds_read_value;

    assign leds_read_value = {44'b0, leds_sel ? leds : 16'b0};

    always @(posedge pll_clk) begin
        if (leds_sel && mem_write_mask[0])
            leds <= mem_write_value[15:0];
    end

    reg [63:0] uart_read_value;

    uart uart (
        .clk(pll_clk),
        .reset(reset),

        .rx_in(uart_rx),
        .tx_out(uart_tx),

        .address_in(mem_address),
        .sel_in(uart_sel),
        .read_in(mem_read),
        .read_value_out(uart_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value)
    );

    reg [63:0] timer_read_value;

    timer timer (
        .clk(pll_clk),

        .cycle_in(cycle),

        .address_in(mem_address),
        .sel_in(timer_sel),
        .read_in(mem_read),
        .read_value_out(timer_read_value),
        .write_mask_in(mem_write_mask),
        .write_value_in(mem_write_value)
    );
endmodule
