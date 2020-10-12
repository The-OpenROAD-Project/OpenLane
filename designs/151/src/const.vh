// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`ifndef CONST
`define CONST

`define MEM_DATA_BITS 128
`define MEM_TAG_BITS 5
`define MEM_ADDR_BITS 28
`define MEM_DATA_CYCLES 4

`define CACHE_SET_BITS 2

`define CPU_ADDR_BITS 32
`define CPU_INST_BITS 32
`define CPU_DATA_BITS 32
`define CPU_OP_BITS 4
`define CPU_WMASK_BITS 16
`define CPU_TAG_BITS 15

// Control selector constants.

// Stage 1.
`define S1_PC_SEL_INC 2'd0
`define S1_PC_SEL_S3 2'd1
`define S1_PC_SEL_OVERRIDE 2'd2
`define S1_PC_SEL_STALL 2'd3

// Stage 2.
`define S2_ALU_A_SEL_RS1_DATA 2'd0
`define S2_ALU_A_SEL_S2_PC 2'd1
`define S2_ALU_A_SEL_IMM_J 2'd2

`define S2_ALU_B_SEL_RS2_DATA 3'd0
`define S2_ALU_B_SEL_IMM_I 3'd1
`define S2_ALU_B_SEL_IMM_U 3'd2
`define S2_ALU_B_SEL_IMM_S 3'd3
`define S2_ALU_B_SEL_CONST_4 3'd4

`define S2_ADDER_A_SEL_RS1_DATA 2'd0
`define S2_ADDER_A_SEL_IMM_J 2'd1
`define S2_ADDER_A_SEL_IMM_B 2'd2

`define S2_ADDER_B_SEL_PC 2'd0
`define S2_ADDER_B_SEL_IMM_I 2'd1

`define S2_PC_OUT_SEL_STRAIGHT 1'd0
`define S2_PC_OUT_SEL_MASKED 1'd1

// It turns out that the Memory141.v module implements this for us, controlled
// by dmem_we.
`define S2_DMEM_WE_OFF                      2'd0
`define S2_DMEM_WE_BYTE                     2'd1
`define S2_DMEM_WE_HALF_WORD                2'd2
`define S2_DMEM_WE_WORD                     2'd3

// Stage 3.
`define S3_RDATA_SEL_PASSTHROUGH            3'd0
`define S3_RDATA_SEL_LOW_BYTE               3'd1
`define S3_RDATA_SEL_LOW_BYTE_SIGNED        3'd2
`define S3_RDATA_SEL_LOW_HALF_WORD          3'd3
`define S3_RDATA_SEL_LOW_HALF_WORD_SIGNED   3'd4

`define S3_REG_WDATA_SEL_S3_RS1             2'd0
`define S3_REG_WDATA_SEL_S3_RESULT          2'd1
`define S3_REG_WDATA_SEL_S3_RDATA_OUT       2'd2
`define S3_REG_WDATA_SEL_S3_CSR_DATA        2'd3

`define S3_CSR_NEW_DATA_SEL_RS1_DATA        2'd0
`define S3_CSR_NEW_DATA_SEL_IMM_RS1         2'd1

// Misc.
`define CONTROL_TRUE 1'b1
`define CONTROL_FALSE 1'b0

// Cache constants.
`define IDX_ADDR_OFFSET 4:2
`define IDX_ADDR_INDEX 12:5
`define IDX_ADDR_TAG 31:13
`define IDX_ADDR_DRAM 27:5

`define IDX_TAG_TAG 18:0
`define IDX_TAG_VALID 19
`define IDX_TAG_DIRTY 20

`define SZ_OFFSET 3
`define SZ_INDEX 8
`define SZ_TAG (32-`SZ_OFFSET-`SZ_INDEX-2)
`define SZ_METADATA 2
`define SZ_TAGLINE `SZ_TAG+`SZ_METADATA

// PC address on reset
`define PC_RESET 32'h00002000

// The NOP instruction
`define INSTR_NOP {12'd0, 5'd0, `FNC_ADD_SUB, 5'd0, `OPC_ARI_ITYPE}

`define CSR_TOHOST 12'h51E
`define CSR_HARTID 12'h50B
`define CSR_STATUS 12'h50A

`endif //CONST
