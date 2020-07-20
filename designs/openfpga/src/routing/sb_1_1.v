//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: Verilog modules for Unique Switch Blocks[1][1]
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:43:51 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../fpga_defines.v"
// ----- Verilog module for sb_1__1_ -----
module sb_1__1_(pReset,
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


wire [0:3] mux_tree_like_tapbuf_size11_0_sram;
wire [0:3] mux_tree_like_tapbuf_size11_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_1_sram;
wire [0:3] mux_tree_like_tapbuf_size11_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_2_sram;
wire [0:3] mux_tree_like_tapbuf_size11_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_3_sram;
wire [0:3] mux_tree_like_tapbuf_size11_3_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_4_sram;
wire [0:3] mux_tree_like_tapbuf_size11_4_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_5_sram;
wire [0:3] mux_tree_like_tapbuf_size11_5_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_6_sram;
wire [0:3] mux_tree_like_tapbuf_size11_6_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size11_7_sram;
wire [0:3] mux_tree_like_tapbuf_size11_7_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size11_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size11_mem_7_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size12_0_sram;
wire [0:3] mux_tree_like_tapbuf_size12_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_10_sram;
wire [0:3] mux_tree_like_tapbuf_size12_10_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_11_sram;
wire [0:3] mux_tree_like_tapbuf_size12_11_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_12_sram;
wire [0:3] mux_tree_like_tapbuf_size12_12_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_13_sram;
wire [0:3] mux_tree_like_tapbuf_size12_13_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_14_sram;
wire [0:3] mux_tree_like_tapbuf_size12_14_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_15_sram;
wire [0:3] mux_tree_like_tapbuf_size12_15_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_16_sram;
wire [0:3] mux_tree_like_tapbuf_size12_16_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_17_sram;
wire [0:3] mux_tree_like_tapbuf_size12_17_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_18_sram;
wire [0:3] mux_tree_like_tapbuf_size12_18_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_19_sram;
wire [0:3] mux_tree_like_tapbuf_size12_19_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_1_sram;
wire [0:3] mux_tree_like_tapbuf_size12_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_20_sram;
wire [0:3] mux_tree_like_tapbuf_size12_20_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_21_sram;
wire [0:3] mux_tree_like_tapbuf_size12_21_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_22_sram;
wire [0:3] mux_tree_like_tapbuf_size12_22_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_23_sram;
wire [0:3] mux_tree_like_tapbuf_size12_23_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_24_sram;
wire [0:3] mux_tree_like_tapbuf_size12_24_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_25_sram;
wire [0:3] mux_tree_like_tapbuf_size12_25_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_26_sram;
wire [0:3] mux_tree_like_tapbuf_size12_26_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_27_sram;
wire [0:3] mux_tree_like_tapbuf_size12_27_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_2_sram;
wire [0:3] mux_tree_like_tapbuf_size12_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_3_sram;
wire [0:3] mux_tree_like_tapbuf_size12_3_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_4_sram;
wire [0:3] mux_tree_like_tapbuf_size12_4_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_5_sram;
wire [0:3] mux_tree_like_tapbuf_size12_5_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_6_sram;
wire [0:3] mux_tree_like_tapbuf_size12_6_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_7_sram;
wire [0:3] mux_tree_like_tapbuf_size12_7_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_8_sram;
wire [0:3] mux_tree_like_tapbuf_size12_8_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size12_9_sram;
wire [0:3] mux_tree_like_tapbuf_size12_9_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size12_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_10_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_11_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_12_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_13_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_14_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_15_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_16_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_17_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_18_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_19_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_20_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_21_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_22_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_23_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_24_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_25_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_26_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size12_mem_9_ccff_tail;
wire [0:3] mux_tree_like_tapbuf_size13_0_sram;
wire [0:3] mux_tree_like_tapbuf_size13_0_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size13_1_sram;
wire [0:3] mux_tree_like_tapbuf_size13_1_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size13_2_sram;
wire [0:3] mux_tree_like_tapbuf_size13_2_sram_inv;
wire [0:3] mux_tree_like_tapbuf_size13_3_sram;
wire [0:3] mux_tree_like_tapbuf_size13_3_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size13_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size13_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size13_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size13_mem_3_ccff_tail;
wire [0:4] mux_tree_like_tapbuf_size16_0_sram;
wire [0:4] mux_tree_like_tapbuf_size16_0_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_10_sram;
wire [0:4] mux_tree_like_tapbuf_size16_10_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_11_sram;
wire [0:4] mux_tree_like_tapbuf_size16_11_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_1_sram;
wire [0:4] mux_tree_like_tapbuf_size16_1_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_2_sram;
wire [0:4] mux_tree_like_tapbuf_size16_2_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_3_sram;
wire [0:4] mux_tree_like_tapbuf_size16_3_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_4_sram;
wire [0:4] mux_tree_like_tapbuf_size16_4_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_5_sram;
wire [0:4] mux_tree_like_tapbuf_size16_5_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_6_sram;
wire [0:4] mux_tree_like_tapbuf_size16_6_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_7_sram;
wire [0:4] mux_tree_like_tapbuf_size16_7_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_8_sram;
wire [0:4] mux_tree_like_tapbuf_size16_8_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size16_9_sram;
wire [0:4] mux_tree_like_tapbuf_size16_9_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size16_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_10_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_11_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_3_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_4_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_5_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_6_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_7_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_8_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size16_mem_9_ccff_tail;
wire [0:4] mux_tree_like_tapbuf_size19_0_sram;
wire [0:4] mux_tree_like_tapbuf_size19_0_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size19_1_sram;
wire [0:4] mux_tree_like_tapbuf_size19_1_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size19_2_sram;
wire [0:4] mux_tree_like_tapbuf_size19_2_sram_inv;
wire [0:4] mux_tree_like_tapbuf_size19_3_sram;
wire [0:4] mux_tree_like_tapbuf_size19_3_sram_inv;
wire [0:0] mux_tree_like_tapbuf_size19_mem_0_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size19_mem_1_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size19_mem_2_ccff_tail;
wire [0:0] mux_tree_like_tapbuf_size19_mem_3_ccff_tail;

// ----- BEGIN Local short connections -----
// ----- Local connection due to Wire 0 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_3_[0] = chany_top_in_1_[0];
// ----- Local connection due to Wire 1 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_5_[0] = chany_top_in_3_[0];
// ----- Local connection due to Wire 2 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_7_[0] = chany_top_in_5_[0];
// ----- Local connection due to Wire 3 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_9_[0] = chany_top_in_7_[0];
// ----- Local connection due to Wire 4 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_11_[0] = chany_top_in_9_[0];
// ----- Local connection due to Wire 5 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_13_[0] = chany_top_in_11_[0];
// ----- Local connection due to Wire 6 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_15_[0] = chany_top_in_13_[0];
// ----- Local connection due to Wire 8 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_19_[0] = chany_top_in_17_[0];
// ----- Local connection due to Wire 9 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_21_[0] = chany_top_in_19_[0];
// ----- Local connection due to Wire 10 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_23_[0] = chany_top_in_21_[0];
// ----- Local connection due to Wire 12 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_27_[0] = chany_top_in_25_[0];
// ----- Local connection due to Wire 13 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_29_[0] = chany_top_in_27_[0];
// ----- Local connection due to Wire 14 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_31_[0] = chany_top_in_29_[0];
// ----- Local connection due to Wire 16 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_35_[0] = chany_top_in_33_[0];
// ----- Local connection due to Wire 17 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_37_[0] = chany_top_in_35_[0];
// ----- Local connection due to Wire 18 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_39_[0] = chany_top_in_37_[0];
// ----- Local connection due to Wire 20 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_43_[0] = chany_top_in_41_[0];
// ----- Local connection due to Wire 21 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_45_[0] = chany_top_in_43_[0];
// ----- Local connection due to Wire 22 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_47_[0] = chany_top_in_45_[0];
// ----- Local connection due to Wire 24 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_51_[0] = chany_top_in_49_[0];
// ----- Local connection due to Wire 25 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_53_[0] = chany_top_in_51_[0];
// ----- Local connection due to Wire 26 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_55_[0] = chany_top_in_53_[0];
// ----- Local connection due to Wire 28 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_59_[0] = chany_top_in_57_[0];
// ----- Local connection due to Wire 29 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_61_[0] = chany_top_in_59_[0];
// ----- Local connection due to Wire 30 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_63_[0] = chany_top_in_61_[0];
// ----- Local connection due to Wire 32 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_67_[0] = chany_top_in_65_[0];
// ----- Local connection due to Wire 33 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_69_[0] = chany_top_in_67_[0];
// ----- Local connection due to Wire 34 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_71_[0] = chany_top_in_69_[0];
// ----- Local connection due to Wire 36 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_75_[0] = chany_top_in_73_[0];
// ----- Local connection due to Wire 37 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_77_[0] = chany_top_in_75_[0];
// ----- Local connection due to Wire 38 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_79_[0] = chany_top_in_77_[0];
// ----- Local connection due to Wire 40 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_83_[0] = chany_top_in_81_[0];
// ----- Local connection due to Wire 41 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_85_[0] = chany_top_in_83_[0];
// ----- Local connection due to Wire 42 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_87_[0] = chany_top_in_85_[0];
// ----- Local connection due to Wire 44 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_91_[0] = chany_top_in_89_[0];
// ----- Local connection due to Wire 45 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_93_[0] = chany_top_in_91_[0];
// ----- Local connection due to Wire 46 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_95_[0] = chany_top_in_93_[0];
// ----- Local connection due to Wire 48 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_99_[0] = chany_top_in_97_[0];
// ----- Local connection due to Wire 49 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_101_[0] = chany_top_in_99_[0];
// ----- Local connection due to Wire 50 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_103_[0] = chany_top_in_101_[0];
// ----- Local connection due to Wire 52 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_107_[0] = chany_top_in_105_[0];
// ----- Local connection due to Wire 53 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_bottom_out_109_[0] = chany_top_in_107_[0];
// ----- Local connection due to Wire 54 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_111_[0] = chany_top_in_109_[0];
// ----- Local connection due to Wire 56 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_115_[0] = chany_top_in_113_[0];
// ----- Local connection due to Wire 57 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_117_[0] = chany_top_in_115_[0];
// ----- Local connection due to Wire 58 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chany_bottom_out_119_[0] = chany_top_in_117_[0];
// ----- Local connection due to Wire 65 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_3_[0] = chanx_right_in_1_[0];
// ----- Local connection due to Wire 66 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_5_[0] = chanx_right_in_3_[0];
// ----- Local connection due to Wire 67 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_7_[0] = chanx_right_in_5_[0];
// ----- Local connection due to Wire 68 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_9_[0] = chanx_right_in_7_[0];
// ----- Local connection due to Wire 69 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_11_[0] = chanx_right_in_9_[0];
// ----- Local connection due to Wire 70 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_13_[0] = chanx_right_in_11_[0];
// ----- Local connection due to Wire 71 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_15_[0] = chanx_right_in_13_[0];
// ----- Local connection due to Wire 73 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_19_[0] = chanx_right_in_17_[0];
// ----- Local connection due to Wire 74 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_21_[0] = chanx_right_in_19_[0];
// ----- Local connection due to Wire 75 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_23_[0] = chanx_right_in_21_[0];
// ----- Local connection due to Wire 77 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_27_[0] = chanx_right_in_25_[0];
// ----- Local connection due to Wire 78 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_29_[0] = chanx_right_in_27_[0];
// ----- Local connection due to Wire 79 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_31_[0] = chanx_right_in_29_[0];
// ----- Local connection due to Wire 81 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_35_[0] = chanx_right_in_33_[0];
// ----- Local connection due to Wire 82 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_37_[0] = chanx_right_in_35_[0];
// ----- Local connection due to Wire 83 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_39_[0] = chanx_right_in_37_[0];
// ----- Local connection due to Wire 85 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_43_[0] = chanx_right_in_41_[0];
// ----- Local connection due to Wire 86 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_45_[0] = chanx_right_in_43_[0];
// ----- Local connection due to Wire 87 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_47_[0] = chanx_right_in_45_[0];
// ----- Local connection due to Wire 89 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_51_[0] = chanx_right_in_49_[0];
// ----- Local connection due to Wire 90 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_53_[0] = chanx_right_in_51_[0];
// ----- Local connection due to Wire 91 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_55_[0] = chanx_right_in_53_[0];
// ----- Local connection due to Wire 93 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_59_[0] = chanx_right_in_57_[0];
// ----- Local connection due to Wire 94 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_61_[0] = chanx_right_in_59_[0];
// ----- Local connection due to Wire 95 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_63_[0] = chanx_right_in_61_[0];
// ----- Local connection due to Wire 97 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_67_[0] = chanx_right_in_65_[0];
// ----- Local connection due to Wire 98 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_69_[0] = chanx_right_in_67_[0];
// ----- Local connection due to Wire 99 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_71_[0] = chanx_right_in_69_[0];
// ----- Local connection due to Wire 101 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_75_[0] = chanx_right_in_73_[0];
// ----- Local connection due to Wire 102 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_77_[0] = chanx_right_in_75_[0];
// ----- Local connection due to Wire 103 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_79_[0] = chanx_right_in_77_[0];
// ----- Local connection due to Wire 105 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_83_[0] = chanx_right_in_81_[0];
// ----- Local connection due to Wire 106 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_85_[0] = chanx_right_in_83_[0];
// ----- Local connection due to Wire 107 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_87_[0] = chanx_right_in_85_[0];
// ----- Local connection due to Wire 109 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_91_[0] = chanx_right_in_89_[0];
// ----- Local connection due to Wire 110 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_93_[0] = chanx_right_in_91_[0];
// ----- Local connection due to Wire 111 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_95_[0] = chanx_right_in_93_[0];
// ----- Local connection due to Wire 113 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_99_[0] = chanx_right_in_97_[0];
// ----- Local connection due to Wire 114 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_101_[0] = chanx_right_in_99_[0];
// ----- Local connection due to Wire 115 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_103_[0] = chanx_right_in_101_[0];
// ----- Local connection due to Wire 117 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_107_[0] = chanx_right_in_105_[0];
// ----- Local connection due to Wire 118 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_left_out_109_[0] = chanx_right_in_107_[0];
// ----- Local connection due to Wire 119 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_111_[0] = chanx_right_in_109_[0];
// ----- Local connection due to Wire 121 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_115_[0] = chanx_right_in_113_[0];
// ----- Local connection due to Wire 122 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_117_[0] = chanx_right_in_115_[0];
// ----- Local connection due to Wire 123 -----
// ----- Net source id 0 -----
// ----- Net sink id 3 -----
	assign chanx_left_out_119_[0] = chanx_right_in_117_[0];
// ----- Local connection due to Wire 130 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_2_[0] = chany_bottom_in_0_[0];
// ----- Local connection due to Wire 131 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_4_[0] = chany_bottom_in_2_[0];
// ----- Local connection due to Wire 132 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_6_[0] = chany_bottom_in_4_[0];
// ----- Local connection due to Wire 133 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_8_[0] = chany_bottom_in_6_[0];
// ----- Local connection due to Wire 134 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_10_[0] = chany_bottom_in_8_[0];
// ----- Local connection due to Wire 135 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_12_[0] = chany_bottom_in_10_[0];
// ----- Local connection due to Wire 136 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_14_[0] = chany_bottom_in_12_[0];
// ----- Local connection due to Wire 138 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_18_[0] = chany_bottom_in_16_[0];
// ----- Local connection due to Wire 139 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_20_[0] = chany_bottom_in_18_[0];
// ----- Local connection due to Wire 140 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_22_[0] = chany_bottom_in_20_[0];
// ----- Local connection due to Wire 142 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_26_[0] = chany_bottom_in_24_[0];
// ----- Local connection due to Wire 143 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_28_[0] = chany_bottom_in_26_[0];
// ----- Local connection due to Wire 144 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_30_[0] = chany_bottom_in_28_[0];
// ----- Local connection due to Wire 146 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_34_[0] = chany_bottom_in_32_[0];
// ----- Local connection due to Wire 147 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_36_[0] = chany_bottom_in_34_[0];
// ----- Local connection due to Wire 148 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_38_[0] = chany_bottom_in_36_[0];
// ----- Local connection due to Wire 150 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_42_[0] = chany_bottom_in_40_[0];
// ----- Local connection due to Wire 151 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_44_[0] = chany_bottom_in_42_[0];
// ----- Local connection due to Wire 152 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_46_[0] = chany_bottom_in_44_[0];
// ----- Local connection due to Wire 154 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_50_[0] = chany_bottom_in_48_[0];
// ----- Local connection due to Wire 155 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_52_[0] = chany_bottom_in_50_[0];
// ----- Local connection due to Wire 156 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_54_[0] = chany_bottom_in_52_[0];
// ----- Local connection due to Wire 158 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_58_[0] = chany_bottom_in_56_[0];
// ----- Local connection due to Wire 159 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_60_[0] = chany_bottom_in_58_[0];
// ----- Local connection due to Wire 160 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_62_[0] = chany_bottom_in_60_[0];
// ----- Local connection due to Wire 162 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_66_[0] = chany_bottom_in_64_[0];
// ----- Local connection due to Wire 163 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_68_[0] = chany_bottom_in_66_[0];
// ----- Local connection due to Wire 164 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_70_[0] = chany_bottom_in_68_[0];
// ----- Local connection due to Wire 166 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_74_[0] = chany_bottom_in_72_[0];
// ----- Local connection due to Wire 167 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_76_[0] = chany_bottom_in_74_[0];
// ----- Local connection due to Wire 168 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_78_[0] = chany_bottom_in_76_[0];
// ----- Local connection due to Wire 170 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_82_[0] = chany_bottom_in_80_[0];
// ----- Local connection due to Wire 171 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_84_[0] = chany_bottom_in_82_[0];
// ----- Local connection due to Wire 172 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_86_[0] = chany_bottom_in_84_[0];
// ----- Local connection due to Wire 174 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_90_[0] = chany_bottom_in_88_[0];
// ----- Local connection due to Wire 175 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_92_[0] = chany_bottom_in_90_[0];
// ----- Local connection due to Wire 176 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_94_[0] = chany_bottom_in_92_[0];
// ----- Local connection due to Wire 178 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_98_[0] = chany_bottom_in_96_[0];
// ----- Local connection due to Wire 179 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_100_[0] = chany_bottom_in_98_[0];
// ----- Local connection due to Wire 180 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_102_[0] = chany_bottom_in_100_[0];
// ----- Local connection due to Wire 182 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_106_[0] = chany_bottom_in_104_[0];
// ----- Local connection due to Wire 183 -----
// ----- Net source id 0 -----
// ----- Net sink id 0 -----
	assign chany_top_out_108_[0] = chany_bottom_in_106_[0];
// ----- Local connection due to Wire 184 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_110_[0] = chany_bottom_in_108_[0];
// ----- Local connection due to Wire 186 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_114_[0] = chany_bottom_in_112_[0];
// ----- Local connection due to Wire 187 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_116_[0] = chany_bottom_in_114_[0];
// ----- Local connection due to Wire 188 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chany_top_out_118_[0] = chany_bottom_in_116_[0];
// ----- Local connection due to Wire 195 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_2_[0] = chanx_left_in_0_[0];
// ----- Local connection due to Wire 196 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_4_[0] = chanx_left_in_2_[0];
// ----- Local connection due to Wire 197 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_6_[0] = chanx_left_in_4_[0];
// ----- Local connection due to Wire 198 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_8_[0] = chanx_left_in_6_[0];
// ----- Local connection due to Wire 199 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_10_[0] = chanx_left_in_8_[0];
// ----- Local connection due to Wire 200 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_12_[0] = chanx_left_in_10_[0];
// ----- Local connection due to Wire 201 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_14_[0] = chanx_left_in_12_[0];
// ----- Local connection due to Wire 203 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_18_[0] = chanx_left_in_16_[0];
// ----- Local connection due to Wire 204 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_20_[0] = chanx_left_in_18_[0];
// ----- Local connection due to Wire 205 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_22_[0] = chanx_left_in_20_[0];
// ----- Local connection due to Wire 207 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_26_[0] = chanx_left_in_24_[0];
// ----- Local connection due to Wire 208 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_28_[0] = chanx_left_in_26_[0];
// ----- Local connection due to Wire 209 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_30_[0] = chanx_left_in_28_[0];
// ----- Local connection due to Wire 211 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_34_[0] = chanx_left_in_32_[0];
// ----- Local connection due to Wire 212 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_36_[0] = chanx_left_in_34_[0];
// ----- Local connection due to Wire 213 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_38_[0] = chanx_left_in_36_[0];
// ----- Local connection due to Wire 215 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_42_[0] = chanx_left_in_40_[0];
// ----- Local connection due to Wire 216 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_44_[0] = chanx_left_in_42_[0];
// ----- Local connection due to Wire 217 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_46_[0] = chanx_left_in_44_[0];
// ----- Local connection due to Wire 219 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_50_[0] = chanx_left_in_48_[0];
// ----- Local connection due to Wire 220 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_52_[0] = chanx_left_in_50_[0];
// ----- Local connection due to Wire 221 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_54_[0] = chanx_left_in_52_[0];
// ----- Local connection due to Wire 223 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_58_[0] = chanx_left_in_56_[0];
// ----- Local connection due to Wire 224 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_60_[0] = chanx_left_in_58_[0];
// ----- Local connection due to Wire 225 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_62_[0] = chanx_left_in_60_[0];
// ----- Local connection due to Wire 227 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_66_[0] = chanx_left_in_64_[0];
// ----- Local connection due to Wire 228 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_68_[0] = chanx_left_in_66_[0];
// ----- Local connection due to Wire 229 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_70_[0] = chanx_left_in_68_[0];
// ----- Local connection due to Wire 231 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_74_[0] = chanx_left_in_72_[0];
// ----- Local connection due to Wire 232 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_76_[0] = chanx_left_in_74_[0];
// ----- Local connection due to Wire 233 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_78_[0] = chanx_left_in_76_[0];
// ----- Local connection due to Wire 235 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_82_[0] = chanx_left_in_80_[0];
// ----- Local connection due to Wire 236 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_84_[0] = chanx_left_in_82_[0];
// ----- Local connection due to Wire 237 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_86_[0] = chanx_left_in_84_[0];
// ----- Local connection due to Wire 239 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_90_[0] = chanx_left_in_88_[0];
// ----- Local connection due to Wire 240 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_92_[0] = chanx_left_in_90_[0];
// ----- Local connection due to Wire 241 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_94_[0] = chanx_left_in_92_[0];
// ----- Local connection due to Wire 243 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_98_[0] = chanx_left_in_96_[0];
// ----- Local connection due to Wire 244 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_100_[0] = chanx_left_in_98_[0];
// ----- Local connection due to Wire 245 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_102_[0] = chanx_left_in_100_[0];
// ----- Local connection due to Wire 247 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_106_[0] = chanx_left_in_104_[0];
// ----- Local connection due to Wire 248 -----
// ----- Net source id 0 -----
// ----- Net sink id 1 -----
	assign chanx_right_out_108_[0] = chanx_left_in_106_[0];
// ----- Local connection due to Wire 249 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_110_[0] = chanx_left_in_108_[0];
// ----- Local connection due to Wire 251 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_114_[0] = chanx_left_in_112_[0];
// ----- Local connection due to Wire 252 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_116_[0] = chanx_left_in_114_[0];
// ----- Local connection due to Wire 253 -----
// ----- Net source id 0 -----
// ----- Net sink id 2 -----
	assign chanx_right_out_118_[0] = chanx_left_in_116_[0];
// ----- END Local short connections -----
// ----- BEGIN Local output short connections -----
// ----- END Local output short connections -----

	mux_tree_like_tapbuf_size19 mux_top_track_0 (
		.in({top_left_grid_pin_30_[0], top_left_grid_pin_31_[0], top_left_grid_pin_32_[0], top_left_grid_pin_33_[0], top_left_grid_pin_34_[0], chanx_left_in_0_[0], chanx_right_in_1_[0], chanx_left_in_14_[0], chanx_right_in_23_[0], chanx_left_in_34_[0], chanx_right_in_35_[0], chanx_left_in_72_[0], chanx_right_in_73_[0], chanx_left_in_108_[0], chanx_right_in_109_[0], chany_bottom_in_0_[0], chany_bottom_in_34_[0], chany_bottom_in_72_[0], chany_bottom_in_108_[0]}),
		.sram(mux_tree_like_tapbuf_size19_0_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size19_0_sram_inv[0:4]),
		.out(chany_top_out_0_[0]));

	mux_tree_like_tapbuf_size19 mux_right_track_0 (
		.in({right_top_grid_pin_35_[0], right_top_grid_pin_36_[0], right_top_grid_pin_37_[0], right_top_grid_pin_38_[0], right_top_grid_pin_39_[0], chanx_left_in_0_[0], chanx_left_in_34_[0], chanx_left_in_72_[0], chanx_left_in_108_[0], chany_bottom_in_0_[0], chany_top_in_1_[0], chany_bottom_in_34_[0], chany_top_in_35_[0], chany_bottom_in_72_[0], chany_top_in_73_[0], chany_bottom_in_108_[0], chany_top_in_109_[0], chany_bottom_in_110_[0], chany_top_in_119_[0]}),
		.sram(mux_tree_like_tapbuf_size19_1_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size19_1_sram_inv[0:4]),
		.out(chanx_right_out_0_[0]));

	mux_tree_like_tapbuf_size19 mux_bottom_track_1 (
		.in({bottom_left_grid_pin_30_[0], bottom_left_grid_pin_31_[0], bottom_left_grid_pin_32_[0], bottom_left_grid_pin_33_[0], bottom_left_grid_pin_34_[0], chanx_left_in_0_[0], chanx_right_in_1_[0], chanx_left_in_22_[0], chanx_left_in_34_[0], chanx_right_in_35_[0], chanx_left_in_72_[0], chanx_right_in_73_[0], chanx_left_in_108_[0], chanx_right_in_109_[0], chanx_right_in_111_[0], chany_top_in_1_[0], chany_top_in_35_[0], chany_top_in_73_[0], chany_top_in_109_[0]}),
		.sram(mux_tree_like_tapbuf_size19_2_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size19_2_sram_inv[0:4]),
		.out(chany_bottom_out_1_[0]));

	mux_tree_like_tapbuf_size19 mux_left_track_1 (
		.in({left_top_grid_pin_35_[0], left_top_grid_pin_36_[0], left_top_grid_pin_37_[0], left_top_grid_pin_38_[0], left_top_grid_pin_39_[0], chanx_right_in_1_[0], chanx_right_in_35_[0], chanx_right_in_73_[0], chanx_right_in_109_[0], chany_bottom_in_0_[0], chany_top_in_1_[0], chany_top_in_15_[0], chany_bottom_in_34_[0], chany_top_in_35_[0], chany_bottom_in_72_[0], chany_top_in_73_[0], chany_bottom_in_108_[0], chany_top_in_109_[0], chany_bottom_in_118_[0]}),
		.sram(mux_tree_like_tapbuf_size19_3_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size19_3_sram_inv[0:4]),
		.out(chanx_left_out_1_[0]));

	mux_tree_like_tapbuf_size19_mem mem_top_track_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(ccff_head[0]),
		.ccff_tail(mux_tree_like_tapbuf_size19_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size19_0_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size19_0_sram_inv[0:4]));

	mux_tree_like_tapbuf_size19_mem mem_right_track_0 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size19_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size19_1_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size19_1_sram_inv[0:4]));

	mux_tree_like_tapbuf_size19_mem mem_bottom_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_13_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size19_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size19_2_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size19_2_sram_inv[0:4]));

	mux_tree_like_tapbuf_size19_mem mem_left_track_1 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_20_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size19_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size19_3_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size19_3_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16 mux_top_track_16 (
		.in({top_left_grid_pin_30_[0], top_left_grid_pin_31_[0], chanx_left_in_2_[0], chanx_right_in_3_[0], chanx_right_in_31_[0], chanx_left_in_36_[0], chanx_right_in_37_[0], chanx_left_in_74_[0], chanx_right_in_75_[0], chanx_left_in_112_[0], chanx_right_in_113_[0], chanx_left_in_118_[0], chany_bottom_in_2_[0], chany_bottom_in_36_[0], chany_bottom_in_74_[0], chany_bottom_in_112_[0]}),
		.sram(mux_tree_like_tapbuf_size16_0_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_0_sram_inv[0:4]),
		.out(chany_top_out_16_[0]));

	mux_tree_like_tapbuf_size16 mux_top_track_24 (
		.in({top_left_grid_pin_31_[0], top_left_grid_pin_32_[0], chanx_left_in_4_[0], chanx_right_in_5_[0], chanx_right_in_39_[0], chanx_left_in_40_[0], chanx_right_in_41_[0], chanx_left_in_76_[0], chanx_right_in_77_[0], chanx_left_in_110_[0], chanx_left_in_114_[0], chanx_right_in_115_[0], chany_bottom_in_4_[0], chany_bottom_in_40_[0], chany_bottom_in_76_[0], chany_bottom_in_114_[0]}),
		.sram(mux_tree_like_tapbuf_size16_1_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_1_sram_inv[0:4]),
		.out(chany_top_out_24_[0]));

	mux_tree_like_tapbuf_size16 mux_top_track_32 (
		.in({top_left_grid_pin_32_[0], top_left_grid_pin_33_[0], chanx_left_in_6_[0], chanx_right_in_7_[0], chanx_left_in_42_[0], chanx_right_in_43_[0], chanx_right_in_47_[0], chanx_left_in_80_[0], chanx_right_in_81_[0], chanx_left_in_102_[0], chanx_left_in_116_[0], chanx_right_in_117_[0], chany_bottom_in_6_[0], chany_bottom_in_42_[0], chany_bottom_in_80_[0], chany_bottom_in_116_[0]}),
		.sram(mux_tree_like_tapbuf_size16_2_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_2_sram_inv[0:4]),
		.out(chany_top_out_32_[0]));

	mux_tree_like_tapbuf_size16 mux_right_track_16 (
		.in({right_top_grid_pin_35_[0], right_top_grid_pin_36_[0], chanx_left_in_2_[0], chanx_left_in_36_[0], chanx_left_in_74_[0], chanx_left_in_112_[0], chany_bottom_in_2_[0], chany_top_in_3_[0], chany_top_in_15_[0], chany_bottom_in_36_[0], chany_top_in_37_[0], chany_bottom_in_74_[0], chany_top_in_75_[0], chany_bottom_in_102_[0], chany_bottom_in_112_[0], chany_top_in_113_[0]}),
		.sram(mux_tree_like_tapbuf_size16_3_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_3_sram_inv[0:4]),
		.out(chanx_right_out_16_[0]));

	mux_tree_like_tapbuf_size16 mux_right_track_24 (
		.in({right_top_grid_pin_36_[0], right_top_grid_pin_37_[0], chanx_left_in_4_[0], chanx_left_in_40_[0], chanx_left_in_76_[0], chanx_left_in_114_[0], chany_bottom_in_4_[0], chany_top_in_5_[0], chany_top_in_23_[0], chany_bottom_in_40_[0], chany_top_in_41_[0], chany_bottom_in_76_[0], chany_top_in_77_[0], chany_bottom_in_94_[0], chany_bottom_in_114_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size16_4_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_4_sram_inv[0:4]),
		.out(chanx_right_out_24_[0]));

	mux_tree_like_tapbuf_size16 mux_right_track_32 (
		.in({right_top_grid_pin_37_[0], right_top_grid_pin_38_[0], chanx_left_in_6_[0], chanx_left_in_42_[0], chanx_left_in_80_[0], chanx_left_in_116_[0], chany_bottom_in_6_[0], chany_top_in_7_[0], chany_top_in_31_[0], chany_bottom_in_42_[0], chany_top_in_43_[0], chany_bottom_in_80_[0], chany_top_in_81_[0], chany_bottom_in_86_[0], chany_bottom_in_116_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size16_5_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_5_sram_inv[0:4]),
		.out(chanx_right_out_32_[0]));

	mux_tree_like_tapbuf_size16 mux_bottom_track_17 (
		.in({bottom_left_grid_pin_30_[0], bottom_left_grid_pin_31_[0], chanx_left_in_2_[0], chanx_right_in_3_[0], chanx_left_in_30_[0], chanx_left_in_36_[0], chanx_right_in_37_[0], chanx_left_in_74_[0], chanx_right_in_75_[0], chanx_right_in_103_[0], chanx_left_in_112_[0], chanx_right_in_113_[0], chany_top_in_3_[0], chany_top_in_37_[0], chany_top_in_75_[0], chany_top_in_113_[0]}),
		.sram(mux_tree_like_tapbuf_size16_6_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_6_sram_inv[0:4]),
		.out(chany_bottom_out_17_[0]));

	mux_tree_like_tapbuf_size16 mux_bottom_track_25 (
		.in({bottom_left_grid_pin_31_[0], bottom_left_grid_pin_32_[0], chanx_left_in_4_[0], chanx_right_in_5_[0], chanx_left_in_38_[0], chanx_left_in_40_[0], chanx_right_in_41_[0], chanx_left_in_76_[0], chanx_right_in_77_[0], chanx_right_in_95_[0], chanx_left_in_114_[0], chanx_right_in_115_[0], chany_top_in_5_[0], chany_top_in_41_[0], chany_top_in_77_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size16_7_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_7_sram_inv[0:4]),
		.out(chany_bottom_out_25_[0]));

	mux_tree_like_tapbuf_size16 mux_bottom_track_33 (
		.in({bottom_left_grid_pin_32_[0], bottom_left_grid_pin_33_[0], chanx_left_in_6_[0], chanx_right_in_7_[0], chanx_left_in_42_[0], chanx_right_in_43_[0], chanx_left_in_46_[0], chanx_left_in_80_[0], chanx_right_in_81_[0], chanx_right_in_87_[0], chanx_left_in_116_[0], chanx_right_in_117_[0], chany_top_in_7_[0], chany_top_in_43_[0], chany_top_in_81_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size16_8_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_8_sram_inv[0:4]),
		.out(chany_bottom_out_33_[0]));

	mux_tree_like_tapbuf_size16 mux_left_track_17 (
		.in({left_top_grid_pin_35_[0], left_top_grid_pin_36_[0], chanx_right_in_3_[0], chanx_right_in_37_[0], chanx_right_in_75_[0], chanx_right_in_113_[0], chany_bottom_in_2_[0], chany_top_in_3_[0], chany_bottom_in_14_[0], chany_bottom_in_36_[0], chany_top_in_37_[0], chany_bottom_in_74_[0], chany_top_in_75_[0], chany_bottom_in_112_[0], chany_top_in_113_[0], chany_top_in_119_[0]}),
		.sram(mux_tree_like_tapbuf_size16_9_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_9_sram_inv[0:4]),
		.out(chanx_left_out_17_[0]));

	mux_tree_like_tapbuf_size16 mux_left_track_25 (
		.in({left_top_grid_pin_36_[0], left_top_grid_pin_37_[0], chanx_right_in_5_[0], chanx_right_in_41_[0], chanx_right_in_77_[0], chanx_right_in_115_[0], chany_bottom_in_4_[0], chany_top_in_5_[0], chany_bottom_in_22_[0], chany_bottom_in_40_[0], chany_top_in_41_[0], chany_bottom_in_76_[0], chany_top_in_77_[0], chany_top_in_111_[0], chany_bottom_in_114_[0], chany_top_in_115_[0]}),
		.sram(mux_tree_like_tapbuf_size16_10_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_10_sram_inv[0:4]),
		.out(chanx_left_out_25_[0]));

	mux_tree_like_tapbuf_size16 mux_left_track_33 (
		.in({left_top_grid_pin_37_[0], left_top_grid_pin_38_[0], chanx_right_in_7_[0], chanx_right_in_43_[0], chanx_right_in_81_[0], chanx_right_in_117_[0], chany_bottom_in_6_[0], chany_top_in_7_[0], chany_bottom_in_30_[0], chany_bottom_in_42_[0], chany_top_in_43_[0], chany_bottom_in_80_[0], chany_top_in_81_[0], chany_top_in_103_[0], chany_bottom_in_116_[0], chany_top_in_117_[0]}),
		.sram(mux_tree_like_tapbuf_size16_11_sram[0:4]),
		.sram_inv(mux_tree_like_tapbuf_size16_11_sram_inv[0:4]),
		.out(chanx_left_out_33_[0]));

	mux_tree_like_tapbuf_size16_mem mem_top_track_16 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size19_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_0_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_0_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_top_track_24 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_1_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_1_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_top_track_32 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_2_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_2_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_right_track_16 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size19_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_3_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_3_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_right_track_24 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_4_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_4_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_right_track_32 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_5_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_5_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_bottom_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size19_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_6_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_6_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_bottom_track_25 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_7_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_7_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_bottom_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_8_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_8_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_left_track_17 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size19_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_9_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_9_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_left_track_25 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_10_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_10_sram_inv[0:4]));

	mux_tree_like_tapbuf_size16_mem mem_left_track_33 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size16_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size16_11_sram[0:4]),
		.mem_outb(mux_tree_like_tapbuf_size16_11_sram_inv[0:4]));

	mux_tree_like_tapbuf_size13 mux_top_track_40 (
		.in({top_left_grid_pin_33_[0], top_left_grid_pin_34_[0], chanx_left_in_8_[0], chanx_right_in_9_[0], chanx_left_in_44_[0], chanx_right_in_45_[0], chanx_right_in_55_[0], chanx_left_in_82_[0], chanx_right_in_83_[0], chanx_left_in_94_[0], chany_bottom_in_8_[0], chany_bottom_in_44_[0], chany_bottom_in_82_[0]}),
		.sram(mux_tree_like_tapbuf_size13_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size13_0_sram_inv[0:3]),
		.out(chany_top_out_40_[0]));

	mux_tree_like_tapbuf_size13 mux_right_track_40 (
		.in({right_top_grid_pin_38_[0], right_top_grid_pin_39_[0], chanx_left_in_8_[0], chanx_left_in_44_[0], chanx_left_in_82_[0], chany_bottom_in_8_[0], chany_top_in_9_[0], chany_top_in_39_[0], chany_bottom_in_44_[0], chany_top_in_45_[0], chany_bottom_in_78_[0], chany_bottom_in_82_[0], chany_top_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size13_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size13_1_sram_inv[0:3]),
		.out(chanx_right_out_40_[0]));

	mux_tree_like_tapbuf_size13 mux_bottom_track_41 (
		.in({bottom_left_grid_pin_33_[0], bottom_left_grid_pin_34_[0], chanx_left_in_8_[0], chanx_right_in_9_[0], chanx_left_in_44_[0], chanx_right_in_45_[0], chanx_left_in_54_[0], chanx_right_in_79_[0], chanx_left_in_82_[0], chanx_right_in_83_[0], chany_top_in_9_[0], chany_top_in_45_[0], chany_top_in_83_[0]}),
		.sram(mux_tree_like_tapbuf_size13_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size13_2_sram_inv[0:3]),
		.out(chany_bottom_out_41_[0]));

	mux_tree_like_tapbuf_size13 mux_left_track_41 (
		.in({left_top_grid_pin_38_[0], left_top_grid_pin_39_[0], chanx_right_in_9_[0], chanx_right_in_45_[0], chanx_right_in_83_[0], chany_bottom_in_8_[0], chany_top_in_9_[0], chany_bottom_in_38_[0], chany_bottom_in_44_[0], chany_top_in_45_[0], chany_bottom_in_82_[0], chany_top_in_83_[0], chany_top_in_95_[0]}),
		.sram(mux_tree_like_tapbuf_size13_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size13_3_sram_inv[0:3]),
		.out(chanx_left_out_41_[0]));

	mux_tree_like_tapbuf_size13_mem mem_top_track_40 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size13_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size13_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size13_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size13_mem mem_right_track_40 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size13_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size13_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size13_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size13_mem mem_bottom_track_41 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size13_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size13_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size13_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size13_mem mem_left_track_41 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size16_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size13_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size13_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size13_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12 mux_top_track_48 (
		.in({top_left_grid_pin_34_[0], chanx_left_in_10_[0], chanx_right_in_11_[0], chanx_left_in_48_[0], chanx_right_in_49_[0], chanx_right_in_63_[0], chanx_left_in_84_[0], chanx_right_in_85_[0], chanx_left_in_86_[0], chany_bottom_in_10_[0], chany_bottom_in_48_[0], chany_bottom_in_84_[0]}),
		.sram(mux_tree_like_tapbuf_size12_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_0_sram_inv[0:3]),
		.out(chany_top_out_48_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_64 (
		.in({top_left_grid_pin_30_[0], chanx_left_in_16_[0], chanx_right_in_17_[0], chanx_left_in_52_[0], chanx_right_in_53_[0], chanx_left_in_70_[0], chanx_right_in_79_[0], chanx_left_in_90_[0], chanx_right_in_91_[0], chany_bottom_in_16_[0], chany_bottom_in_52_[0], chany_bottom_in_90_[0]}),
		.sram(mux_tree_like_tapbuf_size12_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_1_sram_inv[0:3]),
		.out(chany_top_out_64_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_72 (
		.in({top_left_grid_pin_31_[0], chanx_left_in_18_[0], chanx_right_in_19_[0], chanx_left_in_56_[0], chanx_right_in_57_[0], chanx_left_in_62_[0], chanx_right_in_87_[0], chanx_left_in_92_[0], chanx_right_in_93_[0], chany_bottom_in_18_[0], chany_bottom_in_56_[0], chany_bottom_in_92_[0]}),
		.sram(mux_tree_like_tapbuf_size12_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_2_sram_inv[0:3]),
		.out(chany_top_out_72_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_80 (
		.in({top_left_grid_pin_32_[0], chanx_left_in_20_[0], chanx_right_in_21_[0], chanx_left_in_54_[0], chanx_left_in_58_[0], chanx_right_in_59_[0], chanx_right_in_95_[0], chanx_left_in_96_[0], chanx_right_in_97_[0], chany_bottom_in_20_[0], chany_bottom_in_58_[0], chany_bottom_in_96_[0]}),
		.sram(mux_tree_like_tapbuf_size12_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_3_sram_inv[0:3]),
		.out(chany_top_out_80_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_88 (
		.in({top_left_grid_pin_33_[0], chanx_left_in_24_[0], chanx_right_in_25_[0], chanx_left_in_46_[0], chanx_left_in_60_[0], chanx_right_in_61_[0], chanx_left_in_98_[0], chanx_right_in_99_[0], chanx_right_in_103_[0], chany_bottom_in_24_[0], chany_bottom_in_60_[0], chany_bottom_in_98_[0]}),
		.sram(mux_tree_like_tapbuf_size12_4_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_4_sram_inv[0:3]),
		.out(chany_top_out_88_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_96 (
		.in({top_left_grid_pin_34_[0], chanx_left_in_26_[0], chanx_right_in_27_[0], chanx_left_in_38_[0], chanx_left_in_64_[0], chanx_right_in_65_[0], chanx_left_in_100_[0], chanx_right_in_101_[0], chanx_right_in_111_[0], chany_bottom_in_26_[0], chany_bottom_in_64_[0], chany_bottom_in_100_[0]}),
		.sram(mux_tree_like_tapbuf_size12_5_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_5_sram_inv[0:3]),
		.out(chany_top_out_96_[0]));

	mux_tree_like_tapbuf_size12 mux_top_track_112 (
		.in({top_left_grid_pin_30_[0], chanx_right_in_15_[0], chanx_left_in_22_[0], chanx_left_in_32_[0], chanx_right_in_33_[0], chanx_left_in_68_[0], chanx_right_in_69_[0], chanx_left_in_106_[0], chanx_right_in_107_[0], chany_bottom_in_32_[0], chany_bottom_in_68_[0], chany_bottom_in_106_[0]}),
		.sram(mux_tree_like_tapbuf_size12_6_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_6_sram_inv[0:3]),
		.out(chany_top_out_112_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_48 (
		.in({right_top_grid_pin_39_[0], chanx_left_in_10_[0], chanx_left_in_48_[0], chanx_left_in_84_[0], chany_bottom_in_10_[0], chany_top_in_11_[0], chany_top_in_47_[0], chany_bottom_in_48_[0], chany_top_in_49_[0], chany_bottom_in_70_[0], chany_bottom_in_84_[0], chany_top_in_85_[0]}),
		.sram(mux_tree_like_tapbuf_size12_7_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_7_sram_inv[0:3]),
		.out(chanx_right_out_48_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_64 (
		.in({right_top_grid_pin_35_[0], chanx_left_in_16_[0], chanx_left_in_52_[0], chanx_left_in_90_[0], chany_bottom_in_16_[0], chany_top_in_17_[0], chany_bottom_in_52_[0], chany_top_in_53_[0], chany_bottom_in_54_[0], chany_top_in_63_[0], chany_bottom_in_90_[0], chany_top_in_91_[0]}),
		.sram(mux_tree_like_tapbuf_size12_8_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_8_sram_inv[0:3]),
		.out(chanx_right_out_64_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_72 (
		.in({right_top_grid_pin_36_[0], chanx_left_in_18_[0], chanx_left_in_56_[0], chanx_left_in_92_[0], chany_bottom_in_18_[0], chany_top_in_19_[0], chany_bottom_in_46_[0], chany_bottom_in_56_[0], chany_top_in_57_[0], chany_top_in_71_[0], chany_bottom_in_92_[0], chany_top_in_93_[0]}),
		.sram(mux_tree_like_tapbuf_size12_9_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_9_sram_inv[0:3]),
		.out(chanx_right_out_72_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_80 (
		.in({right_top_grid_pin_37_[0], chanx_left_in_20_[0], chanx_left_in_58_[0], chanx_left_in_96_[0], chany_bottom_in_20_[0], chany_top_in_21_[0], chany_bottom_in_38_[0], chany_bottom_in_58_[0], chany_top_in_59_[0], chany_top_in_79_[0], chany_bottom_in_96_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size12_10_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_10_sram_inv[0:3]),
		.out(chanx_right_out_80_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_88 (
		.in({right_top_grid_pin_38_[0], chanx_left_in_24_[0], chanx_left_in_60_[0], chanx_left_in_98_[0], chany_bottom_in_24_[0], chany_top_in_25_[0], chany_bottom_in_30_[0], chany_bottom_in_60_[0], chany_top_in_61_[0], chany_top_in_87_[0], chany_bottom_in_98_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size12_11_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_11_sram_inv[0:3]),
		.out(chanx_right_out_88_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_96 (
		.in({right_top_grid_pin_39_[0], chanx_left_in_26_[0], chanx_left_in_64_[0], chanx_left_in_100_[0], chany_bottom_in_22_[0], chany_bottom_in_26_[0], chany_top_in_27_[0], chany_bottom_in_64_[0], chany_top_in_65_[0], chany_top_in_95_[0], chany_bottom_in_100_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size12_12_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_12_sram_inv[0:3]),
		.out(chanx_right_out_96_[0]));

	mux_tree_like_tapbuf_size12 mux_right_track_112 (
		.in({right_top_grid_pin_35_[0], chanx_left_in_32_[0], chanx_left_in_68_[0], chanx_left_in_106_[0], chany_bottom_in_32_[0], chany_top_in_33_[0], chany_bottom_in_68_[0], chany_top_in_69_[0], chany_bottom_in_106_[0], chany_top_in_107_[0], chany_top_in_111_[0], chany_bottom_in_118_[0]}),
		.sram(mux_tree_like_tapbuf_size12_13_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_13_sram_inv[0:3]),
		.out(chanx_right_out_112_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_49 (
		.in({bottom_left_grid_pin_34_[0], chanx_left_in_10_[0], chanx_right_in_11_[0], chanx_left_in_48_[0], chanx_right_in_49_[0], chanx_left_in_62_[0], chanx_right_in_71_[0], chanx_left_in_84_[0], chanx_right_in_85_[0], chany_top_in_11_[0], chany_top_in_49_[0], chany_top_in_85_[0]}),
		.sram(mux_tree_like_tapbuf_size12_14_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_14_sram_inv[0:3]),
		.out(chany_bottom_out_49_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_65 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_16_[0], chanx_right_in_17_[0], chanx_left_in_52_[0], chanx_right_in_53_[0], chanx_right_in_55_[0], chanx_left_in_78_[0], chanx_left_in_90_[0], chanx_right_in_91_[0], chany_top_in_17_[0], chany_top_in_53_[0], chany_top_in_91_[0]}),
		.sram(mux_tree_like_tapbuf_size12_15_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_15_sram_inv[0:3]),
		.out(chany_bottom_out_65_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_73 (
		.in({bottom_left_grid_pin_31_[0], chanx_left_in_18_[0], chanx_right_in_19_[0], chanx_right_in_47_[0], chanx_left_in_56_[0], chanx_right_in_57_[0], chanx_left_in_86_[0], chanx_left_in_92_[0], chanx_right_in_93_[0], chany_top_in_19_[0], chany_top_in_57_[0], chany_top_in_93_[0]}),
		.sram(mux_tree_like_tapbuf_size12_16_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_16_sram_inv[0:3]),
		.out(chany_bottom_out_73_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_81 (
		.in({bottom_left_grid_pin_32_[0], chanx_left_in_20_[0], chanx_right_in_21_[0], chanx_right_in_39_[0], chanx_left_in_58_[0], chanx_right_in_59_[0], chanx_left_in_94_[0], chanx_left_in_96_[0], chanx_right_in_97_[0], chany_top_in_21_[0], chany_top_in_59_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size12_17_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_17_sram_inv[0:3]),
		.out(chany_bottom_out_81_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_89 (
		.in({bottom_left_grid_pin_33_[0], chanx_left_in_24_[0], chanx_right_in_25_[0], chanx_right_in_31_[0], chanx_left_in_60_[0], chanx_right_in_61_[0], chanx_left_in_98_[0], chanx_right_in_99_[0], chanx_left_in_102_[0], chany_top_in_25_[0], chany_top_in_61_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size12_18_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_18_sram_inv[0:3]),
		.out(chany_bottom_out_89_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_97 (
		.in({bottom_left_grid_pin_34_[0], chanx_right_in_23_[0], chanx_left_in_26_[0], chanx_right_in_27_[0], chanx_left_in_64_[0], chanx_right_in_65_[0], chanx_left_in_100_[0], chanx_right_in_101_[0], chanx_left_in_110_[0], chany_top_in_27_[0], chany_top_in_65_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size12_19_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_19_sram_inv[0:3]),
		.out(chany_bottom_out_97_[0]));

	mux_tree_like_tapbuf_size12 mux_bottom_track_113 (
		.in({bottom_left_grid_pin_30_[0], chanx_left_in_14_[0], chanx_left_in_32_[0], chanx_right_in_33_[0], chanx_left_in_68_[0], chanx_right_in_69_[0], chanx_left_in_106_[0], chanx_right_in_107_[0], chanx_right_in_119_[0], chany_top_in_33_[0], chany_top_in_69_[0], chany_top_in_107_[0]}),
		.sram(mux_tree_like_tapbuf_size12_20_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_20_sram_inv[0:3]),
		.out(chany_bottom_out_113_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_49 (
		.in({left_top_grid_pin_39_[0], chanx_right_in_11_[0], chanx_right_in_49_[0], chanx_right_in_85_[0], chany_bottom_in_10_[0], chany_top_in_11_[0], chany_bottom_in_46_[0], chany_bottom_in_48_[0], chany_top_in_49_[0], chany_bottom_in_84_[0], chany_top_in_85_[0], chany_top_in_87_[0]}),
		.sram(mux_tree_like_tapbuf_size12_21_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_21_sram_inv[0:3]),
		.out(chanx_left_out_49_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_65 (
		.in({left_top_grid_pin_35_[0], chanx_right_in_17_[0], chanx_right_in_53_[0], chanx_right_in_91_[0], chany_bottom_in_16_[0], chany_top_in_17_[0], chany_bottom_in_52_[0], chany_top_in_53_[0], chany_bottom_in_62_[0], chany_top_in_71_[0], chany_bottom_in_90_[0], chany_top_in_91_[0]}),
		.sram(mux_tree_like_tapbuf_size12_22_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_22_sram_inv[0:3]),
		.out(chanx_left_out_65_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_73 (
		.in({left_top_grid_pin_36_[0], chanx_right_in_19_[0], chanx_right_in_57_[0], chanx_right_in_93_[0], chany_bottom_in_18_[0], chany_top_in_19_[0], chany_bottom_in_56_[0], chany_top_in_57_[0], chany_top_in_63_[0], chany_bottom_in_70_[0], chany_bottom_in_92_[0], chany_top_in_93_[0]}),
		.sram(mux_tree_like_tapbuf_size12_23_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_23_sram_inv[0:3]),
		.out(chanx_left_out_73_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_81 (
		.in({left_top_grid_pin_37_[0], chanx_right_in_21_[0], chanx_right_in_59_[0], chanx_right_in_97_[0], chany_bottom_in_20_[0], chany_top_in_21_[0], chany_top_in_55_[0], chany_bottom_in_58_[0], chany_top_in_59_[0], chany_bottom_in_78_[0], chany_bottom_in_96_[0], chany_top_in_97_[0]}),
		.sram(mux_tree_like_tapbuf_size12_24_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_24_sram_inv[0:3]),
		.out(chanx_left_out_81_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_89 (
		.in({left_top_grid_pin_38_[0], chanx_right_in_25_[0], chanx_right_in_61_[0], chanx_right_in_99_[0], chany_bottom_in_24_[0], chany_top_in_25_[0], chany_top_in_47_[0], chany_bottom_in_60_[0], chany_top_in_61_[0], chany_bottom_in_86_[0], chany_bottom_in_98_[0], chany_top_in_99_[0]}),
		.sram(mux_tree_like_tapbuf_size12_25_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_25_sram_inv[0:3]),
		.out(chanx_left_out_89_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_97 (
		.in({left_top_grid_pin_39_[0], chanx_right_in_27_[0], chanx_right_in_65_[0], chanx_right_in_101_[0], chany_bottom_in_26_[0], chany_top_in_27_[0], chany_top_in_39_[0], chany_bottom_in_64_[0], chany_top_in_65_[0], chany_bottom_in_94_[0], chany_bottom_in_100_[0], chany_top_in_101_[0]}),
		.sram(mux_tree_like_tapbuf_size12_26_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_26_sram_inv[0:3]),
		.out(chanx_left_out_97_[0]));

	mux_tree_like_tapbuf_size12 mux_left_track_113 (
		.in({left_top_grid_pin_35_[0], chanx_right_in_33_[0], chanx_right_in_69_[0], chanx_right_in_107_[0], chany_top_in_23_[0], chany_bottom_in_32_[0], chany_top_in_33_[0], chany_bottom_in_68_[0], chany_top_in_69_[0], chany_bottom_in_106_[0], chany_top_in_107_[0], chany_bottom_in_110_[0]}),
		.sram(mux_tree_like_tapbuf_size12_27_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size12_27_sram_inv[0:3]),
		.out(chanx_left_out_113_[0]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_48 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size13_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_64 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_72 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_80 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_88 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_4_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_4_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_96 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_5_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_5_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_top_track_112 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_6_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_6_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_48 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size13_mem_1_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_7_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_7_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_64 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_8_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_8_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_8_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_72 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_8_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_9_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_9_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_9_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_80 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_9_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_10_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_10_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_10_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_88 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_10_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_11_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_11_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_11_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_96 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_11_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_12_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_12_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_12_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_right_track_112 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_13_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_13_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_13_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size13_mem_2_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_14_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_14_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_14_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_4_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_15_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_15_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_15_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_73 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_15_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_16_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_16_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_16_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_16_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_17_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_17_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_17_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_89 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_17_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_18_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_18_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_18_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_18_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_19_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_19_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_19_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_bottom_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_20_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_20_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_20_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_49 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size13_mem_3_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_21_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_21_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_21_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_65 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_6_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_22_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_22_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_22_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_73 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_22_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_23_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_23_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_23_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_81 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_23_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_24_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_24_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_24_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_89 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_24_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_25_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_25_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_25_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_97 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_25_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size12_mem_26_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_26_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_26_sram_inv[0:3]));

	mux_tree_like_tapbuf_size12_mem mem_left_track_113 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size11_mem_7_ccff_tail[0]),
		.ccff_tail(ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size12_27_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size12_27_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11 mux_top_track_56 (
		.in({chanx_left_in_12_[0], chanx_right_in_13_[0], chanx_left_in_50_[0], chanx_right_in_51_[0], chanx_right_in_71_[0], chanx_left_in_78_[0], chanx_left_in_88_[0], chanx_right_in_89_[0], chany_bottom_in_12_[0], chany_bottom_in_50_[0], chany_bottom_in_88_[0]}),
		.sram(mux_tree_like_tapbuf_size11_0_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_0_sram_inv[0:3]),
		.out(chany_top_out_56_[0]));

	mux_tree_like_tapbuf_size11 mux_top_track_104 (
		.in({chanx_left_in_28_[0], chanx_right_in_29_[0], chanx_left_in_30_[0], chanx_left_in_66_[0], chanx_right_in_67_[0], chanx_left_in_104_[0], chanx_right_in_105_[0], chanx_right_in_119_[0], chany_bottom_in_28_[0], chany_bottom_in_66_[0], chany_bottom_in_104_[0]}),
		.sram(mux_tree_like_tapbuf_size11_1_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_1_sram_inv[0:3]),
		.out(chany_top_out_104_[0]));

	mux_tree_like_tapbuf_size11 mux_right_track_56 (
		.in({chanx_left_in_12_[0], chanx_left_in_50_[0], chanx_left_in_88_[0], chany_bottom_in_12_[0], chany_top_in_13_[0], chany_bottom_in_50_[0], chany_top_in_51_[0], chany_top_in_55_[0], chany_bottom_in_62_[0], chany_bottom_in_88_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size11_2_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_2_sram_inv[0:3]),
		.out(chanx_right_out_56_[0]));

	mux_tree_like_tapbuf_size11 mux_right_track_104 (
		.in({chanx_left_in_28_[0], chanx_left_in_66_[0], chanx_left_in_104_[0], chany_bottom_in_14_[0], chany_bottom_in_28_[0], chany_top_in_29_[0], chany_bottom_in_66_[0], chany_top_in_67_[0], chany_top_in_103_[0], chany_bottom_in_104_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size11_3_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_3_sram_inv[0:3]),
		.out(chanx_right_out_104_[0]));

	mux_tree_like_tapbuf_size11 mux_bottom_track_57 (
		.in({chanx_left_in_12_[0], chanx_right_in_13_[0], chanx_left_in_50_[0], chanx_right_in_51_[0], chanx_right_in_63_[0], chanx_left_in_70_[0], chanx_left_in_88_[0], chanx_right_in_89_[0], chany_top_in_13_[0], chany_top_in_51_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size11_4_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_4_sram_inv[0:3]),
		.out(chany_bottom_out_57_[0]));

	mux_tree_like_tapbuf_size11 mux_bottom_track_105 (
		.in({chanx_right_in_15_[0], chanx_left_in_28_[0], chanx_right_in_29_[0], chanx_left_in_66_[0], chanx_right_in_67_[0], chanx_left_in_104_[0], chanx_right_in_105_[0], chanx_left_in_118_[0], chany_top_in_29_[0], chany_top_in_67_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size11_5_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_5_sram_inv[0:3]),
		.out(chany_bottom_out_105_[0]));

	mux_tree_like_tapbuf_size11 mux_left_track_57 (
		.in({chanx_right_in_13_[0], chanx_right_in_51_[0], chanx_right_in_89_[0], chany_bottom_in_12_[0], chany_top_in_13_[0], chany_bottom_in_50_[0], chany_top_in_51_[0], chany_bottom_in_54_[0], chany_top_in_79_[0], chany_bottom_in_88_[0], chany_top_in_89_[0]}),
		.sram(mux_tree_like_tapbuf_size11_6_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_6_sram_inv[0:3]),
		.out(chanx_left_out_57_[0]));

	mux_tree_like_tapbuf_size11 mux_left_track_105 (
		.in({chanx_right_in_29_[0], chanx_right_in_67_[0], chanx_right_in_105_[0], chany_bottom_in_28_[0], chany_top_in_29_[0], chany_top_in_31_[0], chany_bottom_in_66_[0], chany_top_in_67_[0], chany_bottom_in_102_[0], chany_bottom_in_104_[0], chany_top_in_105_[0]}),
		.sram(mux_tree_like_tapbuf_size11_7_sram[0:3]),
		.sram_inv(mux_tree_like_tapbuf_size11_7_sram_inv[0:3]),
		.out(chanx_left_out_105_[0]));

	mux_tree_like_tapbuf_size11_mem mem_top_track_56 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_0_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_0_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_0_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_0_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_top_track_104 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_5_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_1_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_1_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_1_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_right_track_56 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_7_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_2_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_2_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_2_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_right_track_104 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_12_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_3_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_3_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_3_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_bottom_track_57 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_14_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_4_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_4_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_4_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_bottom_track_105 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_19_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_5_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_5_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_5_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_left_track_57 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_21_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_6_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_6_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_6_sram_inv[0:3]));

	mux_tree_like_tapbuf_size11_mem mem_left_track_105 (
		.pReset(pReset[0]),
		.prog_clk(prog_clk[0]),
		.ccff_head(mux_tree_like_tapbuf_size12_mem_26_ccff_tail[0]),
		.ccff_tail(mux_tree_like_tapbuf_size11_mem_7_ccff_tail[0]),
		.mem_out(mux_tree_like_tapbuf_size11_7_sram[0:3]),
		.mem_outb(mux_tree_like_tapbuf_size11_7_sram_inv[0:3]));

endmodule
// ----- END Verilog module for sb_1__1_ -----


