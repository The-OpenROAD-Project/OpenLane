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












