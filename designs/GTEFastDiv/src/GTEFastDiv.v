/*
	---------------------------------------------
		Playstation GTE Fast Unsigned Division
	---------------------------------------------

	Here is the specification according to No$PSX Documentation.
	----------------------------------------------------------

	GTE Division Inaccuracy (for RTPS/RTPT commands)
	Basically, the GTE division does (attempt to) work as so (using 33bit maths):
		n = (((H*20000h/SZ3)+1)/2)
	alternatively, below would give (almost) the same result (using 32bit maths):
		n = ((H*10000h+SZ3/2)/SZ3)
	in both cases, the result is saturated about as so:
		if n>1FFFFh or division_by_zero then n=1FFFFh, FLAG.Bit17=1, FLAG.Bit31=1
  
	"However, the real GTE hardware is using a fast, but less accurate division mechanism (based on Unsigned Newton-Raphson (UNR) algorithm):

	if (H < SZ3*2) then                            ;check if overflow
		z = count_leading_zeroes(SZ3)                ;z=0..0Fh (for 16bit SZ3)
		n = (H SHL z)                                ;n=0..7FFF8000h
		d = (SZ3 SHL z)                              ;d=8000h..FFFFh
		u = unr_table[(d-7FC0h) SHR 7] + 101h        ;u=200h..101h
		d = ((2000080h - (d * u)) SHR 8)             ;d=10000h..0FF01h
		d = ((0000080h + (d * u)) SHR 8)             ;d=20000h..10000h
		n = min(1FFFFh, (((n*d) + 8000h) SHR 16))    ;n=0..1FFFFh
	else n = 1FFFFh, FLAG.Bit17=1, FLAG.Bit31=1    ;n=1FFFFh plus overflow flag "

	the GTE's unr_table[000h..100h] consists of following values:

	  FFh,FDh,FBh,F9h,F7h,F5h,F3h,F1h,EFh,EEh,ECh,EAh,E8h,E6h,E4h,E3h ;\
	  E1h,DFh,DDh,DCh,DAh,D8h,D6h,D5h,D3h,D1h,D0h,CEh,CDh,CBh,C9h,C8h ; 00h..3Fh
	  C6h,C5h,C3h,C1h,C0h,BEh,BDh,BBh,BAh,B8h,B7h,B5h,B4h,B2h,B1h,B0h ;
	  AEh,ADh,ABh,AAh,A9h,A7h,A6h,A4h,A3h,A2h,A0h,9Fh,9Eh,9Ch,9Bh,9Ah ;/
	  99h,97h,96h,95h,94h,92h,91h,90h,8Fh,8Dh,8Ch,8Bh,8Ah,89h,87h,86h ;\
	  85h,84h,83h,82h,81h,7Fh,7Eh,7Dh,7Ch,7Bh,7Ah,79h,78h,77h,75h,74h ; 40h..7Fh
	  73h,72h,71h,70h,6Fh,6Eh,6Dh,6Ch,6Bh,6Ah,69h,68h,67h,66h,65h,64h ;
	  63h,62h,61h,60h,5Fh,5Eh,5Dh,5Dh,5Ch,5Bh,5Ah,59h,58h,57h,56h,55h ;/
	  54h,53h,53h,52h,51h,50h,4Fh,4Eh,4Dh,4Dh,4Ch,4Bh,4Ah,49h,48h,48h ;\
	  47h,46h,45h,44h,43h,43h,42h,41h,40h,3Fh,3Fh,3Eh,3Dh,3Ch,3Ch,3Bh ; 80h..BFh
	  3Ah,39h,39h,38h,37h,36h,36h,35h,34h,33h,33h,32h,31h,31h,30h,2Fh ;
	  2Eh,2Eh,2Dh,2Ch,2Ch,2Bh,2Ah,2Ah,29h,28h,28h,27h,26h,26h,25h,24h ;/
	  24h,23h,22h,22h,21h,20h,20h,1Fh,1Eh,1Eh,1Dh,1Dh,1Ch,1Bh,1Bh,1Ah ;\
	  19h,19h,18h,18h,17h,16h,16h,15h,15h,14h,14h,13h,12h,12h,11h,11h ; C0h..FFh
	  10h,0Fh,0Fh,0Eh,0Eh,0Dh,0Dh,0Ch,0Ch,0Bh,0Ah,0Ah,09h,09h,08h,08h ;
	  07h,07h,06h,06h,05h,05h,04h,04h,03h,03h,02h,02h,01h,01h,00h,00h ;/
	  00h    ;<-- one extra table entry (for "(d-7FC0h)/80h"=100h)    ;-100h

	Above can be generated as "unr_table[i]=min(0,(40000h/(i+100h)+1)/2-101h)".
	Some special cases: NNNNh/0001h uses a big multiplier (d=20000h), in practice, this can occur only for 0000h/0001h and 0001h/0001h (due to the H<SZ3*2 overflow check).
	The min(1FFFFh) limit is needed for cases like FE3Fh/7F20h, F015h/780Bh, etc. (these do produce UNR result 20000h, and are saturated to 1FFFFh, but without setting overflow FLAG bits).

	From Reddit, an interesting anecdote worth pasting here :
	----------------------------------------------------------
	"Anecdote time: This information cost someone his job! Back in the day, the main technical support mechanism for PSX devs was private newsgroups (remember them!) 
	running on a Sony news server. It was common to use the same app (e.g. Outlook Express) to both send emails and read newsgroups, and if you weren't careful 
	you could send a mail to both an email address and a newsgroup at the same time. That's what happened here!

	Someone else had discovered a quirk of the RTPS opcode and documented his findings, and then this guy had leaked the information to an emulator developer, 
	passing it off as his own research, and then accidentally copying it to the Sony newsgroup, for all the devs and Sony support team to see. 
	News servers had to be configured to handle 'delete requests', and this one wasn't, so the post was there for all to see, publicly shaming the leaker (who would've been under NDA) 
	and presumably quickly leading to his company losing their PSX development licence, and naturally his dismissal. 
	Amusingly I think what riled some people most was not that he was leaking confidential technical details, but that he was passing someone else's research off as his own! 
	Funny times. But I guess we ought to consider him a hero now, as this information would have been long lost otherwise!"
	
	---------------------------------------------
	Hardware will do the bit 31 outside from bit 17. So we output only the overflow bit.
	- Possible implementation / optimization : Use 2x Multiplier instead of Logarithmic Shifter.
	- For now, all combinatorial. Depending on specs, will probably pipeline some stages.
*/

module GTEFastDiv(
	input [15:0]	h,			// Dividend
	input [15:0]	z3,			// Divisor
	output[16:0]	divRes,		// Result
	output          overflow	// Overflow bit
);
	// (H < SZ3*2)
	wire isHLessZM2 = ( { 1'b0,h } < { z3,1'b0 } );

	//-----------------------------------------------
	//  Count 'h' Leading zero computation
	//-----------------------------------------------
	// Probably a bit smaller than a 16 bit priority encoder.
	// Faster too.
	reg [1:0] countT3,countT2,countT1,countT0;
	
	always @ (z3)
	casez(z3[15:12]) // Number of leading zero for [15:12]
		4'b0001: countT3 = 2'b11; 
		4'b001?: countT3 = 2'b10;
		4'b01??: countT3 = 2'b01;
		4'b1???: countT3 = 2'b00;
		default: countT3 = 2'b00;
	endcase
	wire anyOneT3 = |z3[15:12];
	

	always @ (z3)
	casez(z3[11:8]) // Number of leading zero for [11: 8]
		4'b0001: countT2 = 2'b11;
		4'b001?: countT2 = 2'b10;
		4'b01??: countT2 = 2'b01;
		4'b1???: countT2 = 2'b00;
		default: countT2 = 2'b00;
	endcase
	wire anyOneT2 = |z3[11:8];

	always @ (z3)
	casez(z3[7:4]) // Number of leading zero for [ 7: 4]
		4'b0001: countT1 = 2'b11;
		4'b001?: countT1 = 2'b10;
		4'b01??: countT1 = 2'b01;
		4'b1???: countT1 = 2'b00;
		default: countT1 = 2'b00;
	endcase
	wire anyOneT1 = |z3[7:4];

	always @ (z3)
	casez(z3[3:0]) // Number of leading zero for [ 3: 0]
		4'b0001: countT0 = 2'b11;
		4'b001?: countT0 = 2'b10;
		4'b01??: countT0 = 2'b01;
		4'b1???: countT0 = 2'b00;
		default: countT0 = 2'b00;
	endcase
	// NEVER USED : wire anyOneT0 = |z3[3:0];

	// Gather all leading zero generated in parallel and generate final value.
	reg [3:0] shiftAmount;
	always @ (*)
	begin
		if (anyOneT3)
			shiftAmount = { 2'b00 ,countT3 };
		else
		begin
			if (anyOneT2)
				shiftAmount = { 2'b01, countT2 };
			else
			begin
				if (anyOneT1)
					shiftAmount = { 2'b10, countT1 };
				else
					shiftAmount = { 2'b11, countT0 };
			end
		end
	end
	
	// ---------------------------------------------
	//   Z - 16 Bit Barrel Shifter (Could use a multiplier too)
	// ---------------------------------------------
	wire [15:0] b0	= shiftAmount[3] ? { z3[ 7:0], 8'd0 } : z3[15:0];	// 8 Bit Left Shift
	wire [15:0] b1	= shiftAmount[2] ? { b0[11:0], 4'd0 } : b0[15:0];	// 4 Bit Left Shift
	wire [15:0] b2	= shiftAmount[1] ? { b1[13:0], 2'd0 } : b1[15:0];	// 2 Bit Left Shift
	wire [15:0] b3	= shiftAmount[0] ? { b2[14:0], 1'd0 } : b2[15:0];	// 1 Bit Left Shift
	wire [15:0] d   = b3;	// [8000..FFFF]
	
	// ---------------------------------------------
	//   H - 16 to 31 Bit extending Barrel Shifter (Could use a multiplier too)
	// ---------------------------------------------
	wire [23:0] h0	= shiftAmount[3] ? {  h, 8'd0 } : { 8'd0, h  };	// 8 Bit Left Shift
	wire [27:0] h1	= shiftAmount[2] ? { h0, 4'd0 } : { 4'd0, h0 };	// 4 Bit Left Shift
	wire [29:0] h2	= shiftAmount[1] ? { h1, 2'd0 } : { 2'd0, h1 };	// 2 Bit Left Shift
	wire [30:0] h3	= shiftAmount[0] ? { h2, 1'd0 } : { 1'd0, h2 };	// 1 Bit Left Shift
	wire [30:0] n   = h3;	// [0..7FFF8000]
	
	// ---------------------------------------------
	// unr_table[(d-7FC0h) SHR 7] + 101h
	// ---------------------------------------------
	wire [15:0] ladr = d - 16'h7FC0; // [0x8000~0xFFFF] - 0x7FC0
	
	reg [7:0] lookup; // PUT HERE BECAUSSE MODELSIM DID NOT LIKE AFTER !!!!
	always @(*)
	begin
		case (ladr[14:7])
		'd0   : lookup = 8'hff;  'd1  : lookup = 8'hfd; 'd2   : lookup = 8'hfb;  'd3  : lookup = 8'hf9;  'd4  : lookup = 8'hf7;  'd5  : lookup = 8'hf5;  'd6  : lookup = 8'hf3;  'd7  : lookup = 8'hf1;
		'd8   : lookup = 8'hef;  'd9  : lookup = 8'hee; 'd10  : lookup = 8'hec;  'd11 : lookup = 8'hea;  'd12 : lookup = 8'he8;  'd13 : lookup = 8'he6;  'd14 : lookup = 8'he4;  'd15 : lookup = 8'he3;
		'd16  : lookup = 8'he1;	 'd17 : lookup = 8'hdf;	'd18  : lookup = 8'hdd;	 'd19 : lookup = 8'hdc;  'd20 : lookup = 8'hda;  'd21 : lookup = 8'hd8;  'd22 : lookup = 8'hd6;  'd23 : lookup = 8'hd5;
		'd24  : lookup = 8'hd3;	 'd25 : lookup = 8'hd1;	'd26  : lookup = 8'hd0;	 'd27 : lookup = 8'hce;  'd28 : lookup = 8'hcd;  'd29 : lookup = 8'hcb;  'd30 : lookup = 8'hc9;  'd31 : lookup = 8'hc8;
		'd32  : lookup = 8'hc6;	 'd33 : lookup = 8'hc5;	'd34  : lookup = 8'hc3;	 'd35 : lookup = 8'hc1;  'd36 : lookup = 8'hc0;  'd37 : lookup = 8'hbe;  'd38 : lookup = 8'hbd;  'd39 : lookup = 8'hbb;
		'd40  : lookup = 8'hba;	 'd41 : lookup = 8'hb8;	'd42  : lookup = 8'hb7;	 'd43 : lookup = 8'hb5;  'd44 : lookup = 8'hb4;  'd45 : lookup = 8'hb2;  'd46 : lookup = 8'hb1;  'd47 : lookup = 8'hb0;
		'd48  : lookup = 8'hae;	 'd49 : lookup = 8'had;	'd50  : lookup = 8'hab;	 'd51 : lookup = 8'haa;  'd52 : lookup = 8'ha9;  'd53 : lookup = 8'ha7;  'd54 : lookup = 8'ha6;  'd55 : lookup = 8'ha4;
		'd56  : lookup = 8'ha3;	 'd57 : lookup = 8'ha2;	'd58  : lookup = 8'ha0;	 'd59 : lookup = 8'h9f;  'd60 : lookup = 8'h9e;  'd61 : lookup = 8'h9c;  'd62 : lookup = 8'h9b;  'd63 : lookup = 8'h9a;
		'd64  : lookup = 8'h99;	 'd65 : lookup = 8'h97;	'd66  : lookup = 8'h96;	 'd67 : lookup = 8'h95;  'd68 : lookup = 8'h94;  'd69 : lookup = 8'h92;  'd70 : lookup = 8'h91;  'd71 : lookup = 8'h90;
		'd72  : lookup = 8'h8f;	 'd73 : lookup = 8'h8d;	'd74  : lookup = 8'h8c;	 'd75 : lookup = 8'h8b;  'd76 : lookup = 8'h8a;  'd77 : lookup = 8'h89;  'd78 : lookup = 8'h87;  'd79 : lookup = 8'h86;
		'd80  : lookup = 8'h85;	 'd81 : lookup = 8'h84;	'd82  : lookup = 8'h83;	 'd83 : lookup = 8'h82;  'd84 : lookup = 8'h81;  'd85 : lookup = 8'h7f;  'd86 : lookup = 8'h7e;  'd87 : lookup = 8'h7d;
		'd88  : lookup = 8'h7c;	 'd89 : lookup = 8'h7b;	'd90  : lookup = 8'h7a;	 'd91 : lookup = 8'h79;  'd92 : lookup = 8'h78;  'd93 : lookup = 8'h77;  'd94 : lookup = 8'h75;  'd95 : lookup = 8'h74;
		'd96  : lookup = 8'h73;	 'd97 : lookup = 8'h72;	'd98  : lookup = 8'h71;	 'd99 : lookup = 8'h70; 'd100 : lookup = 8'h6f; 'd101 : lookup = 8'h6e; 'd102 : lookup = 8'h6d; 'd103 : lookup = 8'h6c;
		'd104 : lookup = 8'h6b; 'd105 : lookup = 8'h6a; 'd106 : lookup = 8'h69; 'd107 : lookup = 8'h68; 'd108 : lookup = 8'h67; 'd109 : lookup = 8'h66; 'd110 : lookup = 8'h65; 'd111 : lookup = 8'h64;
		'd112 : lookup = 8'h63; 'd113 : lookup = 8'h62; 'd114 : lookup = 8'h61; 'd115 : lookup = 8'h60; 'd116 : lookup = 8'h5f; 'd117 : lookup = 8'h5e; 'd118 : lookup = 8'h5d; 'd119 : lookup = 8'h5d;
		'd120 : lookup = 8'h5c; 'd121 : lookup = 8'h5b; 'd122 : lookup = 8'h5a; 'd123 : lookup = 8'h59; 'd124 : lookup = 8'h58; 'd125 : lookup = 8'h57; 'd126 : lookup = 8'h56; 'd127 : lookup = 8'h55;
		'd128 : lookup = 8'h54; 'd129 : lookup = 8'h53; 'd130 : lookup = 8'h53; 'd131 : lookup = 8'h52; 'd132 : lookup = 8'h51; 'd133 : lookup = 8'h50; 'd134 : lookup = 8'h4f; 'd135 : lookup = 8'h4e;
		'd136 : lookup = 8'h4d; 'd137 : lookup = 8'h4d; 'd138 : lookup = 8'h4c; 'd139 : lookup = 8'h4b; 'd140 : lookup = 8'h4a; 'd141 : lookup = 8'h49; 'd142 : lookup = 8'h48; 'd143 : lookup = 8'h48;
		'd144 : lookup = 8'h47; 'd145 : lookup = 8'h46; 'd146 : lookup = 8'h45; 'd147 : lookup = 8'h44; 'd148 : lookup = 8'h43; 'd149 : lookup = 8'h43; 'd150 : lookup = 8'h42; 'd151 : lookup = 8'h41;
		'd152 : lookup = 8'h40; 'd153 : lookup = 8'h3f; 'd154 : lookup = 8'h3f; 'd155 : lookup = 8'h3e; 'd156 : lookup = 8'h3d; 'd157 : lookup = 8'h3c; 'd158 : lookup = 8'h3c; 'd159 : lookup = 8'h3b;
		'd160 : lookup = 8'h3a; 'd161 : lookup = 8'h39; 'd162 : lookup = 8'h39; 'd163 : lookup = 8'h38; 'd164 : lookup = 8'h37; 'd165 : lookup = 8'h36; 'd166 : lookup = 8'h36; 'd167 : lookup = 8'h35;
		'd168 : lookup = 8'h34; 'd169 : lookup = 8'h33; 'd170 : lookup = 8'h33; 'd171 : lookup = 8'h32; 'd172 : lookup = 8'h31; 'd173 : lookup = 8'h31; 'd174 : lookup = 8'h30; 'd175 : lookup = 8'h2f;
		'd176 : lookup = 8'h2e; 'd177 : lookup = 8'h2e; 'd178 : lookup = 8'h2d; 'd179 : lookup = 8'h2c; 'd180 : lookup = 8'h2c; 'd181 : lookup = 8'h2b; 'd182 : lookup = 8'h2a; 'd183 : lookup = 8'h2a;
		'd184 : lookup = 8'h29; 'd185 : lookup = 8'h28; 'd186 : lookup = 8'h28; 'd187 : lookup = 8'h27; 'd188 : lookup = 8'h26; 'd189 : lookup = 8'h26; 'd190 : lookup = 8'h25; 'd191 : lookup = 8'h24;
		'd192 : lookup = 8'h24; 'd193 : lookup = 8'h23; 'd194 : lookup = 8'h22; 'd195 : lookup = 8'h22; 'd196 : lookup = 8'h21; 'd197 : lookup = 8'h20; 'd198 : lookup = 8'h20; 'd199 : lookup = 8'h1f;
		'd200 : lookup = 8'h1e; 'd201 : lookup = 8'h1e; 'd202 : lookup = 8'h1d; 'd203 : lookup = 8'h1d; 'd204 : lookup = 8'h1c; 'd205 : lookup = 8'h1b; 'd206 : lookup = 8'h1b; 'd207 : lookup = 8'h1a;
		'd208 : lookup = 8'h19; 'd209 : lookup = 8'h19; 'd210 : lookup = 8'h18; 'd211 : lookup = 8'h18; 'd212 : lookup = 8'h17; 'd213 : lookup = 8'h16; 'd214 : lookup = 8'h16; 'd215 : lookup = 8'h15;
		'd216 : lookup = 8'h15; 'd217 : lookup = 8'h14; 'd218 : lookup = 8'h14; 'd219 : lookup = 8'h13; 'd220 : lookup = 8'h12; 'd221 : lookup = 8'h12; 'd222 : lookup = 8'h11; 'd223 : lookup = 8'h11;
		'd224 : lookup = 8'h10; 'd225 : lookup = 8'h0f; 'd226 : lookup = 8'h0f; 'd227 : lookup = 8'h0e; 'd228 : lookup = 8'h0e; 'd229 : lookup = 8'h0d; 'd230 : lookup = 8'h0d; 'd231 : lookup = 8'h0c;
		'd232 : lookup = 8'h0c; 'd233 : lookup = 8'h0b; 'd234 : lookup = 8'h0a; 'd235 : lookup = 8'h0a; 'd236 : lookup = 8'h09; 'd237 : lookup = 8'h09; 'd238 : lookup = 8'h08; 'd239 : lookup = 8'h08;
		'd240 : lookup = 8'h07;	'd241 : lookup = 8'h07;	'd242 : lookup = 8'h06;	'd243 : lookup = 8'h06;	'd244 : lookup = 8'h05;	'd245 : lookup = 8'h05;	'd246 : lookup = 8'h04;	'd247 : lookup = 8'h04;
		'd248 : lookup = 8'h03;	'd249 : lookup = 8'h03;	'd250 : lookup = 8'h02;	'd251 : lookup = 8'h02;	'd252 : lookup = 8'h01;	'd253 : lookup = 8'h01;	'd254 : lookup = 8'h00;	'd255 : lookup = 8'h00;
		default: lookup = 8'h00;
	endcase
	end
	wire [7:0] uLUT  = ladr[15] ? 8'h00 : lookup;
	wire [9:0] u     = {2'b00,uLUT} + 10'h101;				// Output = [0x101..0x200] (need 10 bit because of 0x200 !)

	// ---------------------------------------------
	//   Stage 2
	// ---------------------------------------------
	// d = ((0x2000080 - (d * u)) >> 8); d=10000h..0FF01h
	wire [25:0] mdu1 = (d*u);						// .16x.10 = .26	Output [808000..0x1FFFE00]
	wire [25:0] dmdu1= 26'h2000080 - mdu1;			// Fix 25 Bit :     Output [ 0x280..0x17F8080]
	wire [16:0] d2 = dmdu1[24:8];					// Shr 8.			Output [   0x2..0x17F80  ]
	
	// ---------------------------------------------
	//   Stage 3
	// ---------------------------------------------
	// d = ((0x0000080 + (d * u)) >> 8); d=20000h..10000h
	wire [26:0] mdu2 = (d2*u);						// .17x.10 = .27	Output [ 0x202..0x2FF0000] (but 26 bit should be enough)
	wire [19:0] dmdu2=  mdu2[26:7] + 1'b1; 			// Same as adding 0x80 then shift 7, less HW.
	wire [18:0] d3   = dmdu2[19:1];					// Then shift 1 again.
	
	// ---------------------------------------------
	//   Stage 4
	// ---------------------------------------------
	// n = min(0x1FFFF, (((n*d) + 0x8000) >> 16)); // n=0..1FFFFh
	wire [49:0] mnd = n*d3; 					// .31 x .19
	wire [34:0] shfm= mnd[49:15] + 1'b1;		// Remove 15 bit add 1 = same as add 0x8000 then shift 15.
	wire [33:0] shcp= shfm[34:1];

	wire   ovf				= !isHLessZM2;
	wire 		isOver		= (|shcp[33:17]) | ovf;			// Same as >= 0x20000, optimized comparison OR overflow bit set from comparison test.
	wire [16:0] outStage4	=   shcp[16: 0]  | {17{isOver}};// Saturated arithmetic, if over 0x2000 -> then all 0x1FFFF, else value.
	
	// + setup bit17 and bit 31:
	// 17   Divide overflow. RTPS/RTPT division result saturated to max=1FFFFh
	// 31	Error Flag (Bit30..23, and 18..13 ORed together) (Read only)
	// if n>1FFFFh or division_by_zero then n=1FFFFh, FLAG.Bit17=1, FLAG.Bit31=1

	// ---------------------------------------------
	//   Output
	// ---------------------------------------------
	assign divRes	= outStage4;
	assign overflow	= ovf;
endmodule