// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "const.vh"

module RegisterFile #(
  parameter LOG2_NUM_REGISTERS = 5,
  parameter NUM_REGISTERS = 1 << (LOG2_NUM_REGISTERS)
)(
  input clk,
  input reset,

  // NOTE(aryap): This should just be 4:0 for the initial code.
  input [LOG2_NUM_REGISTERS-1:0] waddr,
  input [`CPU_DATA_BITS-1:0] wdata,
  input write_enable,

  input [LOG2_NUM_REGISTERS-1:0] raddr0,
  output [`CPU_DATA_BITS-1:0] rdata0,

  input [LOG2_NUM_REGISTERS-1:0] raddr1,
  output [`CPU_DATA_BITS-1:0] rdata1
);
 // Integer registers.
 reg [`CPU_DATA_BITS-1:0] registers[NUM_REGISTERS-1:0];

 // Data read and propagate.

 // TODO(aryap): This is combinational only. Data is not moved on a clock. We
 // may need to add a cycle to read and straddle the S1/S2 boundary?
 assign rdata0 = registers[raddr0];
 assign rdata1 = registers[raddr1];


 // TODO(aryap): Reset all registers to 0 on a 'rst' signal.
 always @(posedge clk) begin
   // Don't write to zero!
   if (write_enable && waddr != 0) registers[waddr] <= wdata;
 end

endmodule
