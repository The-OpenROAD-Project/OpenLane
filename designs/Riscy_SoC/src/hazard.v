`ifndef HAZARD
`define HAZARD

module hazard_unit (
    
    input [8:0] decode_rs1_unreg_in,
    input decode_rs1_read_unreg_in,
    input [8:0] decode_rs2_unreg_in,
    input decode_rs2_read_unreg_in,
    input decode_mem_fence_unreg_in,

    input decode_mem_read_in,
    input decode_mem_fence_in,
    input [8:0] decode_rd_in,
    input decode_rd_write_in,

    input execute_mem_fence_in,

    input mem_branch_mispredicted_in,

    input instr_read_in,
    input instr_ready_in,

    input data_read_in,
    input data_write_in,
    input data_ready_in,

    output wire fetch_stall_out,
    output wire fetch_flush_out,

    output wire decode_stall_out,
    output wire decode_flush_out,

    output wire execute_stall_out,
    output wire execute_flush_out,

    output wire mem_stall_out,
    output wire mem_flush_out
);
    wire rs1_matches;
    wire rs2_matches;
    wire fetch_wait_for_bus;
    wire fetch_wait_for_mem_read;
    wire fetch_wait_for_mem_fence;
    wire mem_wait_for_bus;

    assign rs1_matches = decode_rs1_unreg_in == decode_rd_in && decode_rs1_read_unreg_in;
    assign rs2_matches = decode_rs2_unreg_in == decode_rd_in && decode_rs2_read_unreg_in;
    assign fetch_wait_for_bus = instr_read_in && !instr_ready_in;
    assign fetch_wait_for_mem_read = (rs1_matches || rs2_matches) && |decode_rd_in && decode_mem_read_in && decode_rd_write_in;
    assign fetch_wait_for_mem_fence = decode_mem_fence_unreg_in || decode_mem_fence_in || execute_mem_fence_in;
    assign mem_wait_for_bus = (data_read_in || data_write_in) && !data_ready_in;

    assign fetch_stall_out = decode_stall_out || fetch_wait_for_mem_read || fetch_wait_for_bus;
    assign fetch_flush_out = 0;

    assign decode_stall_out = execute_stall_out;
    assign decode_flush_out = fetch_stall_out || mem_branch_mispredicted_in;

    assign execute_stall_out = mem_stall_out;
    assign execute_flush_out = decode_stall_out || mem_branch_mispredicted_in;

    assign mem_stall_out = mem_wait_for_bus;
    assign mem_flush_out = execute_stall_out;
endmodule

`endif
