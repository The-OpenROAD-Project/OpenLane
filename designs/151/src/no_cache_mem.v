// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "const.vh"

module no_cache_mem #(
  parameter CPU_WIDTH = `CPU_INST_BITS,
  parameter WORD_ADDR_BITS = `CPU_ADDR_BITS-`ceilLog2(`CPU_INST_BITS/8)
) (
  input clk,
  input reset,

  input                       cpu_req_val,
  output                      cpu_req_rdy,
  input [WORD_ADDR_BITS-1:0]  cpu_req_addr,
  input [CPU_WIDTH-1:0]       cpu_req_data,
  input [3:0]                 cpu_req_write,

  output reg                  cpu_resp_val,
  output reg [CPU_WIDTH-1:0]  cpu_resp_data
);

  localparam DEPTH = 2*512*512;
  localparam WORDS = `MEM_DATA_BITS/CPU_WIDTH;

  reg [`MEM_DATA_BITS-1:0] ram [DEPTH-1:0];

  wire [WORD_ADDR_BITS-`ceilLog2(WORDS)-1:0] upper_addr;
  assign upper_addr = cpu_req_addr[WORD_ADDR_BITS-1:`ceilLog2(WORDS)];

  wire [`ceilLog2(WORDS)-1:0] lower_addr;
  assign lower_addr = cpu_req_addr[`ceilLog2(WORDS)-1:0];

  wire [`MEM_DATA_BITS-1:0] read_data;
  assign read_data = (ram[upper_addr] >> CPU_WIDTH*lower_addr);

  assign cpu_req_rdy = 1'b1;

  wire [CPU_WIDTH-1:0] wmask;
  assign wmask = {{8{cpu_req_write[3]}},{8{cpu_req_write[2]}},{8{cpu_req_write[1]}},{8{cpu_req_write[0]}}};

  wire [`MEM_DATA_BITS-1:0] write_data;
  assign write_data = (ram[upper_addr] & ~({{`MEM_DATA_BITS-CPU_WIDTH{1'b0}},wmask} << CPU_WIDTH*lower_addr)) | ((cpu_req_data & wmask) << CPU_WIDTH*lower_addr);

  always @(posedge clk) begin
    if (reset)
      cpu_resp_val <= 1'b0;
    else if (cpu_req_val && cpu_req_rdy) begin
      if (cpu_req_write) begin
        cpu_resp_val <= 1'b0;
        ram[upper_addr] <= write_data;
      end else begin
        cpu_resp_val <= 1'b1;
        cpu_resp_data <= read_data[CPU_WIDTH-1:0];
      end
    end else
      cpu_resp_val <= 1'b0;
  end

  initial
  begin : zero
    integer i;
    for (i = 0; i < DEPTH; i = i + 1)
      ram[i] = 0;
  end

endmodule

