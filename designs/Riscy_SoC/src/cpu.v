`ifndef CPU
`define CPU

`include "decode.v"
`include "execute.v"
`include "fetch.v"
`include "hazard.v"
`include "mem.v"

module cpu (
    input clk,

    output wire [63:0] instr_address_out,
    output wire instr_read_out,
    input [63:0] instr_read_value_in,
    input instr_ready_in,

    output wire [63:0] data_address_out,
    output wire data_read_out,
    output wire data_write_out,
    input [63:0] data_read_value_in,
    output wire [6:0] data_write_mask_out,
    output wire [63:0] data_write_value_out,
    input data_ready_in,

    output wire [63:0] cycle_out 
);
    reg fetch_stall;
    reg fetch_flush;

    reg decode_stall;
    reg decode_flush;

    reg execute_stall;
    reg execute_flush;

    reg mem_stall;
    reg mem_flush;

    reg fetch_branch_predicted_taken;

    reg [63:0] fetch_pc;
    reg [63:0] fetch_instr;

    reg [8:0] decode_rs1_unreg;
    reg decode_rs1_read_unreg;
    reg [8:0] decode_rs2_unreg;
    reg decode_rs2_read_unreg;
    reg decode_mem_fence_unreg;

    reg decode_branch_predicted_taken;
    reg decode_valid;
    reg [8:0] decode_rs1;
    reg [8:0] decode_rs2;
    reg [4:0] decode_alu_op;
    reg decode_alu_sub_sra;
    reg [2:0] decode_alu_src1;
    reg [2:0] decode_alu_src2;
    reg decode_mem_read;
    reg decode_mem_write;
    reg [2:0] decode_mem_width;
    reg decode_mem_zero_extend;
    reg decode_mem_fence;
    reg decode_csr_read;
    reg decode_csr_write;
    reg [2:0] decode_csr_write_op;
    reg decode_csr_src;
    reg [2:0] decode_branch_op;
    reg decode_branch_pc_src;
    reg [8:0] decode_rd;
    reg decode_rd_write;

    reg [63:0] decode_pc;
    reg [63:0] decode_rs1_value;
    reg [63:0] decode_rs2_value;
    reg [63:0] decode_imm_value;
    reg [23:0] decode_csr;

    reg execute_branch_predicted_taken;
    reg execute_valid;
    reg execute_alu_non_zero;
    reg execute_mem_read;
    reg execute_mem_write;
    reg [2:0] execute_mem_width;
    reg execute_mem_zero_extend;
    reg execute_mem_fence;
    reg [2:0] execute_branch_op;
    reg [8:0] execute_rd;
    reg execute_rd_write;

    reg [63:0] execute_result;
    reg [63:0] execute_rs2_value;
    reg [63:0] execute_branch_pc;

    reg mem_valid;
    reg [8:0] mem_rd;
    reg mem_rd_write;

    reg mem_branch_mispredicted;

    reg [63:0] mem_rd_value;

    reg [63:0] mem_branch_pc;

    hazard_unit hazard_unit (

        .decode_rs1_unreg_in(decode_rs1_unreg),
        .decode_rs1_read_unreg_in(decode_rs1_read_unreg),
        .decode_rs2_unreg_in(decode_rs2_unreg),
        .decode_rs2_read_unreg_in(decode_rs2_read_unreg),
        .decode_mem_fence_unreg_in(decode_mem_fence_unreg),

        .decode_mem_read_in(decode_mem_read),
        .decode_mem_fence_in(decode_mem_fence),
        .decode_rd_in(decode_rd),
        .decode_rd_write_in(decode_rd_write),

        .execute_mem_fence_in(execute_mem_fence),

        .mem_branch_mispredicted_in(mem_branch_mispredicted),

        .instr_read_in(instr_read_out),
        .instr_ready_in(instr_ready_in),

        .data_read_in(data_read_out),
        .data_write_in(data_write_out),
        .data_ready_in(data_ready_in),

        .fetch_stall_out(fetch_stall),
        .fetch_flush_out(fetch_flush),

        .decode_stall_out(decode_stall),
        .decode_flush_out(decode_flush),

        .execute_stall_out(execute_stall),
        .execute_flush_out(execute_flush),

        .mem_stall_out(mem_stall),
        .mem_flush_out(mem_flush)
    );

    fetch fetch (
        .clk(clk),

        .stall_in(fetch_stall),
        .flush_in(fetch_flush),

        .branch_mispredicted_in(mem_branch_mispredicted),

        .instr_read_out(instr_read_out),

        .branch_predicted_taken_out(fetch_branch_predicted_taken),

        .branch_pc_in(mem_branch_pc),

        .instr_read_value_in(instr_read_value_in),

        .pc_out(fetch_pc),
        .instr_out(fetch_instr),

        .instr_address_out(instr_address_out)
    );

    decode decode (
        .clk(clk),

        .stall_in(decode_stall),
        .flush_in(decode_flush),

        .branch_predicted_taken_in(fetch_branch_predicted_taken),

        .rd_in(mem_rd),
        .rd_write_in(mem_rd_write),

        .pc_in(fetch_pc),
        .instr_in(fetch_instr),

        .rd_value_in(mem_rd_value),

        .rs1_unreg_out(decode_rs1_unreg),
        .rs1_read_unreg_out(decode_rs1_read_unreg),
        .rs2_unreg_out(decode_rs2_unreg),
        .rs2_read_unreg_out(decode_rs2_read_unreg),
        .mem_fence_unreg_out(decode_mem_fence_unreg),

        .branch_predicted_taken_out(decode_branch_predicted_taken),
        .valid_out(decode_valid),
        .rs1_out(decode_rs1),
        .rs2_out(decode_rs2),
        .alu_op_out(decode_alu_op),
        .alu_sub_sra_out(decode_alu_sub_sra),
        .alu_src1_out(decode_alu_src1),
        .alu_src2_out(decode_alu_src2),
        .mem_read_out(decode_mem_read),
        .mem_write_out(decode_mem_write),
        .mem_width_out(decode_mem_width),
        .mem_zero_extend_out(decode_mem_zero_extend),
        .mem_fence_out(decode_mem_fence),
        .csr_read_out(decode_csr_read),
        .csr_write_out(decode_csr_write),
        .csr_write_op_out(decode_csr_write_op),
        .csr_src_out(decode_csr_src),
        .branch_op_out(decode_branch_op),
        .branch_pc_src_out(decode_branch_pc_src),
        .rd_out(decode_rd),
        .rd_write_out(decode_rd_write),

        .pc_out(decode_pc),
        .rs1_value_out(decode_rs1_value),
        .rs2_value_out(decode_rs2_value),
        .imm_value_out(decode_imm_value),
        .csr_out(decode_csr)
    );

    execute execute (
        .clk(clk),

        .stall_in(execute_stall),
        .flush_in(execute_flush),

        .branch_predicted_taken_in(decode_branch_predicted_taken),
        .valid_in(decode_valid),
        .rs1_in(decode_rs1),
        .rs2_in(decode_rs2),
        .alu_op_in(decode_alu_op),
        .alu_sub_sra_in(decode_alu_sub_sra),
        .alu_src1_in(decode_alu_src1),
        .alu_src2_in(decode_alu_src2),
        .mem_read_in(decode_mem_read),
        .mem_write_in(decode_mem_write),
        .mem_width_in(decode_mem_width),
        .mem_zero_extend_in(decode_mem_zero_extend),
        .mem_fence_in(decode_mem_fence),
        .csr_read_in(decode_csr_read),
        .csr_write_in(decode_csr_write),
        .csr_write_op_in(decode_csr_write_op),
        .csr_src_in(decode_csr_src),
        .branch_op_in(decode_branch_op),
        .branch_pc_src_in(decode_branch_pc_src),
        .rd_in(decode_rd),
        .rd_write_in(decode_rd_write),

        .writeback_valid_in(mem_valid),
        .writeback_rd_in(mem_rd),
        .writeback_rd_write_in(mem_rd_write),

        .pc_in(decode_pc),
        .rs1_value_in(decode_rs1_value),
        .rs2_value_in(decode_rs2_value),
        .imm_value_in(decode_imm_value),
        .csr_in(decode_csr),

        .writeback_rd_value_in(mem_rd_value),


        .branch_predicted_taken_out(execute_branch_predicted_taken),
        .valid_out(execute_valid),
        .alu_non_zero_out(execute_alu_non_zero),
        .mem_read_out(execute_mem_read),
        .mem_write_out(execute_mem_write),
        .mem_width_out(execute_mem_width),
        .mem_zero_extend_out(execute_mem_zero_extend),
        .mem_fence_out(execute_mem_fence),
        .branch_op_out(execute_branch_op),
        .rd_out(execute_rd),
        .rd_write_out(execute_rd_write),


        .result_out(execute_result),
        .rs2_value_out(execute_rs2_value),
        .branch_pc_out(execute_branch_pc),

        .cycle_out(cycle_out)
    );

    mem mem (
        .clk(clk),

        .stall_in(mem_stall),
        .flush_in(mem_flush),

        .branch_predicted_taken_in(execute_branch_predicted_taken),
        .valid_in(execute_valid),
        .alu_non_zero_in(execute_alu_non_zero),
        .read_in(execute_mem_read),
        .write_in(execute_mem_write),
        .width_in(execute_mem_width),
        .zero_extend_in(execute_mem_zero_extend),
        .branch_op_in(execute_branch_op),
        .rd_in(execute_rd),
        .rd_write_in(execute_rd_write),

        .result_in(execute_result),
        .rs2_value_in(execute_rs2_value),
        .branch_pc_in(execute_branch_pc),

        .data_read_value_in(data_read_value_in),

        .valid_out(mem_valid),
        .branch_mispredicted_out(mem_branch_mispredicted),
        .rd_out(mem_rd),
        .rd_write_out(mem_rd_write),

        .data_read_out(data_read_out),
        .data_write_out(data_write_out),
        .data_write_mask_out(data_write_mask_out),

        .rd_value_out(mem_rd_value),
        .branch_pc_out(mem_branch_pc),

        .data_address_out(data_address_out),
        .data_write_value_out(data_write_value_out)
    );
endmodule

`endif
