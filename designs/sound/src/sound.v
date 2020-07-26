/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module sound(
    input               clk,
    input               rst_n,
    
    output              irq,
    
    //speaker input
    input               speaker_enable,
    input               speaker_out,
    
    //io slave 220h-22Fh
    input       [3:0]   io_address,
    input               io_read,
    output reg  [7:0]   io_readdata,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //fm music io slave 388h-389h
    input               fm_address,
    input               fm_read,
    output      [7:0]   fm_readdata,
    input               fm_write,
    input       [7:0]   fm_writedata,

    //dma
    output              dma_soundblaster_req,
    input               dma_soundblaster_ack,
    input               dma_soundblaster_terminal,
    input       [7:0]   dma_soundblaster_readdata,
    output      [7:0]   dma_soundblaster_writedata,
    
    //sound interface master
    output      [2:0]   avm_address,
    input               avm_waitrequest,
    output              avm_write,
    output      [31:0]  avm_writedata,
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------ dsp

wire [7:0] io_readdata_from_dsp;

wire       sample_from_dsp_disabled;
wire       sample_from_dsp_do;
wire [7:0] sample_from_dsp_value;

sound_dsp sound_dsp_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    .irq                        (irq),                          //output
    
    //io slave 220h-22Fh
    .io_address                 (io_address),                   //input [3:0]
    .io_read                    (io_read),                      //input
    .io_readdata_from_dsp       (io_readdata_from_dsp),         //output [7:0]
    .io_write                   (io_write),                     //input
    .io_writedata               (io_writedata),                 //input [7:0]
    
    //dma
    .dma_soundblaster_req       (dma_soundblaster_req),         //output
    .dma_soundblaster_ack       (dma_soundblaster_ack),         //input
    .dma_soundblaster_terminal  (dma_soundblaster_terminal),    //input
    .dma_soundblaster_readdata  (dma_soundblaster_readdata),    //input [7:0]
    .dma_soundblaster_writedata (dma_soundblaster_writedata),   //output [7:0]
    
    //sample
    .sample_from_dsp_disabled   (sample_from_dsp_disabled),     //output
    .sample_from_dsp_do         (sample_from_dsp_do),           //output
    .sample_from_dsp_value      (sample_from_dsp_value),        //output [7:0] unsigned
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    */
    .mgmt_address               (mgmt_address),                 //input [8:0]
    .mgmt_write                 (mgmt_write),                   //input
    .mgmt_writedata             (mgmt_writedata)                //input [31:0]
);

//------------------------------------------------------------------------------ opl2

wire [7:0] sb_readdata_from_opl2;

wire        sample_from_opl2;
wire [15:0] sample_from_opl2_value;

sound_opl2 sound_opl2_inst(
    .clk                        (clk),
    .rst_n                      (rst_n),
    
    //sb slave 220h-22Fh
    .sb_address                 (io_address),               //input [3:0]
    .sb_read                    (io_read),                  //input
    .sb_readdata_from_opl2      (sb_readdata_from_opl2),    //output [7:0]
    .sb_write                   (io_write),                 //input
    .sb_writedata               (io_writedata),             //input [7:0]
    
    
    //fm music io slave 388h-389h
    .fm_address                 (fm_address),               //input
    .fm_read                    (fm_read),                  //input
    .fm_readdata                (fm_readdata),              //output [7:0]
    .fm_write                   (fm_write),                 //input
    .fm_writedata               (fm_writedata),             //input [7:0]
    
    //sample
    .sample_from_opl2           (sample_from_opl2),         //output
    .sample_from_opl2_value     (sample_from_opl2_value),   //output [15:0]
    
    //mgmt slave
    /*
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    .mgmt_address               (mgmt_address),   //input [8:0]
    .mgmt_write                 (mgmt_write),     //input
    .mgmt_writedata             (mgmt_writedata)  //input [31:0]
);

//------------------------------------------------------------------------------ io_readdata

wire [7:0] io_readdata_next =
    (io_address == 4'h8 || io_address == 4'h9)?     sb_readdata_from_opl2 :
                                                    io_readdata_from_dsp;
    
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'd0;
    else                io_readdata <= io_readdata_next;
end

//------------------------------------------------------------------------------ speaker

reg [15:0] speaker_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               speaker_value <= 16'd0;
    else if(speaker_enable && speaker_out == 1'b0)  speaker_value <= 16'd16384;
    else if(speaker_enable && speaker_out == 1'b1)  speaker_value <= 16'd49152;
    else                                            speaker_value <= 16'd0;
end

//------------------------------------------------------------------------------

reg [15:0] sample_dsp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   sample_dsp <= 16'd0;
    else if(sample_from_dsp_disabled)   sample_dsp <= 16'd0;
    else if(sample_from_dsp_do)         sample_dsp <= { sample_from_dsp_value, 8'd0 } - 16'd32768; //unsigned to signed
end

reg [15:0] sample_opl2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           sample_opl2 <= 16'd0;
    else if(sample_from_opl2)   sample_opl2 <= sample_from_opl2_value; //already signed
end

wire [15:0] sample_sum_1 = sample_dsp + sample_opl2;

wire [15:0] sample_next_1 = (sample_dsp[15] == 1'b0 && sample_opl2[15] == 1'b0 && sample_sum_1[15] == 1'b1)?   16'd32767 :
                            (sample_dsp[15] == 1'b1 && sample_opl2[15] == 1'b1 && sample_sum_1[15] == 1'b0)?   16'd32768 :
                                                                                                               sample_sum_1[15:0];
reg [15:0] sample_sum_1_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_sum_1_reg <= 16'd0;
    else if(state == STATE_LOAD_1)  sample_sum_1_reg <= sample_next_1;
end

wire [15:0] sample_sum_2 = sample_sum_1_reg + speaker_value;

wire [15:0] sample_next_2 = (sample_sum_1_reg[15] == 1'b0 && speaker_value[15] == 1'b0 && sample_sum_2[15] == 1'b1)?    16'd32767 :
                            (sample_sum_1_reg[15] == 1'b1 && speaker_value[15] == 1'b1 && sample_sum_2[15] == 1'b0)?    16'd32768 :
                                                                                                                        sample_sum_2[15:0];

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE   = 2'd0;
localparam [1:0] STATE_LOAD_1 = 2'd1;
localparam [1:0] STATE_LOAD_2 = 2'd2;
localparam [1:0] STATE_WRITE  = 2'd3;

reg [1:0] state;

reg [15:0] sample_sum_2_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_sum_2_reg <= 16'd0;
    else if(state == STATE_LOAD_2)  sample_sum_2_reg <= sample_next_2;
end

assign avm_address   = 3'd0;
assign avm_writedata = { 16'd0, sample_sum_2_reg }; //signed
assign avm_write     = state == STATE_WRITE;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   state <= STATE_IDLE;
    else if(state == STATE_IDLE && sample_from_opl2)    state <= STATE_LOAD_1;
    else if(state == STATE_LOAD_1)                      state <= STATE_LOAD_2;
    else if(state == STATE_LOAD_2)                      state <= STATE_WRITE;
    else if(state == STATE_WRITE && ~(avm_waitrequest)) state <= STATE_IDLE;
end

//------------------------------------------------------------------------------

endmodule


module sound_dsp(
    input               clk,
    input               rst_n,
    
    output reg          irq,
    
    //io slave 220h-22Fh
    input       [3:0]   io_address,
    input               io_read,
    output      [7:0]   io_readdata_from_dsp,
    input               io_write,
    input       [7:0]   io_writedata,
    
    //dma
    output              dma_soundblaster_req,
    input               dma_soundblaster_ack,
    input               dma_soundblaster_terminal,
    input       [7:0]   dma_soundblaster_readdata,
    output      [7:0]   dma_soundblaster_writedata,
    
    //sample
    output              sample_from_dsp_disabled,
    output              sample_from_dsp_do,
    output      [7:0]   sample_from_dsp_value,
    
    //mgmt slave
    /*
    0-255.[15:0]: cycles in period
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg io_read_last;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0) io_read_last <= 1'b0; else if(io_read_last) io_read_last <= 1'b0; else io_read_last <= io_read; end 
wire io_read_valid = io_read && io_read_last == 1'b0;

//------------------------------------------------------------------------------

assign io_readdata_from_dsp =
    (io_address == 4'hE)?                       { read_ready, 7'h7F } :
    (io_address == 4'hA && copy_cnt > 6'd0)?    copyright_byte :
    (io_address == 4'hA)?                       read_buffer[15:8] :
    (io_address == 4'hC)?                       { write_ready, 7'h7F } :
                                                8'hFF;

//------------------------------------------------------------------------------

wire highspeed_start = cmd_high_auto_dma_out || cmd_high_single_dma_out || cmd_high_auto_dma_input || cmd_high_single_dma_input;

reg highspeed_mode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           highspeed_mode <= 1'b0;
    else if(highspeed_reset)    highspeed_mode <= 1'b0;
    else if(highspeed_start)    highspeed_mode <= 1'b1;
    else if(dma_finished)       highspeed_mode <= 1'b0;
end

reg midi_uart_mode;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           midi_uart_mode <= 1'b0;
    else if(midi_uart_reset)    midi_uart_mode <= 1'b0;
    else if(cmd_midi_uart)      midi_uart_mode <= 1'b1;
end

reg reset_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               reset_reg <= 1'b0;
    else if(io_write && io_address == 4'h6 && ~(highspeed_mode))    reset_reg <= io_writedata[0];
end

wire highspeed_reset = io_write && io_address == 4'h6 && highspeed_mode;
wire midi_uart_reset = reset_reg && io_write && io_address == 4'h6 && ~(highspeed_mode) && midi_uart_mode    && io_writedata[0] == 1'b0;
wire sw_reset        = reset_reg && io_write && io_address == 4'h6 && ~(highspeed_mode) && ~(midi_uart_mode) && io_writedata[0] == 1'b0;

//------------------------------------------------------------------------------ dummy input

wire input_strobe = cmd_direct_input || dma_input;

reg input_direction;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       input_direction <= 1'b0;
    else if(sw_reset)                                                       input_direction <= 1'b0;
    else if(input_strobe && ~(input_direction) && input_sample == 8'd254)   input_direction <= 1'b1;
    else if(input_strobe && input_direction    && input_sample == 8'd1)     input_direction <= 1'b0;
end

reg [7:0] input_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           input_sample <= 8'd128;
    else if(sw_reset)                           input_sample <= 8'd128;
    else if(input_strobe && ~(input_direction)) input_sample <= input_sample + 8'd1;
    else if(input_strobe && input_direction)    input_sample <= input_sample - 8'd1;
end

assign dma_soundblaster_writedata = (dma_id_active)? dma_id_value : input_sample;

//------------------------------------------------------------------------------

wire cmd_single_byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode);

wire cmd_wait_for_2byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode) && (
    io_writedata == 8'h10 || //direct output
    io_writedata == 8'h38 || //midi   output
    io_writedata == 8'h40 || //set time constant
    io_writedata == 8'hE0 || //dsp identification
    io_writedata == 8'hE4 || //write test register
    io_writedata == 8'hE2    //dma id
);
wire cmd_wait_for_3byte = write_left == 2'd0 && io_write && io_address == 4'hC && ~(midi_uart_mode) && ~(highspeed_mode) && (
    io_writedata == 8'h14 ||   //single cycle dma output
    io_writedata == 8'h16 ||   //single cycle dma 2 bit adpcm output
    io_writedata == 8'h17 ||   //single cycle dma 2 bit adpcm output with reference
    io_writedata == 8'h74 ||   //single cycle dma 4 bit adpcm output
    io_writedata == 8'h75 ||   //single cycle dma 4 bit adpcm output with reference
    io_writedata == 8'h76 ||   //single cycle dma 4 bit adpcm output
    io_writedata == 8'h77 ||   //single cycle dma 4 bit adpcm output with reference
    io_writedata == 8'h24 ||   //single cycle dma input
    io_writedata == 8'h48 ||   //set block size
    io_writedata == 8'h80      //pause dac
);

wire cmd_multiple_byte = write_length > 2'd0 && write_left == 2'd0 && ~(midi_uart_mode) && ~(highspeed_mode);

wire cmd_dsp_version            = cmd_single_byte && io_writedata == 8'hE1;
wire cmd_direct_output          = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h10;
wire cmd_single_dma_output      = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h14;
wire cmd_single_2_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h16;
wire cmd_single_2_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h17;
wire cmd_single_4_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h74;
wire cmd_single_4_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h75;
wire cmd_single_3_adpcm_out     = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h76;
wire cmd_single_3_adpcm_out_ref = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h77;

wire cmd_single_dma_input       = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h24;

wire cmd_auto_dma_out           = cmd_single_byte && io_writedata == 8'h1C;
wire cmd_auto_dma_exit          = cmd_single_byte && io_writedata == 8'hDA;

wire cmd_auto_2_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h1F;
wire cmd_auto_3_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h7F;
wire cmd_auto_4_adpcm_out_ref   = cmd_single_byte && io_writedata == 8'h7D;

wire cmd_direct_input           = cmd_single_byte && io_writedata == 8'h20;
wire cmd_auto_dma_input         = cmd_single_byte && io_writedata == 8'h2C;

//wire cmd_midi_polling_input     = cmd_single_byte && io_writedata == 8'h30;
//wire cmd_midi_interrupt_input   = cmd_single_byte && io_writedata == 8'h31;

wire cmd_midi_uart              = cmd_single_byte && { io_writedata[7:2], 2'b00 } == 8'h34;
//wire cmd_midi_output            = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h38;

wire cmd_set_time_constant      = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'h40;
wire cmd_set_block_size         = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h48;

wire cmd_pause_dac              = cmd_multiple_byte && write_length == 2'd3 && write_buffer[23:16] == 8'h80;

wire cmd_high_auto_dma_out      = cmd_single_byte && io_writedata == 8'h90;
wire cmd_high_single_dma_out    = cmd_single_byte && io_writedata == 8'h91;

wire cmd_high_auto_dma_input    = cmd_single_byte && io_writedata == 8'h98;
wire cmd_high_single_dma_input  = cmd_single_byte && io_writedata == 8'h99;

wire cmd_dma_pause_start        = cmd_single_byte && io_writedata == 8'hD0;
wire cmd_dma_pause_end          = cmd_single_byte && io_writedata == 8'hD4;

wire cmd_speaker_on             = cmd_single_byte && io_writedata == 8'hD1;
wire cmd_speaker_off            = cmd_single_byte && io_writedata == 8'hD3;
wire cmd_speaker_status         = cmd_single_byte && io_writedata == 8'hD8;

wire cmd_dsp_identification     = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE0;
wire cmd_f8_zero                = cmd_single_byte && io_writedata == 8'hF8;
wire cmd_trigger_irq            = cmd_single_byte && io_writedata == 8'hF2;

wire cmd_test_register_write    = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE4;
wire cmd_test_register_read     = cmd_single_byte && io_writedata == 8'hE8;

wire cmd_copyright              = cmd_single_byte && io_writedata == 8'hE3;
wire cmd_dma_id                 = cmd_multiple_byte && write_length == 2'd2 && write_buffer[15:8] == 8'hE2;

//------------------------------------------------------------------------------ 'weird dma identification' from DosBox

reg [1:0] dma_id_count;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   dma_id_count <= 2'd0;
    else if(sw_reset)   dma_id_count <= 2'd0;
    else if(cmd_dma_id) dma_id_count <= dma_id_count + 2'd1;
end

reg [7:0] dma_id_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   dma_id_value <= 8'hAA;
    else if(sw_reset)   dma_id_value <= 8'hAA;
    else if(cmd_dma_id) dma_id_value <= dma_id_value + dma_id_q;
end

reg dma_id_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               dma_id_active <= 1'b0;
    else if(sw_reset)               dma_id_active <= 1'b0;
    else if(cmd_dma_id)             dma_id_active <= 1'b1;
    else if(dma_soundblaster_ack)   dma_id_active <= 1'b0;
end

wire [7:0] dma_id_q;

simple_single_rom #(
    .widthad    (10),
    .width      (8),
    .datafile   ("./designs/sound/src/dsp_dma_identification_rom.hex")
)
dma_id_rom_inst (
    .clk        (clk),
    
    .addr       ({dma_id_count, io_writedata}),
    .q          (dma_id_q)
);

//------------------------------------------------------------------------------ copyright

reg [5:0] copy_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               copy_cnt <= 6'd0;
    else if(cmd_copyright)                                          copy_cnt <= 6'd45;
    else if(io_read_valid && io_address == 4'hA && copy_cnt > 6'd0) copy_cnt <= copy_cnt - 6'd1;
end

wire [7:0] copyright_byte =
    (copy_cnt == 6'd45 || copy_cnt == 6'd34 || copy_cnt == 6'd31 || copy_cnt == 6'd20)?                     8'h43 : //C
    (copy_cnt == 6'd44 || copy_cnt == 6'd17 || copy_cnt == 6'd15)?                                          8'h4F : //O
    (copy_cnt == 6'd43)?                                                                                    8'h50 : //P
    (copy_cnt == 6'd42 || copy_cnt == 6'd13)?                                                               8'h59 : //Y
    (copy_cnt == 6'd41 || copy_cnt == 6'd30)?                                                               8'h52 : //R
    (copy_cnt == 6'd40 || copy_cnt == 6'd26)?                                                               8'h49 : //I
    (copy_cnt == 6'd39 || copy_cnt == 6'd14)?                                                               8'h47 : //G
    (copy_cnt == 6'd38 || copy_cnt == 6'd19)?                                                               8'h48 : //H
    (copy_cnt == 6'd37 || copy_cnt == 6'd27 || copy_cnt == 6'd22 || copy_cnt == 6'd10)?                     8'h54 : //T
    (copy_cnt == 6'd36 || copy_cnt == 6'd32 || copy_cnt == 6'd23 || copy_cnt == 6'd12 || copy_cnt == 6'd7)? 8'h20 : //' '
    (copy_cnt == 6'd35)?                                                                                    8'h28 : //(
    (copy_cnt == 6'd33)?                                                                                    8'h29 : //)
    (copy_cnt == 6'd29 || copy_cnt == 6'd24 || copy_cnt == 6'd21)?                                          8'h45 : //E
    (copy_cnt == 6'd28)?                                                                                    8'h41 : //A
    (copy_cnt == 6'd25)?                                                                                    8'h56 : //V
    (copy_cnt == 6'd18)?                                                                                    8'h4E : //N
    (copy_cnt == 6'd16 || copy_cnt == 6'd11)?                                                               8'h4C : //L
    (copy_cnt == 6'd13)?                                                                                    8'h59 : //Y
    (copy_cnt == 6'd9)?                                                                                     8'h44 : //D
    (copy_cnt == 6'd8)?                                                                                     8'h2C : //,
    (copy_cnt == 6'd6)?                                                                                     8'h31 : //1
    (copy_cnt == 6'd5 || copy_cnt == 6'd4)?                                                                 8'h39 : //9
    (copy_cnt == 6'd3)?                                                                                     8'h32 : //2
    (copy_cnt == 6'd2)?                                                                                     8'h2E : //.
                                                                                                            8'h00;  //for copy_cnt == 6'd1
//------------------------------------------------------------------------------

reg [7:0] test_register;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   test_register <= 8'd0;
    else if(cmd_test_register_write)    test_register <= write_buffer[7:0];
end

reg speaker_on;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           speaker_on <= 1'b0;
    else if(sw_reset)           speaker_on <= 1'b0;
    else if(cmd_speaker_on)     speaker_on <= 1'b1;
    else if(cmd_speaker_off)    speaker_on <= 1'b0;
end

reg [15:0] block_size;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           block_size <= 16'd0;
    else if(sw_reset)           block_size <= 16'd0;
    else if(cmd_set_block_size) block_size <= { write_buffer[7:0], write_buffer[15:8] };
end

reg pause_dma;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   pause_dma <= 1'b0;
    else if(sw_reset)                                                   pause_dma <= 1'b0;
    else if(cmd_dma_pause_start)                                        pause_dma <= 1'b1;
    else if(cmd_dma_pause_end || dma_single_start || dma_auto_start)    pause_dma <= 1'b0;
end

//------------------------------------------------------------------------------ pause dac

wire pause_interrupt = pause_counter == 16'd0 && pause_period == 16'd1;

reg pause_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           pause_active <= 1'b0;
    else if(sw_reset)                                           pause_active <= 1'b0;
    else if(cmd_pause_dac)                                      pause_active <= 1'b1;
    else if(pause_counter == 16'd0 && pause_period == 16'd0)    pause_active <= 1'b0;
end

reg [15:0] pause_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       pause_counter <= 16'd0;
    else if(sw_reset)                                       pause_counter <= 16'd0;
    else if(cmd_pause_dac)                                  pause_counter <= { write_buffer[7:0], write_buffer[15:8] };
    else if(pause_period == 16'd0 && pause_counter > 16'd0) pause_counter <= pause_counter - 16'd1;
end

reg [15:0] pause_period;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                       pause_period <= 16'd0;
    else if(sw_reset)                                       pause_period <= 16'd0;
    else if(cmd_pause_dac)                                  pause_period <= period_q;
    else if(pause_period == 16'd0 && pause_counter > 16'd0) pause_period <= period_q;
    else if(pause_period > 16'd0)                           pause_period <= pause_period - 16'd1;
end

//------------------------------------------------------------------------------

wire write_ready = midi_uart_mode || highspeed_mode;

reg [1:0] write_length;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           write_length <= 2'd0;
    else if(sw_reset)                           write_length <= 2'd0;
    else if(cmd_midi_uart || highspeed_start)   write_length <= 2'd0;
    else if(cmd_wait_for_2byte)                 write_length <= 2'd2;
    else if(cmd_wait_for_3byte)                 write_length <= 2'd3;
    else if(write_left == 2'd0)                 write_length <= 2'd0;
end

reg [1:0] write_left;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               write_left <= 2'd0;
    else if(sw_reset)                                               write_left <= 2'd0;
    else if(cmd_midi_uart || highspeed_start)                       write_left <= 2'd0;
    else if(cmd_wait_for_2byte)                                     write_left <= 2'd1;
    else if(cmd_wait_for_3byte)                                     write_left <= 2'd2;
    else if(io_write && io_address == 4'hC && write_left > 2'd0)    write_left <= write_left - 2'd1;
end

reg [23:0] write_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               write_buffer <= 24'd0;
    else if(sw_reset)                                               write_buffer <= 24'd0;
    else if(cmd_wait_for_2byte || cmd_wait_for_3byte)               write_buffer <= { write_buffer[15:0], io_writedata };
    else if(io_write && io_address == 4'hC && write_left > 2'd0)    write_buffer <= { write_buffer[15:0], io_writedata };
end

//------------------------------------------------------------------------------

wire read_ready = ~(midi_uart_mode) && read_buffer_size > 2'd0;

reg [1:0] read_buffer_size;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   read_buffer_size <= 2'd0;
    else if(sw_reset)                                                   read_buffer_size <= 2'd1;
    else if(cmd_dsp_version)                                            read_buffer_size <= 2'd2;
    else if(cmd_direct_input)                                           read_buffer_size <= 2'd1;
    else if(cmd_midi_uart)                                              read_buffer_size <= 2'd0;
    else if(cmd_speaker_status)                                         read_buffer_size <= 2'd1;
    else if(cmd_dsp_identification)                                     read_buffer_size <= 2'd1;
    else if(cmd_f8_zero)                                                read_buffer_size <= 2'd1;
    else if(cmd_test_register_read)                                     read_buffer_size <= 2'd1;
    else if(cmd_copyright)                                              read_buffer_size <= 2'd0;
    
    else if(io_read_valid && io_address == 4'hA && read_buffer_size > 2'd0) read_buffer_size <= read_buffer_size - 2'd1;
end

reg [15:0] read_buffer;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   read_buffer <= 16'd0;
    else if(sw_reset)                                                   read_buffer <= { 8'hAA, 8'h00 };
    else if(cmd_dsp_version)                                            read_buffer <= { 8'h02, 8'h01 };
    else if(cmd_direct_input)                                           read_buffer <= { input_sample, 8'h00 };
    else if(cmd_speaker_status)                                         read_buffer <= { (speaker_on)? 8'hFF : 8'h00, 8'h00 };
    else if(cmd_dsp_identification)                                     read_buffer <= { ~(write_buffer[7:0]), 8'h00 };
    else if(cmd_f8_zero)                                                read_buffer <= { 8'h00, 8'h00 };
    else if(cmd_test_register_read)                                     read_buffer <= { test_register, 8'h00 };
    
    else if(io_read_valid && io_address == 4'hA && read_buffer_size > 2'd0) read_buffer <= { read_buffer[7:0], 8'd0 };
end

//------------------------------------------------------------------------------ irq

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               irq <= 1'b0;
    else if(sw_reset)                                               irq <= 1'b0;
    
    else if(dma_finished || dma_auto_restart || pause_interrupt)    irq <= 1'b1;
    else if(cmd_trigger_irq)                                        irq <= 1'b1;
    
    else if(io_read_valid && io_address == 4'hE)                    irq <= 1'b0;
end

//------------------------------------------------------------------------------ dma commands

localparam [4:0] S_IDLE                 = 5'd0;
localparam [4:0] S_OUT_SINGLE_8_BIT     = 5'd1;
localparam [4:0] S_OUT_SINGLE_4_BIT     = 5'd2;
localparam [4:0] S_OUT_SINGLE_3_BIT     = 5'd3;
localparam [4:0] S_OUT_SINGLE_2_BIT     = 5'd4;
localparam [4:0] S_OUT_SINGLE_4_BIT_REF = 5'd5;
localparam [4:0] S_OUT_SINGLE_3_BIT_REF = 5'd6;
localparam [4:0] S_OUT_SINGLE_2_BIT_REF = 5'd7;
localparam [4:0] S_OUT_AUTO_8_BIT       = 5'd8;
localparam [4:0] S_OUT_AUTO_4_BIT_REF   = 5'd9;
localparam [4:0] S_OUT_AUTO_3_BIT_REF   = 5'd10;
localparam [4:0] S_OUT_AUTO_2_BIT_REF   = 5'd11;
localparam [4:0] S_IN_SINGLE            = 5'd12;
localparam [4:0] S_IN_AUTO              = 5'd13;
localparam [4:0] S_OUT_SINGLE_HIGH      = 5'd14;
localparam [4:0] S_OUT_AUTO_HIGH        = 5'd15;
localparam [4:0] S_IN_SINGLE_HIGH       = 5'd16;
localparam [4:0] S_IN_AUTO_HIGH         = 5'd17;

reg [4:0] dma_command;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_command <= S_IDLE;
    else if(sw_reset)                           dma_command <= S_IDLE;
    
    else if(cmd_single_dma_output)              dma_command <= S_OUT_SINGLE_8_BIT;
    else if(cmd_single_4_adpcm_out)             dma_command <= S_OUT_SINGLE_4_BIT;
    else if(cmd_single_3_adpcm_out)             dma_command <= S_OUT_SINGLE_3_BIT;
    else if(cmd_single_2_adpcm_out)             dma_command <= S_OUT_SINGLE_2_BIT;
    
    else if(cmd_single_4_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_4_BIT_REF;
    else if(cmd_single_3_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_3_BIT_REF;
    else if(cmd_single_2_adpcm_out_ref)         dma_command <= S_OUT_SINGLE_2_BIT_REF;
    
    else if(cmd_auto_dma_out)                   dma_command <= S_OUT_AUTO_8_BIT;
    else if(cmd_auto_4_adpcm_out_ref)           dma_command <= S_OUT_AUTO_4_BIT_REF;
    else if(cmd_auto_3_adpcm_out_ref)           dma_command <= S_OUT_AUTO_3_BIT_REF;
    else if(cmd_auto_2_adpcm_out_ref)           dma_command <= S_OUT_AUTO_2_BIT_REF;
    
    else if(cmd_single_dma_input)               dma_command <= S_IN_SINGLE;
    else if(cmd_auto_dma_input)                 dma_command <= S_IN_AUTO;
    
    else if(cmd_high_single_dma_out)            dma_command <= S_OUT_SINGLE_HIGH;
    else if(cmd_high_auto_dma_out)              dma_command <= S_OUT_AUTO_HIGH;
    
    else if(cmd_high_single_dma_input)          dma_command <= S_IN_SINGLE_HIGH;
    else if(cmd_high_auto_dma_input)            dma_command <= S_IN_AUTO_HIGH;
    
    else if(dma_single_start || dma_auto_start) dma_command <= S_IDLE;
end

//------------------------------------------------------------------------------ dma

wire dma_single_start = dma_restart_possible && (
    dma_command == S_OUT_SINGLE_8_BIT || dma_command == S_OUT_SINGLE_4_BIT     || dma_command == S_OUT_SINGLE_3_BIT     || dma_command == S_OUT_SINGLE_2_BIT     ||
                                         dma_command == S_OUT_SINGLE_4_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_2_BIT_REF ||
    dma_command == S_IN_SINGLE ||
    dma_command == S_OUT_SINGLE_HIGH || dma_command == S_IN_SINGLE_HIGH
);

wire dma_auto_start = dma_restart_possible && (
    dma_command == S_OUT_AUTO_8_BIT || dma_command == S_OUT_AUTO_4_BIT_REF || dma_command == S_OUT_AUTO_3_BIT_REF || dma_command == S_OUT_AUTO_2_BIT_REF ||
    dma_command == S_IN_AUTO ||
    dma_command == S_OUT_AUTO_HIGH || dma_command == S_IN_AUTO_HIGH
);

wire dma_normal_req = dma_in_progress && dma_wait == 16'd0 && adpcm_wait == 2'd0 && ~(pause_dma);

assign dma_soundblaster_req = dma_id_active || dma_normal_req;

wire dma_valid  = dma_normal_req && dma_soundblaster_ack && ~(dma_id_active);
wire dma_output = ~(dma_is_input) && dma_valid;
wire dma_input  = dma_is_input    && dma_valid;

wire dma_finished = dma_in_progress && ~(dma_autoinit) && (
    (dma_valid && dma_left == 17'd1 && adpcm_type == ADPCM_NONE) ||
    (adpcm_output && dma_left == 17'd0 && adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)
);
    
wire dma_auto_restart = dma_in_progress && dma_autoinit && (
    (dma_valid && dma_left == 17'd1 && adpcm_type == ADPCM_NONE) ||
    (adpcm_output && dma_left == 17'd0 && adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)
);

wire dma_restart_possible = dma_wait == 16'd0 && (adpcm_wait == 2'd0 || (adpcm_type != ADPCM_NONE && adpcm_wait == 2'd1)) && (~(dma_in_progress) || dma_auto_restart || pause_dma);

reg [16:0] dma_left;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_left <= 17'd0;
    else if(sw_reset)                           dma_left <= 17'd0;
    else if(dma_single_start)                   dma_left <= { write_buffer[7:0], write_buffer[15:8] } + 16'd1;
    else if(dma_auto_start || dma_auto_restart) dma_left <= block_size + 16'd1;
    else if(dma_valid && dma_left > 17'd0)      dma_left <= dma_left - 17'd1;
    else if(dma_finished)                       dma_left <= 17'd0;
end

reg dma_in_progress;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                           dma_in_progress <= 1'b0;
    else if(sw_reset)                           dma_in_progress <= 1'b0;
    else if(dma_single_start || dma_auto_start) dma_in_progress <= 1'b1;
    else if(dma_finished)                       dma_in_progress <= 1'b0;
end

reg dma_is_input;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                                                               dma_is_input <= 1'b0;
    else if(sw_reset)                                                                                                                                                               dma_is_input <= 1'b0;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_IN_SINGLE || dma_command == S_IN_AUTO || dma_command == S_IN_SINGLE_HIGH || dma_command == S_IN_AUTO_HIGH))   dma_is_input <= 1'b1;
    else if(dma_single_start || dma_auto_start)                                                                                                                                     dma_is_input <= 1'b0;
end

reg dma_autoinit;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           dma_autoinit <= 1'b0;
    else if(sw_reset)           dma_autoinit <= 1'b0;
    else if(dma_single_start)   dma_autoinit <= 1'b0;
    else if(dma_auto_start)     dma_autoinit <= 1'b1;
    else if(cmd_auto_dma_exit)  dma_autoinit <= 1'b0;
end

reg [15:0] dma_wait;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                   dma_wait <= 16'd0;
    else if(sw_reset)                                                                                                   dma_wait <= 16'd0;
    else if(dma_finished || dma_valid || adpcm_output || (~(dma_in_progress) && (dma_single_start || dma_auto_start)))  dma_wait <= period_q;
    else if(dma_wait > 16'd0)                                                                                           dma_wait <= dma_wait - 16'd1;
end

//------------------------------------------------------------------------------ adpcm

localparam [1:0] ADPCM_NONE = 2'd0;
localparam [1:0] ADPCM_4BIT = 2'd1;
localparam [1:0] ADPCM_3BIT = 2'd2;
localparam [1:0] ADPCM_2BIT = 2'd3;

wire adpcm_reference_start = 
    (dma_single_start || dma_auto_start) && (
    dma_command == S_OUT_SINGLE_2_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_4_BIT_REF ||
    dma_command == S_OUT_AUTO_2_BIT_REF   || dma_command == S_OUT_AUTO_3_BIT_REF   || dma_command == S_OUT_AUTO_4_BIT_REF
);

wire adpcm_output = dma_wait == 16'd0 && adpcm_wait > 2'd0;

reg adpcm_reference_awaiting;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               adpcm_reference_awaiting <= 1'b0;
    else if(sw_reset)                               adpcm_reference_awaiting <= 1'b0;
    else if(adpcm_reference_start)                  adpcm_reference_awaiting <= 1'b1;
    else if(dma_single_start || dma_auto_start)     adpcm_reference_awaiting <= 1'b0;
    else if(adpcm_reference_awaiting && dma_output) adpcm_reference_awaiting <= 1'b0;
    else if(dma_finished)                           adpcm_reference_awaiting <= 1'b0;
end

reg adpcm_reference_output;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   adpcm_reference_output <= 1'b0;
    else                adpcm_reference_output <= adpcm_reference_awaiting;
end

reg [1:0] adpcm_wait;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               adpcm_wait <= 2'd0;
    else if(sw_reset)                               adpcm_wait <= 2'd0;
    else if(dma_single_start || dma_auto_start)     adpcm_wait <= 2'd0;
    else if(adpcm_reference_awaiting && dma_output) adpcm_wait <= 2'd0;
    else if(dma_output && adpcm_type == ADPCM_2BIT) adpcm_wait <= 2'd3;
    else if(dma_output && adpcm_type == ADPCM_3BIT) adpcm_wait <= 2'd2;
    else if(dma_output && adpcm_type == ADPCM_4BIT) adpcm_wait <= 2'd1;
    else if(adpcm_output && adpcm_wait > 2'd0)      adpcm_wait <= adpcm_wait - 2'd1;
end

reg [7:0] adpcm_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_sample <= 8'd0;
    else if(sw_reset)                                   adpcm_sample <= 8'd0;
    else if(dma_output)                                 adpcm_sample <= dma_soundblaster_readdata;
    else if(adpcm_output && adpcm_type == ADPCM_2BIT)   adpcm_sample <= { adpcm_sample[5:0], 2'b0 };
    else if(adpcm_output && adpcm_type == ADPCM_3BIT)   adpcm_sample <= { adpcm_sample[4:0], 3'b0 };
    else if(adpcm_output && adpcm_type == ADPCM_4BIT)   adpcm_sample <= { adpcm_sample[3:0], 4'b0 };
end

reg adpcm_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_active <= 1'b0;
    else if(sw_reset)                                   adpcm_active <= 1'b0;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_active <= 1'b0;
    else if(adpcm_type != ADPCM_NONE && dma_output)     adpcm_active <= 1'b1;
    else if(adpcm_output)                               adpcm_active <= 1'b1;
    else                                                adpcm_active <= 1'b0;
end

wire [7:0] adpcm_active_value =
    (adpcm_type == ADPCM_2BIT)?     adpcm_2bit_reference_next :
    (adpcm_type == ADPCM_3BIT)?     adpcm_3bit_reference_next :
                                    adpcm_4bit_reference_next;

reg [1:0] adpcm_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                                                                       adpcm_type <= ADPCM_NONE;
    else if(sw_reset)                                                                                                                                                       adpcm_type <= ADPCM_NONE;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_2_BIT_REF || dma_command == S_OUT_SINGLE_2_BIT || dma_command == S_OUT_AUTO_2_BIT_REF))    adpcm_type <= ADPCM_2BIT;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_3_BIT_REF || dma_command == S_OUT_SINGLE_3_BIT || dma_command == S_OUT_AUTO_3_BIT_REF))    adpcm_type <= ADPCM_3BIT;
    else if((dma_single_start || dma_auto_start) && (dma_command == S_OUT_SINGLE_4_BIT_REF || dma_command == S_OUT_SINGLE_4_BIT || dma_command == S_OUT_AUTO_4_BIT_REF))    adpcm_type <= ADPCM_4BIT;
    else if((dma_single_start || dma_auto_start))                                                                                                                           adpcm_type <= ADPCM_NONE;
    else if(dma_finished)                                                                                                                                                   adpcm_type <= ADPCM_NONE;
end

reg [2:0] adpcm_step;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_step <= 3'd0;
    else if(sw_reset)                                   adpcm_step <= 3'd0;
    else if(adpcm_active && adpcm_type == ADPCM_2BIT)   adpcm_step <= adpcm_2bit_step_next;
    else if(adpcm_active && adpcm_type == ADPCM_3BIT)   adpcm_step <= adpcm_3bit_step_next;
    else if(adpcm_active && adpcm_type == ADPCM_4BIT)   adpcm_step <= adpcm_4bit_step_next;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_step <= 3'd0;
end

reg [7:0] adpcm_reference;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   adpcm_reference <= 8'd0;
    else if(sw_reset)                                   adpcm_reference <= 8'd0;
    else if(adpcm_active && adpcm_type == ADPCM_2BIT)   adpcm_reference <= adpcm_2bit_reference_next;
    else if(adpcm_active && adpcm_type == ADPCM_3BIT)   adpcm_reference <= adpcm_3bit_reference_next;
    else if(adpcm_active && adpcm_type == ADPCM_4BIT)   adpcm_reference <= adpcm_4bit_reference_next;
    else if(adpcm_reference_awaiting && dma_output)     adpcm_reference <= dma_soundblaster_readdata;
end

//------------------------------------------------------------------------------ adpcm 2 bit

wire [1:0] adpcm_2bit_sample = adpcm_sample[7:6];

wire [7:0] adpcm_2bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?      { 7'd0, adpcm_2bit_sample[0] } :
    (adpcm_step[2:0] == 3'd1)?      { 6'd0, adpcm_2bit_sample[0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?      { 5'd0, adpcm_2bit_sample[0], 2'b10 } :
    (adpcm_step[2:0] == 3'd3)?      { 4'd0, adpcm_2bit_sample[0], 3'b100 } :
    (adpcm_step[2:0] == 3'd4)?      { 3'd0, adpcm_2bit_sample[0], 4'b1000 } :
                                    { 2'd0, adpcm_2bit_sample[0], 5'b10000 }; //adpcm_step[2:0] == 3'd5

wire [8:0] adpcm_2bit_reference_sum = adpcm_reference + adpcm_2bit_reference_adjust;
wire [8:0] adpcm_2bit_reference_sub = adpcm_reference - adpcm_2bit_reference_adjust;

wire [7:0] adpcm_2bit_reference_next =
    (adpcm_2bit_sample[1] && adpcm_2bit_reference_sub[8])?  8'd0 :
    (adpcm_2bit_sample[1])?                                 adpcm_2bit_reference_sub[7:0] :
    (adpcm_2bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_2bit_reference_sum[7:0];
wire [2:0] adpcm_2bit_step_next =
    (adpcm_step < 3'd5 && adpcm_2bit_sample[0] == 1'b1)?    adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_2bit_sample[0] == 1'b0)?    adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------ adpcm 3 bit

wire [2:0] adpcm_3bit_sample = adpcm_sample[7:5];

wire [7:0] adpcm_3bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?                                  { 6'd0, adpcm_3bit_sample[1:0] } :
    (adpcm_step[2:0] == 3'd1)?                                  { 5'd0, adpcm_3bit_sample[1:0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?                                  { 4'd0, adpcm_3bit_sample[1:0], 2'b10 } :
    (adpcm_step[2:0] == 3'd3)?                                  { 3'd0, adpcm_3bit_sample[1:0], 3'b100 } :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd0)?     8'd5 :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd1)?     8'd15 :
    (adpcm_step[2:0] == 3'd4 && adpcm_3bit_sample == 3'd2)?     8'd25 :
                                                                8'd35;
    
wire [8:0] adpcm_3bit_reference_sum = adpcm_reference + adpcm_3bit_reference_adjust;
wire [8:0] adpcm_3bit_reference_sub = adpcm_reference - adpcm_3bit_reference_adjust;

wire [7:0] adpcm_3bit_reference_next =
    (adpcm_3bit_sample[2] && adpcm_3bit_reference_sub[8])?  8'd0 :
    (adpcm_3bit_sample[2])?                                 adpcm_3bit_reference_sub[7:0] :
    (adpcm_3bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_3bit_reference_sum[7:0];
wire [2:0] adpcm_3bit_step_next =
    (adpcm_step < 3'd4 && adpcm_3bit_sample[1:0] == 2'b11)? adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_3bit_sample[1:0] == 2'b00)? adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------ adpcm 4 bit

wire [3:0] adpcm_4bit_sample = adpcm_sample[7:4];

wire [7:0] adpcm_4bit_reference_adjust =
    (adpcm_step[2:0] == 3'd0)?      { 5'd0, adpcm_4bit_sample[2:0] } :
    (adpcm_step[2:0] == 3'd1)?      { 4'd0, adpcm_4bit_sample[2:0], 1'b1 } :
    (adpcm_step[2:0] == 3'd2)?      { 3'd0, adpcm_4bit_sample[2:0], 2'b10 } :
                                    { 2'd0, adpcm_4bit_sample[2:0], 3'b100 }; //adpcm_step[2:0] == 3'd3
    
wire [8:0] adpcm_4bit_reference_sum = adpcm_reference + adpcm_4bit_reference_adjust;
wire [8:0] adpcm_4bit_reference_sub = adpcm_reference - adpcm_4bit_reference_adjust;

wire [7:0] adpcm_4bit_reference_next =
    (adpcm_4bit_sample[3] && adpcm_4bit_reference_sub[8])?  8'd0 :
    (adpcm_4bit_sample[3])?                                 adpcm_4bit_reference_sub[7:0] :
    (adpcm_4bit_reference_sum[8])?                          8'd255 :
                                                            adpcm_4bit_reference_sum[7:0];
wire [2:0] adpcm_4bit_step_next =
    (adpcm_step < 3'd3 && adpcm_4bit_sample[2:0] >= 3'd5)?  adpcm_step + 3'd1 :
    (adpcm_step > 3'd0 && adpcm_4bit_sample[2:0] == 3'd0)?  adpcm_step - 3'd1 :
                                                            adpcm_step;

//------------------------------------------------------------------------------

reg [7:0] period_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               period_address <= 8'd128;
    else if(sw_reset)               period_address <= 8'd128;
    else if(cmd_set_time_constant)  period_address <= write_buffer[7:0];
end

wire [15:0] period_q;

simple_ram #(
    .widthad    (8),
    .width      (16)
)
period_ram_inst(
    .clk                (clk),
    
    .wraddress          (mgmt_address[7:0]),
    .wren               (mgmt_write && mgmt_address[8] == 1'b0),
    .data               (mgmt_writedata[15:0]),
    
    .rdaddress          (period_address),
    .q                  (period_q)
);

//------------------------------------------------------------------------------

assign sample_from_dsp_disabled = ~(speaker_on) || pause_active;
assign sample_from_dsp_do = ~(sample_from_dsp_disabled) && ((dma_output && adpcm_type == ADPCM_NONE) || cmd_direct_output || adpcm_active || (~(adpcm_reference_awaiting) && adpcm_reference_output));

assign sample_from_dsp_value =
    (adpcm_reference_output)?   adpcm_sample :
    (adpcm_active)?             adpcm_active_value :
    (dma_output)?               dma_soundblaster_readdata :
                                write_buffer[7:0];

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, mgmt_writedata[31:16], dma_soundblaster_terminal, 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule


module sound_opl2(
    input               clk,
    input               rst_n,
    
    //sb slave 220h-22Fh
    input       [3:0]   sb_address,
    input               sb_read,
    output      [7:0]   sb_readdata_from_opl2,
    input               sb_write,
    input       [7:0]   sb_writedata,
    
    
    //fm music io slave 388h-389h
    input               fm_address,
    input               fm_read,
    output      [7:0]   fm_readdata,
    input               fm_write,
    input       [7:0]   fm_writedata,
    
    //sample
    output              sample_from_opl2,
    output      [15:0]  sample_from_opl2_value,
    
    //mgmt slave
    /*
    256.[12:0]:  cycles in 80us
    257.[9:0]:   cycles in 1 sample: 96000 Hz
    */
    input       [8:0]   mgmt_address,
    input               mgmt_write,
    input       [31:0]  mgmt_writedata
);

//------------------------------------------------------------------------------

reg [7:0] io_readdata;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   io_readdata <= 8'h06;
    else                io_readdata <= { timer1_overflow | timer2_overflow, timer1_overflow, timer2_overflow, 1'b0, 4'h6 };
end

assign sb_readdata_from_opl2 = io_readdata;
assign fm_readdata           = io_readdata;

//388h reads 06h for OPL2

//------------------------------------------------------------------------------

reg [7:0] index;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               index <= 8'd0;
    else if((sb_address == 4'd0 || sb_address == 4'd8) && sb_write) index <= sb_writedata;
    else if(fm_address == 1'd0 && fm_write)                         index <= fm_writedata;
end

wire io_write = (((sb_address == 4'd1 || sb_address == 4'd9) && sb_write) || (fm_address == 1'd1 && fm_write));

wire [7:0] io_writedata = (sb_write)? sb_writedata : fm_writedata;

//------------------------------------------------------------------------------ timer 1

reg [7:0] timer1_preset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   timer1_preset <= 8'd0;
    else if(io_write && index == 8'h02) timer1_preset <= io_writedata;
end

reg timer1_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           timer1_mask <= 1'd0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]))   timer1_mask <= io_writedata[6];
end

reg timer1_overflow;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer1_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && io_writedata[7])                              timer1_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && io_writedata[6])        timer1_overflow <= 1'b0;
    else if(timer1_active && timer1_sub == 13'd0 && timer1 == 8'hFF && ~(timer1_mask))  timer1_overflow <= 1'b1;
end

wire timer1_activate = io_write && index == 8'h04 && ~(io_writedata[7]) && ~(timer1_active) && io_writedata[0];

reg timer1_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer1_active <= 1'd0;
    else if(timer1_activate)                                                            timer1_active <= 1'b1;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && ~(io_writedata[0]))     timer1_active <= 1'b0;
end

reg [7:0] timer1;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   timer1 <= 8'd0;
    else if(timer1_activate)                                            timer1 <= timer1_preset;
    else if(timer1_active && timer1_sub == 13'd0 && timer1 == 8'hFF)    timer1 <= timer1_preset;
    else if(timer1_active && timer1_sub == 13'd0)                       timer1 <= timer1 + 8'd1;
end

reg [12:0] timer1_sub;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               timer1_sub <= 13'd0;
    else if(timer1_activate)                        timer1_sub <= period_80us;
    else if(timer1_active && timer1_sub > 13'd0)    timer1_sub <= timer1_sub - 13'd1;
    else if(timer1_active && timer1_sub == 13'd0)   timer1_sub <= period_80us;
end

//------------------------------------------------------------------------------ timer 2

reg [7:0] timer2_preset;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   timer2_preset <= 8'd0;
    else if(io_write && index == 8'h03) timer2_preset <= io_writedata;
end

reg timer2_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           timer2_mask <= 1'd0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]))   timer2_mask <= io_writedata[5];
end

reg timer2_overflow;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer2_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && io_writedata[7])                              timer2_overflow <= 1'b0;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && io_writedata[5])        timer2_overflow <= 1'b0;
    else if(timer2_active && timer2_sub == 15'd0 && timer2 == 8'hFF && ~(timer2_mask))  timer2_overflow <= 1'b1;
end

wire timer2_activate = io_write && index == 8'h04 && ~(io_writedata[7]) && ~(timer2_active) && io_writedata[1];

reg timer2_active;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   timer2_active <= 1'd0;
    else if(timer2_activate)                                                            timer2_active <= 1'b1;
    else if(io_write && index == 8'h04 && ~(io_writedata[7]) && ~(io_writedata[1]))     timer2_active <= 1'b0;
end

reg [7:0] timer2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   timer2 <= 8'd0;
    else if(timer2_activate)                                            timer2 <= timer2_preset;
    else if(timer2_active && timer2_sub == 15'd0 && timer2 == 8'hFF)    timer2 <= timer2_preset;
    else if(timer2_active && timer2_sub == 15'd0)                       timer2 <= timer2 + 8'd1;
end

reg [14:0] timer2_sub;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               timer2_sub <= 15'd0;
    else if(timer2_activate)                        timer2_sub <= { period_80us, 2'b00 };
    else if(timer2_active && timer2_sub > 15'd0)    timer2_sub <= timer2_sub - 15'd1;
    else if(timer2_active && timer2_sub == 15'd0)   timer2_sub <= { period_80us, 2'b00 };
end

//------------------------------------------------------------------------------ mgmt

reg [12:0] period_80us;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               period_80us <= 13'd2400;
    else if(mgmt_write && mgmt_address == 9'd256)   period_80us <= mgmt_writedata[12:0];
end

reg [9:0] period_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               period_sample <= 10'd347;
    else if(mgmt_write && mgmt_address == 9'd257)   period_sample <= mgmt_writedata[9:0];
end

//------------------------------------------------------------------------------ register write with immediate reaction

reg await_waveform_select_enable;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_waveform_select_enable <= 1'b0;
    else if(io_write && index == 8'h01)     await_waveform_select_enable <= io_writedata[5];
end

//------------------------------------------------------------------------------ register write with delayed reaction

reg await_keyboard_split;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_keyboard_split <= 1'b0;
    else if(io_write && index == 8'h08)     await_keyboard_split <= io_writedata[6];
end

reg await_tremolo_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_tremolo_depth <= 1'b0;
    else if(io_write && index == 8'hBD)     await_tremolo_depth <= io_writedata[7];
end

reg await_vibrato_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_vibrato_depth <= 1'b0;
    else if(io_write && index == 8'hBD)     await_vibrato_depth <= io_writedata[6];
end

reg await_rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       await_rythm <= 1'b0;
    else if(io_write && index == 8'hBD)     await_rythm <= io_writedata[5];
end

//------------------------------------------------------------------------------

//waveform_select_enable

//composite_sine_wave

//enable_bass_drum
//enable_snare_drum
//enable_tom_tom
//enable_cymbal
//enable_hi_hat

reg keyboard_split;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_split <= 1'b0;
    else if(prepare_cnt_load_regs)  keyboard_split <= await_keyboard_split;
end

reg tremolo_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               tremolo_depth <= 1'b0;
    else if(prepare_cnt_load_regs)  tremolo_depth <= await_tremolo_depth;
end

reg vibrato_depth;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato_depth <= 1'b0;
    else if(prepare_cnt_load_regs)  vibrato_depth <= await_vibrato_depth;
end

reg rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               rythm <= 1'b0;
    else if(prepare_cnt_load_regs)  rythm <= await_rythm;
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs = prepare_cnt == 7'd2;

wire prepare_cnt_sample_1 = prepare_cnt == 7'd114;
wire prepare_cnt_sample_2 = prepare_cnt == 7'd115;
wire prepare_cnt_sample_3 = prepare_cnt == 7'd116;
wire prepare_cnt_sample_4 = prepare_cnt == 7'd117;
wire prepare_cnt_sample_5 = prepare_cnt == 7'd118;
wire prepare_cnt_sample_6 = prepare_cnt == 7'd119;
wire prepare_cnt_sample_7 = prepare_cnt == 7'd120;
wire prepare_cnt_sample_8 = prepare_cnt == 7'd121;
wire prepare_cnt_sample_9 = prepare_cnt == 7'd122;

wire prepare_cnt_sample_10= prepare_cnt == 7'd123;
wire prepare_cnt_sample_11= prepare_cnt == 7'd124;

//------------------------------------------------------------------------------

reg [9:0] sample_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample_cnt <= 10'd0;
    else if(sample_cnt == 10'd0)    sample_cnt <= period_sample - 10'd1;
    else                            sample_cnt <= sample_cnt - 10'd1;
end

//------------------------------------------------------------------------------

reg [6:0] prepare_cnt;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               prepare_cnt <= 7'd0;
    else if(sample_cnt == 10'd1)    prepare_cnt <= 7'd1;
    else if(prepare_cnt != 7'd0)    prepare_cnt <= prepare_cnt + 7'd1;
end

reg [22:0] lfsr;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               lfsr <= 23'd1;
    else if(prepare_cnt_load_regs)  lfsr <= { lfsr[22] ^ lfsr[15] ^ lfsr[14] ^ lfsr[0], lfsr[22:1] };
end

//cliping
//wire [15:0] sample_next = (sample[25] == 1'b0 && sample > 26'h0007FFF)? 26'h0007FFF : (sample[25] == 1'b1 && sample < 26'h3FF8000)? 26'h3FF8000 : sample;

wire [15:0] sample_next =
    (sample[25] == 1'b0 && sample[24] == 1'b1)? sample[25:10] :
    (sample[25] == 1'b0 && sample[23] == 1'b1)? sample[24:9] :
    (sample[25] == 1'b0 && sample[22] == 1'b1)? sample[23:8] :
    (sample[25] == 1'b0 && sample[21] == 1'b1)? sample[22:7] :
    (sample[25] == 1'b0 && sample[20] == 1'b1)? sample[21:6] :
    (sample[25] == 1'b0 && sample[19] == 1'b1)? sample[20:5] :
    (sample[25] == 1'b0 && sample[18] == 1'b1)? sample[19:4] :
    (sample[25] == 1'b0 && sample[17] == 1'b1)? sample[18:3] :
    (sample[25] == 1'b0 && sample[16] == 1'b1)? sample[17:2] :
    (sample[25] == 1'b0 && sample[15] == 1'b1)? sample[16:1] :
    (sample[25] == 1'b1 && sample[24] == 1'b0)? sample[25:10] :
    (sample[25] == 1'b1 && sample[23] == 1'b0)? sample[24:9] :
    (sample[25] == 1'b1 && sample[22] == 1'b0)? sample[23:8] :
    (sample[25] == 1'b1 && sample[21] == 1'b0)? sample[22:7] :
    (sample[25] == 1'b1 && sample[20] == 1'b0)? sample[21:6] :
    (sample[25] == 1'b1 && sample[19] == 1'b0)? sample[20:5] :
    (sample[25] == 1'b1 && sample[18] == 1'b0)? sample[19:4] :
    (sample[25] == 1'b1 && sample[17] == 1'b0)? sample[18:3] :
    (sample[25] == 1'b1 && sample[16] == 1'b0)? sample[17:2] :
    (sample[25] == 1'b1 && sample[15] == 1'b0)? sample[16:1] :
                                                sample[15:0];

reg [25:0] sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sample <= 26'd0;
    else if(prepare_cnt_sample_1)   sample <=          { {10{chanval_0[15]}}, chanval_0 };
    else if(prepare_cnt_sample_2)   sample <= sample + { {10{chanval_1[15]}}, chanval_1 };
    else if(prepare_cnt_sample_3)   sample <= sample + { {10{chanval_2[15]}}, chanval_2 };
    else if(prepare_cnt_sample_4)   sample <= sample + { {10{chanval_3[15]}}, chanval_3 };
    else if(prepare_cnt_sample_5)   sample <= sample + { {10{chanval_4[15]}}, chanval_4 };
    else if(prepare_cnt_sample_6)   sample <= sample + { {10{chanval_5[15]}}, chanval_5 };
    else if(prepare_cnt_sample_7)   sample <= sample + { {10{chanval_6[15]}}, chanval_6 };
    else if(prepare_cnt_sample_8)   sample <= sample + { {10{chanval_7[15]}}, chanval_7 };
    else if(prepare_cnt_sample_9)   sample <= sample + { {10{chanval_8[15]}}, chanval_8 };
    
    else if(prepare_cnt_sample_10)  sample <= sample_next;
end

assign sample_from_opl2_value = sample[15:0];
assign sample_from_opl2       = prepare_cnt_sample_11;

//------------------------------------------------------------------------------

wire rythm_c1;
wire rythm_c3;

wire [15:0] chanval_0;
wire [15:0] chanval_1;
wire [15:0] chanval_2;
wire [15:0] chanval_3;
wire [15:0] chanval_4;
wire [15:0] chanval_5;
wire [15:0] chanval_6;
wire [15:0] chanval_7;
wire [15:0] chanval_8;

sound_opl2_channel channel_0_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h20),  //input
    .write_40h_55h_op1      (io_write && index == 8'h40),  //input
    .write_60h_75h_op1      (io_write && index == 8'h60),  //input
    .write_80h_95h_op1      (io_write && index == 8'h80),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE0),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h23),  //input
    .write_40h_55h_op2      (io_write && index == 8'h43),  //input
    .write_60h_75h_op2      (io_write && index == 8'h63),  //input
    .write_80h_95h_op2      (io_write && index == 8'h83),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE3),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA0),  //input
    .write_B0h_B8h          (io_write && index == 8'hB0),  //input
    .write_C0h_C8h          (io_write && index == 8'hC0),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_0)    //output [15:0]
);

sound_opl2_channel channel_1_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h21),  //input
    .write_40h_55h_op1      (io_write && index == 8'h41),  //input
    .write_60h_75h_op1      (io_write && index == 8'h61),  //input
    .write_80h_95h_op1      (io_write && index == 8'h81),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE1),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h24),  //input
    .write_40h_55h_op2      (io_write && index == 8'h44),  //input
    .write_60h_75h_op2      (io_write && index == 8'h64),  //input
    .write_80h_95h_op2      (io_write && index == 8'h84),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE4),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA1),  //input
    .write_B0h_B8h          (io_write && index == 8'hB1),  //input
    .write_C0h_C8h          (io_write && index == 8'hC1),  //input
    
    .writedata              (io_writedata),  //input [7:0]

    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_1)   //output [15:0]
);

sound_opl2_channel channel_2_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h22),  //input
    .write_40h_55h_op1      (io_write && index == 8'h42),  //input
    .write_60h_75h_op1      (io_write && index == 8'h62),  //input
    .write_80h_95h_op1      (io_write && index == 8'h82),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE2),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h25),  //input
    .write_40h_55h_op2      (io_write && index == 8'h45),  //input
    .write_60h_75h_op2      (io_write && index == 8'h65),  //input
    .write_80h_95h_op2      (io_write && index == 8'h85),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hE5),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA2),  //input
    .write_B0h_B8h          (io_write && index == 8'hB2),  //input
    .write_C0h_C8h          (io_write && index == 8'hC2),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_2)    //output [15:0]
);

sound_opl2_channel channel_3_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h28),  //input
    .write_40h_55h_op1      (io_write && index == 8'h48),  //input
    .write_60h_75h_op1      (io_write && index == 8'h68),  //input
    .write_80h_95h_op1      (io_write && index == 8'h88),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE8),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2B),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4B),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6B),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8B),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hEB),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA3),  //input
    .write_B0h_B8h          (io_write && index == 8'hB3),  //input
    .write_C0h_C8h          (io_write && index == 8'hC3),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_3)    //output [15:0]
);

sound_opl2_channel channel_4_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h29),  //input
    .write_40h_55h_op1      (io_write && index == 8'h49),  //input
    .write_60h_75h_op1      (io_write && index == 8'h69),  //input
    .write_80h_95h_op1      (io_write && index == 8'h89),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hE9),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2C),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4C),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6C),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8C),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hEC),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA4),  //input
    .write_B0h_B8h          (io_write && index == 8'hB4),  //input
    .write_C0h_C8h          (io_write && index == 8'hC4),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_4)    //output [15:0]
);

sound_opl2_channel channel_5_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h2A),  //input
    .write_40h_55h_op1      (io_write && index == 8'h4A),  //input
    .write_60h_75h_op1      (io_write && index == 8'h6A),  //input
    .write_80h_95h_op1      (io_write && index == 8'h8A),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hEA),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h2D),  //input
    .write_40h_55h_op2      (io_write && index == 8'h4D),  //input
    .write_60h_75h_op2      (io_write && index == 8'h6D),  //input
    .write_80h_95h_op2      (io_write && index == 8'h8D),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hED),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA5),  //input
    .write_B0h_B8h          (io_write && index == 8'hB5),  //input
    .write_C0h_C8h          (io_write && index == 8'hC5),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (1'b0), //input
    .rythm_write            (1'b0), //input
    .rythm_bass_drum        (1'b0), //input
    .rythm_snare_drum       (1'b0), //input
    .rythm_tom_tom          (1'b0), //input
    .rythm_cymbal           (1'b0), //input
    .rythm_hi_hat           (1'b0), //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_5)    //output [15:0]
);

sound_opl2_channel channel_6_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h30),  //input
    .write_40h_55h_op1      (io_write && index == 8'h50),  //input
    .write_60h_75h_op1      (io_write && index == 8'h70),  //input
    .write_80h_95h_op1      (io_write && index == 8'h90),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF0),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h33),  //input
    .write_40h_55h_op2      (io_write && index == 8'h53),  //input
    .write_60h_75h_op2      (io_write && index == 8'h73),  //input
    .write_80h_95h_op2      (io_write && index == 8'h93),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF3),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA6),  //input
    .write_B0h_B8h          (io_write && index == 8'hB6),  //input
    .write_C0h_C8h          (io_write && index == 8'hC6),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (io_writedata[5] && io_writedata[4]),   //input
    .rythm_snare_drum       (1'b0),                                 //input
    .rythm_tom_tom          (1'b0),                                 //input
    .rythm_cymbal           (1'b0),                                 //input
    .rythm_hi_hat           (1'b0),                                 //input
    
    .channel_6              (1'b1), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b0), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),     //output / not used
    .rythm_c3               (),     //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (1'b0), //input
    .rythm_noisebit         (1'b0), //input
    
    .chanval                (chanval_6)    //output [15:0]
);

sound_opl2_channel channel_7_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h31),  //input
    .write_40h_55h_op1      (io_write && index == 8'h51),  //input
    .write_60h_75h_op1      (io_write && index == 8'h71),  //input
    .write_80h_95h_op1      (io_write && index == 8'h91),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF1),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h34),  //input
    .write_40h_55h_op2      (io_write && index == 8'h54),  //input
    .write_60h_75h_op2      (io_write && index == 8'h74),  //input
    .write_80h_95h_op2      (io_write && index == 8'h94),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF4),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA7),  //input
    .write_B0h_B8h          (io_write && index == 8'hB7),  //input
    .write_C0h_C8h          (io_write && index == 8'hC7),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (1'b0),                                 //input
    .rythm_snare_drum       (io_writedata[5] && io_writedata[3]),   //input
    .rythm_tom_tom          (1'b0),                                 //input
    .rythm_cymbal           (1'b0),                                 //input
    .rythm_hi_hat           (io_writedata[5] && io_writedata[0]),   //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b1), //input
    .channel_8              (1'b0), //input
    
    .rythm_c1               (rythm_c1),             //output
    /* verilator lint_off PINNOCONNECT */
    .rythm_c3               (),                     //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_phasebit         (rythm_c1 | rythm_c3),  //input
    .rythm_noisebit         (lfsr[22]),             //input
    
    .chanval                (chanval_7)    //output [15:0]
);

sound_opl2_channel channel_8_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h_op1      (io_write && index == 8'h32),  //input
    .write_40h_55h_op1      (io_write && index == 8'h52),  //input
    .write_60h_75h_op1      (io_write && index == 8'h72),  //input
    .write_80h_95h_op1      (io_write && index == 8'h92),  //input
    .write_E0h_F5h_op1      (io_write && index == 8'hF2),  //input
    
    .write_20h_35h_op2      (io_write && index == 8'h35),  //input
    .write_40h_55h_op2      (io_write && index == 8'h55),  //input
    .write_60h_75h_op2      (io_write && index == 8'h75),  //input
    .write_80h_95h_op2      (io_write && index == 8'h95),  //input
    .write_E0h_F5h_op2      (io_write && index == 8'hF5),  //input
    
    .write_A0h_A8h          (io_write && index == 8'hA8),  //input
    .write_B0h_B8h          (io_write && index == 8'hB8),  //input
    .write_C0h_C8h          (io_write && index == 8'hC8),  //input
    
    .writedata              (io_writedata),  //input [7:0]
    
    .vibrato_depth          (vibrato_depth),    //input
    .tremolo_depth          (tremolo_depth),    //input
    .waveform_select_enable (await_waveform_select_enable),   //input
    .keyboard_split         (keyboard_split),           //input
    
    .prepare_cnt            (prepare_cnt),  //input [6:0]
    
    .rythm_enable           (rythm),                                //input
    .rythm_write            (io_write && index == 8'hBD),           //input
    .rythm_bass_drum        (1'b0),                                 //input
    .rythm_snare_drum       (1'b0),                                 //input
    .rythm_tom_tom          (io_writedata[5] && io_writedata[2]),   //input
    .rythm_cymbal           (io_writedata[5] && io_writedata[1]),   //input
    .rythm_hi_hat           (1'b0),                                 //input
    
    .channel_6              (1'b0), //input
    .channel_7              (1'b0), //input
    .channel_8              (1'b1), //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),                     //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_c3               (rythm_c3),             //output
    .rythm_phasebit         (rythm_c1 | rythm_c3),  //input
    .rythm_noisebit         (1'b0),                 //input
    
    .chanval                (chanval_8)    //output [15:0]
);

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, sb_read, fm_read, mgmt_writedata[31:13], 1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule

/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module sound_opl2_operator(
    input                   clk,
    input                   rst_n,
    
    input                   write_20h_35h,
    input                   write_40h_55h,
    input                   write_60h_75h,
    input                   write_80h_95h,
    input                   write_E0h_F5h,
    
    input           [7:0]   writedata,
    
    input           [16:0]  freq_and_octave,
    input           [3:0]   freq_high,
    input           [2:0]   octave,
    input           [2:0]   feedback,
    
    input                   vibrato_depth,
    input                   tremolo_depth,
    
    output                  wform_decrel_request,
    output          [7:0]   wform_decrel_address,
    input           [15:0]  wform_decrel_q,
    
    input                   waveform_select_enable,
    
    output reg      [15:0]  cval,
    input                   keyboard_split,
    
    output          [7:0]   attack_address,
    input           [19:0]  attack_value,
    
    input           [6:0]   prepare_cnt,
    
    input                   enable_normal,
    input                   enable_rythm,
    input                   disable_normal,
    input                   disable_percussion,
    
    output                  rythm_c1,
    output                  rythm_c2,
    output                  rythm_c3,
    
    input                   rythm_phasebit,
    input                   rythm_noisebit,
    input                   rythm_snarebit,
    
    //rythm_bassdrum, rythm_hihat, rythm_snare, rythm_tomtom, rythm_cymbal
    input                   rythm_hihat,
    input                   rythm_snare,
    input                   rythm_cymbal,
    
    input                   operator_a,
    input                   operator_b,

    input           [15:0]  modulator
);

//------------------------------------------------------------------------------ write awaiting

reg await_tremolo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_tremolo <= 1'b0;
    else if(write_20h_35h)  await_tremolo <= writedata[7];
end

reg await_vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_vibrato <= 1'b0;
    else if(write_20h_35h)  await_vibrato <= writedata[6];
end

reg await_eg_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_eg_type <= 1'b1;
    else if(write_20h_35h)  await_eg_type <= writedata[5];
end

reg await_keyboard_scaling_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_keyboard_scaling_rate <= 1'b0;
    else if(write_20h_35h)  await_keyboard_scaling_rate <= writedata[4];
end

reg [3:0] await_freq_multi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_freq_multi <= 4'd0;
    else if(write_20h_35h)  await_freq_multi <= writedata[3:0];
end

reg [1:0] await_keyboard_scaling_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_keyboard_scaling_level <= 2'd0;
    else if(write_40h_55h)  await_keyboard_scaling_level <= writedata[7:6];
end

reg [5:0] await_total_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_total_level <= 6'd0;
    else if(write_40h_55h)  await_total_level <= writedata[5:0];
end

reg [3:0] await_attack_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_attack_rate <= 4'd0;
    else if(write_60h_75h)  await_attack_rate <= writedata[7:4];
end

reg [3:0] await_decay_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_decay_rate <= 4'd0;
    else if(write_60h_75h)  await_decay_rate <= writedata[3:0];
end

reg [3:0] await_sustain_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_sustain_level <= 4'd0;
    else if(write_80h_95h)  await_sustain_level <= writedata[7:4];
end

reg [3:0] await_release_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_release_rate <= 4'd0;
    else if(write_80h_95h)  await_release_rate <= writedata[3:0];
end

reg [1:0] await_wave_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_wave_select <= 2'd0;
    else if(write_E0h_F5h)  await_wave_select <= writedata[1:0];
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs      = prepare_cnt == 7'd2;

wire prepare_cnt_freq_1         = prepare_cnt == 7'd3;
wire prepare_cnt_freq_2         = prepare_cnt == 7'd4;
wire prepare_cnt_freq_3         = prepare_cnt == 7'd5;
wire prepare_cnt_freq_4         = prepare_cnt == 7'd6;
wire prepare_cnt_freq_5         = prepare_cnt == 7'd7;
wire prepare_cnt_freq_6         = prepare_cnt == 7'd8;

wire prepare_cnt_chg_release_1  = prepare_cnt == 7'd9;
wire prepare_cnt_chg_release_2  = prepare_cnt == 7'd10;

wire prepare_cnt_chg_decay_1    = prepare_cnt == 7'd11;
wire prepare_cnt_chg_decay_2    = prepare_cnt == 7'd12;

wire prepare_cnt_chg_attack_1   = prepare_cnt == 7'd13;

wire prepare_cnt_chg_enable_1   = prepare_cnt == 7'd14;
wire prepare_cnt_chg_enable_2   = prepare_cnt == 7'd15;

//

wire prepare_cnt_vibrato_1  = prepare_cnt == 7'd24;
wire prepare_cnt_vibrato_2  = prepare_cnt == 7'd25;
wire prepare_cnt_vibrato_3  = prepare_cnt == 7'd26;
wire prepare_cnt_vibrato_4  = prepare_cnt == 7'd27;
wire prepare_cnt_vibrato_5  = prepare_cnt == 7'd28;
wire prepare_cnt_vibrato_6  = prepare_cnt == 7'd29;
wire prepare_cnt_vibrato_7  = prepare_cnt == 7'd30;
wire prepare_cnt_vibrato_8  = prepare_cnt == 7'd31;
wire prepare_cnt_vibrato_9  = prepare_cnt == 7'd32;
wire prepare_cnt_vibrato_10 = prepare_cnt == 7'd33;
wire prepare_cnt_vibrato_11 = prepare_cnt == 7'd34;

wire prepare_cnt_tcount_1   = prepare_cnt == 7'd35;
wire prepare_cnt_tcount_2   = prepare_cnt == 7'd36;
wire prepare_cnt_tcount_3   = prepare_cnt == 7'd37;
//update wfpos, tcount, generator_pos, env_step

wire prepare_cnt_attack_1  = prepare_cnt == 7'd42 && state == S_ATTACK;
//wire prepare_cnt_attack_2  = prepare_cnt == 7'd43 && state == S_ATTACK;
//wire prepare_cnt_attack_3  = prepare_cnt == 7'd44 && state == S_ATTACK;
wire prepare_cnt_attack_4  = prepare_cnt == 7'd45 && state == S_ATTACK;
//wire prepare_cnt_attack_5  = prepare_cnt == 7'd46 && state == S_ATTACK;
//wire prepare_cnt_attack_6  = prepare_cnt == 7'd47 && state == S_ATTACK;
wire prepare_cnt_attack_7  = prepare_cnt == 7'd48 && state == S_ATTACK;
//wire prepare_cnt_attack_8  = prepare_cnt == 7'd49 && state == S_ATTACK;
//wire prepare_cnt_attack_9  = prepare_cnt == 7'd50 && state == S_ATTACK;
wire prepare_cnt_attack_10 = prepare_cnt == 7'd51 && state == S_ATTACK;
//wire prepare_cnt_attack_11 = prepare_cnt == 7'd52 && state == S_ATTACK;
//wire prepare_cnt_attack_12 = prepare_cnt == 7'd53 && state == S_ATTACK;
wire prepare_cnt_attack_13 = prepare_cnt == 7'd54 && state == S_ATTACK;
wire prepare_cnt_attack_14 = prepare_cnt == 7'd55 && state == S_ATTACK;
//wire prepare_cnt_attack_15 = prepare_cnt == 7'd56 && state == S_ATTACK;
//wire prepare_cnt_attack_16 = prepare_cnt == 7'd57 && state == S_ATTACK;
wire prepare_cnt_attack_17 = prepare_cnt == 7'd58 && state == S_ATTACK;
wire prepare_cnt_attack_18 = prepare_cnt == 7'd59 && state == S_ATTACK;
wire prepare_cnt_attack_19 = prepare_cnt == 7'd60 && state == S_ATTACK;
//wire prepare_cnt_attack_20 = prepare_cnt == 7'd61 && state == S_ATTACK;
//wire prepare_cnt_attack_21 = prepare_cnt == 7'd62 && state == S_ATTACK;
wire prepare_cnt_attack_22 = prepare_cnt == 7'd63 && state == S_ATTACK;
wire prepare_cnt_attack_23 = prepare_cnt == 7'd64 && state == S_ATTACK;
wire prepare_cnt_attack_24 = prepare_cnt == 7'd65 && state == S_ATTACK;
wire prepare_cnt_attack_25 = prepare_cnt == 7'd66 && state == S_ATTACK;
wire prepare_cnt_attack_26 = prepare_cnt == 7'd67 && state == S_ATTACK;
wire prepare_cnt_attack_27 = prepare_cnt == 7'd68 && state == S_ATTACK;
wire prepare_cnt_attack_28 = prepare_cnt == 7'd69 && state == S_ATTACK;
wire prepare_cnt_attack_29 = prepare_cnt == 7'd70 && state == S_ATTACK;
wire prepare_cnt_attack_30 = prepare_cnt == 7'd71 && state == S_ATTACK;

wire prepare_cnt_decay_1   = prepare_cnt == 7'd42 && state == S_DECAY;
//wire prepare_cnt_decay_2   = prepare_cnt == 7'd43 && state == S_DECAY;
//wire prepare_cnt_decay_3   = prepare_cnt == 7'd44 && state == S_DECAY;
wire prepare_cnt_decay_4   = prepare_cnt == 7'd45 && state == S_DECAY;
wire prepare_cnt_decay_5   = prepare_cnt == 7'd46 && state == S_DECAY;

wire prepare_cnt_release_1 = prepare_cnt == 7'd42 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
//wire prepare_cnt_release_2 = prepare_cnt == 7'd43 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
//wire prepare_cnt_release_3 = prepare_cnt == 7'd44 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
wire prepare_cnt_release_4 = prepare_cnt == 7'd45 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);
wire prepare_cnt_release_5 = prepare_cnt == 7'd46 && (state == S_RELEASE || state == S_SUSTAIN_NOKEEP);

wire prepare_cnt_output_1  = (prepare_cnt == 7'd74 && operator_a) || (prepare_cnt == 7'd94 && operator_b);
wire prepare_cnt_output_2  = (prepare_cnt == 7'd75 && operator_a) || (prepare_cnt == 7'd95 && operator_b);
wire prepare_cnt_output_3  = (prepare_cnt == 7'd76 && operator_a) || (prepare_cnt == 7'd96 && operator_b);
wire prepare_cnt_output_4  = (prepare_cnt == 7'd77 && operator_a) || (prepare_cnt == 7'd97 && operator_b);
wire prepare_cnt_output_5  = (prepare_cnt == 7'd78 && operator_a) || (prepare_cnt == 7'd98 && operator_b);
//wire prepare_cnt_output_6  = (prepare_cnt == 7'd79 && operator_a) || (prepare_cnt == 7'd99 && operator_b);
//wire prepare_cnt_output_7  = (prepare_cnt == 7'd80 && operator_a) || (prepare_cnt == 7'd100 && operator_b);
wire prepare_cnt_output_8  = (prepare_cnt == 7'd81 && operator_a) || (prepare_cnt == 7'd101 && operator_b);
//wire prepare_cnt_output_9  = (prepare_cnt == 7'd82 && operator_a) || (prepare_cnt == 7'd102 && operator_b);
//wire prepare_cnt_output_10 = (prepare_cnt == 7'd83 && operator_a) || (prepare_cnt == 7'd103 && operator_b);
wire prepare_cnt_output_11 = (prepare_cnt == 7'd84 && operator_a) || (prepare_cnt == 7'd104 && operator_b);
//wire prepare_cnt_output_12 = (prepare_cnt == 7'd85 && operator_a) || (prepare_cnt == 7'd105 && operator_b);
wire prepare_cnt_output_13 = (prepare_cnt == 7'd86 && operator_a) || (prepare_cnt == 7'd106 && operator_b);
wire prepare_cnt_output_14 = (prepare_cnt == 7'd87 && operator_a) || (prepare_cnt == 7'd107 && operator_b);
wire prepare_cnt_output_15 = (prepare_cnt == 7'd88 && operator_a) || (prepare_cnt == 7'd108 && operator_b);


/*

ARC_TVS_KSR_MUL:
    change_keepsustain:     op_state, sus_keep (op_state, sus_keep)
    change_vibrato:         vibrato*, tremolo*
    change_frequency:       toff, tinc, vol, freq_high & 
    
ARC_KSL_OUTLEV:
    change_frequency
    
ARC_ATTR_DECR:
    change_attackrate:      a0,a1,a2,a3, env_step_a, env_step_skip_a (attackrate, toff)
    change_decayrate:       decaymul, env_step_d (decayrate, toff)
    
ARC_SUSL_RELR:
    change_releaserate:     releasemul, env_step_r (releaserate, toff)
    change_sustainlevel:    sustain_level
    
ARC_FREQ_NUM:
    change_frequency op1
    change_frequency op2
    
ARC_KON_BNUM:
    enable_operator op1   / disable_operator op1 / enable_operator op1  / disable_operator op1
    change_frequency op1  / disable_operator op2 / enable_operator op2  / disable_operator op2
    enable_operator op2   /                      / change_frequency op1 / change_frequency op1
    change_frequency op2  /                      / change_frequency op2 / change_frequency op2
    
enable_operator:            tcount, op_state, act_state (act_state, wave_sel)
disable_operator:           op_state, act_state
    
ARC_FEEDBACK:
    change_feedback:        mfbi
    
ARC_WAVE_SEL:
    change_waveform:        cur_wmask, cur_wform (wave_sel)

*/


reg tremolo;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               tremolo <= 1'b0;
    else if(prepare_cnt_load_regs)  tremolo <= await_tremolo;
end

reg vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato <= 1'b0;
    else if(prepare_cnt_load_regs)  vibrato <= await_vibrato;
end

reg eg_type;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               eg_type <= 1'b1;
    else if(prepare_cnt_load_regs)  eg_type <= await_eg_type;
end

reg keyboard_scaling_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_scaling_rate <= 1'b0;
    else if(prepare_cnt_load_regs)  keyboard_scaling_rate <= await_keyboard_scaling_rate;
end

reg [3:0] freq_multi;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               freq_multi <= 4'd0;
    else if(prepare_cnt_load_regs)  freq_multi <= await_freq_multi;
end

reg [1:0] keyboard_scaling_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               keyboard_scaling_level <= 2'd0;
    else if(prepare_cnt_load_regs)  keyboard_scaling_level <= await_keyboard_scaling_level;
end

reg [5:0] total_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               total_level <= 6'd0;
    else if(prepare_cnt_load_regs)  total_level <= await_total_level;
end

reg [3:0] attack_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  attack_rate <= await_attack_rate;
end

reg [3:0] decay_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               decay_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  decay_rate <= await_decay_rate;
end

reg [3:0] sustain_level;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               sustain_level <= 4'd0;
    else if(prepare_cnt_load_regs)  sustain_level <= await_sustain_level;
end

reg [3:0] release_rate;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_rate <= 4'd0;
    else if(prepare_cnt_load_regs)  release_rate <= await_release_rate;
end

reg [1:0] wave_select;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           wave_select <= 2'd0;
    else if(prepare_cnt_load_regs && waveform_select_enable)    wave_select <= await_wave_select;
end

//------------------------------------------------------------------------------ change_frequency

wire [3:0] freq_multi_final =
    (freq_multi == 4'd11)?  4'd10 :
    (freq_multi == 4'd13)?  4'd12 :
    (freq_multi == 4'd14)?  4'd15 :
                            freq_multi;

// f_INT * fixedpoint / (N * f_s)
// f_INT = 49715,903 Hz
// fixedpoint = 32'h00010000
// N = 1024
// f_s = 96000 Hz

// freq_multi * (32+1) * freq_and_octave

reg [22:0] tinc_prepare;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)          tinc_prepare <= 23'd0;
    else if(prepare_cnt_freq_1) tinc_prepare <= { 5'd0, freq_and_octave } + { freq_and_octave, 5'd0 }; //(32+1) * freq_and_octave
end

reg [25:0] tinc;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                       tinc <= 26'd0;
    else if(prepare_cnt_freq_1)                                              tinc <= 26'd0;
    else if(prepare_cnt_freq_2 && freq_multi == 4'd0)                        tinc <= {  4'd0, tinc_prepare[22:1] }; // div2
    else if(prepare_cnt_freq_2 && freq_multi != 4'd0 && freq_multi_final[0]) tinc <= tinc + { 3'd0, tinc_prepare };
    else if(prepare_cnt_freq_3 && freq_multi != 4'd0 && freq_multi_final[1]) tinc <= tinc + { 2'd0, tinc_prepare, 1'd0 };
    else if(prepare_cnt_freq_4 && freq_multi != 4'd0 && freq_multi_final[2]) tinc <= tinc + { 1'd0, tinc_prepare, 2'd0 };
    else if(prepare_cnt_freq_5 && freq_multi != 4'd0 && freq_multi_final[3]) tinc <= tinc + {       tinc_prepare, 3'd0 };
end

wire [3:0] toff_next =
    (~(keyboard_scaling_rate))? { 2'b0, octave[2:1] } : { octave, (freq_high[3] & ~(keyboard_split)) | (freq_high[2] & keyboard_split) };

reg [3:0] toff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)          toff <= 4'd0;
    else if(prepare_cnt_freq_6) toff <= toff_next;
end

wire [5:0] kslev_prepare =
    (freq_high == 4'd15)?     6'd56 :
    (freq_high == 4'd14)?     6'd55 :
    (freq_high == 4'd13)?     6'd54 :
    (freq_high == 4'd12)?     6'd53 :
    (freq_high == 4'd11)?     6'd52 :
    (freq_high == 4'd10)?     6'd51 :
    (freq_high == 4'd9)?      6'd50 :
    (freq_high == 4'd8)?      6'd48 :
    (freq_high == 4'd7)?      6'd47 :
    (freq_high == 4'd6)?      6'd45 :
    (freq_high == 4'd5)?      6'd43 :
    (freq_high == 4'd4)?      6'd40 :
    (freq_high == 4'd3)?      6'd37 :
    (freq_high == 4'd2)?      6'd32 :
    (freq_high == 4'd1)?      6'd24 :
                              6'd0;

wire [2:0] kslev_oct = 3'd7 - octave;
wire [5:0] kslev_sub = { kslev_oct, 3'b0 };

wire [5:0] kslev = (kslev_sub > kslev_prepare)? 6'd0 : kslev_prepare - kslev_sub;

//total_level[5:0]
//keyboard_scaling_level[1:0]

wire [7:0] kslev_mult =
    (keyboard_scaling_level == 2'd0)?   8'd0 :
    (keyboard_scaling_level == 2'd1)?   { 1'd0, kslev, 1'd0 } :
    (keyboard_scaling_level == 2'd2)?   { 2'd0, kslev } :
                                        {       kslev, 2'd0 };

reg [8:0] volume_in;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_in <= 9'd0;
    else if(prepare_cnt_freq_1)  volume_in <= { 1'b0, kslev_mult };
    else if(prepare_cnt_freq_2)  volume_in <= volume_in + { 1'b0, total_level, 2'd0 };
end

wire [16:0] volume_prepare =
    (volume_in[4:0] == 5'd0)?   { 1'b1, 16'h0000 } :
    (volume_in[4:0] == 5'd1)?   { 1'b0, 16'hFA83 } : //2^{-1/32}
    (volume_in[4:0] == 5'd2)?   { 1'b0, 16'hF525 } : //2^{-2/32}
    (volume_in[4:0] == 5'd3)?   { 1'b0, 16'hEFE4 } : //2^{-3/32}
    (volume_in[4:0] == 5'd4)?   { 1'b0, 16'hEAC0 } : //2^{-4/32}
    (volume_in[4:0] == 5'd5)?   { 1'b0, 16'hE5B9 } : //2^{-5/32}
    (volume_in[4:0] == 5'd6)?   { 1'b0, 16'hE0CC } : //2^{-6/32}
    (volume_in[4:0] == 5'd7)?   { 1'b0, 16'hDBFB } : //2^{-7/32}
    (volume_in[4:0] == 5'd8)?   { 1'b0, 16'hD744 } : //2^{-8/32}
    (volume_in[4:0] == 5'd9)?   { 1'b0, 16'hD2A8 } : //2^{-9/32}
    (volume_in[4:0] == 5'd10)?  { 1'b0, 16'hCE24 } : //2^{-10/32}
    (volume_in[4:0] == 5'd11)?  { 1'b0, 16'hC9B9 } : //2^{-11/32}
    (volume_in[4:0] == 5'd12)?  { 1'b0, 16'hC567 } : //2^{-12/32}
    (volume_in[4:0] == 5'd13)?  { 1'b0, 16'hC12C } : //2^{-13/32}
    (volume_in[4:0] == 5'd14)?  { 1'b0, 16'hBD08 } : //2^{-14/32}
    (volume_in[4:0] == 5'd15)?  { 1'b0, 16'hB8FB } : //2^{-15/32}
    (volume_in[4:0] == 5'd16)?  { 1'b0, 16'hB504 } : //2^{-16/32}
    (volume_in[4:0] == 5'd17)?  { 1'b0, 16'hB123 } : //2^{-17/32}
    (volume_in[4:0] == 5'd18)?  { 1'b0, 16'hAD58 } : //2^{-18/32}
    (volume_in[4:0] == 5'd19)?  { 1'b0, 16'hA9A1 } : //2^{-19/32}
    (volume_in[4:0] == 5'd20)?  { 1'b0, 16'hA5FE } : //2^{-20/32}
    (volume_in[4:0] == 5'd21)?  { 1'b0, 16'hA270 } : //2^{-21/32}
    (volume_in[4:0] == 5'd22)?  { 1'b0, 16'h9EF5 } : //2^{-22/32}
    (volume_in[4:0] == 5'd23)?  { 1'b0, 16'h9B8D } : //2^{-23/32}
    (volume_in[4:0] == 5'd24)?  { 1'b0, 16'h9837 } : //2^{-24/32}
    (volume_in[4:0] == 5'd25)?  { 1'b0, 16'h94F4 } : //2^{-25/32}
    (volume_in[4:0] == 5'd26)?  { 1'b0, 16'h91C3 } : //2^{-26/32}
    (volume_in[4:0] == 5'd27)?  { 1'b0, 16'h8EA4 } : //2^{-27/32}
    (volume_in[4:0] == 5'd28)?  { 1'b0, 16'h8B95 } : //2^{-28/32}
    (volume_in[4:0] == 5'd29)?  { 1'b0, 16'h8898 } : //2^{-29/32}
    (volume_in[4:0] == 5'd30)?  { 1'b0, 16'h85AA } : //2^{-30/32}
                                { 1'b0, 16'h82CD };  //2^{-31/32}
                                
reg [16:0] volume_frac;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_frac <= 17'd0;
    else if(prepare_cnt_freq_3)  volume_frac <= volume_prepare;
end

reg [3:0] volume_int;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           volume_int <= 4'd0;
    else if(prepare_cnt_freq_3)  volume_int <= volume_in[8:5];
end

//------------------------------------------------------------------------------ change_release, change_decay, waveform

assign wform_decrel_request = prepare_cnt_chg_release_1 || prepare_cnt_chg_decay_1;

assign wform_decrel_address = (prepare_cnt_chg_release_1)? { toff, release_rate } : (prepare_cnt_chg_decay_1)? { toff, decay_rate } : waveform_address;

//------------------------------------------------------------------------------ change_release

reg [16:0] release_mul;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_mul <= 17'h10000;
    else if(prepare_cnt_chg_release_2)   release_mul <= (release_rate == 4'd0)? 17'h10000 : { 1'b0, wform_decrel_q };
end

wire [6:0] release_steps = { 1'b0, release_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] release_mask_next =
    (release_rate == 4'd0)?         12'h0 : 
    (release_steps[6:2] >= 5'd12)?  12'h0 :
    (release_steps[6:2] == 5'd11)?  12'h001 :
    (release_steps[6:2] == 5'd10)?  12'h003 :
    (release_steps[6:2] == 5'd9)?   12'h007 :
    (release_steps[6:2] == 5'd8)?   12'h00F :
    (release_steps[6:2] == 5'd7)?   12'h01F :
    (release_steps[6:2] == 5'd6)?   12'h03F :
    (release_steps[6:2] == 5'd5)?   12'h07F :
    (release_steps[6:2] == 5'd4)?   12'h0FF :
    (release_steps[6:2] == 5'd3)?   12'h1FF :
    (release_steps[6:2] == 5'd2)?   12'h3FF :
    (release_steps[6:2] == 5'd1)?   12'h7FF :
                                    12'hFFF;

reg [11:0] release_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               release_mask <= 12'd0;
    else if(prepare_cnt_chg_release_2)   release_mask <= release_mask_next;
end

//------------------------------------------------------------------------------ change_decay

reg [16:0] decay_mul;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           decay_mul <= 17'h10000;
    else if(prepare_cnt_chg_decay_2) decay_mul <= (decay_rate == 4'd0)? 17'h10000 : { 1'b0, wform_decrel_q };
end

wire [6:0] decay_steps = { 1'b0, decay_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] decay_mask_next =
    (decay_rate == 4'd0)?           12'h0 : 
    (decay_steps[6:2] >= 5'd12)?    12'h0 :
    (decay_steps[6:2] == 5'd11)?    12'h001 :
    (decay_steps[6:2] == 5'd10)?    12'h003 :
    (decay_steps[6:2] == 5'd9)?     12'h007 :
    (decay_steps[6:2] == 5'd8)?     12'h00F :
    (decay_steps[6:2] == 5'd7)?     12'h01F :
    (decay_steps[6:2] == 5'd6)?     12'h03F :
    (decay_steps[6:2] == 5'd5)?     12'h07F :
    (decay_steps[6:2] == 5'd4)?     12'h0FF :
    (decay_steps[6:2] == 5'd3)?     12'h1FF :
    (decay_steps[6:2] == 5'd2)?     12'h3FF :
    (decay_steps[6:2] == 5'd1)?     12'h7FF :
                                    12'hFFF;

reg [11:0] decay_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   decay_mask <= 12'd0;
    else if(prepare_cnt_chg_decay_2)    decay_mask <= decay_mask_next;
end

//------------------------------------------------------------------------------ change_attack

assign attack_address = { toff, attack_rate };

wire [6:0] attack_steps = { 1'b0, attack_rate, 2'b0 } + { 3'd0, toff };

wire [11:0] attack_mask_next =
    (attack_rate == 4'd0)?          12'h0 : 
    (attack_steps[6:2] >= 5'd12)?   12'h0 :
    (attack_steps[6:2] == 5'd11)?   12'h001 :
    (attack_steps[6:2] == 5'd10)?   12'h003 :
    (attack_steps[6:2] == 5'd9)?    12'h007 :
    (attack_steps[6:2] == 5'd8)?    12'h00F :
    (attack_steps[6:2] == 5'd7)?    12'h01F :
    (attack_steps[6:2] == 5'd6)?    12'h03F :
    (attack_steps[6:2] == 5'd5)?    12'h07F :
    (attack_steps[6:2] == 5'd4)?    12'h0FF :
    (attack_steps[6:2] == 5'd3)?    12'h1FF :
    (attack_steps[6:2] == 5'd2)?    12'h3FF :
    (attack_steps[6:2] == 5'd1)?    12'h7FF :
                                    12'hFFF;

reg [11:0] attack_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_mask <= 12'd0;
    else if(prepare_cnt_chg_attack_1)    attack_mask <= attack_mask_next;
end

wire [7:0] attack_skip_mask_next =
    (attack_mask_next > 12'd48)?        8'hFF :
    (attack_mask_next[1:0] == 2'd0)?    8'hAA :
    (attack_mask_next[1:0] == 2'd1)?    8'hBA :
    (attack_mask_next[1:0] == 2'd2)?    8'hEE :
                                        8'hFE;

reg [7:0] attack_skip_mask;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                   attack_skip_mask <= 8'd0;
    else if(prepare_cnt_chg_attack_1)   attack_skip_mask <= attack_skip_mask_next;
end

//------------------------------------------------------------------------------ change_enable / change_disable : react everytime

reg active_normal;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               active_normal <= 1'b0;
    else if(~(active_normal) && ~(active_rythm) && enable_normal)   active_normal <= 1'b1;
    else if(active_normal && disable_normal)                        active_normal <= 1'b0;
end

reg active_rythm;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               active_rythm <= 1'b0;
    else if(~(active_normal) && ~(active_rythm) && enable_rythm)    active_rythm <= 1'b1;
    else if(active_rythm && disable_percussion)                     active_rythm <= 1'b0;
end

localparam [1:0] ACTIVE_IDLE        = 2'd0;
localparam [1:0] ACTIVE_TO_RELEASE  = 2'd1;
localparam [1:0] ACTIVE_TO_ATTACK   = 2'd2;

reg [1:0] active_on_next_sample;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   active_on_next_sample <= ACTIVE_IDLE;
    else if(~(active_normal) && ~(active_rythm) && (enable_normal || enable_rythm))     active_on_next_sample <= ACTIVE_TO_ATTACK;
    else if((active_normal && disable_normal) || (active_rythm && disable_percussion))  active_on_next_sample <= ACTIVE_TO_RELEASE;
    else if(prepare_cnt_chg_enable_2)                                                   active_on_next_sample <= ACTIVE_IDLE;
end

//------------------------------------------------------------------------------ state

localparam [2:0] S_OFF              = 3'd0;
localparam [2:0] S_ATTACK           = 3'd1;
localparam [2:0] S_DECAY            = 3'd2;
localparam [2:0] S_SUSTAIN          = 3'd3;
localparam [2:0] S_SUSTAIN_NOKEEP   = 3'd4;
localparam [2:0] S_RELEASE          = 3'd5;

reg [2:0] state;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                   state <= S_OFF;
    
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_ATTACK)                      state <= S_ATTACK;
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_RELEASE && state != S_OFF)   state <= S_RELEASE;
    
    else if(prepare_cnt_chg_enable_1 && state == S_SUSTAIN        && eg_type == 1'b0)                   state <= S_SUSTAIN_NOKEEP;
    else if(prepare_cnt_chg_enable_1 && state == S_SUSTAIN_NOKEEP && eg_type == 1'b1)                   state <= S_SUSTAIN;

    //attack
    else if(attack_step_finished)                                                                       state <= S_DECAY;
    
    //decay
    else if(decay_step_finish_to_sustain)                                                               state <= S_SUSTAIN;
    else if(decay_step_finish_to_sustain_no_keep)                                                       state <= S_SUSTAIN_NOKEEP;
    
    //release
    else if(state == S_RELEASE && release_step_finish)                                                  state <= S_OFF;
end

//------------------------------------------------------------------------------ rythm data between operators

assign rythm_c1 = (tcount[18] ^ tcount[23]) | tcount[19];  //(c1 & 0x88) ^ ((c1<<5) & 0x80)
assign rythm_c2 = tcount[24];
assign rythm_c3 = tcount[21] ^ tcount[19]; //((c3 ^ (c3<<2)) & 0x20)

//------------------------------------------------------------------------------ vibrato

// (f_INT/8192) * (8/f_s) * LFO_fixedpoint = 8484
// ~6,1 Hz

reg [26:0] vibrato_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               vibrato_pos <= 27'd0;
    else if(prepare_cnt_vibrato_1)  vibrato_pos <= vibrato_pos + 27'd8484;
end

wire vibrato_table_8 = vibrato_depth && (vibrato_pos[26:24] == 3'd0 || vibrato_pos[26:24] == 3'd4);
wire vibrato_table_4 =
    (vibrato_depth == 1'b0 && (vibrato_pos[26:24] == 3'd0 || vibrato_pos[26:24] == 3'd4)) ||
    (vibrato_depth == 1'b1 && (vibrato_pos[26:24] == 3'd1 || vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd5 || vibrato_pos[26:24] == 3'd7));
wire vibrato_table_2 =
    (vibrato_depth == 1'b0 && (vibrato_pos[26:24] == 3'd1 || vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd5 || vibrato_pos[26:24] == 3'd7));
    
wire [9:0] vibrato_mult =
    (vibrato_table_8 && freq_high[3:1] == 3'd1)?                                10'd91 :  //1
    (vibrato_table_8 && freq_high[3:1] == 3'd2)?                                10'd183 : //2
    (vibrato_table_8 && freq_high[3:1] == 3'd3)?                                10'd275 : //3
    (vibrato_table_8 && freq_high[3:1] == 3'd4)?                                10'd367 : //4
    (vibrato_table_8 && freq_high[3:1] == 3'd5)?                                10'd458 : //5
    (vibrato_table_8 && freq_high[3:1] == 3'd6)?                                10'd550 : //6
    (vibrato_table_8 && freq_high[3:1] == 3'd7)?                                10'd642 : //7
    (vibrato_table_4 && (freq_high[3:1] == 3'd2 || freq_high[3:1] == 3'd3))?    10'd91 :  //1
    (vibrato_table_4 && (freq_high[3:1] == 3'd4 || freq_high[3:1] == 3'd5))?    10'd183 : //2
    (vibrato_table_4 && (freq_high[3:1] == 3'd6 || freq_high[3:1] == 3'd7))?    10'd275 : //3
    (vibrato_table_2 && freq_high[3:1] >= 3'd4)?                                10'd91 :  //1
                                                                                10'd0;

//vibrato_pos[26:24]
//freq_high[3:1]
//vibrato_depth[0]

//tinc*(lut*high/8)*fixed*70/50000)/fixed

wire vibrato_sign = vibrato_pos[26:24] == 3'd3 || vibrato_pos[26:24] == 3'd4 || vibrato_pos[26:24] == 3'd5;

reg [35:0] tinc_vibrato;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   tinc_vibrato <= 36'd0;
    else if(prepare_cnt_vibrato_1)                      tinc_vibrato <= 36'd0;
    else if(prepare_cnt_vibrato_2  && vibrato_mult[0])  tinc_vibrato <= tinc_vibrato + { 10'd0, tinc };
    else if(prepare_cnt_vibrato_3  && vibrato_mult[1])  tinc_vibrato <= tinc_vibrato + { 9'd0,  tinc, 1'b0 };
    else if(prepare_cnt_vibrato_4  && vibrato_mult[2])  tinc_vibrato <= tinc_vibrato + { 8'd0,  tinc, 2'b0 };
    else if(prepare_cnt_vibrato_5  && vibrato_mult[3])  tinc_vibrato <= tinc_vibrato + { 7'd0,  tinc, 3'b0 };
    else if(prepare_cnt_vibrato_6  && vibrato_mult[4])  tinc_vibrato <= tinc_vibrato + { 6'd0,  tinc, 4'b0 };
    else if(prepare_cnt_vibrato_7  && vibrato_mult[5])  tinc_vibrato <= tinc_vibrato + { 5'd0,  tinc, 5'b0 };
    else if(prepare_cnt_vibrato_8  && vibrato_mult[6])  tinc_vibrato <= tinc_vibrato + { 4'd0,  tinc, 6'b0 };
    else if(prepare_cnt_vibrato_9  && vibrato_mult[7])  tinc_vibrato <= tinc_vibrato + { 3'd0,  tinc, 7'b0 };
    else if(prepare_cnt_vibrato_10 && vibrato_mult[8])  tinc_vibrato <= tinc_vibrato + { 2'd0,  tinc, 8'b0 };
    else if(prepare_cnt_vibrato_11 && vibrato_mult[9])  tinc_vibrato <= tinc_vibrato + { 1'd0,  tinc, 9'b0 };
end

//------------------------------------------------------------------------------

reg [25:0] tcount;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                               tcount <= 26'd0;
    else if(prepare_cnt_chg_enable_1 && active_on_next_sample == ACTIVE_TO_ATTACK)  tcount <= 26'd0;
    
    else if(prepare_cnt_tcount_2 && vibrato && ~(vibrato_sign))                     tcount <= tcount + { 6'd0, tinc_vibrato[35:16] };
    else if(prepare_cnt_tcount_2 && vibrato && vibrato_sign)                        tcount <= tcount - { 6'd0, tinc_vibrato[35:16] };
    else if(prepare_cnt_tcount_3)                                                   tcount <= tcount + tinc;
end

wire [25:0] wfpos_next =
                                                                                //(phasebit<<8) | (0x34<<(phasebit ^ (noisebit<<1)))
    (rythm_hihat  && active_rythm && ~(rythm_phasebit) && ~(rythm_noisebit))?   { 2'b0, 8'h34, 16'd0 }:
    (rythm_hihat  && active_rythm && ~(rythm_phasebit) && rythm_noisebit)?      { 8'h34, 2'b0, 16'd0 } :
    (rythm_hihat  && active_rythm && rythm_phasebit    && ~(rythm_noisebit))?   { 8'h80 | 8'h34, 2'b0, 16'd0 } :
    (rythm_hihat  && active_rythm && rythm_phasebit    && rythm_noisebit)?      { 8'h80 | 8'h0D, 2'b0, 16'd0 } :
                                                                                //((1+snare_phase_bit) ^ noisebit)<<8
    (rythm_snare  && active_rythm && ~(rythm_snarebit) && ~(rythm_noisebit))?   { 2'b01, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && ~(rythm_snarebit) && rythm_noisebit)?      { 2'b00, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && rythm_snarebit    && ~(rythm_noisebit))?   { 2'b10, 8'd0, 16'd0 } :
    (rythm_snare  && active_rythm && rythm_snarebit    && rythm_noisebit)?      { 2'b11, 8'd0, 16'd0 } :
                                                                                //(1+phasebit)<<8
    (rythm_cymbal && active_rythm && ~(rythm_phasebit))?                        { 2'b01, 8'd0, 16'd0 } :
    (rythm_cymbal && active_rythm && rythm_phasebit)?                           { 2'b11, 8'd0, 16'd0 } :
                                                                                tcount;

reg [25:0] wfpos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               wfpos <= 26'd0;
    else if(prepare_cnt_tcount_1)   wfpos <= wfpos_next;
end

//------------------------------------------------------------------------------ generator_pos

reg [16:0] generator_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   generator_pos <= 17'd0;
    else if(prepare_cnt_tcount_1 && generator_pos[16])  generator_pos <= { 1'b0, generator_pos[15:0] };
    else if(prepare_cnt_tcount_2)                       generator_pos <= generator_pos + 17'd33939; //f_INT / f_s * fixedpoint
end

wire generator_active = generator_pos[16];

reg [11:0] env_step;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                   env_step <= 12'd0;
    else if(prepare_cnt_tcount_3 && state != S_OFF && generator_active) env_step <= env_step + 12'd1; //for attack,decay,release,sustain
end

//------------------------------------------------------------------------------ operate on attack

reg [19:0] attack_sum;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               attack_sum <= 20'd0;
    else if(prepare_cnt_attack_4)   attack_sum <= mult_result[35:16];                   //amp^2
    else if(prepare_cnt_attack_10)  attack_sum <= mult_result[35:16];                   //(3)
    else if(prepare_cnt_attack_14)  attack_sum <= attack_sum + mult_result_reg[35:16];  //(2)
    else if(prepare_cnt_attack_17)  attack_sum <= attack_sum + mult_result_reg[35:16];  //(1)
    else if(prepare_cnt_attack_18)  attack_sum <= attack_sum + 20'd154;                 //0.0377/16 *fixedpoint
end

reg [19:0] attack_amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   attack_amp <= 20'd0;
    else if(prepare_cnt_attack_22)                      attack_amp <= mult_result[35:16];
    else if(prepare_cnt_attack_23 && attack_value[16])  attack_amp <= attack_amp + { attack_sum[18:0], 1'b0 };
    else if(prepare_cnt_attack_24 && attack_value[17])  attack_amp <= attack_amp + { attack_sum[17:0], 2'b0 };
    else if(prepare_cnt_attack_25 && attack_value[18])  attack_amp <= attack_amp + { attack_sum[16:0], 3'b0 };
    else if(prepare_cnt_attack_26 && attack_value[19])  attack_amp <= attack_amp + { attack_sum[15:0], 4'b0 };
end

//

wire attack_step_active_1 = prepare_cnt_attack_29 && generator_active && (env_step & attack_mask) == 12'd0;
wire attack_step_active_2 = prepare_cnt_attack_30 && generator_active && (env_step & attack_mask) == 12'd0;

wire attack_step_finished = attack_step_active_2 && (amp >= 20'd65536 || attack_steps >= 7'd62);
wire attack_step_update   = attack_step_active_2 && (attack_skip_pos & attack_skip_mask) != 8'd0;

reg [7:0] attack_skip_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           attack_skip_pos <= 8'd0;
    else if(attack_step_active_1 && attack_skip_pos == 8'd0)    attack_skip_pos <= 8'd1;   
    else if(attack_step_active_1)                               attack_skip_pos <= { attack_skip_pos[6:0], attack_skip_pos[7] };
end

//------------------------------------------------------------------------------ operate on decay

wire [16:0] sustain_amp =
    (sustain_level == 4'd0)?    17'h10000 :
    (sustain_level == 4'd1)?    17'h0B504 :
    (sustain_level == 4'd2)?    17'h08000 :
    (sustain_level == 4'd3)?    17'h05A82 :
    (sustain_level == 4'd4)?    17'h04000 :
    (sustain_level == 4'd5)?    17'h02D41 :
    (sustain_level == 4'd6)?    17'h02000 :
    (sustain_level == 4'd7)?    17'h016A0 :
    (sustain_level == 4'd8)?    17'h01000 :
    (sustain_level == 4'd9)?    17'h00B50 :
    (sustain_level == 4'd10)?   17'h00800 :
    (sustain_level == 4'd11)?   17'h005A8 :
    (sustain_level == 4'd12)?   17'h00400 :
    (sustain_level == 4'd13)?   17'h002D4 :
    (sustain_level == 4'd14)?   17'h00200 :
                                17'h00000;

wire decay_step_active = prepare_cnt_decay_5 && generator_active && (env_step & decay_mask) == 12'd0;

wire decay_step_finish_to_sustain           = decay_step_active && amp <= { 3'b0, sustain_amp } && eg_type;
wire decay_step_finish_to_sustain_no_keep   = decay_step_active && amp <= { 3'b0, sustain_amp } && ~(eg_type);

//------------------------------------------------------------------------------ operate on release

wire release_step_active = prepare_cnt_release_5 && generator_active && (env_step & release_mask) == 12'd0;
wire release_step_finish = release_step_active && amp <= 20'd1;

//------------------------------------------------------------------------------ multiply unit

reg [17:0] mult_a;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               mult_a <= 18'd0;
    
    //attack
    else if(prepare_cnt_attack_1)   mult_a <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_4)   mult_a <= mult_result[33:16]; //amp^2
    else if(prepare_cnt_attack_7)   mult_a <= mult_result[33:16]; //amp^3
    else if(prepare_cnt_attack_10)  mult_a <= { 1'b0, attack_sum[16:0] };
    else if(prepare_cnt_attack_13)  mult_a <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_19)  mult_a <= { 2'b0, attack_value[15:0] };

    //decay
    else if(prepare_cnt_decay_1)    mult_a <= { 1'b0, amp[16:0] };
    
    //release
    else if(prepare_cnt_release_1)  mult_a <= { 1'b0, amp[16:0] };
    
    //output
    else if(prepare_cnt_output_5)   mult_a <= { waveform_value[16], waveform_value };
    else if(prepare_cnt_output_8)   mult_a <= mult_result[33:16];
    else if(prepare_cnt_output_11)  mult_a <= mult_result[33:16];
end

reg [17:0] mult_b;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               mult_b <= 18'd0;
    
    //attack
    else if(prepare_cnt_attack_1)   mult_b <= { 1'b0, amp[16:0] };
    else if(prepare_cnt_attack_7)   mult_b <= 18'd30392; //7.42/16 *fixedpoint
    else if(prepare_cnt_attack_10)  mult_b <= 18'h2E6E2; //-17.57/16 *fixedpoint
    else if(prepare_cnt_attack_13)  mult_b <= 18'd43950; //10.73/16 *fixedpoint
    else if(prepare_cnt_attack_19)  mult_b <= { 1'b0, attack_sum[16:0] };
    
    //decay
    else if(prepare_cnt_decay_1)    mult_b <= { 1'b0, decay_mul };
    
    //release
    else if(prepare_cnt_release_1)  mult_b <= { 1'b0, release_mul };
    
    //output
    else if(prepare_cnt_output_5)   mult_b <= { 1'b0, volume_frac };
    else if(prepare_cnt_output_8)   mult_b <= { 1'b0, step_amp };
    else if(prepare_cnt_output_11)  mult_b <= { 1'b0, tremolo_coeff };
end

wire [35:0] mult_result;

simple_mult #(
    .widtha (18),
    .widthb (18),
    .widthp (36)
)
operator_mult_inst (
    .clk    (clk),

    .a      (mult_a),      //input [17:0]
    .b      (mult_b),      //input [17:0]
    
    .out    (mult_result)  //output [35:0]
);

reg [35:0] mult_result_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   mult_result_reg <= 36'd0;
    else                mult_result_reg <= mult_result;
end

reg [16:0] step_amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       step_amp <= 17'd0;

    else if(attack_step_finished)           step_amp <= 17'd65536;
    else if(attack_step_update)             step_amp <= amp[16:0];
    
    else if(decay_step_finish_to_sustain)   step_amp <= sustain_amp;
    else if(decay_step_active)              step_amp <= amp[16:0];
    
    else if(release_step_finish)            step_amp <= 17'd0;
    else if(release_step_active)            step_amp <= amp[16:0];
end

reg [19:0] amp;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                           amp <= 20'd0;
    
    //attack
    else if(prepare_cnt_attack_27)                              amp <= amp + attack_amp;
    else if(prepare_cnt_attack_28 && amp > 20'd65536)           amp <= 20'd65537;
    else if(attack_step_finished)                               amp <= 20'd65536;
    
    //decay
    else if(prepare_cnt_decay_4 && amp > { 3'b0, sustain_amp }) amp <= mult_result[35:16];
    else if(decay_step_finish_to_sustain)                       amp <= { 3'b0, sustain_amp };
    
    //release
    else if(prepare_cnt_release_4 && amp > 20'd1)               amp <= mult_result[35:16];
    else if(release_step_finish)                                amp <= 20'd0;
end

//------------------------------------------------------------------------------ waveform

//mfbi: *2^(feedback+8)
//(lastcval + cval)*2^(feedback+7)

//input [2:0]   feedback,
//input [15:0]  modulator,
//      [25:0]  wfpos

wire [16:0] waveform_wfpos_plus_modulator = { 6'd0, wfpos[25:16] } + modulator;
wire [16:0] waveform_feedback_sum         = cval_last + cval;
wire [25:0] waveform_feedback_modulator =
    (feedback == 3'd1)?     { 2'b0, waveform_feedback_sum[15:0], 8'd0 } :
    (feedback == 3'd2)?     { 1'b0, waveform_feedback_sum[15:0], 9'd0 } :
    (feedback == 3'd3)?     {       waveform_feedback_sum[15:0], 10'd0 } :
    (feedback == 3'd4)?     {       waveform_feedback_sum[14:0], 11'd0 } :
    (feedback == 3'd5)?     {       waveform_feedback_sum[13:0], 12'd0 } :
    (feedback == 3'd6)?     {       waveform_feedback_sum[12:0], 13'd0 } :
                            {       waveform_feedback_sum[11:0], 14'd0 };
                            
reg [25:0] waveform_feedback_modulator_reg;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)   waveform_feedback_modulator_reg <= 26'd0;
    else                waveform_feedback_modulator_reg <= waveform_feedback_modulator;
end                            

wire [26:0] waveform_wfpos_plus_feedback = wfpos + waveform_feedback_modulator_reg;
    
reg [9:0] waveform_counter;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                   waveform_counter <= 10'd0; 
    else if(prepare_cnt_output_1 && feedback == 3'd0)   waveform_counter <= waveform_wfpos_plus_modulator[9:0];
    else if(prepare_cnt_output_1)                       waveform_counter <= waveform_wfpos_plus_feedback[25:16];
end

wire waveform_counter_reverse = (waveform_counter >= 10'd256 && waveform_counter <= 10'd511) || waveform_counter >= 10'd768;

reg [7:0] waveform_address;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && wave_select == 2'd1 && waveform_counter >= 10'd512) waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && wave_select == 2'd3 && waveform_counter_reverse)    waveform_address <= 8'd0;
    else if(prepare_cnt_output_2 && waveform_counter_reverse)                           waveform_address <= 8'd255 - waveform_counter[7:0];
    else if(prepare_cnt_output_2)                                                       waveform_address <= waveform_counter[7:0];
end

wire [15:0] waveform_q_negative = -wform_decrel_q;

reg [16:0] waveform_value;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                   waveform_value <= 17'd0;
    else if(prepare_cnt_output_4 && wave_select == 2'd0 && waveform_counter >= 10'd512) waveform_value <= { 1'b1, waveform_q_negative };
    else if(prepare_cnt_output_4)                                                       waveform_value <= { 1'b0, wform_decrel_q };
end

//------------------------------------------------------------------------------ tremolo

//TREMTAB_SIZE * TREM_FREQ * FIXED_LFO / f_s = 34270
reg [29:0] tremolo_pos;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               tremolo_pos <= 30'd0;
    else if(prepare_cnt_output_1)                                   tremolo_pos <= tremolo_pos + 30'd34270;
    else if(prepare_cnt_output_2 && tremolo_pos[29:24] == 6'd53)    tremolo_pos <= { 6'd0, tremolo_pos[23:0] };
end

wire [6:0] tremolo_idx =
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd13)?      7'd13 - { 1'b0, tremolo_pos[29:24] } :
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd40)?      { 1'b0, tremolo_pos[29:24] } - 7'd14 :
    (tremolo_depth    && tremolo_pos[29:24] <= 6'd52)?      7'd66 - { 1'b0, tremolo_pos[29:24] } :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd1)?       7'd3 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd5)?       7'd2 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd9)?       7'd1 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd17)?      7'd0 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd21)?      7'd1 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd25)?      7'd2 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd29)?      7'd3 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd33)?      7'd4 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd37)?      7'd5 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd42)?      7'd6 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd46)?      7'd5 :
    (~(tremolo_depth) && tremolo_pos[29:24] <= 6'd50)?      7'd4 :
                                                            7'd3;

wire [16:0] tremolo_48db =
    (tremolo_idx[4:0] == 5'd26)?    17'h9308 :
    (tremolo_idx[4:0] == 5'd25)?    17'h9633 :
    (tremolo_idx[4:0] == 5'd24)?    17'h9970 :
    (tremolo_idx[4:0] == 5'd23)?    17'h9CBF :
    (tremolo_idx[4:0] == 5'd22)?    17'hA020 :
    (tremolo_idx[4:0] == 5'd21)?    17'hA394 :
    (tremolo_idx[4:0] == 5'd20)?    17'hA71B :
    (tremolo_idx[4:0] == 5'd19)?    17'hAAB5 :
    (tremolo_idx[4:0] == 5'd18)?    17'hAE63 :
    (tremolo_idx[4:0] == 5'd17)?    17'hB225 :
    (tremolo_idx[4:0] == 5'd16)?    17'hB5FC :
    (tremolo_idx[4:0] == 5'd15)?    17'hB9E8 :
    (tremolo_idx[4:0] == 5'd14)?    17'hBDEA :
    (tremolo_idx[4:0] == 5'd13)?    17'hC203 :
    (tremolo_idx[4:0] == 5'd12)?    17'hC631 :
    (tremolo_idx[4:0] == 5'd11)?    17'hCA77 :
    (tremolo_idx[4:0] == 5'd10)?    17'hCED4 :
    (tremolo_idx[4:0] == 5'd9)?     17'hD34A :
    (tremolo_idx[4:0] == 5'd8)?     17'hD7D8 :
    (tremolo_idx[4:0] == 5'd7)?     17'hDC7F :
    (tremolo_idx[4:0] == 5'd6)?     17'hE140 :
    (tremolo_idx[4:0] == 5'd5)?     17'hE61B :
    (tremolo_idx[4:0] == 5'd4)?     17'hEB10 :
    (tremolo_idx[4:0] == 5'd3)?     17'hF022 :
    (tremolo_idx[4:0] == 5'd2)?     17'hF54F :
    (tremolo_idx[4:0] == 5'd1)?     17'hFA99 :
                                    17'h10000;

wire [16:0] tremolo_12db =
    (tremolo_idx[4:0] == 5'd6)?     17'hDEDC :
    (tremolo_idx[4:0] == 5'd5)?     17'hE411 :
    (tremolo_idx[4:0] == 5'd4)?     17'hE966 :
    (tremolo_idx[4:0] == 5'd3)?     17'hEEDB :
    (tremolo_idx[4:0] == 5'd2)?     17'hF470 :
    (tremolo_idx[4:0] == 5'd1)?     17'hFA27 :
                                    17'h10000;

reg [16:0] tremolo_coeff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                               tremolo_coeff <= 17'd0;
    else if(prepare_cnt_output_3 && ~(tremolo))     tremolo_coeff <= 17'h10000;
    else if(prepare_cnt_output_3 && tremolo_depth)  tremolo_coeff <= tremolo_48db;
    else if(prepare_cnt_output_3)                   tremolo_coeff <= tremolo_12db;
end

//------------------------------------------------------------------------------

wire [15:0] cval_shifted =
    (volume_int == 4'd1)?   { 1'b0,  cval[15:1] } :
    (volume_int == 4'd2)?   { 2'b0,  cval[15:2] } :
    (volume_int == 4'd3)?   { 3'b0,  cval[15:3] } :
    (volume_int == 4'd4)?   { 4'b0,  cval[15:4] } :
    (volume_int == 4'd5)?   { 5'b0,  cval[15:5] } :
    (volume_int == 4'd6)?   { 6'b0,  cval[15:6] } :
    (volume_int == 4'd7)?   { 7'b0,  cval[15:7] } :
    (volume_int == 4'd8)?   { 8'b0,  cval[15:8] } :
    (volume_int == 4'd9)?   { 9'b0,  cval[15:9] } :
    (volume_int == 4'd10)?  { 10'b0, cval[15:10] } :
    (volume_int == 4'd11)?  { 11'b0, cval[15:11] } :
    (volume_int == 4'd12)?  { 12'b0, cval[15:12] } :
    (volume_int == 4'd13)?  { 13'b0, cval[15:13] } :
                                     cval;

reg [15:0] cval_last;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               cval_last <= 16'd0;
    else if(prepare_cnt_output_13)  cval_last <= cval;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               cval <= 16'd0;
    else if(prepare_cnt_output_14)  cval <= mult_result[33:18];
    else if(prepare_cnt_output_15)  cval <= (state == S_OFF)? 16'd0 : cval_shifted;
end

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0,
    release_steps[1:0], decay_steps[1:0], mult_result_reg[15:0],
    waveform_wfpos_plus_modulator[16:10], waveform_feedback_sum[16],
    waveform_wfpos_plus_feedback[26], waveform_wfpos_plus_feedback[15:0],
    tremolo_idx[6:5],
    1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

endmodule

module sound_opl2_channel(
    input                   clk,
    input                   rst_n,
    
    input                   write_20h_35h_op1,
    input                   write_40h_55h_op1,
    input                   write_60h_75h_op1,
    input                   write_80h_95h_op1,
    input                   write_E0h_F5h_op1,
    
    input                   write_20h_35h_op2,
    input                   write_40h_55h_op2,
    input                   write_60h_75h_op2,
    input                   write_80h_95h_op2,
    input                   write_E0h_F5h_op2,
    
    input                   write_A0h_A8h,
    input                   write_B0h_B8h,
    input                   write_C0h_C8h,
    
    input           [7:0]   writedata,
    
    input                   vibrato_depth,
    input                   tremolo_depth,
    input                   waveform_select_enable,
    input                   keyboard_split,
    
    input           [6:0]   prepare_cnt,
    
    input                   rythm_enable,
    input                   rythm_write,
    input                   rythm_bass_drum,
    input                   rythm_snare_drum,
    input                   rythm_tom_tom,
    input                   rythm_cymbal,
    input                   rythm_hi_hat,
    
    input                   channel_6,
    input                   channel_7,
    input                   channel_8,
    
    output                  rythm_c1,
    output                  rythm_c3,  
    input                   rythm_phasebit,
    input                   rythm_noisebit,
    
    output reg      [15:0]  chanval
);

//------------------------------------------------------------------------------

reg [9:0] await_f_number;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_f_number <= 10'd0;
    else if(write_A0h_A8h)  await_f_number <= { f_number[9:8], writedata };
    else if(write_B0h_B8h)  await_f_number <= { writedata[1:0], f_number[7:0] };
end

//reg await_key_on; write_B0h_B8h; writedata[5]

reg [2:0] await_octave;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_octave <= 3'd0;
    else if(write_B0h_B8h)  await_octave <= writedata[4:2];
end

reg [2:0] await_feedback;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_feedback <= 3'd0;
    else if(write_C0h_C8h)  await_feedback <= writedata[3:1];
end

reg await_no_modulation;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)       await_no_modulation <= 1'b0;
    else if(write_C0h_C8h)  await_no_modulation <= writedata[0];
end

//------------------------------------------------------------------------------

wire prepare_cnt_load_regs = prepare_cnt == 7'd2;

reg [9:0] f_number;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               f_number <= 10'd0;
    else if(prepare_cnt_load_regs)  f_number <= await_f_number;
end

//reg key_on;

reg [2:0] octave;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               octave <= 3'd0;
    else if(prepare_cnt_load_regs)  octave <= await_octave;
end

reg [2:0] feedback;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               feedback <= 3'd0;
    else if(prepare_cnt_load_regs)  feedback <= await_feedback;
end

reg no_modulation;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)               no_modulation <= 1'b0;
    else if(prepare_cnt_load_regs)  no_modulation <= await_no_modulation;
end

//------------------------------------------------------------------------------

wire enable_normal_a     = write_B0h_B8h && writedata[5];
wire disable_normal_a    = write_B0h_B8h && ~(writedata[5]);

wire enable_rythm_a      = rythm_write && ((channel_6 &&   rythm_bass_drum)  || (channel_7 &&   rythm_hi_hat)  || (channel_8 &&   rythm_tom_tom));
wire disable_percussion_a= rythm_write && ((channel_6 && ~(rythm_bass_drum)) || (channel_7 && ~(rythm_hi_hat)) || (channel_8 && ~(rythm_tom_tom)));

wire enable_normal_b     = write_B0h_B8h && writedata[5];
wire disable_normal_b    = write_B0h_B8h && ~(writedata[5]);

wire enable_rythm_b      = rythm_write && ((channel_6 &&   rythm_bass_drum)  || (channel_7 &&   rythm_snare_drum)  || (channel_8 &&   rythm_cymbal));
wire disable_percussion_b= rythm_write && ((channel_6 && ~(rythm_bass_drum)) || (channel_7 && ~(rythm_snare_drum)) || (channel_8 && ~(rythm_cymbal)));

//------------------------------------------------------------------------------

wire prepare_cnt_chanval_1 = prepare_cnt == 7'd110;
wire prepare_cnt_chanval_2 = prepare_cnt == 7'd111;

//------------------------------------------------------------------------------

wire [14:0] cval_op_b_times_2 = (cval_op_b[15] == 1'b0 && cval_op_b > 16'h3FFF)? 15'h3FFF : (cval_op_b[15] == 1'b1 && cval_op_b < 16'hC000)? 15'h4000 : cval_op_b[14:0];
wire [14:0] cval_op_a_times_2 = (cval_op_a[15] == 1'b0 && cval_op_a > 16'h3FFF)? 15'h3FFF : (cval_op_a[15] == 1'b1 && cval_op_a < 16'hC000)? 15'h4000 : cval_op_a[14:0];

wire [16:0] cval_op_a_times_2_sum   = chanval + { cval_op_a_times_2, 1'b0 };
wire [15:0] cval_op_a_times_2_final =
    (cval_op_a_times_2_sum[16] == 1'b1 && chanval[15] == 1'b0 && cval_op_a_times_2[14] == 1'b0)?    16'h7FFF :
    (cval_op_a_times_2_sum[16] == 1'b0 && chanval[15] == 1'b1 && cval_op_a_times_2[14] == 1'b1)?    16'h8000 :
                                                                                                    cval_op_a_times_2_sum[15:0];
wire [16:0] cval_op_a_sum   = chanval + cval_op_a;
wire [15:0] cval_op_a_final =
    (cval_op_a_sum[16] == 1'b1 && chanval[15] == 1'b0 && cval_op_a[14] == 1'b0)?    16'h7FFF :
    (cval_op_a_sum[16] == 1'b0 && chanval[15] == 1'b1 && cval_op_a[14] == 1'b1)?    16'h8000 :
                                                                                    cval_op_a_sum[15:0];

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                                                                                       chanval <= 16'd0;
    
    else if(prepare_cnt_chanval_1 && rythm_enable && channel_6)                                                             chanval <= { cval_op_b_times_2, 1'b0 };
    else if(prepare_cnt_chanval_1 && rythm_enable && (channel_7 || channel_8))                                              chanval <= { cval_op_b_times_2, 1'b0 };
    else if(prepare_cnt_chanval_2 && rythm_enable && (channel_7 || channel_8))                                              chanval <= cval_op_a_times_2_final;
    
    else if(prepare_cnt_chanval_1 && (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))))                   chanval <= cval_op_b;
    else if(prepare_cnt_chanval_2 && (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))) && no_modulation)  chanval <= cval_op_a_final;
    
    else if(prepare_cnt_chanval_1)                                                                                          chanval <= 16'd0;
end

wire modulate_with_feedback =
    (rythm_enable && channel_6 && ~(no_modulation)) ||
    (~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8)));

wire modulate_op_b =
    (rythm_enable && channel_6 && ~(no_modulation)) ||
    ((~(rythm_enable) || (~(channel_6) && ~(channel_7) && ~(channel_8))) && ~(no_modulation));

wire [15:0] modulator_b = (modulate_op_b)? cval_op_a : 16'd0;

wire [2:0] feedback_a   = (modulate_with_feedback)? feedback : 3'd0;


//------------------------------------------------------------------------------

//6.0 drum bass
//6.1 drum bass
//7.0 hi hat
//7.1 snare
//8.0 tom tom
//8.1 cymbal

//------------------------------------------------------------------------------

wire [16:0] freq_and_octave =
    (octave == 3'd0)?   { 7'd0, f_number } :
    (octave == 3'd1)?   { 6'd0, f_number, 1'd0 } :
    (octave == 3'd2)?   { 5'd0, f_number, 2'd0 } :
    (octave == 3'd3)?   { 4'd0, f_number, 3'd0 } :
    (octave == 3'd4)?   { 3'd0, f_number, 4'd0 } :
    (octave == 3'd5)?   { 2'd0, f_number, 5'd0 } :
    (octave == 3'd6)?   { 1'd0, f_number, 6'd0 } :
                        {       f_number, 7'd0 };

//------------------------------------------------------------------------------

wire wform_decrel_request_a;
wire wform_decrel_request_b;

wire [7:0]  wform_decrel_address_a;
wire [7:0]  wform_decrel_address_b;

wire [15:0] wform_decrel_q_a;
wire [15:0] wform_decrel_q_b;

simple_rom_0 #(
    .widthad    (9),
    .width      (16),
    .datafile   ("./designs/sound/src/opl2_waveform_rom.hex")
)
waveform_rom_inst (
    .clk        (clk),
    
    .addr_a     ({ wform_decrel_request_a, wform_decrel_address_a }),
    .addr_b     ({ wform_decrel_request_b, wform_decrel_address_b }),
    .q_a        (wform_decrel_q_a),
    .q_b        (wform_decrel_q_b)
);

//------------------------------------------------------------------------------

wire [7:0] attack_address_a;
wire [7:0] attack_address_b;

wire [19:0] attack_value_a;
wire [19:0] attack_value_b;

simple_rom_1 #(
    .widthad    (8),
    .width      (20),
    .datafile   ("./designs/sound/src/opl2_attack_rom.hex")
)
attack_rom_inst (
    .clk        (clk),
    
    .addr_a     (attack_address_a),
    .addr_b     (attack_address_b),
    
    .q_a        (attack_value_a),
    .q_b        (attack_value_b)
);

//------------------------------------------------------------------------------
    
wire [15:0] cval_op_a;
wire [15:0] cval_op_b;

wire rythm_c2;

sound_opl2_operator op1_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h          (write_20h_35h_op1),        //input
    .write_40h_55h          (write_40h_55h_op1),        //input
    .write_60h_75h          (write_60h_75h_op1),        //input
    .write_80h_95h          (write_80h_95h_op1),        //input
    .write_E0h_F5h          (write_E0h_F5h_op1),        //input
    
    .writedata              (writedata),                //input [7:0]
    
    .freq_and_octave        (freq_and_octave),          //input [16:0]
    .freq_high              (f_number[9:6]),            //input [3:0]
    .octave                 (octave),                   //input [2:0]
    .feedback               (feedback_a),               //input [2:0]
   
    .vibrato_depth          (vibrato_depth),            //input
    .tremolo_depth          (tremolo_depth),            //input

    .wform_decrel_request   (wform_decrel_request_a),   //output
    .wform_decrel_address   (wform_decrel_address_a),   //output [7:0]
    .wform_decrel_q         (wform_decrel_q_a),         //input [15:0]
    
    .waveform_select_enable (waveform_select_enable),   //input
    
    .cval                   (cval_op_a),                //output [15:0]
    .keyboard_split         (keyboard_split),           //input

    .attack_address         (attack_address_a),         //output [7:0]
    .attack_value           (attack_value_a),           //input [19:0]
    
    .prepare_cnt            (prepare_cnt),              //input [6:0]
    
    .enable_normal          (enable_normal_a),          //input
    .enable_rythm           (enable_rythm_a),           //input
    .disable_normal         (disable_normal_a),         //input
    .disable_percussion     (disable_percussion_a),     //input
    
    .rythm_c1               (rythm_c1),                 //output
    .rythm_c2               (rythm_c2),                 //output
    /* verilator lint_off PINNOCONNECT */
    .rythm_c3               (),                         //output / not used
    /* verilator lint_on PINNOCONNECT */
    
    .rythm_phasebit         (rythm_phasebit),           //input
    .rythm_noisebit         (rythm_noisebit),           //input
    .rythm_snarebit         (1'b0),                     //input
    
    .rythm_hihat            (channel_7),                //input
    .rythm_snare            (1'b0),                     //input
    .rythm_cymbal           (1'b0),                     //input
    
    .operator_a             (1'b1),                     //input
    .operator_b             (1'b0),                     //input
    
    .modulator              (16'd0)                     //input [15:0]
);

sound_opl2_operator op2_inst(
    .clk                    (clk),
    .rst_n                  (rst_n),
    
    .write_20h_35h          (write_20h_35h_op2),        //input
    .write_40h_55h          (write_40h_55h_op2),        //input
    .write_60h_75h          (write_60h_75h_op2),        //input
    .write_80h_95h          (write_80h_95h_op2),        //input
    .write_E0h_F5h          (write_E0h_F5h_op2),        //input
    
    .writedata              (writedata),                //input [7:0]
   
    .freq_and_octave        (freq_and_octave),          //input [16:0]
    .freq_high              (f_number[9:6]),            //input [3:0]
    .octave                 (octave),                   //input [2:0]
    .feedback               (3'd0),                     //input [2:0]
    
    .vibrato_depth          (vibrato_depth),            //input
    .tremolo_depth          (tremolo_depth),            //input
    
    .wform_decrel_request   (wform_decrel_request_b),   //output
    .wform_decrel_address   (wform_decrel_address_b),   //output [7:0]
    .wform_decrel_q         (wform_decrel_q_b),         //input [15:0]
    
    .waveform_select_enable (waveform_select_enable),   //input
    
    .cval                   (cval_op_b),                //output [15:0]
    .keyboard_split         (keyboard_split),           //input
    
    .attack_address         (attack_address_b),         //output [7:0]
    .attack_value           (attack_value_b),           //input [19:0]
    
    .prepare_cnt            (prepare_cnt),              //input [6:0]
    
    .enable_normal          (enable_normal_b),          //input
    .enable_rythm           (enable_rythm_b),           //input
    .disable_normal         (disable_normal_b),         //input
    .disable_percussion     (disable_percussion_b),     //input
    
    /* verilator lint_off PINNOCONNECT */
    .rythm_c1               (),                         //output / not used
    .rythm_c2               (),                         //output / not used
    /* verilator lint_on PINNOCONNECT */
    .rythm_c3               (rythm_c3),                 //output
    
    .rythm_phasebit         (rythm_phasebit),           //input
    .rythm_noisebit         (rythm_noisebit),           //input
    .rythm_snarebit         (rythm_c2),                 //input
    
    .rythm_hihat            (1'b0),                     //input
    .rythm_snare            (channel_7),                //input
    .rythm_cymbal           (channel_8),                //input
    
    .operator_a             (1'b0),                     //input
    .operator_b             (1'b1),                     //input
    
    .modulator              (modulator_b)               //input [15:0]
);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

endmodule

/*
simple_single_rom #(
    .widthad    (10),
    .width      (8),
    .datafile   ("dsp_dma_identification_rom.hex")
)
dma_id_rom_inst (
    .clk        (clk),
    
    .addr       ({dma_id_count, io_writedata}),
    .q          (dma_id_q)
);

simple_rom #(
    .widthad    (9),
    .width      (16),
    .datafile   ("opl2_waveform_rom.hex")
)
waveform_rom_inst (
    .clk        (clk),
    
    .addr_a     ({ wform_decrel_request_a, wform_decrel_address_a }),
    .addr_b     ({ wform_decrel_request_b, wform_decrel_address_b }),
    .q_a        (wform_decrel_q_a),
    .q_b        (wform_decrel_q_b)
);

simple_rom #(
    .widthad    (8),
    .width      (20),
    .datafile   ("opl2_attack_rom.hex")
)
attack_rom_inst (
    .clk        (clk),
    
    .addr_a     (attack_address_a),
    .addr_b     (attack_address_b),
    
    .q_a        (attack_value_a),
    .q_b        (attack_value_b)
);
*/

module simple_single_rom(
    input                       clk,
    
    input       [widthad-1:0]   addr,
    output reg  [width-1:0]     q
);

parameter width     = 8;
parameter widthad   = 10;
parameter datafile  = "./designs/sound/src/dsp_dma_identification_rom.hex";

reg [width-1:0] mem [(2**widthad)-1:0];

initial
begin
$readmemb(datafile, mem);
end

always @(posedge clk) begin
    q <= mem[addr];
end

endmodule

module simple_rom_0(
    input                       clk,
    
    input       [widthad-1:0]   addr_a,
    output reg  [width-1:0]     q_a,
    
    input       [widthad-1:0]   addr_b,
    output reg  [width-1:0]     q_b
);

parameter width     = 16;
parameter widthad   = 9;
parameter datafile  = "./designs/sound/src/opl2_waveform_rom.hex";

reg [width-1:0] mem [(2**widthad)-1:0];

initial
begin
$readmemh(datafile, mem);
end

always @(posedge clk) begin
    q_a <= mem[addr_a];
    q_b <= mem[addr_b];
end

endmodule
module simple_rom_1(
    input                       clk,
    
    input       [widthad-1:0]   addr_a,
    output reg  [width-1:0]     q_a,
    
    input       [widthad-1:0]   addr_b,
    output reg  [width-1:0]     q_b
);

parameter width     = 20;
parameter widthad   = 8;
parameter datafile  = "./designs/sound/src/opl2_attack_rom.hex";

reg [width-1:0] mem [(2**widthad)-1:0];

initial
begin
$readmemh(datafile, mem);
end

always @(posedge clk) begin
    q_a <= mem[addr_a];
    q_b <= mem[addr_b];
end

endmodule
module simple_ram(
    input                       clk,
    
    input       [widthad-1:0]   wraddress,
    input                       wren,
    input       [width-1:0]     data,
    
    input       [widthad-1:0]   rdaddress,
    output reg  [width-1:0]     q
);
parameter width     = 1;
parameter widthad   = 1;

reg [width-1:0] mem [(2**widthad)-1:0];

always @(posedge clk) begin
    if(wren) mem[wraddress] <= data;
    
    q <= mem[rdaddress];
end

endmodule
module simple_mult(
    input                           clk,
    input signed    [widtha-1:0]    a,
    input signed    [widthb-1:0]    b,
    output          [widthp-1:0]    out
);

//------------------------------------------------------------------------------

parameter widtha = 1;
parameter widthb = 1;
parameter widthp = 2;

//------------------------------------------------------------------------------

reg signed [widtha-1:0] a_reg;
reg signed [widthb-1:0] b_reg;
reg signed [widthp-1:0] out_1;

assign out = out_1;

wire signed [widthp-1:0] mult_out;
assign mult_out = a_reg * b_reg;

always @ (posedge clk)
begin
    a_reg   <= a;
    b_reg   <= b;
    out_1   <= mult_out;
end

//------------------------------------------------------------------------------

endmodule
