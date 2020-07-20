module	divider_dshift(
input	i_clk,
input	i_rst,
input	[31:0]i_dividend,
input	[31:0]i_divisor,
input	i_start,
output	o_ready,
output	reg	[31:0]o_quotient,
output	reg	[31:0]o_remainder
);

parameter	
		state_1=1,
		state_2=2,
		state_3=4,
		state_4=8,
		state_5=16,
		state_6=32;


reg	[31:0]PR;		//partial remainder
reg	signed[31:0]PR_1;
reg	[31:0]DR;		//divisor
reg	[5:0]ct,ct_1;		// ct: index for quotient bit under calculation	ct_1: shift value for last PR
reg	ct_1_en,ct_1_en_1;			// enable calculating of ct_1
reg	DD_sign;		//sign of dividend
reg	[5:0]state;
reg	ready;
assign	o_ready=ready?i_start:0;
reg	[30:0]nq;	//negative quotient
reg	[30:0]q;	//positive quotient
wire	[30:0]nqp1;	// nq+1
wire	[30:0]qp1;	// q+1
assign	nqp1=nq+1;
assign	qp1=q+1;

wire	[31:0]nDR;
assign	nDR=~DR;
wire	nsub;	// not sub	'1' means PR=PR+DR;
		//		'0' means PR=PR-DR;
assign	nsub=PR[31]^DR[31];


/// over subtract detection during final results adjustment
wire	over_sub;
//assign	over_sub=(state==state_4)||(state==state_3)?DD_sign^PR[62]&(PR[62:31]!=0):0;
assign	over_sub=(DD_sign^PR[31])&(PR[31:0]!=0);
//reg	over_sub;
wire	addback_nDR;
wire	addback_DR;
assign	addback_nDR=over_sub&(~nsub);
assign	addback_DR=over_sub&nsub;
///
/// results adjustment
wire	[30:0]final_nq,final_q;
assign	final_nq=addback_DR?nqp1:nq;
assign	final_q=addback_nDR?qp1:q;
wire	[31:0]remainder_addback;
assign	remainder_addback=	addback_DR?i_divisor:
				addback_nDR?~i_divisor:0;
///

/// main subtractor 
wire	[31:0]a,b;
wire	[31:0]sum;
wire	carry_in;
wire	carry_out;

reg	[31:0]reg_a,reg_b;
reg	reg_carry;
reg	[1:0]state_reg;

///////////// Dynamic Shift /////////////
reg	[4:0]shifted,shifted_1;
reg	[31:0]sdata;
wire	[31:0]sdata_o;
wire	[4:0]shifted_o;
shifter	shifter_0(
sdata,
sdata_o,
shifted_o
);

/*
assign	a=	
		state==state_4?{1'b1,~final_nq}:
		state==state_5?remainder_addback:
		nsub?DR:nDR;
*/
assign	a=	ct_1_en?{27'd0,shifted_1}:
		state==state_4?{1'b1,~final_nq}:
		state==state_5?remainder_addback:
		nsub?DR:nDR;
assign	b=	ct_1_en?{26'd0,ct_1}:
		state==state_4?{1'b0,final_q}:
		state==state_5?PR_1:PR;

assign	carry_in=	ct_1_en?0:
		state==state_4?1:
		state==state_5?	addback_nDR?1:0:
		nsub?0:1;
		
adder_32bit	adder_0(
reg_a,
reg_b,
reg_carry,
sum,
carry_out
);




// ct calculation
//reg	UDR;	// update Divisor
wire	[5:0]sum_ct;
wire	[25:0]sum_ct_h;
wire	carry_ct;
adder_32bit	adder_1(
{26'd0,ct},
state[5]?{27'd0,shifted}:~{27'd0,shifted},
state[5]?1'b0:1'b1,
{sum_ct_h,sum_ct},
carry_ct
);






///////////////////////////////////////////

always@(posedge i_clk or negedge i_rst)
	if(!i_rst)begin
		sdata<=0;
		shifted<=0;
		shifted_1<=0;
		PR<=0;
		PR_1<=0;
		DR<=0;
		//UDR<=0;
		ready<=0;
		ct<=0;
		ct_1<=0;
		ct_1_en<=0;
		ct_1_en_1<=0;
		state<=state_1;
		DD_sign<=0;
		o_quotient<=0;
		o_remainder<=0;
		nq<=0;
		q<=0;
		//over_sub<=0;
		reg_a<=0;
		reg_b<=0;
		reg_carry<=0;
		state_reg<=0;
	end
	else begin
		if(ready&&(!i_start))ready<=0;
		case(state_reg)
		0:
		case(state)
			state_1:if((!ready)&&i_start)begin
				sdata<=i_divisor;
				state<=state_6;
				q<=0;
				nq<=0;
				shifted<=0;
				//UDR<=1;
			end
			state_2:begin
				sdata<=i_dividend;
				PR_1<=i_dividend;
				DD_sign<=i_dividend[31];
				state<=state_3;
				state_reg<=1;	
			end
			state_3:begin
				if(ct[5])begin
					state<=state_4;
					ct<=0;
					state_reg<=2;
				end
				else begin
					ct_1_en<=1;
					shifted_1<=shifted;
					nq[ct]<=nsub;
					q[ct]<=~nsub;				
					sdata<=sum;
					state_reg<=1;
				end
			end
			state_4:begin
				state<=state_5;
				o_quotient<=sum;
				PR_1<=PR_1>>>ct_1;
				state_reg<=2;
			end
			state_5:begin
				o_remainder<=sum;
				ct_1<=0;
				state<=state_1;
				ready<=1;
			end

			state_6:begin
				sdata<=sdata_o;
				shifted<=shifted_o;
				ct<=sum_ct;
				if(sdata[31]!=sdata[30])begin
					state<=state_2;
					DR<=sdata;
				end
			end
/*
			state_6:begin
				//if(!over_sub)o_remainder<=sum>>>ct_1;
				o_remainder<=sum;
				ct_1<=0;
				state<=state_1;
				ready<=1;
			end

*/
		endcase
		1:begin
			PR<=sdata_o;
			PR_1<=sdata;
/*
			if(UDR)begin
				UDR<=0;
				ct<=shifted;

				if(shifted==0)begin
					ct<=0;
				end
				else begin
					ct<=shifted-1;
					DR<={DR[31],DR[31:1]};
				end

			end
*/
			shifted<=shifted_o;
			state_reg<=2;
			reg_a<=a;	//calculate ct_1
			reg_b<=b;
			reg_carry<=carry_in;
			ct_1_en<=0;
			ct_1_en_1<=ct_1_en;
		end
		2:begin
			if(state==state_3)begin
				ct<=sum_ct;
			end
			state_reg<=0;
			if(ct_1_en_1)begin
				ct_1<=sum[5:0];
			end
			ct_1_en_1<=0;
			reg_a<=a;	// calculate PR
			reg_b<=b;
			reg_carry<=carry_in;
		end
		endcase
	end




endmodule

//Carry look-ahead adder

module	operator_A(
input	A,
input	B,
output	P,
output	G
);

assign	P=A^B;
assign	G=A&B;

endmodule

module	operator_B(
input	P,G,P1,G1,
output	Po,Go
);

assign	Po=P&P1;
assign	Go=G|(P&G1);

endmodule

module	operator_C(
input	P,G,G1,
output	Go
);

assign	Go=G|(P&G1);

endmodule


/* 32-bit prefix-2 Han-Carlson adder
stage 0:	Number of Generation=32,	NP=32,	NOA=32,	NOB=0,	NOC=0.
stage 1:	NG=16,	NP=15,	NOA=0,	NOB=15,	NOC=1.	
stage 2:	NG=16,	NP=14,	NOA=0,	NOB=14,	NOC=1.	
stage 3:	NG=16,	NP=12,	NOA=0,	NOB=12,	NOC=2.	
stage 4:	NG=16,	NP=8,	NOA=0,	NOB=8,	NOC=4.	
stage 5:	NG=16,	NP=0,	NOA=0,	NOB=0,	NOC=8.	
stage 6;	NG=32,	NP=0,	NOA=0,	NOB=0,	NOC=16.
*/
module	adder_32bit(
input	[31:0]i_a,i_b,
input	i_c,
output	[31:0]o_s,
output	o_c
);

//stage 0
wire	[31:0]P0,G0;
operator_A	operator_A_0(i_a[0],i_b[0],P0[0],G0[0]);
operator_A	operator_A_1(i_a[1],i_b[1],P0[1],G0[1]);
operator_A	operator_A_2(i_a[2],i_b[2],P0[2],G0[2]);
operator_A	operator_A_3(i_a[3],i_b[3],P0[3],G0[3]);
operator_A	operator_A_4(i_a[4],i_b[4],P0[4],G0[4]);
operator_A	operator_A_5(i_a[5],i_b[5],P0[5],G0[5]);
operator_A	operator_A_6(i_a[6],i_b[6],P0[6],G0[6]);
operator_A	operator_A_7(i_a[7],i_b[7],P0[7],G0[7]);
operator_A	operator_A_8(i_a[8],i_b[8],P0[8],G0[8]);
operator_A	operator_A_9(i_a[9],i_b[9],P0[9],G0[9]);
operator_A	operator_A_10(i_a[10],i_b[10],P0[10],G0[10]);
operator_A	operator_A_11(i_a[11],i_b[11],P0[11],G0[11]);
operator_A	operator_A_12(i_a[12],i_b[12],P0[12],G0[12]);
operator_A	operator_A_13(i_a[13],i_b[13],P0[13],G0[13]);
operator_A	operator_A_14(i_a[14],i_b[14],P0[14],G0[14]);
operator_A	operator_A_15(i_a[15],i_b[15],P0[15],G0[15]);
operator_A	operator_A_16(i_a[16],i_b[16],P0[16],G0[16]);
operator_A	operator_A_17(i_a[17],i_b[17],P0[17],G0[17]);
operator_A	operator_A_18(i_a[18],i_b[18],P0[18],G0[18]);
operator_A	operator_A_19(i_a[19],i_b[19],P0[19],G0[19]);
operator_A	operator_A_20(i_a[20],i_b[20],P0[20],G0[20]);
operator_A	operator_A_21(i_a[21],i_b[21],P0[21],G0[21]);
operator_A	operator_A_22(i_a[22],i_b[22],P0[22],G0[22]);
operator_A	operator_A_23(i_a[23],i_b[23],P0[23],G0[23]);
operator_A	operator_A_24(i_a[24],i_b[24],P0[24],G0[24]);
operator_A	operator_A_25(i_a[25],i_b[25],P0[25],G0[25]);
operator_A	operator_A_26(i_a[26],i_b[26],P0[26],G0[26]);
operator_A	operator_A_27(i_a[27],i_b[27],P0[27],G0[27]);
operator_A	operator_A_28(i_a[28],i_b[28],P0[28],G0[28]);
operator_A	operator_A_29(i_a[29],i_b[29],P0[29],G0[29]);
operator_A	operator_A_30(i_a[30],i_b[30],P0[30],G0[30]);
operator_A	operator_A_31(i_a[31],i_b[31],P0[31],G0[31]);

//stage 1
wire	[15:0]G1;
wire	[15:1]P1;
operator_C	operator_C_stage_1_0(P0[0],G0[0],i_c,G1[0]);
operator_B	operator_B_stage_1_1(P0[2],G0[2],P0[1],G0[1],P1[1],G1[1]);
operator_B	operator_B_stage_1_2(P0[4],G0[4],P0[3],G0[3],P1[2],G1[2]);
operator_B	operator_B_stage_1_3(P0[6],G0[6],P0[5],G0[5],P1[3],G1[3]);
operator_B	operator_B_stage_1_4(P0[8],G0[8],P0[7],G0[7],P1[4],G1[4]);
operator_B	operator_B_stage_1_5(P0[10],G0[10],P0[9],G0[9],P1[5],G1[5]);
operator_B	operator_B_stage_1_6(P0[12],G0[12],P0[11],G0[11],P1[6],G1[6]);
operator_B	operator_B_stage_1_7(P0[14],G0[14],P0[13],G0[13],P1[7],G1[7]);
operator_B	operator_B_stage_1_8(P0[16],G0[16],P0[15],G0[15],P1[8],G1[8]);
operator_B	operator_B_stage_1_9(P0[18],G0[18],P0[17],G0[17],P1[9],G1[9]);
operator_B	operator_B_stage_1_10(P0[20],G0[20],P0[19],G0[19],P1[10],G1[10]);
operator_B	operator_B_stage_1_11(P0[22],G0[22],P0[21],G0[21],P1[11],G1[11]);
operator_B	operator_B_stage_1_12(P0[24],G0[24],P0[23],G0[23],P1[12],G1[12]);
operator_B	operator_B_stage_1_13(P0[26],G0[26],P0[25],G0[25],P1[13],G1[13]);
operator_B	operator_B_stage_1_14(P0[28],G0[28],P0[27],G0[27],P1[14],G1[14]);
operator_B	operator_B_stage_1_15(P0[30],G0[30],P0[29],G0[29],P1[15],G1[15]);



//stage 2
wire	[15:0]G2;
wire	[15:2]P2;
assign	G2[0]=G1[0];
operator_C	operator_C_stage_2_1(P1[1],G1[1],G1[0],G2[1]);
operator_B	operator_B_stage_2_2(P1[2], G1[2],P1[1],G1[1],P2[2],G2[2]);
operator_B	operator_B_stage_2_3(P1[3], G1[3],P1[2],G1[2],P2[3],G2[3]);
operator_B	operator_B_stage_2_4(P1[4], G1[4],P1[3],G1[3],P2[4],G2[4]);
operator_B	operator_B_stage_2_5(P1[5], G1[5],P1[4],G1[4],P2[5],G2[5]);
operator_B	operator_B_stage_2_6(P1[6], G1[6],P1[5],G1[5],P2[6],G2[6]);
operator_B	operator_B_stage_2_7(P1[7], G1[7],P1[6],G1[6],P2[7],G2[7]);
operator_B	operator_B_stage_2_8(P1[8], G1[8],P1[7],G1[7],P2[8],G2[8]);
operator_B	operator_B_stage_2_9(P1[9], G1[9],P1[8],G1[8],P2[9],G2[9]);
operator_B	operator_B_stage_2_10(P1[10], G1[10],P1[9],G1[9],P2[10],G2[10]);
operator_B	operator_B_stage_2_11(P1[11], G1[11],P1[10],G1[10],P2[11],G2[11]);
operator_B	operator_B_stage_2_12(P1[12], G1[12],P1[11],G1[11],P2[12],G2[12]);
operator_B	operator_B_stage_2_13(P1[13], G1[13],P1[12],G1[12],P2[13],G2[13]);
operator_B	operator_B_stage_2_14(P1[14], G1[14],P1[13],G1[13],P2[14],G2[14]);
operator_B	operator_B_stage_2_15(P1[15], G1[15],P1[14],G1[14],P2[15],G2[15]);

//stage 3
wire	[15:0]G3;
wire	[15:4]P3;
assign	G3[0]=G2[0];
assign	G3[1]=G2[1];
operator_C	operator_C_stage_3_2(P2[2],G2[2],G2[0],G3[2]);
operator_C	operator_C_stage_3_3(P2[3],G2[3],G2[1],G3[3]);
operator_B	operator_B_stage_3_4(P2[4], G2[4],P2[2],G2[2],P3[4],G3[4]);
operator_B	operator_B_stage_3_5(P2[5], G2[5],P2[3],G2[3],P3[5],G3[5]);
operator_B	operator_B_stage_3_6(P2[6], G2[6],P2[4],G2[4],P3[6],G3[6]);
operator_B	operator_B_stage_3_7(P2[7], G2[7],P2[5],G2[5],P3[7],G3[7]);
operator_B	operator_B_stage_3_8(P2[8], G2[8],P2[6],G2[6],P3[8],G3[8]);
operator_B	operator_B_stage_3_9(P2[9], G2[9],P2[7],G2[7],P3[9],G3[9]);
operator_B	operator_B_stage_3_10(P2[10], G2[10],P2[8],G2[8],P3[10],G3[10]);
operator_B	operator_B_stage_3_11(P2[11], G2[11],P2[9],G2[9],P3[11],G3[11]);
operator_B	operator_B_stage_3_12(P2[12], G2[12],P2[10],G2[10],P3[12],G3[12]);
operator_B	operator_B_stage_3_13(P2[13], G2[13],P2[11],G2[11],P3[13],G3[13]);
operator_B	operator_B_stage_3_14(P2[14], G2[14],P2[12],G2[12],P3[14],G3[14]);
operator_B	operator_B_stage_3_15(P2[15], G2[15],P2[13],G2[13],P3[15],G3[15]);

//stage 4
wire	[15:0]G4;
wire	[15:8]P4;
assign	G4[0]=G3[0];
assign	G4[1]=G3[1];
assign	G4[2]=G3[2];
assign	G4[3]=G3[3];
operator_C	operator_C_stage_4_4(P3[4],G3[4],G3[0],G4[4]);
operator_C	operator_C_stage_4_5(P3[5],G3[5],G3[1],G4[5]);
operator_C	operator_C_stage_4_6(P3[6],G3[6],G3[2],G4[6]);
operator_C	operator_C_stage_4_7(P3[7],G3[7],G3[3],G4[7]);
operator_B	operator_B_stage_4_8(P3[8], G3[8],P3[4],G3[4],P4[8],G4[8]);
operator_B	operator_B_stage_4_9(P3[9], G3[9],P3[5],G3[5],P4[9],G4[9]);
operator_B	operator_B_stage_4_10(P3[10], G3[10],P3[6],G3[6],P4[10],G4[10]);
operator_B	operator_B_stage_4_11(P3[11], G3[11],P3[7],G3[7],P4[11],G4[11]);
operator_B	operator_B_stage_4_12(P3[12], G3[12],P3[8],G3[8],P4[12],G4[12]);
operator_B	operator_B_stage_4_13(P3[13], G3[13],P3[9],G3[9],P4[13],G4[13]);
operator_B	operator_B_stage_4_14(P3[14], G3[14],P3[10],G3[10],P4[14],G4[14]);
operator_B	operator_B_stage_4_15(P3[15], G3[15],P3[11],G3[11],P4[15],G4[15]);

//stage 5
wire	[15:0]G5;
assign	G5[0]=G4[0];
assign	G5[1]=G4[1];
assign	G5[2]=G4[2];
assign	G5[3]=G4[3];
assign	G5[4]=G4[4];
assign	G5[5]=G4[5];
assign	G5[6]=G4[6];
assign	G5[7]=G4[7];
operator_C	operator_C_stage_5_8(P4[8],G4[8],G4[0],G5[8]);
operator_C	operator_C_stage_5_9(P4[9],G4[9],G4[1],G5[9]);
operator_C	operator_C_stage_5_10(P4[10],G4[10],G4[2],G5[10]);
operator_C	operator_C_stage_5_11(P4[11],G4[11],G4[3],G5[11]);
operator_C	operator_C_stage_5_12(P4[12],G4[12],G4[4],G5[12]);
operator_C	operator_C_stage_5_13(P4[13],G4[13],G4[5],G5[13]);
operator_C	operator_C_stage_5_14(P4[14],G4[14],G4[6],G5[14]);
operator_C	operator_C_stage_5_15(P4[15],G4[15],G4[7],G5[15]);

//stage 6
wire	[31:0]G6;
assign	G6[0]=G5[0];
assign	G6[2]=G5[1];
assign	G6[4]=G5[2];
assign	G6[6]=G5[3];
assign	G6[8]=G5[4];
assign	G6[10]=G5[5];
assign	G6[12]=G5[6];
assign	G6[14]=G5[7];
assign	G6[16]=G5[8];
assign	G6[18]=G5[9];
assign	G6[20]=G5[10];
assign	G6[22]=G5[11];
assign	G6[24]=G5[12];
assign	G6[26]=G5[13];
assign	G6[28]=G5[14];
assign	G6[30]=G5[15];
operator_C	operator_C_stage_6_0(P0[1],G0[1],G5[0],G6[1]);
operator_C	operator_C_stage_6_1(P0[3],G0[3],G5[1],G6[3]);
operator_C	operator_C_stage_6_2(P0[5],G0[5],G5[2],G6[5]);
operator_C	operator_C_stage_6_3(P0[7],G0[7],G5[3],G6[7]);
operator_C	operator_C_stage_6_4(P0[9],G0[9],G5[4],G6[9]);
operator_C	operator_C_stage_6_5(P0[11],G0[11],G5[5],G6[11]);
operator_C	operator_C_stage_6_6(P0[13],G0[13],G5[6],G6[13]);
operator_C	operator_C_stage_6_7(P0[15],G0[15],G5[7],G6[15]);
operator_C	operator_C_stage_6_8(P0[17],G0[17],G5[8],G6[17]);
operator_C	operator_C_stage_6_9(P0[19],G0[19],G5[9],G6[19]);
operator_C	operator_C_stage_6_10(P0[21],G0[21],G5[10],G6[21]);
operator_C	operator_C_stage_6_11(P0[23],G0[23],G5[11],G6[23]);
operator_C	operator_C_stage_6_12(P0[25],G0[25],G5[12],G6[25]);
operator_C	operator_C_stage_6_13(P0[27],G0[27],G5[13],G6[27]);
operator_C	operator_C_stage_6_14(P0[29],G0[29],G5[14],G6[29]);
operator_C	operator_C_stage_6_15(P0[31],G0[31],G5[15],G6[31]);

assign	o_s[0]=P0[0]^i_c;
assign	o_s[1]=P0[1]^G6[0];
assign	o_s[2]=P0[2]^G6[1];
assign	o_s[3]=P0[3]^G6[2];
assign	o_s[4]=P0[4]^G6[3];
assign	o_s[5]=P0[5]^G6[4];
assign	o_s[6]=P0[6]^G6[5];
assign	o_s[7]=P0[7]^G6[6];
assign	o_s[8]=P0[8]^G6[7];
assign	o_s[9]=P0[9]^G6[8];
assign	o_s[10]=P0[10]^G6[9];
assign	o_s[11]=P0[11]^G6[10];
assign	o_s[12]=P0[12]^G6[11];
assign	o_s[13]=P0[13]^G6[12];
assign	o_s[14]=P0[14]^G6[13];
assign	o_s[15]=P0[15]^G6[14];
assign	o_s[16]=P0[16]^G6[15];
assign	o_s[17]=P0[17]^G6[16];
assign	o_s[18]=P0[18]^G6[17];
assign	o_s[19]=P0[19]^G6[18];
assign	o_s[20]=P0[20]^G6[19];
assign	o_s[21]=P0[21]^G6[20];
assign	o_s[22]=P0[22]^G6[21];
assign	o_s[23]=P0[23]^G6[22];
assign	o_s[24]=P0[24]^G6[23];
assign	o_s[25]=P0[25]^G6[24];
assign	o_s[26]=P0[26]^G6[25];
assign	o_s[27]=P0[27]^G6[26];
assign	o_s[28]=P0[28]^G6[27];
assign	o_s[29]=P0[29]^G6[28];
assign	o_s[30]=P0[30]^G6[29];
assign	o_s[31]=P0[31]^G6[30];
assign	o_c=G6[31];

endmodule

module	shift_1b(
input	i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
assign	o_data=i_shift?{i_data[30:0],1'b0}:i_data;

endmodule

module	shift_3b(
input	[2:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[1]?{i_data[29:0],2'b0}:i_data;
wire	shift1;
assign	shift1=(i_shift[0]&i_shift[1])|(i_shift[2]^i_shift[1]);
shift_1b	shift_1b_0(
shift1,
data1,
o_data
);
endmodule

module	shift_7b(
input	[6:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[3]?{i_data[27:0],4'b0}:i_data;
wire	[2:0]shift1;
assign	shift1=(i_shift[2:0]&{3{i_shift[3]}})|(i_shift[6:4]^{3{i_shift[3]}});

shift_3b	shift_3b_0(
shift1,
data1,
o_data
);

endmodule

module	shift_15b(
input	[14:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[7]?{i_data[23:0],8'b0}:i_data;
wire	[6:0]shift1;
assign	shift1=(i_shift[6:0]&{7{i_shift[7]}})|(i_shift[14:8]^{7{i_shift[7]}});

shift_7b	shift_7b_0(
shift1,
data1,
o_data
);

endmodule











module	shifter(
input	[31:0]i_data,
output	[31:0]o_data,
output	[4:0]o_shifted
);

wire	[31:0]node_0;
assign	node_0=i_data[31]?i_data:~i_data;

// odd nodes tree
///////////////////////// layer 1 ////////////////////////////
wire	[15:0]onode_1;
assign	onode_1[0]=node_0[0]&node_0[1];
assign	onode_1[1]=node_0[2]&node_0[3];
assign	onode_1[2]=node_0[4]&node_0[5];
assign	onode_1[3]=node_0[6]&node_0[7];
assign	onode_1[4]=node_0[8]&node_0[9];
assign	onode_1[5]=node_0[10]&node_0[11];
assign	onode_1[6]=node_0[12]&node_0[13];
assign	onode_1[7]=node_0[14]&node_0[15];
assign	onode_1[8]=node_0[16]&node_0[17];
assign	onode_1[9]=node_0[18]&node_0[19];
assign	onode_1[10]=node_0[20]&node_0[21];
assign	onode_1[11]=node_0[22]&node_0[23];
assign	onode_1[12]=node_0[24]&node_0[25];
assign	onode_1[13]=node_0[26]&node_0[27];
assign	onode_1[14]=node_0[28]&node_0[29];
assign	onode_1[15]=node_0[30]&node_0[31];
///////////////////////// layer 2 ////////////////////////////
wire	[15:0]onode_2;
assign	onode_2[0]=onode_1[0]&onode_1[1];
assign	onode_2[1]=onode_1[1]&onode_1[2];
assign	onode_2[2]=onode_1[2]&onode_1[3];
assign	onode_2[3]=onode_1[3]&onode_1[4];
assign	onode_2[4]=onode_1[4]&onode_1[5];
assign	onode_2[5]=onode_1[5]&onode_1[6];
assign	onode_2[6]=onode_1[6]&onode_1[7];
assign	onode_2[7]=onode_1[7]&onode_1[8];
assign	onode_2[8]=onode_1[8]&onode_1[9];
assign	onode_2[9]=onode_1[9]&onode_1[10];
assign	onode_2[10]=onode_1[10]&onode_1[11];
assign	onode_2[11]=onode_1[11]&onode_1[12];
assign	onode_2[12]=onode_1[12]&onode_1[13];
assign	onode_2[13]=onode_1[13]&onode_1[14];
assign	onode_2[14]=onode_1[14]&onode_1[15];
assign	onode_2[15]=onode_1[15];
///////////////////////// layer 3 ////////////////////////////
wire	[15:0]onode_3;
assign	onode_3[0]=onode_2[0]&onode_2[2];
assign	onode_3[1]=onode_2[1]&onode_2[3];
assign	onode_3[2]=onode_2[2]&onode_2[4];
assign	onode_3[3]=onode_2[3]&onode_2[5];
assign	onode_3[4]=onode_2[4]&onode_2[6];
assign	onode_3[5]=onode_2[5]&onode_2[7];
assign	onode_3[6]=onode_2[6]&onode_2[8];
assign	onode_3[7]=onode_2[7]&onode_2[9];
assign	onode_3[8]=onode_2[8]&onode_2[10];
assign	onode_3[9]=onode_2[9]&onode_2[11];
assign	onode_3[10]=onode_2[10]&onode_2[12];
assign	onode_3[11]=onode_2[11]&onode_2[13];
assign	onode_3[12]=onode_2[12]&onode_2[14];
assign	onode_3[13]=onode_2[13]&onode_2[15];
assign	onode_3[14]=onode_2[14];
assign	onode_3[15]=onode_2[15];
///////////////////////// layer 4 ////////////////////////////
wire	[15:0]onode_4;
assign	onode_4[0]=onode_3[0]&onode_3[4];
assign	onode_4[1]=onode_3[1]&onode_3[5];
assign	onode_4[2]=onode_3[2]&onode_3[6];
assign	onode_4[3]=onode_3[3]&onode_3[7];
assign	onode_4[4]=onode_3[4]&onode_3[8];
assign	onode_4[5]=onode_3[5]&onode_3[9];
assign	onode_4[6]=onode_3[6]&onode_3[10];
assign	onode_4[7]=onode_3[7]&onode_3[11];
assign	onode_4[8]=onode_3[8]&onode_3[12];
assign	onode_4[9]=onode_3[9]&onode_3[13];
assign	onode_4[10]=onode_3[10]&onode_3[14];
assign	onode_4[11]=onode_3[11]&onode_3[15];
assign	onode_4[12]=onode_3[12];
assign	onode_4[13]=onode_3[13];
assign	onode_4[14]=onode_3[14];
assign	onode_4[15]=onode_3[15];
///////////////////////// layer 5 ////////////////////////////
wire	[15:0]onode_5;
assign	onode_5[0]=onode_4[0]&onode_4[8];
assign	onode_5[1]=onode_4[1]&onode_4[9];
assign	onode_5[2]=onode_4[2]&onode_4[10];
assign	onode_5[3]=onode_4[3]&onode_4[11];
assign	onode_5[4]=onode_4[4]&onode_4[12];
assign	onode_5[5]=onode_4[5]&onode_4[13];
assign	onode_5[6]=onode_4[6]&onode_4[14];
assign	onode_5[7]=onode_4[7]&onode_4[15];
assign	onode_5[8]=onode_4[8];
assign	onode_5[9]=onode_4[9];
assign	onode_5[10]=onode_4[10];
assign	onode_5[11]=onode_4[11];
assign	onode_5[12]=onode_4[12];
assign	onode_5[13]=onode_4[13];
assign	onode_5[14]=onode_4[14];
assign	onode_5[15]=onode_4[15];


// even nodes
wire	[14:0]enode;
assign	enode[14]=onode_5[15]&node_0[29];
assign	enode[13]=onode_5[14]&node_0[27];
assign	enode[12]=onode_5[13]&node_0[25];
assign	enode[11]=onode_5[12]&node_0[23];
assign	enode[10]=onode_5[11]&node_0[21];
assign	enode[9]=onode_5[10]&node_0[19];
assign	enode[8]=onode_5[9]&node_0[17];
assign	enode[7]=onode_5[8]&node_0[15];
assign	enode[6]=onode_5[7]&node_0[13];
assign	enode[5]=onode_5[6]&node_0[11];
assign	enode[4]=onode_5[5]&node_0[9];
assign	enode[3]=onode_5[4]&node_0[7];
assign	enode[2]=onode_5[3]&node_0[5];
assign	enode[1]=onode_5[2]&node_0[3];
assign	enode[0]=onode_5[1]&node_0[1];

// shift amount genration
wire	shift_1;
assign	shift_1=onode_5[15];
wire	[1:0]shift_2;
assign	shift_2[0]=onode_5[14];
assign	shift_2[1]=enode[14];
wire	[1:0]shift_3;
assign	shift_3[0]=onode_5[13];
assign	shift_3[1]=enode[13];
wire	[3:0]shift_4;
assign	shift_4[0]=onode_5[11];
assign	shift_4[1]=enode[11];
assign	shift_4[2]=onode_5[12];
assign	shift_4[3]=enode[12];
wire	[7:0]shift_5;
assign	shift_5[0]=onode_5[7];
assign	shift_5[1]=enode[7];
assign	shift_5[2]=onode_5[8];
assign	shift_5[3]=enode[8];
assign	shift_5[4]=onode_5[9];
assign	shift_5[5]=enode[9];
assign	shift_5[6]=onode_5[10];
assign	shift_5[7]=enode[10];
wire	[13:0]shift_6;
assign	shift_6[0]=onode_5[0];
assign	shift_6[1]=enode[0];
assign	shift_6[2]=onode_5[1];
assign	shift_6[3]=enode[1];
assign	shift_6[4]=onode_5[2];
assign	shift_6[5]=enode[2];
assign	shift_6[6]=onode_5[3];
assign	shift_6[7]=enode[3];
assign	shift_6[8]=onode_5[4];
assign	shift_6[9]=enode[4];
assign	shift_6[10]=onode_5[5];
assign	shift_6[11]=enode[5];
assign	shift_6[12]=onode_5[6];
assign	shift_6[13]=enode[6];

// shift tree

wire	[31:0]data_1,data_2,data_3,data_4,data_5;
shift_1b	shift_1b_0(
shift_1,
i_data,
data_1
);

shift_3b	shift_3b_0(
{shift_2,1'b0},
data_1,
data_2
);

shift_3b	shift_3b_1(
{shift_3,1'b0},
data_2,
data_3
);

shift_7b	shift_7b_0(
{shift_4,3'b0},
data_3,
o_data
);
/*
shift_7b	shift_7b_0(
{shift_4,3'b0},
data_3,
data_4
);

shift_15b	shift_15b_0(
{shift_5,7'b0},
data_4,
data_5
);

shift_15b	shift_15b_1(
{shift_6,1'b0},
data_5,
o_data
);
*/
// number of shifted bits determination
wire	[4:0]shifted_1,shifted_2,shifted_3,shifted_4,shifted_5;
assign	shifted_1=shift_1?1:0;
assign	shifted_2=	(shift_2==2'b11)?3:
			(shift_2==2'b10)?2:shifted_1;
assign	shifted_3=	(shift_3==2'b11)?5:
			(shift_3==2'b10)?4:shifted_2;

assign	o_shifted=	(shift_4==4'b1111)?9:
			(shift_4==4'b1110)?8:
			(shift_4==4'b1100)?7:
			(shift_4==4'b1000)?6:shifted_3;

/*
assign	shifted_4=	(shift_4==4'b1111)?9:
			(shift_4==4'b1110)?8:
			(shift_4==4'b1100)?7:
			(shift_4==4'b1000)?6:shifted_3;
assign	shifted_5=	(shift_5==8'b11111111)?17:
			(shift_5==8'b11111110)?16:
			(shift_5==8'b11111100)?15:
			(shift_5==8'b11111000)?14:
			(shift_5==8'b11110000)?13:
			(shift_5==8'b11100000)?12:
			(shift_5==8'b11000000)?11:
			(shift_5==8'b10000000)?10:shifted_4;
assign	o_shifted=	(shift_6==14'b11111111111111)?31:
			(shift_6==14'b11111111111110)?30:
			(shift_6==14'b11111111111100)?29:
			(shift_6==14'b11111111111000)?28:
			(shift_6==14'b11111111110000)?27:
			(shift_6==14'b11111111100000)?26:
			(shift_6==14'b11111111000000)?25:
			(shift_6==14'b11111110000000)?24:
			(shift_6==14'b11111100000000)?23:
			(shift_6==14'b11111000000000)?22:
			(shift_6==14'b11110000000000)?21:
			(shift_6==14'b11100000000000)?20:
			(shift_6==14'b11000000000000)?19:
			(shift_6==14'b10000000000000)?18:shifted_5;
*/


endmodule


`ifdef VERIFY
module	divider_tb();

reg	clk=0,rst=0;
always #1 clk=~clk;

initial #10 rst=1;

/// driver
reg	[31:0]dividend=0,divisor=0;
reg	start=0;
wire	ready;
reg	state_driver=0;
always@(posedge clk)
	if(rst)begin
		case(state_driver)
			0:begin
				start<=1;
				state_driver<=1;
				dividend<=$random;
				divisor<=$random;	
			end	
			1:if(ready)begin
				start<=0;
				state_driver<=0;
			end
		endcase
	end

///

/// monitor
wire	[31:0]quotient,remainder;
reg	state_m=0;

always@(posedge clk)
	if(rst)begin
		case(state_m)
			0:if(start)begin
				if(dividend[31])$write("%6d	dividend=-%d",$time,(~dividend)+1);
				else	$write("%6d	dividend=%d",$time,dividend);
				if(divisor[31])$write("	divisor=-%d\n",(~divisor)+1);
				else	$write("	divisor=%d\n",divisor);
				state_m<=1;
			end
			1:if(ready)begin
				state_m<=0;
				if(quotient[31])$write("%6d	quotient=-%d",$time,(~quotient)+1);
				else	$write("%6d	quotient=%d",$time,quotient);
				if(remainder[31])$write("	remainder=-%d\n",(~remainder)+1);
				else	$write("	remainder=%d\n",remainder);
			end
		endcase
	end
///


/// score board

// test vector record
integer	DD_FH,DR_FH,Q_FH,R_FH;
initial begin
	DD_FH=$fopen("dividend.txt");
	DR_FH=$fopen("divisor.txt");
	Q_FH=$fopen("quotient.txt");
	R_FH=$fopen("remainder.txt");
end
//
wire	sign_q,sign_r;
assign	sign_q=dividend[31]^divisor[31];
assign	sign_r=dividend[31];

reg	[62:0]PR=0;
wire	[31:0]DR;
assign	DR=divisor[31]?(~divisor)+1:divisor;

reg	[31:0]q_tb=0,r_tb=0;
integer	i;
wire [31:0] dividendn = (~ dividend) + 1;
always@* begin
	PR={ 31'd0, 
        (dividend[31] ? dividendn : dividend)
        };
	for(i=31;i>=0;i=i-1)begin
		if(PR[62:31]>=DR)begin
			PR[62:31]=PR[62:31]-DR;
			if(i!=0)PR=PR<<1;
			q_tb[i]=1;
		end
		else begin
			q_tb[i]=0;
			if(i!=0)PR=PR<<1;
		end
	end
	q_tb=sign_q?(~q_tb)+1:q_tb;
	r_tb=sign_r?(~PR[62:31])+1:PR[62:31];
	$fwrite(DD_FH,",0x%h",dividend);
	$fwrite(DR_FH,",0x%h",divisor);
	$fwrite(Q_FH,",0x%h",q_tb);
	$fwrite(R_FH,",0x%h",r_tb);
end
///

/// checker
always@(posedge clk)
	if(rst)begin
		if(ready)begin
			if(quotient==q_tb)$write("quotient match");
			else begin
				$write("quotient mismatch");
				if(q_tb[31])$write(" q_tb=-%d",(~q_tb)+1);
				else $write(" q_tb=%d",q_tb);
			end
			if(remainder==r_tb)$write("	remainder match\n");
			else begin
				$write("	remainder mismatch");
				if(r_tb[31])$write(" r_tb=-%d\n",(~r_tb)+1);
				else $write(" r_tb=%d\n",r_tb);
			end
		end
	end
///


///DUT
divider_dshift	divider_0(
    clk,
    rst,
    dividend,
    divisor,
    start,
    ready,
    quotient,
    remainder
);


///
endmodule
`endif