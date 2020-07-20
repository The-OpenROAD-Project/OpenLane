//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Preprocessing flags to enable/disable features in FPGA Verilog modules
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:37:05 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`define ENABLE_TIMING 1

`define ENABLE_SIGNAL_INITIALIZATION 1

`define ENABLE_FORMAL_VERIFICATION 1

//`define ICARUS_SIMULATOR 1

