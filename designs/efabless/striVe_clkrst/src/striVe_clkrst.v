module striVe_clkrst(
	input ext_clk_sel,
	input ext_clk,
	input pll_clk,
	input reset, 
	input ext_reset,
	output clk,
	output resetn
);

	// Clock assignment (to do:  make this glitch-free)
	assign clk = (ext_clk_sel == 1'b1) ? ext_clk : pll_clk;

	// Reset assignment.  "reset" comes from POR, while "ext_reset"
	// comes from standalone SPI (and is normally zero unless
	// activated from the SPI).

	// Staged-delay reset
	reg [2:0] reset_delay;

	always @(posedge clk or posedge reset) begin
	    if (reset == 1'b1) begin
		reset_delay <= 3'b111;
	    end else begin
		reset_delay <= {1'b0, reset_delay[2:1]};
	    end
	end

	assign resetn = ~(reset_delay[0] | ext_reset);

endmodule
