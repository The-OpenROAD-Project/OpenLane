///*********************************************************
// IEEE STD 1364-2001 Verilog file: iir5sfix.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// 5th order IIR in direct form implementation
module iir5sfix
(input clk, // System clock
input reset, // Asynchron reset
input switch, // Feedback switch
input signed [63:0] x_in, // System input
output signed [39:0] t_out, // Feedback
output signed [39:0] y_out);// System output
// --------------------------------------------------------
wire signed[63:0] a2, a3, a4, a5, a6; // Feedback A
wire signed[63:0] b1, b2, b3, b4, b5, b6;// Feedforward B
wire signed [63:0] h;
reg signed [63:0] s1, s2, s3, s4;
reg signed [63:0] y, t, r2, r3, r4;
reg signed [127:0] a6h, a5h, a4h, a3h, a2h;
reg signed [127:0] b6h, b5h, b4h, b3h, b2h, b1h;
// Feedback A scaled by 2^30
assign a2 = 64'h000000013DF707FA; // (-)4.9682025852
assign a3 = 64'h0000000277FBF6D7; // 9.8747536754
assign a4 = 64'h00000002742912B6; // (-)9.8150069021
assign a5 = 64'h00000001383A6441; // 4.8785639415
assign a6 = 64'h000000003E164061; // (-)0.9701081227
// Feedforward B scaled by 2^30
assign b1 = 64'h000000000004F948; // 0.0003035737
assign a3 = 64'h0000000277FBF6D7; // 9.8747536754 
assign a4 = 64'h00000002742912B6; // (-)9.8150069021 
assign a5 = 64'h00000001383A6441; // 4.8785639415 
assign a6 = 64'h000000003E164061; // (-)0.9701081227
// Feedforward B scaled by 2^30
assign b1 = 64'h000000000004F948; // 0.0003035737 
assign b2 = 64'h00000000000EE2A2; // (-)0.0009085259 
assign b3 = 64'h000000000009E95E; // 0.0006049556 
assign b4 = 64'h000000000009E95E; // 0.0006049556 
assign b5 = 64'h00000000000EE2A2; // (-)0.0009085259 
assign b6 = 64'h000000000004F948; // 0.0003035737 
assign h = (switch) ? x_in-t // Switch is closed
: x_in; // Switch is open
  always @(posedge clk or posedge reset)
  begin : P1  // First equations without infering registers
if (reset) begin             // Asynchronous clear
t<=0; y<=0;r2<=0;r3<=0;r4<=0;s1<=0; s2 <= 0; s3 <= 0; s4 <= 0; a6h <= 0; b6h <= 0;
end else begin 
	a6h <= a6 * h; // h*a[6] use register
a5h = a5 * h; // h*a[5]
r4 <= (a5h >>> 30) - (a6h >>> 30); // h*a[5]+r5
a4h = a4 * h; // h*a[4]
r3 <= r4 - (a4h >>> 30); // h*a[4]+r4
a3h = a3 * h; // h*a[3]
r2 <= r3 + (a3h >>> 30); // h*a[3]+r3
a2h = a2 * h; // h*a[2]+r2
t <= r2 - (a2h >>> 30); // h*a[2]+r2
b6h <= b6 * h; // h*b[6] use register
b5h = b5 * h; // h*b[5]+s5 no register
s4 <= (b6h >>> 30) - (b5h >>> 30); // h*b[5]+s5
b4h = b4 * h; // h*b[4]+s4
s3 <= s4 + (b4h >>> 30); // h*b[4]+s4
b3h = b3 * h; // h*b[3]
s2 <= s3 + (b3h >>> 30); // h*b[3]+s3
b2h = b2 * h; // h*b[2]
s1 <= s2 - (b2h >>> 30); // h*b[2]+s2
b1h = b1 * h; // h*b[1]
y <= s1 + (b1h >>> 30); // h*b[1]+s1
end end
// Redefine bits as 40 bit SLV
// Change 30 to 16 bit fraction, i.e. cut 14 LSBs assign y_out = y[53:14];
assign t_out = t[53:14];
endmodule
