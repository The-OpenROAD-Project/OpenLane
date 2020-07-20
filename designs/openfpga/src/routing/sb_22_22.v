//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for Unique Switch Blocks[22][22]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for sb_22__22_ -----
module sb_22__22_(pReset,
                  prog_clk,
                  chany_bottom_in_0_,
                  chany_bottom_in_2_,
                  chany_bottom_in_4_,
                  chany_bottom_in_6_,
                  chany_bottom_in_8_,
                  chany_bottom_in_10_,
                  chany_bottom_in_12_,
                  chany_bottom_in_14_,
                  chany_bottom_in_16_,
                  chany_bottom_in_18_,
                  chany_bottom_in_20_,
                  chany_bottom_in_22_,
                  chany_bottom_in_24_,
                  chany_bottom_in_26_,
                  chany_bottom_in_28_,
                  chany_bottom_in_30_,
                  chany_bottom_in_32_,
                  chany_bottom_in_34_,
                  chany_bottom_in_36_,
                  chany_bottom_in_38_,
                  chany_bottom_in_40_,
                  chany_bottom_in_42_,
                  chany_bottom_in_44_,
                  chany_bottom_in_46_,
                  chany_bottom_in_48_,
                  chany_bottom_in_50_,
                  chany_bottom_in_52_,
                  chany_bottom_in_54_,
                  chany_bottom_in_56_,
                  chany_bottom_in_58_,
                  chany_bottom_in_60_,
                  chany_bottom_in_62_,
                  chany_bottom_in_64_,
                  chany_bottom_in_66_,
                  chany_bottom_in_68_,
                  chany_bottom_in_70_,
                  chany_bottom_in_72_,
                  chany_bottom_in_74_,
                  chany_bottom_in_76_,
                  chany_bottom_in_78_,
                  chany_bottom_in_80_,
                  chany_bottom_in_82_,
                  chany_bottom_in_84_,
                  chany_bottom_in_86_,
                  chany_bottom_in_88_,
                  chany_bottom_in_90_,
                  chany_bottom_in_92_,
                  chany_bottom_in_94_,
                  chany_bottom_in_96_,
                  chany_bottom_in_98_,
                  chany_bottom_in_100_,
                  chany_bottom_in_102_,
                  chany_bottom_in_104_,
                  chany_bottom_in_106_,
                  chany_bottom_in_108_,
                  chany_bottom_in_110_,
                  chany_bottom_in_112_,
                  chany_bottom_in_114_,
                  chany_bottom_in_116_,
                  chany_bottom_in_118_,
                  bottom_right_grid_pin_1_,
                  bottom_left_grid_pin_30_,
                  bottom_left_grid_pin_31_,
                  bottom_left_grid_pin_32_,
                  bottom_left_grid_pin_33_,
                  bottom_left_grid_pin_34_,
                  chanx_left_in_0_,
                  chanx_left_in_2_,
                  chanx_left_in_4_,
                  chanx_left_in_6_,
                  chanx_left_in_8_,
                  chanx_left_in_10_,
                  chanx_left_in_12_,
                  chanx_left_in_14_,
                  chanx_left_in_16_,
                  chanx_left_in_18_,
                  chanx_left_in_20_,
                  chanx_left_in_22_,
                  chanx_left_in_24_,
                  chanx_left_in_26_,
                  chanx_left_in_28_,
                  chanx_left_in_30_,
                  chanx_left_in_32_,
                  chanx_left_in_34_,
                  chanx_left_in_36_,
                  chanx_left_in_38_,
                  chanx_left_in_40_,
                  chanx_left_in_42_,
                  chanx_left_in_44_,
                  chanx_left_in_46_,
                  chanx_left_in_48_,
                  chanx_left_in_50_,
                  chanx_left_in_52_,
                  chanx_left_in_54_,
                  chanx_left_in_56_,
                  chanx_left_in_58_,
                  chanx_left_in_60_,
                  chanx_left_in_62_,
                  chanx_left_in_64_,
                  chanx_left_in_66_,
                  chanx_left_in_68_,
                  chanx_left_in_70_,
                  chanx_left_in_72_,
                  chanx_left_in_74_,
                  chanx_left_in_76_,
                  chanx_left_in_78_,
                  chanx_left_in_80_,
                  chanx_left_in_82_,
                  chanx_left_in_84_,
                  chanx_left_in_86_,
                  chanx_left_in_88_,
                  chanx_left_in_90_,
                  chanx_left_in_92_,
                  chanx_left_in_94_,
                  chanx_left_in_96_,
                  chanx_left_in_98_,
                  chanx_left_in_100_,
                  chanx_left_in_102_,
                  chanx_left_in_104_,
                  chanx_left_in_106_,
                  chanx_left_in_108_,
                  chanx_left_in_110_,
                  chanx_left_in_112_,
                  chanx_left_in_114_,
                  chanx_left_in_116_,
                  chanx_left_in_118_,
                  left_top_grid_pin_1_,
                  ccff_head,
                  chany_bottom_out_1_,
                  chany_bottom_out_3_,
                  chany_bottom_out_5_,
                  chany_bottom_out_7_,
                  chany_bottom_out_9_,
                  chany_bottom_out_11_,
                  chany_bottom_out_13_,
                  chany_bottom_out_15_,
                  chany_bottom_out_17_,
                  chany_bottom_out_19_,
                  chany_bottom_out_21_,
                  chany_bottom_out_23_,
                  chany_bottom_out_25_,
                  chany_bottom_out_27_,
                  chany_bottom_out_29_,
                  chany_bottom_out_31_,
                  chany_bottom_out_33_,
                  chany_bottom_out_35_,
                  chany_bottom_out_37_,
                  chany_bottom_out_39_,
                  chany_bottom_out_41_,
                  chany_bottom_out_43_,
                  chany_bottom_out_45_,
                  chany_bottom_out_47_,
                  chany_bottom_out_49_,
                  chany_bottom_out_51_,
                  chany_bottom_out_53_,
                  chany_bottom_out_55_,
                  chany_bottom_out_57_,
                  chany_bottom_out_59_,
                  chany_bottom_out_61_,
                  chany_bottom_out_63_,
                  chany_bottom_out_65_,
                  chany_bottom_out_67_,
                  chany_bottom_out_69_,
                  chany_bottom_out_71_,
                  chany_bottom_out_73_,
                  chany_bottom_out_75_,
                  chany_bottom_out_77_,
                  chany_bottom_out_79_,
                  chany_bottom_out_81_,
                  chany_bottom_out_83_,
                  chany_bottom_out_85_,
                  chany_bottom_out_87_,
                  chany_bottom_out_89_,
                  chany_bottom_out_91_,
                  chany_bottom_out_93_,
                  chany_bottom_out_95_,
                  chany_bottom_out_97_,
                  chany_bottom_out_99_,
                  chany_bottom_out_101_,
                  chany_bottom_out_103_,
                  chany_bottom_out_105_,
                  chany_bottom_out_107_,
                  chany_bottom_out_109_,
                  chany_bottom_out_111_,
                  chany_bottom_out_113_,
                  chany_bottom_out_115_,
                  chany_bottom_out_117_,
                  chany_bottom_out_119_,
                  chanx_left_out_1_,
                  chanx_left_out_3_,
                  chanx_left_out_5_,
                  chanx_left_out_7_,
                  chanx_left_out_9_,
                  chanx_left_out_11_,
                  chanx_left_out_13_,
                  chanx_left_out_15_,
                  chanx_left_out_17_,
                  chanx_left_out_19_,
                  chanx_left_out_21_,
                  chanx_left_out_23_,
                  chanx_left_out_25_,
                  chanx_left_out_27_,
                  chanx_left_out_29_,
                  chanx_left_out_31_,
                  chanx_left_out_33_,
                  chanx_left_out_35_,
                  chanx_left_out_37_,
                  chanx_left_out_39_,
                  chanx_left_out_41_,
                  chanx_left_out_43_,
                  chanx_left_out_45_,
                  chanx_left_out_47_,
                  chanx_left_out_49_,
                  chanx_left_out_51_,
                  chanx_left_out_53_,
                  chanx_left_out_55_,
                  chanx_left_out_57_,
                  chanx_left_out_59_,
                  chanx_left_out_61_,
                  chanx_left_out_63_,
                  chanx_left_out_65_,
                  chanx_left_out_67_,
                  chanx_left_out_69_,
                  chanx_left_out_71_,
                  chanx_left_out_73_,
                  chanx_left_out_75_,
                  chanx_left_out_77_,
                  chanx_left_out_79_,
                  chanx_left_out_81_,
                  chanx_left_out_83_,
                  chanx_left_out_85_,
                  chanx_left_out_87_,
                  chanx_left_out_89_,
                  chanx_left_out_91_,
                  chanx_left_out_93_,
                  chanx_left_out_95_,
                  chanx_left_out_97_,
                  chanx_left_out_99_,
                  chanx_left_out_101_,
                  chanx_left_out_103_,
                  chanx_left_out_105_,
                  chanx_left_out_107_,
                  chanx_left_out_109_,
                  chanx_left_out_111_,
                  chanx_left_out_113_,
                  chanx_left_out_115_,
                  chanx_left_out_117_,
                  chanx_left_out_119_,
                  ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_0_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_2_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_4_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_6_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_8_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_10_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_12_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_14_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_16_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_18_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_20_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_22_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_24_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_26_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_28_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_30_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_32_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_34_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_36_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_38_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_40_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_42_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_44_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_46_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_48_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_50_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_52_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_54_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_56_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_58_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_60_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_62_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_64_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_66_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_68_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_70_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_72_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_74_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_76_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_78_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_80_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_82_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_84_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_86_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_88_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_90_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_92_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_94_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_96_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_98_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_100_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_102_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_104_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_106_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_108_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_110_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_112_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_114_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_116_;
//----- INPUT PORTS -----
input [0:0] chany_bottom_in_118_;
//----- INPUT PORTS -----
input [0:0] bottom_right_grid_pin_1_;
//----- INPUT PORTS -----
input [0:0] bottom_left_grid_pin_30_;
//----- INPUT PORTS -----
input [0:0] bottom_left_grid_pin_31_;
//----- INPUT PORTS -----
input [0:0] bottom_left_grid_pin_32_;
//----- INPUT PORTS -----
input [0:0] bottom_left_grid_pin_33_;
//----- INPUT PORTS -----
input [0:0] bottom_left_grid_pin_34_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_0_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_2_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_4_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_6_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_8_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_10_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_12_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_14_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_16_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_18_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_20_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_22_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_24_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_26_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_28_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_30_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_32_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_34_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_36_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_38_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_40_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_42_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_44_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_46_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_48_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_50_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_52_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_54_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_56_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_58_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_60_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_62_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_64_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_66_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_68_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_70_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_72_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_74_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_76_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_78_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_80_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_82_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_84_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_86_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_88_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_90_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_92_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_94_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_96_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_98_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_100_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_102_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_104_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_106_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_108_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_110_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_112_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_114_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_116_;
//----- INPUT PORTS -----
input [0:0] chanx_left_in_118_;
//----- INPUT PORTS -----
input [0:0] left_top_grid_pin_1_;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_1_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_3_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_5_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_7_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_9_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_11_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_13_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_15_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_17_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_19_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_21_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_23_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_25_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_27_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_29_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_31_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_33_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_35_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_37_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_39_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_41_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_43_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_45_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_47_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_49_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_51_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_53_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_55_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_57_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_59_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_61_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_63_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_65_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_67_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_69_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_71_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_73_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_75_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_77_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_79_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_81_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_83_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_85_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_87_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_89_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_91_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_93_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_95_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_97_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_99_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_101_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_103_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_105_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_107_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_109_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_111_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_113_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_115_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_117_;
//----- OUTPUT PORTS -----
output [0:0] chany_bottom_out_119_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_1_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_3_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_5_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_7_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_9_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_11_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_13_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_15_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_17_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_19_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_21_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_23_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_25_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_27_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_29_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_31_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_33_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_35_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_37_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_39_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_41_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_43_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_45_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_47_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_49_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_51_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_53_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_55_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_57_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_59_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_61_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_63_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_65_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_67_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_69_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_71_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_73_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_75_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_77_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_79_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_81_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_83_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_85_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_87_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_89_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_91_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_93_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_95_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_97_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_99_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_101_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_103_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_105_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_107_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_109_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_111_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_113_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_115_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_117_;
//----- OUTPUT PORTS -----
output [0:0] chanx_left_out_119_;
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
// ----- Local connection due to Wire 0 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_3_[0] = chany_bottom_in_0_[0];
// ----- Local connection due to Wire 1 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_5_[0] = chany_bottom_in_2_[0];
// ----- Local connection due to Wire 2 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_7_[0] = chany_bottom_in_4_[0];
// ----- Local connection due to Wire 3 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_9_[0] = chany_bottom_in_6_[0];
// ----- Local connection due to Wire 4 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_11_[0] = chany_bottom_in_8_[0];
// ----- Local connection due to Wire 5 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_13_[0] = chany_bottom_in_10_[0];
// ----- Local connection due to Wire 6 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_15_[0] = chany_bottom_in_12_[0];
// ----- Local connection due to Wire 8 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_19_[0] = chany_bottom_in_16_[0];
// ----- Local connection due to Wire 9 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_21_[0] = chany_bottom_in_18_[0];
// ----- Local connection due to Wire 10 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_23_[0] = chany_bottom_in_20_[0];
// ----- Local connection due to Wire 11 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_25_[0] = chany_bottom_in_22_[0];
// ----- Local connection due to Wire 12 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_27_[0] = chany_bottom_in_24_[0];
// ----- Local connection due to Wire 13 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_29_[0] = chany_bottom_in_26_[0];
// ----- Local connection due to Wire 14 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_31_[0] = chany_bottom_in_28_[0];
// ----- Local connection due to Wire 16 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_35_[0] = chany_bottom_in_32_[0];
// ----- Local connection due to Wire 17 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_37_[0] = chany_bottom_in_34_[0];
// ----- Local connection due to Wire 18 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_39_[0] = chany_bottom_in_36_[0];
// ----- Local connection due to Wire 19 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_41_[0] = chany_bottom_in_38_[0];
// ----- Local connection due to Wire 20 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_43_[0] = chany_bottom_in_40_[0];
// ----- Local connection due to Wire 21 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_45_[0] = chany_bottom_in_42_[0];
// ----- Local connection due to Wire 22 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_47_[0] = chany_bottom_in_44_[0];
// ----- Local connection due to Wire 24 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_51_[0] = chany_bottom_in_48_[0];
// ----- Local connection due to Wire 25 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_53_[0] = chany_bottom_in_50_[0];
// ----- Local connection due to Wire 26 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_55_[0] = chany_bottom_in_52_[0];
// ----- Local connection due to Wire 27 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_57_[0] = chany_bottom_in_54_[0];
// ----- Local connection due to Wire 28 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_59_[0] = chany_bottom_in_56_[0];
// ----- Local connection due to Wire 29 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_61_[0] = chany_bottom_in_58_[0];
// ----- Local connection due to Wire 30 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_63_[0] = chany_bottom_in_60_[0];
// ----- Local connection due to Wire 32 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_67_[0] = chany_bottom_in_64_[0];
// ----- Local connection due to Wire 33 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_69_[0] = chany_bottom_in_66_[0];
// ----- Local connection due to Wire 34 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_71_[0] = chany_bottom_in_68_[0];
// ----- Local connection due to Wire 35 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_73_[0] = chany_bottom_in_70_[0];
// ----- Local connection due to Wire 36 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_75_[0] = chany_bottom_in_72_[0];
// ----- Local connection due to Wire 37 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_77_[0] = chany_bottom_in_74_[0];
// ----- Local connection due to Wire 38 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_79_[0] = chany_bottom_in_76_[0];
// ----- Local connection due to Wire 40 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_83_[0] = chany_bottom_in_80_[0];
// ----- Local connection due to Wire 41 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_85_[0] = chany_bottom_in_82_[0];
// ----- Local connection due to Wire 42 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_87_[0] = chany_bottom_in_84_[0];
// ----- Local connection due to Wire 43 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_89_[0] = chany_bottom_in_86_[0];
// ----- Local connection due to Wire 44 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_91_[0] = chany_bottom_in_88_[0];
// ----- Local connection due to Wire 45 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_93_[0] = chany_bottom_in_90_[0];
// ----- Local connection due to Wire 46 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_95_[0] = chany_bottom_in_92_[0];
// ----- Local connection due to Wire 48 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_99_[0] = chany_bottom_in_96_[0];
// ----- Local connection due to Wire 49 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_101_[0] = chany_bottom_in_98_[0];
// ----- Local connection due to Wire 50 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_103_[0] = chany_bottom_in_100_[0];
// ----- Local connection due to Wire 51 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_105_[0] = chany_bottom_in_102_[0];
// ----- Local connection due to Wire 52 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_107_[0] = chany_bottom_in_104_[0];
// ----- Local connection due to Wire 53 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_109_[0] = chany_bottom_in_106_[0];
// ----- Local connection due to Wire 54 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_111_[0] = chany_bottom_in_108_[0];
// ----- Local connection due to Wire 56 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_115_[0] = chany_bottom_in_112_[0];
// ----- Local connection due to Wire 57 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_117_[0] = chany_bottom_in_114_[0];
// ----- Local connection due to Wire 58 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_119_[0] = chany_bottom_in_116_[0];
// ----- Local connection due to Wire 73 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_13_[0] = chanx_left_in_14_[0];
// ----- Local connection due to Wire 74 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_15_[0] = chanx_left_in_16_[0];
// ----- Local connection due to Wire 81 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_29_[0] = chanx_left_in_30_[0];
// ----- Local connection due to Wire 82 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_31_[0] = chanx_left_in_32_[0];
// ----- Local connection due to Wire 89 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_45_[0] = chanx_left_in_46_[0];
// ----- Local connection due to Wire 90 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_47_[0] = chanx_left_in_48_[0];
// ----- Local connection due to Wire 97 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_61_[0] = chanx_left_in_62_[0];
// ----- Local connection due to Wire 98 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_63_[0] = chanx_left_in_64_[0];
// ----- Local connection due to Wire 105 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_77_[0] = chanx_left_in_78_[0];
// ----- Local connection due to Wire 106 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_79_[0] = chanx_left_in_80_[0];
// ----- Local connection due to Wire 113 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_93_[0] = chanx_left_in_94_[0];
// ----- Local connection due to Wire 114 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_95_[0] = chanx_left_in_96_[0];
// ----- Local connection due to Wire 121 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_109_[0] = chanx_left_in_110_[0];
// ----- Local connection due to Wire 122 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_111_[0] = chanx_left_in_112_[0];
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	mux_tree_like_tapbuf_size2 mux_bottom_track_1 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_2_[0]}),
		.sram(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]),
		.out(chany_bottom_out_1_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_3 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_4_[0]}),
		.sram(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]),
		.out(chany_bottom_out_3_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_5 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_6_[0]}),
		.sram(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]),
		.out(chany_bottom_out_5_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_7 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_8_[0]}),
		.sram(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]),
		.out(chany_bottom_out_7_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_9 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_10_[0]}),
		.sram(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]),
		.out(chany_bottom_out_9_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_11 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_12_[0]}),
		.sram(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]),
		.out(chany_bottom_out_11_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_21 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_22_[0]}),
		.sram(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]),
		.out(chany_bottom_out_21_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_23 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_24_[0]}),
		.sram(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]),
		.out(chany_bottom_out_23_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_25 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_26_[0]}),
		.sram(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]),
		.out(chany_bottom_out_25_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_27 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_28_[0]}),
		.sram(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]),
		.out(chany_bottom_out_27_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_33 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_34_[0]}),
		.sram(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]),
		.out(chany_bottom_out_33_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_35 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_36_[0]}),
		.sram(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]),
		.out(chany_bottom_out_35_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_37 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_38_[0]}),
		.sram(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]),
		.out(chany_bottom_out_37_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_39 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_40_[0]}),
		.sram(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]),
		.out(chany_bottom_out_39_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_41 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_42_[0]}),
		.sram(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]),
		.out(chany_bottom_out_41_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_43 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_44_[0]}),
		.sram(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]),
		.out(chany_bottom_out_43_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_49 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_50_[0]}),
		.sram(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]),
		.out(chany_bottom_out_49_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_51 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_52_[0]}),
		.sram(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]),
		.out(chany_bottom_out_51_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_53 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_54_[0]}),
		.sram(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]),
		.out(chany_bottom_out_53_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_55 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_56_[0]}),
		.sram(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]),
		.out(chany_bottom_out_55_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_57 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_58_[0]}),
		.sram(mux_tree_like_tapbuf_size2_20_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_20_sram_inv[0:1]),
		.out(chany_bottom_out_57_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_59 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_60_[0]}),
		.sram(mux_tree_like_tapbuf_size2_21_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_21_sram_inv[0:1]),
		.out(chany_bottom_out_59_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_65 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_66_[0]}),
		.sram(mux_tree_like_tapbuf_size2_22_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_22_sram_inv[0:1]),
		.out(chany_bottom_out_65_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_67 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_68_[0]}),
		.sram(mux_tree_like_tapbuf_size2_23_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_23_sram_inv[0:1]),
		.out(chany_bottom_out_67_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_69 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_70_[0]}),
		.sram(mux_tree_like_tapbuf_size2_24_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_24_sram_inv[0:1]),
		.out(chany_bottom_out_69_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_71 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_72_[0]}),
		.sram(mux_tree_like_tapbuf_size2_25_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_25_sram_inv[0:1]),
		.out(chany_bottom_out_71_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_73 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_74_[0]}),
		.sram(mux_tree_like_tapbuf_size2_26_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_26_sram_inv[0:1]),
		.out(chany_bottom_out_73_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_75 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_76_[0]}),
		.sram(mux_tree_like_tapbuf_size2_27_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_27_sram_inv[0:1]),
		.out(chany_bottom_out_75_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_81 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_82_[0]}),
		.sram(mux_tree_like_tapbuf_size2_28_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_28_sram_inv[0:1]),
		.out(chany_bottom_out_81_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_83 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_84_[0]}),
		.sram(mux_tree_like_tapbuf_size2_29_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_29_sram_inv[0:1]),
		.out(chany_bottom_out_83_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_85 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_86_[0]}),
		.sram(mux_tree_like_tapbuf_size2_30_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_30_sram_inv[0:1]),
		.out(chany_bottom_out_85_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_87 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_88_[0]}),
		.sram(mux_tree_like_tapbuf_size2_31_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_31_sram_inv[0:1]),
		.out(chany_bottom_out_87_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_89 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_90_[0]}),
		.sram(mux_tree_like_tapbuf_size2_32_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_32_sram_inv[0:1]),
		.out(chany_bottom_out_89_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_91 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_92_[0]}),
		.sram(mux_tree_like_tapbuf_size2_33_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_33_sram_inv[0:1]),
		.out(chany_bottom_out_91_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_97 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_98_[0]}),
		.sram(mux_tree_like_tapbuf_size2_34_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_34_sram_inv[0:1]),
		.out(chany_bottom_out_97_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_99 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_100_[0]}),
		.sram(mux_tree_like_tapbuf_size2_35_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_35_sram_inv[0:1]),
		.out(chany_bottom_out_99_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_101 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_102_[0]}),
		.sram(mux_tree_like_tapbuf_size2_36_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_36_sram_inv[0:1]),
		.out(chany_bottom_out_101_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_103 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_104_[0]}),
		.sram(mux_tree_like_tapbuf_size2_37_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_37_sram_inv[0:1]),
		.out(chany_bottom_out_103_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_105 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_106_[0]}),
		.sram(mux_tree_like_tapbuf_size2_38_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_38_sram_inv[0:1]),
		.out(chany_bottom_out_105_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_107 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_108_[0]}),
		.sram(mux_tree_like_tapbuf_size2_39_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_39_sram_inv[0:1]),
		.out(chany_bottom_out_107_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_113 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_114_[0]}),
		.sram(mux_tree_like_tapbuf_size2_40_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_40_sram_inv[0:1]),
		.out(chany_bottom_out_113_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_115 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_116_[0]}),
		.sram(mux_tree_like_tapbuf_size2_41_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_41_sram_inv[0:1]),
		.out(chany_bottom_out_115_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_117 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_118_[0]}),
		.sram(mux_tree_like_tapbuf_size2_42_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_42_sram_inv[0:1]),
		.out(chany_bottom_out_117_[0]));

	mux_tree_like_tapbuf_size2 mux_bottom_track_119 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_0_[0]}),
		.sram(mux_tree_like_tapbuf_size2_43_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_43_sram_inv[0:1]),
		.out(chany_bottom_out_119_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_1 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_118_[0]}),
		.sram(mux_tree_like_tapbuf_size2_44_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_44_sram_inv[0:1]),
		.out(chanx_left_out_1_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_17 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_14_[0]}),
		.sram(mux_tree_like_tapbuf_size2_45_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_45_sram_inv[0:1]),
		.out(chanx_left_out_17_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_33 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_30_[0]}),
		.sram(mux_tree_like_tapbuf_size2_46_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_46_sram_inv[0:1]),
		.out(chanx_left_out_33_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_49 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_46_[0]}),
		.sram(mux_tree_like_tapbuf_size2_47_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_47_sram_inv[0:1]),
		.out(chanx_left_out_49_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_65 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_62_[0]}),
		.sram(mux_tree_like_tapbuf_size2_48_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_48_sram_inv[0:1]),
		.out(chanx_left_out_65_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_81 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_78_[0]}),
		.sram(mux_tree_like_tapbuf_size2_49_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_49_sram_inv[0:1]),
		.out(chanx_left_out_81_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_97 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_94_[0]}),
		.sram(mux_tree_like_tapbuf_size2_50_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_50_sram_inv[0:1]),
		.out(chanx_left_out_97_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_113 (
		.in({left_top_grid_pin_1_[0], chany_bottom_in_110_[0]}),
		.sram(mux_tree_like_tapbuf_size2_51_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_51_sram_inv[0:1]),
		.out(chanx_left_out_113_[0]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_5 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_7 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_9 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_11 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_21 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_23 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_25 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_27 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_35 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_37 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_39 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_41 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_43 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_51 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_53 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_55 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_19_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_57 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_19_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_20_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_20_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_20_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_59 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_20_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_21_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_21_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_21_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_21_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_22_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_22_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_22_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_67 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_22_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_23_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_23_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_23_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_69 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_23_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_24_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_24_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_24_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_71 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_24_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_25_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_25_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_25_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_73 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_25_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_26_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_26_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_26_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_75 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_26_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_27_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_27_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_27_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_27_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_28_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_28_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_28_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_83 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_28_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_29_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_29_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_29_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_85 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_29_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_30_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_30_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_30_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_87 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_30_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_31_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_31_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_31_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_89 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_31_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_32_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_32_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_32_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_91 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_32_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_33_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_33_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_33_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_33_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_34_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_34_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_34_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_99 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_34_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_35_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_35_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_35_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_101 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_35_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_36_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_36_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_36_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_103 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_36_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_37_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_37_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_37_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_105 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_37_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_38_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_38_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_38_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_107 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_38_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_39_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_39_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_39_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_39_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_40_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_40_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_40_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_115 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_40_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_41_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_41_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_41_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_117 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_41_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_42_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_42_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_42_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_bottom_track_119 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_42_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_43_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_43_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_43_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_43_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_44_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_44_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_44_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_44_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_45_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_45_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_45_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_45_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_46_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_46_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_46_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_46_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_47_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_47_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_47_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_47_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_48_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_48_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_48_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_48_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_49_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_49_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_49_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_49_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_50_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_50_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_50_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_50_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_51_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_51_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3 mux_bottom_track_17 (
		.in({bottom_right_grid_pin_1_[0], bottom_left_grid_pin_33_[0], chanx_left_in_18_[0]}),
		.sram(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]),
		.out(chany_bottom_out_17_[0]));

	mux_tree_like_tapbuf_size3 mux_bottom_track_19 (
		.in({bottom_left_grid_pin_30_[0], bottom_left_grid_pin_34_[0], chanx_left_in_20_[0]}),
		.sram(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]),
		.out(chany_bottom_out_19_[0]));

	mux_tree_like_tapbuf_size3_mem mem_bottom_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_bottom_track_19 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]));

endmodule
// ----- END Verilog module for sb_22__22_ -----


