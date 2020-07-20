//======================================================================
//
// blabla_core.v
// --------------
// Verilog 2001 implementation of the stream cipher BlaBla.
// This is the internal core with wide interfaces.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2017 Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module blabla(
                   input wire            clk,
                   input wire            reset_n,

                   input wire            init,
                   input wire            next,

                   input wire [255 : 0]  key,
                   input wire            keylen,
                   input wire [63 : 0]   iv,
                   input wire [63 : 0]   ctr,
                   input wire [4 : 0]    rounds,

                   input wire [511 : 0]  data_in,

                   output wire           ready,

                   output wire [511 : 0] data_out,
                   output wire           data_out_valid
                  );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  // Datapath quartterround states names.
  localparam QR0 = 0;
  localparam QR1 = 1;

  localparam NUM_ROUNDS = 4'h8;

  localparam TAU0 = 32'h61707865;
  localparam TAU1 = 32'h3120646e;
  localparam TAU2 = 32'h79622d36;
  localparam TAU3 = 32'h6b206574;

  localparam SIGMA0 = 32'h61707865;
  localparam SIGMA1 = 32'h3320646e;
  localparam SIGMA2 = 32'h79622d32;
  localparam SIGMA3 = 32'h6b206574;

  localparam CTRL_IDLE     = 3'h0;
  localparam CTRL_INIT     = 3'h1;
  localparam CTRL_ROUNDS   = 3'h2;
  localparam CTRL_FINALIZE = 3'h3;
  localparam CTRL_DONE     = 3'h4;


  //----------------------------------------------------------------
  // l2b()
  //
  // Swap bytes from little to big endian byte order.
  //----------------------------------------------------------------
  function [31 : 0] l2b(input [31 : 0] op);
    begin
      l2b = {op[7 : 0], op[15 : 8], op[23 : 16], op[31 : 24]};
    end
  endfunction // b2l


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0]  state_reg [0 : 15];
  reg [63 : 0]  state_new [0 : 15];
  reg           state_we;

  reg [511 : 0] data_out_reg;
  reg [511 : 0] data_out_new;

  reg           data_out_valid_reg;
  reg           data_out_valid_new;
  reg           data_out_valid_we;

  reg           qr_ctr_reg;
  reg           qr_ctr_new;
  reg           qr_ctr_we;
  reg           qr_ctr_inc;
  reg           qr_ctr_rst;

  reg [3 : 0]   dr_ctr_reg;
  reg [3 : 0]   dr_ctr_new;
  reg           dr_ctr_we;
  reg           dr_ctr_inc;
  reg           dr_ctr_rst;

  reg [31 : 0]  block0_ctr_reg;
  reg [31 : 0]  block0_ctr_new;
  reg           block0_ctr_we;
  reg [31 : 0]  block1_ctr_reg;
  reg [31 : 0]  block1_ctr_new;
  reg           block1_ctr_we;
  reg           block_ctr_inc;
  reg           block_ctr_set;

  reg           ready_reg;
  reg           ready_new;
  reg           ready_we;

  reg [2 : 0]   blabla_ctrl_reg;
  reg [2 : 0]   blabla_ctrl_new;
  reg           blabla_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] init_state_word [0 : 15];

  reg init_state;
  reg update_state;
  reg update_output;

  reg  [63 : 0] qr0_a;
  reg  [63 : 0] qr0_b;
  reg  [63 : 0] qr0_c;
  reg  [63 : 0] qr0_d;
  wire [63 : 0] qr0_a_prim;
  wire [63 : 0] qr0_b_prim;
  wire [63 : 0] qr0_c_prim;
  wire [63 : 0] qr0_d_prim;
  reg  [63 : 0] qr1_a;
  reg  [63 : 0] qr1_b;
  reg  [63 : 0] qr1_c;
  reg  [63 : 0] qr1_d;
  wire [63 : 0] qr1_a_prim;
  wire [63 : 0] qr1_b_prim;
  wire [63 : 0] qr1_c_prim;
  wire [63 : 0] qr1_d_prim;
  reg  [63 : 0] qr2_a;
  reg  [63 : 0] qr2_b;
  reg  [63 : 0] qr2_c;
  reg  [63 : 0] qr2_d;
  wire [63 : 0] qr2_a_prim;
  wire [63 : 0] qr2_b_prim;
  wire [63 : 0] qr2_c_prim;
  wire [63 : 0] qr2_d_prim;
  reg  [63 : 0] qr3_a;
  reg  [63 : 0] qr3_b;
  reg  [63 : 0] qr3_c;
  reg  [63 : 0] qr3_d;
  wire [63 : 0] qr3_a_prim;
  wire [63 : 0] qr3_b_prim;
  wire [63 : 0] qr3_c_prim;
  wire [63 : 0] qr3_d_prim;


  //----------------------------------------------------------------
  // Instantiation of the qr modules.
  //----------------------------------------------------------------
  blabla_qr qr0(
                .a(qr0_a),
                .b(qr0_b),
                .c(qr0_c),
                .d(qr0_d),

                .a_prim(qr0_a_prim),
                .b_prim(qr0_b_prim),
                .c_prim(qr0_c_prim),
                .d_prim(qr0_d_prim)
               );

  blabla_qr qr1(
                .a(qr1_a),
                .b(qr1_b),
                .c(qr1_c),
                .d(qr1_d),

                .a_prim(qr1_a_prim),
                .b_prim(qr1_b_prim),
                .c_prim(qr1_c_prim),
                .d_prim(qr1_d_prim)
               );

  blabla_qr qr2(
                .a(qr2_a),
                .b(qr2_b),
                .c(qr2_c),
                .d(qr2_d),

                .a_prim(qr2_a_prim),
                .b_prim(qr2_b_prim),
                .c_prim(qr2_c_prim),
                .d_prim(qr2_d_prim)
               );

  blabla_qr qr3(
                .a(qr3_a),
                .b(qr3_b),
                .c(qr3_c),
                .d(qr3_d),

                .a_prim(qr3_a_prim),
                .b_prim(qr3_b_prim),
                .c_prim(qr3_c_prim),
                .d_prim(qr3_d_prim)
               );


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign data_out       = data_out_reg;
  assign data_out_valid = data_out_valid_reg;
  assign ready          = ready_reg;


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
     integer i;

      if (!reset_n)
        begin
          for (i = 0 ; i < 16 ; i = i + 1)
            state_reg[i] <= 32'h0;

          data_out_reg       <= 512'h0;
          data_out_valid_reg <= 0;
          qr_ctr_reg         <= QR0;
          dr_ctr_reg         <= 0;
          block0_ctr_reg     <= 32'h0;
          block1_ctr_reg     <= 32'h0;
          blabla_ctrl_reg    <= CTRL_IDLE;
          ready_reg          <= 1;
        end
      else
        begin
          if (state_we)
            begin
              for (i = 0 ; i < 16 ; i = i + 1)
                state_reg[i] <= state_new[i];
            end

          if (update_output)
            data_out_reg <= data_out_new;

          if (data_out_valid_we)
            data_out_valid_reg <= data_out_valid_new;

          if (qr_ctr_we)
            qr_ctr_reg <= qr_ctr_new;

          if (dr_ctr_we)
            dr_ctr_reg <= dr_ctr_new;

          if (block0_ctr_we)
            block0_ctr_reg <= block0_ctr_new;

          if (block1_ctr_we)
            block1_ctr_reg <= block1_ctr_new;

          if (ready_we)
            ready_reg <= ready_new;

          if (blabla_ctrl_we)
            blabla_ctrl_reg <= blabla_ctrl_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // init_state_logic
  //
  // Calculates the initial state for a given block.
  //----------------------------------------------------------------
  always @*
    begin : init_state_logic
      reg [31 : 0] key0;
      reg [31 : 0] key1;
      reg [31 : 0] key2;
      reg [31 : 0] key3;
      reg [31 : 0] key4;
      reg [31 : 0] key5;
      reg [31 : 0] key6;
      reg [31 : 0] key7;

      key0 = l2b(key[255 : 224]);
      key1 = l2b(key[223 : 192]);
      key2 = l2b(key[191 : 160]);
      key3 = l2b(key[159 : 128]);
      key4 = l2b(key[127 :  96]);
      key5 = l2b(key[95  :  64]);
      key6 = l2b(key[63  :  32]);
      key7 = l2b(key[31  :   0]);

      init_state_word[04] = key0;
      init_state_word[05] = key1;
      init_state_word[06] = key2;
      init_state_word[07] = key3;
      init_state_word[12] = block0_ctr_reg;
      init_state_word[13] = block1_ctr_reg;
      init_state_word[14] = l2b(iv[63 : 32]);
      init_state_word[15] = l2b(iv[31 :  0]);

      if (keylen)
        begin
          // 256 bit key.
          init_state_word[00] = SIGMA0;
          init_state_word[01] = SIGMA1;
          init_state_word[02] = SIGMA2;
          init_state_word[03] = SIGMA3;
          init_state_word[08] = key4;
          init_state_word[09] = key5;
          init_state_word[10] = key6;
          init_state_word[11] = key7;
        end
      else
        begin
          // 128 bit key.
          init_state_word[00] = TAU0;
          init_state_word[01] = TAU1;
          init_state_word[02] = TAU2;
          init_state_word[03] = TAU3;
          init_state_word[08] = key0;
          init_state_word[09] = key1;
          init_state_word[10] = key2;
          init_state_word[11] = key3;
        end
    end


  //----------------------------------------------------------------
  // state_logic
  // Logic to init and update the internal state.
  //----------------------------------------------------------------
  always @*
    begin : state_logic
      integer i;

      for (i = 0 ; i < 16 ; i = i + 1)
        state_new[i] = 64'h0;
      state_we = 0;

      qr0_a = 64'h0;
      qr0_b = 64'h0;
      qr0_c = 64'h0;
      qr0_d = 64'h0;
      qr1_a = 64'h0;
      qr1_b = 64'h0;
      qr1_c = 64'h0;
      qr1_d = 64'h0;
      qr2_a = 64'h0;
      qr2_b = 64'h0;
      qr2_c = 64'h0;
      qr2_d = 64'h0;
      qr3_a = 64'h0;
      qr3_b = 64'h0;
      qr3_c = 64'h0;
      qr3_d = 64'h0;

      if (init_state)
        begin
          for (i = 0 ; i < 16 ; i = i + 1)
            state_new[i] = init_state_word[i];
          state_we   = 1;
        end // if (init_state)

      if (update_state)
        begin
          state_we = 1;
          case (qr_ctr_reg)
            QR0:
              begin
                qr0_a = state_reg[00];
                qr0_b = state_reg[04];
                qr0_c = state_reg[08];
                qr0_d = state_reg[12];
                qr1_a = state_reg[01];
                qr1_b = state_reg[05];
                qr1_c = state_reg[09];
                qr1_d = state_reg[13];
                qr2_a = state_reg[02];
                qr2_b = state_reg[06];
                qr2_c = state_reg[10];
                qr2_d = state_reg[14];
                qr3_a = state_reg[03];
                qr3_b = state_reg[07];
                qr3_c = state_reg[11];
                qr3_d = state_reg[15];
                state_new[00] = qr0_a_prim;
                state_new[04] = qr0_b_prim;
                state_new[08] = qr0_c_prim;
                state_new[12] = qr0_d_prim;
                state_new[01] = qr1_a_prim;
                state_new[05] = qr1_b_prim;
                state_new[09] = qr1_c_prim;
                state_new[13] = qr1_d_prim;
                state_new[02] = qr2_a_prim;
                state_new[06] = qr2_b_prim;
                state_new[10] = qr2_c_prim;
                state_new[14] = qr2_d_prim;
                state_new[03] = qr3_a_prim;
                state_new[07] = qr3_b_prim;
                state_new[11] = qr3_c_prim;
                state_new[15] = qr3_d_prim;
              end

            QR1:
              begin
                qr0_a = state_reg[00];
                qr0_b = state_reg[05];
                qr0_c = state_reg[10];
                qr0_d = state_reg[15];
                qr1_a = state_reg[01];
                qr1_b = state_reg[06];
                qr1_c = state_reg[11];
                qr1_d = state_reg[12];
                qr2_a = state_reg[02];
                qr2_b = state_reg[07];
                qr2_c = state_reg[08];
                qr2_d = state_reg[13];
                qr3_a = state_reg[03];
                qr3_b = state_reg[04];
                qr3_c = state_reg[09];
                qr3_d = state_reg[14];
                state_new[00] = qr0_a_prim;
                state_new[05] = qr0_b_prim;
                state_new[10] = qr0_c_prim;
                state_new[15] = qr0_d_prim;
                state_new[01] = qr1_a_prim;
                state_new[06] = qr1_b_prim;
                state_new[11] = qr1_c_prim;
                state_new[12] = qr1_d_prim;
                state_new[02] = qr2_a_prim;
                state_new[07] = qr2_b_prim;
                state_new[08] = qr2_c_prim;
                state_new[13] = qr2_d_prim;
                state_new[03] = qr3_a_prim;
                state_new[04] = qr3_b_prim;
                state_new[09] = qr3_c_prim;
                state_new[14] = qr3_d_prim;
              end
          endcase // case (quarterround_select)
        end // if (update_state)
    end // state_logic


  //----------------------------------------------------------------
  // data_out_logic
  // Final output logic that combines the result from state
  // update with the input block. This adds a 16 rounds and
  // a final layer of XOR gates.
  //
  // Note that we also remap all the words into LSB format.
  //----------------------------------------------------------------
  always @*
    begin : data_out_logic
      integer i;
      reg [31 : 0] msb_block_state [0 : 15];
      reg [31 : 0] lsb_block_state [0 : 15];
      reg [511 : 0] block_state;

      for (i = 0 ; i < 16 ; i = i + 1)
        begin
          msb_block_state[i] = init_state_word[i] + state_reg[i];
          lsb_block_state[i] = l2b(msb_block_state[i][31 : 0]);
        end

      block_state = {lsb_block_state[00], lsb_block_state[01],
                     lsb_block_state[02], lsb_block_state[03],
                     lsb_block_state[04], lsb_block_state[05],
                     lsb_block_state[06], lsb_block_state[07],
                     lsb_block_state[08], lsb_block_state[09],
                     lsb_block_state[10], lsb_block_state[11],
                     lsb_block_state[12], lsb_block_state[13],
                     lsb_block_state[14], lsb_block_state[15]};

      data_out_new = data_in ^ block_state;
    end // data_out_logic


  //----------------------------------------------------------------
  // qr_ctr
  // Update logic for the quarterround counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : qr_ctr
      qr_ctr_new = 0;
      qr_ctr_we  = 0;

      if (qr_ctr_rst)
        begin
          qr_ctr_new = 0;
          qr_ctr_we  = 1;
        end

      if (qr_ctr_inc)
        begin
          qr_ctr_new = qr_ctr_reg + 1'b1;
          qr_ctr_we  = 1;
        end
    end // qr_ctr


  //----------------------------------------------------------------
  // dr_ctr
  // Update logic for the round counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : dr_ctr
      dr_ctr_new = 0;
      dr_ctr_we  = 0;

      if (dr_ctr_rst)
        begin
          dr_ctr_new = 0;
          dr_ctr_we  = 1;
        end

      if (dr_ctr_inc)
        begin
          dr_ctr_new = dr_ctr_reg + 1'b1;
          dr_ctr_we  = 1;
        end
    end // dr_ctr


  //----------------------------------------------------------------
  // block_ctr
  // Update logic for the 64-bit block counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : block_ctr
      block0_ctr_new = 32'h0;
      block1_ctr_new = 32'h0;
      block0_ctr_we = 0;
      block1_ctr_we = 0;

      if (block_ctr_set)
        begin
          block0_ctr_new = ctr[31 : 00];
          block1_ctr_new = ctr[63 : 32];
          block0_ctr_we = 1;
          block1_ctr_we = 1;
        end

      if (block_ctr_inc)
        begin
          block0_ctr_new = block0_ctr_reg + 1;
          block0_ctr_we = 1;

          // Avoid chaining the 32-bit adders.
          if (block0_ctr_reg == 32'hffffffff)
            begin
              block1_ctr_new = block1_ctr_reg + 1;
              block1_ctr_we = 1;
            end
        end
    end // block_ctr


  //----------------------------------------------------------------
  // blabla_ctrl_fsm
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @*
    begin : blabla_ctrl_fsm
      init_state         = 0;
      update_state       = 0;
      update_output      = 0;
      qr_ctr_inc         = 0;
      qr_ctr_rst         = 0;
      dr_ctr_inc         = 0;
      dr_ctr_rst         = 0;
      block_ctr_inc      = 0;
      block_ctr_set      = 0;
      ready_new          = 0;
      ready_we           = 0;
      data_out_valid_new = 0;
      data_out_valid_we  = 0;
      blabla_ctrl_new    = CTRL_IDLE;
      blabla_ctrl_we     = 0;

      case (blabla_ctrl_reg)
        CTRL_IDLE:
          begin
            if (init)
              begin
                block_ctr_set   = 1;
                ready_new       = 0;
                ready_we        = 1;
                blabla_ctrl_new = CTRL_INIT;
                blabla_ctrl_we  = 1;
              end
          end

        CTRL_INIT:
          begin
            init_state      = 1;
            qr_ctr_rst      = 1;
            dr_ctr_rst      = 1;
            blabla_ctrl_new = CTRL_ROUNDS;
            blabla_ctrl_we  = 1;
          end

        CTRL_ROUNDS:
          begin
            update_state = 1;
            qr_ctr_inc   = 1;
            if (qr_ctr_reg == QR1)
              begin
                dr_ctr_inc = 1;
                if (dr_ctr_reg == (rounds[4 : 1] - 1))
                  begin
                    blabla_ctrl_new = CTRL_FINALIZE;
                    blabla_ctrl_we  = 1;
                  end
              end
          end

        CTRL_FINALIZE:
          begin
            ready_new          = 1;
            ready_we           = 1;
            update_output      = 1;
            data_out_valid_new = 1;
            data_out_valid_we  = 1;
            blabla_ctrl_new    = CTRL_DONE;
            blabla_ctrl_we     = 1;
          end

        CTRL_DONE:
          begin
            if (init)
              begin
                ready_new          = 0;
                ready_we           = 1;
                data_out_valid_new = 0;
                data_out_valid_we  = 1;
                block_ctr_set      = 1;
                blabla_ctrl_new    = CTRL_INIT;
                blabla_ctrl_we     = 1;
              end
            else if (next)
              begin
                ready_new          = 0;
                ready_we           = 1;
                data_out_valid_new = 0;
                data_out_valid_we  = 1;
                block_ctr_inc      = 1;
                blabla_ctrl_new    = CTRL_INIT;
                blabla_ctrl_we     = 1;
              end
          end

        default:
          begin

          end
      endcase // case (blabla_ctrl_reg)
    end // blabla_ctrl_fsm
endmodule // blabla_core

//======================================================================
// EOF blabla_core.v
//======================================================================

module blabla_qr(
                 input wire [63 : 0]  a,
                 input wire [63 : 0]  b,
                 input wire [63 : 0]  c,
                 input wire [63 : 0]  d,

                 output wire [63 : 0] a_prim,
                 output wire [63 : 0] b_prim,
                 output wire [63 : 0] c_prim,
                 output wire [63 : 0] d_prim
                );

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] internal_a_prim;
  reg [63 : 0] internal_b_prim;
  reg [63 : 0] internal_c_prim;
  reg [63 : 0] internal_d_prim;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports.
  //----------------------------------------------------------------
  assign a_prim = internal_a_prim;
  assign b_prim = internal_b_prim;
  assign c_prim = internal_c_prim;
  assign d_prim = internal_d_prim;


  //----------------------------------------------------------------
  // qr
  //
  // The actual quarterround function.
  //----------------------------------------------------------------
  always @*
    begin : qr
      reg [63 : 0] a0;
      reg [63 : 0] a1;
      reg [63 : 0] b0;
      reg [63 : 0] b1;
      reg [63 : 0] b2;
      reg [63 : 0] b3;
      reg [63 : 0] c0;
      reg [63 : 0] c1;
      reg [63 : 0] d0;
      reg [63 : 0] d1;
      reg [63 : 0] d2;
      reg [63 : 0] d3;

      a0 = a + b;
      d0 = d ^ a0;
      d1 = {d0[15 : 0], d0[31 : 16]};
      c0 = c + d1;
      b0 = b ^ c0;
      b1 = {b0[19 : 0], b0[31 : 20]};
      a1 = a0 + b1;
      d2 = d1 ^ a1;
      d3 = {d2[23 : 0], d2[31 : 24]};
      c1 = c0 + d3;
      b2 = b1 ^ c1;
      b3 = {b2[24 : 0], b2[31 : 25]};

      internal_a_prim = a1;
      internal_b_prim = b3;
      internal_c_prim = c1;
      internal_d_prim = d3;
    end // qr
endmodule // blabla_qr