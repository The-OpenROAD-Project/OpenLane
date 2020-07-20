`ifndef BUS_ARBITER
`define BUS_ARBITER

module bus_arbiter (
    input [63:0] instr_address_in,
    input instr_read_in,
    output reg [63:0] instr_read_value_out,
    output reg instr_ready,
    input [63:0] data_address_in,
    input data_read_in,
    input data_write_in,
    output reg [63:0] data_read_value_out,
    input [7:0] data_write_mask_in,
    input [63:0] data_write_value_in,
    output reg data_ready,
    output reg [63:0] address_out,
    output reg read_out,
    output reg write_out,
    input [63:0] read_value_in,
    output reg [7:0] write_mask_out,
    output reg [63:0] write_value_out
);
    always @* begin
        if (data_read_in || data_write_in) begin
            address_out = data_address_in;
            read_out = data_read_in;
            write_out = data_write_in;
            instr_read_value_out = 64'bx;
            data_read_value_out = read_value_in;
            write_mask_out = data_write_mask_in;
            write_value_out = data_write_value_in;
            instr_ready = 1'b0;
            data_ready = 1'b1;
        end else if (instr_read_in) begin
            address_out = instr_address_in;
            read_out = instr_read_in;
            write_out = 1'b0;
            instr_read_value_out = read_value_in;
            data_read_value_out = 64'bx;
            write_mask_out = 8'b0;
            write_value_out = 64'bx;
            instr_ready = 1'b1;
            data_ready = 1'b0;
        end else begin
            address_out = 64'bx;
            read_out = 1'b0;
            write_out = 1'b0;
            instr_read_value_out = 64'bx;
            data_read_value_out = 64'bx;
            write_mask_out = 8'b0;
            write_value_out = 64'bx;
            instr_ready = 1'b0;
            data_ready = 1'b0;
        end
    end
endmodule

`endif
