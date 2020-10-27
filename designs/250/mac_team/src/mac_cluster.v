`include "mac_const.vh"

module mac_cluster (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] A0,
  input [`MAC_MIN_WIDTH-1:0] B0,
  input [`MAC_MIN_WIDTH-1:0] A1,
  input [`MAC_MIN_WIDTH-1:0] B1,
  input [`MAC_MIN_WIDTH-1:0] A2,
  input [`MAC_MIN_WIDTH-1:0] B2,
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_MIN_WIDTH-1:0] B3,
  input [4*`MAC_ACC_WIDTH + `MAC_CONF_WIDTH - 1:0] cfg, // 4 * `MAC_ACC_WIDTH initial register values + `MAC_CONF_WIDTH config bits

  output [`MAC_ACC_WIDTH-1:0] out0,
  output [`MAC_ACC_WIDTH-1:0] out1,
  output [`MAC_ACC_WIDTH-1:0] out2,
  output [`MAC_ACC_WIDTH-1:0] out3
);

wire [`MAC_INT_WIDTH-1:0] mac_mul_out0;
wire [`MAC_INT_WIDTH-1:0] mac_mul_out1;
wire [`MAC_INT_WIDTH-1:0] mac_mul_out2;
wire [`MAC_INT_WIDTH-1:0] mac_mul_out3;


// Instantiating all blocks in a quad-cluster and fully connecting them together
mac_mul_block_0 macmul0 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B0(B0),
  .cfg(cfg[`MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out0)
);

mac_mul_block_1 macmul1 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B1(B1),
  .cfg(cfg[`MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out1)
);

mac_mul_block_2 macmul2 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B2(B2),
  .cfg(cfg[`MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out2)
);

mac_mul_block_3 macmul3 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .A0(A0),
  .A1(A1),
  .A2(A2),
  .A3(A3),
  .B3(B3),
  .cfg(cfg[`MAC_CONF_WIDTH-1:0]),
  .C(mac_mul_out3)
);

// Combiner
mac_acc_block macacc 
(
  .clk(clk),
  .rst(rst),
  .en(en),
  .cfg(cfg),
  .partial0(mac_mul_out0),
  .partial1(mac_mul_out1),
  .partial2(mac_mul_out2),
  .partial3(mac_mul_out3),
  .out0(out0),
  .out1(out1),
  .out2(out2),
  .out3(out3)
);

endmodule
