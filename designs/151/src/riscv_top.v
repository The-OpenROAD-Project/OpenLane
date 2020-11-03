// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

// emacs --batch riscv_top.v -f verilog-batch-auto

`include "const.vh"

module riscv_top
(
  input clk,
  input reset,

  output                      mem_req_valid,
  input                       mem_req_ready,
  output                      mem_req_rw,
  output [`MEM_ADDR_BITS-1:0] mem_req_addr,
  output [`MEM_TAG_BITS-1:0]  mem_req_tag,

  output                      mem_req_data_valid,
  input                       mem_req_data_ready,
  output [`MEM_DATA_BITS-1:0] mem_req_data_bits,
  output [(`MEM_DATA_BITS/8)-1:0] mem_req_data_mask,

  input                       mem_resp_valid,
  input [`MEM_TAG_BITS-1:0]   mem_resp_tag,
  input [`MEM_DATA_BITS-1:0]  mem_resp_data,
  output [31:0]               csr
);

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [31:0]   dcache_addr;    // From cpu of Riscv141.v
  wire [31:0]   dcache_din;   // From cpu of Riscv141.v
  wire [31:0]   dcache_dout;    // From mem of Memory141.v
  wire          dcache_val;
  wire      dcache_re;    // From cpu of Riscv141.v
  wire [3:0]    dcache_we;    // From cpu of Riscv141.v
  wire [31:0]   icache_addr;    // From cpu of Riscv141.v
  wire [31:0]   icache_dout;    // From mem of Memory141.v
  wire      icache_re;    // From cpu of Riscv141.v
  wire      stall;      // From mem of Memory141.v
  // End of automatics

  Memory141 mem(
  /*AUTOINST*/
    // Outputs
    .dcache_dout    (dcache_dout[31:0]),
    .dcache_val     (dcache_val),
    .icache_dout    (icache_dout[31:0]),
    .stall      (stall),
    .mem_req_valid    (mem_req_valid),
    .mem_req_rw   (mem_req_rw),
    .mem_req_addr   (mem_req_addr[`MEM_ADDR_BITS-1:0]),
    .mem_req_tag    (mem_req_tag[`MEM_TAG_BITS-1:0]),
    .mem_req_data_valid (mem_req_data_valid),
    .mem_req_data_bits  (mem_req_data_bits[`MEM_DATA_BITS-1:0]),
    .mem_req_data_mask  (mem_req_data_mask[(`MEM_DATA_BITS/8)-1:0]),
    // Inputs
    .clk      (clk),
    .reset      (reset),
    .dcache_addr    (dcache_addr[31:0]),
    .icache_addr    (icache_addr[31:0]),
    .dcache_we    (dcache_we[3:0]),
    .dcache_re    (dcache_re),
    .icache_re    (icache_re),
    .dcache_din   (dcache_din[31:0]),
    .mem_req_ready    (mem_req_ready),
    .mem_req_data_ready (mem_req_data_ready),
    .mem_resp_valid   (mem_resp_valid),
    .mem_resp_data    (mem_resp_data[`MEM_DATA_BITS-1:0]),
    .mem_resp_tag   (mem_resp_tag[`MEM_TAG_BITS-1:0]));
  
  // RISC-V 141 CPU
  Riscv141 cpu(
  /*AUTOINST*/
         // Outputs
         .dcache_addr   (dcache_addr[31:0]),
         .icache_addr   (icache_addr[31:0]),
         .dcache_we   (dcache_we[3:0]),
         .dcache_re   (dcache_re),
         .icache_re   (icache_re),
         .dcache_din    (dcache_din[31:0]),
         // Inputs
         .clk         (clk),
         .reset     (reset),
         .dcache_dout   (dcache_dout[31:0]),
         .dcache_val    (dcache_val),
         .icache_dout   (icache_dout[31:0]),
           .csr             (csr),
         .stall     (stall));

endmodule

// Local Variables:
// verilog-library-extensions:(".v" ".vh")
// verilog-library-directories:(".")
// End:
