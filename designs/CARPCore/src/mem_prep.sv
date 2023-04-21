`timescale 1ns/1ps
`include "defs.svh"

module mem_prep (
    input mem_width_e   mem_width_i,
    input [31:0]        mem_data_i,
    input [31:0]        mem_addr_i,
    input               mem_read_i,
    input               mem_write_i,

    output logic [31:0] mem_word_addr_ao,
    output logic [31:0] mem_write_data_ao,
    output logic [3:0]  mem_strobe_ao,
    output logic        mem_illegal_ao
);

    logic illegal_addr;

    mem_width_e  pre_width;
    logic [31:0] pre_write_data; // Write data as provided by the pipeline

    logic [1:0]  req_byte_idx;
    logic [3:0]  req_strobe;;
    logic [31:0] req_write_data; // Processed data for the memory interface request

    assign pre_width        = mem_width_i;
    assign pre_write_data   = mem_data_i;

    // Round to word boundary
    assign req_byte_idx      = mem_addr_i[1:0];

    // Output signals
    assign mem_word_addr_ao  = {mem_addr_i[31:2], 2'b0};
    assign mem_write_data_ao = req_write_data;
    assign mem_strobe_ao     = mem_write_i ? req_strobe : 4'b0;

    assign mem_illegal_ao = (
        illegal_addr && 
        (mem_read_i || mem_write_i)
    );

    // Calculate the strobe value depending on the byte index
    always_comb begin
        illegal_addr   = 0;
        req_strobe     = 4'b0;
        req_write_data = pre_write_data;

        case (pre_width)
            BYTE: begin
                req_write_data = {4{pre_write_data[7:0]}}; // 4 copies of byte
                req_strobe     = 4'b0001 << req_byte_idx;
            end
            HALF: begin 
                
                req_write_data = {2{pre_write_data[15:0]}}; // 2 copies of half
                // Unaligned halfword is not supported
                illegal_addr   = req_byte_idx[0];
                req_strobe     = illegal_addr ? 4'b0 : 4'b0011 << req_byte_idx;
            end
            WORD: begin 
                req_write_data = pre_write_data;
                // Unaligned word is not supported
                illegal_addr   = req_byte_idx != 2'b00;
                req_strobe     = illegal_addr ? 4'b0 : 4'b1111;
            end
            default: illegal_addr = 1;
        endcase
    end

endmodule
