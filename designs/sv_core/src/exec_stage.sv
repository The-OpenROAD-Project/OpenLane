`timescale 1ns/1ps
`include "defs.svh"
`include "pipe_regs.svh"
`include "rvfi.svh"

module exec_stage (

`ifdef RVFI
    input  rvfi_reg_t rvfi_i,
    output rvfi_reg_t rvfi_o,
`endif

    input clk_i,
    input rst_ni,

    // From Decode
    input                valid_i,
    input decode_state_t decode_state_i,
    input reg_meta_t     reg_meta_i,

    // Stage Control
    input stage_ctrl_t stage_ctrl_i,

    // To Forwarding
    output data_fwd_t data_fwd_o,

    // To Program Counter
    output logic        target_sel_o,
    output logic [31:0] target_addr_o,

    // To Memory Stage
    output logic        valid_o,
    output exec_state_t exec_state_o,
    output reg_meta_t   reg_meta_o,

    // Memory Access
    output logic        mem_read_ao,
    output logic        mem_write_ao,
    output logic [3:0]  mem_strb_ao,
    output logic [31:0] mem_addr_ao,
    output logic [31:0] mem_data_ao
);
    /////////
    // ALU //
    /////////
    // ALU A Source MUX
    logic [31:0] alu_a_in;
    always_comb begin
        unique case (decode_state_i.alu_a_src)
            RS1:     alu_a_in = reg_meta_i.rs1_data;
            U_IMMED: alu_a_in = decode_state_i.u_immed;
            J_IMMED: alu_a_in = decode_state_i.j_immed;
            B_IMMED: alu_a_in = decode_state_i.b_immed;
            default: alu_a_in = reg_meta_i.rs1_data;
        endcase
    end

    // ALU B Source MUX
    logic [31:0] alu_b_in;
    always_comb begin
        unique case (decode_state_i.alu_b_src)
            RS2:     alu_b_in = reg_meta_i.rs2_data;
            I_IMMED: alu_b_in = decode_state_i.i_immed;
            S_IMMED: alu_b_in = decode_state_i.s_immed;
            PC:      alu_b_in = decode_state_i.pc;
            default: alu_b_in = reg_meta_i.rs2_data;
        endcase
    end

    // ALU
    logic [31:0] alu_out;
    alu i_alu (
        .op_i(decode_state_i.alu_op),
        .a_i(alu_a_in),
        .b_i(alu_b_in),

        .out_o(alu_out)
    );


    ////////////
    // Branch //
    ////////////

    // Branch Cond. Gen
    logic branch_taken;
    branch_gen i_branch_gen (
        .op_i(decode_state_i.branch_op),
        .rs1_data_i(reg_meta_i.rs1_data),
        .rs2_data_i(reg_meta_i.rs2_data),

        .taken_o(branch_taken)
    );

    // Program Counter Signals
    assign target_sel_o = (decode_state_i.pc_src | branch_taken) & valid_i;
    assign target_addr_o = alu_out;


    ////////////////
    // Load/Store //
    ////////////////

    // Memory Prep
    logic [31:0] mem_addr, mem_wdata;
    logic [3:0] mem_strb;
    logic mem_read, mem_write;

    /* verilator lint_off UNUSEDSIGNAL */
    // mem_illegal will be used, but usage is not yet implemented.
    logic mem_illegal;
    /* verilator lint_on UNUSEDSIGNAL */
    

    assign mem_read = decode_state_i.mem_read & ~stage_ctrl_i.squash & ~stage_ctrl_i.stall & valid_i;
    assign mem_write = decode_state_i.mem_write & ~stage_ctrl_i.squash & ~stage_ctrl_i.stall & valid_i;
    mem_prep i_mem_prep (
        .mem_width_i(decode_state_i.mem_width),
        .mem_data_i (reg_meta_i.rs2_data),
        .mem_addr_i (alu_out),
        .mem_read_i (mem_read),
        .mem_write_i(mem_write),

        .mem_word_addr_ao (mem_addr),
        .mem_write_data_ao(mem_wdata),
        .mem_strobe_ao    (mem_strb),
        .mem_illegal_ao   (mem_illegal)
    );


    // Assign Memory Interface Signals
    assign mem_read_ao  = mem_read;
    assign mem_write_ao = mem_write;
    assign mem_strb_ao  = mem_strb;
    assign mem_addr_ao  = mem_addr;
    assign mem_data_ao  = mem_wdata;

    //////////////////////////////
    // EX/MEM Pipeline Register //
    //////////////////////////////
    logic valid;
    assign valid = valid_i & ~stage_ctrl_i.squash;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            valid_o      <= 0;
            exec_state_o <= '0;
            reg_meta_o   <= '0;
        end else if (!stage_ctrl_i.stall) begin

            // Update Execute Stage State
            exec_state_o.alu_out <= alu_out;

            exec_state_o.next_pc <= decode_state_i.next_pc;

            exec_state_o.rf_wr_en  <= decode_state_i.rf_wr_en;
            exec_state_o.rf_wr_src <= decode_state_i.rf_wr_src;

            exec_state_o.mem_read  <= mem_read;
            exec_state_o.mem_sign  <= decode_state_i.mem_sign;
            exec_state_o.mem_width <= decode_state_i.mem_width;

            // Register Metadata
            reg_meta_o.rs1_used <= reg_meta_i.rs1_used;
            reg_meta_o.rs1      <= reg_meta_i.rs1;
            reg_meta_o.rs1_data <= reg_meta_i.rs1_data;

            reg_meta_o.rs2_used <= reg_meta_i.rs2_used;
            reg_meta_o.rs2      <= reg_meta_i.rs2;
            reg_meta_o.rs2_data <= reg_meta_i.rs2_data;

            reg_meta_o.rd_used <= reg_meta_i.rd_used;
            reg_meta_o.rd      <= reg_meta_i.rd;
            
            // Set validity of stage
            valid_o <= valid;

            // Forwarded data
            data_fwd_o.rf_wr_en <= decode_state_i.rf_wr_en;
            data_fwd_o.rd       <= reg_meta_i.rd;
            data_fwd_o.rd_data  <= alu_out;
            data_fwd_o.valid    <= valid;
            data_fwd_o.mem_read <= mem_read;
        end
    end

`ifdef RVFI

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvfi_o <= '0;
        end else if (!stage_ctrl_i.stall) begin
            // Execute stage updates to RVFI state
            rvfi_o.rs1_rdata <= reg_meta_i.rs1_used ? reg_meta_i.rs1_data : '0;
            rvfi_o.rs2_rdata <= reg_meta_i.rs2_used ? reg_meta_i.rs2_data : '0;

            rvfi_o.pc_wdata  <= target_sel_o ? target_addr_o : rvfi_i.pc_wdata;

            rvfi_o.mem_addr  <= mem_addr; // `RISCV_FORMAL_ALIGNED_MEM must be set
            rvfi_o.mem_rmask <= mem_strb;
            rvfi_o.mem_wmask <= mem_strb;
            rvfi_o.mem_wdata <= mem_wdata; // no issues here, right?

            // Unmodified signals, or RVFI signals modified in later stages
            rvfi_o.insn      <= rvfi_i.insn;
            rvfi_o.trap      <= rvfi_i.trap; // illegal memory accesses need to trap
            rvfi_o.halt      <= rvfi_i.halt;
            rvfi_o.intr      <= rvfi_i.intr;
            rvfi_o.rs1_addr  <= rvfi_i.rs1_addr;
            rvfi_o.rs2_addr  <= rvfi_i.rs2_addr;
            rvfi_o.pc_rdata  <= rvfi_i.pc_rdata;
            rvfi_o.mem_rdata <= rvfi_i.mem_rdata;

        end
    end

`ifdef VERILATOR
    logic _unused;
    assign _unused = &{1'b0, rvfi_i};
`endif
`endif
endmodule
