module doublepll (
    input	reset,		// Sense positive reset
    input	osc,		// Input oscillator to match
    input [4:0]	div,		// PLL feedback division ratio

    output [1:0] clockp,	// Two 90 degree clock phases
    output [3:0] clockd		// Divided clock (2, 4, 8, 16)
);
    wire reset_b = ~reset;
	assign clockp = clockp_1&clockp_2;
	assign clockd = clockd_1&clockd_2;
    digital_pll pll (
	.reset(reset_b),
	.osc(osc),
	.clockp(clockp_1),
	.clockd(clockd_1),
	.div(div)
    );

    digital_pll pll1 (
	.reset(reset),
	.osc(osc),
	.clockp(clockp_2),
	.clockd(clockd_2),
	.div(div)
    );
endmodule

(* blackbox *)
module digital_pll(reset, osc, clockp, clockd, div);

    input	reset;		// Sense positive reset
    input	osc;		// Input oscillator to match
    input [4:0]	div;		// PLL feedback division ratio

    output [1:0] clockp;	// Two 90 degree clock phases
    output [3:0] clockd;	// Divided clock (2, 4, 8, 16)
endmodule
