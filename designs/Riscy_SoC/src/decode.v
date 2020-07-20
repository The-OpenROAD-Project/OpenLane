`ifndef DECODE
`define DECODE

`include "control_unit.v"
`include "regs.v"

module decode (
    input clk,

    input stall_in,
    input flush_in,

    input branch_predicted_taken_in,

    input [8:0] rd_in,
    input rd_write_in,

    input [63:0] pc_in,
    input [63:0] instr_in,

    input [63:0] rd_value_in,

    output wire [8:0] rs1_unreg_out,
    output wire rs1_read_unreg_out,
    output wire [8:0] rs2_unreg_out,
    output wire rs2_read_unreg_out,
    output wire mem_fence_unreg_out,

    output reg branch_predicted_taken_out,
    output reg valid_out,
    output reg [8:0] rs1_out,
    output reg [8:0] rs2_out,
    output reg [4:0] alu_op_out,
    output reg alu_sub_sra_out,
    output reg [2:0] alu_src1_out,
    output reg [2:0] alu_src2_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [2:0] mem_width_out,
    output reg mem_zero_extend_out,
    output reg mem_fence_out,
    output reg csr_read_out,
    output reg csr_write_out,
    output reg [2:0] csr_write_op_out,
    output reg csr_src_out,
    output reg [2:0] branch_op_out,
    output reg branch_pc_src_out,
    output reg [8:0] rd_out,
    output reg rd_write_out,

    output reg [63:0] pc_out,
    output reg [63:0] rs1_value_out,
    output reg [63:0] rs2_value_out,
    output reg [63:0] imm_value_out,
    output reg [23:0] csr_out
);
    wire [8:0] rs2;
    wire [8:0] rs1;
    wire [8:0] rd;

    assign rs2 = instr_in[48:40];
    assign rs1 = instr_in[39:31];
    assign rd  = instr_in[23:15];

    assign rs1_unreg_out = rs1;
    assign rs2_unreg_out = rs2;

    regs regs (
        .clk(clk),
        .stall_in(stall_in),

        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd_in),
        .rd_write_in(rd_write_in),

        .rd_value_in(rd_value_in),

        .rs1_value_out(rs1_value_out),
        .rs2_value_out(rs2_value_out)
    );

    reg valid;
    wire rs1_read;
    wire rs2_read;
    reg [4:0] imm;
    reg [4:0] alu_op;
    reg alu_sub_sra;
    reg [2:0] alu_src1;
    reg [2:0] alu_src2;
    reg mem_read;
    reg mem_write;
    reg [2:0] mem_width;
    reg mem_zero_extend;
    wire mem_fence;
    reg csr_read;
    reg csr_write;
    reg [2:0] csr_write_op;
    reg csr_src;
    reg [2:0] branch_op;
    reg branch_pc_src;
    reg rd_write;

    assign rs1_read_unreg_out = rs1_read;
    assign rs2_read_unreg_out = rs2_read;
    assign mem_fence_unreg_out = mem_fence;

    control_unit control_unit (

        .instr_in(instr_in),

        .rs1_in(rs1),
        .rd_in(rd),

        .valid_out(valid),
        .rs1_read_out(rs1_read),
        .rs2_read_out(rs2_read),
        .imm_out(imm),
        .alu_op_out(alu_op),
        .alu_sub_sra_out(alu_sub_sra),
        .alu_src1_out(alu_src1),
        .alu_src2_out(alu_src2),
        .mem_read_out(mem_read),
        .mem_write_out(mem_write),
        .mem_width_out(mem_width),
        .mem_zero_extend_out(mem_zero_extend),
        .mem_fence_out(mem_fence),
        .csr_read_out(csr_read),
        .csr_write_out(csr_write),
        .csr_write_op_out(csr_write_op),
        .csr_src_out(csr_src),
        .branch_op_out(branch_op),
        .branch_pc_src_out(branch_pc_src),
        .rd_write_out(rd_write)
    );

    reg [63:0] imm_value;

    imm_mux imm_mux (

        .imm_in(imm),

        .instr_in(instr_in),

        .imm_value_out(imm_value)
    );

    wire [23:0] csr;

    assign csr = instr_in[63:40];

    always @(posedge clk) begin
        if (!stall_in) begin
            branch_predicted_taken_out <= branch_predicted_taken_in;
            valid_out <= valid;
            rs1_out <= rs1;
            rs2_out <= rs2;
            alu_op_out <= alu_op;
            alu_sub_sra_out <= alu_sub_sra;
            alu_src1_out <= alu_src1;
            alu_src2_out <= alu_src2;
            mem_read_out <= mem_read;
            mem_write_out <= mem_write;
            mem_width_out <= mem_width;
            mem_zero_extend_out <= mem_zero_extend;
            mem_fence_out <= mem_fence;
            csr_read_out <= csr_read;
            csr_write_out <= csr_write;
            csr_write_op_out <= csr_write_op;
            csr_src_out <= csr_src;
            branch_op_out <= branch_op;
            branch_pc_src_out <= branch_pc_src;
            rd_out <= rd;
            rd_write_out <= rd_write;

            pc_out <= pc_in;
            imm_value_out <= imm_value;
            csr_out <= csr;

            if (flush_in) begin
                valid_out <= 0;
                mem_read_out <= 0;
                mem_write_out <= 0;
                csr_read_out <= 0;
                csr_write_out <= 0;
                branch_op_out <= 0;
                rd_write_out <= 0;
            end
        end
    end
endmodule

`endif
