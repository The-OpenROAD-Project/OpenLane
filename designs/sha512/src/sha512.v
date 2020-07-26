//======================================================================
//
// sha512.v
// --------
// Top level wrapper for the SHA-512 hash function providing
// a simple memory like interface with 32 bit data access.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014,  Secworks Sweden AB
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

module sha512(
              // Clock and reset.
              input wire           clk,
              input wire           reset_n,

              // Control.
              input wire           cs,
              input wire           we,

              // Data ports.
              input wire  [7 : 0]  address,
              input wire  [31 : 0] write_data,
              output wire [31 : 0] read_data,
              output wire          error
             );

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter ADDR_NAME0           = 8'h00;
  parameter ADDR_NAME1           = 8'h01;
  parameter ADDR_VERSION         = 8'h02;

  parameter ADDR_CTRL            = 8'h08;
  parameter CTRL_INIT_BIT        = 0;
  parameter CTRL_NEXT_BIT        = 1;
  parameter CTRL_MODE_LOW_BIT    = 2;
  parameter CTRL_MODE_HIGH_BIT   = 3;
  parameter CTRL_WORK_FACTOR_BIT = 7;

  parameter ADDR_STATUS          = 8'h09;
  parameter STATUS_READY_BIT     = 0;
  parameter STATUS_VALID_BIT     = 1;

  parameter ADDR_WORK_FACTOR_NUM = 8'h0a;

  parameter ADDR_BLOCK0          = 8'h10;
  parameter ADDR_BLOCK31         = 8'h2f;

  parameter ADDR_DIGEST0         = 8'h40;
  parameter ADDR_DIGEST15        = 8'h4f;

  parameter CORE_NAME0           = 32'h73686132; // "sha2"
  parameter CORE_NAME1           = 32'h2d353132; // "-512"
  parameter CORE_VERSION         = 32'h302e3830; // "0.80"

  parameter MODE_SHA_512_224     = 2'h0;
  parameter MODE_SHA_512_256     = 2'h1;
  parameter MODE_SHA_384         = 2'h2;
  parameter MODE_SHA_512         = 2'h3;

  parameter DEFAULT_WORK_FACTOR_NUM = 32'h000f0000;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg init_reg;
  reg init_new;

  reg next_reg;
  reg next_new;

  reg ready_reg;

  reg work_factor_reg;
  reg work_factor_new;
  reg work_factor_we;

  reg [1 : 0] mode_reg;
  reg [1 : 0] mode_new;
  reg         mode_we;

  reg [31 : 0] work_factor_num_reg;
  reg          work_factor_num_we;

  reg [31 : 0] block_reg [0 : 31];
  reg          block_we;

  reg [511 : 0] digest_reg;
  reg           digest_valid_reg;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire            core_ready;
  wire [1023 : 0] core_block;
  wire [511 : 0]  core_digest;
  wire            core_digest_valid;
  reg [4 : 0]     block_addr;

  reg [31 : 0]    tmp_read_data;
  reg             tmp_error;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign core_block = {block_reg[00], block_reg[01], block_reg[02], block_reg[03],
                       block_reg[04], block_reg[05], block_reg[06], block_reg[07],
                       block_reg[08], block_reg[09], block_reg[10], block_reg[11],
                       block_reg[12], block_reg[13], block_reg[14], block_reg[15],
                       block_reg[16], block_reg[17], block_reg[18], block_reg[19],
                       block_reg[20], block_reg[21], block_reg[22], block_reg[23],
                       block_reg[24], block_reg[25], block_reg[26], block_reg[27],
                       block_reg[28], block_reg[29], block_reg[30], block_reg[31]};

  assign read_data = tmp_read_data;
  assign error     = tmp_error;


  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  sha512_core core(
                   .clk(clk),
                   .reset_n(reset_n),

                   .init(init_reg),
                   .next(next_reg),
                   .mode(mode_reg),

                   .work_factor(work_factor_reg),
                   .work_factor_num(work_factor_num_reg),

                   .block(core_block),

                   .ready(core_ready),

                   .digest(core_digest),
                   .digest_valid(core_digest_valid)
                  );


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      integer i;

      if (!reset_n)
        begin
          for (i = 0 ; i < 32 ; i = i + 1)
            block_reg[i] <= 32'h0;

          init_reg            <= 1'h0;
          next_reg            <= 1'h0;
          mode_reg            <= MODE_SHA_512;
          work_factor_reg     <= 1'h0;
          work_factor_num_reg <= DEFAULT_WORK_FACTOR_NUM;
          ready_reg           <= 1'h0;
          digest_reg          <= 512'h0;
          digest_valid_reg    <= 1'h0;
        end
      else
        begin
          ready_reg        <= core_ready;
          digest_valid_reg <= core_digest_valid;
          init_reg         <= init_new;
          next_reg         <= next_new;

          if (mode_we)
            mode_reg <= mode_new;

          if (work_factor_we)
            work_factor_reg <= work_factor_new;

          if (work_factor_num_we)
            work_factor_num_reg <= write_data;

          if (core_digest_valid)
            digest_reg <= core_digest;

          if (block_we)
            block_reg[block_addr] <= write_data;
        end
    end // reg_update


  //----------------------------------------------------------------
  // api_logic
  //
  // Implementation of the api logic. If cs is enabled will either
  // try to write to or read from the internal registers.
  //----------------------------------------------------------------
  always @*
    begin : api_logic
      init_new           = 1'h0;
      next_new           = 1'h0;
      mode_new           = MODE_SHA_512;
      mode_we            = 1'h0;
      work_factor_new    = 1'h0;
      work_factor_we     = 1'h0;
      work_factor_num_we = 1'h0;
      block_we           = 1'h0;
      tmp_read_data      = 32'h0;
      tmp_error          = 1'h0;

      block_addr = address[4 : 0] - ADDR_BLOCK0[4 : 0];

      if (cs)
        begin
          if (we)
            begin
              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
                block_we = 1'h1;

              case (address)
                ADDR_CTRL:
                  begin
                    init_new        = write_data[CTRL_INIT_BIT];
                    next_new        = write_data[CTRL_NEXT_BIT];
                    mode_new        = write_data[CTRL_MODE_HIGH_BIT : CTRL_MODE_LOW_BIT];
                    mode_we         = 1'h1;
                    work_factor_new = write_data[CTRL_WORK_FACTOR_BIT];
                    work_factor_we  = 1'h1;
                  end

                ADDR_WORK_FACTOR_NUM:
                  work_factor_num_we = 1'h1;

                default:
                    tmp_error = 1'h1;
              endcase // case (address)
            end // if (we)

          else
            begin
              if ((address >= ADDR_DIGEST0) && (address <= ADDR_DIGEST15))
                tmp_read_data = digest_reg[(15 - (address - ADDR_DIGEST0)) * 32 +: 32];

              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
                tmp_read_data = block_reg[address[4 : 0]];

              case (address)
                ADDR_NAME0:
                  tmp_read_data = CORE_NAME0;

                ADDR_NAME1:
                  tmp_read_data = CORE_NAME1;

                ADDR_VERSION:
                  tmp_read_data = CORE_VERSION;

                ADDR_CTRL:
                  tmp_read_data = {24'h0, work_factor_reg, 3'b0, mode_reg, next_reg, init_reg};

                ADDR_STATUS:
                  tmp_read_data = {30'h0, digest_valid_reg, ready_reg};

                ADDR_WORK_FACTOR_NUM:
                  tmp_read_data = work_factor_num_reg;

                default:
                  tmp_error = 1'h1;
              endcase // case (address)
            end
        end
    end // addr_decoder
endmodule // sha512

//======================================================================
// EOF sha512.v
//======================================================================

//======================================================================
//
// sha512_core.v
// -------------
// Verilog 2001 implementation of the SHA-512 hash function.
// This is the internal core with wide interfaces.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014 Secworks Sweden AB
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

module sha512_core(
                   input wire            clk,
                   input wire            reset_n,

                   input wire            init,
                   input wire            next,
                   input wire [1 : 0]    mode,

                   input wire            work_factor,
                   input wire [31 : 0]   work_factor_num,

                   input wire [1023 : 0] block,

                   output wire           ready,
                   output wire [511 : 0] digest,
                   output wire           digest_valid
                  );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter SHA512_ROUNDS = 79;

  parameter CTRL_IDLE   = 0;
  parameter CTRL_ROUNDS = 1;
  parameter CTRL_DONE   = 2;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0] a_reg;
  reg [63 : 0] a_new;
  reg [63 : 0] b_reg;
  reg [63 : 0] b_new;
  reg [63 : 0] c_reg;
  reg [63 : 0] c_new;
  reg [63 : 0] d_reg;
  reg [63 : 0] d_new;
  reg [63 : 0] e_reg;
  reg [63 : 0] e_new;
  reg [63 : 0] f_reg;
  reg [63 : 0] f_new;
  reg [63 : 0] g_reg;
  reg [63 : 0] g_new;
  reg [63 : 0] h_reg;
  reg [63 : 0] h_new;
  reg          a_h_we;

  reg [63 : 0] H0_reg;
  reg [63 : 0] H0_new;
  reg [63 : 0] H1_reg;
  reg [63 : 0] H1_new;
  reg [63 : 0] H2_reg;
  reg [63 : 0] H2_new;
  reg [63 : 0] H3_reg;
  reg [63 : 0] H3_new;
  reg [63 : 0] H4_reg;
  reg [63 : 0] H4_new;
  reg [63 : 0] H5_reg;
  reg [63 : 0] H5_new;
  reg [63 : 0] H6_reg;
  reg [63 : 0] H6_new;
  reg [63 : 0] H7_reg;
  reg [63 : 0] H7_new;
  reg          H_we;

  reg [6 : 0]  round_ctr_reg;
  reg [6 : 0]  round_ctr_new;
  reg          round_ctr_we;
  reg          round_ctr_inc;
  reg          round_ctr_rst;

  reg [31 : 0] work_factor_ctr_reg;
  reg [31 : 0] work_factor_ctr_new;
  reg          work_factor_ctr_rst;
  reg          work_factor_ctr_inc;
  reg          work_factor_ctr_we;

  reg          ready_reg;
  reg          ready_new;
  reg          ready_we;

  reg          digest_valid_reg;
  reg          digest_valid_new;
  reg          digest_valid_we;

  reg [1 : 0]  sha512_ctrl_reg;
  reg [1 : 0]  sha512_ctrl_new;
  reg          sha512_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg digest_init;
  reg digest_update;

  reg state_init;
  reg state_update;

  reg first_block;

  reg [63 : 0] t1;
  reg [63 : 0] t2;

  wire [63 : 0] k_data;

  reg           w_init;
  reg           w_next;
  wire [63 : 0] w_data;

  wire [63 : 0] H0_0;
  wire [63 : 0] H0_1;
  wire [63 : 0] H0_2;
  wire [63 : 0] H0_3;
  wire [63 : 0] H0_4;
  wire [63 : 0] H0_5;
  wire [63 : 0] H0_6;
  wire [63 : 0] H0_7;


  //----------------------------------------------------------------
  // Module instantiantions.
  //----------------------------------------------------------------
  sha512_k_constants k_constants_inst(
                                      .addr(round_ctr_reg),
                                      .K(k_data)
                                     );


  sha512_h_constants h_constants_inst(
                                      .mode(mode),

                                      .H0(H0_0),
                                      .H1(H0_1),
                                      .H2(H0_2),
                                      .H3(H0_3),
                                      .H4(H0_4),
                                      .H5(H0_5),
                                      .H6(H0_6),
                                      .H7(H0_7)
                                     );


  sha512_w_mem w_mem_inst(
                          .clk(clk),
                          .reset_n(reset_n),

                          .block(block),

                          .init(w_init),
                          .next(w_next),
                          .w(w_data)
                         );


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready = ready_reg;

  assign digest = {H0_reg, H1_reg, H2_reg, H3_reg,
                   H4_reg, H5_reg, H6_reg, H7_reg};

  assign digest_valid = digest_valid_reg;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n)
        begin
          a_reg               <= 64'h0;
          b_reg               <= 64'h0;
          c_reg               <= 64'h0;
          d_reg               <= 64'h0;
          e_reg               <= 64'h0;
          f_reg               <= 64'h0;
          g_reg               <= 64'h0;
          h_reg               <= 64'h0;
          H0_reg              <= 64'h0;
          H1_reg              <= 64'h0;
          H2_reg              <= 64'h0;
          H3_reg              <= 64'h0;
          H4_reg              <= 64'h0;
          H5_reg              <= 64'h0;
          H6_reg              <= 64'h0;
          H7_reg              <= 64'h0;
          work_factor_ctr_reg <= 32'h0;
          ready_reg           <= 1'b1;
          digest_valid_reg    <= 1'b0;
          round_ctr_reg       <= 7'h0;
          sha512_ctrl_reg     <= CTRL_IDLE;
        end

      else
        begin
          if (a_h_we)
            begin
              a_reg <= a_new;
              b_reg <= b_new;
              c_reg <= c_new;
              d_reg <= d_new;
              e_reg <= e_new;
              f_reg <= f_new;
              g_reg <= g_new;
              h_reg <= h_new;
            end

          if (H_we)
            begin
              H0_reg <= H0_new;
              H1_reg <= H1_new;
              H2_reg <= H2_new;
              H3_reg <= H3_new;
              H4_reg <= H4_new;
              H5_reg <= H5_new;
              H6_reg <= H6_new;
              H7_reg <= H7_new;
            end

          if (round_ctr_we)
            round_ctr_reg <= round_ctr_new;

          if (work_factor_ctr_we)
            work_factor_ctr_reg <= work_factor_ctr_new;

          if (ready_we)
            ready_reg <= ready_new;

          if (digest_valid_we)
            digest_valid_reg <= digest_valid_new;

          if (sha512_ctrl_we)
            sha512_ctrl_reg <= sha512_ctrl_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // digest_logic
  //
  // The logic needed to init as well as update the digest.
  //----------------------------------------------------------------
  always @*
    begin : digest_logic
      H0_new = 64'h0;
      H1_new = 64'h0;
      H2_new = 64'h0;
      H3_new = 64'h0;
      H4_new = 64'h0;
      H5_new = 64'h0;
      H6_new = 64'h0;
      H7_new = 64'h0;
      H_we = 0;

      if (digest_init)
        begin
          H0_new = H0_0;
          H1_new = H0_1;
          H2_new = H0_2;
          H3_new = H0_3;
          H4_new = H0_4;
          H5_new = H0_5;
          H6_new = H0_6;
          H7_new = H0_7;
          H_we = 1;
        end

      if (digest_update)
        begin
          H0_new = H0_reg + a_reg;
          H1_new = H1_reg + b_reg;
          H2_new = H2_reg + c_reg;
          H3_new = H3_reg + d_reg;
          H4_new = H4_reg + e_reg;
          H5_new = H5_reg + f_reg;
          H6_new = H6_reg + g_reg;
          H7_new = H7_reg + h_reg;
          H_we = 1;
        end
    end // digest_logic


  //----------------------------------------------------------------
  // t1_logic
  //
  // The logic for the T1 function.
  //----------------------------------------------------------------
  always @*
    begin : t1_logic
      reg [63 : 0] sum1;
      reg [63 : 0] ch;

      sum1 = {e_reg[13 : 0], e_reg[63 : 14]} ^
             {e_reg[17 : 0], e_reg[63 : 18]} ^
             {e_reg[40 : 0], e_reg[63 : 41]};

      ch = (e_reg & f_reg) ^ ((~e_reg) & g_reg);

      t1 = h_reg + sum1 + ch + k_data + w_data;
    end // t1_logic


  //----------------------------------------------------------------
  // t2_logic
  //
  // The logic for the T2 function
  //----------------------------------------------------------------
  always @*
    begin : t2_logic
      reg [63 : 0] sum0;
      reg [63 : 0] maj;

      sum0 = {a_reg[27 : 0], a_reg[63 : 28]} ^
             {a_reg[33 : 0], a_reg[63 : 34]} ^
             {a_reg[38 : 0], a_reg[63 : 39]};

      maj = (a_reg & b_reg) ^ (a_reg & c_reg) ^ (b_reg & c_reg);

      t2 = sum0 + maj;
    end // t2_logic


  //----------------------------------------------------------------
  // state_logic
  //
  // The logic needed to init as well as update the state during
  // round processing.
  //----------------------------------------------------------------
  always @*
    begin : state_logic
      a_new  = 64'h0;
      b_new  = 64'h0;
      c_new  = 64'h0;
      d_new  = 64'h0;
      e_new  = 64'h0;
      f_new  = 64'h0;
      g_new  = 64'h0;
      h_new  = 64'h0;
      a_h_we = 0;

      if (state_init)
        begin
          if (first_block)
            begin
              a_new  = H0_0;
              b_new  = H0_1;
              c_new  = H0_2;
              d_new  = H0_3;
              e_new  = H0_4;
              f_new  = H0_5;
              g_new  = H0_6;
              h_new  = H0_7;
              a_h_we = 1;
            end
          else
            begin
              a_new  = H0_reg;
              b_new  = H1_reg;
              c_new  = H2_reg;
              d_new  = H3_reg;
              e_new  = H4_reg;
              f_new  = H5_reg;
              g_new  = H6_reg;
              h_new  = H7_reg;
              a_h_we = 1;
            end
        end

      if (state_update)
        begin
          a_new  = t1 + t2;
          b_new  = a_reg;
          c_new  = b_reg;
          d_new  = c_reg;
          e_new  = d_reg + t1;
          f_new  = e_reg;
          g_new  = f_reg;
          h_new  = g_reg;
          a_h_we = 1;
        end
    end // state_logic


  //----------------------------------------------------------------
  // round_ctr
  //
  // Update logic for the round counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : round_ctr
      round_ctr_new = 7'h00;
      round_ctr_we  = 0;

      if (round_ctr_rst)
        begin
          round_ctr_new = 7'h00;
          round_ctr_we  = 1;
        end

      if (round_ctr_inc)
        begin
          round_ctr_new = round_ctr_reg + 1'b1;
          round_ctr_we  = 1;
        end
    end // round_ctr


  //----------------------------------------------------------------
  // work_factor_ctr
  //
  // Work factor counter logic.
  //----------------------------------------------------------------
  always @*
    begin : work_factor_ctr
      work_factor_ctr_new  = 32'h0;
      work_factor_ctr_we   = 0;

      if (work_factor_ctr_rst)
        begin
          work_factor_ctr_new = 32'h0;
          work_factor_ctr_we  = 1;
        end

      if (work_factor_ctr_inc)
        begin
          work_factor_ctr_new = work_factor_ctr_reg + 1'b1;
          work_factor_ctr_we  = 1;
        end
    end // work_factor_ctr


  //----------------------------------------------------------------
  // sha512_ctrl_fsm
  //
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @*
    begin : sha512_ctrl_fsm
      digest_init         = 1'b0;
      digest_update       = 1'b0;
      state_init          = 1'b0;
      state_update        = 1'b0;
      first_block         = 1'b0;
      w_init              = 1'b0;
      w_next              = 1'b0;
      round_ctr_inc       = 1'b0;
      round_ctr_rst       = 1'b0;
      digest_valid_new    = 1'b0;
      digest_valid_we     = 1'b0;
      work_factor_ctr_rst = 1'b0;
      work_factor_ctr_inc = 1'b0;
      ready_new           = 1'b0;
      ready_we            = 1'b0;
      sha512_ctrl_new     = CTRL_IDLE;
      sha512_ctrl_we      = 1'b0;

      case (sha512_ctrl_reg)
        CTRL_IDLE:
          begin
            if (init)
              begin
                ready_new           = 1'b0;
                ready_we            = 1'b1;
                work_factor_ctr_rst = 1;
                digest_init         = 1;
                w_init              = 1;
                state_init          = 1;
                first_block         = 1;
                round_ctr_rst       = 1;
                digest_valid_new    = 0;
                digest_valid_we     = 1;
                sha512_ctrl_new     = CTRL_ROUNDS;
                sha512_ctrl_we      = 1;
              end

            if (next)
              begin
                ready_new           = 1'b0;
                ready_we            = 1'b1;
                work_factor_ctr_rst = 1;
                w_init              = 1;
                state_init          = 1;
                round_ctr_rst       = 1;
                digest_valid_new    = 0;
                digest_valid_we     = 1;
                sha512_ctrl_new     = CTRL_ROUNDS;
                sha512_ctrl_we      = 1;
              end
          end


        CTRL_ROUNDS:
          begin
            w_next        = 1;
            state_update  = 1;
            round_ctr_inc = 1;

            if (round_ctr_reg == SHA512_ROUNDS)
              begin
                work_factor_ctr_inc = 1;
                sha512_ctrl_new     = CTRL_DONE;
                sha512_ctrl_we      = 1;
              end
          end


        CTRL_DONE:
          begin
            if (work_factor)
              begin
                if (work_factor_ctr_reg < work_factor_num)
                  begin
                    w_init              = 1'b1;
                    state_init          = 1'b1;
                    round_ctr_rst       = 1'b1;
                    sha512_ctrl_new     = CTRL_ROUNDS;
                    sha512_ctrl_we      = 1'b1;
                  end
                else
                  begin
                    ready_new        = 1'b1;
                    ready_we         = 1'b1;
                    digest_update    = 1'b1;
                    digest_valid_new = 1'b1;
                    digest_valid_we  = 1'b1;
                    sha512_ctrl_new  = CTRL_IDLE;
                    sha512_ctrl_we   = 1'b1;
                  end
              end
            else
              begin
                ready_new        = 1'b1;
                ready_we         = 1'b1;
                digest_update    = 1'b1;
                digest_valid_new = 1'b1;
                digest_valid_we  = 1'b1;
                sha512_ctrl_new  = CTRL_IDLE;
                sha512_ctrl_we   = 1'b1;
              end
          end
      endcase // case (sha512_ctrl_reg)
    end // sha512_ctrl_fsm

endmodule // sha512_core

//======================================================================
// EOF sha512_core.v
//======================================================================

//======================================================================
//
// sha512_h_constants.v
// ---------------------
// The H initial constants for the different modes in SHA-512.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014 Secworks Sweden AB
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

module sha512_h_constants(
                          input wire  [1 : 0]  mode,

                          output wire [63 : 0] H0,
                          output wire [63 : 0] H1,
                          output wire [63 : 0] H2,
                          output wire [63 : 0] H3,
                          output wire [63 : 0] H4,
                          output wire [63 : 0] H5,
                          output wire [63 : 0] H6,
                          output wire [63 : 0] H7
                         );

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] tmp_H0;
  reg [63 : 0] tmp_H1;
  reg [63 : 0] tmp_H2;
  reg [63 : 0] tmp_H3;
  reg [63 : 0] tmp_H4;
  reg [63 : 0] tmp_H5;
  reg [63 : 0] tmp_H6;
  reg [63 : 0] tmp_H7;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign H0 = tmp_H0;
  assign H1 = tmp_H1;
  assign H2 = tmp_H2;
  assign H3 = tmp_H3;
  assign H4 = tmp_H4;
  assign H5 = tmp_H5;
  assign H6 = tmp_H6;
  assign H7 = tmp_H7;

  
  //----------------------------------------------------------------
  // mode_mux
  //
  // Based on the given mode, the correct H constants are selected.
  //----------------------------------------------------------------
  always @*
    begin : mode_mux
      case(mode)
        0:
          begin
            // SHA-512/224
            tmp_H0 = 64'h8c3d37c819544da2;
            tmp_H1 = 64'h73e1996689dcd4d6;
            tmp_H2 = 64'h1dfab7ae32ff9c82;
            tmp_H3 = 64'h679dd514582f9fcf;
            tmp_H4 = 64'h0f6d2b697bd44da8;
            tmp_H5 = 64'h77e36f7304c48942;
            tmp_H6 = 64'h3f9d85a86a1d36c8;
            tmp_H7 = 64'h1112e6ad91d692a1;
          end

        1:
          begin
            // SHA-512/256
            tmp_H0 = 64'h22312194fc2bf72c; 
            tmp_H1 = 64'h9f555fa3c84c64c2; 
            tmp_H2 = 64'h2393b86b6f53b151; 
            tmp_H3 = 64'h963877195940eabd; 
            tmp_H4 = 64'h96283ee2a88effe3; 
            tmp_H5 = 64'hbe5e1e2553863992; 
            tmp_H6 = 64'h2b0199fc2c85b8aa; 
            tmp_H7 = 64'h0eb72ddc81c52ca2;
          end
        
        2:
          begin
            // SHA-384
            tmp_H0 = 64'hcbbb9d5dc1059ed8;
            tmp_H1 = 64'h629a292a367cd507;
            tmp_H2 = 64'h9159015a3070dd17; 
            tmp_H3 = 64'h152fecd8f70e5939; 
            tmp_H4 = 64'h67332667ffc00b31; 
            tmp_H5 = 64'h8eb44a8768581511; 
            tmp_H6 = 64'hdb0c2e0d64f98fa7; 
            tmp_H7 = 64'h47b5481dbefa4fa4;
          end
        
        3:
          begin
            // SHA-512
            tmp_H0 = 64'h6a09e667f3bcc908;
            tmp_H1 = 64'hbb67ae8584caa73b;
            tmp_H2 = 64'h3c6ef372fe94f82b; 
            tmp_H3 = 64'ha54ff53a5f1d36f1; 
            tmp_H4 = 64'h510e527fade682d1; 
            tmp_H5 = 64'h9b05688c2b3e6c1f; 
            tmp_H6 = 64'h1f83d9abfb41bd6b; 
            tmp_H7 = 64'h5be0cd19137e2179;  
          end
      endcase // case (addr)
    end // block: mode_mux
endmodule // sha512_h_constants

//======================================================================
// sha512_h_constants.v
//======================================================================
//======================================================================
//
// sha512_k_constants.v
// --------------------
// The table K with constants in the SHA-512 hash function.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014 Secworks Sweden AB
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

module sha512_k_constants(
                          input wire  [6 : 0]  addr,
                          output wire [63 : 0] K
                         );

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] tmp_K;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign K = tmp_K;


  //----------------------------------------------------------------
  // addr_mux
  //----------------------------------------------------------------
  always @*
    begin : addr_mux
      case(addr)
        0:  tmp_K = 64'h428a2f98d728ae22;
        1:  tmp_K = 64'h7137449123ef65cd;
        2:  tmp_K = 64'hb5c0fbcfec4d3b2f;
        3:  tmp_K = 64'he9b5dba58189dbbc;
        4:  tmp_K = 64'h3956c25bf348b538;
        5:  tmp_K = 64'h59f111f1b605d019;
        6:  tmp_K = 64'h923f82a4af194f9b;
        7:  tmp_K = 64'hab1c5ed5da6d8118;
        8:  tmp_K = 64'hd807aa98a3030242;
        9:  tmp_K = 64'h12835b0145706fbe;
        10: tmp_K = 64'h243185be4ee4b28c;
        11: tmp_K = 64'h550c7dc3d5ffb4e2;
        12: tmp_K = 64'h72be5d74f27b896f;
        13: tmp_K = 64'h80deb1fe3b1696b1;
        14: tmp_K = 64'h9bdc06a725c71235;
        15: tmp_K = 64'hc19bf174cf692694;
        16: tmp_K = 64'he49b69c19ef14ad2;
        17: tmp_K = 64'hefbe4786384f25e3;
        18: tmp_K = 64'h0fc19dc68b8cd5b5;
        19: tmp_K = 64'h240ca1cc77ac9c65;
        20: tmp_K = 64'h2de92c6f592b0275;
        21: tmp_K = 64'h4a7484aa6ea6e483;
        22: tmp_K = 64'h5cb0a9dcbd41fbd4;
        23: tmp_K = 64'h76f988da831153b5;
        24: tmp_K = 64'h983e5152ee66dfab;
        25: tmp_K = 64'ha831c66d2db43210;
        26: tmp_K = 64'hb00327c898fb213f;
        27: tmp_K = 64'hbf597fc7beef0ee4;
        28: tmp_K = 64'hc6e00bf33da88fc2;
        29: tmp_K = 64'hd5a79147930aa725;
        30: tmp_K = 64'h06ca6351e003826f;
        31: tmp_K = 64'h142929670a0e6e70;
        32: tmp_K = 64'h27b70a8546d22ffc;
        33: tmp_K = 64'h2e1b21385c26c926;
        34: tmp_K = 64'h4d2c6dfc5ac42aed;
        35: tmp_K = 64'h53380d139d95b3df;
        36: tmp_K = 64'h650a73548baf63de;
        37: tmp_K = 64'h766a0abb3c77b2a8;
        38: tmp_K = 64'h81c2c92e47edaee6;
        39: tmp_K = 64'h92722c851482353b;
        40: tmp_K = 64'ha2bfe8a14cf10364;
        41: tmp_K = 64'ha81a664bbc423001;
        42: tmp_K = 64'hc24b8b70d0f89791;
        43: tmp_K = 64'hc76c51a30654be30;
        44: tmp_K = 64'hd192e819d6ef5218;
        45: tmp_K = 64'hd69906245565a910;
        46: tmp_K = 64'hf40e35855771202a;
        47: tmp_K = 64'h106aa07032bbd1b8;
        48: tmp_K = 64'h19a4c116b8d2d0c8;
        49: tmp_K = 64'h1e376c085141ab53;
        50: tmp_K = 64'h2748774cdf8eeb99;
        51: tmp_K = 64'h34b0bcb5e19b48a8;
        52: tmp_K = 64'h391c0cb3c5c95a63;
        53: tmp_K = 64'h4ed8aa4ae3418acb;
        54: tmp_K = 64'h5b9cca4f7763e373;
        55: tmp_K = 64'h682e6ff3d6b2b8a3;
        56: tmp_K = 64'h748f82ee5defb2fc;
        57: tmp_K = 64'h78a5636f43172f60;
        58: tmp_K = 64'h84c87814a1f0ab72;
        59: tmp_K = 64'h8cc702081a6439ec;
        60: tmp_K = 64'h90befffa23631e28;
        61: tmp_K = 64'ha4506cebde82bde9;
        62: tmp_K = 64'hbef9a3f7b2c67915;
        63: tmp_K = 64'hc67178f2e372532b;
        64: tmp_K = 64'hca273eceea26619c;
        65: tmp_K = 64'hd186b8c721c0c207;
        66: tmp_K = 64'heada7dd6cde0eb1e;
        67: tmp_K = 64'hf57d4f7fee6ed178;
        68: tmp_K = 64'h06f067aa72176fba;
        69: tmp_K = 64'h0a637dc5a2c898a6;
        70: tmp_K = 64'h113f9804bef90dae;
        71: tmp_K = 64'h1b710b35131c471b;
        72: tmp_K = 64'h28db77f523047d84;
        73: tmp_K = 64'h32caab7b40c72493;
        74: tmp_K = 64'h3c9ebe0a15c9bebc;
        75: tmp_K = 64'h431d67c49c100d4c;
        76: tmp_K = 64'h4cc5d4becb3e42b6;
        77: tmp_K = 64'h597f299cfc657e2a;
        78: tmp_K = 64'h5fcb6fab3ad6faec;
        79: tmp_K = 64'h6c44198c4a475817;

        default:
          tmp_K = 64'h0;
      endcase // case (addr)
    end // block: addr_mux
endmodule // sha512_k_constants

//======================================================================
// sha512_k_constants.v
//======================================================================

//======================================================================
//
// sha512_w_mem_regs.v
// -------------------
// The W memory for the SHA-512 core. This version uses 16
// 32-bit registers as a sliding window to generate the 64 words.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014 Secworks Sweden AB
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

module sha512_w_mem(
                    input wire            clk,
                    input wire            reset_n,

                    input wire [1023 : 0] block,

                    input wire            init,
                    input wire            next,
                    output wire [63 : 0]  w
                   );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter CTRL_IDLE   = 1'b0;
  parameter CTRL_UPDATE = 1'b1;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0] w_mem [0 : 15];
  reg [63 : 0] w_mem00_new;
  reg [63 : 0] w_mem01_new;
  reg [63 : 0] w_mem02_new;
  reg [63 : 0] w_mem03_new;
  reg [63 : 0] w_mem04_new;
  reg [63 : 0] w_mem05_new;
  reg [63 : 0] w_mem06_new;
  reg [63 : 0] w_mem07_new;
  reg [63 : 0] w_mem08_new;
  reg [63 : 0] w_mem09_new;
  reg [63 : 0] w_mem10_new;
  reg [63 : 0] w_mem11_new;
  reg [63 : 0] w_mem12_new;
  reg [63 : 0] w_mem13_new;
  reg [63 : 0] w_mem14_new;
  reg [63 : 0] w_mem15_new;
  reg          w_mem_we;

  reg [6 : 0] w_ctr_reg;
  reg [6 : 0] w_ctr_new;
  reg         w_ctr_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] w_tmp;
  reg [63 : 0] w_new;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign w = w_tmp;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      integer i;

      if (!reset_n)
        begin
          for (i = 0; i < 16; i = i + 1)
            w_mem[i] <= 64'h0;

          w_ctr_reg <= 7'h0;
        end
      else
        begin
          if (w_mem_we)
            begin
              w_mem[00] <= w_mem00_new;
              w_mem[01] <= w_mem01_new;
              w_mem[02] <= w_mem02_new;
              w_mem[03] <= w_mem03_new;
              w_mem[04] <= w_mem04_new;
              w_mem[05] <= w_mem05_new;
              w_mem[06] <= w_mem06_new;
              w_mem[07] <= w_mem07_new;
              w_mem[08] <= w_mem08_new;
              w_mem[09] <= w_mem09_new;
              w_mem[10] <= w_mem10_new;
              w_mem[11] <= w_mem11_new;
              w_mem[12] <= w_mem12_new;
              w_mem[13] <= w_mem13_new;
              w_mem[14] <= w_mem14_new;
              w_mem[15] <= w_mem15_new;
            end

          if (w_ctr_we)
              w_ctr_reg <= w_ctr_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // select_w
  //
  // Mux for the external read operation. This is where we exract
  // the W variable.
  //----------------------------------------------------------------
  always @*
    begin : select_w
      if (w_ctr_reg < 16)
        w_tmp = w_mem[w_ctr_reg[3 : 0]];
      else
        w_tmp = w_new;
    end // select_w


  //----------------------------------------------------------------
  // w_new_logic
  //
  // Logic that calculates the next value to be inserted into
  // the sliding window of the memory.
  //----------------------------------------------------------------
  always @*
    begin : w_mem_update_logic
      reg [63 : 0] w_0;
      reg [63 : 0] w_1;
      reg [63 : 0] w_9;
      reg [63 : 0] w_14;
      reg [63 : 0] d0;
      reg [63 : 0] d1;

      w_mem00_new = 64'h0;
      w_mem01_new = 64'h0;
      w_mem02_new = 64'h0;
      w_mem03_new = 64'h0;
      w_mem04_new = 64'h0;
      w_mem05_new = 64'h0;
      w_mem06_new = 64'h0;
      w_mem07_new = 64'h0;
      w_mem08_new = 64'h0;
      w_mem09_new = 64'h0;
      w_mem10_new = 64'h0;
      w_mem11_new = 64'h0;
      w_mem12_new = 64'h0;
      w_mem13_new = 64'h0;
      w_mem14_new = 64'h0;
      w_mem15_new = 64'h0;
      w_mem_we    = 0;

      w_0  = w_mem[0];
      w_1  = w_mem[1];
      w_9  = w_mem[9];
      w_14 = w_mem[14];

      d0 = {w_1[0],     w_1[63 : 1]} ^ // ROTR1
           {w_1[7 : 0], w_1[63 : 8]} ^ // ROTR8
           {7'b0000000, w_1[63 : 7]};  // SHR7

      d1 = {w_14[18 : 0], w_14[63 : 19]} ^ // ROTR19
           {w_14[60 : 0], w_14[63 : 61]} ^ // ROTR61
           {6'b000000,    w_14[63 : 6]};   // SHR6

      w_new = w_0 + d0 + w_9 + d1;

      if (init)
        begin
          w_mem00_new = block[1023 : 960];
          w_mem01_new = block[959  : 896];
          w_mem02_new = block[895  : 832];
          w_mem03_new = block[831  : 768];
          w_mem04_new = block[767  : 704];
          w_mem05_new = block[703  : 640];
          w_mem06_new = block[639  : 576];
          w_mem07_new = block[575  : 512];
          w_mem08_new = block[511  : 448];
          w_mem09_new = block[447  : 384];
          w_mem10_new = block[383  : 320];
          w_mem11_new = block[319  : 256];
          w_mem12_new = block[255  : 192];
          w_mem13_new = block[191  : 128];
          w_mem14_new = block[127  :  64];
          w_mem15_new = block[63   :   0];
          w_mem_we    = 1;
        end

      if (next && (w_ctr_reg > 15))
        begin
          w_mem00_new = w_mem[01];
          w_mem01_new = w_mem[02];
          w_mem02_new = w_mem[03];
          w_mem03_new = w_mem[04];
          w_mem04_new = w_mem[05];
          w_mem05_new = w_mem[06];
          w_mem06_new = w_mem[07];
          w_mem07_new = w_mem[08];
          w_mem08_new = w_mem[09];
          w_mem09_new = w_mem[10];
          w_mem10_new = w_mem[11];
          w_mem11_new = w_mem[12];
          w_mem12_new = w_mem[13];
          w_mem13_new = w_mem[14];
          w_mem14_new = w_mem[15];
          w_mem15_new = w_new;
          w_mem_we    = 1;
        end
    end // w_mem_update_logic


  //----------------------------------------------------------------
  // w_ctr
  // W schedule adress counter. Counts from 0x10 to 0x3f and
  // is used to expand the block into words.
  //----------------------------------------------------------------
  always @*
    begin : w_ctr
      w_ctr_new = 7'h0;
      w_ctr_we  = 1'h0;

      if (init)
        begin
          w_ctr_new = 7'h00;
          w_ctr_we  = 1'h1;
        end

      if (next)
        begin
          w_ctr_new = w_ctr_reg + 7'h01;
          w_ctr_we  = 1'h1;
        end
    end // w_ctr

endmodule // sha512_w_mem

//======================================================================
// sha512_w_mem.v
//======================================================================

 
