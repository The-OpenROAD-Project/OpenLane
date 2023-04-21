`timescale 1ns/1ps

// TODO: Add RVFI or riscv_formal macros import
`ifdef RISCV_FORMAL
    `define RVFI
`endif


module wrapper (

    input clk_i,
    input rst_ni,

    // Test memory outputs
    // Instruction Memory Outputs
    output logic        imem_rd_o,
    output logic [31:0] imem_addr_o,
    output logic [31:0] inst_o,
    output logic [3:0]  dmem_strobe_o,
    output logic [31:0] dmem_addr_o,
    output logic [31:0] dmem_wdata_o,
    output logic [31:0] dmem_rdata_o,

    // Test Register Outputs
    output logic [4:0]  rf_port1_reg_o,
    output logic [4:0]  rf_port2_reg_o,
    output logic [4:0]  rf_wr_reg_o,
    output logic [31:0] rf_wr_data_o,
    output logic        rf_wr_en_o,
    output logic [31:0] rf_rs1_o,
    output logic [31:0] rf_rs2_o

    `ifdef RVFI
    ,
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
    output logic [31:0] rvfi_mem_wdata
`endif
);

    // Memory Signals
    logic imem_rd;
    logic [31:0] imem_addr, inst;

    logic dmem_rd, dmem_wr, dmem_rdata_valid, dmem_ready;
    logic [3:0] dmem_strobe;
    logic [31:0] dmem_addr, dmem_wdata, dmem_rdata;

    logic [31:0] dmem_rdata_internal;
    logic [31:0] dmem_addr_last;

    // Register File Signals
    logic [4:0] rf_port1_reg, rf_port2_reg, rf_wr_reg;
    logic [31:0] rf_rs1, rf_rs2, rf_wr_data;
    logic rf_wr_en;

    logic imem_gnt;
    assign imem_gnt = 1;

    // Core Instance
    core i_core(
        .clk_i,
        .rst_ni,

        // Instruction Memory Interface
        .imem_gnt_i  (imem_gnt),
        .imem_rd_o   (imem_rd),
        .imem_addr_o (imem_addr),
        .inst_i      (inst),

        // Data Memory Interface
        .dmem_rd_o          (dmem_rd),
        .dmem_wr_o          (dmem_wr),
        .dmem_strobe_o      (dmem_strobe),
        .dmem_addr_o        (dmem_addr),
        .dmem_wdata_o       (dmem_wdata),
        .dmem_rdata_i       (dmem_rdata),
        .dmem_rdata_valid_i ('1),
        .dmem_ready_i       ('1),

        // Register File Interface
        .rf_port1_reg_o     (rf_port1_reg),
        .rf_port2_reg_o     (rf_port2_reg),
        .rf_wr_en_o         (rf_wr_en),
        .rf_wr_reg_o        (rf_wr_reg),
        .rf_wr_data_o       (rf_wr_data),
        .rf_rs1_i           (rf_rs1),
        .rf_rs2_i           (rf_rs2)

`ifdef RVFI
        ,
        .rvfi_valid     (rvfi_valid),
        .rvfi_order     (rvfi_order),
        .rvfi_insn      (rvfi_insn),
        .rvfi_trap      (rvfi_trap),
        .rvfi_halt      (rvfi_halt),
        .rvfi_intr      (rvfi_intr),
        .rvfi_mode      (rvfi_mode),
        .rvfi_ixl       (rvfi_ixl),

        .rvfi_rs1_addr  (rvfi_rs1_addr),
        .rvfi_rs2_addr  (rvfi_rs2_addr),
        .rvfi_rs1_rdata (rvfi_rs1_rdata),
        .rvfi_rs2_rdata (rvfi_rs2_rdata),
        .rvfi_rd_addr   (rvfi_rd_addr),
        .rvfi_rd_wdata  (rvfi_rd_wdata),

        .rvfi_pc_rdata  (rvfi_pc_rdata),
        .rvfi_pc_wdata  (rvfi_pc_wdata),

        .rvfi_mem_addr  (rvfi_mem_addr),
        .rvfi_mem_rmask (rvfi_mem_rmask),
        .rvfi_mem_wmask (rvfi_mem_wmask),
        .rvfi_mem_rdata (rvfi_mem_rdata),
        .rvfi_mem_wdata (rvfi_mem_wdata)
`endif
    );

    // Memory Mapped IO handler
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            dmem_addr_last <= '0;
        else
            dmem_addr_last <= dmem_addr;
    end

    always_comb begin
        if (dmem_addr_last >= 32'h4000) begin
            // Reads above 0x4000 return 32'b0
            dmem_rdata = 32'b0;
        end else begin
            dmem_rdata = dmem_rdata_internal;
        end
    end


    // Memory
    test_memory #( .NUM_COL(4), .COL_WIDTH(8), .ADDR_WIDTH(12), .DATA_WIDTH(32)
    ) i_memory (
        .clk_i,
        .pA_en_i     ('1),
        .pA_strobe_i (dmem_strobe),
        .pA_addr_i   (dmem_addr[13:2]),
        .pA_data_i   (dmem_wdata),
        .pA_data_o   (dmem_rdata_internal),
        .pB_en_i     (imem_rd),
        .pB_strobe_i ('0),
        .pB_addr_i   (imem_addr[13:2]),
        .pB_data_i   ('0),
        .pB_data_o   (inst)
    );

    // Register File
    register_file i_reg_file (
        .clk_i,
        .rst_ni,

        .read1_i      (rf_port1_reg),
        .read2_i      (rf_port2_reg),

        .wr_reg_i     (rf_wr_reg),
        .wr_data_i    (rf_wr_data),
        .wr_en_i      (rf_wr_en),

        .data1_ao     (rf_rs1),
        .data2_a0     (rf_rs2) );


    // Test memory outputs
    assign dmem_strobe_o = dmem_strobe;
    assign dmem_addr_o = dmem_addr;
    assign dmem_wdata_o = dmem_wdata;
    assign dmem_rdata_o = dmem_rdata;

    // Test Register Outputs
    assign imem_rd_o = imem_rd;
    assign imem_addr_o = imem_addr;
    assign inst_o = inst;
    assign rf_port1_reg_o = rf_port1_reg;
    assign rf_port2_reg_o = rf_port2_reg;
    assign rf_wr_reg_o = rf_wr_reg;
    assign rf_wr_data_o = rf_wr_data;
    assign rf_wr_en_o = rf_wr_en;
    assign rf_rs1_o = rf_rs1;
    assign rf_rs2_o = rf_rs2;

endmodule
