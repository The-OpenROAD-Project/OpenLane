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
