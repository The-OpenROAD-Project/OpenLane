//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for Unique Switch Blocks[22][1]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for sb_22__1_ -----
module sb_22__1_(pReset,
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
                 top_left_grid_pin_30_,
                 top_left_grid_pin_31_,
                 top_left_grid_pin_32_,
                 top_left_grid_pin_33_,
                 top_left_grid_pin_34_,
                 top_right_grid_pin_1_,
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
                 left_top_grid_pin_35_,
                 left_top_grid_pin_36_,
                 left_top_grid_pin_37_,
                 left_top_grid_pin_38_,
                 left_top_grid_pin_39_,
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
input [0:0] top_left_grid_pin_30_;
//----- INPUT PORTS -----
input [0:0] top_left_grid_pin_31_;
//----- INPUT PORTS -----
input [0:0] top_left_grid_pin_32_;
//----- INPUT PORTS -----
input [0:0] top_left_grid_pin_33_;
//----- INPUT PORTS -----
input [0:0] top_left_grid_pin_34_;
//----- INPUT PORTS -----
input [0:0] top_right_grid_pin_1_;
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
input [0:0] left_top_grid_pin_35_;
//----- INPUT PORTS -----
input [0:0] left_top_grid_pin_36_;
//----- INPUT PORTS -----
input [0:0] left_top_grid_pin_37_;
//----- INPUT PORTS -----
input [0:0] left_top_grid_pin_38_;
//----- INPUT PORTS -----
input [0:0] left_top_grid_pin_39_;
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


wire [0:3] mux_tree_like_tapbuf_size10_0_sram;
wire [0:3] mux_tree_like_tapbuf_size10_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size10_1_sram;
wire [0:3] mux_tree_like_tapbuf_size10_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size10_2_sram;
wire [0:3] mux_tree_like_tapbuf_size10_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size10_3_sram;
wire [0:3] mux_tree_like_tapbuf_size10_3_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size10_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size10_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size10_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size10_mem_3_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size11_0_sram;
wire [0:3] mux_tree_like_tapbuf_size11_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_1_sram;
wire [0:3] mux_tree_like_tapbuf_size11_1_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size11_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_1_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size15_0_sram;
wire [0:3] mux_tree_like_tapbuf_size15_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size15_1_sram;
wire [0:3] mux_tree_like_tapbuf_size15_1_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size15_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size15_mem_1_ccff_tail;
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
wire [0:1] mux_tree_like_tapbuf_size2_2_sram;
wire [0:1] mux_tree_like_tapbuf_size2_2_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_3_sram;
wire [0:1] mux_tree_like_tapbuf_size2_3_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size2_4_sram;
wire [0:1] mux_tree_like_tapbuf_size2_4_sram_inv;
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
wire [0:0] mux_tree_like_tapbuf_size2_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size2_mem_9_ccff_tail;
wire [0:1] mux_tree_like_tapbuf_size3_0_sram;
wire [0:1] mux_tree_like_tapbuf_size3_0_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_10_sram;
wire [0:1] mux_tree_like_tapbuf_size3_10_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_11_sram;
wire [0:1] mux_tree_like_tapbuf_size3_11_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_12_sram;
wire [0:1] mux_tree_like_tapbuf_size3_12_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_13_sram;
wire [0:1] mux_tree_like_tapbuf_size3_13_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_14_sram;
wire [0:1] mux_tree_like_tapbuf_size3_14_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_15_sram;
wire [0:1] mux_tree_like_tapbuf_size3_15_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_16_sram;
wire [0:1] mux_tree_like_tapbuf_size3_16_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_17_sram;
wire [0:1] mux_tree_like_tapbuf_size3_17_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_18_sram;
wire [0:1] mux_tree_like_tapbuf_size3_18_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_19_sram;
wire [0:1] mux_tree_like_tapbuf_size3_19_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_1_sram;
wire [0:1] mux_tree_like_tapbuf_size3_1_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_20_sram;
wire [0:1] mux_tree_like_tapbuf_size3_20_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_21_sram;
wire [0:1] mux_tree_like_tapbuf_size3_21_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_22_sram;
wire [0:1] mux_tree_like_tapbuf_size3_22_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_23_sram;
wire [0:1] mux_tree_like_tapbuf_size3_23_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_24_sram;
wire [0:1] mux_tree_like_tapbuf_size3_24_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_2_sram;
wire [0:1] mux_tree_like_tapbuf_size3_2_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_3_sram;
wire [0:1] mux_tree_like_tapbuf_size3_3_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_4_sram;
wire [0:1] mux_tree_like_tapbuf_size3_4_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_5_sram;
wire [0:1] mux_tree_like_tapbuf_size3_5_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_6_sram;
wire [0:1] mux_tree_like_tapbuf_size3_6_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_7_sram;
wire [0:1] mux_tree_like_tapbuf_size3_7_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_8_sram;
wire [0:1] mux_tree_like_tapbuf_size3_8_sram_inv;
wire [0:1] mux_tree_like_tapbuf_size3_9_sram;
wire [0:1] mux_tree_like_tapbuf_size3_9_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size3_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_10_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_11_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_12_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_13_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_14_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_15_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_16_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_17_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_18_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_19_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_20_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_21_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_22_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_23_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_24_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size3_mem_9_ccff_tail;
wire [0:2] mux_tree_like_tapbuf_size4_0_sram;
wire [0:2] mux_tree_like_tapbuf_size4_0_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_1_sram;
wire [0:2] mux_tree_like_tapbuf_size4_1_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_2_sram;
wire [0:2] mux_tree_like_tapbuf_size4_2_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_3_sram;
wire [0:2] mux_tree_like_tapbuf_size4_3_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_4_sram;
wire [0:2] mux_tree_like_tapbuf_size4_4_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_5_sram;
wire [0:2] mux_tree_like_tapbuf_size4_5_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_6_sram;
wire [0:2] mux_tree_like_tapbuf_size4_6_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_7_sram;
wire [0:2] mux_tree_like_tapbuf_size4_7_sram_inv;
wire [0:2] mux_tree_like_tapbuf_size4_8_sram;
wire [0:2] mux_tree_like_tapbuf_size4_8_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size4_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size4_mem_8_ccff_tail;
wire [0:2] mux_tree_like_tapbuf_size5_0_sram;
wire [0:2] mux_tree_like_tapbuf_size5_0_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size5_mem_0_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size8_0_sram;
wire [0:3] mux_tree_like_tapbuf_size8_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_10_sram;
wire [0:3] mux_tree_like_tapbuf_size8_10_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_11_sram;
wire [0:3] mux_tree_like_tapbuf_size8_11_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_1_sram;
wire [0:3] mux_tree_like_tapbuf_size8_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_2_sram;
wire [0:3] mux_tree_like_tapbuf_size8_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_3_sram;
wire [0:3] mux_tree_like_tapbuf_size8_3_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_4_sram;
wire [0:3] mux_tree_like_tapbuf_size8_4_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_5_sram;
wire [0:3] mux_tree_like_tapbuf_size8_5_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_6_sram;
wire [0:3] mux_tree_like_tapbuf_size8_6_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_7_sram;
wire [0:3] mux_tree_like_tapbuf_size8_7_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_8_sram;
wire [0:3] mux_tree_like_tapbuf_size8_8_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size8_9_sram;
wire [0:3] mux_tree_like_tapbuf_size8_9_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size8_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_10_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_11_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size8_mem_9_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size9_0_sram;
wire [0:3] mux_tree_like_tapbuf_size9_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_1_sram;
wire [0:3] mux_tree_like_tapbuf_size9_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_2_sram;
wire [0:3] mux_tree_like_tapbuf_size9_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_3_sram;
wire [0:3] mux_tree_like_tapbuf_size9_3_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_4_sram;
wire [0:3] mux_tree_like_tapbuf_size9_4_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_5_sram;
wire [0:3] mux_tree_like_tapbuf_size9_5_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_6_sram;
wire [0:3] mux_tree_like_tapbuf_size9_6_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size9_7_sram;
wire [0:3] mux_tree_like_tapbuf_size9_7_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size9_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size9_mem_7_ccff_tail;

// ----- BEGIN Local short connections -----
// ----- Local connection due to Wire 0 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_3_[0] = chany_top_in_1_[0];
// ----- Local connection due to Wire 1 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_5_[0] = chany_top_in_3_[0];
// ----- Local connection due to Wire 2 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_7_[0] = chany_top_in_5_[0];
// ----- Local connection due to Wire 3 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_9_[0] = chany_top_in_7_[0];
// ----- Local connection due to Wire 4 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_11_[0] = chany_top_in_9_[0];
// ----- Local connection due to Wire 5 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_13_[0] = chany_top_in_11_[0];
// ----- Local connection due to Wire 6 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_15_[0] = chany_top_in_13_[0];
// ----- Local connection due to Wire 8 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_19_[0] = chany_top_in_17_[0];
// ----- Local connection due to Wire 9 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_21_[0] = chany_top_in_19_[0];
// ----- Local connection due to Wire 10 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_23_[0] = chany_top_in_21_[0];
// ----- Local connection due to Wire 12 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_27_[0] = chany_top_in_25_[0];
// ----- Local connection due to Wire 13 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_29_[0] = chany_top_in_27_[0];
// ----- Local connection due to Wire 14 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_31_[0] = chany_top_in_29_[0];
// ----- Local connection due to Wire 16 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_35_[0] = chany_top_in_33_[0];
// ----- Local connection due to Wire 17 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_37_[0] = chany_top_in_35_[0];
// ----- Local connection due to Wire 18 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_39_[0] = chany_top_in_37_[0];
// ----- Local connection due to Wire 20 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_43_[0] = chany_top_in_41_[0];
// ----- Local connection due to Wire 21 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_45_[0] = chany_top_in_43_[0];
// ----- Local connection due to Wire 22 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_47_[0] = chany_top_in_45_[0];
// ----- Local connection due to Wire 24 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_51_[0] = chany_top_in_49_[0];
// ----- Local connection due to Wire 25 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_53_[0] = chany_top_in_51_[0];
// ----- Local connection due to Wire 26 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_55_[0] = chany_top_in_53_[0];
// ----- Local connection due to Wire 27 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_111_[0] = chany_top_in_55_[0];
// ----- Local connection due to Wire 28 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_59_[0] = chany_top_in_57_[0];
// ----- Local connection due to Wire 29 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_61_[0] = chany_top_in_59_[0];
// ----- Local connection due to Wire 30 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_63_[0] = chany_top_in_61_[0];
// ----- Local connection due to Wire 31 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_109_[0] = chany_top_in_63_[0];
// ----- Local connection due to Wire 32 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_67_[0] = chany_top_in_65_[0];
// ----- Local connection due to Wire 33 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_69_[0] = chany_top_in_67_[0];
// ----- Local connection due to Wire 34 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_71_[0] = chany_top_in_69_[0];
// ----- Local connection due to Wire 35 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_107_[0] = chany_top_in_71_[0];
// ----- Local connection due to Wire 36 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_75_[0] = chany_top_in_73_[0];
// ----- Local connection due to Wire 37 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_77_[0] = chany_top_in_75_[0];
// ----- Local connection due to Wire 38 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_79_[0] = chany_top_in_77_[0];
// ----- Local connection due to Wire 40 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_83_[0] = chany_top_in_81_[0];
// ----- Local connection due to Wire 41 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_85_[0] = chany_top_in_83_[0];
// ----- Local connection due to Wire 42 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_87_[0] = chany_top_in_85_[0];
// ----- Local connection due to Wire 44 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_91_[0] = chany_top_in_89_[0];
// ----- Local connection due to Wire 45 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_93_[0] = chany_top_in_91_[0];
// ----- Local connection due to Wire 46 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_95_[0] = chany_top_in_93_[0];
// ----- Local connection due to Wire 48 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_99_[0] = chany_top_in_97_[0];
// ----- Local connection due to Wire 49 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_101_[0] = chany_top_in_99_[0];
// ----- Local connection due to Wire 50 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_103_[0] = chany_top_in_101_[0];
// ----- Local connection due to Wire 52 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_107_[0] = chany_top_in_105_[0];
// ----- Local connection due to Wire 53 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_bottom_out_109_[0] = chany_top_in_107_[0];
// ----- Local connection due to Wire 54 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_111_[0] = chany_top_in_109_[0];
// ----- Local connection due to Wire 56 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_115_[0] = chany_top_in_113_[0];
// ----- Local connection due to Wire 57 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_117_[0] = chany_top_in_115_[0];
// ----- Local connection due to Wire 58 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_119_[0] = chany_top_in_117_[0];
// ----- Local connection due to Wire 59 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chanx_left_out_95_[0] = chany_top_in_119_[0];
// ----- Local connection due to Wire 66 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_2_[0] = chany_bottom_in_0_[0];
// ----- Local connection due to Wire 67 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_4_[0] = chany_bottom_in_2_[0];
// ----- Local connection due to Wire 68 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_6_[0] = chany_bottom_in_4_[0];
// ----- Local connection due to Wire 69 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_8_[0] = chany_bottom_in_6_[0];
// ----- Local connection due to Wire 70 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_10_[0] = chany_bottom_in_8_[0];
// ----- Local connection due to Wire 71 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_12_[0] = chany_bottom_in_10_[0];
// ----- Local connection due to Wire 72 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_14_[0] = chany_bottom_in_12_[0];
// ----- Local connection due to Wire 74 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_18_[0] = chany_bottom_in_16_[0];
// ----- Local connection due to Wire 75 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_20_[0] = chany_bottom_in_18_[0];
// ----- Local connection due to Wire 76 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_22_[0] = chany_bottom_in_20_[0];
// ----- Local connection due to Wire 78 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_26_[0] = chany_bottom_in_24_[0];
// ----- Local connection due to Wire 79 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_28_[0] = chany_bottom_in_26_[0];
// ----- Local connection due to Wire 80 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_30_[0] = chany_bottom_in_28_[0];
// ----- Local connection due to Wire 82 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_34_[0] = chany_bottom_in_32_[0];
// ----- Local connection due to Wire 83 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_36_[0] = chany_bottom_in_34_[0];
// ----- Local connection due to Wire 84 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_38_[0] = chany_bottom_in_36_[0];
// ----- Local connection due to Wire 86 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_42_[0] = chany_bottom_in_40_[0];
// ----- Local connection due to Wire 87 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_44_[0] = chany_bottom_in_42_[0];
// ----- Local connection due to Wire 88 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_46_[0] = chany_bottom_in_44_[0];
// ----- Local connection due to Wire 90 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_50_[0] = chany_bottom_in_48_[0];
// ----- Local connection due to Wire 91 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_52_[0] = chany_bottom_in_50_[0];
// ----- Local connection due to Wire 92 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_54_[0] = chany_bottom_in_52_[0];
// ----- Local connection due to Wire 94 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_58_[0] = chany_bottom_in_56_[0];
// ----- Local connection due to Wire 95 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_60_[0] = chany_bottom_in_58_[0];
// ----- Local connection due to Wire 96 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_62_[0] = chany_bottom_in_60_[0];
// ----- Local connection due to Wire 98 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_66_[0] = chany_bottom_in_64_[0];
// ----- Local connection due to Wire 99 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_68_[0] = chany_bottom_in_66_[0];
// ----- Local connection due to Wire 100 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_70_[0] = chany_bottom_in_68_[0];
// ----- Local connection due to Wire 102 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_74_[0] = chany_bottom_in_72_[0];
// ----- Local connection due to Wire 103 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_76_[0] = chany_bottom_in_74_[0];
// ----- Local connection due to Wire 104 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_78_[0] = chany_bottom_in_76_[0];
// ----- Local connection due to Wire 106 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_82_[0] = chany_bottom_in_80_[0];
// ----- Local connection due to Wire 107 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_84_[0] = chany_bottom_in_82_[0];
// ----- Local connection due to Wire 108 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_86_[0] = chany_bottom_in_84_[0];
// ----- Local connection due to Wire 110 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_90_[0] = chany_bottom_in_88_[0];
// ----- Local connection due to Wire 111 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_92_[0] = chany_bottom_in_90_[0];
// ----- Local connection due to Wire 112 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_94_[0] = chany_bottom_in_92_[0];
// ----- Local connection due to Wire 114 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_98_[0] = chany_bottom_in_96_[0];
// ----- Local connection due to Wire 115 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_100_[0] = chany_bottom_in_98_[0];
// ----- Local connection due to Wire 116 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_102_[0] = chany_bottom_in_100_[0];
// ----- Local connection due to Wire 118 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_106_[0] = chany_bottom_in_104_[0];
// ----- Local connection due to Wire 119 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_108_[0] = chany_bottom_in_106_[0];
// ----- Local connection due to Wire 120 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_110_[0] = chany_bottom_in_108_[0];
// ----- Local connection due to Wire 122 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_114_[0] = chany_bottom_in_112_[0];
// ----- Local connection due to Wire 123 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_116_[0] = chany_bottom_in_114_[0];
// ----- Local connection due to Wire 124 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_118_[0] = chany_bottom_in_116_[0];
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	mux_tree_like_tapbuf_size15 mux_top_track_0 (
		.in({top_left_grid_pin_30_[0], top_left_grid_pin_31_[0], top_left_grid_pin_32_[0], top_left_grid_pin_33_[0], top_left_grid_pin_34_[0], top_right_grid_pin_1_[0], chanx_left_in_0_[0], chanx_left_in_28_[0], chanx_left_in_56_[0], chanx_left_in_84_[0], chanx_left_in_112_[0], chany_bottom_in_0_[0], chany_bottom_in_34_[0], chany_bottom_in_72_[0], chany_bottom_in_108_[0]}),
		.sram(mux_tree_like_tapbuf_size15_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size15_0_sram_inv[0:3]),
		.out(chany_top_out_0_[0]));

	mux_tree_like_tapbuf_size15 mux_bottom_track_1 (
		.in({bottom_right_grid_pin_1_[0], bottom_left_grid_pin_30_[0], bottom_left_grid_pin_31_[0], bottom_left_grid_pin_32_[0], bottom_left_grid_pin_33_[0], bottom_left_grid_pin_34_[0], chanx_left_in_2_[0], chanx_left_in_30_[0], chanx_left_in_58_[0], chanx_left_in_86_[0], chanx_left_in_114_[0], chany_top_in_1_[0], chany_top_in_35_[0], chany_top_in_73_[0], chany_top_in_109_[0]}),
		.sram(mux_tree_like_tapbuf_size15_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size15_1_sram_inv[0:3]),
		.out(chany_bottom_out_1_[0]));

	mux_tree_like_tapbuf_size15_mem mem_top_track_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(mux_tree_like_tapbuf_size15_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size15_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size15_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size15_mem mem_bottom_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size15_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size15_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size15_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size10 mux_top_track_16 (
		.in({top_left_grid_pin_30_[0], top_left_grid_pin_31_[0], chanx_left_in_26_[0], chanx_left_in_54_[0], chanx_left_in_82_[0], chanx_left_in_110_[0], chany_bottom_in_2_[0], chany_bottom_in_36_[0], chany_bottom_in_74_[0], chany_bottom_in_112_[0]}),
		.sram(mux_tree_like_tapbuf_size10_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size10_0_sram_inv[0:3]),
		.out(chany_top_out_16_[0]));

	mux_tree_like_tapbuf_size10 mux_top_track_24 (
		.in({top_left_grid_pin_31_[0], top_left_grid_pin_32_[0], chanx_left_in_24_[0], chanx_left_in_52_[0], chanx_left_in_80_[0], chanx_left_in_108_[0], chany_bottom_in_4_[0], chany_bottom_in_40_[0], chany_bottom_in_76_[0], chany_bottom_in_114_[0]}),
		.sram(mux_tree_like_tapbuf_size10_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size10_1_sram_inv[0:3]),
		.out(chany_top_out_24_[0]));

	mux_tree_like_tapbuf_size10 mux_top_track_32 (
		.in({top_left_grid_pin_32_[0], top_left_grid_pin_33_[0], chanx_left_in_22_[0], chanx_left_in_50_[0], chanx_left_in_78_[0], chanx_left_in_106_[0], chany_bottom_in_6_[0], chany_bottom_in_42_[0], chany_bottom_in_80_[0], chany_bottom_in_116_[0]}),
		.sram(mux_tree_like_tapbuf_size10_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size10_2_sram_inv[0:3]),
		.out(chany_top_out_32_[0]));

	mux_tree_like_tapbuf_size10 mux_bottom_track_33 (
		.in({bottom_left_grid_pin_31_[0], bottom_left_grid_pin_32_[0], chanx_left_in_8_[0], chanx_left_in_36_[0], chanx_left_in_64_[0], chanx_left_in_92_[0], chany_top_in_7_[0], chany_top_in_43_[0], chany_top_in_81_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size10_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size10_3_sram_inv[0:3]),
		.out(chany_bottom_out_33_[0]));

	mux_tree_like_tapbuf_size10_mem mem_top_track_16 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size15_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size10_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size10_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size10_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size10_mem mem_top_track_24 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size10_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size10_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size10_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size10_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size10_mem mem_top_track_32 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size10_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size10_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size10_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size10_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size10_mem mem_bottom_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size10_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size10_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size10_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9 mux_top_track_40 (
		.in({top_left_grid_pin_33_[0], top_left_grid_pin_34_[0], chanx_left_in_20_[0], chanx_left_in_48_[0], chanx_left_in_76_[0], chanx_left_in_104_[0], chany_bottom_in_8_[0], chany_bottom_in_44_[0], chany_bottom_in_82_[0]}),
		.sram(mux_tree_like_tapbuf_size9_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_0_sram_inv[0:3]),
		.out(chany_top_out_40_[0]));

	mux_tree_like_tapbuf_size9 mux_top_track_48 (
		.in({top_left_grid_pin_34_[0], top_right_grid_pin_1_[0], chanx_left_in_18_[0], chanx_left_in_46_[0], chanx_left_in_74_[0], chanx_left_in_102_[0], chany_bottom_in_10_[0], chany_bottom_in_48_[0], chany_bottom_in_84_[0]}),
		.sram(mux_tree_like_tapbuf_size9_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_1_sram_inv[0:3]),
		.out(chany_top_out_48_[0]));

	mux_tree_like_tapbuf_size9 mux_top_track_96 (
		.in({top_left_grid_pin_34_[0], chanx_left_in_6_[0], chanx_left_in_34_[0], chanx_left_in_62_[0], chanx_left_in_90_[0], chanx_left_in_118_[0], chany_bottom_in_26_[0], chany_bottom_in_64_[0], chany_bottom_in_100_[0]}),
		.sram(mux_tree_like_tapbuf_size9_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_2_sram_inv[0:3]),
		.out(chany_top_out_96_[0]));

	mux_tree_like_tapbuf_size9 mux_top_track_104 (
		.in({top_right_grid_pin_1_[0], chanx_left_in_4_[0], chanx_left_in_32_[0], chanx_left_in_60_[0], chanx_left_in_88_[0], chanx_left_in_116_[0], chany_bottom_in_28_[0], chany_bottom_in_66_[0], chany_bottom_in_104_[0]}),
		.sram(mux_tree_like_tapbuf_size9_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_3_sram_inv[0:3]),
		.out(chany_top_out_104_[0]));

	mux_tree_like_tapbuf_size9 mux_top_track_112 (
		.in({top_left_grid_pin_30_[0], chanx_left_in_2_[0], chanx_left_in_30_[0], chanx_left_in_58_[0], chanx_left_in_86_[0], chanx_left_in_114_[0], chany_bottom_in_32_[0], chany_bottom_in_68_[0], chany_bottom_in_106_[0]}),
		.sram(mux_tree_like_tapbuf_size9_4_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_4_sram_inv[0:3]),
		.out(chany_top_out_112_[0]));

	mux_tree_like_tapbuf_size9 mux_bottom_track_41 (
		.in({bottom_left_grid_pin_32_[0], bottom_left_grid_pin_33_[0], chanx_left_in_10_[0], chanx_left_in_38_[0], chanx_left_in_66_[0], chanx_left_in_94_[0], chany_top_in_9_[0], chany_top_in_45_[0], chany_top_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size9_5_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_5_sram_inv[0:3]),
		.out(chany_bottom_out_41_[0]));

	mux_tree_like_tapbuf_size9 mux_bottom_track_49 (
		.in({bottom_left_grid_pin_33_[0], bottom_left_grid_pin_34_[0], chanx_left_in_12_[0], chanx_left_in_40_[0], chanx_left_in_68_[0], chanx_left_in_96_[0], chany_top_in_11_[0], chany_top_in_49_[0], chany_top_in_85_[0]}),
		.sram(mux_tree_like_tapbuf_size9_6_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_6_sram_inv[0:3]),
		.out(chany_bottom_out_49_[0]));

	mux_tree_like_tapbuf_size9 mux_bottom_track_113 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_0_[0], chanx_left_in_28_[0], chanx_left_in_56_[0], chanx_left_in_84_[0], chanx_left_in_112_[0], chany_top_in_33_[0], chany_top_in_69_[0], chany_top_in_107_[0]}),
		.sram(mux_tree_like_tapbuf_size9_7_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size9_7_sram_inv[0:3]),
		.out(chany_bottom_out_113_[0]));

	mux_tree_like_tapbuf_size9_mem mem_top_track_40 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size10_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_top_track_48 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_top_track_96 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_top_track_104 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_top_track_112 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_4_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_4_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_bottom_track_41 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size10_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_5_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_5_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_bottom_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_6_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_6_sram_inv[0:3]));

	mux_tree_like_tapbuf_size9_mem mem_bottom_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size9_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size9_7_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size9_7_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8 mux_top_track_56 (
		.in({top_right_grid_pin_1_[0], chanx_left_in_16_[0], chanx_left_in_44_[0], chanx_left_in_72_[0], chanx_left_in_100_[0], chany_bottom_in_12_[0], chany_bottom_in_50_[0], chany_bottom_in_88_[0]}),
		.sram(mux_tree_like_tapbuf_size8_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_0_sram_inv[0:3]),
		.out(chany_top_out_56_[0]));

	mux_tree_like_tapbuf_size8 mux_top_track_64 (
		.in({top_left_grid_pin_30_[0], chanx_left_in_14_[0], chanx_left_in_42_[0], chanx_left_in_70_[0], chanx_left_in_98_[0], chany_bottom_in_16_[0], chany_bottom_in_52_[0], chany_bottom_in_90_[0]}),
		.sram(mux_tree_like_tapbuf_size8_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_1_sram_inv[0:3]),
		.out(chany_top_out_64_[0]));

	mux_tree_like_tapbuf_size8 mux_top_track_72 (
		.in({top_left_grid_pin_31_[0], chanx_left_in_12_[0], chanx_left_in_40_[0], chanx_left_in_68_[0], chanx_left_in_96_[0], chany_bottom_in_18_[0], chany_bottom_in_56_[0], chany_bottom_in_92_[0]}),
		.sram(mux_tree_like_tapbuf_size8_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_2_sram_inv[0:3]),
		.out(chany_top_out_72_[0]));

	mux_tree_like_tapbuf_size8 mux_top_track_80 (
		.in({top_left_grid_pin_32_[0], chanx_left_in_10_[0], chanx_left_in_38_[0], chanx_left_in_66_[0], chanx_left_in_94_[0], chany_bottom_in_20_[0], chany_bottom_in_58_[0], chany_bottom_in_96_[0]}),
		.sram(mux_tree_like_tapbuf_size8_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_3_sram_inv[0:3]),
		.out(chany_top_out_80_[0]));

	mux_tree_like_tapbuf_size8 mux_top_track_88 (
		.in({top_left_grid_pin_33_[0], chanx_left_in_8_[0], chanx_left_in_36_[0], chanx_left_in_64_[0], chanx_left_in_92_[0], chany_bottom_in_24_[0], chany_bottom_in_60_[0], chany_bottom_in_98_[0]}),
		.sram(mux_tree_like_tapbuf_size8_4_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_4_sram_inv[0:3]),
		.out(chany_top_out_88_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_57 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_14_[0], chanx_left_in_42_[0], chanx_left_in_70_[0], chanx_left_in_98_[0], chany_top_in_13_[0], chany_top_in_51_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size8_5_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_5_sram_inv[0:3]),
		.out(chany_bottom_out_57_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_65 (
		.in({bottom_right_grid_pin_1_[0], chanx_left_in_16_[0], chanx_left_in_44_[0], chanx_left_in_72_[0], chanx_left_in_100_[0], chany_top_in_17_[0], chany_top_in_53_[0], chany_top_in_91_[0]}),
		.sram(mux_tree_like_tapbuf_size8_6_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_6_sram_inv[0:3]),
		.out(chany_bottom_out_65_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_73 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_18_[0], chanx_left_in_46_[0], chanx_left_in_74_[0], chanx_left_in_102_[0], chany_top_in_19_[0], chany_top_in_57_[0], chany_top_in_93_[0]}),
		.sram(mux_tree_like_tapbuf_size8_7_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_7_sram_inv[0:3]),
		.out(chany_bottom_out_73_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_81 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_20_[0], chanx_left_in_48_[0], chanx_left_in_76_[0], chanx_left_in_104_[0], chany_top_in_21_[0], chany_top_in_59_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size8_8_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_8_sram_inv[0:3]),
		.out(chany_bottom_out_81_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_89 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_22_[0], chanx_left_in_50_[0], chanx_left_in_78_[0], chanx_left_in_106_[0], chany_top_in_25_[0], chany_top_in_61_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size8_9_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_9_sram_inv[0:3]),
		.out(chany_bottom_out_89_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_97 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_24_[0], chanx_left_in_52_[0], chanx_left_in_80_[0], chanx_left_in_108_[0], chany_top_in_27_[0], chany_top_in_65_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size8_10_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_10_sram_inv[0:3]),
		.out(chany_bottom_out_97_[0]));

	mux_tree_like_tapbuf_size8 mux_bottom_track_105 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_26_[0], chanx_left_in_54_[0], chanx_left_in_82_[0], chanx_left_in_110_[0], chany_top_in_29_[0], chany_top_in_67_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size8_11_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size8_11_sram_inv[0:3]),
		.out(chany_bottom_out_105_[0]));

	mux_tree_like_tapbuf_size8_mem mem_top_track_56 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_top_track_64 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_top_track_72 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_top_track_80 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_top_track_88 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_4_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_4_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_57 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_5_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_5_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_6_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_6_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_73 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_7_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_7_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_8_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_8_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_89 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_9_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_9_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_10_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_10_sram_inv[0:3]));

	mux_tree_like_tapbuf_size8_mem mem_bottom_track_105 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size8_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size8_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size8_11_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size8_11_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11 mux_bottom_track_17 (
		.in({bottom_right_grid_pin_1_[0], bottom_left_grid_pin_30_[0], chanx_left_in_4_[0], chanx_left_in_32_[0], chanx_left_in_60_[0], chanx_left_in_88_[0], chanx_left_in_116_[0], chany_top_in_3_[0], chany_top_in_37_[0], chany_top_in_75_[0], chany_top_in_113_[0]}),
		.sram(mux_tree_like_tapbuf_size11_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_0_sram_inv[0:3]),
		.out(chany_bottom_out_17_[0]));

	mux_tree_like_tapbuf_size11 mux_bottom_track_25 (
		.in({bottom_left_grid_pin_30_[0], bottom_left_grid_pin_31_[0], chanx_left_in_6_[0], chanx_left_in_34_[0], chanx_left_in_62_[0], chanx_left_in_90_[0], chanx_left_in_118_[0], chany_top_in_5_[0], chany_top_in_41_[0], chany_top_in_77_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size11_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_1_sram_inv[0:3]),
		.out(chany_bottom_out_25_[0]));

	mux_tree_like_tapbuf_size11_mem mem_bottom_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size15_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_bottom_track_25 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size4 mux_left_track_1 (
		.in({left_top_grid_pin_35_[0], chany_bottom_in_0_[0], chany_top_in_1_[0], chany_top_in_15_[0]}),
		.sram(mux_tree_like_tapbuf_size4_0_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_0_sram_inv[0:2]),
		.out(chanx_left_out_1_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_3 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_2_[0], chany_top_in_3_[0], chany_bottom_in_14_[0]}),
		.sram(mux_tree_like_tapbuf_size4_1_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_1_sram_inv[0:2]),
		.out(chanx_left_out_3_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_5 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_4_[0], chany_top_in_5_[0], chany_bottom_in_22_[0]}),
		.sram(mux_tree_like_tapbuf_size4_2_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_2_sram_inv[0:2]),
		.out(chanx_left_out_5_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_7 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_6_[0], chany_top_in_7_[0], chany_bottom_in_30_[0]}),
		.sram(mux_tree_like_tapbuf_size4_3_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_3_sram_inv[0:2]),
		.out(chanx_left_out_7_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_9 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_8_[0], chany_top_in_9_[0], chany_bottom_in_38_[0]}),
		.sram(mux_tree_like_tapbuf_size4_4_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_4_sram_inv[0:2]),
		.out(chanx_left_out_9_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_19 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_20_[0], chany_top_in_21_[0], chany_bottom_in_78_[0]}),
		.sram(mux_tree_like_tapbuf_size4_5_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_5_sram_inv[0:2]),
		.out(chanx_left_out_19_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_21 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_24_[0], chany_top_in_25_[0], chany_bottom_in_86_[0]}),
		.sram(mux_tree_like_tapbuf_size4_6_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_6_sram_inv[0:2]),
		.out(chanx_left_out_21_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_23 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_26_[0], chany_top_in_27_[0], chany_bottom_in_94_[0]}),
		.sram(mux_tree_like_tapbuf_size4_7_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_7_sram_inv[0:2]),
		.out(chanx_left_out_23_[0]));

	mux_tree_like_tapbuf_size4 mux_left_track_25 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_28_[0], chany_top_in_29_[0], chany_bottom_in_102_[0]}),
		.sram(mux_tree_like_tapbuf_size4_8_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size4_8_sram_inv[0:2]),
		.out(chanx_left_out_25_[0]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size9_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_0_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_0_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_3 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_1_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_1_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_5 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_2_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_2_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_7 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_3_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_3_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_9 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_4_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_4_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_19 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size5_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_5_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_5_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_21 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_6_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_6_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_23 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_7_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_7_sram_inv[0:2]));

	mux_tree_like_tapbuf_size4_mem mem_left_track_25 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size4_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size4_8_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size4_8_sram_inv[0:2]));

	mux_tree_like_tapbuf_size3 mux_left_track_11 (
		.in({chany_bottom_in_10_[0], chany_top_in_11_[0], chany_bottom_in_46_[0]}),
		.sram(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]),
		.out(chanx_left_out_11_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_13 (
		.in({chany_bottom_in_12_[0], chany_top_in_13_[0], chany_bottom_in_54_[0]}),
		.sram(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]),
		.out(chanx_left_out_13_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_15 (
		.in({chany_bottom_in_16_[0], chany_top_in_17_[0], chany_bottom_in_62_[0]}),
		.sram(mux_tree_like_tapbuf_size3_2_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_2_sram_inv[0:1]),
		.out(chanx_left_out_15_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_27 (
		.in({chany_bottom_in_32_[0], chany_top_in_33_[0], chany_bottom_in_110_[0]}),
		.sram(mux_tree_like_tapbuf_size3_3_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_3_sram_inv[0:1]),
		.out(chanx_left_out_27_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_29 (
		.in({chany_bottom_in_34_[0], chany_top_in_35_[0], chany_bottom_in_118_[0]}),
		.sram(mux_tree_like_tapbuf_size3_4_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_4_sram_inv[0:1]),
		.out(chanx_left_out_29_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_33 (
		.in({left_top_grid_pin_35_[0], chany_bottom_in_40_[0], chany_top_in_41_[0]}),
		.sram(mux_tree_like_tapbuf_size3_5_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_5_sram_inv[0:1]),
		.out(chanx_left_out_33_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_35 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_42_[0], chany_top_in_43_[0]}),
		.sram(mux_tree_like_tapbuf_size3_6_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_6_sram_inv[0:1]),
		.out(chanx_left_out_35_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_37 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_44_[0], chany_top_in_45_[0]}),
		.sram(mux_tree_like_tapbuf_size3_7_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_7_sram_inv[0:1]),
		.out(chanx_left_out_37_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_39 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_48_[0], chany_top_in_49_[0]}),
		.sram(mux_tree_like_tapbuf_size3_8_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_8_sram_inv[0:1]),
		.out(chanx_left_out_39_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_41 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_50_[0], chany_top_in_51_[0]}),
		.sram(mux_tree_like_tapbuf_size3_9_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_9_sram_inv[0:1]),
		.out(chanx_left_out_41_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_49 (
		.in({left_top_grid_pin_35_[0], chany_bottom_in_60_[0], chany_top_in_61_[0]}),
		.sram(mux_tree_like_tapbuf_size3_10_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_10_sram_inv[0:1]),
		.out(chanx_left_out_49_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_51 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_64_[0], chany_top_in_65_[0]}),
		.sram(mux_tree_like_tapbuf_size3_11_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_11_sram_inv[0:1]),
		.out(chanx_left_out_51_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_53 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_66_[0], chany_top_in_67_[0]}),
		.sram(mux_tree_like_tapbuf_size3_12_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_12_sram_inv[0:1]),
		.out(chanx_left_out_53_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_55 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_68_[0], chany_top_in_69_[0]}),
		.sram(mux_tree_like_tapbuf_size3_13_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_13_sram_inv[0:1]),
		.out(chanx_left_out_55_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_57 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_72_[0], chany_top_in_73_[0]}),
		.sram(mux_tree_like_tapbuf_size3_14_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_14_sram_inv[0:1]),
		.out(chanx_left_out_57_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_65 (
		.in({left_top_grid_pin_35_[0], chany_bottom_in_82_[0], chany_top_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size3_15_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_15_sram_inv[0:1]),
		.out(chanx_left_out_65_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_67 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_84_[0], chany_top_in_85_[0]}),
		.sram(mux_tree_like_tapbuf_size3_16_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_16_sram_inv[0:1]),
		.out(chanx_left_out_67_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_69 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_88_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size3_17_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_17_sram_inv[0:1]),
		.out(chanx_left_out_69_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_71 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_90_[0], chany_top_in_91_[0]}),
		.sram(mux_tree_like_tapbuf_size3_18_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_18_sram_inv[0:1]),
		.out(chanx_left_out_71_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_73 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_92_[0], chany_top_in_93_[0]}),
		.sram(mux_tree_like_tapbuf_size3_19_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_19_sram_inv[0:1]),
		.out(chanx_left_out_73_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_81 (
		.in({left_top_grid_pin_35_[0], chany_bottom_in_104_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size3_20_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_20_sram_inv[0:1]),
		.out(chanx_left_out_81_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_83 (
		.in({left_top_grid_pin_36_[0], chany_bottom_in_106_[0], chany_top_in_107_[0]}),
		.sram(mux_tree_like_tapbuf_size3_21_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_21_sram_inv[0:1]),
		.out(chanx_left_out_83_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_85 (
		.in({left_top_grid_pin_37_[0], chany_bottom_in_108_[0], chany_top_in_109_[0]}),
		.sram(mux_tree_like_tapbuf_size3_22_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_22_sram_inv[0:1]),
		.out(chanx_left_out_85_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_87 (
		.in({left_top_grid_pin_38_[0], chany_bottom_in_112_[0], chany_top_in_113_[0]}),
		.sram(mux_tree_like_tapbuf_size3_23_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_23_sram_inv[0:1]),
		.out(chanx_left_out_87_[0]));

	mux_tree_like_tapbuf_size3 mux_left_track_89 (
		.in({left_top_grid_pin_39_[0], chany_bottom_in_114_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size3_24_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size3_24_sram_inv[0:1]),
		.out(chanx_left_out_89_[0]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_11 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_13 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_1_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_15 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_2_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_2_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_27 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size4_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_3_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_3_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_29 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_4_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_4_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_5_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_5_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_35 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_6_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_6_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_37 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_7_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_7_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_39 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_8_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_8_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_41 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_9_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_9_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_10_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_10_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_51 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_11_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_11_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_53 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_12_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_12_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_55 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_13_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_13_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_57 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_14_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_14_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_15_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_15_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_67 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_16_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_16_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_69 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_17_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_17_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_71 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_18_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_18_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_73 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_18_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_19_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_19_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_19_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_20_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_20_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_20_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_83 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_20_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_21_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_21_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_21_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_85 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_21_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_22_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_22_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_22_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_87 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_22_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_23_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_23_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_23_sram_inv[0:1]));

	mux_tree_like_tapbuf_size3_mem mem_left_track_89 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_23_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size3_mem_24_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size3_24_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size3_24_sram_inv[0:1]));

	mux_tree_like_tapbuf_size5 mux_left_track_17 (
		.in({left_top_grid_pin_35_[0], left_top_grid_pin_39_[0], chany_bottom_in_18_[0], chany_top_in_19_[0], chany_bottom_in_70_[0]}),
		.sram(mux_tree_like_tapbuf_size5_0_sram[0:2]),
		.sram_inv(mux_tree_like_tapbuf_size5_0_sram_inv[0:2]),
		.out(chanx_left_out_17_[0]));

	mux_tree_like_tapbuf_size5_mem mem_left_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size5_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size5_0_sram[0:2]),
		.mem_outb(mux_tree_like_tapbuf_size5_0_sram_inv[0:2]));

	mux_tree_like_tapbuf_size2 mux_left_track_31 (
		.in({chany_bottom_in_36_[0], chany_top_in_37_[0]}),
		.sram(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]),
		.out(chanx_left_out_31_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_43 (
		.in({chany_bottom_in_52_[0], chany_top_in_53_[0]}),
		.sram(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]),
		.out(chanx_left_out_43_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_45 (
		.in({chany_bottom_in_56_[0], chany_top_in_57_[0]}),
		.sram(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]),
		.out(chanx_left_out_45_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_47 (
		.in({chany_bottom_in_58_[0], chany_top_in_59_[0]}),
		.sram(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]),
		.out(chanx_left_out_47_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_59 (
		.in({chany_bottom_in_74_[0], chany_top_in_75_[0]}),
		.sram(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]),
		.out(chanx_left_out_59_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_61 (
		.in({chany_bottom_in_76_[0], chany_top_in_77_[0]}),
		.sram(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]),
		.out(chanx_left_out_61_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_63 (
		.in({chany_bottom_in_80_[0], chany_top_in_81_[0]}),
		.sram(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]),
		.out(chanx_left_out_63_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_75 (
		.in({chany_bottom_in_96_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]),
		.out(chanx_left_out_75_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_77 (
		.in({chany_bottom_in_98_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]),
		.out(chanx_left_out_77_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_79 (
		.in({chany_bottom_in_100_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]),
		.out(chanx_left_out_79_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_91 (
		.in({chany_bottom_in_116_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]),
		.out(chanx_left_out_91_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_97 (
		.in({left_top_grid_pin_35_[0], chany_top_in_111_[0]}),
		.sram(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]),
		.out(chanx_left_out_97_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_99 (
		.in({left_top_grid_pin_36_[0], chany_top_in_103_[0]}),
		.sram(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]),
		.out(chanx_left_out_99_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_101 (
		.in({left_top_grid_pin_37_[0], chany_top_in_95_[0]}),
		.sram(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]),
		.out(chanx_left_out_101_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_103 (
		.in({left_top_grid_pin_38_[0], chany_top_in_87_[0]}),
		.sram(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]),
		.out(chanx_left_out_103_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_105 (
		.in({left_top_grid_pin_39_[0], chany_top_in_79_[0]}),
		.sram(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]),
		.out(chanx_left_out_105_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_113 (
		.in({left_top_grid_pin_35_[0], chany_top_in_47_[0]}),
		.sram(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]),
		.out(chanx_left_out_113_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_115 (
		.in({left_top_grid_pin_36_[0], chany_top_in_39_[0]}),
		.sram(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]),
		.out(chanx_left_out_115_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_117 (
		.in({left_top_grid_pin_37_[0], chany_top_in_31_[0]}),
		.sram(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]),
		.out(chanx_left_out_117_[0]));

	mux_tree_like_tapbuf_size2 mux_left_track_119 (
		.in({left_top_grid_pin_38_[0], chany_top_in_23_[0]}),
		.sram(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.sram_inv(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]),
		.out(chanx_left_out_119_[0]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_31 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_0_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_0_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_43 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_1_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_1_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_45 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_2_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_2_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_47 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_3_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_3_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_59 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_4_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_4_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_61 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_5_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_5_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_63 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_6_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_6_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_75 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_19_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_7_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_7_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_77 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_8_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_8_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_79 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_9_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_9_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_91 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size3_mem_24_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_10_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_10_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_11_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_11_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_99 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_12_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_12_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_101 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_13_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_13_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_103 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_14_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_14_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_105 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_15_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_15_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_16_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_16_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_115 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_17_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_17_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_117 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_18_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_18_sram_inv[0:1]));

	mux_tree_like_tapbuf_size2_mem mem_left_track_119 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size2_mem_18_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size2_19_sram[0:1]),
		.mem_outb(mux_tree_like_tapbuf_size2_19_sram_inv[0:1]));

endmodule
// ----- END Verilog module for sb_22__1_ -----


