//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Header file to include other Verilog netlists
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "routing/sb_0_0.v"
`include "routing/sb_0_1.v"
`include "routing/sb_0_22.v"
`include "routing/sb_1_0.v"
`include "routing/sb_1_1.v"
`include "routing/sb_1_22.v"
`include "routing/sb_22_0.v"
`include "routing/sb_22_1.v"
`include "routing/sb_22_22.v"
`include "routing/cbx_1_0.v"
`include "routing/cbx_1_1.v"
`include "routing/cbx_1_22.v"
`include "routing/cby_0_1.v"
`include "routing/cby_1_1.v"
`include "routing/cby_22_1.v"
