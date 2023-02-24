module OTTER_WRAPPER (
	CLK,
	RESET,
	INTR
);
	input CLK;
	input RESET;
	input INTR;
	wire [31:0] IOBUS_out;
	wire [31:0] IOBUS_in;
	wire [31:0] IOBUS_addr;
	wire IOBUS_wr;
	OTTER_MCU MCU(
		.RESET(RESET),
		.INTR(INTR),
		.CLK(CLK),
		.IOBUS_OUT(IOBUS_out),
		.IOBUS_IN(IOBUS_in),
		.IOBUS_ADDR(IOBUS_addr),
		.IOBUS_WR(IOBUS_wr)
	);
endmodule
