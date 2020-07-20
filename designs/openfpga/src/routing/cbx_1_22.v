//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for Unique Connection Blocks[1][22]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for cbx_1__22_ -----
module cbx_1__22_(pReset,
                  prog_clk,
                  chanx_in_0_,
                  chanx_in_1_,
                  chanx_in_2_,
                  chanx_in_3_,
                  chanx_in_4_,
                  chanx_in_5_,
                  chanx_in_6_,
                  chanx_in_7_,
                  chanx_in_8_,
                  chanx_in_9_,
                  chanx_in_10_,
                  chanx_in_11_,
                  chanx_in_12_,
                  chanx_in_13_,
                  chanx_in_14_,
                  chanx_in_15_,
                  chanx_in_16_,
                  chanx_in_17_,
                  chanx_in_18_,
                  chanx_in_19_,
                  chanx_in_20_,
                  chanx_in_21_,
                  chanx_in_22_,
                  chanx_in_23_,
                  chanx_in_24_,
                  chanx_in_25_,
                  chanx_in_26_,
                  chanx_in_27_,
                  chanx_in_28_,
                  chanx_in_29_,
                  chanx_in_30_,
                  chanx_in_31_,
                  chanx_in_32_,
                  chanx_in_33_,
                  chanx_in_34_,
                  chanx_in_35_,
                  chanx_in_36_,
                  chanx_in_37_,
                  chanx_in_38_,
                  chanx_in_39_,
                  chanx_in_40_,
                  chanx_in_41_,
                  chanx_in_42_,
                  chanx_in_43_,
                  chanx_in_44_,
                  chanx_in_45_,
                  chanx_in_46_,
                  chanx_in_47_,
                  chanx_in_48_,
                  chanx_in_49_,
                  chanx_in_50_,
                  chanx_in_51_,
                  chanx_in_52_,
                  chanx_in_53_,
                  chanx_in_54_,
                  chanx_in_55_,
                  chanx_in_56_,
                  chanx_in_57_,
                  chanx_in_58_,
                  chanx_in_59_,
                  chanx_in_60_,
                  chanx_in_61_,
                  chanx_in_62_,
                  chanx_in_63_,
                  chanx_in_64_,
                  chanx_in_65_,
                  chanx_in_66_,
                  chanx_in_67_,
                  chanx_in_68_,
                  chanx_in_69_,
                  chanx_in_70_,
                  chanx_in_71_,
                  chanx_in_72_,
                  chanx_in_73_,
                  chanx_in_74_,
                  chanx_in_75_,
                  chanx_in_76_,
                  chanx_in_77_,
                  chanx_in_78_,
                  chanx_in_79_,
                  chanx_in_80_,
                  chanx_in_81_,
                  chanx_in_82_,
                  chanx_in_83_,
                  chanx_in_84_,
                  chanx_in_85_,
                  chanx_in_86_,
                  chanx_in_87_,
                  chanx_in_88_,
                  chanx_in_89_,
                  chanx_in_90_,
                  chanx_in_91_,
                  chanx_in_92_,
                  chanx_in_93_,
                  chanx_in_94_,
                  chanx_in_95_,
                  chanx_in_96_,
                  chanx_in_97_,
                  chanx_in_98_,
                  chanx_in_99_,
                  chanx_in_100_,
                  chanx_in_101_,
                  chanx_in_102_,
                  chanx_in_103_,
                  chanx_in_104_,
                  chanx_in_105_,
                  chanx_in_106_,
                  chanx_in_107_,
                  chanx_in_108_,
                  chanx_in_109_,
                  chanx_in_110_,
                  chanx_in_111_,
                  chanx_in_112_,
                  chanx_in_113_,
                  chanx_in_114_,
                  chanx_in_115_,
                  chanx_in_116_,
                  chanx_in_117_,
                  chanx_in_118_,
                  chanx_in_119_,
                  ccff_head,
                  chanx_out_0_,
                  chanx_out_1_,
                  chanx_out_2_,
                  chanx_out_3_,
                  chanx_out_4_,
                  chanx_out_5_,
                  chanx_out_6_,
                  chanx_out_7_,
                  chanx_out_8_,
                  chanx_out_9_,
                  chanx_out_10_,
                  chanx_out_11_,
                  chanx_out_12_,
                  chanx_out_13_,
                  chanx_out_14_,
                  chanx_out_15_,
                  chanx_out_16_,
                  chanx_out_17_,
                  chanx_out_18_,
                  chanx_out_19_,
                  chanx_out_20_,
                  chanx_out_21_,
                  chanx_out_22_,
                  chanx_out_23_,
                  chanx_out_24_,
                  chanx_out_25_,
                  chanx_out_26_,
                  chanx_out_27_,
                  chanx_out_28_,
                  chanx_out_29_,
                  chanx_out_30_,
                  chanx_out_31_,
                  chanx_out_32_,
                  chanx_out_33_,
                  chanx_out_34_,
                  chanx_out_35_,
                  chanx_out_36_,
                  chanx_out_37_,
                  chanx_out_38_,
                  chanx_out_39_,
                  chanx_out_40_,
                  chanx_out_41_,
                  chanx_out_42_,
                  chanx_out_43_,
                  chanx_out_44_,
                  chanx_out_45_,
                  chanx_out_46_,
                  chanx_out_47_,
                  chanx_out_48_,
                  chanx_out_49_,
                  chanx_out_50_,
                  chanx_out_51_,
                  chanx_out_52_,
                  chanx_out_53_,
                  chanx_out_54_,
                  chanx_out_55_,
                  chanx_out_56_,
                  chanx_out_57_,
                  chanx_out_58_,
                  chanx_out_59_,
                  chanx_out_60_,
                  chanx_out_61_,
                  chanx_out_62_,
                  chanx_out_63_,
                  chanx_out_64_,
                  chanx_out_65_,
                  chanx_out_66_,
                  chanx_out_67_,
                  chanx_out_68_,
                  chanx_out_69_,
                  chanx_out_70_,
                  chanx_out_71_,
                  chanx_out_72_,
                  chanx_out_73_,
                  chanx_out_74_,
                  chanx_out_75_,
                  chanx_out_76_,
                  chanx_out_77_,
                  chanx_out_78_,
                  chanx_out_79_,
                  chanx_out_80_,
                  chanx_out_81_,
                  chanx_out_82_,
                  chanx_out_83_,
                  chanx_out_84_,
                  chanx_out_85_,
                  chanx_out_86_,
                  chanx_out_87_,
                  chanx_out_88_,
                  chanx_out_89_,
                  chanx_out_90_,
                  chanx_out_91_,
                  chanx_out_92_,
                  chanx_out_93_,
                  chanx_out_94_,
                  chanx_out_95_,
                  chanx_out_96_,
                  chanx_out_97_,
                  chanx_out_98_,
                  chanx_out_99_,
                  chanx_out_100_,
                  chanx_out_101_,
                  chanx_out_102_,
                  chanx_out_103_,
                  chanx_out_104_,
                  chanx_out_105_,
                  chanx_out_106_,
                  chanx_out_107_,
                  chanx_out_108_,
                  chanx_out_109_,
                  chanx_out_110_,
                  chanx_out_111_,
                  chanx_out_112_,
                  chanx_out_113_,
                  chanx_out_114_,
                  chanx_out_115_,
                  chanx_out_116_,
                  chanx_out_117_,
                  chanx_out_118_,
                  chanx_out_119_,
                  top_grid_pin_0_,
                  bottom_grid_pin_40_,
                  ccff_tail);
//----- GLOBAL PORTS -----
input [0:0] pReset;
//----- GLOBAL PORTS -----
input [0:0] prog_clk;
//----- INPUT PORTS -----
input [0:0] chanx_in_0_;
//----- INPUT PORTS -----
input [0:0] chanx_in_1_;
//----- INPUT PORTS -----
input [0:0] chanx_in_2_;
//----- INPUT PORTS -----
input [0:0] chanx_in_3_;
//----- INPUT PORTS -----
input [0:0] chanx_in_4_;
//----- INPUT PORTS -----
input [0:0] chanx_in_5_;
//----- INPUT PORTS -----
input [0:0] chanx_in_6_;
//----- INPUT PORTS -----
input [0:0] chanx_in_7_;
//----- INPUT PORTS -----
input [0:0] chanx_in_8_;
//----- INPUT PORTS -----
input [0:0] chanx_in_9_;
//----- INPUT PORTS -----
input [0:0] chanx_in_10_;
//----- INPUT PORTS -----
input [0:0] chanx_in_11_;
//----- INPUT PORTS -----
input [0:0] chanx_in_12_;
//----- INPUT PORTS -----
input [0:0] chanx_in_13_;
//----- INPUT PORTS -----
input [0:0] chanx_in_14_;
//----- INPUT PORTS -----
input [0:0] chanx_in_15_;
//----- INPUT PORTS -----
input [0:0] chanx_in_16_;
//----- INPUT PORTS -----
input [0:0] chanx_in_17_;
//----- INPUT PORTS -----
input [0:0] chanx_in_18_;
//----- INPUT PORTS -----
input [0:0] chanx_in_19_;
//----- INPUT PORTS -----
input [0:0] chanx_in_20_;
//----- INPUT PORTS -----
input [0:0] chanx_in_21_;
//----- INPUT PORTS -----
input [0:0] chanx_in_22_;
//----- INPUT PORTS -----
input [0:0] chanx_in_23_;
//----- INPUT PORTS -----
input [0:0] chanx_in_24_;
//----- INPUT PORTS -----
input [0:0] chanx_in_25_;
//----- INPUT PORTS -----
input [0:0] chanx_in_26_;
//----- INPUT PORTS -----
input [0:0] chanx_in_27_;
//----- INPUT PORTS -----
input [0:0] chanx_in_28_;
//----- INPUT PORTS -----
input [0:0] chanx_in_29_;
//----- INPUT PORTS -----
input [0:0] chanx_in_30_;
//----- INPUT PORTS -----
input [0:0] chanx_in_31_;
//----- INPUT PORTS -----
input [0:0] chanx_in_32_;
//----- INPUT PORTS -----
input [0:0] chanx_in_33_;
//----- INPUT PORTS -----
input [0:0] chanx_in_34_;
//----- INPUT PORTS -----
input [0:0] chanx_in_35_;
//----- INPUT PORTS -----
input [0:0] chanx_in_36_;
//----- INPUT PORTS -----
input [0:0] chanx_in_37_;
//----- INPUT PORTS -----
input [0:0] chanx_in_38_;
//----- INPUT PORTS -----
input [0:0] chanx_in_39_;
//----- INPUT PORTS -----
input [0:0] chanx_in_40_;
//----- INPUT PORTS -----
input [0:0] chanx_in_41_;
//----- INPUT PORTS -----
input [0:0] chanx_in_42_;
//----- INPUT PORTS -----
input [0:0] chanx_in_43_;
//----- INPUT PORTS -----
input [0:0] chanx_in_44_;
//----- INPUT PORTS -----
input [0:0] chanx_in_45_;
//----- INPUT PORTS -----
input [0:0] chanx_in_46_;
//----- INPUT PORTS -----
input [0:0] chanx_in_47_;
//----- INPUT PORTS -----
input [0:0] chanx_in_48_;
//----- INPUT PORTS -----
input [0:0] chanx_in_49_;
//----- INPUT PORTS -----
input [0:0] chanx_in_50_;
//----- INPUT PORTS -----
input [0:0] chanx_in_51_;
//----- INPUT PORTS -----
input [0:0] chanx_in_52_;
//----- INPUT PORTS -----
input [0:0] chanx_in_53_;
//----- INPUT PORTS -----
input [0:0] chanx_in_54_;
//----- INPUT PORTS -----
input [0:0] chanx_in_55_;
//----- INPUT PORTS -----
input [0:0] chanx_in_56_;
//----- INPUT PORTS -----
input [0:0] chanx_in_57_;
//----- INPUT PORTS -----
input [0:0] chanx_in_58_;
//----- INPUT PORTS -----
input [0:0] chanx_in_59_;
//----- INPUT PORTS -----
input [0:0] chanx_in_60_;
//----- INPUT PORTS -----
input [0:0] chanx_in_61_;
//----- INPUT PORTS -----
input [0:0] chanx_in_62_;
//----- INPUT PORTS -----
input [0:0] chanx_in_63_;
//----- INPUT PORTS -----
input [0:0] chanx_in_64_;
//----- INPUT PORTS -----
input [0:0] chanx_in_65_;
//----- INPUT PORTS -----
input [0:0] chanx_in_66_;
//----- INPUT PORTS -----
input [0:0] chanx_in_67_;
//----- INPUT PORTS -----
input [0:0] chanx_in_68_;
//----- INPUT PORTS -----
input [0:0] chanx_in_69_;
//----- INPUT PORTS -----
input [0:0] chanx_in_70_;
//----- INPUT PORTS -----
input [0:0] chanx_in_71_;
//----- INPUT PORTS -----
input [0:0] chanx_in_72_;
//----- INPUT PORTS -----
input [0:0] chanx_in_73_;
//----- INPUT PORTS -----
input [0:0] chanx_in_74_;
//----- INPUT PORTS -----
input [0:0] chanx_in_75_;
//----- INPUT PORTS -----
input [0:0] chanx_in_76_;
//----- INPUT PORTS -----
input [0:0] chanx_in_77_;
//----- INPUT PORTS -----
input [0:0] chanx_in_78_;
//----- INPUT PORTS -----
input [0:0] chanx_in_79_;
//----- INPUT PORTS -----
input [0:0] chanx_in_80_;
//----- INPUT PORTS -----
input [0:0] chanx_in_81_;
//----- INPUT PORTS -----
input [0:0] chanx_in_82_;
//----- INPUT PORTS -----
input [0:0] chanx_in_83_;
//----- INPUT PORTS -----
input [0:0] chanx_in_84_;
//----- INPUT PORTS -----
input [0:0] chanx_in_85_;
//----- INPUT PORTS -----
input [0:0] chanx_in_86_;
//----- INPUT PORTS -----
input [0:0] chanx_in_87_;
//----- INPUT PORTS -----
input [0:0] chanx_in_88_;
//----- INPUT PORTS -----
input [0:0] chanx_in_89_;
//----- INPUT PORTS -----
input [0:0] chanx_in_90_;
//----- INPUT PORTS -----
input [0:0] chanx_in_91_;
//----- INPUT PORTS -----
input [0:0] chanx_in_92_;
//----- INPUT PORTS -----
input [0:0] chanx_in_93_;
//----- INPUT PORTS -----
input [0:0] chanx_in_94_;
//----- INPUT PORTS -----
input [0:0] chanx_in_95_;
//----- INPUT PORTS -----
input [0:0] chanx_in_96_;
//----- INPUT PORTS -----
input [0:0] chanx_in_97_;
//----- INPUT PORTS -----
input [0:0] chanx_in_98_;
//----- INPUT PORTS -----
input [0:0] chanx_in_99_;
//----- INPUT PORTS -----
input [0:0] chanx_in_100_;
//----- INPUT PORTS -----
input [0:0] chanx_in_101_;
//----- INPUT PORTS -----
input [0:0] chanx_in_102_;
//----- INPUT PORTS -----
input [0:0] chanx_in_103_;
//----- INPUT PORTS -----
input [0:0] chanx_in_104_;
//----- INPUT PORTS -----
input [0:0] chanx_in_105_;
//----- INPUT PORTS -----
input [0:0] chanx_in_106_;
//----- INPUT PORTS -----
input [0:0] chanx_in_107_;
//----- INPUT PORTS -----
input [0:0] chanx_in_108_;
//----- INPUT PORTS -----
input [0:0] chanx_in_109_;
//----- INPUT PORTS -----
input [0:0] chanx_in_110_;
//----- INPUT PORTS -----
input [0:0] chanx_in_111_;
//----- INPUT PORTS -----
input [0:0] chanx_in_112_;
//----- INPUT PORTS -----
input [0:0] chanx_in_113_;
//----- INPUT PORTS -----
input [0:0] chanx_in_114_;
//----- INPUT PORTS -----
input [0:0] chanx_in_115_;
//----- INPUT PORTS -----
input [0:0] chanx_in_116_;
//----- INPUT PORTS -----
input [0:0] chanx_in_117_;
//----- INPUT PORTS -----
input [0:0] chanx_in_118_;
//----- INPUT PORTS -----
input [0:0] chanx_in_119_;
//----- INPUT PORTS -----
input [0:0] ccff_head;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_0_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_1_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_2_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_3_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_4_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_5_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_6_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_7_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_8_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_9_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_10_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_11_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_12_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_13_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_14_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_15_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_16_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_17_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_18_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_19_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_20_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_21_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_22_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_23_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_24_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_25_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_26_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_27_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_28_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_29_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_30_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_31_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_32_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_33_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_34_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_35_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_36_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_37_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_38_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_39_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_40_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_41_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_42_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_43_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_44_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_45_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_46_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_47_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_48_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_49_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_50_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_51_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_52_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_53_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_54_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_55_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_56_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_57_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_58_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_59_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_60_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_61_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_62_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_63_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_64_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_65_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_66_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_67_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_68_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_69_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_70_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_71_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_72_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_73_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_74_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_75_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_76_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_77_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_78_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_79_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_80_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_81_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_82_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_83_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_84_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_85_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_86_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_87_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_88_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_89_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_90_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_91_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_92_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_93_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_94_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_95_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_96_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_97_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_98_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_99_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_100_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_101_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_102_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_103_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_104_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_105_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_106_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_107_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_108_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_109_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_110_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_111_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_112_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_113_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_114_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_115_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_116_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_117_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_118_;
//----- OUTPUT PORTS -----
output [0:0] chanx_out_119_;
//----- OUTPUT PORTS -----
output [0:0] top_grid_pin_0_;
//----- OUTPUT PORTS -----
output [0:0] bottom_grid_pin_40_;
//----- OUTPUT PORTS -----
output [0:0] ccff_tail;

//----- BEGIN wire-connection ports -----
//----- END wire-connection ports -----


//----- BEGIN Registered ports -----
//----- END Registered ports -----


wire [0:3] mux_tree_like_tapbuf_size14_0_sram;
wire [0:3] mux_tree_like_tapbuf_size14_0_sram_inv;
wire [0:5] mux_tree_like_tapbuf_size42_0_sram;
wire [0:5] mux_tree_like_tapbuf_size42_0_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size42_mem_0_ccff_tail;

// ----- BEGIN Local short connections -----
// ----- Local connection due to Wire 0 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_0_[0] = chanx_in_0_[0];
// ----- Local connection due to Wire 1 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_1_[0] = chanx_in_1_[0];
// ----- Local connection due to Wire 2 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_2_[0] = chanx_in_2_[0];
// ----- Local connection due to Wire 3 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_3_[0] = chanx_in_3_[0];
// ----- Local connection due to Wire 4 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_4_[0] = chanx_in_4_[0];
// ----- Local connection due to Wire 5 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_5_[0] = chanx_in_5_[0];
// ----- Local connection due to Wire 6 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_6_[0] = chanx_in_6_[0];
// ----- Local connection due to Wire 7 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_7_[0] = chanx_in_7_[0];
// ----- Local connection due to Wire 8 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_8_[0] = chanx_in_8_[0];
// ----- Local connection due to Wire 9 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_9_[0] = chanx_in_9_[0];
// ----- Local connection due to Wire 10 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_10_[0] = chanx_in_10_[0];
// ----- Local connection due to Wire 11 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_11_[0] = chanx_in_11_[0];
// ----- Local connection due to Wire 12 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_12_[0] = chanx_in_12_[0];
// ----- Local connection due to Wire 13 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_13_[0] = chanx_in_13_[0];
// ----- Local connection due to Wire 14 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_14_[0] = chanx_in_14_[0];
// ----- Local connection due to Wire 15 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_15_[0] = chanx_in_15_[0];
// ----- Local connection due to Wire 16 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_16_[0] = chanx_in_16_[0];
// ----- Local connection due to Wire 17 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_17_[0] = chanx_in_17_[0];
// ----- Local connection due to Wire 18 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_18_[0] = chanx_in_18_[0];
// ----- Local connection due to Wire 19 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_19_[0] = chanx_in_19_[0];
// ----- Local connection due to Wire 20 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_20_[0] = chanx_in_20_[0];
// ----- Local connection due to Wire 21 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_21_[0] = chanx_in_21_[0];
// ----- Local connection due to Wire 22 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_22_[0] = chanx_in_22_[0];
// ----- Local connection due to Wire 23 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_23_[0] = chanx_in_23_[0];
// ----- Local connection due to Wire 24 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_24_[0] = chanx_in_24_[0];
// ----- Local connection due to Wire 25 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_25_[0] = chanx_in_25_[0];
// ----- Local connection due to Wire 26 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_26_[0] = chanx_in_26_[0];
// ----- Local connection due to Wire 27 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_27_[0] = chanx_in_27_[0];
// ----- Local connection due to Wire 28 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_28_[0] = chanx_in_28_[0];
// ----- Local connection due to Wire 29 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_29_[0] = chanx_in_29_[0];
// ----- Local connection due to Wire 30 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_30_[0] = chanx_in_30_[0];
// ----- Local connection due to Wire 31 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_31_[0] = chanx_in_31_[0];
// ----- Local connection due to Wire 32 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_32_[0] = chanx_in_32_[0];
// ----- Local connection due to Wire 33 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_33_[0] = chanx_in_33_[0];
// ----- Local connection due to Wire 34 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_34_[0] = chanx_in_34_[0];
// ----- Local connection due to Wire 35 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_35_[0] = chanx_in_35_[0];
// ----- Local connection due to Wire 36 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_36_[0] = chanx_in_36_[0];
// ----- Local connection due to Wire 37 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_37_[0] = chanx_in_37_[0];
// ----- Local connection due to Wire 38 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_38_[0] = chanx_in_38_[0];
// ----- Local connection due to Wire 39 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_39_[0] = chanx_in_39_[0];
// ----- Local connection due to Wire 40 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_40_[0] = chanx_in_40_[0];
// ----- Local connection due to Wire 41 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_41_[0] = chanx_in_41_[0];
// ----- Local connection due to Wire 42 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_42_[0] = chanx_in_42_[0];
// ----- Local connection due to Wire 43 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_43_[0] = chanx_in_43_[0];
// ----- Local connection due to Wire 44 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_44_[0] = chanx_in_44_[0];
// ----- Local connection due to Wire 45 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_45_[0] = chanx_in_45_[0];
// ----- Local connection due to Wire 46 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_46_[0] = chanx_in_46_[0];
// ----- Local connection due to Wire 47 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_47_[0] = chanx_in_47_[0];
// ----- Local connection due to Wire 48 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_48_[0] = chanx_in_48_[0];
// ----- Local connection due to Wire 49 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_49_[0] = chanx_in_49_[0];
// ----- Local connection due to Wire 50 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_50_[0] = chanx_in_50_[0];
// ----- Local connection due to Wire 51 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_51_[0] = chanx_in_51_[0];
// ----- Local connection due to Wire 52 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_52_[0] = chanx_in_52_[0];
// ----- Local connection due to Wire 53 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_53_[0] = chanx_in_53_[0];
// ----- Local connection due to Wire 54 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_54_[0] = chanx_in_54_[0];
// ----- Local connection due to Wire 55 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_55_[0] = chanx_in_55_[0];
// ----- Local connection due to Wire 56 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_56_[0] = chanx_in_56_[0];
// ----- Local connection due to Wire 57 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_57_[0] = chanx_in_57_[0];
// ----- Local connection due to Wire 58 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_58_[0] = chanx_in_58_[0];
// ----- Local connection due to Wire 59 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_59_[0] = chanx_in_59_[0];
// ----- Local connection due to Wire 60 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_60_[0] = chanx_in_60_[0];
// ----- Local connection due to Wire 61 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_61_[0] = chanx_in_61_[0];
// ----- Local connection due to Wire 62 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_62_[0] = chanx_in_62_[0];
// ----- Local connection due to Wire 63 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_63_[0] = chanx_in_63_[0];
// ----- Local connection due to Wire 64 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_64_[0] = chanx_in_64_[0];
// ----- Local connection due to Wire 65 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_65_[0] = chanx_in_65_[0];
// ----- Local connection due to Wire 66 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_66_[0] = chanx_in_66_[0];
// ----- Local connection due to Wire 67 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_67_[0] = chanx_in_67_[0];
// ----- Local connection due to Wire 68 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_68_[0] = chanx_in_68_[0];
// ----- Local connection due to Wire 69 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_69_[0] = chanx_in_69_[0];
// ----- Local connection due to Wire 70 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_70_[0] = chanx_in_70_[0];
// ----- Local connection due to Wire 71 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_71_[0] = chanx_in_71_[0];
// ----- Local connection due to Wire 72 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_72_[0] = chanx_in_72_[0];
// ----- Local connection due to Wire 73 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_73_[0] = chanx_in_73_[0];
// ----- Local connection due to Wire 74 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_74_[0] = chanx_in_74_[0];
// ----- Local connection due to Wire 75 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_75_[0] = chanx_in_75_[0];
// ----- Local connection due to Wire 76 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_76_[0] = chanx_in_76_[0];
// ----- Local connection due to Wire 77 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_77_[0] = chanx_in_77_[0];
// ----- Local connection due to Wire 78 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_78_[0] = chanx_in_78_[0];
// ----- Local connection due to Wire 79 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_79_[0] = chanx_in_79_[0];
// ----- Local connection due to Wire 80 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_80_[0] = chanx_in_80_[0];
// ----- Local connection due to Wire 81 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_81_[0] = chanx_in_81_[0];
// ----- Local connection due to Wire 82 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_82_[0] = chanx_in_82_[0];
// ----- Local connection due to Wire 83 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_83_[0] = chanx_in_83_[0];
// ----- Local connection due to Wire 84 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_84_[0] = chanx_in_84_[0];
// ----- Local connection due to Wire 85 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_85_[0] = chanx_in_85_[0];
// ----- Local connection due to Wire 86 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_86_[0] = chanx_in_86_[0];
// ----- Local connection due to Wire 87 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_87_[0] = chanx_in_87_[0];
// ----- Local connection due to Wire 88 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_88_[0] = chanx_in_88_[0];
// ----- Local connection due to Wire 89 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_89_[0] = chanx_in_89_[0];
// ----- Local connection due to Wire 90 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_90_[0] = chanx_in_90_[0];
// ----- Local connection due to Wire 91 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_91_[0] = chanx_in_91_[0];
// ----- Local connection due to Wire 92 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_92_[0] = chanx_in_92_[0];
// ----- Local connection due to Wire 93 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_93_[0] = chanx_in_93_[0];
// ----- Local connection due to Wire 94 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_94_[0] = chanx_in_94_[0];
// ----- Local connection due to Wire 95 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_95_[0] = chanx_in_95_[0];
// ----- Local connection due to Wire 96 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_96_[0] = chanx_in_96_[0];
// ----- Local connection due to Wire 97 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_97_[0] = chanx_in_97_[0];
// ----- Local connection due to Wire 98 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_98_[0] = chanx_in_98_[0];
// ----- Local connection due to Wire 99 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_99_[0] = chanx_in_99_[0];
// ----- Local connection due to Wire 100 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_100_[0] = chanx_in_100_[0];
// ----- Local connection due to Wire 101 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_101_[0] = chanx_in_101_[0];
// ----- Local connection due to Wire 102 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_102_[0] = chanx_in_102_[0];
// ----- Local connection due to Wire 103 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_103_[0] = chanx_in_103_[0];
// ----- Local connection due to Wire 104 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_104_[0] = chanx_in_104_[0];
// ----- Local connection due to Wire 105 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_105_[0] = chanx_in_105_[0];
// ----- Local connection due to Wire 106 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_106_[0] = chanx_in_106_[0];
// ----- Local connection due to Wire 107 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_107_[0] = chanx_in_107_[0];
// ----- Local connection due to Wire 108 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_108_[0] = chanx_in_108_[0];
// ----- Local connection due to Wire 109 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_109_[0] = chanx_in_109_[0];
// ----- Local connection due to Wire 110 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_110_[0] = chanx_in_110_[0];
// ----- Local connection due to Wire 111 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_111_[0] = chanx_in_111_[0];
// ----- Local connection due to Wire 112 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_112_[0] = chanx_in_112_[0];
// ----- Local connection due to Wire 113 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_113_[0] = chanx_in_113_[0];
// ----- Local connection due to Wire 114 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_114_[0] = chanx_in_114_[0];
// ----- Local connection due to Wire 115 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_115_[0] = chanx_in_115_[0];
// ----- Local connection due to Wire 116 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_116_[0] = chanx_in_116_[0];
// ----- Local connection due to Wire 117 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_117_[0] = chanx_in_117_[0];
// ----- Local connection due to Wire 118 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_118_[0] = chanx_in_118_[0];
// ----- Local connection due to Wire 119 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_out_119_[0] = chanx_in_119_[0];
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	mux_tree_like_tapbuf_size42 mux_bottom_ipin_0 (
		.in({chanx_in_0_[0], chanx_in_1_[0], chanx_in_6_[0], chanx_in_7_[0], chanx_in_12_[0], chanx_in_13_[0], chanx_in_16_[0], chanx_in_17_[0], chanx_in_22_[0], chanx_in_23_[0], chanx_in_28_[0], chanx_in_29_[0], chanx_in_34_[0], chanx_in_35_[0], chanx_in_40_[0], chanx_in_41_[0], chanx_in_46_[0], chanx_in_47_[0], chanx_in_52_[0], chanx_in_53_[0], chanx_in_58_[0], chanx_in_59_[0], chanx_in_64_[0], chanx_in_65_[0], chanx_in_70_[0], chanx_in_71_[0], chanx_in_76_[0], chanx_in_77_[0], chanx_in_82_[0], chanx_in_83_[0], chanx_in_88_[0], chanx_in_89_[0], chanx_in_94_[0], chanx_in_95_[0], chanx_in_100_[0], chanx_in_101_[0], chanx_in_106_[0], chanx_in_107_[0], chanx_in_112_[0], chanx_in_113_[0], chanx_in_118_[0], chanx_in_119_[0]}),
		.sram(mux_tree_like_tapbuf_size42_0_sram[0:5]),
		.sram_inv(mux_tree_like_tapbuf_size42_0_sram_inv[0:5]),
		.out(top_grid_pin_0_[0]));

	mux_tree_like_tapbuf_size42_mem mem_bottom_ipin_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(mux_tree_like_tapbuf_size42_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size42_0_sram[0:5]),
		.mem_outb(mux_tree_like_tapbuf_size42_0_sram_inv[0:5]));

	mux_tree_like_tapbuf_size14 mux_top_ipin_0 (
		.in({chanx_in_2_[0], chanx_in_3_[0], chanx_in_18_[0], chanx_in_19_[0], chanx_in_36_[0], chanx_in_37_[0], chanx_in_54_[0], chanx_in_55_[0], chanx_in_72_[0], chanx_in_73_[0], chanx_in_90_[0], chanx_in_91_[0], chanx_in_108_[0], chanx_in_109_[0]}),
		.sram(mux_tree_like_tapbuf_size14_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size14_0_sram_inv[0:3]),
		.out(bottom_grid_pin_40_[0]));

	mux_tree_like_tapbuf_size14_mem mem_top_ipin_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size42_mem_0_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size14_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size14_0_sram_inv[0:3]));

endmodule
// ----- END Verilog module for cbx_1__22_ -----



