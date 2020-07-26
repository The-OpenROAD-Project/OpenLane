////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	firtap.v
//
// Project:	DSP Filtering Example Project
//
// Purpose:	Implements a single tap within a FIR filter.  This particular
//		FIR tap design is specifically designed to make it easier
//	for the parent module to add (or remove) taps.  Hence, by stringing
//	N of these components together, an N tap filter can be created.
//
//	This fir tap is a component of genericfir.v, the high speed (1-sample
//	per clock, adjustable tap) FIR filter.
//
//	Be aware, implementing a FIR tap in this manner can be a very expensive
//	use of FPGA resources, very quickly necessitating a large FPGA for
//	even the smallest (128 tap) filters.
//
//	Resource usage may be minimized by minizing the number of taps,
//	minimizing the number of bits in each tap, and/or the number of bits
//	in the input (and output) samples.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
//
// This file is part of the DSP filtering set of designs.
//
// The DSP filtering designs are free RTL designs: you can redistribute them
// and/or modify any of them under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// The DSP filtering designs are distributed in the hope that they will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
// General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	firtap(i_clk, i_reset, i_tap_wr, i_tap, o_tap,
		i_ce, i_sample, o_sample,
		i_partial_acc, o_acc);
	parameter		IW=16, TW=IW, OW=IW+TW+8;
	parameter [0:0]		FIXED_TAPS=0;
	parameter [(TW-1):0]	INITIAL_VALUE=0;
	//
	input	wire			i_clk, i_reset;
	//
	input	wire			i_tap_wr;
	input	wire	[(TW-1):0]	i_tap;
	output	wire signed [(TW-1):0]	o_tap;
	//
	input	wire			i_ce;
	input	wire signed [(IW-1):0]	i_sample;
	output	wire	[(IW-1):0]	o_sample;
	//
	input	wire	[(OW-1):0]	i_partial_acc;
	output	wire	[(OW-1):0]	o_acc;
	//

	reg		[(IW-1):0]	delayed_sample;
	reg	signed	[(TW+IW-1):0]	product;

	// Determine the tap we are using
	generate
	if (FIXED_TAPS != 0)
		// If our taps are fixed, the tap is given by the i_tap
		// external input.  This allows the parent module to be
		// able to use readmemh to set all of the taps in a filter
		assign	o_tap = i_tap;

	else begin
		// If the taps are adjustable, then use the i_tap_wr signal
		// to know when to adjust the tap.  In this case, taps are
		// strung together through the filter structure--our output
		// tap becomes the input tap of the next tap module, and
		// i_tap_wr causes all of them to shift forward by one.
		reg	[(TW-1):0]	tap;

		initial	tap = INITIAL_VALUE;
		always @(posedge i_clk)
			if (i_tap_wr)
				tap <= i_tap;
		assign o_tap = tap;

	end endgenerate

	// Forward the sample on down the line, to be the input sample for the
	// next component
	initial	o_sample = 0;
	initial	delayed_sample = 0;
	always @(posedge i_clk)
		if (i_reset)
		begin
			delayed_sample <= 0;
			o_sample <= 0;
		end else if (i_ce)
		begin
			// Note the two sample delay in this forwarding
			// structure.  This aligns the inputs up so that the
			// accumulator structure (below) works.
			delayed_sample <= i_sample;
			o_sample <= delayed_sample;
		end

`ifndef	FORMAL
	// Multiply the filter tap by the incoming sample
	always @(posedge i_clk)
		if (i_reset)
			product <= 0;
		else if (i_ce)
			product <= o_tap * i_sample;
`else
	wire	[(TW+IW-1):0]	w_pre_product;

	abs_mpy #(.AW(TW), .BW(IW), .OPT_SIGNED(1'b1))
		abs_bypass(i_clk, i_reset, o_tap, i_sample, w_pre_product);

	initial	product = 0;
	always @(posedge i_clk)
	if (i_reset)
		product <= 0;
	else if (i_ce)
		product <= w_pre_product;
`endif

	// Continue summing together the output components of the FIR filter
	initial	o_acc = 0;
	always @(posedge i_clk)
		if (i_reset)
			o_acc <= 0;
		else if (i_ce)
			o_acc <= i_partial_acc
				+ { {(OW-(TW+IW)){product[(TW+IW-1)]}},
						product };


	// Make verilator happy
	// verilate lint_on  UNUSED
	wire	unused;
	assign	unused = i_tap_wr;
	// verilate lint_off UNUSED
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	genericfir.v
//
// Project:	DSP Filtering Example Project
//
// Purpose:	Implement a high speed (1-output per clock), adjustable tap FIR
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
//
// This file is part of the DSP filtering set of designs.
//
// The DSP filtering designs are free RTL designs: you can redistribute them
// and/or modify any of them under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// The DSP filtering designs are distributed in the hope that they will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
// General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with these designs.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	genericfir(i_clk, i_reset, i_tap_wr, i_tap, i_ce, i_sample, o_result);
	parameter		NTAPS=128, IW=12, TW=IW, OW=2*IW+7;
	parameter [0:0]		FIXED_TAPS=0;
	input	wire			i_clk, i_reset;
	//
	input	wire			i_tap_wr;	// Ignored if FIXED_TAPS
	input	wire	[(TW-1):0]	i_tap;		// Ignored if FIXED_TAPS
	//
	input	wire			i_ce;
	input	wire	[(IW-1):0]	i_sample;
	output	wire	[(OW-1):0]	o_result;

	wire	[(TW-1):0] tap		[NTAPS:0];
	wire	[(TW-1):0] tapout	[NTAPS:0];
	wire	[(IW-1):0] sample	[NTAPS:0];
	wire	[(OW-1):0] result	[NTAPS:0];
	wire		tap_wr;

	// The first sample in our sample chain is the sample we are given
	assign	sample[0]	= i_sample;
	// Initialize the partial summing accumulator with zero
	assign	result[0]	= 0;

	genvar	k;
	generate
	if(FIXED_TAPS)
	begin
		initial $readmemh("taps.hex", tap);

		assign	tap_wr = 1'b0;
	end else begin
		assign	tap_wr = i_tap_wr;
		assign	tap[0] = i_tap;
	end

	for(k=0; k<NTAPS; k=k+1)
	begin: FILTER

		firtap #(.FIXED_TAPS(FIXED_TAPS),
				.IW(IW), .OW(OW), .TW(TW),
				.INITIAL_VALUE(0))
			tapk(i_clk, i_reset,
				// Tap update circuitry
				tap_wr, tap[NTAPS-1-k], tapout[k],
				// Sample delay line
				i_ce, sample[k], sample[k+1],
				// The output accumulator
				result[k], result[k+1]);

		if (!FIXED_TAPS)
			assign	tap[NTAPS-1-k] = tapout[k+1];

		// Make verilator happy
		// verilator lint_off UNUSED
		wire	[(TW-1):0]	unused_tap;
		if (FIXED_TAPS)
			assign	unused_tap    = tapout[k];
		// verilator lint_on UNUSED
	end endgenerate

	assign	o_result = result[NTAPS];

	// Make verilator happy
	// verilator lint_off UNUSED
	wire	[(TW):0]	unused;
	assign	unused = { i_tap_wr, i_tap };
	// verilator lint_on UNUSED

endmodule

