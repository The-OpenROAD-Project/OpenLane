//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for Unique Switch Blocks[0][0]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for sb_0__0_ -----
module sb_0__0_(pReset,
                prog_clk,
                chany_top_in_1_,
                chany_top_in_3_,
                chany_top_in_5_,
                chany_top_in_7_,
                chany_top_in_9_,
                chany_top_in_11_,
                chany_top_in_13_,
                chany_top_in_15_,
                chany_top_in_17_,
                chany_top_in_19_,
                chany_top_in_21_,
                chany_top_in_23_,
                chany_top_in_25_,
                chany_top_in_27_,
                chany_top_in_29_,
                chany_top_in_31_,
                chany_top_in_33_,
                chany_top_in_35_,
                chany_top_in_37_,
                chany_top_in_39_,
                chany_top_in_41_,
                chany_top_in_43_,
                chany_top_in_45_,
                chany_top_in_47_,
                chany_top_in_49_,
                chany_top_in_51_,
                chany_top_in_53_,
                chany_top_in_55_,
                chany_top_in_57_,
                chany_top_in_59_,
                chany_top_in_61_,
                chany_top_in_63_,
                chany_top_in_65_,
                chany_top_in_67_,
                chany_top_in_69_,
                chany_top_in_71_,
                chany_top_in_73_,
                chany_top_in_75_,
                chany_top_in_77_,
                chany_top_in_79_,
                chany_top_in_81_,
                chany_top_in_83_,
                chany_top_in_85_,
                chany_top_in_87_,
                chany_top_in_89_,
                chany_top_in_91_,
                chany_top_in_93_,
                chany_top_in_95_,
                chany_top_in_97_,
                chany_top_in_99_,
                chany_top_in_101_,
                chany_top_in_103_,
                chany_top_in_105_,
                chany_top_in_107_,
                chany_top_in_109_,
                chany_top_in_111_,
                chany_top_in_113_,
                chany_top_in_115_,
                chany_top_in_117_,
                chany_top_in_119_,
                top_left_grid_pin_1_,
                chanx_right_in_1_,
                chanx_right_in_3_,
                chanx_right_in_5_,
                chanx_right_in_7_,
                chanx_right_in_9_,
                chanx_right_in_11_,
                chanx_right_in_13_,
                chanx_right_in_15_,
                chanx_right_in_17_,
                chanx_right_in_19_,
                chanx_right_in_21_,
                chanx_right_in_23_,
                chanx_right_in_25_,
                chanx_right_in_27_,
                chanx_right_in_29_,
                chanx_right_in_31_,
                chanx_right_in_33_,
                chanx_right_in_35_,
                chanx_right_in_37_,
                chanx_right_in_39_,
                chanx_right_in_41_,
                chanx_right_in_43_,
                chanx_right_in_45_,
                chanx_right_in_47_,
                chanx_right_in_49_,
                chanx_right_in_51_,
                chanx_right_in_53_,
                chanx_right_in_55_,
                chanx_right_in_57_,
                chanx_right_in_59_,
                chanx_right_in_61_,
                chanx_right_in_63_,
                chanx_right_in_65_,
                chanx_right_in_67_,
                chanx_right_in_69_,
                chanx_right_in_71_,
                chanx_right_in_73_,
                chanx_right_in_75_,
                chanx_right_in_77_,
                chanx_right_in_79_,
                chanx_right_in_81_,
                chanx_right_in_83_,
                chanx_right_in_85_,
                chanx_right_in_87_,
                chanx_right_in_89_,
                chanx_right_in_91_,
                chanx_right_in_93_,
                chanx_right_in_95_,
                chanx_right_in_97_,
                chanx_right_in_99_,
                chanx_right_in_101_,
                chanx_right_in_103_,
                chanx_right_in_105_,
                chanx_right_in_107_,
                chanx_right_in_109_,
                chanx_right_in_111_,
                chanx_right_in_113_,
                chanx_right_in_115_,
                chanx_right_in_117_,
                chanx_right_in_119_,
                right_top_grid_pin_35_,
                right_top_grid_pin_36_,
                right_top_grid_pin_37_,
                right_top_grid_pin_38_,
                right_top_grid_pin_39_,
                right_bottom_grid_pin_1_,
                ccff_head,
                chany_top_out_0_,
                chany_top_out_2_,
                chany_top_out_4_,
                chany_top_out_6_,
                chany_top_out_8_,
                chany_top_out_10_,
                chany_top_out_12_,
                chany_top_out_14_,
                chany_top_out_16_,
                chany_top_out_18_,
                chany_top_out_20_,
                chany_top_out_22_,
                chany_top_out_24_,
                chany_top_out_26_,
                chany_top_out_28_,
                chany_top_out_30_,
                chany_top_out_32_,
                chany_top_out_34_,
                chany_top_out_36_,
                chany_top_out_38_,
                chany_top_out_40_,
                chany_top_out_42_,
                chany_top_out_44_,
                chany_top_out_46_,
                chany_top_out_48_,
                chany_top_out_50_,
                chany_top_out_52_,
                chany_top_out_54_,
                chany_top_out_56_,
                chany_top_out_58_,
                chany_top_out_60_,
                chany_top_out_62_,
                chany_top_out_64_,
                chany_top_out_66_,
                chany_top_out_68_,
                chany_top_out_70_,
                chany_top_out_72_,
                chany_top_out_74_,
                chany_top_out_76_,
                chany_top_out_78_,
                chany_top_out_80_,
                chany_top_out_82_,
                chany_top_out_84_,
                chany_top_out_86_,
                chany_top_out_88_,
                chany_top_out_90_,
                chany_top_out_92_,
                chany_top_out_94_,
                chany_top_out_96_,
                chany_top_out_98_,
                chany_top_out_100_,
                chany_top_out_102_,
                chany_top_out_104_,
                chany_top_out_106_,
                chany_top_out_108_,
                chany_top_out_110_,
                chany_top_out_112_,
                chany_top_out_114_,
                chany_top_out_116_,
                chany_top_out_118_,
                chanx_right_out_0_,
                chanx_right_out_2_,
                chanx_right_out_4_,
                chanx_right_out_6_,
                chanx_right_out_8_,
                chanx_right_out_10_,
                chanx_right_out_12_,
                chanx_right_out_14_,
                chanx_right_out_16_,
                chanx_right_out_18_,
                chanx_right_out_20_,
                chanx_right_out_22_,
                chanx_right_out_24_,
                chanx_right_out_26_,
                chanx_right_out_28_,
                chanx_right_out_30_,
                chanx_right_out_32_,
                chanx_right_out_34_,
                chanx_right_out_36_,
                chanx_right_out_38_,
                chanx_right_out_40_,
                chanx_right_out_42_,
                chanx_right_out_44_,
                chanx_right_out_46_,
                chanx_right_out_48_,
                chanx_right_out_50_,
                chanx_right_out_52_,
                chanx_right_out_54_,
                chanx_right_out_56_,
                chanx_right_out_58_,
                chanx_right_out_60_,
                chanx_right_out_62_,
                chanx_right_out_64_,
                chanx_right_out_66_,
                chanx_right_out_68_,
                chanx_right_out_70_,
                chanx_right_out_72_,
                chanx_right_out_74_,
                chanx_right_out_76_,
                chanx_right_out_78_,
                chanx_right_out_80_,
                chanx_right_out_82_,
                chanx_right_out_84_,
                chanx_right_out_86_,
                chanx_right_out_88_,
                chanx_right_out_90_,
                chanx_right_out_92_,
                chanx_right_out_94_,
                chanx_right_out_96_,
                chanx_right_out_98_,
                chanx_right_out_100_,
                chanx_right_out_102_,
                chanx_right_out_104_,
                chanx_right_out_106_,
                chanx_right_out_108_,
                chanx_right_out_110_,
                chanx_right_out_112_,
                chanx_right_out_114_,
                chanx_right_out_116_,
                chanx_right_out_118_,
                ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] chany_top_in_1_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_3_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_5_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_7_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_9_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_11_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_13_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_15_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_17_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_19_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_21_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_23_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_25_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_27_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_29_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_31_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_33_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_35_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_37_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_39_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_41_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_43_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_45_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_47_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_49_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_51_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_53_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_55_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_57_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_59_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_61_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_63_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_65_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_67_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_69_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_71_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_73_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_75_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_77_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_79_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_81_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_83_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_85_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_87_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_89_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_91_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_93_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_95_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_97_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_99_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_101_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_103_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_105_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_107_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_109_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_111_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_113_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_115_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_117_;
//----- INPUT PORTS -----
input [0:0] chany_top_in_119_;
//----- INPUT PORTS -----
input [0:0] top_left_grid_pin_1_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_1_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_3_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_5_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_7_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_9_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_11_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_13_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_15_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_17_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_19_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_21_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_23_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_25_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_27_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_29_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_31_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_33_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_35_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_37_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_39_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_41_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_43_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_45_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_47_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_49_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_51_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_53_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_55_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_57_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_59_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_61_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_63_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_65_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_67_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_69_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_71_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_73_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_75_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_77_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_79_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_81_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_83_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_85_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_87_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_89_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_91_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_93_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_95_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_97_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_99_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_101_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_103_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_105_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_107_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_109_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_111_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_113_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_115_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_117_;
//----- INPUT PORTS -----
input [0:0] chanx_right_in_119_;
//----- INPUT PORTS -----
input [0:0] right_top_grid_pin_35_;
//----- INPUT PORTS -----
input [0:0] right_top_grid_pin_36_;
//----- INPUT PORTS -----
input [0:0] right_top_grid_pin_37_;
//----- INPUT PORTS -----
input [0:0] right_top_grid_pin_38_;
//----- INPUT PORTS -----
input [0:0] right_top_grid_pin_39_;
//----- INPUT PORTS -----
input [0:0] right_bottom_grid_pin_1_;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_0_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_2_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_4_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_6_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_8_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_10_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_12_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_14_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_16_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_18_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_20_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_22_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_24_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_26_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_28_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_30_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_32_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_34_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_36_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_38_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_40_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_42_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_44_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_46_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_48_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_50_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_52_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_54_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_56_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_58_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_60_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_62_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_64_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_66_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_68_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_70_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_72_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_74_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_76_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_78_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_80_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_82_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_84_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_86_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_88_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_90_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_92_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_94_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_96_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_98_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_100_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_102_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_104_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_106_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_108_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_110_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_112_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_114_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_116_;
//----- OUTPUT PORTS -----
output [0:0] chany_top_out_118_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_0_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_2_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_4_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_6_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_8_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_10_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_12_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_14_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_16_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_18_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_20_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_22_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_24_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_26_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_28_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_30_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_32_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_34_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_36_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_38_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_40_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_42_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_44_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_46_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_48_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_50_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_52_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_54_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_56_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_58_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_60_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_62_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_64_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_66_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_68_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_70_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_72_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_74_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_76_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_78_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_80_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_82_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_84_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_86_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_88_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_90_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_92_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_94_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_96_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_98_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_100_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_102_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_104_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_106_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_108_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_110_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_112_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_114_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_116_;
//----- OUTPUT PORTS -----
output [0:0] chanx_right_out_118_;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:1] mux_tree_like_tapbuf_size2_0_sram;
wire [0:1] mux_tree_like_tapbuf_size2_0_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_10_sram;
wire [0:1] mux_tree_like_tapbuf_size2_10_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_11_sram;
wire [0:1] mux_tree_like_tapbuf_size2_11_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_12_sram;
wire [0:1] mux_tree_like_tapbuf_size2_12_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_13_sram;
wire [0:1] mux_tree_like_tapbuf_size2_13_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_14_sram;
wire [0:1] mux_tree_like_tapbuf_size2_14_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_15_sram;
wire [0:1] mux_tree_like_tapbuf_size2_15_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_16_sram;
wire [0:1] mux_tree_like_tapbuf_size2_16_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_17_sram;
wire [0:1] mux_tree_like_tapbuf_size2_17_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_18_sram;
wire [0:1] mux_tree_like_tapbuf_size2_18_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_19_sram;
wire [0:1] mux_tree_like_tapbuf_size2_19_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_1_sram;
wire [0:1] mux_tree_like_tapbuf_size2_1_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_20_sram;
wire [0:1] mux_tree_like_tapbuf_size2_20_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_21_sram;
wire [0:1] mux_tree_like_tapbuf_size2_21_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_22_sram;
wire [0:1] mux_tree_like_tapbuf_size2_22_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_23_sram;
wire [0:1] mux_tree_like_tapbuf_size2_23_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_24_sram;
wire [0:1] mux_tree_like_tapbuf_size2_24_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_25_sram;
wire [0:1] mux_tree_like_tapbuf_size2_25_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_26_sram;
wire [0:1] mux_tree_like_tapbuf_size2_26_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_27_sram;
wire [0:1] mux_tree_like_tapbuf_size2_27_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_28_sram;
wire [0:1] mux_tree_like_tapbuf_size2_28_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_29_sram;
wire [0:1] mux_tree_like_tapbuf_size2_29_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_2_sram;
wire [0:1] mux_tree_like_tapbuf_size2_2_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_30_sram;
wire [0:1] mux_tree_like_tapbuf_size2_30_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_31_sram;
wire [0:1] mux_tree_like_tapbuf_size2_31_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_32_sram;
wire [0:1] mux_tree_like_tapbuf_size2_32_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_33_sram;
wire [0:1] mux_tree_like_tapbuf_size2_33_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_34_sram;
wire [0:1] mux_tree_like_tapbuf_size2_34_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_35_sram;
wire [0:1] mux_tree_like_tapbuf_size2_35_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_36_sram;
wire [0:1] mux_tree_like_tapbuf_size2_36_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_37_sram;
wire [0:1] mux_tree_like_tapbuf_size2_37_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_38_sram;
wire [0:1] mux_tree_like_tapbuf_size2_38_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_39_sram;
wire [0:1] mux_tree_like_tapbuf_size2_39_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_3_sram;
wire [0:1] mux_tree_like_tapbuf_size2_3_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_40_sram;
wire [0:1] mux_tree_like_tapbuf_size2_40_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_41_sram;
wire [0:1] mux_tree_like_tapbuf_size2_41_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_42_sram;
wire [0:1] mux_tree_like_tapbuf_size2_42_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_43_sram;
wire [0:1] mux_tree_like_tapbuf_size2_43_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_44_sram;
wire [0:1] mux_tree_like_tapbuf_size2_44_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_45_sram;
wire [0:1] mux_tree_like_tapbuf_size2_45_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_46_sram;
wire [0:1] mux_tree_like_tapbuf_size2_46_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_47_sram;
wire [0:1] mux_tree_like_tapbuf_size2_47_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_48_sram;
wire [0:1] mux_tree_like_tapbuf_size2_48_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_49_sram;
wire [0:1] mux_tree_like_tapbuf_size2_49_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_4_sram;
wire [0:1] mux_tree_like_tapbuf_size2_4_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_50_sram;
wire [0:1] mux_tree_like_tapbuf_size2_50_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_51_sram;
wire [0:1] mux_tree_like_tapbuf_size2_51_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_5_sram;
wire [0:1] mux_tree_like_tapbuf_size2_5_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_6_sram;
wire [0:1] mux_tree_like_tapbuf_size2_6_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_7_sram;
wire [0:1] mux_tree_like_tapbuf_size2_7_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_8_sram;
wire [0:1] mux_tree_like_tapbuf_size2_8_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_9_sram;
wire [0:1] mux_tree_like_tapbuf_size2_9_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size2_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_10_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_11_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_12_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_13_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_14_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_15_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_16_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_17_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_18_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_19_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_20_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_21_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_22_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_23_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_24_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_25_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_26_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_27_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_28_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_29_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_30_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_31_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_32_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_33_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_34_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_35_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_36_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_37_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_38_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_39_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_40_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_41_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_42_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_43_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_44_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_45_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_46_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_47_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_48_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_49_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_50_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_9_ccff_tail;
wire [0:1] mux_tree_like_tapbuf_size3_0_sram;
wire [0:1] mux_tree_like_tapbuf_size3_0_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_1_sram;
wire [0:1] mux_tree_like_tapbuf_size3_1_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size3_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_1_ccff_tail;

// ----- BEGIN Local short connections -----
// ----- Local connection due to Wire 5 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_12_[0] = chany_top_in_11_[0];
// ----- Local connection due to Wire 6 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_14_[0] = chany_top_in_13_[0];
// ----- Local connection due to Wire 13 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_28_[0] = chany_top_in_27_[0];
// ----- Local connection due to Wire 14 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_30_[0] = chany_top_in_29_[0];
// ----- Local connection due to Wire 21 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_44_[0] = chany_top_in_43_[0];
// ----- Local connection due to Wire 22 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_46_[0] = chany_top_in_45_[0];
// ----- Local connection due to Wire 29 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_60_[0] = chany_top_in_59_[0];
// ----- Local connection due to Wire 30 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_62_[0] = chany_top_in_61_[0];
// ----- Local connection due to Wire 37 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_76_[0] = chany_top_in_75_[0];
// ----- Local connection due to Wire 38 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_78_[0] = chany_top_in_77_[0];
// ----- Local connection due to Wire 45 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_92_[0] = chany_top_in_91_[0];
// ----- Local connection due to Wire 46 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_94_[0] = chany_top_in_93_[0];
// ----- Local connection due to Wire 53 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_108_[0] = chany_top_in_107_[0];
// ----- Local connection due to Wire 54 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_right_out_110_[0] = chany_top_in_109_[0];
// ----- Local connection due to Wire 61 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_118_[0] = chanx_right_in_1_[0];
// ----- Local connection due to Wire 63 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_2_[0] = chanx_right_in_5_[0];
// ----- Local connection due to Wire 64 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_4_[0] = chanx_right_in_7_[0];
// ----- Local connection due to Wire 65 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_6_[0] = chanx_right_in_9_[0];
// ----- Local connection due to Wire 66 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_8_[0] = chanx_right_in_11_[0];
// ----- Local connection due to Wire 67 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_10_[0] = chanx_right_in_13_[0];
// ----- Local connection due to Wire 68 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_12_[0] = chanx_right_in_15_[0];
// ----- Local connection due to Wire 69 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_14_[0] = chanx_right_in_17_[0];
// ----- Local connection due to Wire 71 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_18_[0] = chanx_right_in_21_[0];
// ----- Local connection due to Wire 72 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_20_[0] = chanx_right_in_23_[0];
// ----- Local connection due to Wire 73 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_22_[0] = chanx_right_in_25_[0];
// ----- Local connection due to Wire 74 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_24_[0] = chanx_right_in_27_[0];
// ----- Local connection due to Wire 75 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_26_[0] = chanx_right_in_29_[0];
// ----- Local connection due to Wire 76 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_28_[0] = chanx_right_in_31_[0];
// ----- Local connection due to Wire 77 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_30_[0] = chanx_right_in_33_[0];
// ----- Local connection due to Wire 79 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_34_[0] = chanx_right_in_37_[0];
// ----- Local connection due to Wire 80 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_36_[0] = chanx_right_in_39_[0];
// ----- Local connection due to Wire 81 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_38_[0] = chanx_right_in_41_[0];
// ----- Local connection due to Wire 82 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_40_[0] = chanx_right_in_43_[0];
// ----- Local connection due to Wire 83 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_42_[0] = chanx_right_in_45_[0];
// ----- Local connection due to Wire 84 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_44_[0] = chanx_right_in_47_[0];
// ----- Local connection due to Wire 85 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_46_[0] = chanx_right_in_49_[0];
// ----- Local connection due to Wire 87 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_50_[0] = chanx_right_in_53_[0];
// ----- Local connection due to Wire 88 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_52_[0] = chanx_right_in_55_[0];
// ----- Local connection due to Wire 89 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_54_[0] = chanx_right_in_57_[0];
// ----- Local connection due to Wire 90 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_56_[0] = chanx_right_in_59_[0];
// ----- Local connection due to Wire 91 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_58_[0] = chanx_right_in_61_[0];
// ----- Local connection due to Wire 92 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_60_[0] = chanx_right_in_63_[0];
// ----- Local connection due to Wire 93 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_62_[0] = chanx_right_in_65_[0];
// ----- Local connection due to Wire 95 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_66_[0] = chanx_right_in_69_[0];
// ----- Local connection due to Wire 96 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_68_[0] = chanx_right_in_71_[0];
// ----- Local connection due to Wire 97 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_70_[0] = chanx_right_in_73_[0];
// ----- Local connection due to Wire 98 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_72_[0] = chanx_right_in_75_[0];
// ----- Local connection due to Wire 99 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_74_[0] = chanx_right_in_77_[0];
// ----- Local connection due to Wire 100 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_76_[0] = chanx_right_in_79_[0];
// ----- Local connection due to Wire 101 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_78_[0] = chanx_right_in_81_[0];
// ----- Local connection due to Wire 103 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_82_[0] = chanx_right_in_85_[0];
// ----- Local connection due to Wire 104 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_84_[0] = chanx_right_in_87_[0];
// ----- Local connection due to Wire 105 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_86_[0] = chanx_right_in_89_[0];
// ----- Local connection due to Wire 106 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_88_[0] = chanx_right_in_91_[0];
// ----- Local connection due to Wire 107 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_90_[0] = chanx_right_in_93_[0];
// ----- Local connection due to Wire 108 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_92_[0] = chanx_right_in_95_[0];
// ----- Local connection due to Wire 109 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_94_[0] = chanx_right_in_97_[0];
// ----- Local connection due to Wire 111 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_98_[0] = chanx_right_in_101_[0];
// ----- Local connection due to Wire 112 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_100_[0] = chanx_right_in_103_[0];
// ----- Local connection due to Wire 113 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_102_[0] = chanx_right_in_105_[0];
// ----- Local connection due to Wire 114 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_104_[0] = chanx_right_in_107_[0];
// ----- Local connection due to Wire 115 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_106_[0] = chanx_right_in_109_[0];
// ----- Local connection due to Wire 116 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_108_[0] = chanx_right_in_111_[0];
// ----- Local connection due to Wire 117 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_110_[0] = chanx_right_in_113_[0];
// ----- Local connection due to Wire 119 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_114_[0] = chanx_right_in_117_[0];
// ----- Local connection due to Wire 120 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_116_[0] = chanx_right_in_119_[0];
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	mux_tree_like_tapbuf_size2 mux_top_track_0 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_3_[0]}),
		.sram(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]),
		.out(chany_top_out_0_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_16 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_19_[0]}),
		.sram(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]),
		.out(chany_top_out_16_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_32 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_35_[0]}),
		.sram(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]),
		.out(chany_top_out_32_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_48 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_51_[0]}),
		.sram(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]),
		.out(chany_top_out_48_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_64 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_67_[0]}),
		.sram(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]),
		.out(chany_top_out_64_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_80 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]),
		.out(chany_top_out_80_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_96 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]),
		.out(chany_top_out_96_[0]));

	mux_tree_like_tapbuf_size2 mux_top_track_112 (
		.in({top_left_grid_pin_1_[0], chanx_right_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]),
		.out(chany_top_out_112_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_0 (
		.in({right_top_grid_pin_35_[0], chany_top_in_119_[0]}),
		.sram(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]),
		.out(chanx_right_out_0_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_2 (
		.in({right_top_grid_pin_36_[0], chany_top_in_1_[0]}),
		.sram(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]),
		.out(chanx_right_out_2_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_4 (
		.in({right_top_grid_pin_37_[0], chany_top_in_3_[0]}),
		.sram(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]),
		.out(chanx_right_out_4_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_6 (
		.in({right_top_grid_pin_38_[0], chany_top_in_5_[0]}),
		.sram(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]),
		.out(chanx_right_out_6_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_8 (
		.in({right_top_grid_pin_39_[0], chany_top_in_7_[0]}),
		.sram(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]),
		.out(chanx_right_out_8_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_10 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_9_[0]}),
		.sram(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]),
		.out(chanx_right_out_10_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_20 (
		.in({right_top_grid_pin_37_[0], chany_top_in_19_[0]}),
		.sram(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]),
		.out(chanx_right_out_20_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_22 (
		.in({right_top_grid_pin_38_[0], chany_top_in_21_[0]}),
		.sram(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]),
		.out(chanx_right_out_22_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_24 (
		.in({right_top_grid_pin_39_[0], chany_top_in_23_[0]}),
		.sram(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]),
		.out(chanx_right_out_24_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_26 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_25_[0]}),
		.sram(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]),
		.out(chanx_right_out_26_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_32 (
		.in({right_top_grid_pin_35_[0], chany_top_in_31_[0]}),
		.sram(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]),
		.out(chanx_right_out_32_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_34 (
		.in({right_top_grid_pin_36_[0], chany_top_in_33_[0]}),
		.sram(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]),
		.out(chanx_right_out_34_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_36 (
		.in({right_top_grid_pin_37_[0], chany_top_in_35_[0]}),
		.sram(mux_tree_like_tapbuf_size2_20_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_20_sram_inv[0:1]),
		.out(chanx_right_out_36_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_38 (
		.in({right_top_grid_pin_38_[0], chany_top_in_37_[0]}),
		.sram(mux_tree_like_tapbuf_size2_21_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_21_sram_inv[0:1]),
		.out(chanx_right_out_38_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_40 (
		.in({right_top_grid_pin_39_[0], chany_top_in_39_[0]}),
		.sram(mux_tree_like_tapbuf_size2_22_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_22_sram_inv[0:1]),
		.out(chanx_right_out_40_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_42 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_41_[0]}),
		.sram(mux_tree_like_tapbuf_size2_23_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_23_sram_inv[0:1]),
		.out(chanx_right_out_42_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_48 (
		.in({right_top_grid_pin_35_[0], chany_top_in_47_[0]}),
		.sram(mux_tree_like_tapbuf_size2_24_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_24_sram_inv[0:1]),
		.out(chanx_right_out_48_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_50 (
		.in({right_top_grid_pin_36_[0], chany_top_in_49_[0]}),
		.sram(mux_tree_like_tapbuf_size2_25_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_25_sram_inv[0:1]),
		.out(chanx_right_out_50_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_52 (
		.in({right_top_grid_pin_37_[0], chany_top_in_51_[0]}),
		.sram(mux_tree_like_tapbuf_size2_26_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_26_sram_inv[0:1]),
		.out(chanx_right_out_52_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_54 (
		.in({right_top_grid_pin_38_[0], chany_top_in_53_[0]}),
		.sram(mux_tree_like_tapbuf_size2_27_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_27_sram_inv[0:1]),
		.out(chanx_right_out_54_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_56 (
		.in({right_top_grid_pin_39_[0], chany_top_in_55_[0]}),
		.sram(mux_tree_like_tapbuf_size2_28_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_28_sram_inv[0:1]),
		.out(chanx_right_out_56_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_58 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_57_[0]}),
		.sram(mux_tree_like_tapbuf_size2_29_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_29_sram_inv[0:1]),
		.out(chanx_right_out_58_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_64 (
		.in({right_top_grid_pin_35_[0], chany_top_in_63_[0]}),
		.sram(mux_tree_like_tapbuf_size2_30_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_30_sram_inv[0:1]),
		.out(chanx_right_out_64_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_66 (
		.in({right_top_grid_pin_36_[0], chany_top_in_65_[0]}),
		.sram(mux_tree_like_tapbuf_size2_31_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_31_sram_inv[0:1]),
		.out(chanx_right_out_66_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_68 (
		.in({right_top_grid_pin_37_[0], chany_top_in_67_[0]}),
		.sram(mux_tree_like_tapbuf_size2_32_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_32_sram_inv[0:1]),
		.out(chanx_right_out_68_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_70 (
		.in({right_top_grid_pin_38_[0], chany_top_in_69_[0]}),
		.sram(mux_tree_like_tapbuf_size2_33_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_33_sram_inv[0:1]),
		.out(chanx_right_out_70_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_72 (
		.in({right_top_grid_pin_39_[0], chany_top_in_71_[0]}),
		.sram(mux_tree_like_tapbuf_size2_34_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_34_sram_inv[0:1]),
		.out(chanx_right_out_72_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_74 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_73_[0]}),
		.sram(mux_tree_like_tapbuf_size2_35_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_35_sram_inv[0:1]),
		.out(chanx_right_out_74_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_80 (
		.in({right_top_grid_pin_35_[0], chany_top_in_79_[0]}),
		.sram(mux_tree_like_tapbuf_size2_36_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_36_sram_inv[0:1]),
		.out(chanx_right_out_80_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_82 (
		.in({right_top_grid_pin_36_[0], chany_top_in_81_[0]}),
		.sram(mux_tree_like_tapbuf_size2_37_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_37_sram_inv[0:1]),
		.out(chanx_right_out_82_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_84 (
		.in({right_top_grid_pin_37_[0], chany_top_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size2_38_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_38_sram_inv[0:1]),
		.out(chanx_right_out_84_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_86 (
		.in({right_top_grid_pin_38_[0], chany_top_in_85_[0]}),
		.sram(mux_tree_like_tapbuf_size2_39_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_39_sram_inv[0:1]),
		.out(chanx_right_out_86_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_88 (
		.in({right_top_grid_pin_39_[0], chany_top_in_87_[0]}),
		.sram(mux_tree_like_tapbuf_size2_40_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_40_sram_inv[0:1]),
		.out(chanx_right_out_88_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_90 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size2_41_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_41_sram_inv[0:1]),
		.out(chanx_right_out_90_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_96 (
		.in({right_top_grid_pin_35_[0], chany_top_in_95_[0]}),
		.sram(mux_tree_like_tapbuf_size2_42_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_42_sram_inv[0:1]),
		.out(chanx_right_out_96_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_98 (
		.in({right_top_grid_pin_36_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size2_43_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_43_sram_inv[0:1]),
		.out(chanx_right_out_98_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_100 (
		.in({right_top_grid_pin_37_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size2_44_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_44_sram_inv[0:1]),
		.out(chanx_right_out_100_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_102 (
		.in({right_top_grid_pin_38_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size2_45_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_45_sram_inv[0:1]),
		.out(chanx_right_out_102_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_104 (
		.in({right_top_grid_pin_39_[0], chany_top_in_103_[0]}),
		.sram(mux_tree_like_tapbuf_size2_46_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_46_sram_inv[0:1]),
		.out(chanx_right_out_104_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_106 (
		.in({right_bottom_grid_pin_1_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size2_47_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_47_sram_inv[0:1]),
		.out(chanx_right_out_106_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_112 (
		.in({right_top_grid_pin_35_[0], chany_top_in_111_[0]}),
		.sram(mux_tree_like_tapbuf_size2_48_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_48_sram_inv[0:1]),
		.out(chanx_right_out_112_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_114 (
		.in({right_top_grid_pin_36_[0], chany_top_in_113_[0]}),
		.sram(mux_tree_like_tapbuf_size2_49_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_49_sram_inv[0:1]),
		.out(chanx_right_out_114_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_116 (
		.in({right_top_grid_pin_37_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size2_50_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_50_sram_inv[0:1]),
		.out(chanx_right_out_116_[0]));

	mux_tree_like_tapbuf_size2 mux_right_track_118 (
		.in({right_top_grid_pin_38_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size2_51_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_51_sram_inv[0:1]),
		.out(chanx_right_out_118_[0]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_16 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_32 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_48 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_64 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_80 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_96 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_top_track_112 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_2 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_4 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_6 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_8 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_10 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_20 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_22 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_24 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_26 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_32 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_34 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_19_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_36 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_19_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_20_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_20_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_20_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_38 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_20_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_21_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_21_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_21_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_40 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_21_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_22_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_22_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_22_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_42 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_22_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_23_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_23_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_23_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_48 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_23_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_24_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_24_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_24_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_50 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_24_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_25_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_25_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_25_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_52 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_25_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_26_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_26_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_26_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_54 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_26_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_27_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_27_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_27_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_56 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_27_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_28_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_28_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_28_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_58 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_28_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_29_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_29_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_29_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_64 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_29_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_30_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_30_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_30_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_66 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_30_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_31_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_31_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_31_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_68 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_31_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_32_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_32_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_32_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_70 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_32_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_33_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_33_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_33_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_72 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_33_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_34_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_34_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_34_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_74 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_34_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_35_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_35_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_35_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_80 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_35_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_36_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_36_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_36_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_82 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_36_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_37_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_37_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_37_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_84 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_37_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_38_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_38_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_38_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_86 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_38_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_39_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_39_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_39_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_88 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_39_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_40_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_40_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_40_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_90 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_40_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_41_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_41_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_41_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_96 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_41_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_42_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_42_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_42_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_98 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_42_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_43_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_43_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_43_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_100 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_43_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_44_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_44_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_44_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_102 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_44_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_45_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_45_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_45_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_104 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_45_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_46_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_46_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_46_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_106 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_46_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_47_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_47_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_47_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_112 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_47_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_48_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_48_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_48_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_114 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_48_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_49_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_49_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_49_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_116 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_49_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_50_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_50_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_50_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_right_track_118 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_50_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_51_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_51_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3 mux_right_track_16 (
		.in({right_top_grid_pin_35_[0], right_top_grid_pin_39_[0], chany_top_in_15_[0]}),
		.sram(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]),
		.out(chanx_right_out_16_[0]));

	mux_tree_like_tapbuf_size3 mux_right_track_18 (
		.in({right_top_grid_pin_36_[0], right_bottom_grid_pin_1_[0], chany_top_in_17_[0]}),
		.sram(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]),
		.out(chanx_right_out_18_[0]));

	mux_tree_like_tapbuf_size3_mem mem_right_track_16 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_right_track_18 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]));

endmodule
// ----- END Verilog module for sb_0__0_ -----


