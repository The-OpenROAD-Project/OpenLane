// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

module riscv_arbiter
(
  input clk,
  input reset,

  input                       ic_mem_req_valid,
  output                      ic_mem_req_ready,
  input [`MEM_ADDR_BITS-1:0]  ic_mem_req_addr,
  output                      ic_mem_resp_valid,

  input                       dc_mem_req_valid,
  output                      dc_mem_req_ready,
  input                       dc_mem_req_rw,
  input [`MEM_ADDR_BITS-1:0]  dc_mem_req_addr,
  output                      dc_mem_resp_valid,

  output                      mem_req_valid,
  input                       mem_req_ready,
  output                      mem_req_rw,
  output [`MEM_ADDR_BITS-1:0] mem_req_addr,
  output [`MEM_TAG_BITS-1:0]  mem_req_tag,
  input                       mem_resp_valid,
  input [`MEM_TAG_BITS-1:0]   mem_resp_tag
);

  assign ic_mem_req_ready = mem_req_ready;
  assign dc_mem_req_ready = mem_req_ready & ~ic_mem_req_valid;

  assign mem_req_valid = ic_mem_req_valid | dc_mem_req_valid;
  assign mem_req_rw
    = ic_mem_req_valid ? 1'b0
    : dc_mem_req_rw;
  assign mem_req_addr
    = ic_mem_req_valid ? ic_mem_req_addr
    : dc_mem_req_addr;
  assign mem_req_tag
    = ic_mem_req_valid ? 4'd0
    : 4'd1;

  assign ic_mem_resp_valid = mem_resp_valid & (mem_resp_tag == 4'd0);
  assign dc_mem_resp_valid = mem_resp_valid & (mem_resp_tag == 4'd1);

endmodule
