/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform, Parallel implementation         ////
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
//  $Id: dct.v,v 1.3 2002/10/31 12:50:03 rherveille Exp $
//
//  $Date: 2002/10/31 12:50:03 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: dct.v,v $
//               Revision 1.3  2002/10/31 12:50:03  rherveille
//               *** empty log message ***
//
//               Revision 1.2  2002/10/23 09:06:59  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module dct(
	clk,
	ena,
	rst,
	dstrb,
	din,
	dout_00, dout_01, dout_02, dout_03, dout_04, dout_05, dout_06, dout_07,
	dout_10, dout_11, dout_12, dout_13, dout_14, dout_15, dout_16, dout_17,
	dout_20, dout_21, dout_22, dout_23, dout_24, dout_25, dout_26, dout_27,
	dout_30, dout_31, dout_32, dout_33, dout_34, dout_35, dout_36, dout_37,
	dout_40, dout_41, dout_42, dout_43, dout_44, dout_45, dout_46, dout_47,
	dout_50, dout_51, dout_52, dout_53, dout_54, dout_55, dout_56, dout_57,
	dout_60, dout_61, dout_62, dout_63, dout_64, dout_65, dout_66, dout_67,
	dout_70, dout_71, dout_72, dout_73, dout_74, dout_75, dout_76, dout_77,
	douten
);

	//
	// parameters
	//
	// Worst case errors (Din = 64* -128) remain in decimal bit
	// when using 13bit coefficients
	//
	// For ultra-high
	parameter coef_width = 11;
	parameter di_width = 8;
	parameter do_width = 12;

	//
	// inputs & outputs
	//

	input clk;
	input ena;
	input rst;   // active low asynchronous reset

	input dstrb; // data-strobe. Present dstrb 1clk-cycle before data block
	input  [di_width:1] din;
	output [do_width:1]
		dout_00, dout_01, dout_02, dout_03, dout_04, dout_05, dout_06, dout_07,
		dout_10, dout_11, dout_12, dout_13, dout_14, dout_15, dout_16, dout_17,
		dout_20, dout_21, dout_22, dout_23, dout_24, dout_25, dout_26, dout_27,
		dout_30, dout_31, dout_32, dout_33, dout_34, dout_35, dout_36, dout_37,
		dout_40, dout_41, dout_42, dout_43, dout_44, dout_45, dout_46, dout_47,
		dout_50, dout_51, dout_52, dout_53, dout_54, dout_55, dout_56, dout_57,
		dout_60, dout_61, dout_62, dout_63, dout_64, dout_65, dout_66, dout_67,
		dout_70, dout_71, dout_72, dout_73, dout_74, dout_75, dout_76, dout_77;

	output douten; // data-out enable
	reg douten;

	//
	// variables
	//
	reg go, dgo, ddgo, ddcnt, dddcnt;
	reg [di_width:1] ddin;

	//
	// module body
	//

	// generate sample counter
	reg  [5:0] sample_cnt;
	wire       dcnt     = &sample_cnt;

	always @(posedge clk or negedge rst)
	  if (~rst)
	     sample_cnt <= #1 6'h0;
	  else if (ena)
	    if(dstrb)
	      sample_cnt <= #1 6'h0;
	    else if(~dcnt)
	      sample_cnt <= #1 sample_cnt + 6'h1;

	// internal signals
	always @(posedge clk or negedge rst)
	  if (~rst)
	  begin
	      go     <= #1 1'b0;
		  dgo    <= #1 1'b0;
		  ddgo   <= #1 1'b0;
		  ddin   <= #1 0;

	      douten <= #1 1'b0;
	      ddcnt  <= #1 1'b1;
	      dddcnt <= #1 1'b1;
	  end
	  else if (ena)
	  begin
	      go     <= #1 dstrb;
	      dgo    <= #1 go;
	      ddgo   <= #1 dgo;
	      ddin   <= #1 din;

	      ddcnt  <= #1 dcnt;
	      dddcnt <= #1 ddcnt;

	      douten <= #1 ddcnt & ~dddcnt;
	  end

	// Hookup DCT units

	// V = 0
	dctub #(coef_width, di_width, 3'h0)
	dct_block_0 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_00), // (U,V) = (0,0)
		.dout1(dout_01), // (U,V) = (0,1)
		.dout2(dout_02), // (U,V) = (0,2)
		.dout3(dout_03), // (U,V) = (0,3)
		.dout4(dout_04), // (U,V) = (0,4)
		.dout5(dout_05), // (U,V) = (0,5)
		.dout6(dout_06), // (U,V) = (0,6)
		.dout7(dout_07)  // (U,V) = (0,7)
	);

	// V = 1
	dctub #(coef_width, di_width, 3'h1)
	dct_block_1 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_10), // (U,V) = (1,0)
		.dout1(dout_11), // (U,V) = (1,1)
		.dout2(dout_12), // (U,V) = (1,2)
		.dout3(dout_13), // (U,V) = (1,3)
		.dout4(dout_14), // (U,V) = (1,4)
		.dout5(dout_15), // (U,V) = (1,5)
		.dout6(dout_16), // (U,V) = (1,6)
		.dout7(dout_17)  // (U,V) = (1,7)
	);

	// V = 2
	dctub #(coef_width, di_width, 3'h2)
	dct_block_2 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_20), // (U,V) = (2,0)
		.dout1(dout_21), // (U,V) = (2,1)
		.dout2(dout_22), // (U,V) = (2,2)
		.dout3(dout_23), // (U,V) = (2,3)
		.dout4(dout_24), // (U,V) = (2,4)
		.dout5(dout_25), // (U,V) = (2,5)
		.dout6(dout_26), // (U,V) = (2,6)
		.dout7(dout_27)  // (U,V) = (2,7)
	);

	// V = 3
	dctub #(coef_width, di_width, 3'h3)
	dct_block_3 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_30), // (U,V) = (3,0)
		.dout1(dout_31), // (U,V) = (3,1)
		.dout2(dout_32), // (U,V) = (3,2)
		.dout3(dout_33), // (U,V) = (3,3)
		.dout4(dout_34), // (U,V) = (3,4)
		.dout5(dout_35), // (U,V) = (3,5)
		.dout6(dout_36), // (U,V) = (3,6)
		.dout7(dout_37)  // (U,V) = (3,7)
	);

	// V = 4
	dctub #(coef_width, di_width, 3'h4)
	dct_block_4 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_40), // (U,V) = (4,0)
		.dout1(dout_41), // (U,V) = (4,1)
		.dout2(dout_42), // (U,V) = (4,2)
		.dout3(dout_43), // (U,V) = (4,3)
		.dout4(dout_44), // (U,V) = (4,4)
		.dout5(dout_45), // (U,V) = (4,5)
		.dout6(dout_46), // (U,V) = (4,6)
		.dout7(dout_47)  // (U,V) = (4,7)
	);

	// V = 5
	dctub #(coef_width, di_width, 3'h5)
	dct_block_5 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_50), // (U,V) = (5,0)
		.dout1(dout_51), // (U,V) = (5,1)
		.dout2(dout_52), // (U,V) = (5,2)
		.dout3(dout_53), // (U,V) = (5,3)
		.dout4(dout_54), // (U,V) = (5,4)
		.dout5(dout_55), // (U,V) = (5,5)
		.dout6(dout_56), // (U,V) = (5,6)
		.dout7(dout_57)  // (U,V) = (5,7)
	);

	// V = 6
	dctub #(coef_width, di_width, 3'h6)
	dct_block_6 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_60), // (U,V) = (6,0)
		.dout1(dout_61), // (U,V) = (6,1)
		.dout2(dout_62), // (U,V) = (6,2)
		.dout3(dout_63), // (U,V) = (6,3)
		.dout4(dout_64), // (U,V) = (6,4)
		.dout5(dout_65), // (U,V) = (6,5)
		.dout6(dout_66), // (U,V) = (6,6)
		.dout7(dout_67)  // (U,V) = (6,7)
	);

	// V = 7
	dctub #(coef_width, di_width, 3'h7)
	dct_block_7 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(sample_cnt[2:0]),
		.y(sample_cnt[5:3]),
		.ddin(ddin),
		.dout0(dout_70), // (U,V) = (7,0)
		.dout1(dout_71), // (U,V) = (7,1)
		.dout2(dout_72), // (U,V) = (7,2)
		.dout3(dout_73), // (U,V) = (7,3)
		.dout4(dout_74), // (U,V) = (7,4)
		.dout5(dout_75), // (U,V) = (7,5)
		.dout6(dout_76), // (U,V) = (7,6)
		.dout7(dout_77)  // (U,V) = (7,7)
	);
endmodule
