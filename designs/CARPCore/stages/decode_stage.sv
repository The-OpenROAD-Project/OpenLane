`timescale 1ns/1ps
`include "defs.svh"
`include "pipe_regs.svh"
`include "rvfi.svh"

module decode_stage (

`ifdef RVFI
    input  rvfi_reg_t rvfi_i,
    output rvfi_reg_t rvfi_o,
`endif

    input clk_i,
    input rst_ni,

    // From Instruction Fetch
    input logic         valid_i,
    input fetch_state_t fetch_state_i,
    input [31:0]        inst_i,

    // Stage Control
    input stage_ctrl_t stage_ctrl_i,

    // To Register File
    output logic [4:0] rf_port1_reg_o,
    output logic [4:0] rf_port2_reg_o,

    // From Register File
    input [31:0] rf_rs1_i,
    input [31:0] rf_rs2_i,

    // To Execute
    output logic          valid_o,
    output decode_state_t decode_state_o,
    output reg_meta_t     reg_meta_o
);
    
    ///////////////////
    // Register File //
    ///////////////////
    assign rf_port1_reg_o = inst_i[19:15];
    assign rf_port2_reg_o = inst_i[24:20];


    ///////////////////////////
    // Module Instantiations //
    ///////////////////////////

    // Decoder
    pc_src_e pc_src;
    branch_op_e branch_op;
    alu_op_e    alu_op;
    alu_a_src_e alu_a_src;
    alu_b_src_e alu_b_src;
    logic       rf_wr_en;
    rf_wr_src_e rf_wr_src;
    logic       mem_write, mem_read;
    mem_sign_e  mem_sign;
    mem_width_e mem_width;
    logic rs1_used, rs2_used, rd_used;

    decoder i_decoder (
        .inst_i,

        .pc_src_o   (pc_src),
        .branch_op_o(branch_op),

        .alu_op_o   (alu_op),
        .alu_a_src_o(alu_a_src),
        .alu_b_src_o(alu_b_src),
        
        .rf_wr_en_o (rf_wr_en),
        .rf_wr_src_o(rf_wr_src),
        
        .mem_write_o(mem_write),
        .mem_read_o (mem_read),
        .mem_sign_o (mem_sign),
        .mem_width_o(mem_width),
        
        .rs1_valid_o(rs1_used),
        .rs2_valid_o(rs2_used),
        .rd_valid_o (rd_used)
    );

    // Immediate Generation
    logic [31:0] i_immed, s_immed, b_immed, u_immed, j_immed;

    immed_gen i_immed_gen (
        .inst_i,
        
        .i_immed_o(i_immed),
        .s_immed_o(s_immed),
        .b_immed_o(b_immed),
        .u_immed_o(u_immed),
        .j_immed_o(j_immed)
    );

    //////////////////
    // Decode State //
    //////////////////

    logic [4:0] rd_addr;
    assign rd_addr = inst_i[11:7];

    always_ff @(posedge clk_i or negedge rst_ni) begin 
        if (!rst_ni) begin
            decode_state_o <= '0;
            reg_meta_o     <= '0;
        end else if (!stage_ctrl_i.stall) begin
            // Set validity of stage
            valid_o <= valid_i & ~stage_ctrl_i.squash;

            // Update Decode Stage State
            decode_state_o.pc_src <= pc_src;

            decode_state_o.branch_op <= branch_op;

            decode_state_o.alu_op   <= alu_op;
            decode_state_o.alu_a_src <= alu_a_src;
            decode_state_o.alu_b_src <= alu_b_src;

            decode_state_o.i_immed <= i_immed;
            decode_state_o.s_immed <= s_immed;
            decode_state_o.b_immed <= b_immed;
            decode_state_o.u_immed <= u_immed;
            decode_state_o.j_immed <= j_immed;

            decode_state_o.pc      <= fetch_state_i.pc;
            decode_state_o.next_pc <= fetch_state_i.next_pc;

            decode_state_o.rf_wr_en  <= (rd_addr != '0) && (rf_wr_en != '0);
            decode_state_o.rf_wr_src <= rf_wr_src;

            decode_state_o.mem_read  <= mem_read;
            decode_state_o.mem_write <= mem_write;
            decode_state_o.mem_sign  <= mem_sign;
            decode_state_o.mem_width <= mem_width;


            // Register Metadata
            reg_meta_o.rs1_used <= rs1_used;
            reg_meta_o.rs1      <= inst_i[19:15];
            reg_meta_o.rs1_data <= rf_rs1_i;

            reg_meta_o.rs2_used <= rs2_used;
            reg_meta_o.rs2      <= inst_i[24:20];
            reg_meta_o.rs2_data <= rf_rs2_i;

            reg_meta_o.rd_used <= rd_used;
            reg_meta_o.rd      <= rd_addr;
        end
    end

`ifdef RVFI 
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvfi_o <= '0;
        end else if (!stage_ctrl_i.stall) begin

            // Decode stage modifications to RVFI state
            rvfi_o.insn     <= inst_i;
            rvfi_o.trap     <= 1'b0; // update to trap if illegal instruction
            rvfi_o.halt     <= 1'b0;
            rvfi_o.rs1_addr <= rs1_used ? rf_port1_reg_o : '0;
            rvfi_o.rs2_addr <= rs2_used ? rf_port2_reg_o : '0;

            // Unmodified RVFI signals or signals assigned in later stages
            rvfi_o.intr      <= rvfi_i.intr;

            rvfi_o.rs1_rdata <= rvfi_i.rs1_rdata;
            rvfi_o.rs2_rdata <= rvfi_i.rs2_rdata;

            rvfi_o.pc_rdata  <= rvfi_i.pc_rdata;
            rvfi_o.pc_wdata  <= rvfi_i.pc_wdata;

            rvfi_o.mem_addr  <= rvfi_i.mem_addr;
            rvfi_o.mem_rmask <= rvfi_i.mem_rmask;
            rvfi_o.mem_wmask <= rvfi_i.mem_wmask;
            rvfi_o.mem_rdata <= rvfi_i.mem_rdata;
            rvfi_o.mem_wdata <= rvfi_i.mem_wdata;
        end
    end

`ifdef VERILATOR
    logic _unused;
    assign _unused = &{1'b0, rvfi_i};
`endif
`endif
endmodule
