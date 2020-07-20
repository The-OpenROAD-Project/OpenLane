/*
    Copyright 2011, City University of Hong Kong
    Author is Homer (Dongsheng) Hsing.

    This file is part of Elliptic Curve Group Core.

    Elliptic Curve Group Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Elliptic Curve Group Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Elliptic Curve Group Core.  If not, see http://www.gnu.org/licenses/lgpl.txt
*/

//`include "inc.v"
`define M     97          // M is the degree of the irreducible polynomial
`define WIDTH (2*`M-1)    // width for a GF(3^M) element
`define W2    (4*`M-1)    // width for a GF(3^{2*M}) element
`define W3    (6*`M-1)    // width for a GF(3^{3*M}) element
`define W6    (12*`M-1)   // width for a GF(3^{6*M}) element
`define PX    196'h4000000000000000000000000000000000000000001000002 // PX is the irreducible polynomial
`define SCALAR_WIDTH (151-1) // the width for the scalar value

/* point scalar multiplication on the elliptic curve $y^2=x^3-x+1$ over a Galois field GF(3^M)
 * whose irreducible polynomial is $x^97 + x^12 + 2$. */
/* $P3(x3,y3) == c \cdot P1(x1,y1)$ */
module point_scalar_mult(clk, reset, x1, y1, zero1, c, done, x3, y3, zero3);
    input clk, reset;
    input [`WIDTH:0] x1, y1;
    input zero1;
    input [`SCALAR_WIDTH:0] c;
    output reg done;
    output reg [`WIDTH:0] x3, y3;
    output reg zero3;
    
    reg [`WIDTH:0] x2, y2; reg zero2; // accumulator
    reg [`WIDTH:0] x4, y4; reg zero4; // doubler
    wire [`WIDTH:0] x5, y5; wire zero5; // the first input of the adder
    wire [`WIDTH:0] x6, y6; wire zero6; // the second input of the adder
    wire [`WIDTH:0] x7, y7; wire zero7; // the output of the adder
    reg [`SCALAR_WIDTH : 0] k; // the scalar value
    wire fin; // asserted if job done
    reg op;
    wire p, p2, rst, done1, lastbit;
    
    assign lastbit = k[0];
    assign fin = (k == 0);
    assign x5 = op ? x4 : x2;
    assign y5 = op ? y4 : y2;
    assign zero5 = op ? zero4 : zero2;
    assign {x6,y6} = {x4,y4};
    assign zero6 = ((~op)&(~lastbit)) ? 1 : zero4;
    assign rst   = reset | p2 ;
    
    point_add
        ins1 (clk, rst, x5, y5, zero5, x6, y6, zero6, done1, x7, y7, zero7);
    func6
        ins2 (clk, reset, done1, p),
        ins3 (clk, reset, p, p2);

    always @ (posedge clk)
        if (reset) k <= c;
        else if (op & p) k <= k >> 1;

    always @ (posedge clk)
        if (reset) op <= 0;
        else if (p) op <= ~op;
    
    always @ (posedge clk)
        if (reset)  begin x2 <= 0; y2 <= 0; zero2 <= 1; end
        else if ((~op) & p) begin {x2,y2,zero2} <= {x7,y7,zero7}; end
    
    always @ (posedge clk)
        if (reset)  begin {x4,y4,zero4} <= {x1,y1,zero1}; end
        else if (op & p) begin {x4,y4,zero4} <= {x7,y7,zero7}; end
    
    always @ (posedge clk)
        if (reset)  begin x3 <= 0; y3 <= 0; zero3 <= 1; done <= 0; end
        else if (fin)
          begin {x3,y3,zero3} <= {x2,y2,zero2}; done <= 1; end
endmodule

/* add two points on the elliptic curve $y^2=x^3-x+1$ over a Galois field GF(3^M)
 * whose irreducible polynomial is $x^97 + x^12 + 2$. */
/* $P3(x3,y3) == P1 + P2$ for any points $P1(x1,y1),P2(x2,y2)$ */
module point_add(clk, reset, x1, y1, zero1, x2, y2, zero2, done, x3, y3, zero3);
    input clk, reset;
    input [`WIDTH:0] x1, y1; // this guy is $P1$
    input zero1; // asserted if P1 == 0
    input [`WIDTH:0] x2, y2; // and this guy is $P2$
    input zero2; // asserted if P2 == 0
    output reg done;
    output reg [`WIDTH:0] x3, y3; // ha ha, this guy is $P3$
    output reg zero3; // asserted if P3 == 0
    wire [`WIDTH:0] x3a, x3b, x3c,
                    y3a, y3b, y3c,
                    ny2;
    wire zero3a,
         done10, // asserted if $ins10$ finished
         done11;
    reg  use1,  // asserted if $ins9$ did the work
         cond1,
         cond2,
         cond3,
         cond4,
         cond5;
        
    f3m_neg 
        ins1 (y2, ny2); // ny2 == -y2
    func9
        ins9 (x1, y1, zero1, x2, y2, zero2, x3a, y3a, zero3a);
    func10
        ins10 (clk, reset, x1, y1, done10, x3b, y3b);
    func11
        ins11 (clk, reset, x1, y1, x2, y2, done11, x3c, y3c);
        
    always @ (posedge clk)
        if (reset)
          begin
            use1 <= 0;
            cond1 <= 0;
            cond2 <= 0;
            cond3 <= 0;
            cond4 <= 0;
            cond5 <= 0;
          end
        else
          begin
            use1 <= zero1 | zero2;
            cond1 <= (~use1) && cond2 && cond4; // asserted if $P1 == -P2$
            cond2 <= (x1 == x2);
            cond3 <= (y1 == y2);
            cond4 <= (y1 == ny2);
            cond5 <= (~use1) && cond2 && cond3; // asserted if $P1 == P2$
          end
    
    always @ (posedge clk)
        if (reset)
            zero3 <= 0;
        else
            zero3 <= (use1 & zero3a) | cond1; // if both of $P1$ and $P2$ are inf point, or $P1 == -P2$, then $P3$ is inf point
    
    always @ (posedge clk)
        if (reset)
            done <= 0;
        else
            done <= (use1 | cond1) ? 1 : (cond5 ? done10 : done11);
    
    always @ (posedge clk)
        if (reset)
          begin 
            x3 <= 0; y3 <= 0; 
          end
        else
          begin 
            x3 <= use1 ? x3a : (cond5 ? x3b : x3c);
            y3 <= use1 ? y3a : (cond5 ? y3b : y3c);
          end
endmodule

/* $P3 == P1+P2$ */
/* $P1$ and/or $P2$ is the infinite point */
module func9(x1, y1, zero1, x2, y2, zero2, x3, y3, zero3);
    input [`WIDTH:0] x1, y1, x2, y2;
    input zero1; // asserted if P1 == 0
    input zero2; // asserted if P2 == 0
    output [`WIDTH:0] x3, y3;
    output zero3; // asserted if P3 == 0
    
    assign zero3 = zero1 & zero2;
    
    genvar i;
    generate
        for (i=0; i<=`WIDTH; i=i+1)
          begin:label
            assign x3[i] = (x2[i] & zero1) | (x1[i] & zero2);
            assign y3[i] = (y2[i] & zero1) | (y1[i] & zero2);
          end
    endgenerate
endmodule

/* $P3 == P1+P2$ */
/* $P1$ or $P2$ is not the infinite point. $P1 == P2$ */
module func10(clk, reset, x1, y1, done, x3, y3);
    input clk, reset;
    input [`WIDTH:0] x1, y1;
    output reg done;
    output reg [`WIDTH:0] x3, y3;
    wire [`WIDTH:0] v1, v2, v3, v4, v5, v6;
    wire rst2, done1, done2;
    reg [2:0] K;
    
    f3m_inv
        ins1 (clk, reset, y1, v1, done1); // v1 == inv y1
    f3m_mult
        ins2 (clk, rst2, v1, v1, v2, done2); // v2 == v1^2
    f3m_cubic
        ins3 (v1, v3); // v3 == v1^3
    f3m_add
        ins4 (x1, v2, v4), // v4 == x1+v2 == x1 + (inv y1)^2
        ins5 (y1, v3, v5); // v5 == y1+v3 == y1 + (inv y1)^3
    f3m_neg
        ins6 (v5, v6); // v6 == -[y1 + (inv y1)^3]
    func6
        ins7 (clk, reset, done1, rst2);
    
    always @ (posedge clk)
        if (reset)
            K <= 3'b100;
        else if ((K[2]&rst2)|(K[1]&done2)|K[0])
            K <= K >> 1;
            
    always @ (posedge clk)
        if (reset)
          begin
            done <= 0; x3 <= 0; y3 <= 0;
          end
        else if (K[0])
          begin
            done <= 1; x3 <= v4; y3 <= v6;
          end
endmodule

/* $P3 == P1+P2$ */
/* $P1$ or $P2$ is not the infinite point. $P1 != P2, and P1 != -P2$ */
module func11(clk, reset, x1, y1, x2, y2, done, x3, y3);
    input clk, reset;
    input [`WIDTH:0] x1, y1, x2, y2;
    output reg done;
    output reg [`WIDTH:0] x3, y3;
    wire [`WIDTH:0] v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
    wire rst2, rst3, done1, done2, done3;
    reg [3:0] K;

    f3m_sub
        ins1 (x2, x1, v1), // v1 == x2-x1
        ins2 (y2, y1, v2); // v2 == y2-y1
    f3m_inv
        ins3 (clk, reset, v1, v3, done1); // v3 == inv v1 == inv(x2-x1)
    f3m_mult
        ins4 (clk, rst2, v2, v3, v4, done2), // v4 == v2*v3 == (y2-y1)/(x2-x1)
        ins5 (clk, rst3, v4, v4, v5, done3); // v5 == v4^2
    f3m_cubic
        ins6 (v4, v6); // v6 == v4^3
    f3m_add
        ins7 (x1, x2, v7), // v7 == x1+x2
        ins8 (y1, y2, v8); // v8 == y1+y2
    f3m_sub
        ins9 (v5, v7, v9), // v9 == v5-v7 == v4^2 - (x1+x2)
        ins10 (v8, v6, v10); // v10 == (y1+y2) - v4^3
    func6
        ins11 (clk, reset, done1, rst2),
        ins12 (clk, reset, done2, rst3);

    always @ (posedge clk)
        if (reset)
            K <= 4'b1000;
        else if ((K[3]&rst2)|(K[2]&rst3)|(K[1]&done3)|K[0])
            K <= K >> 1;
            
    always @ (posedge clk)
        if (reset)
          begin
            done <= 0; x3 <= 0; y3 <= 0;
          end
        else if (K[0])
          begin
            done <= 1; x3 <= v9; y3 <= v10;
          end
endmodule

module f3_add(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    wire a0, a1, b0, b1, c0, c1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C = {c1, c0};
    assign c0 = ( a0 & ~a1 & ~b0 & ~b1) |
                (~a0 & ~a1 &  b0 & ~b1) |
                (~a0 &  a1 & ~b0 &  b1) ;
    assign c1 = (~a0 &  a1 & ~b0 & ~b1) |
                ( a0 & ~a1 &  b0 & ~b1) |
                (~a0 & ~a1 & ~b0 &  b1) ;
endmodule

// f3_sub: C == A-B (mod 3)
module f3_sub(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    f3_add m1(A, {B[0], B[1]}, C);
endmodule

// f3_mult: C = A*B (mod 3)
module f3_mult(A, B, C); 
    input [1:0] A;
    input [1:0] B; 
    output [1:0] C;
    wire a0, a1, b0, b1;
    assign {a1, a0} = A;
    assign {b1, b0} = B;
    assign C[0] = (~a1 & a0 & ~b1 & b0) | (a1 & ~a0 & b1 & ~b0);
    assign C[1] = (~a1 & a0 & b1 & ~b0) | (a1 & ~a0 & ~b1 & b0);
endmodule

// c == a+1 (mod 3)
module f3_add1(a, c);
    input [1:0] a;
    output [1:0] c;
    assign c[0] = (~a[0]) & (~a[1]);
    assign c[1] = a[0] & (~a[1]);
endmodule

// c == a-1 (mod 3)
module f3_sub1(a, c);
    input [1:0] a;
    output [1:0] c;
    assign c[0] = (~a[0]) & a[1];
    assign c[1] = (~a[0]) & (~a[1]);
endmodule

//`include "inc.v"
`define MOST 2*`M+1:2*`M

// out = (v1 & l1) | (v2 & l2) | (v3 & l3)
module f3m_mux3(v1, l1, v2, l2, v3, l3, out);
    input [`WIDTH:0] v1, v2, v3;
    input l1, l2, l3;
    output [`WIDTH:0] out;
    genvar i;
    generate
        for(i=0;i<=`WIDTH;i=i+1)
          begin : label
            assign out[i] = (v1[i] & l1) | (v2[i] & l2) | (v3[i] & l3);
          end 
    endgenerate
endmodule

// out = (v0 & l0) | (v1 & l1) | (v2 & l2) | ... | (v5 & l5)
module f3m_mux6(v0, v1, v2, v3, v4, v5, l0, l1, l2, l3, l4, l5, out);
    input l0, l1, l2, l3, l4, l5;
    input [`WIDTH:0] v0, v1, v2, v3, v4, v5;
    output [`WIDTH:0] out;
    genvar i;
    generate
        for(i=0;i<=`WIDTH;i=i+1)
          begin : label
            assign out[i] = (v0[i]&l0)|(v1[i]&l1)|(v2[i]&l2)|(v3[i]&l3)|(v4[i]&l4)|(v5[i]&l5);
          end 
    endgenerate
endmodule

// f3m_add: C = A + B, in field F_{3^M}
module f3m_add(A, B, C);
    input [`WIDTH : 0] A, B;
    output [`WIDTH : 0] C;
    genvar i;
    generate
        for(i=0; i<`M; i=i+1) begin: aa
            f3_add aa(A[(2*i+1) : 2*i], B[(2*i+1) : 2*i], C[(2*i+1) : 2*i]);
        end
    endgenerate
endmodule

// f3m_add3: c == a0+a1+a2, in field GF(3^M)
module f3m_add3(a0, a1, a2, c);
    input [`WIDTH:0] a0,a1,a2;
    output [`WIDTH:0] c;
    wire [`WIDTH:0] v;
    f3m_add
        ins1 (a0,a1,v), // v == a0+a1
        ins2 (v,a2,c);  // c == v+a2 == a0+a1+a2
endmodule

// f3m_add4: c == a0+a1+a2+a3, in field GF(3^M)
module f3m_add4(a0, a1, a2, a3, c);
    input [`WIDTH:0] a0,a1,a2,a3;
    output [`WIDTH:0] c;
    wire [`WIDTH:0] v1,v2;
    f3m_add
        ins1 (a0,a1,v1), // v1 == a0+a1
        ins2 (a2,a3,v2), // v2 == a2+a3
        ins3 (v1,v2,c);  // c == v1+v2 == a0+a1+a2+a3
endmodule

// f3m_neg: c == -a in GF(3^M)
module f3m_neg(a, c);
    input [`WIDTH:0] a;
    output [`WIDTH:0] c;
    genvar i;
    generate
        for(i=0;i<=`WIDTH;i=i+2)
          begin:label
            assign c[i+1:i] = {a[i],a[i+1]};
          end
    endgenerate
endmodule

// f3m_sub: C = A - B, in field F_{3^M}
module f3m_sub(A, B, C);
    input [`WIDTH : 0] A, B;
    output [`WIDTH : 0] C;
    genvar i;
    generate
        for(i=0; i<`M; i=i+1) begin: aa
            f3_sub aa(A[(2*i+1) : 2*i], B[(2*i+1) : 2*i], C[(2*i+1) : 2*i]);
        end
    endgenerate
endmodule

// f3m_mult: C = A * B, in field GF(3^M)
module f3m_mult(clk, reset, A, B, C, done);
    input [`WIDTH : 0] A, B;
    input clk;
    input reset;
    output reg [`WIDTH : 0] C;
    output reg done;
    reg [`WIDTH : 0] x, y, z;
    wire [`WIDTH : 0] z1, z2, z3, z4;
    reg [`M/3+1 : 0] i;
    wire done1;
    wire [1:0] dummy;

    func8 
        ins1 (x, y[5:0], z1); // z1 == A * (B[2]*x^2 + B[1]*x + B[0])
    f3m_add
        ins2 (z1, z, z2); // z2 == z1 + z == A * (B[2]*x^2 + B[1]*x + B[0]) + z
    assign z4 = y >> 6; // z4 == y >> 6
    func7
        ins3 (x, z3); // z3 == X*(x^3) mod p(x)
    assign done1 = i[0];
    
    always @ (posedge clk)
        if (done1)
            C <= z;
    
    always @ (posedge clk)
        if (reset)
            done <= 0;
        else if (done1)
            done <= 1;

    always @ (posedge clk) 
      begin
        if (reset)
          begin
            x <= A; y <= B; z <= 0; i <= {1'b1,{(`M/3+1){1'b0}}};
          end
        else
          begin
            x <= z3[`WIDTH:0]; y <= z4; z <= z2; i <= i >> 1;
          end
      end
endmodule

// c0 == a0*b0; c1 == a1*b1; c2 == a2*b2; all in GF(3^M)
module f3m_mult3(clk, reset, 
                 a0, b0, c0,
                 a1, b1, c1, 
                 a2, b2, c2, 
                 done);
    input clk, reset;
    input [`WIDTH:0] a0, b0, a1, b1, a2, b2;
    output reg [`WIDTH:0] c0, c1, c2;
    output reg done;
    reg [3:0] K;
    reg mult_reset, delay1, delay2;
    wire e1, e2, e3, mult_done, delay3, rst;
    wire [`WIDTH:0] in1, in2, o;
    
    assign rst = delay2;
    assign {e1,e2,e3} = K[3:1];

    f3m_mux3
        ins9 (a0, e1, a1, e2, a2, e3, in1),
        ins10 (b0, e1, b1, e2, b2, e3, in2);
    f3m_mult
        ins11 (clk, mult_reset, in1, in2, o, mult_done); // o == in1 * in2 in GF(3^m)
    func6
        ins12 (clk, reset, mult_done, delay3);

    always @ (posedge clk)
      begin
        if (e1) c0 <= o;
        if (e2) c1 <= o;
        if (e3) c2 <= o;
      end
    
    always @ (posedge clk)
        if (reset) K <= 4'b1000;
        else if (delay3 | K[0]) K <= {1'b0,K[3:1]};
    
    always @ (posedge clk)
      begin
        if (rst) mult_reset <= 1;
        else if (mult_done) mult_reset <= 1;
        else mult_reset <= 0;
      end

    always @ (posedge clk)
        if (reset)     done <= 0;
        else if (K[0]) done <= 1;
    
    always @ (posedge clk)
      begin 
        delay2 <= delay1; delay1 <= reset; 
      end
endmodule

/* out == in^3 mod p(x) */
/* p(x) == x^97 + x^12 + 2 */
module f3m_cubic(input wire [193:0] in, output wire [193:0] out);
wire [1:0] w0; f3_add a0(in[131:130], in[139:138], w0);
wire [1:0] w1; f3_add a1(in[133:132], in[141:140], w1);
wire [1:0] w2; f3_add a2(in[135:134], in[143:142], w2);
wire [1:0] w3; f3_add a3(in[137:136], in[145:144], w3);
wire [1:0] w4; f3_add a4(in[147:146], in[155:154], w4);
wire [1:0] w5; f3_add a5(in[149:148], in[157:156], w5);
wire [1:0] w6; f3_add a6(in[151:150], in[159:158], w6);
wire [1:0] w7; f3_add a7(in[153:152], in[161:160], w7);
wire [1:0] w8; f3_add a8(in[163:162], in[171:170], w8);
wire [1:0] w9; f3_add a9(in[165:164], in[173:172], w9);
wire [1:0] w10; f3_add a10(in[167:166], in[175:174], w10);
wire [1:0] w11; f3_add a11(in[169:168], in[177:176], w11);
wire [1:0] w12; f3_add a12(in[179:178], in[187:186], w12);
wire [1:0] w13; f3_add a13(in[181:180], in[189:188], w13);
wire [1:0] w14; f3_add a14(in[183:182], in[191:190], w14);
wire [1:0] w15; f3_add a15(in[185:184], in[193:192], w15);
wire [1:0] w16;
f3_add a16(in[1:0], w12, w16);
assign out[1:0] = w16;
wire [1:0] w17;
f3_add a17({in[122],in[123]}, in[131:130], w17);
assign out[3:2] = w17;
assign out[5:4] = in[67:66];
wire [1:0] w18;
f3_add a18(in[3:2], w13, w18);
assign out[7:6] = w18;
wire [1:0] w19;
f3_add a19({in[124],in[125]}, in[133:132], w19);
assign out[9:8] = w19;
assign out[11:10] = in[69:68];
wire [1:0] w20;
f3_add a20(in[5:4], w14, w20);
assign out[13:12] = w20;
wire [1:0] w21;
f3_add a21({in[126],in[127]}, in[135:134], w21);
assign out[15:14] = w21;
assign out[17:16] = in[71:70];
wire [1:0] w22;
f3_add a22(in[7:6], w15, w22);
assign out[19:18] = w22;
wire [1:0] w23;
f3_add a23({in[128],in[129]}, in[137:136], w23);
assign out[21:20] = w23;
assign out[23:22] = in[73:72];
wire [1:0] w24;
f3_add a24(in[9:8], {in[178],in[179]}, w24);
assign out[25:24] = w24;
wire [1:0] w25;
f3_add a25(in[123:122], w0, w25);
assign out[27:26] = w25;
wire [1:0] w26;
f3_add a26({in[66],in[67]}, in[75:74], w26);
assign out[29:28] = w26;
wire [1:0] w27;
f3_add a27(in[11:10], {in[180],in[181]}, w27);
assign out[31:30] = w27;
wire [1:0] w28;
f3_add a28(in[125:124], w1, w28);
assign out[33:32] = w28;
wire [1:0] w29;
f3_add a29({in[68],in[69]}, in[77:76], w29);
assign out[35:34] = w29;
wire [1:0] w30;
f3_add a30(in[13:12], {in[182],in[183]}, w30);
assign out[37:36] = w30;
wire [1:0] w31;
f3_add a31(in[127:126], w2, w31);
assign out[39:38] = w31;
wire [1:0] w32;
f3_add a32({in[70],in[71]}, in[79:78], w32);
assign out[41:40] = w32;
wire [1:0] w33;
f3_add a33(in[15:14], {in[184],in[185]}, w33);
assign out[43:42] = w33;
wire [1:0] w34;
f3_add a34(in[129:128], w3, w34);
assign out[45:44] = w34;
wire [1:0] w35;
f3_add a35({in[72],in[73]}, in[81:80], w35);
assign out[47:46] = w35;
wire [1:0] w36;
f3_add a36(in[17:16], {in[186],in[187]}, w36);
assign out[49:48] = w36;
wire [1:0] w37;
f3_add a37(in[147:146], w0, w37);
assign out[51:50] = w37;
wire [1:0] w38;
f3_add a38({in[74],in[75]}, in[83:82], w38);
assign out[53:52] = w38;
wire [1:0] w39;
f3_add a39(in[19:18], {in[188],in[189]}, w39);
assign out[55:54] = w39;
wire [1:0] w40;
f3_add a40(in[149:148], w1, w40);
assign out[57:56] = w40;
wire [1:0] w41;
f3_add a41({in[76],in[77]}, in[85:84], w41);
assign out[59:58] = w41;
wire [1:0] w42;
f3_add a42(in[21:20], {in[190],in[191]}, w42);
assign out[61:60] = w42;
wire [1:0] w43;
f3_add a43(in[151:150], w2, w43);
assign out[63:62] = w43;
wire [1:0] w44;
f3_add a44({in[78],in[79]}, in[87:86], w44);
assign out[65:64] = w44;
wire [1:0] w45;
f3_add a45(in[23:22], {in[192],in[193]}, w45);
assign out[67:66] = w45;
wire [1:0] w46;
f3_add a46(in[153:152], w3, w46);
assign out[69:68] = w46;
wire [1:0] w47;
f3_add a47({in[80],in[81]}, in[89:88], w47);
assign out[71:70] = w47;
assign out[73:72] = in[25:24];
wire [1:0] w48;
f3_add a48(in[139:138], w4, w48);
assign out[75:74] = w48;
wire [1:0] w49;
f3_add a49({in[82],in[83]}, in[91:90], w49);
assign out[77:76] = w49;
assign out[79:78] = in[27:26];
wire [1:0] w50;
f3_add a50(in[141:140], w5, w50);
assign out[81:80] = w50;
wire [1:0] w51;
f3_add a51({in[84],in[85]}, in[93:92], w51);
assign out[83:82] = w51;
assign out[85:84] = in[29:28];
wire [1:0] w52;
f3_add a52(in[143:142], w6, w52);
assign out[87:86] = w52;
wire [1:0] w53;
f3_add a53({in[86],in[87]}, in[95:94], w53);
assign out[89:88] = w53;
assign out[91:90] = in[31:30];
wire [1:0] w54;
f3_add a54(in[145:144], w7, w54);
assign out[93:92] = w54;
wire [1:0] w55;
f3_add a55({in[88],in[89]}, in[97:96], w55);
assign out[95:94] = w55;
assign out[97:96] = in[33:32];
wire [1:0] w56;
f3_add a56(in[163:162], w4, w56);
assign out[99:98] = w56;
wire [1:0] w57;
f3_add a57({in[90],in[91]}, in[99:98], w57);
assign out[101:100] = w57;
assign out[103:102] = in[35:34];
wire [1:0] w58;
f3_add a58(in[165:164], w5, w58);
assign out[105:104] = w58;
wire [1:0] w59;
f3_add a59({in[92],in[93]}, in[101:100], w59);
assign out[107:106] = w59;
assign out[109:108] = in[37:36];
wire [1:0] w60;
f3_add a60(in[167:166], w6, w60);
assign out[111:110] = w60;
wire [1:0] w61;
f3_add a61({in[94],in[95]}, in[103:102], w61);
assign out[113:112] = w61;
assign out[115:114] = in[39:38];
wire [1:0] w62;
f3_add a62(in[169:168], w7, w62);
assign out[117:116] = w62;
wire [1:0] w63;
f3_add a63({in[96],in[97]}, in[105:104], w63);
assign out[119:118] = w63;
assign out[121:120] = in[41:40];
wire [1:0] w64;
f3_add a64(in[155:154], w8, w64);
assign out[123:122] = w64;
wire [1:0] w65;
f3_add a65({in[98],in[99]}, in[107:106], w65);
assign out[125:124] = w65;
assign out[127:126] = in[43:42];
wire [1:0] w66;
f3_add a66(in[157:156], w9, w66);
assign out[129:128] = w66;
wire [1:0] w67;
f3_add a67({in[100],in[101]}, in[109:108], w67);
assign out[131:130] = w67;
assign out[133:132] = in[45:44];
wire [1:0] w68;
f3_add a68(in[159:158], w10, w68);
assign out[135:134] = w68;
wire [1:0] w69;
f3_add a69({in[102],in[103]}, in[111:110], w69);
assign out[137:136] = w69;
assign out[139:138] = in[47:46];
wire [1:0] w70;
f3_add a70(in[161:160], w11, w70);
assign out[141:140] = w70;
wire [1:0] w71;
f3_add a71({in[104],in[105]}, in[113:112], w71);
assign out[143:142] = w71;
assign out[145:144] = in[49:48];
wire [1:0] w72;
f3_add a72(in[179:178], w8, w72);
assign out[147:146] = w72;
wire [1:0] w73;
f3_add a73({in[106],in[107]}, in[115:114], w73);
assign out[149:148] = w73;
assign out[151:150] = in[51:50];
wire [1:0] w74;
f3_add a74(in[181:180], w9, w74);
assign out[153:152] = w74;
wire [1:0] w75;
f3_add a75({in[108],in[109]}, in[117:116], w75);
assign out[155:154] = w75;
assign out[157:156] = in[53:52];
wire [1:0] w76;
f3_add a76(in[183:182], w10, w76);
assign out[159:158] = w76;
wire [1:0] w77;
f3_add a77({in[110],in[111]}, in[119:118], w77);
assign out[161:160] = w77;
assign out[163:162] = in[55:54];
wire [1:0] w78;
f3_add a78(in[185:184], w11, w78);
assign out[165:164] = w78;
wire [1:0] w79;
f3_add a79({in[112],in[113]}, in[121:120], w79);
assign out[167:166] = w79;
assign out[169:168] = in[57:56];
wire [1:0] w80;
f3_add a80(in[171:170], w12, w80);
assign out[171:170] = w80;
wire [1:0] w81;
f3_add a81({in[114],in[115]}, in[123:122], w81);
assign out[173:172] = w81;
assign out[175:174] = in[59:58];
wire [1:0] w82;
f3_add a82(in[173:172], w13, w82);
assign out[177:176] = w82;
wire [1:0] w83;
f3_add a83({in[116],in[117]}, in[125:124], w83);
assign out[179:178] = w83;
assign out[181:180] = in[61:60];
wire [1:0] w84;
f3_add a84(in[175:174], w14, w84);
assign out[183:182] = w84;
wire [1:0] w85;
f3_add a85({in[118],in[119]}, in[127:126], w85);
assign out[185:184] = w85;
assign out[187:186] = in[63:62];
wire [1:0] w86;
f3_add a86(in[177:176], w15, w86);
assign out[189:188] = w86;
wire [1:0] w87;
f3_add a87({in[120],in[121]}, in[129:128], w87);
assign out[191:190] = w87;
assign out[193:192] = in[65:64];
endmodule

/* nine square in GF(3^m), out = in^9 mod p(x) */
/* p(x) == x^97 + x^12 + 2 */
module f3m_nine(clk, in, out);
    input clk;
    input [`WIDTH:0] in;
    output reg [`WIDTH:0] out;
    wire [`WIDTH:0] a,b;
    f3m_cubic
        ins1 (in, a), // a == in^3
        ins2 (a, b);  // b == a^3 == in^9
    always @ (posedge clk)
        out <= b;
endmodule

// inversion in GF(3^m). C = A^(-1)
module f3m_inv(clk, reset, A, C, done);
    input [`WIDTH:0] A;
    input clk;
    input reset;
    output reg [`WIDTH:0] C;
    output reg done;
    
    reg [`WIDTH+2:0] S, R, U, V, d;
    reg [2*`M:0] i;
    wire [1:0] q;
    wire [`WIDTH+2:0] S1, S2,
                      R1,
                      U1, U2, U3,
                      V1, V2,
                      d1, d2;
    wire don;

    assign d1 = {d[`WIDTH+1:0], 1'b1}; // d1 == d+1
    assign d2 = {1'b0, d[`WIDTH+2:1]}; // d2 == d-1
    assign don = i[0];
    
    f3_mult 
        q1(S[`MOST], R[`MOST], q); // q = s_m / r_m
    func1
        ins1(S, R, q, S1), // S1 = S - q*R
        ins2(V, U, q, V1); // V1 = V - q*U
    func2
        ins3(S1, S2), // S2 = x*S1 = x*(S-q*R)
        ins4(R, R1); // R1 = x*R
    func3
        ins5(U, U1), // U1 = x*U mod p
        ins6(V1, V2); // V2 = x*V1 mod p = x*(V-qU) mod p
    func4
        ins7(U, R[`MOST], U2); // U2 = U/r_m
    func5
        ins8(U, U3); // U3 = (U/x) mod p
    
    always @ (posedge clk)
        if (reset)
            done <= 0;
        else if (don)
          begin
            done <= 1; C <= U2[`WIDTH:0];
          end

    always @ (posedge clk) 
        if (reset)
            i <= {1'b1, {(2*`M){1'b0}}};
        else
            i <= i >> 1;
    
    always @ (posedge clk)
        if (reset) 
          begin
            S<=`PX; R<=A; U<=1; V<=0; d<=0;
          end
        else if (R[`MOST] == 2'b0)
          begin
            R<=R1; U<=U1; d<=d1;
          end
        else if (d[0] == 1'b0) // d == 0
          begin
            R<=S2; S<=R; U<=V2; V<=U; d<=d1;
          end
        else // d != 0
          begin
            S<=S2; V<=V1; U<=U3; d<=d2;
          end
endmodule

// put func1~5 here for breaking circular dependency in "f3m", "fun"

// out = S - q*R
module func1(S, R, q, out);
    input [`WIDTH+2:0] S, R;
    input [1:0] q;
    output [`WIDTH+2:0] out;
    wire [`WIDTH+2:0] t;
    func4 f(R, q, t); // t == q*R
    genvar i;
    generate for(i=0; i<=`WIDTH+2; i=i+2) begin: label
        f3_sub s1(S[i+1:i], t[i+1:i], out[i+1:i]); // out == S - t
    end endgenerate
endmodule

// out = x*A
module func2(A, out);
    input [`WIDTH+2:0] A;
    output [`WIDTH+2:0] out;
    assign out = {A[`WIDTH:0], 2'd0};
endmodule

// C = (x*B mod p(x))
module func3(B, C);
    input [`WIDTH+2:0] B;
    output [`WIDTH+2:0] C;
    wire [`WIDTH+2:0] A;
    assign A = {B[`WIDTH:0], 2'd0}; // A == B*x
    wire [1:0] w0;
    f3_mult m0 (A[195:194], 2'd2, w0);
    f3_sub s0 (A[1:0], w0, C[1:0]);
    assign C[23:2] = A[23:2];
    wire [1:0] w12;
    f3_mult m12 (A[195:194], 2'd1, w12);
    f3_sub s12 (A[25:24], w12, C[25:24]);
    assign C[193:26] = A[193:26];
    assign C[195:194] = 0;
endmodule

// C = a * A; A,C \in GF(3^m); a \in GF(3)
module func4(A, aa, C);
    input [`WIDTH+2:0] A;
    input [1:0] aa;
    output [`WIDTH+2:0] C;
    genvar i;
    generate
      for(i=0; i<=`WIDTH+2; i=i+2) 
      begin: label
        f3_mult m(A[i+1:i], aa, C[i+1:i]);
      end 
    endgenerate
endmodule

// C = (A/x) mod p, \in GF(3^m)
module func5(A, C);
    input [`WIDTH+2:0] A;
    output [`WIDTH+2:0] C;
    assign C[195:194] = 0;
    assign C[193:192] = A[1:0];
    assign C[191:24] = A[193:26];
    f3_add a11 (A[25:24], A[1:0], C[23:22]);
    assign C[21:0] = A[23:2];
endmodule

/* $C=A*(x^3) mod p(x)$ */
/* p(x) == x^97 + x^12 + 2 */
module func7(input wire [193:0] in, output wire [193:0] out);
    assign out[5:0] = in[193:188];
    assign out[23:6] = in[17:0];
    wire [1:0] w0;
    f3_add a0(in[19:18], {in[188],in[189]}, w0);
    assign out[25:24] = w0;
    wire [1:0] w1;
    f3_add a1(in[21:20], {in[190],in[191]}, w1);
    assign out[27:26] = w1;
    wire [1:0] w2;
    f3_add a2(in[23:22], {in[192],in[193]}, w2);
    assign out[29:28] = w2;
    assign out[193:30] = in[187:24];
endmodule

/* c = (b_2 x^2 + b_1 x + b_0)*A mod p(x) */
module func8 (a, b, c);
input [193:0] a;
input [5:0] b;
output [193:0] c;
wire [1:0] w1; f3_mult m2 (a[1:0], b[1:0], w1);
wire [1:0] w3; f3_mult m4 (a[191:190], b[5:4], w3);
wire [1:0] w5; f3_mult m6 (a[193:192], b[3:2], w5);
wire [1:0] w7; f3_add a8 (w1, w3, w7);
wire [1:0] w9; f3_add a10 (w7, w5, w9);
assign c[1:0] = w9;
wire [1:0] w11; f3_mult m12 (a[1:0], b[3:2], w11);
wire [1:0] w13; f3_mult m14 (a[193:192], b[5:4], w13);
wire [1:0] w15; f3_mult m16 (a[3:2], b[1:0], w15);
wire [1:0] w17; f3_add a18 (w11, w13, w17);
wire [1:0] w19; f3_add a20 (w17, w15, w19);
assign c[3:2] = w19;
wire [1:0] w21; f3_mult m22 (a[5:4], b[1:0], w21);
wire [1:0] w23; f3_mult m24 (a[1:0], b[5:4], w23);
wire [1:0] w25; f3_mult m26 (a[3:2], b[3:2], w25);
wire [1:0] w27; f3_add a28 (w21, w23, w27);
wire [1:0] w29; f3_add a30 (w27, w25, w29);
assign c[5:4] = w29;
wire [1:0] w31; f3_mult m32 (a[7:6], b[1:0], w31);
wire [1:0] w33; f3_mult m34 (a[3:2], b[5:4], w33);
wire [1:0] w35; f3_mult m36 (a[5:4], b[3:2], w35);
wire [1:0] w37; f3_add a38 (w31, w33, w37);
wire [1:0] w39; f3_add a40 (w37, w35, w39);
assign c[7:6] = w39;
wire [1:0] w41; f3_mult m42 (a[7:6], b[3:2], w41);
wire [1:0] w43; f3_mult m44 (a[9:8], b[1:0], w43);
wire [1:0] w45; f3_mult m46 (a[5:4], b[5:4], w45);
wire [1:0] w47; f3_add a48 (w41, w43, w47);
wire [1:0] w49; f3_add a50 (w47, w45, w49);
assign c[9:8] = w49;
wire [1:0] w51; f3_mult m52 (a[11:10], b[1:0], w51);
wire [1:0] w53; f3_mult m54 (a[7:6], b[5:4], w53);
wire [1:0] w55; f3_mult m56 (a[9:8], b[3:2], w55);
wire [1:0] w57; f3_add a58 (w51, w53, w57);
wire [1:0] w59; f3_add a60 (w57, w55, w59);
assign c[11:10] = w59;
wire [1:0] w61; f3_mult m62 (a[13:12], b[1:0], w61);
wire [1:0] w63; f3_mult m64 (a[11:10], b[3:2], w63);
wire [1:0] w65; f3_mult m66 (a[9:8], b[5:4], w65);
wire [1:0] w67; f3_add a68 (w61, w63, w67);
wire [1:0] w69; f3_add a70 (w67, w65, w69);
assign c[13:12] = w69;
wire [1:0] w71; f3_mult m72 (a[13:12], b[3:2], w71);
wire [1:0] w73; f3_mult m74 (a[15:14], b[1:0], w73);
wire [1:0] w75; f3_mult m76 (a[11:10], b[5:4], w75);
wire [1:0] w77; f3_add a78 (w71, w73, w77);
wire [1:0] w79; f3_add a80 (w77, w75, w79);
assign c[15:14] = w79;
wire [1:0] w81; f3_mult m82 (a[13:12], b[5:4], w81);
wire [1:0] w83; f3_mult m84 (a[15:14], b[3:2], w83);
wire [1:0] w85; f3_mult m86 (a[17:16], b[1:0], w85);
wire [1:0] w87; f3_add a88 (w81, w83, w87);
wire [1:0] w89; f3_add a90 (w87, w85, w89);
assign c[17:16] = w89;
wire [1:0] w91; f3_mult m92 (a[15:14], b[5:4], w91);
wire [1:0] w93; f3_mult m94 (a[19:18], b[1:0], w93);
wire [1:0] w95; f3_mult m96 (a[17:16], b[3:2], w95);
wire [1:0] w97; f3_add a98 (w91, w93, w97);
wire [1:0] w99; f3_add a100 (w97, w95, w99);
assign c[19:18] = w99;
wire [1:0] w101; f3_mult m102 (a[21:20], b[1:0], w101);
wire [1:0] w103; f3_mult m104 (a[17:16], b[5:4], w103);
wire [1:0] w105; f3_mult m106 (a[19:18], b[3:2], w105);
wire [1:0] w107; f3_add a108 (w101, w103, w107);
wire [1:0] w109; f3_add a110 (w107, w105, w109);
assign c[21:20] = w109;
wire [1:0] w111; f3_mult m112 (a[23:22], b[1:0], w111);
wire [1:0] w113; f3_mult m114 (a[19:18], b[5:4], w113);
wire [1:0] w115; f3_mult m116 (a[21:20], b[3:2], w115);
wire [1:0] w117; f3_add a118 (w111, w113, w117);
wire [1:0] w119; f3_add a120 (w117, w115, w119);
assign c[23:22] = w119;
wire [1:0] w121; f3_mult m122 (a[23:22], b[3:2], w121);
wire [1:0] w123; f3_mult m124 (a[25:24], b[1:0], w123);
wire [1:0] w125; f3_mult m126 (a[21:20], b[5:4], w125);
wire [1:0] w127; f3_add a128 (w121, w123, w127);
wire [1:0] w129; f3_add a130 (w127, w125, w129);
wire [1:0] w131; f3_add a132 (w129, {w5[0], w5[1]}, w131);
wire [1:0] w133; f3_add a134 (w131, {w3[0], w3[1]}, w133);
assign c[25:24] = w133;
wire [1:0] w135; f3_mult m136 (a[27:26], b[1:0], w135);
wire [1:0] w137; f3_mult m138 (a[23:22], b[5:4], w137);
wire [1:0] w139; f3_mult m140 (a[25:24], b[3:2], w139);
wire [1:0] w141; f3_add a142 ({w13[0], w13[1]}, w135, w141);
wire [1:0] w143; f3_add a144 (w141, w137, w143);
wire [1:0] w145; f3_add a146 (w143, w139, w145);
assign c[27:26] = w145;
wire [1:0] w147; f3_mult m148 (a[29:28], b[1:0], w147);
wire [1:0] w149; f3_mult m150 (a[27:26], b[3:2], w149);
wire [1:0] w151; f3_mult m152 (a[25:24], b[5:4], w151);
wire [1:0] w153; f3_add a154 (w147, w149, w153);
wire [1:0] w155; f3_add a156 (w153, w151, w155);
assign c[29:28] = w155;
wire [1:0] w157; f3_mult m158 (a[29:28], b[3:2], w157);
wire [1:0] w159; f3_mult m160 (a[31:30], b[1:0], w159);
wire [1:0] w161; f3_mult m162 (a[27:26], b[5:4], w161);
wire [1:0] w163; f3_add a164 (w157, w159, w163);
wire [1:0] w165; f3_add a166 (w163, w161, w165);
assign c[31:30] = w165;
wire [1:0] w167; f3_mult m168 (a[29:28], b[5:4], w167);
wire [1:0] w169; f3_mult m170 (a[31:30], b[3:2], w169);
wire [1:0] w171; f3_mult m172 (a[33:32], b[1:0], w171);
wire [1:0] w173; f3_add a174 (w167, w169, w173);
wire [1:0] w175; f3_add a176 (w173, w171, w175);
assign c[33:32] = w175;
wire [1:0] w177; f3_mult m178 (a[31:30], b[5:4], w177);
wire [1:0] w179; f3_mult m180 (a[35:34], b[1:0], w179);
wire [1:0] w181; f3_mult m182 (a[33:32], b[3:2], w181);
wire [1:0] w183; f3_add a184 (w177, w179, w183);
wire [1:0] w185; f3_add a186 (w183, w181, w185);
assign c[35:34] = w185;
wire [1:0] w187; f3_mult m188 (a[37:36], b[1:0], w187);
wire [1:0] w189; f3_mult m190 (a[33:32], b[5:4], w189);
wire [1:0] w191; f3_mult m192 (a[35:34], b[3:2], w191);
wire [1:0] w193; f3_add a194 (w187, w189, w193);
wire [1:0] w195; f3_add a196 (w193, w191, w195);
assign c[37:36] = w195;
wire [1:0] w197; f3_mult m198 (a[39:38], b[1:0], w197);
wire [1:0] w199; f3_mult m200 (a[35:34], b[5:4], w199);
wire [1:0] w201; f3_mult m202 (a[37:36], b[3:2], w201);
wire [1:0] w203; f3_add a204 (w197, w199, w203);
wire [1:0] w205; f3_add a206 (w203, w201, w205);
assign c[39:38] = w205;
wire [1:0] w207; f3_mult m208 (a[39:38], b[3:2], w207);
wire [1:0] w209; f3_mult m210 (a[41:40], b[1:0], w209);
wire [1:0] w211; f3_mult m212 (a[37:36], b[5:4], w211);
wire [1:0] w213; f3_add a214 (w207, w209, w213);
wire [1:0] w215; f3_add a216 (w213, w211, w215);
assign c[41:40] = w215;
wire [1:0] w217; f3_mult m218 (a[43:42], b[1:0], w217);
wire [1:0] w219; f3_mult m220 (a[39:38], b[5:4], w219);
wire [1:0] w221; f3_mult m222 (a[41:40], b[3:2], w221);
wire [1:0] w223; f3_add a224 (w217, w219, w223);
wire [1:0] w225; f3_add a226 (w223, w221, w225);
assign c[43:42] = w225;
wire [1:0] w227; f3_mult m228 (a[45:44], b[1:0], w227);
wire [1:0] w229; f3_mult m230 (a[43:42], b[3:2], w229);
wire [1:0] w231; f3_mult m232 (a[41:40], b[5:4], w231);
wire [1:0] w233; f3_add a234 (w227, w229, w233);
wire [1:0] w235; f3_add a236 (w233, w231, w235);
assign c[45:44] = w235;
wire [1:0] w237; f3_mult m238 (a[45:44], b[3:2], w237);
wire [1:0] w239; f3_mult m240 (a[47:46], b[1:0], w239);
wire [1:0] w241; f3_mult m242 (a[43:42], b[5:4], w241);
wire [1:0] w243; f3_add a244 (w237, w239, w243);
wire [1:0] w245; f3_add a246 (w243, w241, w245);
assign c[47:46] = w245;
wire [1:0] w247; f3_mult m248 (a[45:44], b[5:4], w247);
wire [1:0] w249; f3_mult m250 (a[47:46], b[3:2], w249);
wire [1:0] w251; f3_mult m252 (a[49:48], b[1:0], w251);
wire [1:0] w253; f3_add a254 (w247, w249, w253);
wire [1:0] w255; f3_add a256 (w253, w251, w255);
assign c[49:48] = w255;
wire [1:0] w257; f3_mult m258 (a[47:46], b[5:4], w257);
wire [1:0] w259; f3_mult m260 (a[51:50], b[1:0], w259);
wire [1:0] w261; f3_mult m262 (a[49:48], b[3:2], w261);
wire [1:0] w263; f3_add a264 (w257, w259, w263);
wire [1:0] w265; f3_add a266 (w263, w261, w265);
assign c[51:50] = w265;
wire [1:0] w267; f3_mult m268 (a[53:52], b[1:0], w267);
wire [1:0] w269; f3_mult m270 (a[49:48], b[5:4], w269);
wire [1:0] w271; f3_mult m272 (a[51:50], b[3:2], w271);
wire [1:0] w273; f3_add a274 (w267, w269, w273);
wire [1:0] w275; f3_add a276 (w273, w271, w275);
assign c[53:52] = w275;
wire [1:0] w277; f3_mult m278 (a[55:54], b[1:0], w277);
wire [1:0] w279; f3_mult m280 (a[51:50], b[5:4], w279);
wire [1:0] w281; f3_mult m282 (a[53:52], b[3:2], w281);
wire [1:0] w283; f3_add a284 (w277, w279, w283);
wire [1:0] w285; f3_add a286 (w283, w281, w285);
assign c[55:54] = w285;
wire [1:0] w287; f3_mult m288 (a[55:54], b[3:2], w287);
wire [1:0] w289; f3_mult m290 (a[57:56], b[1:0], w289);
wire [1:0] w291; f3_mult m292 (a[53:52], b[5:4], w291);
wire [1:0] w293; f3_add a294 (w287, w289, w293);
wire [1:0] w295; f3_add a296 (w293, w291, w295);
assign c[57:56] = w295;
wire [1:0] w297; f3_mult m298 (a[59:58], b[1:0], w297);
wire [1:0] w299; f3_mult m300 (a[55:54], b[5:4], w299);
wire [1:0] w301; f3_mult m302 (a[57:56], b[3:2], w301);
wire [1:0] w303; f3_add a304 (w297, w299, w303);
wire [1:0] w305; f3_add a306 (w303, w301, w305);
assign c[59:58] = w305;
wire [1:0] w307; f3_mult m308 (a[61:60], b[1:0], w307);
wire [1:0] w309; f3_mult m310 (a[59:58], b[3:2], w309);
wire [1:0] w311; f3_mult m312 (a[57:56], b[5:4], w311);
wire [1:0] w313; f3_add a314 (w307, w309, w313);
wire [1:0] w315; f3_add a316 (w313, w311, w315);
assign c[61:60] = w315;
wire [1:0] w317; f3_mult m318 (a[61:60], b[3:2], w317);
wire [1:0] w319; f3_mult m320 (a[63:62], b[1:0], w319);
wire [1:0] w321; f3_mult m322 (a[59:58], b[5:4], w321);
wire [1:0] w323; f3_add a324 (w317, w319, w323);
wire [1:0] w325; f3_add a326 (w323, w321, w325);
assign c[63:62] = w325;
wire [1:0] w327; f3_mult m328 (a[61:60], b[5:4], w327);
wire [1:0] w329; f3_mult m330 (a[63:62], b[3:2], w329);
wire [1:0] w331; f3_mult m332 (a[65:64], b[1:0], w331);
wire [1:0] w333; f3_add a334 (w327, w329, w333);
wire [1:0] w335; f3_add a336 (w333, w331, w335);
assign c[65:64] = w335;
wire [1:0] w337; f3_mult m338 (a[67:66], b[1:0], w337);
wire [1:0] w339; f3_mult m340 (a[63:62], b[5:4], w339);
wire [1:0] w341; f3_mult m342 (a[65:64], b[3:2], w341);
wire [1:0] w343; f3_add a344 (w337, w339, w343);
wire [1:0] w345; f3_add a346 (w343, w341, w345);
assign c[67:66] = w345;
wire [1:0] w347; f3_mult m348 (a[69:68], b[1:0], w347);
wire [1:0] w349; f3_mult m350 (a[65:64], b[5:4], w349);
wire [1:0] w351; f3_mult m352 (a[67:66], b[3:2], w351);
wire [1:0] w353; f3_add a354 (w347, w349, w353);
wire [1:0] w355; f3_add a356 (w353, w351, w355);
assign c[69:68] = w355;
wire [1:0] w357; f3_mult m358 (a[71:70], b[1:0], w357);
wire [1:0] w359; f3_mult m360 (a[67:66], b[5:4], w359);
wire [1:0] w361; f3_mult m362 (a[69:68], b[3:2], w361);
wire [1:0] w363; f3_add a364 (w357, w359, w363);
wire [1:0] w365; f3_add a366 (w363, w361, w365);
assign c[71:70] = w365;
wire [1:0] w367; f3_mult m368 (a[71:70], b[3:2], w367);
wire [1:0] w369; f3_mult m370 (a[73:72], b[1:0], w369);
wire [1:0] w371; f3_mult m372 (a[69:68], b[5:4], w371);
wire [1:0] w373; f3_add a374 (w367, w369, w373);
wire [1:0] w375; f3_add a376 (w373, w371, w375);
assign c[73:72] = w375;
wire [1:0] w377; f3_mult m378 (a[75:74], b[1:0], w377);
wire [1:0] w379; f3_mult m380 (a[71:70], b[5:4], w379);
wire [1:0] w381; f3_mult m382 (a[73:72], b[3:2], w381);
wire [1:0] w383; f3_add a384 (w377, w379, w383);
wire [1:0] w385; f3_add a386 (w383, w381, w385);
assign c[75:74] = w385;
wire [1:0] w387; f3_mult m388 (a[77:76], b[1:0], w387);
wire [1:0] w389; f3_mult m390 (a[75:74], b[3:2], w389);
wire [1:0] w391; f3_mult m392 (a[73:72], b[5:4], w391);
wire [1:0] w393; f3_add a394 (w387, w389, w393);
wire [1:0] w395; f3_add a396 (w393, w391, w395);
assign c[77:76] = w395;
wire [1:0] w397; f3_mult m398 (a[77:76], b[3:2], w397);
wire [1:0] w399; f3_mult m400 (a[79:78], b[1:0], w399);
wire [1:0] w401; f3_mult m402 (a[75:74], b[5:4], w401);
wire [1:0] w403; f3_add a404 (w397, w399, w403);
wire [1:0] w405; f3_add a406 (w403, w401, w405);
assign c[79:78] = w405;
wire [1:0] w407; f3_mult m408 (a[77:76], b[5:4], w407);
wire [1:0] w409; f3_mult m410 (a[79:78], b[3:2], w409);
wire [1:0] w411; f3_mult m412 (a[81:80], b[1:0], w411);
wire [1:0] w413; f3_add a414 (w407, w409, w413);
wire [1:0] w415; f3_add a416 (w413, w411, w415);
assign c[81:80] = w415;
wire [1:0] w417; f3_mult m418 (a[83:82], b[1:0], w417);
wire [1:0] w419; f3_mult m420 (a[79:78], b[5:4], w419);
wire [1:0] w421; f3_mult m422 (a[81:80], b[3:2], w421);
wire [1:0] w423; f3_add a424 (w417, w419, w423);
wire [1:0] w425; f3_add a426 (w423, w421, w425);
assign c[83:82] = w425;
wire [1:0] w427; f3_mult m428 (a[85:84], b[1:0], w427);
wire [1:0] w429; f3_mult m430 (a[81:80], b[5:4], w429);
wire [1:0] w431; f3_mult m432 (a[83:82], b[3:2], w431);
wire [1:0] w433; f3_add a434 (w427, w429, w433);
wire [1:0] w435; f3_add a436 (w433, w431, w435);
assign c[85:84] = w435;
wire [1:0] w437; f3_mult m438 (a[87:86], b[1:0], w437);
wire [1:0] w439; f3_mult m440 (a[83:82], b[5:4], w439);
wire [1:0] w441; f3_mult m442 (a[85:84], b[3:2], w441);
wire [1:0] w443; f3_add a444 (w437, w439, w443);
wire [1:0] w445; f3_add a446 (w443, w441, w445);
assign c[87:86] = w445;
wire [1:0] w447; f3_mult m448 (a[87:86], b[3:2], w447);
wire [1:0] w449; f3_mult m450 (a[89:88], b[1:0], w449);
wire [1:0] w451; f3_mult m452 (a[85:84], b[5:4], w451);
wire [1:0] w453; f3_add a454 (w447, w449, w453);
wire [1:0] w455; f3_add a456 (w453, w451, w455);
assign c[89:88] = w455;
wire [1:0] w457; f3_mult m458 (a[91:90], b[1:0], w457);
wire [1:0] w459; f3_mult m460 (a[87:86], b[5:4], w459);
wire [1:0] w461; f3_mult m462 (a[89:88], b[3:2], w461);
wire [1:0] w463; f3_add a464 (w457, w459, w463);
wire [1:0] w465; f3_add a466 (w463, w461, w465);
assign c[91:90] = w465;
wire [1:0] w467; f3_mult m468 (a[91:90], b[3:2], w467);
wire [1:0] w469; f3_mult m470 (a[89:88], b[5:4], w469);
wire [1:0] w471; f3_mult m472 (a[93:92], b[1:0], w471);
wire [1:0] w473; f3_add a474 (w467, w469, w473);
wire [1:0] w475; f3_add a476 (w473, w471, w475);
assign c[93:92] = w475;
wire [1:0] w477; f3_mult m478 (a[93:92], b[3:2], w477);
wire [1:0] w479; f3_mult m480 (a[95:94], b[1:0], w479);
wire [1:0] w481; f3_mult m482 (a[91:90], b[5:4], w481);
wire [1:0] w483; f3_add a484 (w477, w479, w483);
wire [1:0] w485; f3_add a486 (w483, w481, w485);
assign c[95:94] = w485;
wire [1:0] w487; f3_mult m488 (a[93:92], b[5:4], w487);
wire [1:0] w489; f3_mult m490 (a[95:94], b[3:2], w489);
wire [1:0] w491; f3_mult m492 (a[97:96], b[1:0], w491);
wire [1:0] w493; f3_add a494 (w487, w489, w493);
wire [1:0] w495; f3_add a496 (w493, w491, w495);
assign c[97:96] = w495;
wire [1:0] w497; f3_mult m498 (a[99:98], b[1:0], w497);
wire [1:0] w499; f3_mult m500 (a[95:94], b[5:4], w499);
wire [1:0] w501; f3_mult m502 (a[97:96], b[3:2], w501);
wire [1:0] w503; f3_add a504 (w497, w499, w503);
wire [1:0] w505; f3_add a506 (w503, w501, w505);
assign c[99:98] = w505;
wire [1:0] w507; f3_mult m508 (a[101:100], b[1:0], w507);
wire [1:0] w509; f3_mult m510 (a[97:96], b[5:4], w509);
wire [1:0] w511; f3_mult m512 (a[99:98], b[3:2], w511);
wire [1:0] w513; f3_add a514 (w507, w509, w513);
wire [1:0] w515; f3_add a516 (w513, w511, w515);
assign c[101:100] = w515;
wire [1:0] w517; f3_mult m518 (a[103:102], b[1:0], w517);
wire [1:0] w519; f3_mult m520 (a[99:98], b[5:4], w519);
wire [1:0] w521; f3_mult m522 (a[101:100], b[3:2], w521);
wire [1:0] w523; f3_add a524 (w517, w519, w523);
wire [1:0] w525; f3_add a526 (w523, w521, w525);
assign c[103:102] = w525;
wire [1:0] w527; f3_mult m528 (a[103:102], b[3:2], w527);
wire [1:0] w529; f3_mult m530 (a[105:104], b[1:0], w529);
wire [1:0] w531; f3_mult m532 (a[101:100], b[5:4], w531);
wire [1:0] w533; f3_add a534 (w527, w529, w533);
wire [1:0] w535; f3_add a536 (w533, w531, w535);
assign c[105:104] = w535;
wire [1:0] w537; f3_mult m538 (a[107:106], b[1:0], w537);
wire [1:0] w539; f3_mult m540 (a[103:102], b[5:4], w539);
wire [1:0] w541; f3_mult m542 (a[105:104], b[3:2], w541);
wire [1:0] w543; f3_add a544 (w537, w539, w543);
wire [1:0] w545; f3_add a546 (w543, w541, w545);
assign c[107:106] = w545;
wire [1:0] w547; f3_mult m548 (a[107:106], b[3:2], w547);
wire [1:0] w549; f3_mult m550 (a[105:104], b[5:4], w549);
wire [1:0] w551; f3_mult m552 (a[109:108], b[1:0], w551);
wire [1:0] w553; f3_add a554 (w547, w549, w553);
wire [1:0] w555; f3_add a556 (w553, w551, w555);
assign c[109:108] = w555;
wire [1:0] w557; f3_mult m558 (a[109:108], b[3:2], w557);
wire [1:0] w559; f3_mult m560 (a[111:110], b[1:0], w559);
wire [1:0] w561; f3_mult m562 (a[107:106], b[5:4], w561);
wire [1:0] w563; f3_add a564 (w557, w559, w563);
wire [1:0] w565; f3_add a566 (w563, w561, w565);
assign c[111:110] = w565;
wire [1:0] w567; f3_mult m568 (a[109:108], b[5:4], w567);
wire [1:0] w569; f3_mult m570 (a[111:110], b[3:2], w569);
wire [1:0] w571; f3_mult m572 (a[113:112], b[1:0], w571);
wire [1:0] w573; f3_add a574 (w567, w569, w573);
wire [1:0] w575; f3_add a576 (w573, w571, w575);
assign c[113:112] = w575;
wire [1:0] w577; f3_mult m578 (a[115:114], b[1:0], w577);
wire [1:0] w579; f3_mult m580 (a[111:110], b[5:4], w579);
wire [1:0] w581; f3_mult m582 (a[113:112], b[3:2], w581);
wire [1:0] w583; f3_add a584 (w577, w579, w583);
wire [1:0] w585; f3_add a586 (w583, w581, w585);
assign c[115:114] = w585;
wire [1:0] w587; f3_mult m588 (a[117:116], b[1:0], w587);
wire [1:0] w589; f3_mult m590 (a[113:112], b[5:4], w589);
wire [1:0] w591; f3_mult m592 (a[115:114], b[3:2], w591);
wire [1:0] w593; f3_add a594 (w587, w589, w593);
wire [1:0] w595; f3_add a596 (w593, w591, w595);
assign c[117:116] = w595;
wire [1:0] w597; f3_mult m598 (a[119:118], b[1:0], w597);
wire [1:0] w599; f3_mult m600 (a[115:114], b[5:4], w599);
wire [1:0] w601; f3_mult m602 (a[117:116], b[3:2], w601);
wire [1:0] w603; f3_add a604 (w597, w599, w603);
wire [1:0] w605; f3_add a606 (w603, w601, w605);
assign c[119:118] = w605;
wire [1:0] w607; f3_mult m608 (a[119:118], b[3:2], w607);
wire [1:0] w609; f3_mult m610 (a[121:120], b[1:0], w609);
wire [1:0] w611; f3_mult m612 (a[117:116], b[5:4], w611);
wire [1:0] w613; f3_add a614 (w607, w609, w613);
wire [1:0] w615; f3_add a616 (w613, w611, w615);
assign c[121:120] = w615;
wire [1:0] w617; f3_mult m618 (a[123:122], b[1:0], w617);
wire [1:0] w619; f3_mult m620 (a[119:118], b[5:4], w619);
wire [1:0] w621; f3_mult m622 (a[121:120], b[3:2], w621);
wire [1:0] w623; f3_add a624 (w617, w619, w623);
wire [1:0] w625; f3_add a626 (w623, w621, w625);
assign c[123:122] = w625;
wire [1:0] w627; f3_mult m628 (a[123:122], b[3:2], w627);
wire [1:0] w629; f3_mult m630 (a[121:120], b[5:4], w629);
wire [1:0] w631; f3_mult m632 (a[125:124], b[1:0], w631);
wire [1:0] w633; f3_add a634 (w627, w629, w633);
wire [1:0] w635; f3_add a636 (w633, w631, w635);
assign c[125:124] = w635;
wire [1:0] w637; f3_mult m638 (a[125:124], b[3:2], w637);
wire [1:0] w639; f3_mult m640 (a[127:126], b[1:0], w639);
wire [1:0] w641; f3_mult m642 (a[123:122], b[5:4], w641);
wire [1:0] w643; f3_add a644 (w637, w639, w643);
wire [1:0] w645; f3_add a646 (w643, w641, w645);
assign c[127:126] = w645;
wire [1:0] w647; f3_mult m648 (a[125:124], b[5:4], w647);
wire [1:0] w649; f3_mult m650 (a[127:126], b[3:2], w649);
wire [1:0] w651; f3_mult m652 (a[129:128], b[1:0], w651);
wire [1:0] w653; f3_add a654 (w647, w649, w653);
wire [1:0] w655; f3_add a656 (w653, w651, w655);
assign c[129:128] = w655;
wire [1:0] w657; f3_mult m658 (a[127:126], b[5:4], w657);
wire [1:0] w659; f3_mult m660 (a[131:130], b[1:0], w659);
wire [1:0] w661; f3_mult m662 (a[129:128], b[3:2], w661);
wire [1:0] w663; f3_add a664 (w657, w659, w663);
wire [1:0] w665; f3_add a666 (w663, w661, w665);
assign c[131:130] = w665;
wire [1:0] w667; f3_mult m668 (a[133:132], b[1:0], w667);
wire [1:0] w669; f3_mult m670 (a[129:128], b[5:4], w669);
wire [1:0] w671; f3_mult m672 (a[131:130], b[3:2], w671);
wire [1:0] w673; f3_add a674 (w667, w669, w673);
wire [1:0] w675; f3_add a676 (w673, w671, w675);
assign c[133:132] = w675;
wire [1:0] w677; f3_mult m678 (a[133:132], b[3:2], w677);
wire [1:0] w679; f3_mult m680 (a[131:130], b[5:4], w679);
wire [1:0] w681; f3_mult m682 (a[135:134], b[1:0], w681);
wire [1:0] w683; f3_add a684 (w677, w679, w683);
wire [1:0] w685; f3_add a686 (w683, w681, w685);
assign c[135:134] = w685;
wire [1:0] w687; f3_mult m688 (a[135:134], b[3:2], w687);
wire [1:0] w689; f3_mult m690 (a[137:136], b[1:0], w689);
wire [1:0] w691; f3_mult m692 (a[133:132], b[5:4], w691);
wire [1:0] w693; f3_add a694 (w687, w689, w693);
wire [1:0] w695; f3_add a696 (w693, w691, w695);
assign c[137:136] = w695;
wire [1:0] w697; f3_mult m698 (a[139:138], b[1:0], w697);
wire [1:0] w699; f3_mult m700 (a[135:134], b[5:4], w699);
wire [1:0] w701; f3_mult m702 (a[137:136], b[3:2], w701);
wire [1:0] w703; f3_add a704 (w697, w699, w703);
wire [1:0] w705; f3_add a706 (w703, w701, w705);
assign c[139:138] = w705;
wire [1:0] w707; f3_mult m708 (a[141:140], b[1:0], w707);
wire [1:0] w709; f3_mult m710 (a[139:138], b[3:2], w709);
wire [1:0] w711; f3_mult m712 (a[137:136], b[5:4], w711);
wire [1:0] w713; f3_add a714 (w707, w709, w713);
wire [1:0] w715; f3_add a716 (w713, w711, w715);
assign c[141:140] = w715;
wire [1:0] w717; f3_mult m718 (a[143:142], b[1:0], w717);
wire [1:0] w719; f3_mult m720 (a[141:140], b[3:2], w719);
wire [1:0] w721; f3_mult m722 (a[139:138], b[5:4], w721);
wire [1:0] w723; f3_add a724 (w717, w719, w723);
wire [1:0] w725; f3_add a726 (w723, w721, w725);
assign c[143:142] = w725;
wire [1:0] w727; f3_mult m728 (a[141:140], b[5:4], w727);
wire [1:0] w729; f3_mult m730 (a[143:142], b[3:2], w729);
wire [1:0] w731; f3_mult m732 (a[145:144], b[1:0], w731);
wire [1:0] w733; f3_add a734 (w727, w729, w733);
wire [1:0] w735; f3_add a736 (w733, w731, w735);
assign c[145:144] = w735;
wire [1:0] w737; f3_mult m738 (a[143:142], b[5:4], w737);
wire [1:0] w739; f3_mult m740 (a[147:146], b[1:0], w739);
wire [1:0] w741; f3_mult m742 (a[145:144], b[3:2], w741);
wire [1:0] w743; f3_add a744 (w737, w739, w743);
wire [1:0] w745; f3_add a746 (w743, w741, w745);
assign c[147:146] = w745;
wire [1:0] w747; f3_mult m748 (a[145:144], b[5:4], w747);
wire [1:0] w749; f3_mult m750 (a[149:148], b[1:0], w749);
wire [1:0] w751; f3_mult m752 (a[147:146], b[3:2], w751);
wire [1:0] w753; f3_add a754 (w747, w749, w753);
wire [1:0] w755; f3_add a756 (w753, w751, w755);
assign c[149:148] = w755;
wire [1:0] w757; f3_mult m758 (a[149:148], b[3:2], w757);
wire [1:0] w759; f3_mult m760 (a[147:146], b[5:4], w759);
wire [1:0] w761; f3_mult m762 (a[151:150], b[1:0], w761);
wire [1:0] w763; f3_add a764 (w757, w759, w763);
wire [1:0] w765; f3_add a766 (w763, w761, w765);
assign c[151:150] = w765;
wire [1:0] w767; f3_mult m768 (a[151:150], b[3:2], w767);
wire [1:0] w769; f3_mult m770 (a[149:148], b[5:4], w769);
wire [1:0] w771; f3_mult m772 (a[153:152], b[1:0], w771);
wire [1:0] w773; f3_add a774 (w767, w769, w773);
wire [1:0] w775; f3_add a776 (w773, w771, w775);
assign c[153:152] = w775;
wire [1:0] w777; f3_mult m778 (a[155:154], b[1:0], w777);
wire [1:0] w779; f3_mult m780 (a[151:150], b[5:4], w779);
wire [1:0] w781; f3_mult m782 (a[153:152], b[3:2], w781);
wire [1:0] w783; f3_add a784 (w777, w779, w783);
wire [1:0] w785; f3_add a786 (w783, w781, w785);
assign c[155:154] = w785;
wire [1:0] w787; f3_mult m788 (a[155:154], b[3:2], w787);
wire [1:0] w789; f3_mult m790 (a[153:152], b[5:4], w789);
wire [1:0] w791; f3_mult m792 (a[157:156], b[1:0], w791);
wire [1:0] w793; f3_add a794 (w787, w789, w793);
wire [1:0] w795; f3_add a796 (w793, w791, w795);
assign c[157:156] = w795;
wire [1:0] w797; f3_mult m798 (a[159:158], b[1:0], w797);
wire [1:0] w799; f3_mult m800 (a[157:156], b[3:2], w799);
wire [1:0] w801; f3_mult m802 (a[155:154], b[5:4], w801);
wire [1:0] w803; f3_add a804 (w797, w799, w803);
wire [1:0] w805; f3_add a806 (w803, w801, w805);
assign c[159:158] = w805;
wire [1:0] w807; f3_mult m808 (a[157:156], b[5:4], w807);
wire [1:0] w809; f3_mult m810 (a[159:158], b[3:2], w809);
wire [1:0] w811; f3_mult m812 (a[161:160], b[1:0], w811);
wire [1:0] w813; f3_add a814 (w807, w809, w813);
wire [1:0] w815; f3_add a816 (w813, w811, w815);
assign c[161:160] = w815;
wire [1:0] w817; f3_mult m818 (a[159:158], b[5:4], w817);
wire [1:0] w819; f3_mult m820 (a[163:162], b[1:0], w819);
wire [1:0] w821; f3_mult m822 (a[161:160], b[3:2], w821);
wire [1:0] w823; f3_add a824 (w817, w819, w823);
wire [1:0] w825; f3_add a826 (w823, w821, w825);
assign c[163:162] = w825;
wire [1:0] w827; f3_mult m828 (a[161:160], b[5:4], w827);
wire [1:0] w829; f3_mult m830 (a[165:164], b[1:0], w829);
wire [1:0] w831; f3_mult m832 (a[163:162], b[3:2], w831);
wire [1:0] w833; f3_add a834 (w827, w829, w833);
wire [1:0] w835; f3_add a836 (w833, w831, w835);
assign c[165:164] = w835;
wire [1:0] w837; f3_mult m838 (a[165:164], b[3:2], w837);
wire [1:0] w839; f3_mult m840 (a[163:162], b[5:4], w839);
wire [1:0] w841; f3_mult m842 (a[167:166], b[1:0], w841);
wire [1:0] w843; f3_add a844 (w837, w839, w843);
wire [1:0] w845; f3_add a846 (w843, w841, w845);
assign c[167:166] = w845;
wire [1:0] w847; f3_mult m848 (a[167:166], b[3:2], w847);
wire [1:0] w849; f3_mult m850 (a[165:164], b[5:4], w849);
wire [1:0] w851; f3_mult m852 (a[169:168], b[1:0], w851);
wire [1:0] w853; f3_add a854 (w847, w849, w853);
wire [1:0] w855; f3_add a856 (w853, w851, w855);
assign c[169:168] = w855;
wire [1:0] w857; f3_mult m858 (a[171:170], b[1:0], w857);
wire [1:0] w859; f3_mult m860 (a[167:166], b[5:4], w859);
wire [1:0] w861; f3_mult m862 (a[169:168], b[3:2], w861);
wire [1:0] w863; f3_add a864 (w857, w859, w863);
wire [1:0] w865; f3_add a866 (w863, w861, w865);
assign c[171:170] = w865;
wire [1:0] w867; f3_mult m868 (a[171:170], b[3:2], w867);
wire [1:0] w869; f3_mult m870 (a[169:168], b[5:4], w869);
wire [1:0] w871; f3_mult m872 (a[173:172], b[1:0], w871);
wire [1:0] w873; f3_add a874 (w867, w869, w873);
wire [1:0] w875; f3_add a876 (w873, w871, w875);
assign c[173:172] = w875;
wire [1:0] w877; f3_mult m878 (a[173:172], b[3:2], w877);
wire [1:0] w879; f3_mult m880 (a[175:174], b[1:0], w879);
wire [1:0] w881; f3_mult m882 (a[171:170], b[5:4], w881);
wire [1:0] w883; f3_add a884 (w877, w879, w883);
wire [1:0] w885; f3_add a886 (w883, w881, w885);
assign c[175:174] = w885;
wire [1:0] w887; f3_mult m888 (a[173:172], b[5:4], w887);
wire [1:0] w889; f3_mult m890 (a[175:174], b[3:2], w889);
wire [1:0] w891; f3_mult m892 (a[177:176], b[1:0], w891);
wire [1:0] w893; f3_add a894 (w887, w889, w893);
wire [1:0] w895; f3_add a896 (w893, w891, w895);
assign c[177:176] = w895;
wire [1:0] w897; f3_mult m898 (a[175:174], b[5:4], w897);
wire [1:0] w899; f3_mult m900 (a[179:178], b[1:0], w899);
wire [1:0] w901; f3_mult m902 (a[177:176], b[3:2], w901);
wire [1:0] w903; f3_add a904 (w897, w899, w903);
wire [1:0] w905; f3_add a906 (w903, w901, w905);
assign c[179:178] = w905;
wire [1:0] w907; f3_mult m908 (a[177:176], b[5:4], w907);
wire [1:0] w909; f3_mult m910 (a[181:180], b[1:0], w909);
wire [1:0] w911; f3_mult m912 (a[179:178], b[3:2], w911);
wire [1:0] w913; f3_add a914 (w907, w909, w913);
wire [1:0] w915; f3_add a916 (w913, w911, w915);
assign c[181:180] = w915;
wire [1:0] w917; f3_mult m918 (a[181:180], b[3:2], w917);
wire [1:0] w919; f3_mult m920 (a[183:182], b[1:0], w919);
wire [1:0] w921; f3_mult m922 (a[179:178], b[5:4], w921);
wire [1:0] w923; f3_add a924 (w917, w919, w923);
wire [1:0] w925; f3_add a926 (w923, w921, w925);
assign c[183:182] = w925;
wire [1:0] w927; f3_mult m928 (a[183:182], b[3:2], w927);
wire [1:0] w929; f3_mult m930 (a[181:180], b[5:4], w929);
wire [1:0] w931; f3_mult m932 (a[185:184], b[1:0], w931);
wire [1:0] w933; f3_add a934 (w927, w929, w933);
wire [1:0] w935; f3_add a936 (w933, w931, w935);
assign c[185:184] = w935;
wire [1:0] w937; f3_mult m938 (a[187:186], b[1:0], w937);
wire [1:0] w939; f3_mult m940 (a[183:182], b[5:4], w939);
wire [1:0] w941; f3_mult m942 (a[185:184], b[3:2], w941);
wire [1:0] w943; f3_add a944 (w937, w939, w943);
wire [1:0] w945; f3_add a946 (w943, w941, w945);
assign c[187:186] = w945;
wire [1:0] w947; f3_mult m948 (a[187:186], b[3:2], w947);
wire [1:0] w949; f3_mult m950 (a[185:184], b[5:4], w949);
wire [1:0] w951; f3_mult m952 (a[189:188], b[1:0], w951);
wire [1:0] w953; f3_add a954 (w947, w949, w953);
wire [1:0] w955; f3_add a956 (w953, w951, w955);
assign c[189:188] = w955;
wire [1:0] w957; f3_mult m958 (a[189:188], b[3:2], w957);
wire [1:0] w959; f3_mult m960 (a[191:190], b[1:0], w959);
wire [1:0] w961; f3_mult m962 (a[187:186], b[5:4], w961);
wire [1:0] w963; f3_add a964 (w957, w959, w963);
wire [1:0] w965; f3_add a966 (w963, w961, w965);
assign c[191:190] = w965;
wire [1:0] w967; f3_mult m968 (a[189:188], b[5:4], w967);
wire [1:0] w969; f3_mult m970 (a[191:190], b[3:2], w969);
wire [1:0] w971; f3_mult m972 (a[193:192], b[1:0], w971);
wire [1:0] w973; f3_add a974 (w967, w969, w973);
wire [1:0] w975; f3_add a976 (w973, w971, w975);
assign c[193:192] = w975;
endmodule

module func6(clk, reset, in, out);
    input clk, reset, in;
    output out;
    reg reg1, reg2;
    always @ (posedge clk)
        if (reset)
          begin
            reg1 <= 0; reg2 <= 0;
          end
        else
          begin
            reg2 <= reg1; reg1 <= in;
          end
    assign out = {reg2,reg1}==2'b01 ? 1 : 0;
endmodule

