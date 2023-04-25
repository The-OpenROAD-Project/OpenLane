`timescale 1ns/1ps
`include "defs.svh"
`include "pipe_regs.svh"
`include "rvfi.svh"

module core (
    input clk_i,
    input rst_ni,

    // Instruction Memory Interface (RI5CY subset of OBI)
    output logic        imem_req_o,
    input  logic        imem_gnt_i,
    output logic [31:0] imem_addr_o,
    output logic        imem_we_o,
    output logic [3:0]  imem_be_o,
    output logic [31:0] imem_wdata_o,
    input  logic        imem_rvalid_i,
    input  logic [31:0] imem_rdata_i,


    // Register File Interface
    output logic [4:0]  rf_port1_reg_o,
    output logic [4:0]  rf_port2_reg_o,
    output logic        rf_wr_en_o,
    output logic [4:0]  rf_wr_reg_o,
    output logic [31:0] rf_wr_data_o,
    input        [31:0] rf_rs1_i,
    input        [31:0] rf_rs2_i,

`ifdef RVFI
    // RVFI - RISCV-Formal Interface
    output logic        rvfi_valid,
    output logic [63:0] rvfi_order,
    output logic [31:0] rvfi_insn,
    output logic        rvfi_trap,
    output logic        rvfi_halt,
    output logic        rvfi_intr,
    output logic [1:0]  rvfi_mode,
    output logic [1:0]  rvfi_ixl,

    // Register File
    output logic [4:0]  rvfi_rs1_addr,
    output logic [4:0]  rvfi_rs2_addr,
    output logic [31:0] rvfi_rs1_rdata,
    output logic [31:0] rvfi_rs2_rdata,
    output logic [4:0]  rvfi_rd_addr,
    output logic [31:0] rvfi_rd_wdata,

    // Program Counter
    output logic [31:0] rvfi_pc_rdata,
    output logic [31:0] rvfi_pc_wdata,

    // Memory Access
    output logic [31:0] rvfi_mem_addr,
    output logic [3:0]  rvfi_mem_rmask,
    output logic [3:0]  rvfi_mem_wmask,
    output logic [31:0] rvfi_mem_rdata,
    output logic [31:0] rvfi_mem_wdata,
`endif

    // Data Memory Interface (RI5CY subset of OBI)
    output logic        dmem_req_o,
    input  logic        dmem_gnt_i,
    output logic [31:0] dmem_addr_o,
    output logic        dmem_we_o,
    output logic [3:0]  dmem_be_o,
    output logic [31:0] dmem_wdata_o,
    input  logic        dmem_rvalid_i,
    input  logic [31:0] dmem_rdata_i
);
    // Stage States
    fetch_state_t  fetch_state;
    decode_state_t decode_state;
    exec_state_t   exec_state;
    mem_state_t    mem_state;

    // Stage Control
    stage_ctrl_t fetch_ctrl, decode_ctrl, exec_ctrl, mem_ctrl, wb_ctrl;

    // Register Metadata
    reg_meta_t decode_reg_meta, decode_reg_meta_updated, exec_reg_meta, mem_reg_meta;

    // Stage Valid Signals
    logic fetch_valid, decode_valid, exec_valid, mem_valid;

    // Hazard signals
    logic mem_read_stall, load_use_stall;

    // Forward Data
    data_fwd_t exec_fwd_data, wb_fwd_data;


    // Fetch Stage
    logic pc_target_sel, imem_rd;
    logic [31:0] pc_target_addr;
    fetch_stage i_fetch_stage (
`ifdef RVFI 
        .rvfi_o         (rvfi_fetch),
`endif
        .clk_i,
        .rst_ni,

        .target_sel_i   (pc_target_sel),
        .target_addr_i  (pc_target_addr),
        .stage_ctrl_i   (fetch_ctrl),

        .mem_rd_o       (imem_rd),
        .mem_gnt_i      (imem_gnt_i),
        .mem_addr_o     (imem_addr_o),

        .valid_o        (fetch_valid),
        .fetch_state_o  (fetch_state)
    );

    // Decode Stage
    decode_stage i_decode_stage (
`ifdef RVFI 
        .rvfi_i         (rvfi_fetch),
        .rvfi_o         (rvfi_decode),
`endif
        .clk_i,
        .rst_ni,

        .valid_i        (fetch_valid),
        .fetch_state_i  (fetch_state),
        .inst_i         (imem_rdata_i),
        .stage_ctrl_i   (decode_ctrl),
        
        .rf_port1_reg_o,
        .rf_port2_reg_o,
        .rf_rs1_i,
        .rf_rs2_i,

        .valid_o        (decode_valid),
        .decode_state_o (decode_state),
        .reg_meta_o     (decode_reg_meta)
    );

    // Execute Stage
    logic dmem_rd;
    exec_stage i_exec_stage(
`ifdef RVFI 
        .rvfi_i             (rvfi_decode),
        .rvfi_o             (rvfi_exec),
`endif
        .clk_i,
        .rst_ni,

        .valid_i            (decode_valid),
        .decode_state_i     (decode_state),
        .reg_meta_i         (decode_reg_meta_updated),

        .stage_ctrl_i       (exec_ctrl),
        .data_fwd_o         (exec_fwd_data),

        .target_sel_o       (pc_target_sel),
        .target_addr_o      (pc_target_addr),

        .valid_o            (exec_valid),
        .exec_state_o       (exec_state),
        .reg_meta_o         (exec_reg_meta),

        .mem_read_ao        (dmem_rd),
        .mem_write_ao       (dmem_we_o),
        .mem_strb_ao        (dmem_be_o),
        .mem_addr_ao        (dmem_addr_o),
        .mem_data_ao        (dmem_wdata_o)
    );

    mem_slice_stage i_mem_slice_stage (
    `ifdef RVFI 
        .rvfi_i             (rvfi_exec),
        .rvfi_o             (rvfi_mem),
    `endif

        .clk_i              (clk_i),
        .rst_ni             (rst_ni),

        .valid_i            (exec_valid),
        .exec_state_i       (exec_state),
        .reg_meta_i         (exec_reg_meta),

        .stage_ctrl_i       (mem_ctrl),
        
        .dmem_rvalid_i,
        .dmem_rdata_i       (dmem_rdata_i),

        .valid_o            (mem_valid),
        .mem_state_o        (mem_state),
        .reg_meta_o         (mem_reg_meta),

        .mem_readwait_oa    (mem_read_stall)
    );

    // Writeback Stage
    wb_stage i_wb_stage (
        .valid_i            (mem_valid),
        .mem_state_i        (mem_state),
        .reg_meta_i         (mem_reg_meta),
        .stage_ctrl_i       (wb_ctrl),
        .data_fwd_oa        (wb_fwd_data),
        .rf_wr_en_oa        (rf_wr_en_o),
        .rf_wr_reg_oa       (rf_wr_reg_o),
        .rf_wr_data_oa      (rf_wr_data_o)
    );

    data_fwd_t [1:0] data_fwd_i_sig;
    assign data_fwd_i_sig[1] = 'exec_fwd_data;
    assign data_fwd_i_sig[0] = 'wb_fwd_data;

    // Forwarding Unit
    fwd_unit #( .N_STAGES(2) ) i_fwd_unit(
        .data_fwd_i         (data_fwd_i_sig),
        .dest_meta_i        (decode_reg_meta),

        .load_use_stall_ao  (load_use_stall),
        .dest_meta_o        (decode_reg_meta_updated)
    );

    // Hazard Unit
    /*
    stage_ctrl_t [4:0] stage_ctrl_signals;
    assign wb_ctrl     = stage_ctrl_signals[4];
    assign mem_ctrl    = stage_ctrl_signals[3];
    assign exec_ctrl   = stage_ctrl_signals[2];
    assign decode_ctrl = stage_ctrl_signals[1];
    assign fetch_ctrl  = stage_ctrl_signals[0];
    */
     hazard_unit #( .DEPTH(5), .BC_STAGE(2), .EX_STAGE(2) ) i_hazard_unit(
        .clk_i,
        .rst_ni,

        .imem_gnt_i,
        .imem_rvalid_i,
        .dmem_gnt_i,
        .dmem_rvalid_i      (mem_read_stall),
        .pc_src_i           (pc_target_sel),
        .csr_mret_i         ('0),    // TO DO: route from CSR when integrated
        .csr_flush_i        ('0),   // TO DO: route from CSR when integrated
        .load_use_stall_i   (load_use_stall),
        .stage_ctrl_ao      ({wb_ctrl, mem_ctrl, exec_ctrl, decode_ctrl, fetch_ctrl})
    );

    
    assign imem_we_o    = '0;
    assign imem_be_o    = '0;
    assign imem_wdata_o = '0;
    assign dmem_req_o   = dmem_rd || dmem_we_o;
    assign imem_req_o   = imem_rd;


`ifdef RVFI
    // will WB do any RVFI edits? probably not, use the rvfi_mem signals
    // TODO: drop _o convention for RVFI signals only?

    rvfi_reg_t rvfi_fetch, rvfi_decode, rvfi_exec, rvfi_mem;
    logic inst_retired;

    assign inst_retired = mem_valid && !wb_ctrl.stall && !wb_ctrl.squash;
    assign rvfi_valid   = inst_retired;
    assign rvfi_mode    = 2'b00;
    assign rvfi_ixl     = 2'b01;

    // rvfi_order increments in order of instruction execution
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if      (!rst_ni)      rvfi_order <= '0;
        else if (inst_retired) rvfi_order <= rvfi_order + 1'b1;
    end

    // Zero rd metadata if retired instruction does not write to rd
    assign rvfi_rd_addr  = mem_reg_meta.rd_used ? rf_wr_reg_o  : '0;
    assign rvfi_rd_wdata = (rvfi_rd_addr != '0) ? rf_wr_data_o : '0;

    assign rvfi_insn      = rvfi_mem.insn;
    assign rvfi_trap      = rvfi_mem.trap;
    assign rvfi_halt      = rvfi_mem.halt;
    assign rvfi_intr      = rvfi_mem.intr;
    assign rvfi_rs1_addr  = rvfi_mem.rs1_addr;
    assign rvfi_rs2_addr  = rvfi_mem.rs2_addr;
    assign rvfi_rs1_rdata = rvfi_mem.rs1_rdata;
    assign rvfi_rs2_rdata = rvfi_mem.rs2_rdata;
    assign rvfi_pc_rdata  = rvfi_mem.pc_rdata;
    assign rvfi_pc_wdata  = rvfi_mem.pc_wdata;
    assign rvfi_mem_addr  = rvfi_mem.mem_addr;
    assign rvfi_mem_rmask = rvfi_mem.mem_rmask;
    assign rvfi_mem_wmask = rvfi_mem.mem_wmask;
    assign rvfi_mem_rdata = rvfi_mem.mem_rdata;
    assign rvfi_mem_wdata = rvfi_mem.mem_wdata;
`endif
endmodule
