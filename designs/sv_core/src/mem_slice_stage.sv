`timescale 1ns/1ps
`include "defs.svh"
`include "pipe_regs.svh"
`include "rvfi.svh"

module mem_slice_stage (

`ifdef RVFI
    input  rvfi_reg_t rvfi_i,
    output rvfi_reg_t rvfi_o,
`endif

    input clk_i,
    input rst_ni,

    // From Execute
    input              valid_i,
    input exec_state_t exec_state_i,
    input reg_meta_t   reg_meta_i,

    // Stage Control
    input stage_ctrl_t stage_ctrl_i,

	// Memory result port
	input 		 dmem_rvalid_i,
	input [31:0] dmem_rdata_i,
	// TODO: More signals?

    // To Writeback
    output logic       valid_o,
    output mem_state_t mem_state_o,
    output reg_meta_t  reg_meta_o,

    // To hazard unit
    output logic mem_readwait_oa
);

    // TODO: Add MUXes for forwarded data

    logic [1:0]  byte_offset;
    logic [31:0] pre_data;
    logic        mem_read_active;
    logic        sign;
    logic        sign_ext;

    assign byte_offset = exec_state_i.alu_out[1:0];

    assign mem_read_active = (
        exec_state_i.mem_read &&
        valid_i
    );

    assign mem_readwait_oa = mem_read_active && !dmem_rvalid_i;

    // Splits
    logic [7:0]  bytes [0:3];
    logic [15:0] halfs [0:1];

    assign bytes[0] = dmem_rdata_i[7:0];
    assign bytes[1] = dmem_rdata_i[15:8];
    assign bytes[2] = dmem_rdata_i[23:16];
    assign bytes[3] = dmem_rdata_i[31:24];

    assign halfs[0] = dmem_rdata_i[15:0];
    assign halfs[1] = dmem_rdata_i[31:16];


    always_comb begin
        sign = (exec_state_i.mem_sign == SIGNED);
        sign_ext = 0;
        unique case (exec_state_i.mem_width)
            BYTE: begin
                sign_ext = sign && bytes[byte_offset][7];
                pre_data = {{24{sign_ext}},bytes[byte_offset]};
            end
            HALF: begin
                sign_ext = sign && halfs[byte_offset[1]][15];
                pre_data = {{16{sign_ext}},halfs[byte_offset[1]]};
            end
            WORD: begin
                pre_data = dmem_rdata_i;
            end
            default: begin
                pre_data = '0;
            end
        endcase
    end

    //////////////////////////////
    // MEM/WB Pipeline Register //
    //////////////////////////////
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            valid_o     <= 1'b0;
            mem_state_o <= '0;
            reg_meta_o  <= '0;
        end else if (!stage_ctrl_i.stall) begin
            // Update instruction valid signal
            valid_o <= valid_i & ~stage_ctrl_i.squash;

            // Update Mem Stage State
            mem_state_o.next_pc   <= exec_state_i.next_pc;
            mem_state_o.alu_out   <= exec_state_i.alu_out;

            mem_state_o.rf_wr_en  <= exec_state_i.rf_wr_en;
            mem_state_o.rf_wr_src <= exec_state_i.rf_wr_src;

            mem_state_o.mem_read  <= exec_state_i.mem_read;
            mem_state_o.mem_sign  <= exec_state_i.mem_sign;
            mem_state_o.mem_width <= exec_state_i.mem_width;
            // New signals
            mem_state_o.mem_dout  <= pre_data;

            // Register Metadata
            reg_meta_o.rs1_used <= reg_meta_i.rs1_used;
            reg_meta_o.rs1      <= reg_meta_i.rs1;
            reg_meta_o.rs1_data <= reg_meta_i.rs1_data;

            reg_meta_o.rs2_used <= reg_meta_i.rs2_used;
            reg_meta_o.rs2      <= reg_meta_i.rs2;
            reg_meta_o.rs2_data <= reg_meta_i.rs2_data;

            reg_meta_o.rd_used <= reg_meta_i.rd_used;
            reg_meta_o.rd      <= reg_meta_i.rd;
        end
    end

`ifdef RVFI

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvfi_o <= '0;
        end else if (!stage_ctrl_i.stall) begin
            // MEM stage modifications
            rvfi_o.mem_rdata <= dmem_rdata_i;
            // Unmodified signals
            rvfi_o.insn      <= rvfi_i.insn;
            rvfi_o.trap      <= rvfi_i.trap; // illegal memory accesses need to trap
            rvfi_o.halt      <= rvfi_i.halt;
            rvfi_o.intr      <= rvfi_i.intr;

            rvfi_o.rs1_addr  <= rvfi_i.rs1_addr;
            rvfi_o.rs2_addr  <= rvfi_i.rs2_addr;
            rvfi_o.rs1_rdata <= rvfi_i.rs1_rdata;
            rvfi_o.rs2_rdata <= rvfi_i.rs2_rdata;

            rvfi_o.pc_rdata  <= rvfi_i.pc_rdata;
            rvfi_o.pc_wdata  <= rvfi_i.pc_wdata;

            rvfi_o.mem_addr  <= rvfi_i.mem_addr;
            rvfi_o.mem_rmask <= rvfi_i.mem_rmask;
            rvfi_o.mem_wmask <= rvfi_i.mem_wmask;
            rvfi_o.mem_wdata <= rvfi_i.mem_wdata;
        end
    end


`ifdef VERILATOR
    logic _unused;
    assign _unused = &{1'b0, rvfi_i};
`endif
`endif

endmodule
