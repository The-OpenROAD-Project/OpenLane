//======================================================================
//
// sha3.v
// --------
// Top level wrapper for the SHA-3 hash function core providing
// a simple memory like interface with 32 bit data access.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2015, Assured AB
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

module sha3(
            // Clock and reset.
            input wire           clk,
            input wire           reset_n,

            // Control.
            input wire           cs,
            input wire           we,

            // Data ports.
            input wire  [7 : 0]  address,
            input wire  [31 : 0] write_data,
            output wire [31 : 0] read_data
           );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_NAME0       = 8'h00;
  localparam ADDR_NAME1       = 8'h01;
  localparam ADDR_VERSION     = 8'h02;

  localparam ADDR_CTRL        = 8'h08;
  localparam CTRL_INIT_BIT    = 0;
  localparam CTRL_NEXT_BIT    = 1;

  localparam ADDR_STATUS      = 8'h09;
  localparam STATUS_READY_BIT = 0;
  localparam STATUS_VALID_BIT = 1;
  localparam STATUS_ERROR_BIT = 2;

  localparam ADDR_BLOCK00     = 8'h10;
  localparam ADDR_BLOCK31     = 8'h2f;

  localparam ADDR_DIGEST00    = 8'h40;
  localparam ADDR_DIGEST15    = 8'h4f;

  localparam CORE_NAME0       = 32'h7368612d; // "sha-"
  localparam CORE_NAME1       = 32'h33202020; // "3   "
  localparam CORE_VERSION     = 32'h302e3130; // "0.10"

  localparam MODE_SHA3_224    = 2'h0;
  localparam MODE_SHA3_256    = 2'h1;
  localparam MODE_SHA3_384    = 2'h2;
  localparam MODE_SHA3_512    = 2'h3;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg init_reg;
  reg init_new;

  reg next_reg;
  reg next_new;

  reg [1 : 0] mode_reg;
  reg [1 : 0] mode_new;
  reg         mode_we;

  reg ready_reg;

  reg [31 : 0] block_reg [0 : 31];
  reg [4 : 0]  block_addr;
  reg          block_we;

  reg [511 : 0] digest_reg;
  reg [7 : 0]   digest_addr;
  reg           digest_valid_reg;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire            core_init;
  wire            core_next;
  wire [1 : 0]    core_mode;
  wire            core_work_factor;
  wire [31 : 0]   core_work_factor_num;
  wire            core_ready;
  wire [1023 : 0] core_block;
  wire [511 : 0]  core_digest;
  wire            core_digest_valid;

  reg [31 : 0]    tmp_read_data;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign core_init = init_reg;

  assign core_next = next_reg;

  assign core_mode = mode_reg;

  assign core_block = {block_reg[00], block_reg[01], block_reg[02], block_reg[03],
                       block_reg[04], block_reg[04], block_reg[05], block_reg[07],
                       block_reg[08], block_reg[09], block_reg[10], block_reg[11],
                       block_reg[12], block_reg[13], block_reg[14], block_reg[15],
                       block_reg[16], block_reg[17], block_reg[18], block_reg[19],
                       block_reg[20], block_reg[21], block_reg[22], block_reg[23],
                       block_reg[24], block_reg[24], block_reg[25], block_reg[27],
                       block_reg[28], block_reg[29], block_reg[30], block_reg[31]};

  assign read_data = tmp_read_data;


  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  sha3_core core(
                 .clk(clk),
                 .reset_n(reset_n),

                 .init(core_init),
                 .next(core_next),
                 .mode(core_mode),

                 .block(core_block),

                 .ready(core_ready),

                 .digest(core_digest),
                 .digest_valid(core_digest_valid)
                );


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      integer i;

      if (!reset_n)
        begin
          init_reg         <= 0;
          next_reg         <= 0;
          mode_reg         <= MODE_SHA3_256;
          ready_reg        <= 0;
          digest_reg       <= 512'h0;
          digest_valid_reg <= 0;
          for (i = 0 ; i < 32 ; i = i + 1)
            block_reg[i] = 32'h0;
        end
      else
        begin
          ready_reg        <= core_ready;
          digest_valid_reg <= core_digest_valid;
          init_reg         <= init_new;
          next_reg         <= next_new;

          if (mode_we)
            mode_reg <= write_data[3 : 2];

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
      init_new      = 0;
      next_new      = 0;
      mode_we       = 0;
      block_we      = 0;
      tmp_read_data = 32'h0;

      block_addr    = address - ADDR_BLOCK00;
      digest_addr   = 8'h10 - (address - ADDR_DIGEST00);

      if (cs)
        begin
          if (we)
            begin
              if ((address >= ADDR_BLOCK00) && (address <= ADDR_BLOCK31))
                block_we = 1;

              case (address)
                // Write operations.
                ADDR_CTRL:
                  begin
                    init_new = write_data[CTRL_INIT_BIT];
                    next_new = write_data[CTRL_NEXT_BIT];
                    mode_we  = 1;
                  end

                default:
                  begin
                  end
              endcase // case (address)
            end // if (we)

          else
            begin
              if ((address >= ADDR_BLOCK00) && (address <= ADDR_BLOCK31))
                tmp_read_data = block_reg[block_addr];

              // TODO: Fix mux construction for digest.
              if ((address >= ADDR_DIGEST00) && (address <= ADDR_DIGEST15))
                tmp_read_data = digest_reg[32 * digest_addr -: 32];

              case (address)
                // Read operations.
                ADDR_NAME0:
                  tmp_read_data = CORE_NAME0;

                ADDR_NAME1:
                  tmp_read_data = CORE_NAME1;

                ADDR_VERSION:
                  tmp_read_data = CORE_VERSION;

                ADDR_CTRL:
                  tmp_read_data = {28'h0, mode_reg, next_reg, init_reg};

                ADDR_STATUS:
                    tmp_read_data = {30'h0, digest_valid_reg, ready_reg};

                default:
                  begin
                  end
              endcase // case (address)
            end
        end
    end // addr_decoder
endmodule // sha3

//======================================================================
// EOF sha3.v
//======================================================================





//======================================================================
//
// sha3core.v
// -------------
// Verilog 2001 implementation of the SHA3 hash function.
// This is the internal core with wide interfaces.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2016 Secworks Sweden AB
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

module sha3_core(
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

  reg [6 : 0] t_ctr_reg;
  reg [6 : 0] t_ctr_new;
  reg         t_ctr_we;
  reg         t_ctr_inc;
  reg         t_ctr_rst;

  reg [31 : 0] work_factor_ctr_reg;
  reg [31 : 0] work_factor_ctr_new;
  reg          work_factor_ctr_rst;
  reg          work_factor_ctr_inc;
  reg          work_factor_ctr_done;
  reg          work_factor_ctr_we;

  reg digest_valid_reg;
  reg digest_valid_new;
  reg digest_valid_we;

  reg [1 : 0] sha512_ctrl_reg;
  reg [1 : 0] sha512_ctrl_new;
  reg         sha512_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg digest_init;
  reg digest_update;

  reg state_init;
  reg state_update;

  reg first_block;

  reg ready_flag;

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


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready = ready_flag;

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
          a_reg               <= 64'h0000000000000000;
          b_reg               <= 64'h0000000000000000;
          c_reg               <= 64'h0000000000000000;
          d_reg               <= 64'h0000000000000000;
          e_reg               <= 64'h0000000000000000;
          f_reg               <= 64'h0000000000000000;
          g_reg               <= 64'h0000000000000000;
          h_reg               <= 64'h0000000000000000;
          H0_reg              <= 64'h0000000000000000;
          H1_reg              <= 64'h0000000000000000;
          H2_reg              <= 64'h0000000000000000;
          H3_reg              <= 64'h0000000000000000;
          H4_reg              <= 64'h0000000000000000;
          H5_reg              <= 64'h0000000000000000;
          H6_reg              <= 64'h0000000000000000;
          H7_reg              <= 64'h0000000000000000;
          work_factor_ctr_reg <= 32'h00000000;
          digest_valid_reg    <= 0;
          t_ctr_reg           <= 7'h00;
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

          if (t_ctr_we)
            begin
              t_ctr_reg <= t_ctr_new;
            end

          if (work_factor_ctr_we)
            begin
              work_factor_ctr_reg <= work_factor_ctr_new;
            end

          if (digest_valid_we)
            begin
              digest_valid_reg <= digest_valid_new;
            end

          if (sha512_ctrl_we)
            begin
              sha512_ctrl_reg <= sha512_ctrl_new;
            end
        end
    end // reg_update


  //----------------------------------------------------------------
  // digest_logic
  //
  // The logic needed to init as well as update the digest.
  //----------------------------------------------------------------
  always @*
    begin : digest_logic
      H0_new = 64'h00000000;
      H1_new = 64'h00000000;
      H2_new = 64'h00000000;
      H3_new = 64'h00000000;
      H4_new = 64'h00000000;
      H5_new = 64'h00000000;
      H6_new = 64'h00000000;
      H7_new = 64'h00000000;
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
      a_new  = 64'h00000000;
      b_new  = 64'h00000000;
      c_new  = 64'h00000000;
      d_new  = 64'h00000000;
      e_new  = 64'h00000000;
      f_new  = 64'h00000000;
      g_new  = 64'h00000000;
      h_new  = 64'h00000000;
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
  // t_ctr
  //
  // Update logic for the round counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : t_ctr
      t_ctr_new = 7'h00;
      t_ctr_we  = 0;

      if (t_ctr_rst)
        begin
          t_ctr_new = 7'h00;
          t_ctr_we  = 1;
        end

      if (t_ctr_inc)
        begin
          t_ctr_new = t_ctr_reg + 1'b1;
          t_ctr_we  = 1;
        end
    end // t_ctr


  //----------------------------------------------------------------
  // work_factor_ctr
  //
  // Work factor counter logic.
  //----------------------------------------------------------------
  always @*
    begin : work_factor_ctr
      work_factor_ctr_new  = 32'h00000000;
      work_factor_ctr_we   = 0;
      work_factor_ctr_done = 0;

      if (work_factor_ctr_reg == work_factor_num)
        begin
          work_factor_ctr_done = 1;
        end

      if (work_factor_ctr_rst)
        begin
          work_factor_ctr_new  = 32'h00000000;
          work_factor_ctr_we   = 1;
        end

      if (work_factor_ctr_inc)
        begin
          work_factor_ctr_new  = work_factor_ctr_reg + 1'b1;
          work_factor_ctr_we   = 1;
        end
    end // work_factor_ctr


  //----------------------------------------------------------------
  // sha512_ctrl_fsm
  //
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @*
    begin : sha512_ctrl_fsm
      digest_init         = 0;
      digest_update       = 0;

      state_init          = 0;
      state_update        = 0;

      first_block         = 0;
      ready_flag          = 0;

      w_init              = 0;
      w_next              = 0;

      t_ctr_inc           = 0;
      t_ctr_rst           = 0;

      digest_valid_new    = 0;
      digest_valid_we     = 0;

      work_factor_ctr_rst = 0;
      work_factor_ctr_inc = 0;

      sha512_ctrl_new     = CTRL_IDLE;
      sha512_ctrl_we      = 0;


      case (sha512_ctrl_reg)
        CTRL_IDLE:
          begin
            ready_flag = 1;

            if (init)
              begin
                work_factor_ctr_rst = 1;
                digest_init         = 1;
                w_init              = 1;
                state_init          = 1;
                first_block         = 1;
                t_ctr_rst           = 1;
                digest_valid_new    = 0;
                digest_valid_we     = 1;
                sha512_ctrl_new     = CTRL_ROUNDS;
                sha512_ctrl_we      = 1;
              end

            if (next)
              begin
                work_factor_ctr_rst = 1;
                w_init              = 1;
                state_init          = 1;
                t_ctr_rst           = 1;
                digest_valid_new    = 0;
                digest_valid_we     = 1;
                sha512_ctrl_new     = CTRL_ROUNDS;
                sha512_ctrl_we      = 1;
              end
          end


        CTRL_ROUNDS:
          begin
            w_next       = 1;
            state_update = 1;
            t_ctr_inc    = 1;

            if (t_ctr_reg == SHA512_ROUNDS)
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
                if (!work_factor_ctr_done)
                  begin
                    w_init              = 1;
                    state_init          = 1;
                    t_ctr_rst           = 1;
                    sha512_ctrl_new     = CTRL_ROUNDS;
                    sha512_ctrl_we      = 1;
                  end
                else
                  begin
                    digest_update    = 1;
                    digest_valid_new = 1;
                    digest_valid_we  = 1;
                    sha512_ctrl_new  = CTRL_IDLE;
                    sha512_ctrl_we   = 1;
                  end
              end
            else
              begin
                digest_update    = 1;
                digest_valid_new = 1;
                digest_valid_we  = 1;
                sha512_ctrl_new  = CTRL_IDLE;
                sha512_ctrl_we   = 1;
              end
          end
      endcase // case (sha512_ctrl_reg)
    end // sha512_ctrl_fsm

endmodule // sha512_core

//======================================================================
// EOF sha512_core.v
//======================================================================
