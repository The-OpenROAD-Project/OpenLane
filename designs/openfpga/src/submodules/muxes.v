//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Multiplexers
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for mux_tree_like_tapbuf_size42 -----
module mux_tree_like_tapbuf_size42(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:41] in;
//----- INPUT PORTS -----
input [0:5] sram;
//----- INPUT PORTS -----
input [0:5] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_15_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_16_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_17_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_18_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_19_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_20_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_21_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_22_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_23_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_24_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_25_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_26_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_27_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_28_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_29_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_30_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_31_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_32_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_33_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_34_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_35_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_36_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_37_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_38_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_39_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_40_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_41_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_15_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_16_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_17_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_18_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_19_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_20_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_21_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_22_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_23_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_24_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_25_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_26_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_27_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_28_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_29_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_30_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_31_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_32_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_33_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_34_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_35_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_36_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_37_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_38_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_39_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_40_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_41_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_15_ (
		.A(in[15]),
		.Y(sky130_fd_sc_hd__inv_1_15_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_16_ (
		.A(in[16]),
		.Y(sky130_fd_sc_hd__inv_1_16_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_17_ (
		.A(in[17]),
		.Y(sky130_fd_sc_hd__inv_1_17_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_18_ (
		.A(in[18]),
		.Y(sky130_fd_sc_hd__inv_1_18_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_19_ (
		.A(in[19]),
		.Y(sky130_fd_sc_hd__inv_1_19_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_20_ (
		.A(in[20]),
		.Y(sky130_fd_sc_hd__inv_1_20_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_21_ (
		.A(in[21]),
		.Y(sky130_fd_sc_hd__inv_1_21_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_22_ (
		.A(in[22]),
		.Y(sky130_fd_sc_hd__inv_1_22_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_23_ (
		.A(in[23]),
		.Y(sky130_fd_sc_hd__inv_1_23_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_24_ (
		.A(in[24]),
		.Y(sky130_fd_sc_hd__inv_1_24_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_25_ (
		.A(in[25]),
		.Y(sky130_fd_sc_hd__inv_1_25_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_26_ (
		.A(in[26]),
		.Y(sky130_fd_sc_hd__inv_1_26_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_27_ (
		.A(in[27]),
		.Y(sky130_fd_sc_hd__inv_1_27_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_28_ (
		.A(in[28]),
		.Y(sky130_fd_sc_hd__inv_1_28_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_29_ (
		.A(in[29]),
		.Y(sky130_fd_sc_hd__inv_1_29_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_30_ (
		.A(in[30]),
		.Y(sky130_fd_sc_hd__inv_1_30_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_31_ (
		.A(in[31]),
		.Y(sky130_fd_sc_hd__inv_1_31_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_32_ (
		.A(in[32]),
		.Y(sky130_fd_sc_hd__inv_1_32_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_33_ (
		.A(in[33]),
		.Y(sky130_fd_sc_hd__inv_1_33_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_34_ (
		.A(in[34]),
		.Y(sky130_fd_sc_hd__inv_1_34_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_35_ (
		.A(in[35]),
		.Y(sky130_fd_sc_hd__inv_1_35_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_36_ (
		.A(in[36]),
		.Y(sky130_fd_sc_hd__inv_1_36_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_37_ (
		.A(in[37]),
		.Y(sky130_fd_sc_hd__inv_1_37_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_38_ (
		.A(in[38]),
		.Y(sky130_fd_sc_hd__inv_1_38_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_39_ (
		.A(in[39]),
		.Y(sky130_fd_sc_hd__inv_1_39_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_40_ (
		.A(in[40]),
		.Y(sky130_fd_sc_hd__inv_1_40_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_41_ (
		.A(in[41]),
		.Y(sky130_fd_sc_hd__inv_1_41_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_41_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_15_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_8_ (
		.A1(sky130_fd_sc_hd__inv_1_16_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_17_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_9_ (
		.A1(sky130_fd_sc_hd__inv_1_18_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_19_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_10_ (
		.A1(sky130_fd_sc_hd__inv_1_20_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_21_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_4_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_15_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_5_ (
		.A1(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_22_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_16_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_23_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_24_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_17_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_25_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_26_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_18_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_8_ (
		.A1(sky130_fd_sc_hd__inv_1_27_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_28_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_19_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_9_ (
		.A1(sky130_fd_sc_hd__inv_1_29_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_30_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_20_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_10_ (
		.A1(sky130_fd_sc_hd__inv_1_31_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_32_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_21_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_11_ (
		.A1(sky130_fd_sc_hd__inv_1_33_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_34_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_22_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_12_ (
		.A1(sky130_fd_sc_hd__inv_1_35_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_36_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_23_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_13_ (
		.A1(sky130_fd_sc_hd__inv_1_37_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_38_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_24_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_14_ (
		.A1(sky130_fd_sc_hd__inv_1_39_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_40_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_25_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_15_ (
		.A1(sky130_fd_sc_hd__inv_1_41_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_26_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_27_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_28_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_15_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_16_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_29_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_17_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_18_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_30_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_4_ (
		.A1(sky130_fd_sc_hd__mux2_1_19_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_20_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_31_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_5_ (
		.A1(sky130_fd_sc_hd__mux2_1_21_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_22_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_32_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_6_ (
		.A1(sky130_fd_sc_hd__mux2_1_23_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_24_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_33_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_7_ (
		.A1(sky130_fd_sc_hd__mux2_1_25_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_26_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_34_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_27_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_28_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_35_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_29_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_30_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_36_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_31_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_32_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_37_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_33_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_34_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_38_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_35_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_36_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_39_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_37_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_38_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_40_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l6_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_39_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_40_X[0]),
		.S(sram[5]),
		.X(sky130_fd_sc_hd__mux2_1_41_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size42 -----



// ----- Verilog module for mux_tree_like_tapbuf_size14 -----
module mux_tree_like_tapbuf_size14(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:13] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size14 -----



// ----- Verilog module for mux_tree_like_tapbuf_size2 -----
module mux_tree_like_tapbuf_size2(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:1] in;
//----- INPUT PORTS -----
input [0:1] sram;
//----- INPUT PORTS -----
input [0:1] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size2 -----



// ----- Verilog module for mux_tree_like_tapbuf_size15 -----
module mux_tree_like_tapbuf_size15(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:14] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size15 -----



// ----- Verilog module for mux_tree_like_tapbuf_size3 -----
module mux_tree_like_tapbuf_size3(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:2] in;
//----- INPUT PORTS -----
input [0:1] sram;
//----- INPUT PORTS -----
input [0:1] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size3 -----



// ----- Verilog module for mux_tree_like_tapbuf_size10 -----
module mux_tree_like_tapbuf_size10(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:9] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size10 -----



// ----- Verilog module for mux_tree_like_tapbuf_size9 -----
module mux_tree_like_tapbuf_size9(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:8] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size9 -----



// ----- Verilog module for mux_tree_like_tapbuf_size8 -----
module mux_tree_like_tapbuf_size8(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:7] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size8 -----



// ----- Verilog module for mux_tree_like_tapbuf_size11 -----
module mux_tree_like_tapbuf_size11(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:10] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size11 -----



// ----- Verilog module for mux_tree_like_tapbuf_size19 -----
module mux_tree_like_tapbuf_size19(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:18] in;
//----- INPUT PORTS -----
input [0:4] sram;
//----- INPUT PORTS -----
input [0:4] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_15_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_16_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_17_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_18_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_15_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_16_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_17_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_18_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_15_ (
		.A(in[15]),
		.Y(sky130_fd_sc_hd__inv_1_15_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_16_ (
		.A(in[16]),
		.Y(sky130_fd_sc_hd__inv_1_16_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_17_ (
		.A(in[17]),
		.Y(sky130_fd_sc_hd__inv_1_17_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_18_ (
		.A(in[18]),
		.Y(sky130_fd_sc_hd__inv_1_18_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_18_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_15_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_16_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_17_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_18_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_15_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_16_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_15_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_17_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_16_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_17_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_18_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size19 -----



// ----- Verilog module for mux_tree_like_tapbuf_size4 -----
module mux_tree_like_tapbuf_size4(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:3] in;
//----- INPUT PORTS -----
input [0:2] sram;
//----- INPUT PORTS -----
input [0:2] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size4 -----



// ----- Verilog module for mux_tree_like_tapbuf_size5 -----
module mux_tree_like_tapbuf_size5(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:4] in;
//----- INPUT PORTS -----
input [0:2] sram;
//----- INPUT PORTS -----
input [0:2] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size5 -----



// ----- Verilog module for mux_tree_like_tapbuf_size16 -----
module mux_tree_like_tapbuf_size16(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:15] in;
//----- INPUT PORTS -----
input [0:4] sram;
//----- INPUT PORTS -----
input [0:4] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_15_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_15_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_15_ (
		.A(in[15]),
		.Y(sky130_fd_sc_hd__inv_1_15_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_15_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_15_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_15_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size16 -----



// ----- Verilog module for mux_tree_like_tapbuf_size13 -----
module mux_tree_like_tapbuf_size13(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:12] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size13 -----



// ----- Verilog module for mux_tree_like_tapbuf_size12 -----
module mux_tree_like_tapbuf_size12(in,
                                   sram,
                                   sram_inv,
                                   out);
//----- INPUT PORTS -----
input [0:11] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size12 -----



// ----- Verilog module for mux_tree_like_tapbuf_size7 -----
module mux_tree_like_tapbuf_size7(in,
                                  sram,
                                  sram_inv,
                                  out);
//----- INPUT PORTS -----
input [0:6] in;
//----- INPUT PORTS -----
input [0:2] sram;
//----- INPUT PORTS -----
input [0:2] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__inv_4 sky130_fd_sc_hd__inv_4_0_ (
		.A(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size7 -----



// ----- Verilog module for mux_tree_like_size40 -----
module mux_tree_like_size40(in,
                            sram,
                            sram_inv,
                            out);
//----- INPUT PORTS -----
input [0:39] in;
//----- INPUT PORTS -----
input [0:5] sram;
//----- INPUT PORTS -----
input [0:5] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] const1_0_const1;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_15_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_16_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_17_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_18_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_19_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_20_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_21_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_22_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_23_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_24_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_25_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_26_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_27_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_28_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_29_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_30_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_31_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_32_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_33_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_34_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_35_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_36_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_37_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_38_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_39_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_15_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_16_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_17_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_18_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_19_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_20_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_21_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_22_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_23_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_24_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_25_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_26_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_27_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_28_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_29_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_30_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_31_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_32_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_33_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_34_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_35_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_36_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_37_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_38_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_39_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_15_ (
		.A(in[15]),
		.Y(sky130_fd_sc_hd__inv_1_15_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_16_ (
		.A(in[16]),
		.Y(sky130_fd_sc_hd__inv_1_16_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_17_ (
		.A(in[17]),
		.Y(sky130_fd_sc_hd__inv_1_17_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_18_ (
		.A(in[18]),
		.Y(sky130_fd_sc_hd__inv_1_18_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_19_ (
		.A(in[19]),
		.Y(sky130_fd_sc_hd__inv_1_19_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_20_ (
		.A(in[20]),
		.Y(sky130_fd_sc_hd__inv_1_20_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_21_ (
		.A(in[21]),
		.Y(sky130_fd_sc_hd__inv_1_21_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_22_ (
		.A(in[22]),
		.Y(sky130_fd_sc_hd__inv_1_22_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_23_ (
		.A(in[23]),
		.Y(sky130_fd_sc_hd__inv_1_23_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_24_ (
		.A(in[24]),
		.Y(sky130_fd_sc_hd__inv_1_24_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_25_ (
		.A(in[25]),
		.Y(sky130_fd_sc_hd__inv_1_25_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_26_ (
		.A(in[26]),
		.Y(sky130_fd_sc_hd__inv_1_26_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_27_ (
		.A(in[27]),
		.Y(sky130_fd_sc_hd__inv_1_27_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_28_ (
		.A(in[28]),
		.Y(sky130_fd_sc_hd__inv_1_28_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_29_ (
		.A(in[29]),
		.Y(sky130_fd_sc_hd__inv_1_29_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_30_ (
		.A(in[30]),
		.Y(sky130_fd_sc_hd__inv_1_30_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_31_ (
		.A(in[31]),
		.Y(sky130_fd_sc_hd__inv_1_31_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_32_ (
		.A(in[32]),
		.Y(sky130_fd_sc_hd__inv_1_32_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_33_ (
		.A(in[33]),
		.Y(sky130_fd_sc_hd__inv_1_33_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_34_ (
		.A(in[34]),
		.Y(sky130_fd_sc_hd__inv_1_34_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_35_ (
		.A(in[35]),
		.Y(sky130_fd_sc_hd__inv_1_35_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_36_ (
		.A(in[36]),
		.Y(sky130_fd_sc_hd__inv_1_36_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_37_ (
		.A(in[37]),
		.Y(sky130_fd_sc_hd__inv_1_37_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_38_ (
		.A(in[38]),
		.Y(sky130_fd_sc_hd__inv_1_38_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_39_ (
		.A(in[39]),
		.Y(sky130_fd_sc_hd__inv_1_39_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_40_ (
		.A(sky130_fd_sc_hd__mux2_1_39_X[0]),
		.Y(out[0]));

	const1 const1_0_ (
		.const1(const1_0_const1[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_15_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_8_ (
		.A1(sky130_fd_sc_hd__inv_1_16_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_17_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_4_ (
		.A1(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.A0(sky130_fd_sc_hd__inv_1_18_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_19_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_20_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_21_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_22_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_15_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_23_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_24_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_16_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_8_ (
		.A1(sky130_fd_sc_hd__inv_1_25_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_26_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_17_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_9_ (
		.A1(sky130_fd_sc_hd__inv_1_27_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_28_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_18_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_10_ (
		.A1(sky130_fd_sc_hd__inv_1_29_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_30_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_19_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_11_ (
		.A1(sky130_fd_sc_hd__inv_1_31_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_32_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_20_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_12_ (
		.A1(sky130_fd_sc_hd__inv_1_33_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_34_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_21_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_13_ (
		.A1(sky130_fd_sc_hd__inv_1_35_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_36_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_22_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_14_ (
		.A1(sky130_fd_sc_hd__inv_1_37_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_38_Y[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_23_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_15_ (
		.A1(sky130_fd_sc_hd__inv_1_39_Y[0]),
		.A0(const1_0_const1[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_24_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_25_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_26_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_27_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_15_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_16_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_28_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_4_ (
		.A1(sky130_fd_sc_hd__mux2_1_17_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_18_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_29_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_5_ (
		.A1(sky130_fd_sc_hd__mux2_1_19_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_20_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_30_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_6_ (
		.A1(sky130_fd_sc_hd__mux2_1_21_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_22_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_31_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_7_ (
		.A1(sky130_fd_sc_hd__mux2_1_23_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_24_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_32_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_25_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_26_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_33_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_27_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_28_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_34_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_29_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_30_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_35_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_31_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_32_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_36_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_33_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_34_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_37_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l5_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_35_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_36_X[0]),
		.S(sram[4]),
		.X(sky130_fd_sc_hd__mux2_1_38_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l6_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_37_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_38_X[0]),
		.S(sram[5]),
		.X(sky130_fd_sc_hd__mux2_1_39_X[0]));

endmodule
// ----- END Verilog module for mux_tree_like_size40 -----



// ----- Verilog module for unfrac_lut4_mux -----
module unfrac_lut4_mux(in,
                       sram,
                       sram_inv,
                       out);
//----- INPUT PORTS -----
input [0:15] in;
//----- INPUT PORTS -----
input [0:3] sram;
//----- INPUT PORTS -----
input [0:3] sram_inv;
//----- OUTPUT PORTS -----
output [0:0] out;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] sky130_fd_sc_hd__buf_1_0_X;
wire [0:0] sky130_fd_sc_hd__buf_1_1_X;
wire [0:0] sky130_fd_sc_hd__buf_1_2_X;
wire [0:0] sky130_fd_sc_hd__buf_1_3_X;
wire [0:0] sky130_fd_sc_hd__inv_1_0_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_10_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_11_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_12_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_13_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_14_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_15_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_1_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_2_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_3_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_4_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_5_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_6_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_7_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_8_Y;
wire [0:0] sky130_fd_sc_hd__inv_1_9_Y;
wire [0:0] sky130_fd_sc_hd__mux2_1_0_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_10_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_11_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_12_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_13_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_14_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_1_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_2_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_3_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_4_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_5_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_6_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_7_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_8_X;
wire [0:0] sky130_fd_sc_hd__mux2_1_9_X;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_0_ (
		.A(in[0]),
		.Y(sky130_fd_sc_hd__inv_1_0_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_1_ (
		.A(in[1]),
		.Y(sky130_fd_sc_hd__inv_1_1_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_2_ (
		.A(in[2]),
		.Y(sky130_fd_sc_hd__inv_1_2_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_3_ (
		.A(in[3]),
		.Y(sky130_fd_sc_hd__inv_1_3_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_4_ (
		.A(in[4]),
		.Y(sky130_fd_sc_hd__inv_1_4_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_5_ (
		.A(in[5]),
		.Y(sky130_fd_sc_hd__inv_1_5_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_6_ (
		.A(in[6]),
		.Y(sky130_fd_sc_hd__inv_1_6_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_7_ (
		.A(in[7]),
		.Y(sky130_fd_sc_hd__inv_1_7_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_8_ (
		.A(in[8]),
		.Y(sky130_fd_sc_hd__inv_1_8_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_9_ (
		.A(in[9]),
		.Y(sky130_fd_sc_hd__inv_1_9_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_10_ (
		.A(in[10]),
		.Y(sky130_fd_sc_hd__inv_1_10_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_11_ (
		.A(in[11]),
		.Y(sky130_fd_sc_hd__inv_1_11_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_12_ (
		.A(in[12]),
		.Y(sky130_fd_sc_hd__inv_1_12_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_13_ (
		.A(in[13]),
		.Y(sky130_fd_sc_hd__inv_1_13_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_14_ (
		.A(in[14]),
		.Y(sky130_fd_sc_hd__inv_1_14_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_15_ (
		.A(in[15]),
		.Y(sky130_fd_sc_hd__inv_1_15_Y[0]));

	sky130_fd_sc_hd__inv_1 sky130_fd_sc_hd__inv_1_16_ (
		.A(sky130_fd_sc_hd__mux2_1_14_X[0]),
		.Y(out[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_0_ (
		.A1(sky130_fd_sc_hd__inv_1_0_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_1_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_0_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_1_ (
		.A1(sky130_fd_sc_hd__inv_1_2_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_3_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_1_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_2_ (
		.A1(sky130_fd_sc_hd__inv_1_4_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_5_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_2_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_3_ (
		.A1(sky130_fd_sc_hd__inv_1_6_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_7_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_3_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_4_ (
		.A1(sky130_fd_sc_hd__inv_1_8_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_9_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_4_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_5_ (
		.A1(sky130_fd_sc_hd__inv_1_10_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_11_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_5_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_6_ (
		.A1(sky130_fd_sc_hd__inv_1_12_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_13_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_6_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l1_in_7_ (
		.A1(sky130_fd_sc_hd__inv_1_14_Y[0]),
		.A0(sky130_fd_sc_hd__inv_1_15_Y[0]),
		.S(sram[0]),
		.X(sky130_fd_sc_hd__mux2_1_7_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_0_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_1_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_8_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_1_ (
		.A1(sky130_fd_sc_hd__mux2_1_2_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_3_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_9_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_2_ (
		.A1(sky130_fd_sc_hd__mux2_1_4_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_5_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_10_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l2_in_3_ (
		.A1(sky130_fd_sc_hd__mux2_1_6_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_7_X[0]),
		.S(sram[1]),
		.X(sky130_fd_sc_hd__mux2_1_11_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_0_ (
		.A1(sky130_fd_sc_hd__buf_1_0_X[0]),
		.A0(sky130_fd_sc_hd__buf_1_1_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_12_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l3_in_1_ (
		.A1(sky130_fd_sc_hd__buf_1_2_X[0]),
		.A0(sky130_fd_sc_hd__buf_1_3_X[0]),
		.S(sram[2]),
		.X(sky130_fd_sc_hd__mux2_1_13_X[0]));

	sky130_fd_sc_hd__mux2_1 mux_l4_in_0_ (
		.A1(sky130_fd_sc_hd__mux2_1_12_X[0]),
		.A0(sky130_fd_sc_hd__mux2_1_13_X[0]),
		.S(sram[3]),
		.X(sky130_fd_sc_hd__mux2_1_14_X[0]));

	sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_1_0_ (
		.A(sky130_fd_sc_hd__mux2_1_8_X[0]),
		.X(sky130_fd_sc_hd__buf_1_0_X[0]));

	sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_1_1_ (
		.A(sky130_fd_sc_hd__mux2_1_9_X[0]),
		.X(sky130_fd_sc_hd__buf_1_1_X[0]));

	sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_1_2_ (
		.A(sky130_fd_sc_hd__mux2_1_10_X[0]),
		.X(sky130_fd_sc_hd__buf_1_2_X[0]));

	sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_1_3_ (
		.A(sky130_fd_sc_hd__mux2_1_11_X[0]),
		.X(sky130_fd_sc_hd__buf_1_3_X[0]));

endmodule
// ----- END Verilog module for unfrac_lut4_mux -----



