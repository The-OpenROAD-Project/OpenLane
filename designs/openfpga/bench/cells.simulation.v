//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Netlist Summary
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:44:02 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_inv_1.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_buf_4.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_inv_4.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_inv_2.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_buf_2.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_buf_1.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_mux2_1.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_or2_1.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_dfrtp_1.v"
`include "/openLANE_flow/pdks/ef-skywater-s8/EFS8A/libs.ref/verilog/scs8hd/scs8hd_dfrbp_1.v"

