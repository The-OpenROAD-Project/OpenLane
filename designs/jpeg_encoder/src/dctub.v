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
