`ifndef DEFS_SVH
`define DEFS_SVH

/////////////
// Opcodes //
/////////////
typedef enum logic [6:0] {
    LUI      = 7'b0110111,
    AUIPC    = 7'b0010111,
    JAL      = 7'b1101111,
    JALR     = 7'b1100111,
    BRANCH   = 7'b1100011,
    LOAD     = 7'b0000011,
    STORE    = 7'b0100011,
    OP_IMM   = 7'b0010011,
    OP       = 7'b0110011,
    SYSTEM   = 7'b1110011
} opcode_e;


/////////////////
// ALU Defines //
/////////////////
typedef enum logic [1:0] {
    RS1,
    U_IMMED,
    J_IMMED,
    B_IMMED
} alu_a_src_e;

typedef enum logic [1:0] {
    RS2,
    I_IMMED,
    S_IMMED,
    PC
} alu_b_src_e;

// ALU Ops (func7[5],func3)
typedef enum logic [3:0] {
    // func7[5] = 0
    ADD  = 4'b0000,
    SLL  = 4'b0001,
    SLT  = 4'b0010,
    SLTU = 4'b0011,
    XOR  = 4'b0100,
    SRL  = 4'b0101,
    OR   = 4'b0110,
    AND  = 4'b0111,
    
    // func7[5] = 1
    SUB  = 4'b1000,
    SRA  = 4'b1101,

    // Special functions
    PASS = 4'b1111 // Passthrough ALU input A
} alu_op_e;


//////////////////////////////
// Branch Cond. Gen Defines //
//////////////////////////////
typedef enum logic [2:0] {
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111,

    NO_BRANCH = 3'b010
} branch_op_e;


///////////////////////////
// Register File Defines //
///////////////////////////
typedef enum logic [1:0] {
    ALU,
    MEM,
    CSR,
    PC_PLUS_4
} rf_wr_src_e;


/////////////////////////////
// Program Counter Defines //
/////////////////////////////
typedef enum logic {
    PLUS_4,
    TARGET
} pc_src_e;


////////////////////
// Memory Defines //
////////////////////
typedef enum logic [1:0] {
    BYTE = 2'b00,
    HALF = 2'b01,
    WORD = 2'b10,

    UNUSED_SIZE = 2'b11
} mem_width_e;

typedef enum logic {
    SIGNED   = 1'b0,
    UNSIGNED = 1'b1
} mem_sign_e;

`endif
