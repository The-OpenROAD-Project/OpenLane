//********************************************************* 
// IEEE STD 1364-2001 Verilog file: ica.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//********************************************************* 
module ica // ------> Interface
(input clk,
input reset,
input signed [31:0] s1_in,
input signed [31:0] s2_in,
input signed [31:0] mu_in, // Learning rate
output signed [31:0] x1_out, // Mixing 1. output
output signed [31:0] x2_out, // Mixing 2. output
output signed [31:0] B11_out, // Demixing 1,1
output signed [31:0] B12_out, // Demixing 1,2
output signed [31:0] B21_out, // Demixing 2,1
output signed [31:0] B22_out, // Demixing 2,2
output reg signed [31:0] y1_out, // 1. component output 
output reg signed [31:0] y2_out); // 2. component output
// --------------------------------------------------------
// All data and coefficients are in 16.16 format
  reg signed [31:0] s, s1, s2, x1, x2, B11, B12, B21, B22;
  reg signed [31:0] y1, y2, f1, f2, H11, H12, H21, H22, mu;
  reg signed [31:0] DB11, DB12, DB21, DB22;
  // Product double bit width
  reg signed [63:0] a11s1, a12s2, a21s1, a22s2;
  reg signed [63:0] x1B11, x2B12, x1B21, x2B22;
  reg signed [63:0] y1y1, y2f1, y1y2, y1f2, y2y2;
  reg signed [63:0] muDB11, muDB12, muDB21, muDB22;
  reg signed [63:0] B11H11, H12B21, B12H11, H12B22;
  reg signed [63:0] B11H21, H22B21, B12H21, H22B22;
wire signed [31:0] a11, a12, a21, a22, one, negone; 
assign a11 = 32'h0000C000; // 0.75
assign a12 = 32'h00018000; // 1.5
assign a21 = 32'h00008000; // 0.5
assign a22 = 32'h00005555; // 0.333333 assign one = 32’h00010000; // 1.0 assign negone = 32’hFFFF0000; // -1.0
  always @(posedge clk or posedge reset)
  begin : P1                 // ICA using EASI
if (reset) begin // reset/initialize all registers x1<=0; x2<=0;y1_out<=0;y2_out<=0; B11<=one; B12<=0;s1<=0;mu<=0; B21<=0; B22<=one;s2<=0;
    end else begin
// System clock
// Asynchron reset // 1. signal input // 2. signal input

s1 <= s1_in; // place inputs in registers s2 <= s2_in;
mu <= mu_in;
// Mixing matrix
a11s1 = a11 * s1; a12s2 = a12 * s2;
x1 <= (a11s1 >>> 16) + (a12s2 >>> 16); a21s1 = a21 * s1; a22s2 = a22 * s2;
x2 <= (a21s1 >>> 16) - (a22s2 >>> 16);
// New y values first
x1B11=x1*B11; x2B12=x2*B12; y1 = (x1B11 >>> 16) + (x2B12 >>> 16); x1B21 = x1 * B21; x2B22 = x2 * B22; y2 = (x1B21 >>> 16) + (x2B22 >>> 16);
   // compute the H matrix
// Build tanh approximation function for f1
    if (y1 > one) f1 = one;
    else if (y1 < negone) f1 = negone;
    else f1 = y1;
// Build tanh approximation function for f2
    if (y2 > one) f2 = one;
    else if (y2 < negone) f2 = negone;
    else f2 = y2;
y1y1 = y1 * y1;
H11 = one - (y1y1 >>> 16) ;
y2f1 = f1 * y2; y1y2 = y1 * y2; y1f2 = y1 * f2;
H12 = (y2f1 >>> 16) - (y1y2 >>> 16) - (y1f2 >>> 16); H21 = (y1f2 >>> 16) - (y1y2 >>> 16) - (y2f1 >>> 16); y2y2 = y2 * y2;
H22 = one - (y2y2 >>> 16);
   // update matrix Delta B
    B11H11 = B11 * H11; H12B21 = H12 * B21;
    DB11 = (B11H11 >>> 16) + (H12B21 >>> 16);
    B12H11 = B12 * H11; H12B22 = H12 * B22;
    DB12 = (B12H11 >>> 16) + (H12B22 >>> 16);
    B11H21 = B11 * H21;  H22B21 = H22 * B21;
    DB21 = (B11H21 >>> 16) + (H22B21 >>> 16);
    B12H21 = B12 * H21; H22B22 = H22 * B22;
    DB22 = (B12H21 >>> 16) + (H22B22 >>> 16);
 // Store update matrix B in registers
    muDB11 = mu * DB11; muDB12 = mu * DB12;
    muDB21 = mu * DB21; muDB22 = mu * DB22;
    B11 <=  B11 + (muDB11 >>> 16) ;

B12 <=  B12 + (muDB12 >>> 16);
      B21 <=  B21 + (muDB21 >>> 16);
      B22 <=  B22 + (muDB22 >>> 16);
// register y output y1_out <= y1; y2_out <= y2;
end end
assign x1_out = x1; // Redefine bits as 32 bit SLV assign x2_out = x2;
assign B11_out = B11;
assign B12_out = B12;
assign B21_out = B21; assign B22_out = B22;
endmodule