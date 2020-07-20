//********************************************************* 
// IEEE STD 1364-2001 Verilog file: pca.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org 
//********************************************************* 
module pca // ------> Interface
(input clk,
input reset,
input signed [31:0] s1_in, input signed [31:0] s2_in, input signed [31:0] mu1_in,

input signed [31:0] mu2_in, // Learning rate 2. PC 
output signed [31:0] x1_out, // Mixing 1. 
output signed [31:0] x2_out, // Mixing 2. 
output signed [31:0] w11_out, // Eigenvector [1,1] 
output signed [31:0] w12_out, // Eigenvector [1,2] 
output signed [31:0] w21_out, // Eigenvector [2,1] 
output signed [31:0] w22_out, // Eigenvector [2,2] 
output reg signed [31:0] y1_out, // 1. PC output 
output reg signed [31:0] y2_out); // 2. PC output
// --------------------------------------------------------
// All data and coefficients are in 16.16 format
  reg signed [31:0] s, s1, s2, x1, x2, w11, w12, w21, w22;
  reg signed [31:0] h11, h12, y1, y2, mu1, mu2;
  // Product double bit width
  reg signed [63:0] a11s1, a12s2, a21s1, a22s2;
  reg signed [63:0] x1w11, x2w12, w11y1, mu1y1, p12;
  reg signed [63:0] x1w21, x2w22, w21y2, p21, w22y2;
  reg signed [63:0] mu2y2, p22, p11;
wire signed [31:0] a11, a12, a21, a22, ini; 
assign a11 = 32'h0000C000; // 0.75
assign a12 = 32'h00018000; // 1.5
assign a21 = 32'h00008000; // 0.5
assign a22 = 32'h00005555; // 0.333333 assign ini = 32’h00008000; // 0.5
  always @(posedge clk or posedge reset)
  begin : P1                 // PCA using Sanger GHA
if (reset) begin // reset/initialize all registers 
x1<=0; x2<=0;y1_out<=0;y2_out<=0; w11<=ini; w12<=ini;s1<=0;mu1<=0; w21<=ini; w22<=ini;s2<=0;mu2<=0;
end else begin
s1 <= s1_in; // place inputs in registers s2 <= s2_in;
mu1 <= mu1_in;
mu2 <= mu2_in;
// Mixing matrix
a11s1 = a11 * s1; a12s2 = a12 * s2;
x1 <= (a11s1 >>> 16) + (a12s2 >>> 16); a21s1 = a21 * s1; a22s2 = a22 * s2;
x2 <= (a21s1 >>> 16) - (a22s2 >>> 16);

     // first PC and eigenvector
      x1w11 = x1 * w11;
      x2w12 = x2 * w12;
      y1 = (x1w11 >>> 16) + (x2w12 >>> 16);
      w11y1 = w11 * y1;
mu1y1 = mu1 * y1;
h11 = w11y1 >>> 16;
p11 = (mu1y1 >>> 16) * (x1 - h11); w11 <= w11 + (p11 >>> 16);
h12 = (w12 * y1) >>> 16;
p12 = (x2 - h12) * (mu1y1 >>> 16); w12 <= w12 + (p12 >>> 16);
// second PC and eigenvector
x1w21 = x1 * w21; x2w22 = x2 * w22;
y2 = (x1w21 >>> 16) + (x2w22 >>> 16);
w21y2 = w21 * y2;
mu2y2 = mu2 * y2;
p21 = (mu2y2 >>> 16) * (x1 - h11 - (w21y2 >>> 16)); w21 <= w21 + (p21 >>> 16);
w22y2 = w22 * y2;
p22 = (mu2y2 >>> 16) * (x2 - h12 - (w22y2 >>> 16)); w22 <= w22 + (p22 >>> 16);
// registers y output
y1_out <= y1;
y2_out <= y2;
end end
// Redefine bits as 32 bit SLV assign x1_out = x1;
assign x2_out = x2;
assign w11_out = w11;
assign w12_out = w12; 
assign w21_out = w21; 
assign w22_out = w22;
endmodule
