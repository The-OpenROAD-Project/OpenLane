`ifndef PIPE_REGS_SVH
`define PIPE_REGS_SVH

`include "defs.svh"

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] next_pc;
} fetch_state_t;

typedef struct packed {
    // PC Signals
    pc_src_e pc_src;

    // Branch Cond. Signals
    branch_op_e branch_op;

    // ALU Signals
    alu_op_e     alu_op;
    alu_a_src_e  alu_a_src;
    alu_b_src_e  alu_b_src;

    // Immediates
    logic [31:0] i_immed;
    logic [31:0] s_immed; 
    logic [31:0] b_immed; 
    logic [31:0] u_immed; 
    logic [31:0] j_immed;

    // Program Counter
    logic [31:0] pc;
    logic [31:0] next_pc;

    // Register File signals
    logic       rf_wr_en;
    rf_wr_src_e rf_wr_src;

    // Memory signals
    logic       mem_read;
    logic       mem_write;
    mem_sign_e  mem_sign;
    mem_width_e mem_width;
} decode_state_t;


typedef struct packed {
    // Program Counter + 4
    // (to be stored for jump instructions)
    logic [31:0] next_pc;

    // ALU Output
    logic [31:0] alu_out;

    // Register File Signals
    logic       rf_wr_en;
    rf_wr_src_e rf_wr_src;

    // Memory Signals
    logic mem_read;
    mem_sign_e  mem_sign;
    mem_width_e mem_width;
} exec_state_t;

typedef struct packed {
    // Program Counter + 4
    // (to be stored for jump instructions)
    logic [31:0] next_pc;

    // ALU Output
    logic [31:0] alu_out;

    // Register File Signals
    logic       rf_wr_en;
    rf_wr_src_e rf_wr_src;

    // Memory Signals
    logic mem_read;
    mem_sign_e  mem_sign;
    mem_width_e mem_width;
    //logic [31:0] mem_write_data;    

    // Memory output
    logic [31:0] mem_dout;
    
} mem_state_t;


// Register Metadata
typedef struct packed {
    logic rs1_used;
    logic [4:0] rs1;
    logic [31:0] rs1_data;
    
    logic rs2_used;
    logic [4:0] rs2;
    logic [31:0] rs2_data;

    logic rd_used;
    logic [4:0] rd;
} reg_meta_t;


// Stage Control Signals
typedef struct packed {
    logic squash;
    logic stall;
} stage_ctrl_t;

// Data Forwarding Signals
typedef struct packed {
        logic        rf_wr_en;
        logic        mem_read;
        logic [4:0]  rd;
        logic [31:0] rd_data;
        logic        valid;
} data_fwd_t;

`endif
