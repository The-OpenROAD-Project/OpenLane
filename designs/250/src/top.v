module fpga_250 (
  input wire clk,
  input wire rst,

  input wire config_in,

  input wire [15:0] fake_in,
  output wire [15:0] fake_out,
);

localparam NUM = 1;

wire [7:0] A [NUM:0];
wire [7:0] B [NUM:0];

assign A[0] = fake_in[7:0];
assign B[0] = fake_in[15:8];

mac_cluster my_mac(
       .A0(A[0]),
       .B0(A[0]),
       .A1(B[0]),
       .B1(B[0]),
       .out0(A[1]),
       .out1(B[1])
);

// generate
//   genvar i;
//   for (i = 0; i < NUM; i = i + 1) begin : cluster
//     mac_cluster mac (
//       .A0(A[i]),
//       .B0(A[i]),
//       .A1(B[i]),
//       .B1(B[i]),
//       .out0(A[i+1]),
//       .out1(B[i+1])
//     );
//   end
// endgenerate

assign fake_out = {A[NUM], B[NUM]};

endmodule
