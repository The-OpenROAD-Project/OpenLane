//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Look-Up Tables
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for unfrac_lut4 -----
module unfrac_lut4(in,
                   sram,
                   sram_inv,
                   out);
//----- INPUT PORTS -----
input [0:3] in;
//----- INPUT PORTS -----
input [0:15] sram;
//----- INPUT PORTS -----
input [0:15] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
wire [0:3] in;
wire [0:0] out;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] scs8hd_buf_2_0_X;
wire [0:0] scs8hd_buf_2_1_X;
wire [0:0] scs8hd_buf_2_2_X;
wire [0:0] scs8hd_buf_2_3_X;
wire [0:0] scs8hd_inv_1_0_Y;
wire [0:0] scs8hd_inv_1_1_Y;
wire [0:0] scs8hd_inv_1_2_Y;
wire [0:0] scs8hd_inv_1_3_Y;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	scs8hd_inv_1 scs8hd_inv_1_0_ (
		.A(in[0]),
		.Y(scs8hd_inv_1_0_Y[0]));

	scs8hd_inv_1 scs8hd_inv_1_1_ (
		.A(in[1]),
		.Y(scs8hd_inv_1_1_Y[0]));

	scs8hd_inv_1 scs8hd_inv_1_2_ (
		.A(in[2]),
		.Y(scs8hd_inv_1_2_Y[0]));

	scs8hd_inv_1 scs8hd_inv_1_3_ (
		.A(in[3]),
		.Y(scs8hd_inv_1_3_Y[0]));

	scs8hd_buf_2 scs8hd_buf_2_0_ (
		.A(in[0]),
		.X(scs8hd_buf_2_0_X[0]));

	scs8hd_buf_2 scs8hd_buf_2_1_ (
		.A(in[1]),
		.X(scs8hd_buf_2_1_X[0]));

	scs8hd_buf_2 scs8hd_buf_2_2_ (
		.A(in[2]),
		.X(scs8hd_buf_2_2_X[0]));

	scs8hd_buf_2 scs8hd_buf_2_3_ (
		.A(in[3]),
		.X(scs8hd_buf_2_3_X[0]));

	unfrac_lut4_mux unfrac_lut4_mux_0_ (
		.in(sram[0:15]),
		.sram({scs8hd_buf_2_0_X[0], scs8hd_buf_2_1_X[0], scs8hd_buf_2_2_X[0], scs8hd_buf_2_3_X[0]}),
		.sram_inv({scs8hd_inv_1_0_Y[0], scs8hd_inv_1_1_Y[0], scs8hd_inv_1_2_Y[0], scs8hd_inv_1_3_Y[0]}),
		.out(out[0]));

endmodule
// ----- END Verilog module for unfrac_lut4 -----


