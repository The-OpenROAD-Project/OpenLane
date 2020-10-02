// Copyright 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Tunable ring oscillator---synthesizable (physical) version.
//
// NOTE:  This netlist cannot be simulated correctly due to lack
// of accurate timing in the digital cell verilog models.

module delay_stage(in, trim, out);
    input in;
    input [1:0] trim;
    output out;

    wire d0, d1, d2;

    sky130_fd_sc_hd__clkbuf_2 delaybuf0 (
	.A(in),
	.X(ts)
    );

    sky130_fd_sc_hd__clkbuf_1 delaybuf1 (
	.A(ts),
	.X(d0)
    );

    sky130_fd_sc_hd__einvp_2 delayen1 (
	.A(d0),
	.TE(trim[1]),
	.Z(d1)
    );

    sky130_fd_sc_hd__einvn_4 delayenb1 (
	.A(ts),
	.TE_B(trim[1]),
	.Z(d1)
    );

    sky130_fd_sc_hd__clkinv_1 delayint0 (
	.A(d1),
	.Y(d2)
    );

    sky130_fd_sc_hd__einvp_2 delayen0 (
	.A(d2),
	.TE(trim[0]),
	.Z(out)
    );

    sky130_fd_sc_hd__einvn_8 delayenb0 (
	.A(ts),
	.TE_B(trim[0]),
	.Z(out)
    );

endmodule

module start_stage(in, trim, reset, out);
    input in;
    input [1:0] trim;
    input reset;
    output out;

    wire d0, d1, d2, ctrl0, one;

    sky130_fd_sc_hd__clkbuf_1 delaybuf0 (
	.A(in),
	.X(d0)
    );

    sky130_fd_sc_hd__einvp_2 delayen1 (
	.A(d0),
	.TE(trim[1]),
	.Z(d1)
    );

    sky130_fd_sc_hd__einvn_4 delayenb1 (
	.A(in),
	.TE_B(trim[1]),
	.Z(d1)
    );

    sky130_fd_sc_hd__clkinv_1 delayint0 (
	.A(d1),
	.Y(d2)
    );

    sky130_fd_sc_hd__einvp_2 delayen0 (
	.A(d2),
	.TE(trim[0]),
	.Z(out)
    );

    sky130_fd_sc_hd__einvn_8 delayenb0 (
	.A(in),
	.TE_B(ctrl0),
	.Z(out)
    );

    sky130_fd_sc_hd__einvp_1 reseten0 (
	.A(one),
	.TE(reset),
	.Z(out)
    );

    sky130_fd_sc_hd__or2_2 ctrlen0 (
	.A(reset),
	.B(trim[0]),
	.X(ctrl0)
    );

    sky130_fd_sc_hd__conb_1 const1 (
	.HI(one),
	.LO()
    );

endmodule

// Ring oscillator with 13 stages, each with two trim bits delay
// (see above).  Trim is not binary:  For trim[1:0], lower bit
// trim[0] is primary trim and must be applied first;  upper
// bit trim[1] is secondary trim and should only be applied
// after the primary trim is applied, or it has no effect.
//
// Total effective number of inverter stages in this oscillator
// ranges from 13 at trim 0 to 65 at trim 24.  The intention is
// to cover a range greater than 2x so that the midrange can be
// reached over all PVT conditions.
//
// Frequency of this ring oscillator under SPICE simulations at
// nominal PVT is maximum 214 MHz (trim 0), minimum 90 MHz (trim 24).

module ring_osc2x13(reset, trim, clockp);
    input reset;
    input [25:0] trim;
    output[1:0] clockp;

    wire [12:0] d;
    wire [1:0] clockp;
    wire [1:0] c;

    // Main oscillator loop stages
 
    genvar i;
    generate
	for (i = 0; i < 12; i = i + 1) begin : dstage
	    delay_stage id (
		.in(d[i]),
		.trim({trim[i+13], trim[i]}),
		.out(d[i+1])
	    );
	end
    endgenerate

    // Reset/startup stage
 
    start_stage iss (
	.in(d[12]),
	.trim({trim[25], trim[12]}),
	.reset(reset),
	.out(d[0])
    );

    // Buffered outputs a 0 and 90 degrees phase (approximately)

    sky130_fd_sc_hd__clkinv_2 ibufp00 (
	.A(d[0]),
	.Y(c[0])
    );
    sky130_fd_sc_hd__clkinv_8 ibufp01 (
	.A(c[0]),
	.Y(clockp[0])
    );
    sky130_fd_sc_hd__clkinv_2 ibufp10 (
	.A(d[6]),
	.Y(c[1])
    );
    sky130_fd_sc_hd__clkinv_8 ibufp11 (
	.A(c[1]),
	.Y(clockp[1])
    );

endmodule
