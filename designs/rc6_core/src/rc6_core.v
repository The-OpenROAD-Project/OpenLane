/*  
Copyright 2019 XCrypt Studio                
																	 
Licensed under the Apache License, Version 2.0 (the "License");         
you may not use this file except in compliance with the License.        
You may obtain a copy of the License at                                 
																	 
 http://www.apache.org/licenses/LICENSE-2.0                          
																	 
Unless required by applicable law or agreed to in writing, software    
distributed under the License is distributed on an "AS IS" BASIS,       
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and     
limitations under the License.                                          
*/  

// ------------------------------------------------------------------------------
// File name        :   rc6_core.v
// Function         :   RC6 Cryptographic Algorithm Core (KeyLen = 16,Round = 20)
// ------------------------------------------------------------------------------
// Author           :   Xie
// Version          £º  v-1.0
// Date				:   2019-2-1
// Email            :   xcrypt@126.com
// ------------------------------------------------------------------------------

module rc6_core(
    input           i_clk,
    input           i_rst,
    input           i_flag,    //1-encrypt,0-decrypt
    input  [127:0]  i_key,
    input           i_key_en,  //1-key init start
	output 			o_key_ok,  //1-key init done
    input  [127:0]   i_din,
    input           i_din_en,
    output [127:0]   o_dout,
    output          o_dout_en
    );
 
	wire  [32*44-1:0] s_exkey;
 
	//key expand
	rc6_keyex u_keyex(
	.i_clk		(i_clk		),
	.i_rst		(i_rst		),
	.i_key		(i_key		),
	.i_key_en	(i_key_en	),
	.o_exkey	(s_exkey	),
	.o_key_ok	(o_key_ok	)	
	);

	// data encrypt or decrypt
	rc6_dpc u_dpc(
	.i_clk		(i_clk		),
	.i_rst		(i_rst		),	
	.i_flag		(i_flag		),
	.i_keyex	(s_exkey	),
    .i_din		(i_din		),
    .i_din_en	(i_din_en	),
    .o_dout		(o_dout		),
    .o_dout_en	(o_dout_en	)
	);	
	
endmodule

module rc6_dpc(
	input				i_clk,
	input				i_rst,
	input 				i_flag,
	input  [32*44-1:0] 	i_keyex,
    input  [127:0]   	i_din,
    input           	i_din_en,
    output [127:0]   	o_dout,
    output          	o_dout_en
);

	localparam DLY = 1;
	
	reg  [4:0]		r_count;	
	wire [31:0]		s_a,s_ax,s_ay,s_ay_e,s_ay_d;
	wire [31:0]		s_b;
	wire [31:0]		s_c,s_cx,s_cy,s_cy_e,s_cy_d;
	wire [31:0]		s_d;	
	wire [127:0] 	s_din;
	reg  [127:0] 	r_din;
	reg  [32*38-1:0] r_keyex;
	wire [63:0]		s_fkey;
	wire [63:0]		s_lkey;
	wire [63:0]		s_ikey;
	wire [63:0]		s_rkey;
	wire [127:0]	s_pdin;
	wire [4:0]		s_rr_x,s_rr_y;
	wire [31:0]		s_rdin_x,s_rdin_y;
	wire [31:0] 	s_rdout_x,s_rdout_y;
	wire [31:0]		s_t,s_u;

	function [31:0] SWAP;
		input [31:0] D;
		begin
			SWAP = {D[7:0],D[15:8],D[23:16],D[31:24]};
		end
	endfunction
	
	function [31:0]	ROL5;
		input [31:0] D;
		begin
			ROL5 = {D[26:0],D[31:27]};
		end
	endfunction 
	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst) 
			r_count <= #DLY 5'b0;
		else if(i_din_en)
			r_count <= #DLY 5'd1;
		else if(r_count==5'd19) 
			r_count <= #DLY 5'b0;
		else if(r_count!=5'd0)
			r_count <= #DLY r_count + 5'd1;
	end
	
	always@(posedge i_clk  or posedge i_rst) begin
		if(i_rst)
			r_keyex <= #DLY 'b0;
		else if(i_din_en) begin
			if(i_flag)
				r_keyex <= #DLY i_keyex[32*40-1:32*2];
			else 
				r_keyex <= #DLY i_keyex[32*42-1:32*4];
		end else if(r_count!=5'd0)begin
			if(i_flag)
				r_keyex <= #DLY {r_keyex[32*36-1:0],64'b0};
			else	
				r_keyex <= #DLY {64'b0,r_keyex[32*38-1:64]};
		end
	end 

	assign s_fkey = i_flag ? i_keyex[32*44-1:32*42]:i_keyex[32*2-1:0];  //first
	assign s_lkey = i_flag ? i_keyex[32*2-1:0]:i_keyex[32*44-1:32*42];  //last
	assign s_ikey = i_flag ? i_keyex[32*42-1:32*40] : i_keyex[32*4-1:32*2];
	assign s_rkey = i_flag ? r_keyex[32*38-1:32*36] : r_keyex[32*2-1:0];
	
	assign s_pdin = i_flag ? {SWAP(i_din[127:96]),(SWAP(i_din[95:64])+s_fkey[63:32]),SWAP(i_din[63:32]),(SWAP(i_din[31:0])+s_fkey[31:0])} 
						: {SWAP(i_din[127:96])-s_fkey[63:32],SWAP(i_din[95:64]),SWAP(i_din[63:32])-s_fkey[31:0],SWAP(i_din[31:0])};
						
	assign s_din = i_din_en ? s_pdin : r_din;	
	
	assign s_a = i_flag ? s_din[127:96] : s_din[31:0];
	assign s_b = i_flag ? s_din[95:64] : s_din[127:96];
	assign s_c = i_flag ? s_din[63:32] : s_din[95:64];
	assign s_d = i_flag ? s_din[31:0] : s_din[63:32];	
	
	//---ENCRYPT---
	   // for (r = 0; r < 20; r += 4) {
       // RND(a,b,c,d);
       // RND(b,c,d,a);
       // RND(c,d,a,b);
       // RND(d,a,b,c);
   // }
       // t = (b * (b + b + 1)); t = ROLc(t, 5); \ encrypt
       // u = (d * (d + d + 1)); u = ROLc(u, 5); \
       // a = ROL(a^t,u) + K[0];                \
       // c = ROL(c^u,t) + K[1]; K += 2;
	//---DECRYPT---
       // for (r = 0; r < 20; r += 4) {
       // 	RND(d,a,b,c);
       // 	RND(c,d,a,b);
       // 	RND(b,c,d,a);
       // 	RND(a,b,c,d);
	   // }
       // t = (b * (b + b + 1)); t = ROLc(t, 5); \ decrypt
       // u = (d * (d + d + 1)); u = ROLc(u, 5); \
       // c = ROR(c - K[1], t) ^ u; \
       // a = ROR(a - K[0], u) ^ t; K -= 2;
	   
	assign s_t = ROL5(s_b*(s_b + s_b + 1));
	assign s_u = ROL5(s_d*(s_d + s_d + 1));
	assign s_rr_x = i_flag ? s_u[4:0] : (32-s_t[4:0]); 
	assign s_rr_y = i_flag ? s_t[4:0] : (32-s_u[4:0]);
	assign s_rdin_x = i_flag ? s_a^s_t : (i_din_en ? (s_c-s_ikey[31:0]):(s_c-s_rkey[31:0]));
	assign s_rdin_y = i_flag ? s_c^s_u : (i_din_en ? (s_a-s_ikey[63:32]):(s_a-s_rkey[63:32]));
	
	rc6_rol u_rol1(.round(s_rr_x),.din(s_rdin_x),.dout(s_rdout_x));
	rc6_rol u_rol2(.round(s_rr_y),.din(s_rdin_y),.dout(s_rdout_y));
	
	assign s_ax = i_flag ? s_rdout_x : s_rdout_y^s_t;
	assign s_cx = i_flag ? s_rdout_y : s_rdout_x^s_u;
	
	assign s_ay_e =  i_din_en ? (s_ax + s_ikey[63:32]):(s_ax + s_rkey[63:32]);
	assign s_cy_e =  i_din_en ? (s_cx + s_ikey[31:0]):(s_cx + s_rkey[31:0]);

	assign s_cy_d =  s_cx;
	assign s_ay_d =  s_ax;
	
	assign s_ay =  i_flag ? s_ay_e : s_ay_d;
	assign s_cy =  i_flag ? s_cy_e : s_cy_d;
	
	always@(posedge i_clk  or posedge i_rst) begin
		if(i_rst)
			r_din <= #DLY 64'b0;
		else if(i_flag)
			r_din <= #DLY {s_b,s_cy,s_d,s_ay};
		else 
			r_din <= #DLY {s_ay,s_b,s_cy,s_d};
	end	
		
	assign o_dout = i_flag ? {SWAP(s_b+s_lkey[63:32]),SWAP(s_cy),SWAP(s_d+s_lkey[31:0]),SWAP(s_ay)} 
						: {SWAP(s_ay),SWAP(s_b-s_lkey[63:32]),SWAP(s_cy),SWAP(s_d-s_lkey[31:0])};
						
	assign o_dout_en = (r_count==5'd19) ? 1'b1:1'b0;
	
endmodule

module rc6_keyex(
	input 				i_clk,
	input 				i_rst,
	input 	[127:0]	 	i_key,		//key
	input 				i_key_en,	//key init flag
	output 	[32*44-1:0]	o_exkey,  	//round key
	output 				o_key_ok  	//key init ok
	);
	
	localparam DLY = 1;
	localparam [32*44-1:0] STAB = {
		32'hb7e15163, 32'h5618cb1c, 32'hf45044d5, 32'h9287be8e,
		32'h30bf3847, 32'hcef6b200, 32'h6d2e2bb9, 32'h0b65a572,
		32'ha99d1f2b, 32'h47d498e4, 32'he60c129d, 32'h84438c56,
		32'h227b060f, 32'hc0b27fc8, 32'h5ee9f981, 32'hfd21733a,
		32'h9b58ecf3, 32'h399066ac, 32'hd7c7e065, 32'h75ff5a1e,
		32'h1436d3d7, 32'hb26e4d90, 32'h50a5c749, 32'heedd4102,
		32'h8d14babb, 32'h2b4c3474, 32'hc983ae2d, 32'h67bb27e6,
		32'h05f2a19f, 32'ha42a1b58, 32'h42619511, 32'he0990eca,
		32'h7ed08883, 32'h1d08023c, 32'hbb3f7bf5, 32'h5976f5ae,
		32'hf7ae6f67, 32'h95e5e920, 32'h341d62d9, 32'hd254dc92,
		32'h708c564b, 32'h0ec3d004, 32'hacfb49bd, 32'h4b32c376};
	
	wire 	[127:0]		s_ikey;
	wire 	[31:0]		s_sk;
	wire 	[31:0]		s_lk;
	wire 	[31:0]		s_a,s_ax;
	wire 	[31:0]		s_b,s_bx;
	reg  	[127:0]		r_key;
	reg		[32*44-1:0]	r_exkey;
	reg 	[7:0]		r_count;
	reg 				r_key_ok;
	wire 				s_busy;
	wire 	[31:0]		s_tmp;
	
	function [31:0] SWAP;
		input [31:0] D;
		begin
			SWAP = {D[7:0],D[15:8],D[23:16],D[31:24]};
		end
	endfunction
	
	assign s_ikey = {SWAP(i_key[127:96]),SWAP(i_key[95:64]),SWAP(i_key[63:32]),SWAP(i_key[31:0])};
	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst)
			r_key <= #DLY 128'b0;
		else if(i_key_en)
			r_key <= #DLY {s_ikey[95:0],s_bx};
		else if(s_busy)
			r_key <= #DLY {r_key[95:0],s_bx};
	end	
	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst) 
			r_exkey <= #DLY 1408'b0;
		else if(i_key_en)
			r_exkey <= #DLY {STAB[32*43-1:0],s_ax};
		else if(s_busy)begin
			r_exkey <= #DLY {r_exkey[32*43-1:0],s_ax};
		end
	end	

	assign s_a = i_key_en ? 32'b0 : r_exkey[31:0];
	assign s_b = i_key_en ? 32'b0 : r_key[31:0];
	assign s_lk = i_key_en ? s_ikey[127:96] : r_key[127:96];
	assign s_sk = i_key_en ? STAB[32*44-1:32*43]: r_exkey[32*44-1:32*43];
	assign s_tmp = s_ax+s_b;

	rc6_rol u_rol1(.round(5'd3),.din((s_sk + s_a + s_b)),.dout(s_ax)); //S
	rc6_rol u_rol2(.round(s_tmp[4:0]),.din((s_lk + s_ax + s_b)),.dout(s_bx)); //L
	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst)
			r_count <= #DLY 8'd0;
		else if(i_key_en)
			r_count <= #DLY 8'd1;
		else if(r_count==8'd131)
			r_count <= #DLY 7'd0;
		else if(r_count!=8'd0)
			r_count <= #DLY r_count + 8'd1;
	end

	assign o_exkey = r_exkey;

	assign s_busy = ((r_count!=8'd0)||(i_key_en==1'b1)) ? 1'b1 : 1'b0;
	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst)
			r_key_ok <= #DLY 1'b0;
		else if(r_count==8'd131)
			r_key_ok <= #DLY 1'b1;
		else if(i_key_en==1'b1)
			r_key_ok <= #DLY 1'b0;
	end
	
	assign o_key_ok = r_key_ok&(~i_key_en);
	
endmodule

module rc6_rol(
    input   [4:0]	round,
	input 	[31:0]  din,
    output  [31:0]  dout
    );
    reg [31:0] r_dout;
    assign dout = r_dout;
    always@(round or din) begin
        case(round)
			5'h00 : r_dout = din;
			5'h01 : r_dout = {din[30:0],din[31]	  };
			5'h02 : r_dout = {din[29:0],din[31:30]};
			5'h03 : r_dout = {din[28:0],din[31:29]};
			5'h04 : r_dout = {din[27:0],din[31:28]};
			5'h05 : r_dout = {din[26:0],din[31:27]};
			5'h06 : r_dout = {din[25:0],din[31:26]};
			5'h07 : r_dout = {din[24:0],din[31:25]};
			5'h08 : r_dout = {din[23:0],din[31:24]};
			5'h09 : r_dout = {din[22:0],din[31:23]};
			5'h0a : r_dout = {din[21:0],din[31:22]};
			5'h0b : r_dout = {din[20:0],din[31:21]};
			5'h0c : r_dout = {din[19:0],din[31:20]};
			5'h0d : r_dout = {din[18:0],din[31:19]};
			5'h0e : r_dout = {din[17:0],din[31:18]};
			5'h0f : r_dout = {din[16:0],din[31:17]};
			5'h10 : r_dout = {din[15:0],din[31:16]};
			5'h11 : r_dout = {din[14:0],din[31:15]};
			5'h12 : r_dout = {din[13:0],din[31:14]};
			5'h13 : r_dout = {din[12:0],din[31:13]};
			5'h14 : r_dout = {din[11:0],din[31:12]};
			5'h15 : r_dout = {din[10:0],din[31:11]};
			5'h16 : r_dout = {din[ 9:0],din[31:10]};
			5'h17 : r_dout = {din[ 8:0],din[31: 9]};
			5'h18 : r_dout = {din[ 7:0],din[31: 8]};
			5'h19 : r_dout = {din[ 6:0],din[31: 7]};
			5'h1a : r_dout = {din[ 5:0],din[31: 6]};
			5'h1b : r_dout = {din[ 4:0],din[31: 5]};
			5'h1c : r_dout = {din[ 3:0],din[31: 4]};
			5'h1d : r_dout = {din[ 2:0],din[31: 3]};
			5'h1e : r_dout = {din[ 1:0],din[31: 2]};
			5'h1f : r_dout = {din[0]   ,din[31: 1]};
        endcase
    end

endmodule

