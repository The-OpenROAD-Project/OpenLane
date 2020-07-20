/*
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief OCS blitter implementation with WISHBONE master and slave interface.
 */

/*! \brief \copybrief ocs_blitter.v

List of blitter registers:
\verbatim
Implemented:
   BLTCON0     ~040  W   A       Blitter control register 0
   BLTCON1     ~042  W   A( E )  Blitter control register 1
   BLTAFWM     ~044  W   A       Blitter first word mask for source A
   BLTALWM     ~046  W   A       Blitter last word mask for source A
   BLTCPTH   + ~048  W   A       Blitter pointer to source C (high 3 bits)
   BLTCPTL   + ~04A  W   A       Blitter pointer to source C (low 15 bits)
   BLTBPTH   + ~04C  W   A       Blitter pointer to source B (high 3 bits)
   BLTBPTL   + ~04E  W   A       Blitter pointer to source B (low 15 bits)
   BLTAPTH   + ~050  W   A( E )  Blitter pointer to source A (high 3 bits)
   BLTAPTL   + ~052  W   A       Blitter pointer to source A (low 15 bits)
   BLTDPTH   + ~054  W   A       Blitter pointer to destination D (high 3 bits)
   BLTDPTL   + ~056  W   A       Blitter pointer to destination D (low 15 bits)
   BLTSIZE     ~058  W   A       Blitter start and size (window width,height)
   BLTCMOD     ~060  W   A       Blitter modulo for source C
   BLTBMOD     ~062  W   A       Blitter modulo for source B
   BLTAMOD     ~064  W   A       Blitter modulo for source A
   BLTDMOD     ~066  W   A       Blitter modulo for destination D
   BLTCDAT   % ~070  W   A       Blitter source C data register
   BLTBDAT   % ~072  W   A       Blitter source B data register
   BLTADAT   % ~074  W   A       Blitter source A data register
Not implemented:
   BLTDDAT   & *000  ER  A       Blitter destination early read (dummy address)
\endverbatim
*/
module ocs_blitter(
    //% \name Clock and reset
    //% @{
    input               CLK_I,
    input               reset_n,
    //% @}
    
    //% \name WISHBONE master
    //% @{
    output reg          CYC_O,
    output reg          STB_O,
    output reg          WE_O,
    output reg [31:2]   ADR_O,
    output reg [3:0]    SEL_O,
    output reg [31:0]   master_DAT_O,
    input [31:0]        master_DAT_I,
    input               ACK_I,
    //% @}
    
    //% \name WISHBONE slave
    //% @{
    input               CYC_I,
    input               STB_I,
    input               WE_I,
    input [8:2]         ADR_I,
    input [3:0]         SEL_I,
    input [31:0]        slave_DAT_I,
    output reg          ACK_O,
    //% @}
    
    //% \name Internal OCS ports
    //% @{
    input [10:0]        dma_con,
    
    output reg          blitter_irq,
    output reg          blitter_zero,
    output reg          blitter_busy
    //% @}
);

reg [15:0] a_first_word_mask;
reg [15:0] a_last_word_mask;
reg [15:0] blt_con0;
reg [15:0] blt_con1;
reg [15:0] blt_size;
reg [5:0] blt_width_in_words;

reg [63:0] a_dat;
reg [63:0] b_dat;
reg [47:0] c_dat;
reg [15:0] a_mod;
reg [15:0] b_mod;
reg [15:0] c_mod;
reg [15:0] d_mod;
reg [31:0] a_address;
reg [31:0] b_address;
reg [31:0] c_address;
reg [31:0] d_address;
reg [3:0] a_shift_saved;
reg [3:0] b_shift_saved;

reg [1:0] a_avail;
reg [1:0] b_avail;
reg [1:0] c_avail;
reg line_single;
reg fill_carry;

reg max_width;

reg [3:0] state;
parameter [3:0]
    S_IDLE          = 3'd0,
    S_CHECK_LOAD    = 3'd1,
    S_LOAD_A        = 3'd2,
    S_LOAD_B        = 3'd3,
    S_LOAD_C        = 3'd4,
    S_CHECK_SAVE    = 3'd5,
    S_SAVE_D        = 3'd6;

wire reverse;
// reverse: LINE=0, DESC=1
assign reverse = (blt_con1[0] == 1'b0 && blt_con1[1] == 1'b1);

// mask, even when A channel not enabled
wire [15:0] a_dat_mask;
assign a_dat_mask = 
    (a_enabled == 1'b1)? 16'hFFFF :
    (blt_width_in_words[5:0] == blt_size[5:0] && blt_width_in_words[5:0] == 6'd1)? a_first_word_mask & a_last_word_mask :
    (blt_width_in_words[5:0] == blt_size[5:0])? a_first_word_mask :
    (blt_width_in_words[5:0] == 6'd1)? a_last_word_mask :
    16'hFFFF;

wire [63:0] a_dat_final;
assign a_dat_final = (reverse == 1'b0) ? 
    { a_dat[63:48], a_dat[47:32] & a_dat_mask, a_dat[31:0] } :
    { a_dat[63:32], a_dat[31:16] & a_dat_mask, a_dat[15:0] };

wire [15:0] a_shifted;
assign a_shifted =
    (line_single == 1'b1 && blt_con1[0] == 1'b1 && blt_con1[1] == 1'b1) ? 16'd0 :
    (a_shift_saved == 4'd0) ? ((reverse == 1'b0) ? a_dat_final[47:32] : a_dat_final[31:16]) :
    (a_shift_saved == 4'd1) ? ((reverse == 1'b0) ? a_dat_final[48:33] : a_dat_final[30:15]) :
    (a_shift_saved == 4'd2) ? ((reverse == 1'b0) ? a_dat_final[49:34] : a_dat_final[29:14]) :
    (a_shift_saved == 4'd3) ? ((reverse == 1'b0) ? a_dat_final[50:35] : a_dat_final[28:13]) :
    (a_shift_saved == 4'd4) ? ((reverse == 1'b0) ? a_dat_final[51:36] : a_dat_final[27:12]) :
    (a_shift_saved == 4'd5) ? ((reverse == 1'b0) ? a_dat_final[52:37] : a_dat_final[26:11]) :
    (a_shift_saved == 4'd6) ? ((reverse == 1'b0) ? a_dat_final[53:38] : a_dat_final[25:10]) :
    (a_shift_saved == 4'd7) ? ((reverse == 1'b0) ? a_dat_final[54:39] : a_dat_final[24:9]) :
    (a_shift_saved == 4'd8) ? ((reverse == 1'b0) ? a_dat_final[55:40] : a_dat_final[23:8]) :
    (a_shift_saved == 4'd9) ? ((reverse == 1'b0) ? a_dat_final[56:41] : a_dat_final[22:7]) :
    (a_shift_saved == 4'd10) ? ((reverse == 1'b0) ? a_dat_final[57:42] : a_dat_final[21:6]) :
    (a_shift_saved == 4'd11) ? ((reverse == 1'b0) ? a_dat_final[58:43] : a_dat_final[20:5]) :
    (a_shift_saved == 4'd12) ? ((reverse == 1'b0) ? a_dat_final[59:44] : a_dat_final[19:4]) :
    (a_shift_saved == 4'd13) ? ((reverse == 1'b0) ? a_dat_final[60:45] : a_dat_final[18:3]) :
    (a_shift_saved == 4'd14) ? ((reverse == 1'b0) ? a_dat_final[61:46] : a_dat_final[17:2]) :
    ((reverse == 1'b0) ? a_dat_final[62:47] : a_dat_final[16:1]);

wire [15:0] b_shifted;
assign b_shifted =
    (b_shift_saved == 4'd0) ? ((reverse == 1'b0) ? b_dat[47:32] : b_dat[31:16]) :
    (b_shift_saved == 4'd1) ? ((reverse == 1'b0) ? b_dat[48:33] : b_dat[30:15]) :
    (b_shift_saved == 4'd2) ? ((reverse == 1'b0) ? b_dat[49:34] : b_dat[29:14]) :
    (b_shift_saved == 4'd3) ? ((reverse == 1'b0) ? b_dat[50:35] : b_dat[28:13]) :
    (b_shift_saved == 4'd4) ? ((reverse == 1'b0) ? b_dat[51:36] : b_dat[27:12]) :
    (b_shift_saved == 4'd5) ? ((reverse == 1'b0) ? b_dat[52:37] : b_dat[26:11]) :
    (b_shift_saved == 4'd6) ? ((reverse == 1'b0) ? b_dat[53:38] : b_dat[25:10]) :
    (b_shift_saved == 4'd7) ? ((reverse == 1'b0) ? b_dat[54:39] : b_dat[24:9]) :
    (b_shift_saved == 4'd8) ? ((reverse == 1'b0) ? b_dat[55:40] : b_dat[23:8]) :
    (b_shift_saved == 4'd9) ? ((reverse == 1'b0) ? b_dat[56:41] : b_dat[22:7]) :
    (b_shift_saved == 4'd10) ? ((reverse == 1'b0) ? b_dat[57:42] : b_dat[21:6]) :
    (b_shift_saved == 4'd11) ? ((reverse == 1'b0) ? b_dat[58:43] : b_dat[20:5]) :
    (b_shift_saved == 4'd12) ? ((reverse == 1'b0) ? b_dat[59:44] : b_dat[19:4]) :
    (b_shift_saved == 4'd13) ? ((reverse == 1'b0) ? b_dat[60:45] : b_dat[18:3]) :
    (b_shift_saved == 4'd14) ? ((reverse == 1'b0) ? b_dat[61:46] : b_dat[17:2]) :
    ((reverse == 1'b0) ? b_dat[62:47] : b_dat[16:1]);

wire [15:0] b_shifted_final;
assign b_shifted_final = (blt_con1[0] == 1'b0) ? b_shifted : ( (b_shifted[0] == 1'b0) ? 16'd0 :  16'hFFFF );

wire [15:0] c_selected;
assign c_selected = (reverse == 1'b0) ? c_dat[47:32] : c_dat[15:0];

wire [15:0] minterm_output;
assign minterm_output = {
    blt_con0[ {1'b0, a_shifted[15], b_shifted_final[15], c_selected[15]} ],
    blt_con0[ {1'b0, a_shifted[14], b_shifted_final[14], c_selected[14]} ],
    blt_con0[ {1'b0, a_shifted[13], b_shifted_final[13], c_selected[13]} ],
    blt_con0[ {1'b0, a_shifted[12], b_shifted_final[12], c_selected[12]} ],
    blt_con0[ {1'b0, a_shifted[11], b_shifted_final[11], c_selected[11]} ],
    blt_con0[ {1'b0, a_shifted[10], b_shifted_final[10], c_selected[10]} ],
    blt_con0[ {1'b0, a_shifted[9], b_shifted_final[9], c_selected[9]} ],
    blt_con0[ {1'b0, a_shifted[8], b_shifted_final[8], c_selected[8]} ],
    blt_con0[ {1'b0, a_shifted[7], b_shifted_final[7], c_selected[7]} ],
    blt_con0[ {1'b0, a_shifted[6], b_shifted_final[6], c_selected[6]} ],
    blt_con0[ {1'b0, a_shifted[5], b_shifted_final[5], c_selected[5]} ],
    blt_con0[ {1'b0, a_shifted[4], b_shifted_final[4], c_selected[4]} ],
    blt_con0[ {1'b0, a_shifted[3], b_shifted_final[3], c_selected[3]} ],
    blt_con0[ {1'b0, a_shifted[2], b_shifted_final[2], c_selected[2]} ],
    blt_con0[ {1'b0, a_shifted[1], b_shifted_final[1], c_selected[1]} ],
    blt_con0[ {1'b0, a_shifted[0], b_shifted_final[0], c_selected[0]} ]
};
wire [15:0] xor_chains;
assign xor_chains = {                  
    minterm_output[0] ^ minterm_output[1]  ^ minterm_output[2]  ^ minterm_output[3] ^ minterm_output[4]  ^ minterm_output[5]  ^
                        minterm_output[6]  ^ minterm_output[7]  ^ minterm_output[8]  ^ minterm_output[9] ^ minterm_output[10] ^ minterm_output[11] ^
                        minterm_output[12] ^ minterm_output[13] ^ minterm_output[14],
    minterm_output[0] ^ minterm_output[1]  ^ minterm_output[2]  ^ minterm_output[3] ^ minterm_output[4]  ^ minterm_output[5]  ^
                        minterm_output[6]  ^ minterm_output[7]  ^ minterm_output[8]  ^ minterm_output[9] ^ minterm_output[10] ^ minterm_output[11] ^
                        minterm_output[12] ^ minterm_output[13],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4]  ^ minterm_output[5]  ^
                        minterm_output[6] ^ minterm_output[7] ^ minterm_output[8] ^ minterm_output[9] ^ minterm_output[10] ^ minterm_output[11] ^
                        minterm_output[12],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4]  ^ minterm_output[5]  ^
                        minterm_output[6] ^ minterm_output[7] ^ minterm_output[8] ^ minterm_output[9] ^ minterm_output[10] ^ minterm_output[11],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4]  ^ minterm_output[5]  ^
                        minterm_output[6] ^ minterm_output[7] ^ minterm_output[8] ^ minterm_output[9] ^ minterm_output[10],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4] ^ minterm_output[5]   ^
                        minterm_output[6] ^ minterm_output[7] ^ minterm_output[8] ^ minterm_output[9],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4] ^ minterm_output[5]   ^
                        minterm_output[6] ^ minterm_output[7] ^ minterm_output[8],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4] ^ minterm_output[5]   ^
                        minterm_output[6] ^ minterm_output[7],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4] ^ minterm_output[5]   ^
                        minterm_output[6],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4] ^ minterm_output[5],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3] ^ minterm_output[4],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2] ^ minterm_output[3],
    minterm_output[0] ^ minterm_output[1] ^ minterm_output[2],
    minterm_output[0] ^ minterm_output[1],               
    minterm_output[0],                
    1'b0
};
wire [15:0] final_output;
assign final_output = 
    (blt_con1[0] == 1'b1 || (blt_con1[3] == 1'b0 && blt_con1[4] == 1'b0)) ? minterm_output :
    (blt_con1[4] == 1'b1) ? {
        fill_carry ^ xor_chains[15] ^ minterm_output[15],
        fill_carry ^ xor_chains[14] ^ minterm_output[14],
        fill_carry ^ xor_chains[13] ^ minterm_output[13],
        fill_carry ^ xor_chains[12] ^ minterm_output[12],
        fill_carry ^ xor_chains[11] ^ minterm_output[11],
        fill_carry ^ xor_chains[10] ^ minterm_output[10],
        fill_carry ^ xor_chains[9] ^ minterm_output[9],
        fill_carry ^ xor_chains[8] ^ minterm_output[8],
        fill_carry ^ xor_chains[7] ^ minterm_output[7],
        fill_carry ^ xor_chains[6] ^ minterm_output[6],
        fill_carry ^ xor_chains[5] ^ minterm_output[5],
        fill_carry ^ xor_chains[4] ^ minterm_output[4],
        fill_carry ^ xor_chains[3] ^ minterm_output[3],
        fill_carry ^ xor_chains[2] ^ minterm_output[2],
        fill_carry ^ xor_chains[1] ^ minterm_output[1],
        fill_carry ^ xor_chains[0] ^ minterm_output[0]
   } : {
        (fill_carry ^ xor_chains[15]) | minterm_output[15],
        (fill_carry ^ xor_chains[14]) | minterm_output[14],
        (fill_carry ^ xor_chains[13]) | minterm_output[13],
        (fill_carry ^ xor_chains[12]) | minterm_output[12],
        (fill_carry ^ xor_chains[11]) | minterm_output[11],
        (fill_carry ^ xor_chains[10]) | minterm_output[10],
        (fill_carry ^ xor_chains[9]) | minterm_output[9],
        (fill_carry ^ xor_chains[8]) | minterm_output[8],
        (fill_carry ^ xor_chains[7]) | minterm_output[7],
        (fill_carry ^ xor_chains[6]) | minterm_output[6],
        (fill_carry ^ xor_chains[5]) | minterm_output[5],
        (fill_carry ^ xor_chains[4]) | minterm_output[4],
        (fill_carry ^ xor_chains[3]) | minterm_output[3],
        (fill_carry ^ xor_chains[2]) | minterm_output[2],
        (fill_carry ^ xor_chains[1]) | minterm_output[1],
        (fill_carry ^ xor_chains[0]) | minterm_output[0]
   };

// DMAEN, BLTEN, USEA, LINE=0
wire a_enabled;
assign a_enabled = (dma_con[9] == 1'b1 && dma_con[6] == 1'b1 && blt_con0[11] == 1'b1 && blt_con1[0] == 1'b0);
// DMAEN, BLTEN, USEB
wire b_enabled;
assign b_enabled = (dma_con[9] == 1'b1 && dma_con[6] == 1'b1 && blt_con0[10] == 1'b1);
// DMAEN, BLTEN, USEC
wire c_enabled;
assign c_enabled = (dma_con[9] == 1'b1 && dma_con[6] == 1'b1 && blt_con0[9] == 1'b1);
// DMAEN, BLTEN, USED
wire d_enabled;
assign d_enabled = (dma_con[9] == 1'b1 && dma_con[6] == 1'b1 && blt_con0[8] == 1'b1);

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        CYC_O <= 1'b0;
        STB_O <= 1'b0;
        WE_O <= 1'b0;
        ADR_O <= 30'd0;
        SEL_O <= 4'b0000;
        master_DAT_O <= 32'd0;
        ACK_O <= 1'b0;
        blitter_irq <= 1'b0;
        blitter_zero <= 1'b0;
        blitter_busy <= 1'b0;
        
        a_first_word_mask <= 16'd0;
        a_last_word_mask <= 16'd0;
        blt_con0 <= 16'd0;
        blt_con1 <= 16'd0;
        blt_size <= 16'd0;
        blt_width_in_words <= 6'd0;
        a_dat <= 64'd0;
        b_dat <= 64'd0;
        c_dat <= 48'd0;
        a_mod <= 16'd0;
        b_mod <= 16'd0;
        c_mod <= 16'd0;
        d_mod <= 16'd0;
        a_address <= 32'd0;
        b_address <= 32'd0;
        c_address <= 32'd0;
        d_address <= 32'd0;
        a_shift_saved <= 4'd0;
        b_shift_saved <= 4'd0;
        
        a_avail <= 2'd0;
        b_avail <= 2'd0;
        c_avail <= 2'd0;
        line_single <= 1'b0;
        fill_carry <= 1'b0;
        
        max_width <= 1'b0;
        
        state <= S_IDLE;
    end
    else begin
        
        if(CYC_I == 1'b1 && STB_I == 1'b1 && /*WE_I == 1'b1 &&*/ ACK_O == 1'b0) ACK_O <= 1'b1;
        else ACK_O <= 1'b0;
        
        if(blitter_irq == 1'b1) blitter_irq <= 1'b0;
        
        // 040:     BLTCON0,    BLTCON1,
        // 044:     BLTAFWM,    BLTALWM,
        // 048:     BLTCPTH,    BLTCPTL,
        // 04C:     BLTBPTH,    BLTBPTL,
        // 050:     BLTAPTH,    BLTAPTL,
        // 054:     BLTDPTH,    BLTDPTL,
        // 058:     BLTSIZE,    not used
        // 060:     BLTCMOD,    BLTBMOD,
        // 064:     BLTAMOD,    BLTDMOD,
        // 070:     BLTCDAT,    BLTBDAT,
        // 074:     BLTADAT,    not used,
        if(CYC_I == 1'b1 && STB_I == 1'b1 && WE_I == 1'b1) begin
            if({ ADR_I, 2'b0 } == 9'h040 && SEL_I[0] == 1'b1)  blt_con1[7:0]   <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h040 && SEL_I[1] == 1'b1)  blt_con1[15:8]  <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h040 && SEL_I[2] == 1'b1)  blt_con0[7:0]   <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h040 && SEL_I[3] == 1'b1)  blt_con0[15:8]  <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h044 && SEL_I[0] == 1'b1)  a_last_word_mask[7:0]   <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h044 && SEL_I[1] == 1'b1)  a_last_word_mask[15:8]  <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h044 && SEL_I[2] == 1'b1)  a_first_word_mask[7:0]  <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h044 && SEL_I[3] == 1'b1)  a_first_word_mask[15:8] <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h048 && SEL_I[0] == 1'b1)  c_address[7:0]  <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h048 && SEL_I[1] == 1'b1)  c_address[15:8] <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h048 && SEL_I[2] == 1'b1)  c_address[23:16]<= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h048 && SEL_I[3] == 1'b1)  c_address[31:24]<= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h04C && SEL_I[0] == 1'b1)  b_address[7:0]  <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h04C && SEL_I[1] == 1'b1)  b_address[15:8] <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h04C && SEL_I[2] == 1'b1)  b_address[23:16]<= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h04C && SEL_I[3] == 1'b1)  b_address[31:24]<= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h050 && SEL_I[0] == 1'b1)  a_address[7:0]  <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h050 && SEL_I[1] == 1'b1)  a_address[15:8] <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h050 && SEL_I[2] == 1'b1)  a_address[23:16]<= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h050 && SEL_I[3] == 1'b1)  a_address[31:24]<= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h054 && SEL_I[0] == 1'b1)  d_address[7:0]  <= slave_DAT_I[7:0];
            if({ ADR_I, 2'b0 } == 9'h054 && SEL_I[1] == 1'b1)  d_address[15:8] <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h054 && SEL_I[2] == 1'b1)  d_address[23:16]<= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h054 && SEL_I[3] == 1'b1)  d_address[31:24]<= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h058 && SEL_I[0] == 1'b1)  ;
            if({ ADR_I, 2'b0 } == 9'h058 && SEL_I[1] == 1'b1)  ;
            if({ ADR_I, 2'b0 } == 9'h058 && SEL_I[2] == 1'b1)  blt_size[7:0]    <= slave_DAT_I[23:16];
            if({ ADR_I, 2'b0 } == 9'h058 && SEL_I[3] == 1'b1)  blt_size[15:8]   <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h060 && SEL_I[0] == 1'b1)  b_mod[7:0]       <= { slave_DAT_I[7:1], 1'b0 };
            if({ ADR_I, 2'b0 } == 9'h060 && SEL_I[1] == 1'b1)  b_mod[15:8]      <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h060 && SEL_I[2] == 1'b1)  c_mod[7:0]       <= { slave_DAT_I[23:17], 1'b0 };
            if({ ADR_I, 2'b0 } == 9'h060 && SEL_I[3] == 1'b1)  c_mod[15:8]      <= slave_DAT_I[31:24];
            if({ ADR_I, 2'b0 } == 9'h064 && SEL_I[0] == 1'b1)  d_mod[7:0]       <= { slave_DAT_I[7:1], 1'b0 };
            if({ ADR_I, 2'b0 } == 9'h064 && SEL_I[1] == 1'b1)  d_mod[15:8]      <= slave_DAT_I[15:8];
            if({ ADR_I, 2'b0 } == 9'h064 && SEL_I[2] == 1'b1)  a_mod[7:0]       <= { slave_DAT_I[23:17], 1'b0 };
            if({ ADR_I, 2'b0 } == 9'h064 && SEL_I[3] == 1'b1)  a_mod[15:8]      <= slave_DAT_I[31:24];
            
            if({ ADR_I, 2'b0 } == 9'h070 && SEL_I[0] == 1'b1) begin
                b_dat[39:32]   <= slave_DAT_I[7:0];
                b_dat[23:16]   <= slave_DAT_I[7:0];
            end
            if({ ADR_I, 2'b0 } == 9'h070 && SEL_I[1] == 1'b1) begin
                b_dat[47:40]  <= slave_DAT_I[15:8];
                b_dat[31:24]  <= slave_DAT_I[15:8];
            end
            if({ ADR_I, 2'b0 } == 9'h070 && SEL_I[2] == 1'b1) begin
                c_dat[39:32]  <= slave_DAT_I[23:16];
                c_dat[7:0]  <= slave_DAT_I[23:16];
            end
            if({ ADR_I, 2'b0 } == 9'h070 && SEL_I[3] == 1'b1) begin
                c_dat[47:40] <= slave_DAT_I[31:24];
                c_dat[15:8] <= slave_DAT_I[31:24];
            end
            if({ ADR_I, 2'b0 } == 9'h074 && SEL_I[0] == 1'b1)  ;
            if({ ADR_I, 2'b0 } == 9'h074 && SEL_I[1] == 1'b1)  ;
            
            if({ ADR_I, 2'b0 } == 9'h074 && SEL_I[2] == 1'b1) begin
                a_dat[39:32] <= slave_DAT_I[23:16];
                a_dat[23:16] <= slave_DAT_I[23:16];
            end
            if({ ADR_I, 2'b0 } == 9'h074 && SEL_I[3] == 1'b1) begin
                a_dat[47:40] <= slave_DAT_I[31:24];
                a_dat[31:24] <= slave_DAT_I[31:24];
            end  
            
            if({ ADR_I, 2'b0 } == 9'h074 && SEL_I[3:2] != 2'b00)   a_shift_saved <= blt_con0[15:12];
            if({ ADR_I, 2'b0 } == 9'h070 && SEL_I[1:0] != 2'b00)   b_shift_saved <= blt_con1[15:12];
            
            
            
            
            if(/*state == S_IDLE &&*/ { ADR_I, 2'b0 } == 9'h058 && SEL_I[3:2] == 2'b11 /*&&
                slave_DAT_I[21:16] != 6'd0 && slave_DAT_I[31:22] != 10'd0*/)
            begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                blt_width_in_words[5:0]  <= slave_DAT_I[21:16];
                if(slave_DAT_I[21:16] == 6'd0) max_width <= 1'b1;
                if(blt_con1[0] == 1'b0 && a_enabled == 1'b0) a_shift_saved <= blt_con0[15:12];
                if(blt_con1[0] == 1'b0 && b_enabled == 1'b0) b_shift_saved <= blt_con1[15:12];
                
                if(blt_con1[0] == 1'b1) begin
                    a_dat[63:48] <= 16'd0;
                    b_dat[63:48] <= b_dat[47:32];
                    a_shift_saved <= blt_con0[15:12];
                end
                else if(reverse == 1'b0) begin
                    a_dat[63:48] <= 16'd0;
                    b_dat[63:48] <= 16'd0;
                end
                else begin
                    a_dat[15:0] <= 16'd0;
                    b_dat[15:0] <= 16'd0;
                end
                blitter_zero <= 1'b1;
                blitter_busy <= 1'b1;
                a_avail <= 2'd0;
                b_avail <= 2'd0;
                c_avail <= 2'd0;
                master_DAT_O <= 32'd0;
                line_single <= 1'b0;
                fill_carry <= blt_con1[2];
                
                state <= S_CHECK_LOAD;
            end
        end
        else if(state == S_CHECK_LOAD) begin
        
            if(a_enabled == 1'b1 && a_avail < 2'd2)         state <= S_LOAD_A;
            else if(b_enabled == 1'b1 && b_avail < 2'd2)    state <= S_LOAD_B;
            else if(c_enabled &&
                ((blt_con1[0] == 1'b0 && c_avail < 2'd2) ||
                 (blt_con1[0] == 1'b1 && c_avail < 2'd1)))  state <= S_LOAD_C;
            else                                            state <= S_CHECK_SAVE;
        end
        // read max 48 bits
        else if(state == S_LOAD_A) begin
            
            if(ACK_I == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;              
/*
                    if(reverse == 1'b0) begin
                        a_address <= a_address + { {16{a_mod[15]}}, a_mod };
                        b_address <= b_address + { {16{b_mod[15]}}, b_mod };
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod };
                        d_address <= d_address + { {16{d_mod[15]}}, d_mod };
                    end
                    else begin
                        a_address <= a_address - { {16{a_mod[15]}}, a_mod };
                        b_address <= b_address - { {16{b_mod[15]}}, b_mod };
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod };
                        d_address <= d_address - { {16{d_mod[15]}}, d_mod };
                    end
*/              
                a_shift_saved <= blt_con0[15:12];
                
                a_avail <= a_avail + 2'd1;
                
                if(reverse == 1'b0) begin
                    if(a_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)    a_address <= a_address + { {16{a_mod[15]}}, a_mod };
                    else if(blt_size[5:0] == 6'd1)                                                  a_address <= a_address + 32'd2 + { {16{a_mod[15]}}, a_mod };
                    else if(a_avail == 2'd1 && blt_width_in_words == 6'd2)                          a_address <= a_address + 32'd2 + { {16{a_mod[15]}}, a_mod };
                    else                                                                            a_address <= a_address + 32'd2;                   
                    
                    if(a_avail == 2'd0) begin
                        a_dat[47:32] <=     a_first_word_mask &
                                            ((blt_width_in_words == 6'd1)? a_last_word_mask : 16'hFFFF ) &
                                            ((a_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(a_avail == 2'd1) begin
                        a_dat[31:16] <=     ((blt_width_in_words == 6'd1)? a_first_word_mask : 16'hFFFF ) &
                                            ((blt_width_in_words == 6'd2 || blt_size[5:0] == 6'd1)? a_last_word_mask : 16'hFFFF ) &
                                            ((a_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
                else begin
                    if(a_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)    a_address <= a_address - { {16{a_mod[15]}}, a_mod };
                    else if(blt_size[5:0] == 6'd1)                                                  a_address <= a_address - 32'd2 - { {16{a_mod[15]}}, a_mod };
                    else if(a_avail == 2'd1 && blt_width_in_words == 6'd2)                          a_address <= a_address - 32'd2 - { {16{a_mod[15]}}, a_mod };
                    else                                                                            a_address <= a_address - 32'd2;                   
                    
                    
                    if(a_avail == 2'd0) begin
                        a_dat[31:16] <=     a_first_word_mask &
                                            ((blt_width_in_words == 6'd1)? a_last_word_mask : 16'hFFFF ) &
                                            ((a_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(a_avail == 2'd1) begin
                        a_dat[47:32] <=     ((blt_width_in_words == 6'd1)? a_first_word_mask : 16'hFFFF ) &
                                            ((blt_width_in_words == 6'd2 || blt_size[5:0] == 6'd1)? a_last_word_mask : 16'hFFFF ) &
                                            ((a_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
               
                state <= S_CHECK_LOAD;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= { 11'b0, a_address[20:2] };
                SEL_O <= 4'b1111;
            end
        end
        // read max 48 bits
        else if(state == S_LOAD_B) begin
            
            if(ACK_I == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                b_shift_saved <= blt_con1[15:12];
                b_avail <= b_avail + 2'd1;
                
                if(reverse == 1'b0) begin
                    if(b_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)    b_address <= b_address + { {16{b_mod[15]}}, b_mod };
                    else if(blt_size[5:0] == 6'd1)                                                  b_address <= b_address + 32'd2 + { {16{b_mod[15]}}, b_mod };
                    else if(b_avail == 2'd1 && blt_width_in_words == 6'd2)                          b_address <= b_address + 32'd2 + { {16{b_mod[15]}}, b_mod };
                    else                                                                            b_address <= b_address + 32'd2;                   
                    
                    if(b_avail == 2'd0) begin
                        b_dat[47:32] <=     ((b_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(b_avail == 2'd1) begin
                        b_dat[31:16] <=     ((b_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
                else begin
                    if(b_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)    b_address <= b_address - { {16{b_mod[15]}}, b_mod };
                    else if(blt_size[5:0] == 6'd1)                                                  b_address <= b_address - 32'd2 - { {16{b_mod[15]}}, b_mod };
                    else if(b_avail == 2'd1 && blt_width_in_words == 6'd2)                          b_address <= b_address - 32'd2 - { {16{b_mod[15]}}, b_mod };
                    else                                                                            b_address <= b_address - 32'd2;                   
                    
                    if(b_avail == 2'd0) begin
                        b_dat[31:16] <=     ((b_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(b_avail == 2'd1) begin
                        b_dat[47:32] <=     ((b_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
               
                state <= S_CHECK_LOAD;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= { 11'b0, b_address[20:2] };
                SEL_O <= 4'b1111;
            end
        end
        // read max 48 bits
        else if(state == S_LOAD_C) begin
            
            if(ACK_I == 1'b1) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                c_avail <= c_avail + 2'd1;
                
                if(reverse == 1'b0) begin
                    if(blt_con1[0] == 1'b1)                                                             ;
                    else if(c_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   c_address <= c_address + { {16{c_mod[15]}}, c_mod };
                    else if(blt_size[5:0] == 6'd1)                                                      c_address <= c_address + 32'd2 + { {16{c_mod[15]}}, c_mod };
                    else if(c_avail == 2'd1 && blt_width_in_words == 6'd2)                              c_address <= c_address + 32'd2 + { {16{c_mod[15]}}, c_mod };
                    else                                                                                c_address <= c_address + 32'd2;                   
                       
                    if(c_avail == 2'd0) begin
                        c_dat[47:32] <=     ((c_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(c_avail == 2'd1) begin
                        c_dat[31:16] <=     ((c_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
                else begin
                    if(blt_con1[0] == 1'b1)                                                             ;
                    else if(c_avail == 2'd1 && blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   c_address <= c_address - { {16{c_mod[15]}}, c_mod };
                    else if(blt_size[5:0] == 6'd1)                                                      c_address <= c_address - 32'd2 - { {16{c_mod[15]}}, c_mod };
                    else if(c_avail == 2'd1 && blt_width_in_words == 6'd2)                              c_address <= c_address - 32'd2 - { {16{c_mod[15]}}, c_mod };
                    else                                                                                c_address <= c_address - 32'd2;                   
                    
                    if(c_avail == 2'd0) begin
                        c_dat[15:0] <=     ((c_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                    else if(c_avail == 2'd1) begin
                        c_dat[31:16] <=     ((c_address[1] == 1'b0)? master_DAT_I[31:16] : master_DAT_I[15:0]);
                    end
                end
                
                state <= S_CHECK_LOAD;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b0;
                ADR_O <= { 11'b0, c_address[20:2] };
                SEL_O <= 4'b1111;
            end
        end
        else if(state == S_CHECK_SAVE) begin
            
            // in LINE mode
            if(blt_con1[0] == 1'b1) begin
                if((blt_width_in_words > 6'd0 || max_width == 1'b1) && (blt_size[15:6] > 10'd1 || blt_size[15:6] == 10'd0)) begin    
                    
                    master_DAT_O <= (d_address[1] == 1'b1) ? { 16'b0, final_output } : { final_output, 16'b0 };
                    
                    if(a_address[15] == 1'b1)   a_address[31:0] <= a_address[31:0] + { {16{b_mod[15]}}, b_mod[15:0] };
                    else                        a_address[31:0] <= a_address[31:0] + { {16{a_mod[15]}}, a_mod[15:0] };
                
                    b_shift_saved <= b_shift_saved - 4'd1;
                    
                    // octet0
                    if(blt_con1[4:2] == 3'd6 && a_address[15] == 1'b1 && a_shift_saved != 4'd15) begin
                        // no address change
                        a_shift_saved <= a_shift_saved + 4'd1;
                        c_dat[47:32] <= final_output;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    end
                    else if(blt_con1[4:2] == 3'd6 && a_address[15] == 1'b1 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2;
                        a_shift_saved <= a_shift_saved + 4'd1;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd6 && a_address[15] == 1'b0 && a_shift_saved != 4'd15) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd6 && a_address[15] == 1'b0 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2 - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet1
                    else if(blt_con1[4:2] == 3'd1 && a_address[15] == 1'b1 && a_shift_saved != 4'd15) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd1 && a_address[15] == 1'b1 && a_shift_saved == 4'd15) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd1 && a_address[15] == 1'b0 && a_shift_saved != 4'd15) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd1 && a_address[15] == 1'b0 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2 - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet2
                    else if(blt_con1[4:2] == 3'd3 && a_address[15] == 1'b1 && a_shift_saved != 4'd0) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd3 && a_address[15] == 1'b1 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd3 && a_address[15] == 1'b0 && a_shift_saved != 4'd0) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd3 && a_address[15] == 1'b0 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2 - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet3
                    else if(blt_con1[4:2] == 3'd7 && a_address[15] == 1'b1 && a_shift_saved != 4'd0) begin
                        // no address change
                        a_shift_saved <= a_shift_saved - 4'd1;
                        c_dat[47:32] <= final_output;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    end
                    else if(blt_con1[4:2] == 3'd7 && a_address[15] == 1'b1 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2;
                        a_shift_saved <= a_shift_saved - 4'd1;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd7 && a_address[15] == 1'b0 && a_shift_saved != 4'd0) begin
                        c_address <= c_address - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd7 && a_address[15] == 1'b0 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2 - { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet4
                    else if(blt_con1[4:2] == 3'd5 && a_address[15] == 1'b1 && a_shift_saved != 4'd0) begin
                        // no address change
                        a_shift_saved <= a_shift_saved - 4'd1;
                        c_dat[47:32] <= final_output;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    end
                    else if(blt_con1[4:2] == 3'd5 && a_address[15] == 1'b1 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2;
                        a_shift_saved <= a_shift_saved - 4'd1;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd5 && a_address[15] == 1'b0 && a_shift_saved != 4'd0) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd5 && a_address[15] == 1'b0 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2 + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet5
                    else if(blt_con1[4:2] == 3'd2 && a_address[15] == 1'b1 && a_shift_saved != 4'd0) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd2 && a_address[15] == 1'b1 && a_shift_saved == 4'd0) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd2 && a_address[15] == 1'b0 && a_shift_saved != 4'd0) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd2 && a_address[15] == 1'b0 && a_shift_saved == 4'd0) begin
                        c_address <= c_address - 32'd2 + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved - 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet6
                    else if(blt_con1[4:2] == 3'd0 && a_address[15] == 1'b1 && a_shift_saved != 4'd15) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd0 && a_address[15] == 1'b1 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        // no shift
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd0 && a_address[15] == 1'b0 && a_shift_saved != 4'd15) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd0 && a_address[15] == 1'b0 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2 + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end

                    // octet7
                    else if(blt_con1[4:2] == 3'd4 && a_address[15] == 1'b1 && a_shift_saved != 4'd15) begin
                        // no address change
                        a_shift_saved <= a_shift_saved + 4'd1;
                        c_dat[47:32] <= final_output;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    end
                    else if(blt_con1[4:2] == 3'd4 && a_address[15] == 1'b1 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2;
                        a_shift_saved <= a_shift_saved + 4'd1;
                        if(blt_con1[1] == 1'b1) line_single <= 1'b1;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd4 && a_address[15] == 1'b0 && a_shift_saved != 4'd15) begin
                        c_address <= c_address + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                    else if(blt_con1[4:2] == 3'd4 && a_address[15] == 1'b0 && a_shift_saved == 4'd15) begin
                        c_address <= c_address + 32'd2 + { {16{c_mod[15]}}, c_mod[15:0] };
                        a_shift_saved <= a_shift_saved + 4'd1;
                        line_single <= 1'b0;
                        state <= S_SAVE_D;
                    end
                
                end    
                else if((blt_width_in_words > 6'd0 || max_width == 1'b1) && blt_size[15:6] == 10'd1) begin
                    master_DAT_O <= (d_address[1] == 1'b1) ? { 16'b0, final_output } : { final_output, 16'b0 };
                    state <= S_SAVE_D;
                end
                // after save
                else if(blt_width_in_words == 6'd0 && (blt_size[15:6] > 10'd1 || blt_size[15:6] == 10'd0)) begin    
                    blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    blt_width_in_words  <= blt_size[5:0];
                    if(blt_size[5:0] == 6'd0) max_width <= 1'b1;
                    c_avail <= 2'd0;
                    d_address <= c_address;
                    //if(blt_con1[1] == 1'b1 && c_address == d_address) line_single <= 1'b1;
                    
                    state <= S_CHECK_LOAD;
                end
                // finish
                else if(blt_width_in_words == 6'd0 && blt_size[15:6] == 10'd1) begin
                    blt_con0[15:12] <= 4'd0;
                    
                    blitter_busy <= 1'b0;
                    blitter_irq <= 1'b1;
                    state <= S_IDLE;
                end
            end
            else begin
                if( (blt_width_in_words > 6'd0 || max_width == 1'b1) &&
                    (a_enabled == 1'b0 || a_avail > 2'd1) && 
                    (b_enabled == 1'b0 || b_avail > 2'd1) && 
                    (c_enabled == 1'b0 || c_avail > 2'd1))
                begin
                    master_DAT_O <= (d_address[1] == 1'b1) ? { 16'b0, final_output } : { final_output, 16'b0 };  
                    fill_carry <= fill_carry ^ xor_chains[15] ^ minterm_output[15];
                    state <= S_SAVE_D;
                end
                else if(blt_width_in_words == 6'd0 && blt_size[15:6] == 10'd1) begin
                    blitter_busy <= 1'b0;
                    blitter_irq <= 1'b1;
                    state <= S_IDLE;
                end
                else if(blt_width_in_words == 6'd0 && (blt_size[15:6] > 10'd1 || blt_size[15:6] == 10'd0)) begin
                    blt_width_in_words  <= blt_size[5:0];
                    if(blt_size[5:0] == 6'd0) max_width <= 1'b1;
                    
                    fill_carry <= blt_con1[2];
                   
                    if(reverse == 1'b0) begin
                        d_address <= d_address + { {16{d_mod[15]}}, d_mod };
                    end
                    else begin
                        d_address <= d_address - { {16{d_mod[15]}}, d_mod };
                    end
                   
                    blt_size[15:6] <= blt_size[15:6] - 10'd1;
                    state <= S_CHECK_LOAD;
                end
                else begin
                    state <= S_CHECK_LOAD;
                end
            end
        end
        else if(state == S_SAVE_D) begin
            
            if(ACK_I == 1'b1 || d_enabled == 1'b0) begin
                CYC_O <= 1'b0;
                STB_O <= 1'b0;
                
                if(a_enabled == 1'b0) begin
                    if(reverse == 1'b0)     a_dat[63:48] <= a_dat_final[47:32];
                    else                    a_dat[15:0] <= a_dat_final[31:16];
                end
                else if(reverse == 1'b0) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   a_dat <= { a_dat[47:32], a_dat[47:32], a_dat[47:32], a_dat[47:32] };
                    else                                                        a_dat <= { a_dat_final[47:0], 16'b0 };
                    a_avail <= a_avail - 2'd1;
                end
                else if(reverse == 1'b1) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   a_dat <= { a_dat[31:16], a_dat[31:16], a_dat[31:16], a_dat[31:16] };
                    else                                                        a_dat <= { 16'b0, a_dat_final[63:16] };
                    a_avail <= a_avail - 2'd1;
                end
                
                if(b_enabled == 1'b0) begin
                    if(reverse == 1'b0)     b_dat[63:48] <= b_dat[47:32];
                    else                    b_dat[15:0] <= b_dat[31:16];
                end
                else if(reverse == 1'b0) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   b_dat <= { b_dat[47:32], b_dat[47:32], b_dat[47:32], b_dat[47:32] };
                    else                                                        b_dat <= { b_dat[47:0], 16'b0 };
                    b_avail <= b_avail - 2'd1;
                end
                else if(reverse == 1'b1) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   b_dat <= { b_dat[31:16], b_dat[31:16], b_dat[31:16], b_dat[31:16] };
                    else                                                        b_dat <= { 16'b0, b_dat[63:16] };
                    b_avail <= b_avail - 2'd1;
                end
                
                if(c_enabled == 1'b0) begin
                     //; no shift
                end
                else if(reverse == 1'b0) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   c_dat <= { c_dat[47:32], c_dat[47:32], c_dat[47:32] };
                    else                                                        c_dat <= { c_dat[31:0], 16'b0 };
                    c_avail <= c_avail - 2'd1;
                end
                else if(reverse == 1'b1) begin
                    if(blt_width_in_words == 6'd1 && blt_size[15:6] == 10'd1)   c_dat <= { c_dat[15:0], c_dat[15:0], c_dat[15:0] };
                    else                                                        c_dat <= { 16'b0, c_dat[47:16] };
                    c_avail <= c_avail - 2'd1;
                end
                
                if( (d_address[1] == 1'b1 && master_DAT_O[15:0] != 16'd0) ||
                    (d_address[1] == 1'b0 && master_DAT_O[31:16] != 16'd0) )
                begin
                    blitter_zero <= 1'b0; 
                end
                
                // update d_address and blt_width_in_words
                max_width <= 1'b0;
                if(blt_con1[0] == 1'b1) blt_width_in_words <= 6'd0;
                else                    blt_width_in_words <= blt_width_in_words - 6'd1;
                
                if(blt_con1[0] == 1'b1)     ;
                else if(reverse == 1'b0)    d_address <= d_address + 32'd2;
                else                        d_address <= d_address - 32'd2;
                
                state <= S_CHECK_SAVE;
            end
            else begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;
                WE_O <= 1'b1;
                ADR_O <= { 11'b0, d_address[20:2] };
                SEL_O <= (d_address[1] == 1'b1) ? 4'b0011 : 4'b1100;   
            end
        end
    end
end

endmodule
