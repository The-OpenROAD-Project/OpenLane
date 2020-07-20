//IEEE Floating Point Divider (Double Precision)
//Copyright (C) Jonathan P Dawson 2014
//2014-01-11
//
module double_divider(
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
            divide_0      = 4'd6,
            divide_1      = 4'd7,
            divide_2      = 4'd8,
            divide_3      = 4'd9,
            normalise_1   = 4'd10,
            normalise_2   = 4'd11,
            round         = 4'd12,
            pack          = 4'd13,
            put_z         = 4'd14;

  reg       [63:0] a, b, z;
  reg       [52:0] a_m, b_m, z_m;
  reg       [12:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [108:0] quotient, divisor, dividend, remainder;
  reg       [6:0] count;

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
          //if a is inf and b is inf return NaN 
        end else if ((a_e == 1024) && (b_e == 1024)) begin
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
          if ($signed(b_e == -1023) && (b_m == 0)) begin
            z[63] <= 1;
            z[62:52] <= 2047;
            z[51] <= 1;
            z[50:0] <= 0;
            state <= put_z;
          end
        //if b is inf return zero
        end else if (b_e == 1024) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 0;
          z[51:0] <= 0;
          state <= put_z;
        //if a is zero return zero
        end else if (($signed(a_e) == -1023) && (a_m == 0)) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 0;
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
        //if b is zero return inf
        end else if (($signed(b_e) == -1023) && (b_m == 0)) begin
          z[63] <= a_s ^ b_s;
          z[62:52] <= 2047;
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
          state <= divide_0;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end
      end

      divide_0:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e - b_e;
        quotient <= 0;
        remainder <= 0;
        count <= 0;
        dividend <= a_m << 56;
        divisor <= b_m;
        state <= divide_1;
      end

      divide_1:
      begin
        quotient <= quotient << 1;
        remainder <= remainder << 1;
        remainder[0] <= dividend[108];
        dividend <= dividend << 1;
        state <= divide_2;
      end

      divide_2:
      begin
        if (remainder >= divisor) begin
          quotient[0] <= 1;
          remainder <= remainder - divisor;
        end
        if (count == 107) begin
          state <= divide_3;
        end else begin
          count <= count + 1;
          state <= divide_1;
        end
      end

      divide_3:
      begin
        z_m <= quotient[55:3];
        guard <= quotient[2];
        round_bit <= quotient[1];
        sticky <= quotient[0] | (remainder != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[52] == 0 && $signed(z_e) > -1022) begin
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
          if (z_m == 53'hffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end

      pack:
      begin
        z[51 : 0] <= z_m[51:0];
        z[62 : 52] <= z_e[10:0] + 1023;
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
