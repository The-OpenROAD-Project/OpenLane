/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Encoder Unit                                          ////
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
//  $Id: jpeg_encoder.v,v 1.3 2002/10/31 12:51:44 rherveille Exp $
//
//  $Date: 2002/10/31 12:51:44 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: jpeg_encoder.v,v $
//               Revision 1.3  2002/10/31 12:51:44  rherveille
//               *** empty log message ***
//
//               Revision 1.2  2002/10/23 18:58:51  rherveille
//               Fixed a bug in the zero-run (run-length-coder)
//
//               Revision 1.1  2002/10/23 09:07:01  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module jpeg_encoder(
	clk,
	ena,
	dstrb,
	din,
	qnt_val,
	qnt_cnt,
	size,
	rlen,
	amp,
	douten,
        SE,
        SI,
        SO
);

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
	// Tests with real continuous and non-continous tone image data   //
	// have shown that when using the examples quantization tables    //
	// from ITU-T.81 annex K 10bit coefficients are sufficient to     //
	// comply to the ITU-T.83 specs. Compliance tests have been met   //
	// using as little as 9bit coefficients.                          //
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
	parameter di_width = 8; // no function yet

	//
	// inputs & outputs
	//
input SE;
input SI;
output SO;

	input clk;                      // system clock
	input ena;                      // clock enable

	input dstrb;                    // data-strobe. Present dstrb 1clk-cycle before data block
	input [di_width-1:0] din;
	input [7:0]          qnt_val;   // quantization value

	output [ 5:0] qnt_cnt;          // quantization value address
	
	output [ 3:0] size;    // size
	output [ 3:0] rlen;    // run-length
	output [11:0] amp;     // amplitude
	output        douten;  // data output enable


	//
	// variables
	//


	wire rst = 1'b1;                      // active low asynchronous reset
	wire fdct_doe, qnr_doe;
	wire [11:0] fdct_dout;
	reg  [11:0] dfdct_dout;
	wire [10:0] qnr_dout;
	reg         dqnr_doe;


	//
	// module body
	//

	// Hookup FDCT & ZigZag module
	fdct #(coef_width, di_width, 12)
	fdct_zigzag(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.dout(fdct_dout),
		.douten(fdct_doe)
	);

	// delay 'fdct_dout' => wait for synchronous quantization RAM/ROM
	always @(posedge clk)
	  if(ena)
	    dfdct_dout <= #1 fdct_dout;

	// Hookup QNR (Quantization and Rounding) unit
	jpeg_qnr
	qnr(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(fdct_doe),
		.din(dfdct_dout),
		.qnt_val(qnt_val),
		.qnt_cnt(qnt_cnt),
		.dout(qnr_dout),
		.douten(qnr_doe)
	);

	// delay douten 1 clk_cycle => account for delayed fdct_res & qnt_val
	always @(posedge clk)
	  if(ena)
	    dqnr_doe <= #1 qnr_doe;

	//
	// TODO: Insert DC differential generator here.
	//
	wire [11:0] dc_diff_dout = {qnr_dout[10], qnr_dout};
	wire        dc_diff_doe = dqnr_doe;

	// Hookup Run Length Encoder
	jpeg_rle
	rle(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(dc_diff_doe),
		.din(dc_diff_dout),
		.size(size),
		.rlen(rlen),
		.amp(amp),
		.douten(douten),
		.bstart()
	);
endmodule
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
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform, DCT unit block                  ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: dctub.v,v 1.3 2002/10/31 12:50:03 rherveille Exp $
//
//  $Date: 2002/10/31 12:50:03 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: dctub.v,v $
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

module dctub(clk, ena, ddgo, x, y, ddin,
		dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7);

	parameter coef_width = 16;
	parameter di_width = 8;
	parameter [2:0] v = 3'h0;

	//
	// inputs & outputs
	//
	input clk;
	input ena;
	input ddgo;               // double delayed go strobe
	input [2:0] x, y;

	input  [di_width:1] ddin; // delayed data input
	output [11:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7;

	//
	// module body
	//

	// Hookup DCT units
	dctu #(coef_width, di_width, v, 3'h0)
	dct_unit_0 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout0)
	);

	dctu #(coef_width, di_width, v, 3'h1)
	dct_unit_1 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout1)
	);

	dctu #(coef_width, di_width, v, 3'h2)
	dct_unit_2 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout2)
	);

	dctu #(coef_width, di_width, v, 3'h3)
	dct_unit_3 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout3)
	);

	dctu #(coef_width, di_width, v, 3'h4)
	dct_unit_4 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout4)
	);

	dctu #(coef_width, di_width, v, 3'h5)
	dct_unit_5 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout5)
	);

	dctu #(coef_width, di_width, v, 3'h6)
	dct_unit_6 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout6)
	);

	dctu #(coef_width, di_width, v, 3'h7)
	dct_unit_7 (
		.clk(clk),
		.ena(ena),
		.ddgo(ddgo),
		.x(x),
		.y(y),
		.ddin(ddin),
		.dout(dout7)
	);
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Quantization & Rounding Core                          ////
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
//  $Id: jpeg_qnr.v,v 1.3 2002/10/31 12:52:55 rherveille Exp $
//
//  $Date: 2002/10/31 12:52:55 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: jpeg_qnr.v,v $
//               Revision 1.3  2002/10/31 12:52:55  rherveille
//               *** empty log message ***
//
//               Revision 1.2  2002/10/23 09:07:03  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module jpeg_qnr(clk, ena, rst, dstrb, din, qnt_val, qnt_cnt, dout, douten);

	//
	// parameters
	//
	parameter d_width = 12;
	parameter z_width = 2 * d_width;

	//
	// inputs & outputs
	//
	input clk;                    // system clock
	input ena;                    // clock enable
	input rst;                    // asynchronous active low reset

	input                dstrb;   // present dstrb 1clk cycle before din
	input  [d_width-1:0] din;     // data input
	input  [ 7:0]        qnt_val; // quantization value

	output [ 5:0]        qnt_cnt; // sample number (get quantization value qnt_cnt)
	output [10:0]        dout;    // data output
	output               douten;

	//
	// variables
	//
	wire [z_width-1:0] iz; // intermediate divident value
	wire [d_width-1:0] id; // intermediate dividor value
	wire [d_width  :0] iq; // intermediate result divider
	reg  [d_width  :0] rq; // rounded q-value
	reg  [d_width+3:0] dep;// data enable pipeline

	// generate sample counter
	reg  [5:0] qnt_cnt;
	wire       dcnt     = &qnt_cnt;

	always @(posedge clk or negedge rst)
	  if (~rst)
	     qnt_cnt <= #1 6'h0;
	  else if (dstrb)
	     qnt_cnt <= #1 6'h0;
	  else if (ena)
	     qnt_cnt <= #1 qnt_cnt + 6'h1;

	// generate intermediate dividor/divident values
	assign id = { {(d_width - 8){1'b0}}, qnt_val};
	assign iz = { {(z_width - d_width){din[d_width-1]}}, din};

	// hookup division unit
	div_su #(z_width)
	divider (
		.clk(clk),
		.ena(ena),
		.z(iz),
		.d(id),
		.q(iq),
		.s(),
		.div0(),
		.ovf()
	);

	// round result to the nearest integer
	always @(posedge clk)
	  if (ena)
	    if (iq[0])
	      if (iq[d_width])
	         rq <= #1 iq - 1'h1;
	      else
	         rq <= #1 iq + 1'h1;
	    else
	       rq <= #1 iq;

	// assign dout signal
	assign dout = rq[d_width -1: d_width-11];


	// generate data-out enable signal
	// This is a pipeline, data is not dependant on sample-count
	integer n;
	always @(posedge clk or negedge rst)
	  if (!rst)
	     dep <= #1 0;
	  else if(ena)
	     begin
	         dep[0] <= #1 dstrb;

	         for (n=1; n <= d_width +3; n = n +1)
	             dep[n] <= #1 dep[n-1];
	     end

	assign douten = dep[d_width +3];
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Run-Length encoder                                    ////
////                                                             ////
////  1) Retreive zig-zag-ed samples (starting with DC coeff.)   ////
////  2) Translate DC-coeff. into 11bit-size and amplitude       ////
////  3) Translate AC-coeff. into zero-runs, size and amplitude  ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: jpeg_rle.v,v 1.4 2002/10/31 12:53:39 rherveille Exp $
//
//  $Date: 2002/10/31 12:53:39 $
//  $Revision: 1.4 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: jpeg_rle.v,v $
//               Revision 1.4  2002/10/31 12:53:39  rherveille
//               *** empty log message ***
//
//               Revision 1.3  2002/10/23 18:58:54  rherveille
//               Fixed a bug in the zero-run (run-length-coder)
//
//               Revision 1.2  2002/10/23 09:07:04  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module jpeg_rle(clk, rst, ena, dstrb, din, size, rlen, amp, douten, bstart);

	//
	// parameters
	//

	//
	// inputs & outputs
	//
	input         clk;     // system clock
	input         rst;     // asynchronous reset
	input         ena;     // clock enable
	input         dstrb;
	input  [11:0] din;     // data input

	output [ 3:0] size;    // size
	output [ 3:0] rlen;    // run-length
	output [11:0] amp;     // amplitude
	output        douten;  // data output enable
	output        bstart;  // block start

	//
	// variables
	//

	wire [ 3:0] rle_rlen, rz1_rlen, rz2_rlen, rz3_rlen, rz4_rlen;
	wire [ 3:0] rle_size, rz1_size, rz2_size, rz3_size, rz4_size;
	wire [11:0] rle_amp,  rz1_amp,  rz2_amp,  rz3_amp,  rz4_amp;
	wire        rle_den,  rz1_den,  rz2_den,  rz3_den,  rz4_den;
	wire        rle_dc,   rz1_dc,   rz2_dc,   rz3_dc,   rz4_dc;

	//
	// module body
	//

	reg ddstrb;
	always @(posedge clk)
	  ddstrb <= #1 dstrb;

	// generate run-length encoded signals
	jpeg_rle1 rle(
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.go(ddstrb),
		.din(din),
		.rlen(rle_rlen),
		.size(rle_size),
		.amp(rle_amp),
		.den(rle_den),
		.dcterm(rle_dc)
	);

	// Find (15,0) (0,0) sequences and replace by (0,0)
	// There can be max. 4 (15,0) sequences in a row

	// step1
	jpeg_rzs rz1(
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.rleni(rle_rlen),
		.sizei(rle_size),
		.ampi(rle_amp),
		.deni(rle_den),
		.dci(rle_dc),
		.rleno(rz1_rlen),
		.sizeo(rz1_size),
		.ampo(rz1_amp),
		.deno(rz1_den),
		.dco(rz1_dc)
	);

	// step2
	jpeg_rzs rz2(
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.rleni(rz1_rlen),
		.sizei(rz1_size),
		.ampi(rz1_amp),
		.deni(rz1_den),
		.dci(rz1_dc),
		.rleno(rz2_rlen),
		.sizeo(rz2_size),
		.ampo(rz2_amp),
		.deno(rz2_den),
		.dco(rz2_dc)
	);

	// step3
	jpeg_rzs rz3(
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.rleni(rz2_rlen),
		.sizei(rz2_size),
		.ampi(rz2_amp),
		.deni(rz2_den),
		.dci(rz2_dc),
		.rleno(rz3_rlen),
		.sizeo(rz3_size),
		.ampo(rz3_amp),
		.deno(rz3_den),
		.dco(rz3_dc)
	);

	// step4
	jpeg_rzs rz4(
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.rleni(rz3_rlen),
		.sizei(rz3_size),
		.ampi(rz3_amp),
		.deni(rz3_den),
		.dci(rz3_dc),
		.rleno(rz4_rlen),
		.sizeo(rz4_size),
		.ampo(rz4_amp),
		.deno(rz4_den),
		.dco(rz4_dc)
	);


	// assign outputs
	assign rlen   = rz4_rlen;
	assign size   = rz4_size;
	assign amp    = rz4_amp;
	assign douten = rz4_den;
	assign bstart = rz4_dc;
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform Unit                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: dctu.v,v 1.3 2002/10/31 12:50:03 rherveille Exp $
//
//  $Date: 2002/10/31 12:50:03 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: dctu.v,v $
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

module dctu(clk, ena, ddgo, x, y, ddin, dout);

	parameter coef_width = 16;
	parameter di_width = 8;
	parameter [2:0] v = 0;
	parameter [2:0] u = 0;

	//
	// inputs & outputs
	//

	input clk;
	input ena;
	input ddgo;               // double delayed go signal
	input [2:0] x, y;

	input  [di_width:1] ddin; // delayed data input
	output [11:0] dout;

	//
	// variables
	//
	reg [      31:0] coef;

	wire [coef_width +10:0] result;
        `include "dct_cos_table.v"
	//
	// module body
	//

	// hookup cosine-table
	always @(posedge clk)
	  if(ena)
	    coef <= #1 dct_cos_table(x, y, u, v);

	// hookup dct-mac unit
	dct_mac #(8, coef_width)
	macu (
		.clk(clk),
		.ena(ena),
		.dclr(ddgo),
		.din(ddin),
		.coef( coef[31:31 -coef_width +1] ),
		.result(result)
	);

	assign dout = result[coef_width +10: coef_width -1];
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Run-Length Encoder, remove zero sequences             ////
////                                                             ////
////  - Detect (15,0) (0,0) seqence                              ////
////  - Replace them by (0,0)                                    ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: jpeg_rzs.v,v 1.4 2002/10/31 12:53:39 rherveille Exp $
//
//  $Date: 2002/10/31 12:53:39 $
//  $Revision: 1.4 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: jpeg_rzs.v,v $
//               Revision 1.4  2002/10/31 12:53:39  rherveille
//               *** empty log message ***
//
//               Revision 1.3  2002/10/23 18:58:54  rherveille
//               Fixed a bug in the zero-run (run-length-coder)
//
//               Revision 1.2  2002/10/23 09:07:04  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module jpeg_rzs(clk, ena, rst, deni, dci, rleni, sizei, ampi, deno, dco, rleno, sizeo, ampo);

	//
	// inputs & outputs
	//
	input        clk;
	input        ena;
	input        rst;
	input        deni;
	input        dci;
	input [ 3:0] sizei;
	input [ 3:0] rleni;
	input [11:0] ampi;

	output        deno;
	output        dco;
	output [ 3:0] sizeo;
	output [ 3:0] rleno;
	output [11:0] ampo;

	reg        deno, dco;
	reg [ 3:0] sizeo, rleno;
	reg [11:0] ampo;

	//
	// variables
	//

	reg [ 3:0] size;
	reg [ 3:0] rlen;
	reg [11:0] amp;
	reg        den;
	reg        dc;

	wire eob;
	wire zerobl;
	reg  state;

	//
	// module body
	//

	always @(posedge clk)
	  if(ena & deni)
	    begin
	        size <= #1 sizei;
	        rlen <= #1 rleni;
	        amp  <= #1 ampi;
	    end

	always @(posedge clk)
	  if(ena)
	    begin
	        sizeo <= #1 size;
	        rleno <= #1 rlen;
	        ampo  <= #1 amp;

	        dc    <= #1 dci;
	        dco   <= #1 dc;
	    end

	assign zerobl = &rleni &  ~|sizei & deni;
	assign eob    = ~|{rleni, sizei} & deni & ~dci;

	always @(posedge clk or negedge rst)
	  if (!rst)
	     begin
	         state <= #1 1'b0;
	         den   <= #1 1'b0;
	         deno  <= #1 1'b0;
	     end
	  else
	    if(ena)
	      case (state) // synopsys full_case parallel_case
	         1'b0:
	             begin
	                 if (zerobl)
	                    begin
	                        state <= #1 1'b1; // go to zero-detection state
	                        den   <= #1 1'b0; // do not yet set data output enable
	                        deno  <= #1 den;  // output previous data
	                    end
	                 else
	                    begin
	                        state <= #1 1'b0; // stay in 'normal' state
	                        den   <= #1 deni; // set data output enable
	                        deno  <= #1 den;  // output previous data
	                    end
	             end

	         1'b1:
	             begin
	                 deno <= #1 1'b0;

	                 if (deni)
	                    if (zerobl)
	                       begin
	                           state <= #1 1'b1; // stay in zero-detection state
	                           den   <= #1 1'b0; // hold current zer-block
	                           deno  <= #1 1'b1; // output previous zero-block
	                       end
	                    else if (eob)
	                       begin
	                           state <= #1 1'b0; // go to 'normal' state
	                           den   <= #1 1'b1; // set output enable for EOB
	                           deno  <= #1 1'b0; // (was already zero), maybe optimize ??
	                       end
	                    else
	                       begin
	                           state <= #1 1'b0; // go to normal state
	                           den   <= #1 1'b1; // set data output enable
	                           deno  <= #1 1'b1; // oops, zero-block should have been output
	                       end
	             end
	      endcase
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Discrete Cosine Transform, MAC unit                        ////
////                                                             ////
////  Virtex-II: Block-Multiplier is used                        ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: dct_mac.v,v 1.3 2002/10/31 12:50:03 rherveille Exp $
//
//  $Date: 2002/10/31 12:50:03 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: dct_mac.v,v $
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

module dct_mac(clk, ena, dclr, din, coef, result);

	//
	// parameters
	//
	parameter dwidth = 8;
	parameter cwidth = 16;
	parameter mwidth = dwidth + cwidth;  // multiplier result
	parameter rwidth = mwidth +3;        // add 3 bits for growth

	//
	// inputs & outputs
	//
	input               clk;    // clock input
	input               ena;    // clock enable
	input               dclr;   // start new mac (delayed 1 cycle)
	input  [dwidth-1:0] din;    // data input
	input  [cwidth-1:0] coef;   // coefficient input
	output [rwidth-1:0] result; // mac-result
	reg [rwidth -1:0] result;

	//
	// variables
	//
	wire [mwidth-1:0] idin;
	wire [mwidth-1:0] icoef;

	reg  [mwidth -1:0] mult_res /* synthesis syn_multstyle="block_mult" syn_pipeline=1*/ ;
	wire [rwidth -1:0] ext_mult_res;


	//
	// module body
	//
	assign icoef = { {(mwidth-cwidth){coef[cwidth-1]}}, coef};
	assign idin  = { {(mwidth-dwidth){din[dwidth-1]}}, din};

	// generate multiplier structure
	always @(posedge clk)
	  if(ena)
	    mult_res <= #1 icoef * idin;

	assign ext_mult_res = { {3{mult_res[mwidth-1]}}, mult_res};

	// generate adder structure
	always @(posedge clk)
	  if(ena)
	    if(dclr)
	      result <= #1 ext_mult_res;
	    else
	      result <= #1 ext_mult_res + result;
endmodule












/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Non-restoring unsinged divider                             ////
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
//  $Id: div_uu.v,v 1.3 2002/10/31 12:52:55 rherveille Exp $
//
//  $Date: 2002/10/31 12:52:55 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: div_uu.v,v $
//               Revision 1.3  2002/10/31 12:52:55  rherveille
//               *** empty log message ***
//
//               Revision 1.2  2002/10/23 09:07:03  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module div_uu(clk, ena, z, d, q, s, div0, ovf);

	//
	// parameters
	//
	parameter z_width = 16;
	parameter d_width = z_width /2;
	
	//
	// inputs & outputs
	//
	input clk;               // system clock
	input ena;               // clock enable

	input  [z_width -1:0] z; // divident
	input  [d_width -1:0] d; // divisor
	output [d_width -1:0] q; // quotient
	reg [d_width-1:0] q;
	output [d_width -1:0] s; // remainder
	reg [d_width-1:0] s;
	output div0;
	reg div0;
	output ovf;
	reg ovf;

	//	
	// functions
	//
	function [z_width:0] gen_s;
		input [z_width:0] si;
		input [z_width:0] di;
	begin
	  if(si[z_width])
	    gen_s = {si[z_width-1:0], 1'b0} + di;
	  else
	    gen_s = {si[z_width-1:0], 1'b0} - di;
	end
	endfunction

	function [d_width-1:0] gen_q;
		input [d_width-1:0] qi;
		input [z_width:0] si;
	begin
	  gen_q = {qi[d_width-2:0], ~si[z_width]};
	end
	endfunction

	function [d_width-1:0] assign_s;
		input [z_width:0] si;
		input [z_width:0] di;
		reg [z_width:0] tmp;
	begin
	  if(si[z_width])
	    tmp = si + di;
	  else
	    tmp = si;

	  assign_s = tmp[z_width-1:z_width-4];
	end
	endfunction

	//
	// variables
	//
	reg [d_width-1:0] q_pipe  [d_width-1:0];
	reg [z_width:0] s_pipe  [d_width:0];
	reg [z_width:0] d_pipe  [d_width:0];

	reg [d_width:0] div0_pipe, ovf_pipe;
	//
	// perform parameter checks
	//
	// synopsys translate_off
	initial
	begin
	  if(d_width !== z_width / 2)
	    $display("div.v parameter error (d_width != z_width/2).");
	end
	// synopsys translate_on

	integer n0, n1, n2, n3;

	// generate divisor (d) pipe
	always @(d)
	  d_pipe[0] <= {1'b0, d, {(z_width-d_width){1'b0}} };

	always @(posedge clk)
	  if(ena)
	    for(n0=1; n0 <= d_width; n0=n0+1)
	       d_pipe[n0] <= #1 d_pipe[n0-1];

	// generate internal remainder pipe
	always @(z)
	  s_pipe[0] <= z;

	always @(posedge clk)
	  if(ena)
	    for(n1=1; n1 <= d_width; n1=n1+1)
	       s_pipe[n1] <= #1 gen_s(s_pipe[n1-1], d_pipe[n1-1]);

	// generate quotient pipe
	always @(posedge clk)
	  q_pipe[0] <= #1 0;

	always @(posedge clk)
	  if(ena)
	    for(n2=1; n2 < d_width; n2=n2+1)
	       q_pipe[n2] <= #1 gen_q(q_pipe[n2-1], s_pipe[n2]);


	// flags (divide_by_zero, overflow)
	always @(z or d)
	begin
	  ovf_pipe[0]  <= !(z[z_width-1:d_width] < d);
	  div0_pipe[0] <= ~|d;
	end

	always @(posedge clk)
	  if(ena)
	    for(n3=1; n3 <= d_width; n3=n3+1)
	    begin
	        ovf_pipe[n3] <= #1 ovf_pipe[n3-1];
	        div0_pipe[n3] <= #1 div0_pipe[n3-1];
	    end

	// assign outputs
	always @(posedge clk)
	  if(ena)
	    ovf <= #1 ovf_pipe[d_width];

	always @(posedge clk)
	  if(ena)
	    div0 <= #1 div0_pipe[d_width];

	always @(posedge clk)
	  if(ena)
	    q <= #1 gen_q(q_pipe[d_width-1], s_pipe[d_width]);

	always @(posedge clk)
	  if(ena)
	    s <= #1 assign_s(s_pipe[d_width], d_pipe[d_width]);
endmodule



/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Non-restoring signed by unsigned divider                   ////
////  Uses the non-restoring unsigned by unsigned divider        ////
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
//  $Id: div_su.v,v 1.3 2002/10/31 12:52:54 rherveille Exp $
//
//  $Date: 2002/10/31 12:52:54 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: div_su.v,v $
//               Revision 1.3  2002/10/31 12:52:54  rherveille
//               *** empty log message ***
//
//               Revision 1.2  2002/10/23 09:07:03  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module div_su(clk, ena, z, d, q, s, div0, ovf);

	//
	// parameters
	//
	parameter z_width = 16;
	parameter d_width = z_width /2;
	
	//
	// inputs & outputs
	//
	input clk;              // system clock
	input ena;              // clock enable

	input  [z_width-1:0] z; // divident
	input  [d_width-1:0] d; // divisor
	output [d_width  :0] q; // quotient
	output [d_width-1:0] s; // remainder
	output div0;
	output ovf;

	reg [d_width :0] q;
	reg [d_width-1:0] s;
	reg div0;
	reg ovf;

	//
	// variables
	//
	reg [z_width -1:0] iz;
	reg [d_width -1:0] id;
	reg [d_width +1:0] spipe;

	wire [d_width -1:0] iq, is;
	wire                idiv0, iovf;

	//
	// module body
	//

	// delay d
	always @(posedge clk)
	  if (ena)
	    id <= #1 d;

	// check z, take abs value
	always @(posedge clk)
	  if (ena)
	    if (z[z_width-1])
	       iz <= #1 ~z +1'h1;
	    else
	       iz <= #1 z;

	// generate spipe (sign bit pipe)
	integer n;
	always @(posedge clk)
	  if(ena)
	  begin
	      spipe[0] <= #1 z[z_width-1];

	      for(n=1; n <= d_width+1; n=n+1)
	         spipe[n] <= #1 spipe[n-1];
	  end

	// hookup non-restoring divider
	div_uu #(z_width, d_width)
	divider (
		.clk(clk),
		.ena(ena),
		.z(iz),
		.d(id),
		.q(iq),
		.s(is),
		.div0(idiv0),
		.ovf(iovf)
	);

	// correct divider results if 'd' was negative
	always @(posedge clk)
	  if(ena)
	    if(spipe[d_width+1])
	    begin
	        q <= #1 (~iq) + 1'h1;
	        s <= #1 (~is) + 1'h1;
	    end
	    else
	    begin
	        q <= #1 {1'b0, iq};
	        s <= #1 {1'b0, is};
	    end

	// delay flags same as results
	always @(posedge clk)
	  if(ena)
	  begin
	      div0 <= #1 idiv0;
	      ovf  <= #1 iovf;
	  end
endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Run-Length Encoder, intermediate results              ////
////                                                             ////
////  - Translate DC and AC coeff. into:                         ////
////  1) zero-run-length                                         ////
////  2) bit-size for amplitude                                  ////
////  3) amplitude                                               ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
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
//  $Id: jpeg_rle1.v,v 1.4 2002/10/31 12:53:39 rherveille Exp $
//
//  $Date: 2002/10/31 12:53:39 $
//  $Revision: 1.4 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: jpeg_rle1.v,v $
//               Revision 1.4  2002/10/31 12:53:39  rherveille
//               *** empty log message ***
//
//               Revision 1.3  2002/10/23 18:58:54  rherveille
//               Fixed a bug in the zero-run (run-length-coder)
//
//               Revision 1.2  2002/10/23 09:07:04  rherveille
//               Improved many files.
//               Fixed some bugs in Run-Length-Encoder.
//               Removed dependency on ud_cnt and ro_cnt.
//               Started (Motion)JPEG hardware encoder project.
//

//synopsys translate_off
//`include "timescale.v"
//synopsys translate_on

module jpeg_rle1(clk, rst, ena, go, din, rlen, size, amp, den, dcterm);

	//
	// parameters
	//

	//
	// inputs & outputs
	//
	input         clk;    // system clock
	input         rst;    // asynchronous reset
	input         ena;    // clock enable
	input         go;
	input  [11:0] din;    // data input

	output [ 3:0] rlen;   // run-length
	output [ 3:0] size;   // size (or category)
	output [11:0] amp;    // amplitude
	output        den;    // data output enable
	output        dcterm; // DC-term (start of new block)

	reg [ 3:0] rlen, size;
	reg [11:0] amp;
	reg        den, dcterm;

	//
	// variables
	//

	reg [5:0] sample_cnt;
	reg [3:0] zero_cnt;
	wire      is_zero;

	reg       state;
	parameter dc = 1'b0;
	parameter ac = 1'b1;

	//
	// module body
	//

	//
	// function declarations
	//
	
	// Function abs; absolute value
	function [10:0] abs;
	  input [11:0] a;
	begin
	  if (a[11])
	      abs = (~a[10:0]) +11'h1;
	  else
	      abs = a[10:0];
	end
	endfunction

	// Function cat, calculates category for Din
	function [3:0] cat;
	  input [11:0] a;
	  reg   [10:0] tmp;
	begin
	    // get absolute value
	    tmp = abs(a);

	    // determine category
	    casex(tmp) // synopsys full_case parallel_case
	      11'b1??_????_???? : cat = 4'hb; // 1024..2047
	      11'b01?_????_???? : cat = 4'ha; //  512..1023
	      11'b001_????_???? : cat = 4'h9; //  256.. 511
	      11'b000_1???_???? : cat = 4'h8; //  128.. 255
	      11'b000_01??_???? : cat = 4'h7; //   64.. 127
	      11'b000_001?_???? : cat = 4'h6; //   32..  63
	      11'b000_0001_???? : cat = 4'h5; //   16..  31
	      11'b000_0000_1??? : cat = 4'h4; //    8..  15
	      11'b000_0000_01?? : cat = 4'h3; //    4..   7
	      11'b000_0000_001? : cat = 4'h2; //    2..   3
	      11'b000_0000_0001 : cat = 4'h1; //    1
	      11'b000_0000_0000 : cat = 4'h0; //    0 (DC only)
	    endcase
	end
	endfunction


	// Function modamp, calculate additional bits per category
	function [10:0] rem;
	  input [11:0] a;
	  reg   [10:0] tmp, tmp_rem;
	begin
	    tmp_rem = a[11] ? (a[10:0] - 10'h1) : a[10:0];

	    if(0)
	    begin
	      // get absolute value
	      tmp = abs(a);

	      casex(tmp) // synopsys full_case parallel_case
	        11'b1??_????_???? : rem = tmp_rem & 11'b111_1111_1111;
	        11'b01?_????_???? : rem = tmp_rem & 11'b011_1111_1111;
	        11'b001_????_???? : rem = tmp_rem & 11'b001_1111_1111;
	        11'b000_1???_???? : rem = tmp_rem & 11'b000_1111_1111;
	        11'b000_01??_???? : rem = tmp_rem & 11'b000_0111_1111;
	        11'b000_001?_???? : rem = tmp_rem & 11'b000_0011_1111;
	        11'b000_0001_???? : rem = tmp_rem & 11'b000_0001_1111;
	        11'b000_0000_1??? : rem = tmp_rem & 11'b000_0000_1111;
	        11'b000_0000_01?? : rem = tmp_rem & 11'b000_0000_0111;
	        11'b000_0000_001? : rem = tmp_rem & 11'b000_0000_0011;
	        11'b000_0000_0001 : rem = tmp_rem & 11'b000_0000_0001;
	        11'b000_0000_0000 : rem = tmp_rem & 11'b000_0000_0000;
	      endcase
	    end
	    else
	      rem = tmp_rem;
	end
	endfunction

	// detect zero
	assign is_zero = ~|din;

	// assign dout
	always @(posedge clk)
	  if (ena)
	      amp <= #1 rem(din);

	// generate sample counter
	always @(posedge clk)
	  if (ena)
	      if (go)
	          sample_cnt <= #1 1; // count AC-terms, 'go=1' is sample-zero
	      else
	          sample_cnt <= #1 sample_cnt +1;

	// generate zero counter
	always @(posedge clk)
	  if (ena)
	      if (is_zero)
	          zero_cnt <= #1 zero_cnt +1;
	      else
	          zero_cnt <= #1 0;

	// statemachine, create intermediate results
	always @(posedge clk or negedge rst)
	  if(!rst)
	    begin
	        state  <= #1 dc;
	        rlen   <= #1 0;
	        size   <= #1 0;
	        den    <= #1 1'b0;
	        dcterm <= #1 1'b0;
	    end
	  else if (ena)
	    case (state) // synopsys full_case parallel_case
	      dc:
	        begin
	            rlen <= #1 0;
	            size <= #1 cat(din);

	            if(go)
	              begin
	                  state  <= #1 ac;
	                  den    <= #1 1'b1;
	                  dcterm <= #1 1'b1;
	              end
	            else
	              begin
	                  state  <= #1 dc;
	                  den    <= #1 1'b0;
	                  dcterm <= #1 1'b0;
	              end
	        end

	      ac:
	        if(&sample_cnt)   // finished current block
	           begin
	               state <= #1 dc;

	               if (is_zero) // last sample zero? send EOB
	                  begin
	                      rlen   <= #1 0;
	                      size   <= #1 0;
	                      den    <= #1 1'b1;
	                      dcterm <= #1 1'b0;
	                  end
	               else
	                  begin
	                      rlen <= #1 zero_cnt;
	                      size <= #1 cat(din);
	                      den  <= #1 1'b1;
	                      dcterm <= #1 1'b0;
	                  end
	           end
	        else
	           begin
	               state  <= #1 ac;

	               rlen   <= #1 zero_cnt;
	               dcterm <= #1 1'b0;

	               if (is_zero)
	                  begin
	                      size   <= #1 0;
	                      den    <= #1 &zero_cnt;
	                  end
	               else
	                  begin
	                      size <= #1 cat(din);
	                      den  <= #1 1'b1;
	                  end
	           end
	    endcase

endmodule
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
