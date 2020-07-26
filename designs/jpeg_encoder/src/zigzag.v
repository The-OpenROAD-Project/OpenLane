/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Zig-Zag Unit                                               ////
////  Performs zigzag-ing, as used by many DCT based encoders    ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
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
//  $Id: zigzag.v,v 1.2 2002/10/23 09:06:59 rherveille Exp $
//
//  $Date: 2002/10/23 09:06:59 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: zigzag.v,v $
//               Revision 1.2  2002/10/23 09:06:59  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//


// synopsys translate_off
//`include "timescale.v"
// synopsys translate_on

module zigzag(
	clk, 
	ena, 
	dstrb, 
	din_00, din_01, din_02, din_03, din_04, din_05, din_06, din_07,
	din_10, din_11, din_12, din_13, din_14, din_15, din_16, din_17,
	din_20, din_21, din_22, din_23, din_24, din_25, din_26, din_27,
	din_30, din_31, din_32, din_33, din_34, din_35, din_36, din_37,
	din_40, din_41, din_42, din_43, din_44, din_45, din_46, din_47,
	din_50, din_51, din_52, din_53, din_54, din_55, din_56, din_57,
	din_60, din_61, din_62, din_63, din_64, din_65, din_66, din_67,
	din_70, din_71, din_72, din_73, din_74, din_75, din_76, din_77,
	dout,
	douten
);

	//
	// inputs & outputs
	//

	input clk;                    // system clock
	input ena;                    // clock enable

	input dstrb;                  // data-strobe. Present dstrb 1clk-cycle before data block
	input [11:0]
		din_00, din_01, din_02, din_03, din_04, din_05, din_06, din_07,
		din_10, din_11, din_12, din_13, din_14, din_15, din_16, din_17,
		din_20, din_21, din_22, din_23, din_24, din_25, din_26, din_27,
		din_30, din_31, din_32, din_33, din_34, din_35, din_36, din_37,
		din_40, din_41, din_42, din_43, din_44, din_45, din_46, din_47,
		din_50, din_51, din_52, din_53, din_54, din_55, din_56, din_57,
		din_60, din_61, din_62, din_63, din_64, din_65, din_66, din_67,
		din_70, din_71, din_72, din_73, din_74, din_75, din_76, din_77;
	output [11:0] dout;
	output        douten; // data-out enable

	//
	// variables
	//

	reg ld_zigzag;
	reg [11:0] sresult [63:0]; // store results for zig-zagging

	//
	// module body
	//

	always @(posedge clk)
	  if(ena)
	    ld_zigzag <= #1 dstrb;

	assign douten = ld_zigzag;


	//
	// Generate zig-zag structure
	//
	// This implicates that the quantization step be performed after
	// the zig-zagging.
	//
	//    0: 1: 2: 3: 4: 5: 6: 7:		0: 1: 2: 3: 4: 5: 6: 7:
	// 0: 63 62 58 57 49 48 36 35		3f 3e 3a 39 31 30 24 23
	// 1: 61 59 56 50 47 37 34 21		3d 3b 38 32 2f 25 22 15
	// 2: 60 55 51 46 38 33 22 20		3c 37 33 2e 26 21 16 14
	// 3: 54 52 45 39 32 23 19 10		36 34 2d 27 20 17 13 0a
	// 4: 53 44 40 31 24 18 11 09		35 2c 28 1f 18 12 0b 09
	// 5: 43 41 30 25 17 12 08 03		2b 29 1e 19 11 0c 08 03
	// 6: 42 29 26 16 13 07 04 02		2a 1d 1a 10 0d 07 04 02
	// 7: 28 27 15 14 06 05 01 00		1c 1b 0f 0e 06 05 01 00
	//
	// zig-zag the DCT results
	integer n;

	always @(posedge clk)
	  if(ena)
	    if(ld_zigzag)   // reload results-register file
	    begin
	        sresult[63] <= #1 din_00;
	        sresult[62] <= #1 din_01;
	        sresult[61] <= #1 din_10;
	        sresult[60] <= #1 din_20;
	        sresult[59] <= #1 din_11;
	        sresult[58] <= #1 din_02;
	        sresult[57] <= #1 din_03;
	        sresult[56] <= #1 din_12;
	        sresult[55] <= #1 din_21;
	        sresult[54] <= #1 din_30;
	        sresult[53] <= #1 din_40;
	        sresult[52] <= #1 din_31;
	        sresult[51] <= #1 din_22;
	        sresult[50] <= #1 din_13;
	        sresult[49] <= #1 din_04;
	        sresult[48] <= #1 din_05;
	        sresult[47] <= #1 din_14;
	        sresult[46] <= #1 din_23;
	        sresult[45] <= #1 din_32;
	        sresult[44] <= #1 din_41;
	        sresult[43] <= #1 din_50;
	        sresult[42] <= #1 din_60;
	        sresult[41] <= #1 din_51;
	        sresult[40] <= #1 din_42;
	        sresult[39] <= #1 din_33;
	        sresult[38] <= #1 din_24;
	        sresult[37] <= #1 din_15;
	        sresult[36] <= #1 din_06;
	        sresult[35] <= #1 din_07;
	        sresult[34] <= #1 din_16;
	        sresult[33] <= #1 din_25;
	        sresult[32] <= #1 din_34;
	        sresult[31] <= #1 din_43;
	        sresult[30] <= #1 din_52;
	        sresult[29] <= #1 din_61;
	        sresult[28] <= #1 din_70;
	        sresult[27] <= #1 din_71;
	        sresult[26] <= #1 din_62;
	        sresult[25] <= #1 din_53;
	        sresult[24] <= #1 din_44;
	        sresult[23] <= #1 din_35;
	        sresult[22] <= #1 din_26;
	        sresult[21] <= #1 din_17;
	        sresult[20] <= #1 din_27;
	        sresult[19] <= #1 din_36;
	        sresult[18] <= #1 din_45;
	        sresult[17] <= #1 din_54;
	        sresult[16] <= #1 din_63;
	        sresult[15] <= #1 din_72;
	        sresult[14] <= #1 din_73;
	        sresult[13] <= #1 din_64;
	        sresult[12] <= #1 din_55;
	        sresult[11] <= #1 din_46;
	        sresult[10] <= #1 din_37;
	        sresult[09] <= #1 din_47;
	        sresult[08] <= #1 din_56;
	        sresult[07] <= #1 din_65;
	        sresult[06] <= #1 din_74;
	        sresult[05] <= #1 din_75;
	        sresult[04] <= #1 din_66;
	        sresult[03] <= #1 din_57;
	        sresult[02] <= #1 din_67;
	        sresult[01] <= #1 din_76;
	        sresult[00] <= #1 din_77;
	    end
	  else       // shift results out
	    for (n=1; n<=63; n=n+1) // do not change sresult[0]
	       sresult[n] <= #1 sresult[n -1];

	assign dout = sresult[63];
endmodule
