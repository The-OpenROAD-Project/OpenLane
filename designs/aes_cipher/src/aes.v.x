/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: aes_cipher_top.v,v 1.1.1.1 2002/11/09 11:22:48 rudi Exp $
//
//  $Date: 2002/11/09 11:22:48 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: aes_cipher_top.v,v $
//               Revision 1.1.1.1  2002/11/09 11:22:48  rudi
//               Initial Checkin
//
//
//
//
//
//


module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out, SE, SI, SO );
input		clk, rst;
input		ld, SE, SI;
output		done, SO;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3;
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;
wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;
wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire	[7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;
wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;
wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;
reg		done, ld_r;
reg	[3:0]	dcnt;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	if(!rst)	dcnt <= #1 4'h0;
	else
	if(ld)		dcnt <= #1 4'hb;
	else
	if(|dcnt)	dcnt <= #1 dcnt - 4'h1;

always @(posedge clk) done <= #1 !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <= #1 text_in;
always @(posedge clk) ld_r <= #1 ld;

////////////////////////////////////////////////////////////////////
//
// Initial Permutation (AddRoundKey)
//

always @(posedge clk)	sa33 <= #1 ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_next;
always @(posedge clk)	sa23 <= #1 ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_next;
always @(posedge clk)	sa13 <= #1 ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_next;
always @(posedge clk)	sa03 <= #1 ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_next;
always @(posedge clk)	sa32 <= #1 ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_next;
always @(posedge clk)	sa22 <= #1 ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_next;
always @(posedge clk)	sa12 <= #1 ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_next;
always @(posedge clk)	sa02 <= #1 ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_next;
always @(posedge clk)	sa31 <= #1 ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_next;
always @(posedge clk)	sa21 <= #1 ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_next;
always @(posedge clk)	sa11 <= #1 ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_next;
always @(posedge clk)	sa01 <= #1 ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_next;
always @(posedge clk)	sa30 <= #1 ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_next;
always @(posedge clk)	sa20 <= #1 ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_next;
always @(posedge clk)	sa10 <= #1 ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_next;
always @(posedge clk)	sa00 <= #1 ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_next;

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//

assign sa00_sr = sa00_sub;
assign sa01_sr = sa01_sub;
assign sa02_sr = sa02_sub;
assign sa03_sr = sa03_sub;
assign sa10_sr = sa11_sub;
assign sa11_sr = sa12_sub;
assign sa12_sr = sa13_sub;
assign sa13_sr = sa10_sub;
assign sa20_sr = sa22_sub;
assign sa21_sr = sa23_sub;
assign sa22_sr = sa20_sub;
assign sa23_sr = sa21_sub;
assign sa30_sr = sa33_sub;
assign sa31_sr = sa30_sub;
assign sa32_sr = sa31_sub;
assign sa33_sr = sa32_sub;
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);
assign sa00_next = sa00_mc ^ w0[31:24];
assign sa01_next = sa01_mc ^ w1[31:24];
assign sa02_next = sa02_mc ^ w2[31:24];
assign sa03_next = sa03_mc ^ w3[31:24];
assign sa10_next = sa10_mc ^ w0[23:16];
assign sa11_next = sa11_mc ^ w1[23:16];
assign sa12_next = sa12_mc ^ w2[23:16];
assign sa13_next = sa13_mc ^ w3[23:16];
assign sa20_next = sa20_mc ^ w0[15:08];
assign sa21_next = sa21_mc ^ w1[15:08];
assign sa22_next = sa22_mc ^ w2[15:08];
assign sa23_next = sa23_mc ^ w3[15:08];
assign sa30_next = sa30_mc ^ w0[07:00];
assign sa31_next = sa31_mc ^ w1[07:00];
assign sa32_next = sa32_mc ^ w2[07:00];
assign sa33_next = sa33_mc ^ w3[07:00];

////////////////////////////////////////////////////////////////////
//
// Final text output
//

always @(posedge clk) text_out[127:120] <= #1 sa00_sr ^ w0[31:24];
always @(posedge clk) text_out[095:088] <= #1 sa01_sr ^ w1[31:24];
always @(posedge clk) text_out[063:056] <= #1 sa02_sr ^ w2[31:24];
always @(posedge clk) text_out[031:024] <= #1 sa03_sr ^ w3[31:24];
always @(posedge clk) text_out[119:112] <= #1 sa10_sr ^ w0[23:16];
always @(posedge clk) text_out[087:080] <= #1 sa11_sr ^ w1[23:16];
always @(posedge clk) text_out[055:048] <= #1 sa12_sr ^ w2[23:16];
always @(posedge clk) text_out[023:016] <= #1 sa13_sr ^ w3[23:16];
always @(posedge clk) text_out[111:104] <= #1 sa20_sr ^ w0[15:08];
always @(posedge clk) text_out[079:072] <= #1 sa21_sr ^ w1[15:08];
always @(posedge clk) text_out[047:040] <= #1 sa22_sr ^ w2[15:08];
always @(posedge clk) text_out[015:008] <= #1 sa23_sr ^ w3[15:08];
always @(posedge clk) text_out[103:096] <= #1 sa30_sr ^ w0[07:00];
always @(posedge clk) text_out[071:064] <= #1 sa31_sr ^ w1[07:00];
always @(posedge clk) text_out[039:032] <= #1 sa32_sr ^ w2[07:00];
always @(posedge clk) text_out[007:000] <= #1 sa33_sr ^ w3[07:00];

////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction

////////////////////////////////////////////////////////////////////
//
// Modules
//

aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		ld	),
	.key(		key	),
	.wo_0(		w0	),
	.wo_1(		w1	),
	.wo_2(		w2	),
	.wo_3(		w3	));

aes_sbox us00(	.a(	sa00	), .d(	sa00_sub	));
aes_sbox us01(	.a(	sa01	), .d(	sa01_sub	));
aes_sbox us02(	.a(	sa02	), .d(	sa02_sub	));
aes_sbox us03(	.a(	sa03	), .d(	sa03_sub	));
aes_sbox us10(	.a(	sa10	), .d(	sa10_sub	));
aes_sbox us11(	.a(	sa11	), .d(	sa11_sub	));
aes_sbox us12(	.a(	sa12	), .d(	sa12_sub	));
aes_sbox us13(	.a(	sa13	), .d(	sa13_sub	));
aes_sbox us20(	.a(	sa20	), .d(	sa20_sub	));
aes_sbox us21(	.a(	sa21	), .d(	sa21_sub	));
aes_sbox us22(	.a(	sa22	), .d(	sa22_sub	));
aes_sbox us23(	.a(	sa23	), .d(	sa23_sub	));
aes_sbox us30(	.a(	sa30	), .d(	sa30_sub	));
aes_sbox us31(	.a(	sa31	), .d(	sa31_sub	));
aes_sbox us32(	.a(	sa32	), .d(	sa32_sub	));
aes_sbox us33(	.a(	sa33	), .d(	sa33_sub	));

endmodule


/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: aes_key_expand_128.v,v 1.1.1.1 2002/11/09 11:22:38 rudi Exp $
//
//  $Date: 2002/11/09 11:22:38 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: aes_key_expand_128.v,v $
//               Revision 1.1.1.1  2002/11/09 11:22:38  rudi
//               Initial Checkin
//
//
//
//
//
//


module aes_key_expand_128(clk, kld, key, wo_0, wo_1, wo_2, wo_3);
input		clk;
input		kld;
input	[127:0]	key;
output	[31:0]	wo_0, wo_1, wo_2, wo_3;
reg	[31:0]	w[3:0];
wire	[31:0]	tmp_w;
wire	[31:0]	subword;
wire	[31:0]	rcon;

assign wo_0 = w[0];
assign wo_1 = w[1];
assign wo_2 = w[2];
assign wo_3 = w[3];
always @(posedge clk)	w[0] <= #1 kld ? key[127:096] : w[0]^subword^rcon;
always @(posedge clk)	w[1] <= #1 kld ? key[095:064] : w[0]^w[1]^subword^rcon;
always @(posedge clk)	w[2] <= #1 kld ? key[063:032] : w[0]^w[2]^w[1]^subword^rcon;
always @(posedge clk)	w[3] <= #1 kld ? key[031:000] : w[0]^w[3]^w[2]^w[1]^subword^rcon;
assign tmp_w = w[3];
aes_sbox u0(	.a(tmp_w[23:16]), .d(subword[31:24]));
aes_sbox u1(	.a(tmp_w[15:08]), .d(subword[23:16]));
aes_sbox u2(	.a(tmp_w[07:00]), .d(subword[15:08]));
aes_sbox u3(	.a(tmp_w[31:24]), .d(subword[07:00]));
aes_rcon r0(	.clk(clk), .kld(kld), .out(rcon));
endmodule

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: aes_rcon.v,v 1.1.1.1 2002/11/09 11:22:38 rudi Exp $
//
//  $Date: 2002/11/09 11:22:38 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: aes_rcon.v,v $
//               Revision 1.1.1.1  2002/11/09 11:22:38  rudi
//               Initial Checkin
//
//
//
//
//
//



module aes_rcon(clk, kld, out);
input		clk;
input		kld;
output	[31:0]	out;
reg	[31:0]	out;
reg	[3:0]	rcnt;
wire	[3:0]	rcnt_next;

always @(posedge clk)
	if(kld)		out <= #1 32'h01_00_00_00;
	else		out <= #1 frcon(rcnt_next);

assign rcnt_next = rcnt + 4'h1;
always @(posedge clk)
	if(kld)		rcnt <= #1 4'h0;
	else		rcnt <= #1 rcnt_next;

function [31:0]	frcon;
input	[3:0]	i;
case(i)	// synopsys parallel_case
   4'h0: frcon=32'h01_00_00_00;
   4'h1: frcon=32'h02_00_00_00;
   4'h2: frcon=32'h04_00_00_00;
   4'h3: frcon=32'h08_00_00_00;
   4'h4: frcon=32'h10_00_00_00;
   4'h5: frcon=32'h20_00_00_00;
   4'h6: frcon=32'h40_00_00_00;
   4'h7: frcon=32'h80_00_00_00;
   4'h8: frcon=32'h1b_00_00_00;
   4'h9: frcon=32'h36_00_00_00;
   default: frcon=32'h00_00_00_00;
endcase
endfunction

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES SBOX (ROM)                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: aes_sbox.v,v 1.1.1.1 2002/11/09 11:22:38 rudi Exp $
//
//  $Date: 2002/11/09 11:22:38 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: aes_sbox.v,v $
//               Revision 1.1.1.1  2002/11/09 11:22:38  rudi
//               Initial Checkin
//
//
//
//
//
//



module aes_sbox(a,d);
input	[7:0]	a;
output	[7:0]	d;
reg	[7:0]	d;

always @(a)
	case(a)		// synopsys full_case parallel_case
	   8'h00: d=8'h63;
	   8'h01: d=8'h7c;
	   8'h02: d=8'h77;
	   8'h03: d=8'h7b;
	   8'h04: d=8'hf2;
	   8'h05: d=8'h6b;
	   8'h06: d=8'h6f;
	   8'h07: d=8'hc5;
	   8'h08: d=8'h30;
	   8'h09: d=8'h01;
	   8'h0a: d=8'h67;
	   8'h0b: d=8'h2b;
	   8'h0c: d=8'hfe;
	   8'h0d: d=8'hd7;
	   8'h0e: d=8'hab;
	   8'h0f: d=8'h76;
	   8'h10: d=8'hca;
	   8'h11: d=8'h82;
	   8'h12: d=8'hc9;
	   8'h13: d=8'h7d;
	   8'h14: d=8'hfa;
	   8'h15: d=8'h59;
	   8'h16: d=8'h47;
	   8'h17: d=8'hf0;
	   8'h18: d=8'had;
	   8'h19: d=8'hd4;
	   8'h1a: d=8'ha2;
	   8'h1b: d=8'haf;
	   8'h1c: d=8'h9c;
	   8'h1d: d=8'ha4;
	   8'h1e: d=8'h72;
	   8'h1f: d=8'hc0;
	   8'h20: d=8'hb7;
	   8'h21: d=8'hfd;
	   8'h22: d=8'h93;
	   8'h23: d=8'h26;
	   8'h24: d=8'h36;
	   8'h25: d=8'h3f;
	   8'h26: d=8'hf7;
	   8'h27: d=8'hcc;
	   8'h28: d=8'h34;
	   8'h29: d=8'ha5;
	   8'h2a: d=8'he5;
	   8'h2b: d=8'hf1;
	   8'h2c: d=8'h71;
	   8'h2d: d=8'hd8;
	   8'h2e: d=8'h31;
	   8'h2f: d=8'h15;
	   8'h30: d=8'h04;
	   8'h31: d=8'hc7;
	   8'h32: d=8'h23;
	   8'h33: d=8'hc3;
	   8'h34: d=8'h18;
	   8'h35: d=8'h96;
	   8'h36: d=8'h05;
	   8'h37: d=8'h9a;
	   8'h38: d=8'h07;
	   8'h39: d=8'h12;
	   8'h3a: d=8'h80;
	   8'h3b: d=8'he2;
	   8'h3c: d=8'heb;
	   8'h3d: d=8'h27;
	   8'h3e: d=8'hb2;
	   8'h3f: d=8'h75;
	   8'h40: d=8'h09;
	   8'h41: d=8'h83;
	   8'h42: d=8'h2c;
	   8'h43: d=8'h1a;
	   8'h44: d=8'h1b;
	   8'h45: d=8'h6e;
	   8'h46: d=8'h5a;
	   8'h47: d=8'ha0;
	   8'h48: d=8'h52;
	   8'h49: d=8'h3b;
	   8'h4a: d=8'hd6;
	   8'h4b: d=8'hb3;
	   8'h4c: d=8'h29;
	   8'h4d: d=8'he3;
	   8'h4e: d=8'h2f;
	   8'h4f: d=8'h84;
	   8'h50: d=8'h53;
	   8'h51: d=8'hd1;
	   8'h52: d=8'h00;
	   8'h53: d=8'hed;
	   8'h54: d=8'h20;
	   8'h55: d=8'hfc;
	   8'h56: d=8'hb1;
	   8'h57: d=8'h5b;
	   8'h58: d=8'h6a;
	   8'h59: d=8'hcb;
	   8'h5a: d=8'hbe;
	   8'h5b: d=8'h39;
	   8'h5c: d=8'h4a;
	   8'h5d: d=8'h4c;
	   8'h5e: d=8'h58;
	   8'h5f: d=8'hcf;
	   8'h60: d=8'hd0;
	   8'h61: d=8'hef;
	   8'h62: d=8'haa;
	   8'h63: d=8'hfb;
	   8'h64: d=8'h43;
	   8'h65: d=8'h4d;
	   8'h66: d=8'h33;
	   8'h67: d=8'h85;
	   8'h68: d=8'h45;
	   8'h69: d=8'hf9;
	   8'h6a: d=8'h02;
	   8'h6b: d=8'h7f;
	   8'h6c: d=8'h50;
	   8'h6d: d=8'h3c;
	   8'h6e: d=8'h9f;
	   8'h6f: d=8'ha8;
	   8'h70: d=8'h51;
	   8'h71: d=8'ha3;
	   8'h72: d=8'h40;
	   8'h73: d=8'h8f;
	   8'h74: d=8'h92;
	   8'h75: d=8'h9d;
	   8'h76: d=8'h38;
	   8'h77: d=8'hf5;
	   8'h78: d=8'hbc;
	   8'h79: d=8'hb6;
	   8'h7a: d=8'hda;
	   8'h7b: d=8'h21;
	   8'h7c: d=8'h10;
	   8'h7d: d=8'hff;
	   8'h7e: d=8'hf3;
	   8'h7f: d=8'hd2;
	   8'h80: d=8'hcd;
	   8'h81: d=8'h0c;
	   8'h82: d=8'h13;
	   8'h83: d=8'hec;
	   8'h84: d=8'h5f;
	   8'h85: d=8'h97;
	   8'h86: d=8'h44;
	   8'h87: d=8'h17;
	   8'h88: d=8'hc4;
	   8'h89: d=8'ha7;
	   8'h8a: d=8'h7e;
	   8'h8b: d=8'h3d;
	   8'h8c: d=8'h64;
	   8'h8d: d=8'h5d;
	   8'h8e: d=8'h19;
	   8'h8f: d=8'h73;
	   8'h90: d=8'h60;
	   8'h91: d=8'h81;
	   8'h92: d=8'h4f;
	   8'h93: d=8'hdc;
	   8'h94: d=8'h22;
	   8'h95: d=8'h2a;
	   8'h96: d=8'h90;
	   8'h97: d=8'h88;
	   8'h98: d=8'h46;
	   8'h99: d=8'hee;
	   8'h9a: d=8'hb8;
	   8'h9b: d=8'h14;
	   8'h9c: d=8'hde;
	   8'h9d: d=8'h5e;
	   8'h9e: d=8'h0b;
	   8'h9f: d=8'hdb;
	   8'ha0: d=8'he0;
	   8'ha1: d=8'h32;
	   8'ha2: d=8'h3a;
	   8'ha3: d=8'h0a;
	   8'ha4: d=8'h49;
	   8'ha5: d=8'h06;
	   8'ha6: d=8'h24;
	   8'ha7: d=8'h5c;
	   8'ha8: d=8'hc2;
	   8'ha9: d=8'hd3;
	   8'haa: d=8'hac;
	   8'hab: d=8'h62;
	   8'hac: d=8'h91;
	   8'had: d=8'h95;
	   8'hae: d=8'he4;
	   8'haf: d=8'h79;
	   8'hb0: d=8'he7;
	   8'hb1: d=8'hc8;
	   8'hb2: d=8'h37;
	   8'hb3: d=8'h6d;
	   8'hb4: d=8'h8d;
	   8'hb5: d=8'hd5;
	   8'hb6: d=8'h4e;
	   8'hb7: d=8'ha9;
	   8'hb8: d=8'h6c;
	   8'hb9: d=8'h56;
	   8'hba: d=8'hf4;
	   8'hbb: d=8'hea;
	   8'hbc: d=8'h65;
	   8'hbd: d=8'h7a;
	   8'hbe: d=8'hae;
	   8'hbf: d=8'h08;
	   8'hc0: d=8'hba;
	   8'hc1: d=8'h78;
	   8'hc2: d=8'h25;
	   8'hc3: d=8'h2e;
	   8'hc4: d=8'h1c;
	   8'hc5: d=8'ha6;
	   8'hc6: d=8'hb4;
	   8'hc7: d=8'hc6;
	   8'hc8: d=8'he8;
	   8'hc9: d=8'hdd;
	   8'hca: d=8'h74;
	   8'hcb: d=8'h1f;
	   8'hcc: d=8'h4b;
	   8'hcd: d=8'hbd;
	   8'hce: d=8'h8b;
	   8'hcf: d=8'h8a;
	   8'hd0: d=8'h70;
	   8'hd1: d=8'h3e;
	   8'hd2: d=8'hb5;
	   8'hd3: d=8'h66;
	   8'hd4: d=8'h48;
	   8'hd5: d=8'h03;
	   8'hd6: d=8'hf6;
	   8'hd7: d=8'h0e;
	   8'hd8: d=8'h61;
	   8'hd9: d=8'h35;
	   8'hda: d=8'h57;
	   8'hdb: d=8'hb9;
	   8'hdc: d=8'h86;
	   8'hdd: d=8'hc1;
	   8'hde: d=8'h1d;
	   8'hdf: d=8'h9e;
	   8'he0: d=8'he1;
	   8'he1: d=8'hf8;
	   8'he2: d=8'h98;
	   8'he3: d=8'h11;
	   8'he4: d=8'h69;
	   8'he5: d=8'hd9;
	   8'he6: d=8'h8e;
	   8'he7: d=8'h94;
	   8'he8: d=8'h9b;
	   8'he9: d=8'h1e;
	   8'hea: d=8'h87;
	   8'heb: d=8'he9;
	   8'hec: d=8'hce;
	   8'hed: d=8'h55;
	   8'hee: d=8'h28;
	   8'hef: d=8'hdf;
	   8'hf0: d=8'h8c;
	   8'hf1: d=8'ha1;
	   8'hf2: d=8'h89;
	   8'hf3: d=8'h0d;
	   8'hf4: d=8'hbf;
	   8'hf5: d=8'he6;
	   8'hf6: d=8'h42;
	   8'hf7: d=8'h68;
	   8'hf8: d=8'h41;
	   8'hf9: d=8'h99;
	   8'hfa: d=8'h2d;
	   8'hfb: d=8'h0f;
	   8'hfc: d=8'hb0;
	   8'hfd: d=8'h54;
	   8'hfe: d=8'hbb;
	   8'hff: d=8'h16;
	endcase

endmodule


