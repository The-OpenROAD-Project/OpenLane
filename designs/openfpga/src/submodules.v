//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Header file to include other Verilog netlists
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "submodules/inv_buf_passgate.v"
`include "submodules/local_encoder.v"
`include "submodules/muxes.v"
`include "submodules/luts.v"
`include "submodules/wires.v"
`include "submodules/memories.v"
