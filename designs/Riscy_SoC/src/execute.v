`ifndef EXECUTE
`define EXECUTE

`include "alu.v"
`include "branch.v"
`include "csrs.v"

module execute (
    input clk,

    input stall_in,
    input flush_in,

    input branch_predicted_taken_in,
    input valid_in,
    input [8:0] rs1_in,
    input [8:0] rs2_in,
    input [4:0] alu_op_in,
    input alu_sub_sra_in,
    input [2:0] alu_src1_in,
    input [2:0] alu_src2_in,
    input mem_read_in,
    input mem_write_in,
    input [2:0] mem_width_in,
    input mem_zero_extend_in,
    input mem_fence_in,
    input csr_read_in,
    input csr_write_in,
    input [2:0] csr_write_op_in,
    input csr_src_in,
    input [2:0] branch_op_in,
    input branch_pc_src_in,
    input [8:0] rd_in,
    input rd_write_in,

    input writeback_valid_in,
    input [8:0] writeback_rd_in,
    input writeback_rd_write_in,

    input [63:0] pc_in,
    input [63:0] rs1_value_in,
    input [63:0] rs2_value_in,
    input [63:0] imm_value_in,
    input [23:0] csr_in,

    input [63:0] writeback_rd_value_in,

    output reg branch_predicted_taken_out,
    output reg valid_out,
    output reg alu_non_zero_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [2:0] mem_width_out,
    output reg mem_zero_extend_out,
    output reg mem_fence_out,
    output reg [2:0] branch_op_out,
    output reg [8:0] rd_out,
    output reg rd_write_out,

    output reg [63:0] result_out,
    output reg [63:0] rs2_value_out,
    output reg [63:0] branch_pc_out,

    output reg [63:0] cycle_out
);
    reg [63:0] rs1_value;
    reg [63:0] rs2_value;

    always @* begin
        if (rd_write_out && rd_out == rs1_in && |rs1_in)
            rs1_value = result_out;
        else if (writeback_rd_write_in && writeback_rd_in == rs1_in && |rs1_in)
            rs1_value = writeback_rd_value_in;
        else
            rs1_value = rs1_value_in;

        if (rd_write_out && rd_out == rs2_in && |rs2_in)
            rs2_value = result_out;
        else if (writeback_rd_write_in && writeback_rd_in == rs2_in && |rs2_in)
            rs2_value = writeback_rd_value_in;
        else
            rs2_value = rs2_value_in;
    end

    reg alu_non_zero;
    reg [63:0] alu_result;

    alu alu (
        .op_in(alu_op_in),
        .sub_sra_in(alu_sub_sra_in),
        .src1_in(alu_src1_in),
        .src2_in(alu_src2_in),

        .pc_in(pc_in),
        .rs1_value_in(rs1_value),
        .rs2_value_in(rs2_value),
        .imm_value_in(imm_value_in),

        .non_zero_out(alu_non_zero),

        .result_out(alu_result)
    );

    reg [63:0] csr_read_value;
    reg [63:0] cycle;

    csrs csrs (
        .clk(clk),
        .stall_in(stall_in),

        .read_in(csr_read_in),
        .write_in(csr_write_in),
        .write_op_in(csr_write_op_in),
        .src_in(csr_src_in),

        .instr_retired_in(writeback_valid_in),

        .rs1_value_in(rs1_value),
        .imm_value_in(imm_value_in),
        .csr_in(csr_in),

        .read_value_out(csr_read_value),

        .cycle_out(cycle_out)
    );

    reg [63:0] branch_pc;

    branch_pc_mux branch_pc_mux (
        .pc_src_in(branch_pc_src_in),

        .pc_in(pc_in),
        .rs1_value_in(rs1_value),
        .imm_value_in(imm_value_in),

        .pc_out(branch_pc)
    );

    always @(posedge clk) begin
        if (!stall_in) begin
            branch_predicted_taken_out <= branch_predicted_taken_in;
            valid_out <= valid_in;
            alu_non_zero_out <= alu_non_zero;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_width_out <= mem_width_in;
            mem_zero_extend_out <= mem_zero_extend_in;
            mem_fence_out <= mem_fence_in;
            branch_op_out <= branch_op_in;
            rd_out <= rd_in;
            rd_write_out <= rd_write_in;
            rs2_value_out <= rs2_value;
            branch_pc_out <= branch_pc;

            if (csr_read_in)
                result_out <= csr_read_value;
            else
                result_out <= alu_result;

            if (flush_in) begin
                valid_out <= 0;
                mem_read_out <= 0;
                mem_write_out <= 0;
                branch_op_out <= 0;
                rd_write_out <= 0;
            end
        end
    end
endmodule

`endif
