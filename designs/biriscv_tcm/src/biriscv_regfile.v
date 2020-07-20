//-----------------------------------------------------------------
//                         biRISC-V CPU
//                            V0.8.0
//                     Ultra-Embedded.com
//                     Copyright 2019-2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------
module biriscv_regfile
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_REGFILE_XILINX = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [  4:0]  rd0_i
    ,input  [  4:0]  rd1_i
    ,input  [ 31:0]  rd0_value_i
    ,input  [ 31:0]  rd1_value_i
    ,input  [  4:0]  ra0_i
    ,input  [  4:0]  rb0_i
    ,input  [  4:0]  ra1_i
    ,input  [  4:0]  rb1_i

    // Outputs
    ,output [ 31:0]  ra0_value_o
    ,output [ 31:0]  rb0_value_o
    ,output [ 31:0]  ra1_value_o
    ,output [ 31:0]  rb1_value_o
);

//-----------------------------------------------------------------
// Xilinx specific register file
//-----------------------------------------------------------------
generate
if (SUPPORT_REGFILE_XILINX)
begin: REGFILE_XILINX

    wire [31:0] ra0_value_w[1:0];
    wire [31:0] rb0_value_w[1:0];
    wire [31:0] ra1_value_w[1:0];
    wire [31:0] rb1_value_w[1:0];

    biriscv_xilinx_2r1w
    u_a_0
    (
        // Inputs
         .clk_i(clk_i)
        ,.rst_i(rst_i)
        ,.rd0_i(rd0_i)
        ,.rd0_value_i(rd0_value_i)
        ,.ra_i(ra0_i)
        ,.rb_i(rb0_i)

        // Outputs
        ,.ra_value_o(ra0_value_w[0])
        ,.rb_value_o(rb0_value_w[0])
    );

    biriscv_xilinx_2r1w
    u_a_1
    (
        // Inputs
         .clk_i(clk_i)
        ,.rst_i(rst_i)
        ,.rd0_i(rd1_i)
        ,.rd0_value_i(rd1_value_i)
        ,.ra_i(ra0_i)
        ,.rb_i(rb0_i)

        // Outputs
        ,.ra_value_o(ra0_value_w[1])
        ,.rb_value_o(rb0_value_w[1])
    );

    biriscv_xilinx_2r1w
    u_b_0
    (
        // Inputs
         .clk_i(clk_i)
        ,.rst_i(rst_i)
        ,.rd0_i(rd0_i)
        ,.rd0_value_i(rd0_value_i)
        ,.ra_i(ra1_i)
        ,.rb_i(rb1_i)

        // Outputs
        ,.ra_value_o(ra1_value_w[0])
        ,.rb_value_o(rb1_value_w[0])
    );

    biriscv_xilinx_2r1w
    u_b_1
    (
        // Inputs
         .clk_i(clk_i)
        ,.rst_i(rst_i)
        ,.rd0_i(rd1_i)
        ,.rd0_value_i(rd1_value_i)
        ,.ra_i(ra1_i)
        ,.rb_i(rb1_i)

        // Outputs
        ,.ra_value_o(ra1_value_w[1])
        ,.rb_value_o(rb1_value_w[1])
    );

    // Track latest register write 
    reg [31:0] reg_src_q;
    reg [31:0] reg_src_r;

    always @ *
    begin
        reg_src_r = reg_src_q;

        reg_src_r[rd0_i] = 1'b0;
        reg_src_r[rd1_i] = 1'b1;

        // Ignore register 0
        reg_src_r[0] = 1'b0;
    end 

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        reg_src_q <= 32'b0;
    else
        reg_src_q <= reg_src_r;


    assign ra0_value_o = reg_src_q[ra0_i] ? ra0_value_w[1] : ra0_value_w[0];
    assign rb0_value_o = reg_src_q[rb0_i] ? rb0_value_w[1] : rb0_value_w[0];
    assign ra1_value_o = reg_src_q[ra1_i] ? ra1_value_w[1] : ra1_value_w[0];
    assign rb1_value_o = reg_src_q[rb1_i] ? rb1_value_w[1] : rb1_value_w[0];
end
//-----------------------------------------------------------------
// Flop based register file
//-----------------------------------------------------------------
else
begin: REGFILE
    reg [31:0] reg_r1_q;
    reg [31:0] reg_r2_q;
    reg [31:0] reg_r3_q;
    reg [31:0] reg_r4_q;
    reg [31:0] reg_r5_q;
    reg [31:0] reg_r6_q;
    reg [31:0] reg_r7_q;
    reg [31:0] reg_r8_q;
    reg [31:0] reg_r9_q;
    reg [31:0] reg_r10_q;
    reg [31:0] reg_r11_q;
    reg [31:0] reg_r12_q;
    reg [31:0] reg_r13_q;
    reg [31:0] reg_r14_q;
    reg [31:0] reg_r15_q;
    reg [31:0] reg_r16_q;
    reg [31:0] reg_r17_q;
    reg [31:0] reg_r18_q;
    reg [31:0] reg_r19_q;
    reg [31:0] reg_r20_q;
    reg [31:0] reg_r21_q;
    reg [31:0] reg_r22_q;
    reg [31:0] reg_r23_q;
    reg [31:0] reg_r24_q;
    reg [31:0] reg_r25_q;
    reg [31:0] reg_r26_q;
    reg [31:0] reg_r27_q;
    reg [31:0] reg_r28_q;
    reg [31:0] reg_r29_q;
    reg [31:0] reg_r30_q;
    reg [31:0] reg_r31_q;

    // Simulation friendly names
    wire [31:0] x0_zero_w = 32'b0;
    wire [31:0] x1_ra_w   = reg_r1_q;
    wire [31:0] x2_sp_w   = reg_r2_q;
    wire [31:0] x3_gp_w   = reg_r3_q;
    wire [31:0] x4_tp_w   = reg_r4_q;
    wire [31:0] x5_t0_w   = reg_r5_q;
    wire [31:0] x6_t1_w   = reg_r6_q;
    wire [31:0] x7_t2_w   = reg_r7_q;
    wire [31:0] x8_s0_w   = reg_r8_q;
    wire [31:0] x9_s1_w   = reg_r9_q;
    wire [31:0] x10_a0_w  = reg_r10_q;
    wire [31:0] x11_a1_w  = reg_r11_q;
    wire [31:0] x12_a2_w  = reg_r12_q;
    wire [31:0] x13_a3_w  = reg_r13_q;
    wire [31:0] x14_a4_w  = reg_r14_q;
    wire [31:0] x15_a5_w  = reg_r15_q;
    wire [31:0] x16_a6_w  = reg_r16_q;
    wire [31:0] x17_a7_w  = reg_r17_q;
    wire [31:0] x18_s2_w  = reg_r18_q;
    wire [31:0] x19_s3_w  = reg_r19_q;
    wire [31:0] x20_s4_w  = reg_r20_q;
    wire [31:0] x21_s5_w  = reg_r21_q;
    wire [31:0] x22_s6_w  = reg_r22_q;
    wire [31:0] x23_s7_w  = reg_r23_q;
    wire [31:0] x24_s8_w  = reg_r24_q;
    wire [31:0] x25_s9_w  = reg_r25_q;
    wire [31:0] x26_s10_w = reg_r26_q;
    wire [31:0] x27_s11_w = reg_r27_q;
    wire [31:0] x28_t3_w  = reg_r28_q;
    wire [31:0] x29_t4_w  = reg_r29_q;
    wire [31:0] x30_t5_w  = reg_r30_q;
    wire [31:0] x31_t6_w  = reg_r31_q;

    //-----------------------------------------------------------------
    // Flop based register File (for simulation)
    //-----------------------------------------------------------------

    // Synchronous register write back
    always @ (posedge clk_i )
    if (rst_i)
    begin
        reg_r1_q       <= 32'h00000000;
        reg_r2_q       <= 32'h00000000;
        reg_r3_q       <= 32'h00000000;
        reg_r4_q       <= 32'h00000000;
        reg_r5_q       <= 32'h00000000;
        reg_r6_q       <= 32'h00000000;
        reg_r7_q       <= 32'h00000000;
        reg_r8_q       <= 32'h00000000;
        reg_r9_q       <= 32'h00000000;
        reg_r10_q      <= 32'h00000000;
        reg_r11_q      <= 32'h00000000;
        reg_r12_q      <= 32'h00000000;
        reg_r13_q      <= 32'h00000000;
        reg_r14_q      <= 32'h00000000;
        reg_r15_q      <= 32'h00000000;
        reg_r16_q      <= 32'h00000000;
        reg_r17_q      <= 32'h00000000;
        reg_r18_q      <= 32'h00000000;
        reg_r19_q      <= 32'h00000000;
        reg_r20_q      <= 32'h00000000;
        reg_r21_q      <= 32'h00000000;
        reg_r22_q      <= 32'h00000000;
        reg_r23_q      <= 32'h00000000;
        reg_r24_q      <= 32'h00000000;
        reg_r25_q      <= 32'h00000000;
        reg_r26_q      <= 32'h00000000;
        reg_r27_q      <= 32'h00000000;
        reg_r28_q      <= 32'h00000000;
        reg_r29_q      <= 32'h00000000;
        reg_r30_q      <= 32'h00000000;
        reg_r31_q      <= 32'h00000000;
    end
    else
    begin
        if      (rd0_i == 5'd1) reg_r1_q <= rd0_value_i;
        else if (rd1_i == 5'd1) reg_r1_q <= rd1_value_i;
        if      (rd0_i == 5'd2) reg_r2_q <= rd0_value_i;
        else if (rd1_i == 5'd2) reg_r2_q <= rd1_value_i;
        if      (rd0_i == 5'd3) reg_r3_q <= rd0_value_i;
        else if (rd1_i == 5'd3) reg_r3_q <= rd1_value_i;
        if      (rd0_i == 5'd4) reg_r4_q <= rd0_value_i;
        else if (rd1_i == 5'd4) reg_r4_q <= rd1_value_i;
        if      (rd0_i == 5'd5) reg_r5_q <= rd0_value_i;
        else if (rd1_i == 5'd5) reg_r5_q <= rd1_value_i;
        if      (rd0_i == 5'd6) reg_r6_q <= rd0_value_i;
        else if (rd1_i == 5'd6) reg_r6_q <= rd1_value_i;
        if      (rd0_i == 5'd7) reg_r7_q <= rd0_value_i;
        else if (rd1_i == 5'd7) reg_r7_q <= rd1_value_i;
        if      (rd0_i == 5'd8) reg_r8_q <= rd0_value_i;
        else if (rd1_i == 5'd8) reg_r8_q <= rd1_value_i;
        if      (rd0_i == 5'd9) reg_r9_q <= rd0_value_i;
        else if (rd1_i == 5'd9) reg_r9_q <= rd1_value_i;
        if      (rd0_i == 5'd10) reg_r10_q <= rd0_value_i;
        else if (rd1_i == 5'd10) reg_r10_q <= rd1_value_i;
        if      (rd0_i == 5'd11) reg_r11_q <= rd0_value_i;
        else if (rd1_i == 5'd11) reg_r11_q <= rd1_value_i;
        if      (rd0_i == 5'd12) reg_r12_q <= rd0_value_i;
        else if (rd1_i == 5'd12) reg_r12_q <= rd1_value_i;
        if      (rd0_i == 5'd13) reg_r13_q <= rd0_value_i;
        else if (rd1_i == 5'd13) reg_r13_q <= rd1_value_i;
        if      (rd0_i == 5'd14) reg_r14_q <= rd0_value_i;
        else if (rd1_i == 5'd14) reg_r14_q <= rd1_value_i;
        if      (rd0_i == 5'd15) reg_r15_q <= rd0_value_i;
        else if (rd1_i == 5'd15) reg_r15_q <= rd1_value_i;
        if      (rd0_i == 5'd16) reg_r16_q <= rd0_value_i;
        else if (rd1_i == 5'd16) reg_r16_q <= rd1_value_i;
        if      (rd0_i == 5'd17) reg_r17_q <= rd0_value_i;
        else if (rd1_i == 5'd17) reg_r17_q <= rd1_value_i;
        if      (rd0_i == 5'd18) reg_r18_q <= rd0_value_i;
        else if (rd1_i == 5'd18) reg_r18_q <= rd1_value_i;
        if      (rd0_i == 5'd19) reg_r19_q <= rd0_value_i;
        else if (rd1_i == 5'd19) reg_r19_q <= rd1_value_i;
        if      (rd0_i == 5'd20) reg_r20_q <= rd0_value_i;
        else if (rd1_i == 5'd20) reg_r20_q <= rd1_value_i;
        if      (rd0_i == 5'd21) reg_r21_q <= rd0_value_i;
        else if (rd1_i == 5'd21) reg_r21_q <= rd1_value_i;
        if      (rd0_i == 5'd22) reg_r22_q <= rd0_value_i;
        else if (rd1_i == 5'd22) reg_r22_q <= rd1_value_i;
        if      (rd0_i == 5'd23) reg_r23_q <= rd0_value_i;
        else if (rd1_i == 5'd23) reg_r23_q <= rd1_value_i;
        if      (rd0_i == 5'd24) reg_r24_q <= rd0_value_i;
        else if (rd1_i == 5'd24) reg_r24_q <= rd1_value_i;
        if      (rd0_i == 5'd25) reg_r25_q <= rd0_value_i;
        else if (rd1_i == 5'd25) reg_r25_q <= rd1_value_i;
        if      (rd0_i == 5'd26) reg_r26_q <= rd0_value_i;
        else if (rd1_i == 5'd26) reg_r26_q <= rd1_value_i;
        if      (rd0_i == 5'd27) reg_r27_q <= rd0_value_i;
        else if (rd1_i == 5'd27) reg_r27_q <= rd1_value_i;
        if      (rd0_i == 5'd28) reg_r28_q <= rd0_value_i;
        else if (rd1_i == 5'd28) reg_r28_q <= rd1_value_i;
        if      (rd0_i == 5'd29) reg_r29_q <= rd0_value_i;
        else if (rd1_i == 5'd29) reg_r29_q <= rd1_value_i;
        if      (rd0_i == 5'd30) reg_r30_q <= rd0_value_i;
        else if (rd1_i == 5'd30) reg_r30_q <= rd1_value_i;
        if      (rd0_i == 5'd31) reg_r31_q <= rd0_value_i;
        else if (rd1_i == 5'd31) reg_r31_q <= rd1_value_i;
    end

    //-----------------------------------------------------------------
    // Asynchronous read
    //-----------------------------------------------------------------
    reg [31:0] ra0_value_r;
    reg [31:0] rb0_value_r;
    always @ *
    begin
        case (ra0_i)
        5'd1: ra0_value_r = reg_r1_q;
        5'd2: ra0_value_r = reg_r2_q;
        5'd3: ra0_value_r = reg_r3_q;
        5'd4: ra0_value_r = reg_r4_q;
        5'd5: ra0_value_r = reg_r5_q;
        5'd6: ra0_value_r = reg_r6_q;
        5'd7: ra0_value_r = reg_r7_q;
        5'd8: ra0_value_r = reg_r8_q;
        5'd9: ra0_value_r = reg_r9_q;
        5'd10: ra0_value_r = reg_r10_q;
        5'd11: ra0_value_r = reg_r11_q;
        5'd12: ra0_value_r = reg_r12_q;
        5'd13: ra0_value_r = reg_r13_q;
        5'd14: ra0_value_r = reg_r14_q;
        5'd15: ra0_value_r = reg_r15_q;
        5'd16: ra0_value_r = reg_r16_q;
        5'd17: ra0_value_r = reg_r17_q;
        5'd18: ra0_value_r = reg_r18_q;
        5'd19: ra0_value_r = reg_r19_q;
        5'd20: ra0_value_r = reg_r20_q;
        5'd21: ra0_value_r = reg_r21_q;
        5'd22: ra0_value_r = reg_r22_q;
        5'd23: ra0_value_r = reg_r23_q;
        5'd24: ra0_value_r = reg_r24_q;
        5'd25: ra0_value_r = reg_r25_q;
        5'd26: ra0_value_r = reg_r26_q;
        5'd27: ra0_value_r = reg_r27_q;
        5'd28: ra0_value_r = reg_r28_q;
        5'd29: ra0_value_r = reg_r29_q;
        5'd30: ra0_value_r = reg_r30_q;
        5'd31: ra0_value_r = reg_r31_q;
        default : ra0_value_r = 32'h00000000;
        endcase

        case (rb0_i)
        5'd1: rb0_value_r = reg_r1_q;
        5'd2: rb0_value_r = reg_r2_q;
        5'd3: rb0_value_r = reg_r3_q;
        5'd4: rb0_value_r = reg_r4_q;
        5'd5: rb0_value_r = reg_r5_q;
        5'd6: rb0_value_r = reg_r6_q;
        5'd7: rb0_value_r = reg_r7_q;
        5'd8: rb0_value_r = reg_r8_q;
        5'd9: rb0_value_r = reg_r9_q;
        5'd10: rb0_value_r = reg_r10_q;
        5'd11: rb0_value_r = reg_r11_q;
        5'd12: rb0_value_r = reg_r12_q;
        5'd13: rb0_value_r = reg_r13_q;
        5'd14: rb0_value_r = reg_r14_q;
        5'd15: rb0_value_r = reg_r15_q;
        5'd16: rb0_value_r = reg_r16_q;
        5'd17: rb0_value_r = reg_r17_q;
        5'd18: rb0_value_r = reg_r18_q;
        5'd19: rb0_value_r = reg_r19_q;
        5'd20: rb0_value_r = reg_r20_q;
        5'd21: rb0_value_r = reg_r21_q;
        5'd22: rb0_value_r = reg_r22_q;
        5'd23: rb0_value_r = reg_r23_q;
        5'd24: rb0_value_r = reg_r24_q;
        5'd25: rb0_value_r = reg_r25_q;
        5'd26: rb0_value_r = reg_r26_q;
        5'd27: rb0_value_r = reg_r27_q;
        5'd28: rb0_value_r = reg_r28_q;
        5'd29: rb0_value_r = reg_r29_q;
        5'd30: rb0_value_r = reg_r30_q;
        5'd31: rb0_value_r = reg_r31_q;
        default : rb0_value_r = 32'h00000000;
        endcase
    end

    assign ra0_value_o = ra0_value_r;
    assign rb0_value_o = rb0_value_r;


    reg [31:0] ra1_value_r;
    reg [31:0] rb1_value_r;
    always @ *
    begin
        case (ra1_i)
        5'd1: ra1_value_r = reg_r1_q;
        5'd2: ra1_value_r = reg_r2_q;
        5'd3: ra1_value_r = reg_r3_q;
        5'd4: ra1_value_r = reg_r4_q;
        5'd5: ra1_value_r = reg_r5_q;
        5'd6: ra1_value_r = reg_r6_q;
        5'd7: ra1_value_r = reg_r7_q;
        5'd8: ra1_value_r = reg_r8_q;
        5'd9: ra1_value_r = reg_r9_q;
        5'd10: ra1_value_r = reg_r10_q;
        5'd11: ra1_value_r = reg_r11_q;
        5'd12: ra1_value_r = reg_r12_q;
        5'd13: ra1_value_r = reg_r13_q;
        5'd14: ra1_value_r = reg_r14_q;
        5'd15: ra1_value_r = reg_r15_q;
        5'd16: ra1_value_r = reg_r16_q;
        5'd17: ra1_value_r = reg_r17_q;
        5'd18: ra1_value_r = reg_r18_q;
        5'd19: ra1_value_r = reg_r19_q;
        5'd20: ra1_value_r = reg_r20_q;
        5'd21: ra1_value_r = reg_r21_q;
        5'd22: ra1_value_r = reg_r22_q;
        5'd23: ra1_value_r = reg_r23_q;
        5'd24: ra1_value_r = reg_r24_q;
        5'd25: ra1_value_r = reg_r25_q;
        5'd26: ra1_value_r = reg_r26_q;
        5'd27: ra1_value_r = reg_r27_q;
        5'd28: ra1_value_r = reg_r28_q;
        5'd29: ra1_value_r = reg_r29_q;
        5'd30: ra1_value_r = reg_r30_q;
        5'd31: ra1_value_r = reg_r31_q;
        default : ra1_value_r = 32'h00000000;
        endcase

        case (rb1_i)
        5'd1: rb1_value_r = reg_r1_q;
        5'd2: rb1_value_r = reg_r2_q;
        5'd3: rb1_value_r = reg_r3_q;
        5'd4: rb1_value_r = reg_r4_q;
        5'd5: rb1_value_r = reg_r5_q;
        5'd6: rb1_value_r = reg_r6_q;
        5'd7: rb1_value_r = reg_r7_q;
        5'd8: rb1_value_r = reg_r8_q;
        5'd9: rb1_value_r = reg_r9_q;
        5'd10: rb1_value_r = reg_r10_q;
        5'd11: rb1_value_r = reg_r11_q;
        5'd12: rb1_value_r = reg_r12_q;
        5'd13: rb1_value_r = reg_r13_q;
        5'd14: rb1_value_r = reg_r14_q;
        5'd15: rb1_value_r = reg_r15_q;
        5'd16: rb1_value_r = reg_r16_q;
        5'd17: rb1_value_r = reg_r17_q;
        5'd18: rb1_value_r = reg_r18_q;
        5'd19: rb1_value_r = reg_r19_q;
        5'd20: rb1_value_r = reg_r20_q;
        5'd21: rb1_value_r = reg_r21_q;
        5'd22: rb1_value_r = reg_r22_q;
        5'd23: rb1_value_r = reg_r23_q;
        5'd24: rb1_value_r = reg_r24_q;
        5'd25: rb1_value_r = reg_r25_q;
        5'd26: rb1_value_r = reg_r26_q;
        5'd27: rb1_value_r = reg_r27_q;
        5'd28: rb1_value_r = reg_r28_q;
        5'd29: rb1_value_r = reg_r29_q;
        5'd30: rb1_value_r = reg_r30_q;
        5'd31: rb1_value_r = reg_r31_q;
        default : rb1_value_r = 32'h00000000;
        endcase
    end

    assign ra1_value_o = ra1_value_r;
    assign rb1_value_o = rb1_value_r;

    //-------------------------------------------------------------
    // get_register: Read register file
    //-------------------------------------------------------------
    `ifdef verilator
    function [31:0] get_register; /*verilator public*/
        input [4:0] r;
    begin
        case (r)
        5'd1: get_register = reg_r1_q;
        5'd2: get_register = reg_r2_q;
        5'd3: get_register = reg_r3_q;
        5'd4: get_register = reg_r4_q;
        5'd5: get_register = reg_r5_q;
        5'd6: get_register = reg_r6_q;
        5'd7: get_register = reg_r7_q;
        5'd8: get_register = reg_r8_q;
        5'd9: get_register = reg_r9_q;
        5'd10: get_register = reg_r10_q;
        5'd11: get_register = reg_r11_q;
        5'd12: get_register = reg_r12_q;
        5'd13: get_register = reg_r13_q;
        5'd14: get_register = reg_r14_q;
        5'd15: get_register = reg_r15_q;
        5'd16: get_register = reg_r16_q;
        5'd17: get_register = reg_r17_q;
        5'd18: get_register = reg_r18_q;
        5'd19: get_register = reg_r19_q;
        5'd20: get_register = reg_r20_q;
        5'd21: get_register = reg_r21_q;
        5'd22: get_register = reg_r22_q;
        5'd23: get_register = reg_r23_q;
        5'd24: get_register = reg_r24_q;
        5'd25: get_register = reg_r25_q;
        5'd26: get_register = reg_r26_q;
        5'd27: get_register = reg_r27_q;
        5'd28: get_register = reg_r28_q;
        5'd29: get_register = reg_r29_q;
        5'd30: get_register = reg_r30_q;
        5'd31: get_register = reg_r31_q;
        default : get_register = 32'h00000000;
        endcase
    end
    endfunction
    //-------------------------------------------------------------
    // set_register: Write register file
    //-------------------------------------------------------------
    function set_register; /*verilator public*/
        input [4:0] r;
        input [31:0] value;
    begin
        //case (r)
        //5'd1:  reg_r1_q  <= value;
        //5'd2:  reg_r2_q  <= value;
        //5'd3:  reg_r3_q  <= value;
        //5'd4:  reg_r4_q  <= value;
        //5'd5:  reg_r5_q  <= value;
        //5'd6:  reg_r6_q  <= value;
        //5'd7:  reg_r7_q  <= value;
        //5'd8:  reg_r8_q  <= value;
        //5'd9:  reg_r9_q  <= value;
        //5'd10: reg_r10_q <= value;
        //5'd11: reg_r11_q <= value;
        //5'd12: reg_r12_q <= value;
        //5'd13: reg_r13_q <= value;
        //5'd14: reg_r14_q <= value;
        //5'd15: reg_r15_q <= value;
        //5'd16: reg_r16_q <= value;
        //5'd17: reg_r17_q <= value;
        //5'd18: reg_r18_q <= value;
        //5'd19: reg_r19_q <= value;
        //5'd20: reg_r20_q <= value;
        //5'd21: reg_r21_q <= value;
        //5'd22: reg_r22_q <= value;
        //5'd23: reg_r23_q <= value;
        //5'd24: reg_r24_q <= value;
        //5'd25: reg_r25_q <= value;
        //5'd26: reg_r26_q <= value;
        //5'd27: reg_r27_q <= value;
        //5'd28: reg_r28_q <= value;
        //5'd29: reg_r29_q <= value;
        //5'd30: reg_r30_q <= value;
        //5'd31: reg_r31_q <= value;
        //default :
        //    ;
        //endcase
    end
    endfunction
    `endif

end
endgenerate

endmodule
