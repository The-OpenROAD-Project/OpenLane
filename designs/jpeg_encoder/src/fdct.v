/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Forward Discrete Cosine Transform and ZigZag unit          ////
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
//  $Id: fdct.v,v 1.3 2002/10/31 12:50:03 rherveille Exp $
//
//  $Date: 2002/10/31 12:50:03 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: fdct.v,v $
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

module fdct(clk, ena, rst, dstrb, din, dout, douten);

	//
	// parameters
	//

	////////////////////////////////////////////////////////////////////
	//                                                                //
	// ITU-T.81, ITU-T.83 & Coefficient resolution notes              //
	//                                                                //
	////////////////////////////////////////////////////////////////////
	//                                                                //
	// Worst case error (all input values -128) is                    //
	// zero (i.e. no errors) when using 15bit coefficients            //
	//                                                                //
	// Using less bits for the coefficients produces a biterror       //
	// approx. equal to (15 - used_coefficient-bits).                 //
	// i.e. 14bit coefficients, errors in dout-bit[0] only            //
	//      13bit coefficients, errors in dout-bits[1:0]              //
	//      12bit coefficients, errors in dout-bits[2:0] etc.         //
	// Tests with real non-continous tone image data have shown that  //
	// even when using 13bit coefficients errors remain in the lsb    //
	// only (i.e. dout-bit[0]                                         //
	//                                                                //
	// The amount of coefficient-bits needed is dependent on the      //
	// desired quality.                                               //
	// The JPEG-standard compliance specs.(ITU-T.83) prescribe        //
	// that the output of the combined DCT AND Quantization unit      //
	// shall not exceed 1 for the desired quality.                    //
	//                                                                //
	// This means for high quantization levels, lesser bits           //
	// for the DCT unit can be used.                                  //
	//                                                                //
	// Looking at the recommended "quantization tables for generic    //
	// compliance testing of DCT-based processes" (ITU-T.83 annex B)  //
	// it can be noticed that relatively large quantization values    //
	// are being used. Errors in the lower-order bits should          //
	// therefore not be visible.                                      //
	// For certain applications some of the lower-order bits could    //
	// actually be discarded. When looking at the luminance and       //
	// chrominance example quantization tables (ITU-T.81 annex K)     //
	// it can be seen that the smallest quantization value is ten     //
	// (qnt_val_min = 10). This means that the lowest 2bits can be    //
	// discarded (set to zero '0') without having any effect on the   //
	// final result. In this example 11 bit or 12 bit coefficients    //
	// would be sufficient.                                           //
	//                                                                //
	////////////////////////////////////////////////////////////////////

	parameter coef_width = 11;
	parameter di_width = 8;
	parameter do_width = 12;

	//
	// inputs & outputs
	//
	input clk;                    // system clock
	input ena;                    // clock enable
	input rst;                    // active low asynchronous reset

	input dstrb;                  // data-strobe. Present dstrb 1clk-cycle before data block
	input  [di_width-1:0] din;
	output [do_width-1:0] dout;
	output                douten; // data-out enable

	//
	// variables
	//

	wire doe;

	wire [do_width -1:0]  // results from DCT module
		res00, res01, res02, res03, res04, res05, res06, res07,
		res10, res11, res12, res13, res14, res15, res16, res17,
		res20, res21, res22, res23, res24, res25, res26, res27,
		res30, res31, res32, res33, res34, res35, res36, res37, 
		res40, res41, res42, res43, res44, res45, res46, res47,
		res50, res51, res52, res53, res54, res55, res56, res57, 
		res60, res61, res62, res63, res64, res65, res66, res67,
		res70, res71, res72, res73, res74, res75, res76, res77;


	//
	// module body
	//

	// Hookup DCT module
	dct #(coef_width, di_width, do_width)
	dct_mod(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.dout_00(res00),
		.dout_01(res01),
		.dout_02(res02),
		.dout_03(res03),
		.dout_04(res04),
		.dout_05(res05),
		.dout_06(res06),
		.dout_07(res07),
		.dout_10(res10),
		.dout_11(res11),
		.dout_12(res12),
		.dout_13(res13),
		.dout_14(res14),
		.dout_15(res15),
		.dout_16(res16),
		.dout_17(res17),
		.dout_20(res20),
		.dout_21(res21),
		.dout_22(res22),
		.dout_23(res23),
		.dout_24(res24),
		.dout_25(res25),
		.dout_26(res26),
		.dout_27(res27),
		.dout_30(res30),
		.dout_31(res31),
		.dout_32(res32),
		.dout_33(res33),
		.dout_34(res34),
		.dout_35(res35),
		.dout_36(res36),
		.dout_37(res37),
		.dout_40(res40),
		.dout_41(res41),
		.dout_42(res42),
		.dout_43(res43),
		.dout_44(res44),
		.dout_45(res45),
		.dout_46(res46),
		.dout_47(res47),
		.dout_50(res50),
		.dout_51(res51),
		.dout_52(res52),
		.dout_53(res53),
		.dout_54(res54),
		.dout_55(res55),
		.dout_56(res56),
		.dout_57(res57),
		.dout_60(res60),
		.dout_61(res61),
		.dout_62(res62),
		.dout_63(res63),
		.dout_64(res64),
		.dout_65(res65),
		.dout_66(res66),
		.dout_67(res67),
		.dout_70(res70),
		.dout_71(res71),
		.dout_72(res72),
		.dout_73(res73),
		.dout_74(res74),
		.dout_75(res75),
		.dout_76(res76),
		.dout_77(res77),
		.douten(doe)
	);

	// Hookup ZigZag unit
	zigzag zigzag_mod(
		.clk(clk), 
		.ena(ena),
		.dstrb(doe),
		.din_00(res00),
		.din_01(res01),
		.din_02(res02),
		.din_03(res03),
		.din_04(res04),
		.din_05(res05),
		.din_06(res06),
		.din_07(res07),
		.din_10(res10),
		.din_11(res11),
		.din_12(res12),
		.din_13(res13),
		.din_14(res14),
		.din_15(res15),
		.din_16(res16),
		.din_17(res17),
		.din_20(res20),
		.din_21(res21),
		.din_22(res22),
		.din_23(res23),
		.din_24(res24),
		.din_25(res25),
		.din_26(res26),
		.din_27(res27),
		.din_30(res30),
		.din_31(res31),
		.din_32(res32),
		.din_33(res33),
		.din_34(res34),
		.din_35(res35),
		.din_36(res36),
		.din_37(res37),
		.din_40(res40),
		.din_41(res41),
		.din_42(res42),
		.din_43(res43),
		.din_44(res44),
		.din_45(res45),
		.din_46(res46),
		.din_47(res47),
		.din_50(res50),
		.din_51(res51),
		.din_52(res52),
		.din_53(res53),
		.din_54(res54),
		.din_55(res55),
		.din_56(res56),
		.din_57(res57),
		.din_60(res60),
		.din_61(res61),
		.din_62(res62),
		.din_63(res63),
		.din_64(res64),
		.din_65(res65),
		.din_66(res66),
		.din_67(res67),
		.din_70(res70),
		.din_71(res71),
		.din_72(res72),
		.din_73(res73),
		.din_74(res74),
		.din_75(res75),
		.din_76(res76),
		.din_77(res77),
		.dout(dout),
		.douten(douten)
	);
endmodule
