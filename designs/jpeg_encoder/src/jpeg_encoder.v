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
