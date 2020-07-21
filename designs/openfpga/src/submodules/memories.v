//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Memories used in FPGA
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for mux_tree_like_tapbuf_size42_mem -----
module mux_tree_like_tapbuf_size42_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:5] mem_out;
//----- OUTPUT PORTS -----
output [0:5] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[5];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_4_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[3]),
		.Q(mem_out[4]),
		.QN(mem_outb[4]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_5_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[4]),
		.Q(mem_out[5]),
		.QN(mem_outb[5]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size42_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size14_mem -----
module mux_tree_like_tapbuf_size14_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size14_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size2_mem -----
module mux_tree_like_tapbuf_size2_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:1] mem_out;
//----- OUTPUT PORTS -----
output [0:1] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[1];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size2_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size15_mem -----
module mux_tree_like_tapbuf_size15_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size15_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size3_mem -----
module mux_tree_like_tapbuf_size3_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:1] mem_out;
//----- OUTPUT PORTS -----
output [0:1] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[1];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size3_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size10_mem -----
module mux_tree_like_tapbuf_size10_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size10_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size9_mem -----
module mux_tree_like_tapbuf_size9_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size9_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size8_mem -----
module mux_tree_like_tapbuf_size8_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size8_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size11_mem -----
module mux_tree_like_tapbuf_size11_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size11_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size19_mem -----
module mux_tree_like_tapbuf_size19_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:4] mem_out;
//----- OUTPUT PORTS -----
output [0:4] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[4];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_4_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[3]),
		.Q(mem_out[4]),
		.QN(mem_outb[4]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size19_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size4_mem -----
module mux_tree_like_tapbuf_size4_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:2] mem_out;
//----- OUTPUT PORTS -----
output [0:2] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[2];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size4_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size5_mem -----
module mux_tree_like_tapbuf_size5_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:2] mem_out;
//----- OUTPUT PORTS -----
output [0:2] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[2];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size5_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size16_mem -----
module mux_tree_like_tapbuf_size16_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:4] mem_out;
//----- OUTPUT PORTS -----
output [0:4] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[4];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_4_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[3]),
		.Q(mem_out[4]),
		.QN(mem_outb[4]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size16_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size13_mem -----
module mux_tree_like_tapbuf_size13_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size13_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size12_mem -----
module mux_tree_like_tapbuf_size12_mem(pReset,
                                       prog_clk,
                                       ccff_head,
                                       ccff_tail,
                                       mem_out,
                                       mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:3] mem_out;
//----- OUTPUT PORTS -----
output [0:3] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[3];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size12_mem -----



// ----- Verilog module for mux_tree_like_tapbuf_size7_mem -----
module mux_tree_like_tapbuf_size7_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:2] mem_out;
//----- OUTPUT PORTS -----
output [0:2] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[2];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

endmodule
// ----- END Verilog module for mux_tree_like_tapbuf_size7_mem -----



// ----- Verilog module for mux_tree_like_size40_mem -----
module mux_tree_like_size40_mem(pReset,
                                prog_clk,
                                ccff_head,
                                ccff_tail,
                                mem_out,
                                mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:5] mem_out;
//----- OUTPUT PORTS -----
output [0:5] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[5];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_4_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[3]),
		.Q(mem_out[4]),
		.QN(mem_outb[4]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_5_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[4]),
		.Q(mem_out[5]),
		.QN(mem_outb[5]));

endmodule
// ----- END Verilog module for mux_tree_like_size40_mem -----



// ----- Verilog module for unfrac_lut4_sky130_fd_sc_hd__dfrbp_1_mem -----
module unfrac_lut4_sky130_fd_sc_hd__dfrbp_1_mem(pReset,
                                      prog_clk,
                                      ccff_head,
                                      ccff_tail,
                                      mem_out,
                                      mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:15] mem_out;
//----- OUTPUT PORTS -----
output [0:15] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[15];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_1_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[0]),
		.Q(mem_out[1]),
		.QN(mem_outb[1]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_2_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[1]),
		.Q(mem_out[2]),
		.QN(mem_outb[2]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_3_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[2]),
		.Q(mem_out[3]),
		.QN(mem_outb[3]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_4_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[3]),
		.Q(mem_out[4]),
		.QN(mem_outb[4]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_5_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[4]),
		.Q(mem_out[5]),
		.QN(mem_outb[5]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_6_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[5]),
		.Q(mem_out[6]),
		.QN(mem_outb[6]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_7_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[6]),
		.Q(mem_out[7]),
		.QN(mem_outb[7]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_8_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[7]),
		.Q(mem_out[8]),
		.QN(mem_outb[8]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_9_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[8]),
		.Q(mem_out[9]),
		.QN(mem_outb[9]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_10_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[9]),
		.Q(mem_out[10]),
		.QN(mem_outb[10]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_11_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[10]),
		.Q(mem_out[11]),
		.QN(mem_outb[11]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_12_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[11]),
		.Q(mem_out[12]),
		.QN(mem_outb[12]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_13_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[12]),
		.Q(mem_out[13]),
		.QN(mem_outb[13]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_14_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[13]),
		.Q(mem_out[14]),
		.QN(mem_outb[14]));

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_15_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(mem_out[14]),
		.Q(mem_out[15]),
		.QN(mem_outb[15]));

endmodule
// ----- END Verilog module for unfrac_lut4_sky130_fd_sc_hd__dfrbp_1_mem -----



// ----- Verilog module for iopad_sky130_fd_sc_hd__dfrbp_1_mem -----
module iopad_sky130_fd_sc_hd__dfrbp_1_mem(pReset,
                                prog_clk,
                                ccff_head,
                                ccff_tail,
                                mem_out,
                                mem_outb);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;
//----- OUTPUT PORTS -----
output [0:0] mem_out;
//----- OUTPUT PORTS -----
output [0:0] mem_outb;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign ccff_tail[0] = mem_out[0];
// ----- END Local output short connections -----

	sky130_fd_sc_hd__dfrbp_1 sky130_fd_sc_hd__dfrbp_1_0_ (
		.RESETB(pReset[0]),
		.CLK(prog_clk[0]),
		.D(ccff_head[0]),
		.Q(mem_out[0]),
		.QN(mem_outb[0]));

endmodule
// ----- END Verilog module for iopad_sky130_fd_sc_hd__dfrbp_1_mem -----



