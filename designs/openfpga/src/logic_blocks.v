//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Header file to include other Verilog netlists
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "./lb/io_top.v"
`include "./lb/io_right.v"
`include "./lb/io_bottom.v"
`include "./lb/io_left.v"
`include "./lb/clb.v"
