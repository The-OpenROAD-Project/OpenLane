module BigCircle(output G, P, input Gi, Pi, GiPrev, PiPrev);
  
  wire e;
  and #(1) (e, Pi, GiPrev);
  or #(1) (G, e, Gi);
  and #(1) (P, Pi, PiPrev);
  
endmodule

module SmallCircle(output Ci, input Gi);
  
  buf #(1) (Ci, Gi);
  
endmodule

module Square(output G, P, input Ai, Bi);
  
  and #(1) (G, Ai, Bi);
  xor #(2) (P, Ai, Bi);
  
endmodule

module Triangle(output Si, input Pi, CiPrev);
  
  xor #(2) (Si, Pi, CiPrev);
  
endmodule

module KSA8(output [7:0] sum, output cout, input [7:0] a, b);
  
  wire cin = 1'b0;
  wire [7:0] c;
  wire [7:0] g, p;
  Square sq[7:0](g, p, a, b);

  // first line of circles
  wire [7:1] g2, p2;
  SmallCircle sc0_0(c[0], g[0]);
  BigCircle bc0[7:1](g2[7:1], p2[7:1], g[7:1], p[7:1], g[6:0], p[6:0]);
  
  // second line of circle
  wire [7:3] g3, p3;
  SmallCircle sc1[2:1](c[2:1], g2[2:1]);
  BigCircle bc1[7:3](g3[7:3], p3[7:3], g2[7:3], p2[7:3], g2[5:1], p2[5:1]);
    
  // third line of circle
  wire [7:7] g4, p4;
  SmallCircle sc2[6:3](c[6:3], g3[6:3]);
  BigCircle bc2_7(g4[7], p4[7], g3[7], p3[7], g3[3], p3[3]);

  // fourth line of circle
  SmallCircle sc3_7(c[7], g4[7]);

  // last line - triangles
  Triangle tr0(sum[0], p[0], cin);
  Triangle tr[7:1](sum[7:1], p[7:1], c[6:0]);
  
  // generate cout
  buf #(1) (cout, c[7]);
  
endmodule

module KSA16(output [15:0] sum, output cout, input [15:0] a, b);
  
  wire cin = 1'b0;
  wire [15:0] c;
  wire [15:0] g, p;
  Square sq[15:0](g, p, a, b);

  // first line of circles
  wire [15:1] g2, p2;
  SmallCircle sc0_0(c[0], g[0]);
  BigCircle bc0[15:1](g2[15:1], p2[15:1], g[15:1], p[15:1], g[14:0], p[14:0]);
  
  // second line of circle
  wire [15:3] g3, p3;
  SmallCircle sc1[2:1](c[2:1], g2[2:1]);
  BigCircle bc1[15:3](g3[15:3], p3[15:3], g2[15:3], p2[15:3], g2[13:1], p2[13:1]);
  
  // third line of circle
  wire [15:7] g4, p4;
  SmallCircle sc2[6:3](c[6:3], g3[6:3]);
  BigCircle bc2[15:7](g4[15:7], p4[15:7], g3[15:7], p3[15:7], g3[11:3], p3[11:3]);

  // fourth line of circle
  wire [15:15] g5, p5;
  SmallCircle sc3[14:7](c[14:7], g4[14:7]);
  BigCircle bc3_15(g5[15], p5[15], g4[15], p4[15], g4[7], p4[7]);  
  
  // fifth line of circle
  SmallCircle sc4_15(c[15], g5[15]);
  
  // last line - triangles
  Triangle tr0(sum[0], p[0], cin);
  Triangle tr[15:1](sum[15:1], p[15:1], c[14:0]);

  // generate cout
  buf #(1) (cout, c[15]);

endmodule

module KSA32(output [31:0] sum, output cout, input [31:0] a, b);
  
  wire cin = 1'b0;
  wire [31:0] c;
  wire [31:0] g, p;
  Square sq[31:0](g, p, a, b);

  // first line of circles
  wire [31:1] g2, p2;
  SmallCircle sc0_0(c[0], g[0]);
  BigCircle bc0[31:1](g2[31:1], p2[31:1], g[31:1], p[31:1], g[30:0], p[30:0]);

  // second line of circles
  wire [31:3] g3, p3;
  SmallCircle sc1[2:1](c[2:1], g2[2:1]);
  BigCircle bc1[31:3](g3[31:3], p3[31:3], g2[31:3], p2[31:3], g2[29:1], p2[29:1]);

  // third line of circles
  wire [31:7] g4, p4;
  SmallCircle sc2[6:3](c[6:3], g3[6:3]);
  BigCircle bc2[31:7](g4[31:7], p4[31:7], g3[31:7], p3[31:7], g3[27:3], p3[27:3]);

  // fourth line of circles
  wire [31:15] g5, p5;
  SmallCircle sc3[14:7](c[14:7], g4[14:7]);
  BigCircle bc3[31:15](g5[31:15], p5[31:15], g4[31:15], p4[31:15], g4[23:7], p4[23:7]);
        
  // fifth line of circles
  wire [31:31] g6, p6;
  SmallCircle sc4[30:15](c[30:15], g5[30:15]);
  BigCircle bc4_31(g6[31], p6[31], g5[31], p5[31], g5[15], p5[15]);
  
  // sixth line of circles
  SmallCircle sc5_31(c[31], g6[31]);
  
  // last line - triangless
  Triangle tr0(sum[0], p[0], cin);
  Triangle tr[31:1](sum[31:1], p[31:1], c[30:0]);

  // generate cout
  buf #(1) (cout, c[31]);

endmodule

module KSA64(output [63:0] sum, output cout, input [63:0] a, b);
  
  wire cin = 1'b0;
  wire [63:0] c;
  wire [63:0] g, p;
  Square sq[63:0](g, p, a, b);

  // first line of circles
  wire [63:1] g2, p2;
  SmallCircle sc0_0(c[0], g[0]);
  BigCircle bc0[63:1](g2[63:1], p2[63:1], g[63:1], p[63:1], g[62:0], p[62:0]);

  // second line of circles
  wire [63:3] g3, p3;
  SmallCircle sc1[2:1](c[2:1], g2[2:1]);
  BigCircle bc1[63:3](g3[63:3], p3[63:3], g2[63:3], p2[63:3], g2[61:1], p2[61:1]);
    
  // third line of circles
  wire [63:7] g4, p4;
  SmallCircle sc2[6:3](c[6:3], g3[6:3]);
  BigCircle bc2[63:7](g4[63:7], p4[63:7], g3[63:7], p3[63:7], g3[59:3], p3[59:3]);
  
  // fourth line of circles
  wire [63:15] g5, p5;
  SmallCircle sc3[14:7](c[14:7], g4[14:7]);
  BigCircle bc3[63:15](g5[63:15], p5[63:15], g4[63:15], p4[63:15], g4[55:7], p4[55:7]);
        
  // fifth line of circles
  wire [63:31] g6, p6;
  SmallCircle sc4[30:15](c[30:15], g5[30:15]);
  BigCircle bc4[63:31](g6[63:31], p6[63:31], g5[63:31], p5[63:31], g5[47:15], p5[47:15]);
  
  // sixth line of circles
  wire [63:63] g7, p7;
  SmallCircle sc5[62:31](c[62:31], g6[62:31]);  
  BigCircle bc4_63(g7[63], p7[63], g6[63], p6[63], g6[31], p6[31]);

  // seventh line of circles
  SmallCircle sc6(c[63], g7[63]);  

  // last line - triangles
  Triangle tr0(sum[0], p[0], cin);
  Triangle tr[63:1](sum[63:1], p[63:1], c[62:0]);

  // generate cout
  buf #(1) (cout, c[63]);

endmodule
