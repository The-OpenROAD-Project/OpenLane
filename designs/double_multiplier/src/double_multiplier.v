//IEEE Floating Point Multiplier (Double Precision)
//Copyright (C) Jonathan P Dawson 2014
//2014-01-10
module double_multiplier(
        input_a,
        input_b,
        input_a_stb,
        input_b_stb,
        output_z_ack,
        clk,
        rst,
        output_z,
        output_z_stb,
        input_a_ack,
        input_b_ack);

  input     clk;
  input     rst;

  input     [63:0] input_a;
  input     input_a_stb;
  output    input_a_ack;

  input     [63:0] input_b;
  input     input_b_stb;
  output    input_b_ack;

  output    [63:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       s_output_z_stb;
  reg       [63:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [3:0] state;
  parameter get_a         = 4'd0,
            get_b         = 4'd1,
            unpack        = 4'd2,
            special_cases = 4'd3,
            normalise_a   = 4'd4,
            normalise_b   = 4'd5,
            multiply_0    = 4'd6,
            multiply_1    = 4'd7,
            normalise_1   = 4'd8,
            normalise_2   = 4'd9,
            round         = 4'd10,
            pack          = 4'd11,
            put_z         = 4'd12;

  reg       [63:0] a, b, z;
  reg       [52:0] a_m, b_m, z_m;
  reg       [12:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [107:0] product;

  always @(posedge clk)
  begin

    case(state)

      get_a:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a <= input_a;
          s_input_a_ack <= 0;
          state <= get_b;
        end
      end

      get_b:
      begin
        s_input_b_ack <= 1;
        if (s_input_b_ack && input_b_stb) begin
          b <= input_b;
          s_input_b_ack <= 0;
          state <= unpack;
        end
      end

      unpack:
      begin
        a_m <= a[51 : 0];
        b_m <= b[51 : 0];
        a_e <= a[62 : 52] - 1023;
        b_e <= b[62 : 52] - 1023;
        a_s <= a[63];
        b_s <= b[63];
        state <= special_cases;
      end

      special_cases:
      begin
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 1024 && a_m != 0) || (b_e == 1024 && b_m != 0)) begin
          z[63] <= 1;
          z[62:52] <= 2047;
          z[51] <= 1;
          z[50:0] <= 0;
          state <= put_z;
        //if a is inf return inf
        end else if (a_e == 1024) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 2047;
          z[51:0] <= 0;
          state <= put_z;
          //if b is zero return NaN
          if (($signed(b_e) == -1023) && (b_m == 0)) begin
            z[63] <= 1;
            z[62:52] <= 2047;
            z[51] <= 1;
            z[50:0] <= 0;
            state <= put_z;
          end
        //if b is inf return inf
        end else if (b_e == 1024) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 2047;
          z[51:0] <= 0;
          //if b is zero return NaN
          if (($signed(a_e) == -1023) && (a_m == 0)) begin
            z[63] <= 1;
            z[62:52] <= 2047;
            z[51] <= 1;
            z[50:0] <= 0;
            state <= put_z;
          end
          state <= put_z;
        //if a is zero return zero
        end else if (($signed(a_e) == -1023) && (a_m == 0)) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 0;
          z[51:0] <= 0;
          state <= put_z;
        //if b is zero return zero
        end else if (($signed(b_e) == -1023) && (b_m == 0)) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 0;
          z[51:0] <= 0;
          state <= put_z;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -1023) begin
            a_e <= -1022;
          end else begin
            a_m[52] <= 1;
          end
          //Denormalised Number
          if ($signed(b_e) == -1023) begin
            b_e <= -1022;
          end else begin
            b_m[52] <= 1;
          end
          state <= normalise_a;
        end
      end

      normalise_a:
      begin
        if (a_m[52]) begin
          state <= normalise_b;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      normalise_b:
      begin
        if (b_m[52]) begin
          state <= multiply_0;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end
      end

      multiply_0:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e + b_e + 1;
        product <= a_m * b_m * 4;
        state <= multiply_1;
      end

      multiply_1:
      begin
        z_m <= product[107:55];
        guard <= product[54];
        round_bit <= product[53];
        sticky <= (product[52:0] != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[52] == 0) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
        end else begin
          state <= normalise_2;
        end
      end

      normalise_2:
      begin
        if ($signed(z_e) < -1022) begin
          z_e <= z_e + 1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 53'h1fffffffffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end

      pack:
      begin
        z[51 : 0] <= z_m[51:0];
        z[62 : 52] <= z_e[11:0] + 1023;
        z[63] <= z_s;
        if ($signed(z_e) == -1022 && z_m[52] == 0) begin
          z[62 : 52] <= 0;
        end
        //if overflow occurs, return inf
        if ($signed(z_e) > 1023) begin
          z[51 : 0] <= 0;
          z[62 : 52] <= 2047;
          z[63] <= z_s;
        end
        state <= put_z;
      end

      put_z:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        if (s_output_z_stb && output_z_ack) begin
          s_output_z_stb <= 0;
          state <= get_a;
        end
      end

    endcase

    if (rst == 1) begin
      state <= get_a;
      s_input_a_ack <= 0;
      s_input_b_ack <= 0;
      s_output_z_stb <= 0;
    end

  end
  assign input_a_ack = s_input_a_ack;
  assign input_b_ack = s_input_b_ack;
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
