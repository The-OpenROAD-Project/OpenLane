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
