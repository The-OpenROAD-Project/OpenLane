/*
 * See https://github.com/SymbioticEDA/riscv-formal/blob/master/docs/rvfi.md
 * for further documentation of the RISCV-Formal interface
 */

`ifndef RVFI_SVH
`define RVFI_SVH

 `define RISCV_FORMAL_NRET 1
 `define RISCV_FORMAL_XLEN 32
 `define RISCV_FORMAL_ILEN 32
 `define RISCV_FORMAL_ALIGNED_MEM

 typedef struct packed {
    // Instruction Metadata
    //logic        valid;
    //logic [63:0] order;
    logic [31:0] insn;
    logic        trap;
    logic        halt;
    logic        intr;
    //logic [1:0]  mode;
    //logic [1:0]  ixl;

    // Integer Register Metadata
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    logic [31:0] rs1_rdata;
    logic [31:0] rs2_rdata;
    //logic [4:0]  rd_addr;
    //logic [31:0] rd_wdata;

    // Program Counter
    logic [31:0] pc_rdata;
    logic [31:0] pc_wdata;

    // Memory Access
    logic [31:0] mem_addr;
    logic [3:0]  mem_rmask;
    logic [3:0]  mem_wmask;
    logic [31:0] mem_rdata;
    logic [31:0] mem_wdata;
 } rvfi_reg_t;

`endif

