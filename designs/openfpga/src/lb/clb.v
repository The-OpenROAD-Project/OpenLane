//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for physical block: clb]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ---- BEGIN Sub-module of physical block:clb ----
// ----- Verilog module for grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4 -----
module grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4(pReset,
                                                               prog_clk,
                                                               lut4_in,
                                                               ccff_head,
                                                               lut4_out,
                                                               ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:3] lut4_in;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] lut4_out;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
wire [0:3] lut4_in;
wire [0:0] lut4_out;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] ccff_head;
wire [0:0] ccff_tail;
wire [0:15] unfrac_lut4_0_sram;
wire [0:15] unfrac_lut4_0_sram_inv;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	unfrac_lut4 unfrac_lut4_0_ (
		.in(lut4_in[0:3]),
		.sram(unfrac_lut4_0_sram[0:15]),
		.sram_inv(unfrac_lut4_0_sram_inv[0:15]),
		.out(lut4_out[0]));

	unfrac_lut4_scs8hd_dfrbp_1_mem unfrac_lut4_scs8hd_dfrbp_1_mem (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(unfrac_lut4_0_sram[0:15]),
		.mem_outb(unfrac_lut4_0_sram_inv[0:15]));

endmodule
// ----- END Verilog module for grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4 -----



// ----- BEGIN Physical programmable logic block Verilog module: logic -----
// ----- Verilog module for grid_clb_mode_clb__fle_mode_fle__logic -----
module grid_clb_mode_clb__fle_mode_fle__logic(pReset,
                                              prog_clk,
                                              logic_in,
                                              ccff_head,
                                              logic_out,
                                              ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:3] logic_in;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] logic_out;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
wire [0:3] logic_in;
wire [0:0] logic_out;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] ccff_head;
wire [0:0] ccff_tail;
wire [0:0] direct_interc_1_out;
wire [0:0] direct_interc_2_out;
wire [0:0] direct_interc_3_out;
wire [0:0] direct_interc_4_out;
wire [0:0] grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4_0_lut4_out;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4 grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.lut4_in({direct_interc_1_out[0], direct_interc_2_out[0], direct_interc_3_out[0], direct_interc_4_out[0]}),
		.ccff_head(ccff_head[0]),
		.lut4_out(grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4_0_lut4_out[0]),
		.ccff_tail(ccff_tail[0]));

	direct_interc direct_interc_0_ (
		.in(grid_clb_mode_clb__fle_mode_fle__logic_mode_logic__lut4_0_lut4_out[0]),
		.out(logic_out[0]));

	direct_interc direct_interc_1_ (
		.in(logic_in[0]),
		.out(direct_interc_1_out[0]));

	direct_interc direct_interc_2_ (
		.in(logic_in[1]),
		.out(direct_interc_2_out[0]));

	direct_interc direct_interc_3_ (
		.in(logic_in[2]),
		.out(direct_interc_3_out[0]));

	direct_interc direct_interc_4_ (
		.in(logic_in[3]),
		.out(direct_interc_4_out[0]));

endmodule
// ----- END Verilog module for grid_clb_mode_clb__fle_mode_fle__logic -----


// ----- END Physical programmable logic block Verilog module: logic -----

// ----- Verilog module for grid_clb_mode_clb__fle_mode_fle__ff_phy -----
module grid_clb_mode_clb__fle_mode_fle__ff_phy(reset,
                                               clk,
                                               ff_phy_D,
                                               ff_phy_Q,
                                               ff_phy_clk);
//----- GLOBAL PORTS -----
input [0:0] reset;
//----- GLOBAL PORTS -----
input [0:0] clk;
//----- INPUT PORTS -----
input [0:0] ff_phy_D;
//----- OUTPUT PORTS -----
output [0:0] ff_phy_Q;
//----- CLOCK PORTS -----
input [0:0] ff_phy_clk;

//----- BEGIN wire-connection ports -----
wire [0:0] ff_phy_D;
wire [0:0] ff_phy_Q;
wire [0:0] ff_phy_clk;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	scs8hd_dfrtp_1 scs8hd_dfrtp_1_0_ (
		.RESETB(reset[0]),
		.CLK(clk[0]),
		.D(ff_phy_D[0]),
		.Q(ff_phy_Q[0]));

endmodule
// ----- END Verilog module for grid_clb_mode_clb__fle_mode_fle__ff_phy -----



// ----- BEGIN Physical programmable logic block Verilog module: fle -----
// ----- Verilog module for grid_clb_mode_clb__fle -----
module grid_clb_mode_clb__fle(pReset,
                              prog_clk,
                              reset,
                              clk,
                              fle_in,
                              fle_clk,
                              ccff_head,
                              fle_out,
                              ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- GLOBAL PORTS -----
input [0:0] reset;
//----- GLOBAL PORTS -----
input [0:0] clk;
//----- INPUT PORTS -----
input [0:3] fle_in;
//----- INPUT PORTS -----
input [0:0] fle_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] fle_out;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
wire [0:3] fle_in;
wire [0:0] fle_clk;
wire [0:0] fle_out;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] direct_interc_0_out;
wire [0:0] direct_interc_1_out;
wire [0:0] direct_interc_2_out;
wire [0:0] direct_interc_3_out;
wire [0:0] direct_interc_4_out;
wire [0:0] direct_interc_5_out;
wire [0:0] grid_clb_mode_clb__fle_mode_fle__ff_phy_0_ff_phy_Q;
wire [0:0] grid_clb_mode_clb__fle_mode_fle__logic_0_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_mode_fle__logic_0_logic_out;
wire [0:1] mux_tree_like_tapbuf_size2_0_sram;
wire [0:1] mux_tree_like_tapbuf_size2_0_sram_inv;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	grid_clb_mode_clb__fle_mode_fle__logic grid_clb_mode_clb__fle_mode_fle__logic_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.logic_in({direct_interc_0_out[0], direct_interc_1_out[0], direct_interc_2_out[0], direct_interc_3_out[0]}),
		.ccff_head(ccff_head[0]),
		.logic_out(grid_clb_mode_clb__fle_mode_fle__logic_0_logic_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_mode_fle__logic_0_ccff_tail[0]));

	grid_clb_mode_clb__fle_mode_fle__ff_phy grid_clb_mode_clb__fle_mode_fle__ff_phy_0 (
		.reset(reset[0]),
		.clk(clk[0]),
		.ff_phy_D(direct_interc_4_out[0]),
		.ff_phy_Q(grid_clb_mode_clb__fle_mode_fle__ff_phy_0_ff_phy_Q[0]),
		.ff_phy_clk(direct_interc_5_out[0]));

	mux_tree_like_tapbuf_size2 mux_fle_out_0 (
		.in({grid_clb_mode_clb__fle_mode_fle__ff_phy_0_ff_phy_Q[0], grid_clb_mode_clb__fle_mode_fle__logic_0_logic_out[0]}),
		.sram(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]),
		.out(fle_out[0]));

	mux_tree_like_tapbuf_size2_mem mem_fle_out_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(grid_clb_mode_clb__fle_mode_fle__logic_0_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]));

	direct_interc direct_interc_0_ (
		.in(fle_in[0]),
		.out(direct_interc_0_out[0]));

	direct_interc direct_interc_1_ (
		.in(fle_in[1]),
		.out(direct_interc_1_out[0]));

	direct_interc direct_interc_2_ (
		.in(fle_in[2]),
		.out(direct_interc_2_out[0]));

	direct_interc direct_interc_3_ (
		.in(fle_in[3]),
		.out(direct_interc_3_out[0]));

	direct_interc direct_interc_4_ (
		.in(grid_clb_mode_clb__fle_mode_fle__logic_0_logic_out[0]),
		.out(direct_interc_4_out[0]));

	direct_interc direct_interc_5_ (
		.in(fle_clk[0]),
		.out(direct_interc_5_out[0]));

endmodule
// ----- END Verilog module for grid_clb_mode_clb__fle -----


// ----- END Physical programmable logic block Verilog module: fle -----

// ----- BEGIN Physical programmable logic block Verilog module: clb -----
// ----- Verilog module for grid_clb_mode_clb_ -----
module grid_clb_mode_clb_(pReset,
                          prog_clk,
                          reset,
                          clk,
                          clb_I,
                          clb_clk,
                          ccff_head,
                          clb_O,
                          ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- GLOBAL PORTS -----
input [0:0] reset;
//----- GLOBAL PORTS -----
input [0:0] clk;
//----- INPUT PORTS -----
input [0:29] clb_I;
//----- INPUT PORTS -----
input [0:0] clb_clk;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:9] clb_O;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
wire [0:29] clb_I;
wire [0:0] clb_clk;
wire [0:9] clb_O;
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:0] direct_interc_10_out;
wire [0:0] direct_interc_11_out;
wire [0:0] direct_interc_12_out;
wire [0:0] direct_interc_13_out;
wire [0:0] direct_interc_14_out;
wire [0:0] direct_interc_15_out;
wire [0:0] direct_interc_16_out;
wire [0:0] direct_interc_17_out;
wire [0:0] direct_interc_18_out;
wire [0:0] direct_interc_19_out;
wire [0:0] grid_clb_mode_clb__fle_0_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_0_fle_out;
wire [0:0] grid_clb_mode_clb__fle_1_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_1_fle_out;
wire [0:0] grid_clb_mode_clb__fle_2_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_2_fle_out;
wire [0:0] grid_clb_mode_clb__fle_3_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_3_fle_out;
wire [0:0] grid_clb_mode_clb__fle_4_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_4_fle_out;
wire [0:0] grid_clb_mode_clb__fle_5_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_5_fle_out;
wire [0:0] grid_clb_mode_clb__fle_6_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_6_fle_out;
wire [0:0] grid_clb_mode_clb__fle_7_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_7_fle_out;
wire [0:0] grid_clb_mode_clb__fle_8_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_8_fle_out;
wire [0:0] grid_clb_mode_clb__fle_9_ccff_tail;
wire [0:0] grid_clb_mode_clb__fle_9_fle_out;
wire [0:0] mux_tree_like_size40_0_out;
wire [0:5] mux_tree_like_size40_0_sram;
wire [0:5] mux_tree_like_size40_0_sram_inv;
wire [0:0] mux_tree_like_size40_10_out;
wire [0:5] mux_tree_like_size40_10_sram;
wire [0:5] mux_tree_like_size40_10_sram_inv;
wire [0:0] mux_tree_like_size40_11_out;
wire [0:5] mux_tree_like_size40_11_sram;
wire [0:5] mux_tree_like_size40_11_sram_inv;
wire [0:0] mux_tree_like_size40_12_out;
wire [0:5] mux_tree_like_size40_12_sram;
wire [0:5] mux_tree_like_size40_12_sram_inv;
wire [0:0] mux_tree_like_size40_13_out;
wire [0:5] mux_tree_like_size40_13_sram;
wire [0:5] mux_tree_like_size40_13_sram_inv;
wire [0:0] mux_tree_like_size40_14_out;
wire [0:5] mux_tree_like_size40_14_sram;
wire [0:5] mux_tree_like_size40_14_sram_inv;
wire [0:0] mux_tree_like_size40_15_out;
wire [0:5] mux_tree_like_size40_15_sram;
wire [0:5] mux_tree_like_size40_15_sram_inv;
wire [0:0] mux_tree_like_size40_16_out;
wire [0:5] mux_tree_like_size40_16_sram;
wire [0:5] mux_tree_like_size40_16_sram_inv;
wire [0:0] mux_tree_like_size40_17_out;
wire [0:5] mux_tree_like_size40_17_sram;
wire [0:5] mux_tree_like_size40_17_sram_inv;
wire [0:0] mux_tree_like_size40_18_out;
wire [0:5] mux_tree_like_size40_18_sram;
wire [0:5] mux_tree_like_size40_18_sram_inv;
wire [0:0] mux_tree_like_size40_19_out;
wire [0:5] mux_tree_like_size40_19_sram;
wire [0:5] mux_tree_like_size40_19_sram_inv;
wire [0:0] mux_tree_like_size40_1_out;
wire [0:5] mux_tree_like_size40_1_sram;
wire [0:5] mux_tree_like_size40_1_sram_inv;
wire [0:0] mux_tree_like_size40_20_out;
wire [0:5] mux_tree_like_size40_20_sram;
wire [0:5] mux_tree_like_size40_20_sram_inv;
wire [0:0] mux_tree_like_size40_21_out;
wire [0:5] mux_tree_like_size40_21_sram;
wire [0:5] mux_tree_like_size40_21_sram_inv;
wire [0:0] mux_tree_like_size40_22_out;
wire [0:5] mux_tree_like_size40_22_sram;
wire [0:5] mux_tree_like_size40_22_sram_inv;
wire [0:0] mux_tree_like_size40_23_out;
wire [0:5] mux_tree_like_size40_23_sram;
wire [0:5] mux_tree_like_size40_23_sram_inv;
wire [0:0] mux_tree_like_size40_24_out;
wire [0:5] mux_tree_like_size40_24_sram;
wire [0:5] mux_tree_like_size40_24_sram_inv;
wire [0:0] mux_tree_like_size40_25_out;
wire [0:5] mux_tree_like_size40_25_sram;
wire [0:5] mux_tree_like_size40_25_sram_inv;
wire [0:0] mux_tree_like_size40_26_out;
wire [0:5] mux_tree_like_size40_26_sram;
wire [0:5] mux_tree_like_size40_26_sram_inv;
wire [0:0] mux_tree_like_size40_27_out;
wire [0:5] mux_tree_like_size40_27_sram;
wire [0:5] mux_tree_like_size40_27_sram_inv;
wire [0:0] mux_tree_like_size40_28_out;
wire [0:5] mux_tree_like_size40_28_sram;
wire [0:5] mux_tree_like_size40_28_sram_inv;
wire [0:0] mux_tree_like_size40_29_out;
wire [0:5] mux_tree_like_size40_29_sram;
wire [0:5] mux_tree_like_size40_29_sram_inv;
wire [0:0] mux_tree_like_size40_2_out;
wire [0:5] mux_tree_like_size40_2_sram;
wire [0:5] mux_tree_like_size40_2_sram_inv;
wire [0:0] mux_tree_like_size40_30_out;
wire [0:5] mux_tree_like_size40_30_sram;
wire [0:5] mux_tree_like_size40_30_sram_inv;
wire [0:0] mux_tree_like_size40_31_out;
wire [0:5] mux_tree_like_size40_31_sram;
wire [0:5] mux_tree_like_size40_31_sram_inv;
wire [0:0] mux_tree_like_size40_32_out;
wire [0:5] mux_tree_like_size40_32_sram;
wire [0:5] mux_tree_like_size40_32_sram_inv;
wire [0:0] mux_tree_like_size40_33_out;
wire [0:5] mux_tree_like_size40_33_sram;
wire [0:5] mux_tree_like_size40_33_sram_inv;
wire [0:0] mux_tree_like_size40_34_out;
wire [0:5] mux_tree_like_size40_34_sram;
wire [0:5] mux_tree_like_size40_34_sram_inv;
wire [0:0] mux_tree_like_size40_35_out;
wire [0:5] mux_tree_like_size40_35_sram;
wire [0:5] mux_tree_like_size40_35_sram_inv;
wire [0:0] mux_tree_like_size40_36_out;
wire [0:5] mux_tree_like_size40_36_sram;
wire [0:5] mux_tree_like_size40_36_sram_inv;
wire [0:0] mux_tree_like_size40_37_out;
wire [0:5] mux_tree_like_size40_37_sram;
wire [0:5] mux_tree_like_size40_37_sram_inv;
wire [0:0] mux_tree_like_size40_38_out;
wire [0:5] mux_tree_like_size40_38_sram;
wire [0:5] mux_tree_like_size40_38_sram_inv;
wire [0:0] mux_tree_like_size40_39_out;
wire [0:5] mux_tree_like_size40_39_sram;
wire [0:5] mux_tree_like_size40_39_sram_inv;
wire [0:0] mux_tree_like_size40_3_out;
wire [0:5] mux_tree_like_size40_3_sram;
wire [0:5] mux_tree_like_size40_3_sram_inv;
wire [0:0] mux_tree_like_size40_4_out;
wire [0:5] mux_tree_like_size40_4_sram;
wire [0:5] mux_tree_like_size40_4_sram_inv;
wire [0:0] mux_tree_like_size40_5_out;
wire [0:5] mux_tree_like_size40_5_sram;
wire [0:5] mux_tree_like_size40_5_sram_inv;
wire [0:0] mux_tree_like_size40_6_out;
wire [0:5] mux_tree_like_size40_6_sram;
wire [0:5] mux_tree_like_size40_6_sram_inv;
wire [0:0] mux_tree_like_size40_7_out;
wire [0:5] mux_tree_like_size40_7_sram;
wire [0:5] mux_tree_like_size40_7_sram_inv;
wire [0:0] mux_tree_like_size40_8_out;
wire [0:5] mux_tree_like_size40_8_sram;
wire [0:5] mux_tree_like_size40_8_sram_inv;
wire [0:0] mux_tree_like_size40_9_out;
wire [0:5] mux_tree_like_size40_9_sram;
wire [0:5] mux_tree_like_size40_9_sram_inv;
wire [0:0] mux_tree_like_size40_mem_0_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_10_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_11_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_12_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_13_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_14_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_15_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_16_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_17_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_18_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_19_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_1_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_20_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_21_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_22_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_23_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_24_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_25_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_26_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_27_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_28_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_29_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_2_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_30_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_31_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_32_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_33_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_34_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_35_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_36_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_37_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_38_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_3_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_4_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_5_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_6_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_7_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_8_ccff_tail;
wire [0:0] mux_tree_like_size40_mem_9_ccff_tail;

// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_0_out[0], mux_tree_like_size40_1_out[0], mux_tree_like_size40_2_out[0], mux_tree_like_size40_3_out[0]}),
		.fle_clk(direct_interc_10_out[0]),
		.ccff_head(ccff_head[0]),
		.fle_out(grid_clb_mode_clb__fle_0_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_0_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_4_out[0], mux_tree_like_size40_5_out[0], mux_tree_like_size40_6_out[0], mux_tree_like_size40_7_out[0]}),
		.fle_clk(direct_interc_11_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_0_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_1_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_1_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_8_out[0], mux_tree_like_size40_9_out[0], mux_tree_like_size40_10_out[0], mux_tree_like_size40_11_out[0]}),
		.fle_clk(direct_interc_12_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_1_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_2_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_2_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_12_out[0], mux_tree_like_size40_13_out[0], mux_tree_like_size40_14_out[0], mux_tree_like_size40_15_out[0]}),
		.fle_clk(direct_interc_13_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_2_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_3_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_3_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_4 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_16_out[0], mux_tree_like_size40_17_out[0], mux_tree_like_size40_18_out[0], mux_tree_like_size40_19_out[0]}),
		.fle_clk(direct_interc_14_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_3_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_4_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_4_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_5 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_20_out[0], mux_tree_like_size40_21_out[0], mux_tree_like_size40_22_out[0], mux_tree_like_size40_23_out[0]}),
		.fle_clk(direct_interc_15_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_4_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_5_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_5_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_6 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_24_out[0], mux_tree_like_size40_25_out[0], mux_tree_like_size40_26_out[0], mux_tree_like_size40_27_out[0]}),
		.fle_clk(direct_interc_16_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_5_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_6_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_6_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_7 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_28_out[0], mux_tree_like_size40_29_out[0], mux_tree_like_size40_30_out[0], mux_tree_like_size40_31_out[0]}),
		.fle_clk(direct_interc_17_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_6_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_7_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_7_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_8 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_32_out[0], mux_tree_like_size40_33_out[0], mux_tree_like_size40_34_out[0], mux_tree_like_size40_35_out[0]}),
		.fle_clk(direct_interc_18_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_7_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_8_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_8_ccff_tail[0]));

	grid_clb_mode_clb__fle grid_clb_mode_clb__fle_9 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.fle_in({mux_tree_like_size40_36_out[0], mux_tree_like_size40_37_out[0], mux_tree_like_size40_38_out[0], mux_tree_like_size40_39_out[0]}),
		.fle_clk(direct_interc_19_out[0]),
		.ccff_head(grid_clb_mode_clb__fle_8_ccff_tail[0]),
		.fle_out(grid_clb_mode_clb__fle_9_fle_out[0]),
		.ccff_tail(grid_clb_mode_clb__fle_9_ccff_tail[0]));

	direct_interc direct_interc_0_ (
		.in(grid_clb_mode_clb__fle_0_fle_out[0]),
		.out(clb_O[0]));

	direct_interc direct_interc_1_ (
		.in(grid_clb_mode_clb__fle_1_fle_out[0]),
		.out(clb_O[1]));

	direct_interc direct_interc_2_ (
		.in(grid_clb_mode_clb__fle_2_fle_out[0]),
		.out(clb_O[2]));

	direct_interc direct_interc_3_ (
		.in(grid_clb_mode_clb__fle_3_fle_out[0]),
		.out(clb_O[3]));

	direct_interc direct_interc_4_ (
		.in(grid_clb_mode_clb__fle_4_fle_out[0]),
		.out(clb_O[4]));

	direct_interc direct_interc_5_ (
		.in(grid_clb_mode_clb__fle_5_fle_out[0]),
		.out(clb_O[5]));

	direct_interc direct_interc_6_ (
		.in(grid_clb_mode_clb__fle_6_fle_out[0]),
		.out(clb_O[6]));

	direct_interc direct_interc_7_ (
		.in(grid_clb_mode_clb__fle_7_fle_out[0]),
		.out(clb_O[7]));

	direct_interc direct_interc_8_ (
		.in(grid_clb_mode_clb__fle_8_fle_out[0]),
		.out(clb_O[8]));

	direct_interc direct_interc_9_ (
		.in(grid_clb_mode_clb__fle_9_fle_out[0]),
		.out(clb_O[9]));

	direct_interc direct_interc_10_ (
		.in(clb_clk[0]),
		.out(direct_interc_10_out[0]));

	direct_interc direct_interc_11_ (
		.in(clb_clk[0]),
		.out(direct_interc_11_out[0]));

	direct_interc direct_interc_12_ (
		.in(clb_clk[0]),
		.out(direct_interc_12_out[0]));

	direct_interc direct_interc_13_ (
		.in(clb_clk[0]),
		.out(direct_interc_13_out[0]));

	direct_interc direct_interc_14_ (
		.in(clb_clk[0]),
		.out(direct_interc_14_out[0]));

	direct_interc direct_interc_15_ (
		.in(clb_clk[0]),
		.out(direct_interc_15_out[0]));

	direct_interc direct_interc_16_ (
		.in(clb_clk[0]),
		.out(direct_interc_16_out[0]));

	direct_interc direct_interc_17_ (
		.in(clb_clk[0]),
		.out(direct_interc_17_out[0]));

	direct_interc direct_interc_18_ (
		.in(clb_clk[0]),
		.out(direct_interc_18_out[0]));

	direct_interc direct_interc_19_ (
		.in(clb_clk[0]),
		.out(direct_interc_19_out[0]));

	mux_tree_like_size40 mux_fle_0_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_0_sram[0:5]),
		.sram_inv(mux_tree_like_size40_0_sram_inv[0:5]),
		.out(mux_tree_like_size40_0_out[0]));

	mux_tree_like_size40 mux_fle_0_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_1_sram[0:5]),
		.sram_inv(mux_tree_like_size40_1_sram_inv[0:5]),
		.out(mux_tree_like_size40_1_out[0]));

	mux_tree_like_size40 mux_fle_0_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_2_sram[0:5]),
		.sram_inv(mux_tree_like_size40_2_sram_inv[0:5]),
		.out(mux_tree_like_size40_2_out[0]));

	mux_tree_like_size40 mux_fle_0_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_3_sram[0:5]),
		.sram_inv(mux_tree_like_size40_3_sram_inv[0:5]),
		.out(mux_tree_like_size40_3_out[0]));

	mux_tree_like_size40 mux_fle_1_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_4_sram[0:5]),
		.sram_inv(mux_tree_like_size40_4_sram_inv[0:5]),
		.out(mux_tree_like_size40_4_out[0]));

	mux_tree_like_size40 mux_fle_1_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_5_sram[0:5]),
		.sram_inv(mux_tree_like_size40_5_sram_inv[0:5]),
		.out(mux_tree_like_size40_5_out[0]));

	mux_tree_like_size40 mux_fle_1_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_6_sram[0:5]),
		.sram_inv(mux_tree_like_size40_6_sram_inv[0:5]),
		.out(mux_tree_like_size40_6_out[0]));

	mux_tree_like_size40 mux_fle_1_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_7_sram[0:5]),
		.sram_inv(mux_tree_like_size40_7_sram_inv[0:5]),
		.out(mux_tree_like_size40_7_out[0]));

	mux_tree_like_size40 mux_fle_2_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_8_sram[0:5]),
		.sram_inv(mux_tree_like_size40_8_sram_inv[0:5]),
		.out(mux_tree_like_size40_8_out[0]));

	mux_tree_like_size40 mux_fle_2_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_9_sram[0:5]),
		.sram_inv(mux_tree_like_size40_9_sram_inv[0:5]),
		.out(mux_tree_like_size40_9_out[0]));

	mux_tree_like_size40 mux_fle_2_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_10_sram[0:5]),
		.sram_inv(mux_tree_like_size40_10_sram_inv[0:5]),
		.out(mux_tree_like_size40_10_out[0]));

	mux_tree_like_size40 mux_fle_2_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_11_sram[0:5]),
		.sram_inv(mux_tree_like_size40_11_sram_inv[0:5]),
		.out(mux_tree_like_size40_11_out[0]));

	mux_tree_like_size40 mux_fle_3_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_12_sram[0:5]),
		.sram_inv(mux_tree_like_size40_12_sram_inv[0:5]),
		.out(mux_tree_like_size40_12_out[0]));

	mux_tree_like_size40 mux_fle_3_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_13_sram[0:5]),
		.sram_inv(mux_tree_like_size40_13_sram_inv[0:5]),
		.out(mux_tree_like_size40_13_out[0]));

	mux_tree_like_size40 mux_fle_3_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_14_sram[0:5]),
		.sram_inv(mux_tree_like_size40_14_sram_inv[0:5]),
		.out(mux_tree_like_size40_14_out[0]));

	mux_tree_like_size40 mux_fle_3_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_15_sram[0:5]),
		.sram_inv(mux_tree_like_size40_15_sram_inv[0:5]),
		.out(mux_tree_like_size40_15_out[0]));

	mux_tree_like_size40 mux_fle_4_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_16_sram[0:5]),
		.sram_inv(mux_tree_like_size40_16_sram_inv[0:5]),
		.out(mux_tree_like_size40_16_out[0]));

	mux_tree_like_size40 mux_fle_4_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_17_sram[0:5]),
		.sram_inv(mux_tree_like_size40_17_sram_inv[0:5]),
		.out(mux_tree_like_size40_17_out[0]));

	mux_tree_like_size40 mux_fle_4_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_18_sram[0:5]),
		.sram_inv(mux_tree_like_size40_18_sram_inv[0:5]),
		.out(mux_tree_like_size40_18_out[0]));

	mux_tree_like_size40 mux_fle_4_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_19_sram[0:5]),
		.sram_inv(mux_tree_like_size40_19_sram_inv[0:5]),
		.out(mux_tree_like_size40_19_out[0]));

	mux_tree_like_size40 mux_fle_5_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_20_sram[0:5]),
		.sram_inv(mux_tree_like_size40_20_sram_inv[0:5]),
		.out(mux_tree_like_size40_20_out[0]));

	mux_tree_like_size40 mux_fle_5_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_21_sram[0:5]),
		.sram_inv(mux_tree_like_size40_21_sram_inv[0:5]),
		.out(mux_tree_like_size40_21_out[0]));

	mux_tree_like_size40 mux_fle_5_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_22_sram[0:5]),
		.sram_inv(mux_tree_like_size40_22_sram_inv[0:5]),
		.out(mux_tree_like_size40_22_out[0]));

	mux_tree_like_size40 mux_fle_5_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_23_sram[0:5]),
		.sram_inv(mux_tree_like_size40_23_sram_inv[0:5]),
		.out(mux_tree_like_size40_23_out[0]));

	mux_tree_like_size40 mux_fle_6_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_24_sram[0:5]),
		.sram_inv(mux_tree_like_size40_24_sram_inv[0:5]),
		.out(mux_tree_like_size40_24_out[0]));

	mux_tree_like_size40 mux_fle_6_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_25_sram[0:5]),
		.sram_inv(mux_tree_like_size40_25_sram_inv[0:5]),
		.out(mux_tree_like_size40_25_out[0]));

	mux_tree_like_size40 mux_fle_6_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_26_sram[0:5]),
		.sram_inv(mux_tree_like_size40_26_sram_inv[0:5]),
		.out(mux_tree_like_size40_26_out[0]));

	mux_tree_like_size40 mux_fle_6_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_27_sram[0:5]),
		.sram_inv(mux_tree_like_size40_27_sram_inv[0:5]),
		.out(mux_tree_like_size40_27_out[0]));

	mux_tree_like_size40 mux_fle_7_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_28_sram[0:5]),
		.sram_inv(mux_tree_like_size40_28_sram_inv[0:5]),
		.out(mux_tree_like_size40_28_out[0]));

	mux_tree_like_size40 mux_fle_7_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_29_sram[0:5]),
		.sram_inv(mux_tree_like_size40_29_sram_inv[0:5]),
		.out(mux_tree_like_size40_29_out[0]));

	mux_tree_like_size40 mux_fle_7_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_30_sram[0:5]),
		.sram_inv(mux_tree_like_size40_30_sram_inv[0:5]),
		.out(mux_tree_like_size40_30_out[0]));

	mux_tree_like_size40 mux_fle_7_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_31_sram[0:5]),
		.sram_inv(mux_tree_like_size40_31_sram_inv[0:5]),
		.out(mux_tree_like_size40_31_out[0]));

	mux_tree_like_size40 mux_fle_8_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_32_sram[0:5]),
		.sram_inv(mux_tree_like_size40_32_sram_inv[0:5]),
		.out(mux_tree_like_size40_32_out[0]));

	mux_tree_like_size40 mux_fle_8_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_33_sram[0:5]),
		.sram_inv(mux_tree_like_size40_33_sram_inv[0:5]),
		.out(mux_tree_like_size40_33_out[0]));

	mux_tree_like_size40 mux_fle_8_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_34_sram[0:5]),
		.sram_inv(mux_tree_like_size40_34_sram_inv[0:5]),
		.out(mux_tree_like_size40_34_out[0]));

	mux_tree_like_size40 mux_fle_8_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_35_sram[0:5]),
		.sram_inv(mux_tree_like_size40_35_sram_inv[0:5]),
		.out(mux_tree_like_size40_35_out[0]));

	mux_tree_like_size40 mux_fle_9_in_0 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_36_sram[0:5]),
		.sram_inv(mux_tree_like_size40_36_sram_inv[0:5]),
		.out(mux_tree_like_size40_36_out[0]));

	mux_tree_like_size40 mux_fle_9_in_1 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_37_sram[0:5]),
		.sram_inv(mux_tree_like_size40_37_sram_inv[0:5]),
		.out(mux_tree_like_size40_37_out[0]));

	mux_tree_like_size40 mux_fle_9_in_2 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_38_sram[0:5]),
		.sram_inv(mux_tree_like_size40_38_sram_inv[0:5]),
		.out(mux_tree_like_size40_38_out[0]));

	mux_tree_like_size40 mux_fle_9_in_3 (
		.in({clb_I[0:29], grid_clb_mode_clb__fle_0_fle_out[0], grid_clb_mode_clb__fle_1_fle_out[0], grid_clb_mode_clb__fle_2_fle_out[0], grid_clb_mode_clb__fle_3_fle_out[0], grid_clb_mode_clb__fle_4_fle_out[0], grid_clb_mode_clb__fle_5_fle_out[0], grid_clb_mode_clb__fle_6_fle_out[0], grid_clb_mode_clb__fle_7_fle_out[0], grid_clb_mode_clb__fle_8_fle_out[0], grid_clb_mode_clb__fle_9_fle_out[0]}),
		.sram(mux_tree_like_size40_39_sram[0:5]),
		.sram_inv(mux_tree_like_size40_39_sram_inv[0:5]),
		.out(mux_tree_like_size40_39_out[0]));

	mux_tree_like_size40_mem mem_fle_0_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(grid_clb_mode_clb__fle_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_0_sram[0:5]),
		.mem_outb(mux_tree_like_size40_0_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_0_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_1_sram[0:5]),
		.mem_outb(mux_tree_like_size40_1_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_0_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_2_sram[0:5]),
		.mem_outb(mux_tree_like_size40_2_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_0_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_3_sram[0:5]),
		.mem_outb(mux_tree_like_size40_3_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_1_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_4_sram[0:5]),
		.mem_outb(mux_tree_like_size40_4_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_1_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_5_sram[0:5]),
		.mem_outb(mux_tree_like_size40_5_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_1_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_6_sram[0:5]),
		.mem_outb(mux_tree_like_size40_6_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_1_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_7_sram[0:5]),
		.mem_outb(mux_tree_like_size40_7_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_2_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_8_sram[0:5]),
		.mem_outb(mux_tree_like_size40_8_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_2_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_9_sram[0:5]),
		.mem_outb(mux_tree_like_size40_9_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_2_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_10_sram[0:5]),
		.mem_outb(mux_tree_like_size40_10_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_2_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_11_sram[0:5]),
		.mem_outb(mux_tree_like_size40_11_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_3_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_12_sram[0:5]),
		.mem_outb(mux_tree_like_size40_12_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_3_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_13_sram[0:5]),
		.mem_outb(mux_tree_like_size40_13_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_3_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_14_sram[0:5]),
		.mem_outb(mux_tree_like_size40_14_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_3_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_15_sram[0:5]),
		.mem_outb(mux_tree_like_size40_15_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_4_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_16_sram[0:5]),
		.mem_outb(mux_tree_like_size40_16_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_4_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_17_sram[0:5]),
		.mem_outb(mux_tree_like_size40_17_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_4_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_18_sram[0:5]),
		.mem_outb(mux_tree_like_size40_18_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_4_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_18_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_19_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_19_sram[0:5]),
		.mem_outb(mux_tree_like_size40_19_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_5_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_19_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_20_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_20_sram[0:5]),
		.mem_outb(mux_tree_like_size40_20_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_5_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_20_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_21_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_21_sram[0:5]),
		.mem_outb(mux_tree_like_size40_21_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_5_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_21_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_22_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_22_sram[0:5]),
		.mem_outb(mux_tree_like_size40_22_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_5_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_22_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_23_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_23_sram[0:5]),
		.mem_outb(mux_tree_like_size40_23_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_6_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_23_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_24_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_24_sram[0:5]),
		.mem_outb(mux_tree_like_size40_24_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_6_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_24_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_25_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_25_sram[0:5]),
		.mem_outb(mux_tree_like_size40_25_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_6_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_25_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_26_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_26_sram[0:5]),
		.mem_outb(mux_tree_like_size40_26_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_6_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_26_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_27_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_27_sram[0:5]),
		.mem_outb(mux_tree_like_size40_27_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_7_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_27_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_28_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_28_sram[0:5]),
		.mem_outb(mux_tree_like_size40_28_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_7_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_28_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_29_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_29_sram[0:5]),
		.mem_outb(mux_tree_like_size40_29_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_7_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_29_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_30_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_30_sram[0:5]),
		.mem_outb(mux_tree_like_size40_30_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_7_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_30_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_31_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_31_sram[0:5]),
		.mem_outb(mux_tree_like_size40_31_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_8_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_31_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_32_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_32_sram[0:5]),
		.mem_outb(mux_tree_like_size40_32_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_8_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_32_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_33_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_33_sram[0:5]),
		.mem_outb(mux_tree_like_size40_33_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_8_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_33_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_34_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_34_sram[0:5]),
		.mem_outb(mux_tree_like_size40_34_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_8_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_34_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_35_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_35_sram[0:5]),
		.mem_outb(mux_tree_like_size40_35_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_9_in_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_35_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_36_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_36_sram[0:5]),
		.mem_outb(mux_tree_like_size40_36_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_9_in_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_36_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_37_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_37_sram[0:5]),
		.mem_outb(mux_tree_like_size40_37_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_9_in_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_37_ccff_tail[0]),
		.ccff_tail(mux_tree_like_size40_mem_38_ccff_tail[0]),
		.mem_out(mux_tree_like_size40_38_sram[0:5]),
		.mem_outb(mux_tree_like_size40_38_sram_inv[0:5]));

	mux_tree_like_size40_mem mem_fle_9_in_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_size40_mem_38_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_size40_39_sram[0:5]),
		.mem_outb(mux_tree_like_size40_39_sram_inv[0:5]));

endmodule
// ----- END Verilog module for grid_clb_mode_clb_ -----


// ----- END Physical programmable logic block Verilog module: clb -----

// ---- END Sub-module of physical block:clb ----
// ----- BEGIN Grid Verilog module: grid_clb -----
// ----- Verilog module for grid_clb -----
module grid_clb(pReset,
                prog_clk,
                reset,
                clk,
                top_height_0__pin_40_,
                right_height_0__pin_0_,
                right_height_0__pin_1_,
                right_height_0__pin_2_,
                right_height_0__pin_3_,
                right_height_0__pin_4_,
                right_height_0__pin_5_,
                right_height_0__pin_6_,
                right_height_0__pin_7_,
                right_height_0__pin_8_,
                right_height_0__pin_9_,
                right_height_0__pin_10_,
                right_height_0__pin_11_,
                right_height_0__pin_12_,
                right_height_0__pin_13_,
                right_height_0__pin_14_,
                bottom_height_0__pin_15_,
                bottom_height_0__pin_16_,
                bottom_height_0__pin_17_,
                bottom_height_0__pin_18_,
                bottom_height_0__pin_19_,
                bottom_height_0__pin_20_,
                bottom_height_0__pin_21_,
                bottom_height_0__pin_22_,
                bottom_height_0__pin_23_,
                bottom_height_0__pin_24_,
                bottom_height_0__pin_25_,
                bottom_height_0__pin_26_,
                bottom_height_0__pin_27_,
                bottom_height_0__pin_28_,
                bottom_height_0__pin_29_,
                ccff_head,
                right_height_0_pin_30_upper,
                right_height_0_pin_30_lower,
                right_height_0_pin_31_upper,
                right_height_0_pin_31_lower,
                right_height_0_pin_32_upper,
                right_height_0_pin_32_lower,
                right_height_0_pin_33_upper,
                right_height_0_pin_33_lower,
                right_height_0_pin_34_upper,
                right_height_0_pin_34_lower,
                bottom_height_0_pin_35_upper,
                bottom_height_0_pin_35_lower,
                bottom_height_0_pin_36_upper,
                bottom_height_0_pin_36_lower,
                bottom_height_0_pin_37_upper,
                bottom_height_0_pin_37_lower,
                bottom_height_0_pin_38_upper,
                bottom_height_0_pin_38_lower,
                bottom_height_0_pin_39_upper,
                bottom_height_0_pin_39_lower,
                ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- GLOBAL PORTS -----
input [0:0] reset;
//----- GLOBAL PORTS -----
input [0:0] clk;
//----- INPUT PORTS -----
input [0:0] top_height_0__pin_40_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_0_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_1_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_2_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_3_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_4_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_5_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_6_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_7_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_8_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_9_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_10_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_11_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_12_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_13_;
//----- INPUT PORTS -----
input [0:0] right_height_0__pin_14_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_15_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_16_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_17_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_18_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_19_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_20_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_21_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_22_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_23_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_24_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_25_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_26_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_27_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_28_;
//----- INPUT PORTS -----
input [0:0] bottom_height_0__pin_29_;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_30_upper;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_30_lower;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_31_upper;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_31_lower;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_32_upper;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_32_lower;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_33_upper;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_33_lower;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_34_upper;
//----- OUTPUT PORTS -----
output [0:0] right_height_0_pin_34_lower;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_35_upper;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_35_lower;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_36_upper;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_36_lower;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_37_upper;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_37_lower;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_38_upper;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_38_lower;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_39_upper;
//----- OUTPUT PORTS -----
output [0:0] bottom_height_0_pin_39_lower;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----



// ----- BEGIN Local short connections -----
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
	assign right_height_0_pin_30_lower[0] = right_height_0_pin_30_upper[0];
	assign right_height_0_pin_31_lower[0] = right_height_0_pin_31_upper[0];
	assign right_height_0_pin_32_lower[0] = right_height_0_pin_32_upper[0];
	assign right_height_0_pin_33_lower[0] = right_height_0_pin_33_upper[0];
	assign right_height_0_pin_34_lower[0] = right_height_0_pin_34_upper[0];
	assign bottom_height_0_pin_35_lower[0] = bottom_height_0_pin_35_upper[0];
	assign bottom_height_0_pin_36_lower[0] = bottom_height_0_pin_36_upper[0];
	assign bottom_height_0_pin_37_lower[0] = bottom_height_0_pin_37_upper[0];
	assign bottom_height_0_pin_38_lower[0] = bottom_height_0_pin_38_upper[0];
	assign bottom_height_0_pin_39_lower[0] = bottom_height_0_pin_39_upper[0];
// ----- END Local output short connections -----

	grid_clb_mode_clb_ grid_clb_mode_clb__0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.reset(reset[0]),
		.clk(clk[0]),
		.clb_I({right_height_0__pin_0_[0], right_height_0__pin_1_[0], right_height_0__pin_2_[0], right_height_0__pin_3_[0], right_height_0__pin_4_[0], right_height_0__pin_5_[0], right_height_0__pin_6_[0], right_height_0__pin_7_[0], right_height_0__pin_8_[0], right_height_0__pin_9_[0], right_height_0__pin_10_[0], right_height_0__pin_11_[0], right_height_0__pin_12_[0], right_height_0__pin_13_[0], right_height_0__pin_14_[0], bottom_height_0__pin_15_[0], bottom_height_0__pin_16_[0], bottom_height_0__pin_17_[0], bottom_height_0__pin_18_[0], bottom_height_0__pin_19_[0], bottom_height_0__pin_20_[0], bottom_height_0__pin_21_[0], bottom_height_0__pin_22_[0], bottom_height_0__pin_23_[0], bottom_height_0__pin_24_[0], bottom_height_0__pin_25_[0], bottom_height_0__pin_26_[0], bottom_height_0__pin_27_[0], bottom_height_0__pin_28_[0], bottom_height_0__pin_29_[0]}),
		.clb_clk(top_height_0__pin_40_[0]),
		.ccff_head(ccff_head[0]),
		.clb_O({right_height_0_pin_30_upper[0], right_height_0_pin_31_upper[0], right_height_0_pin_32_upper[0], right_height_0_pin_33_upper[0], right_height_0_pin_34_upper[0], bottom_height_0_pin_35_upper[0], bottom_height_0_pin_36_upper[0], bottom_height_0_pin_37_upper[0], bottom_height_0_pin_38_upper[0], bottom_height_0_pin_39_upper[0]}),
		.ccff_tail(ccff_tail[0]));

endmodule
// ----- END Verilog module for grid_clb -----


// ----- END Grid Verilog module: grid_clb -----

