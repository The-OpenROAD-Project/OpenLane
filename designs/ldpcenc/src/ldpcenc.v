//==============================================================================
// ldpcenc.v
//
// Top module of Wi-Fi LDPC encoder.
//------------------------------------------------------------------------------
// Copyright (c) 2019 Guangxi Liu
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.
//==============================================================================


module ldpcenc (
    // System signals
    input clk,                  // system clock
    input rst_n,                // system asynchronous reset, active low
    input srst,                 // synchronous reset

    // Data interface
    input vld_in,               // input data valid
    input sop_in,               // input start of packet
    input [3:0] mode_in,        // input encoder mode, [1:0]:rate, [3:2]:codeword length
    input [26:0] data_in,       // input data
    output rdy_in,              // ready to receive input data
    output vld_out,             // output data valid
    output sop_out,             // output start of packet
    output [26:0] data_out      // output data
);

// Local signals
wire [1:0] state;
wire [3:0] mode;
wire [4:0] cnt_sym;
wire [1:0] cnt_vld;
wire [1:0] cnt_vld_max;
wire clr_acc;
wire vld;
wire [26:0] data_r1;
wire [26:0] data_r2;
wire [26:0] data_r3;


// Instances
ldpcenc_cu u_ldpcenc_cu (
    .clk            (clk),
    .rst_n          (rst_n),
    .srst           (srst),
    .vld_in         (vld_in),
    .sop_in         (sop_in),
    .mode_in        (mode_in),
    .data_in        (data_in),
    .rdy_in         (rdy_in),
    .vld_out        (vld_out),
    .sop_out        (sop_out),
    .state          (state),
    .mode           (mode),
    .cnt_sym        (cnt_sym),
    .cnt_vld        (cnt_vld),
    .cnt_vld_max    (cnt_vld_max),
    .clr_acc        (clr_acc),
    .vld            (vld),
    .data_r1        (data_r1),
    .data_r2        (data_r2),
    .data_r3        (data_r3)
);

ldpcenc_dpu u_ldpcenc_dpu (
    .clk            (clk),
    .rst_n          (rst_n),
    .state          (state),
    .mode           (mode),
    .cnt_sym        (cnt_sym),
    .cnt_vld        (cnt_vld),
    .cnt_vld_max    (cnt_vld_max),
    .clr_acc        (clr_acc),
    .vld            (vld),
    .data_r1        (data_r1),
    .data_r2        (data_r2),
    .data_r3        (data_r3),
    .data_out       (data_out)
);


endmodule

module ldpcenc_cu (
    // System signals
    input clk,                      // system clock
    input rst_n,                    // system asynchronous reset, active low
    input srst,                     // synchronous reset

    // Data interface
    input vld_in,                   // input data valid
    input sop_in,                   // input start of packet
    input [3:0] mode_in,            // input encoder mode, [1:0]:rate, [3:2]:codeword length
    input [26:0] data_in,           // input data
    output rdy_in,                  // ready to receive input data
    output reg vld_out,             // output data valid
    output reg sop_out,             // output start of packet
    output [1:0] state,             // current state
    output reg [3:0] mode,          // input encoder mode, [1:0]:rate, [3:2]:codeword length
    output reg [4:0] cnt_sym,       // counter of symbol
    output reg [1:0] cnt_vld,       // counter of valid
    output reg [1:0] cnt_vld_max,   // maximum value of counter of valid
    output clr_acc,                 // clear accumulator
    output reg vld,                 // data valid
    output reg [26:0] data_r1,      // registered data 1
    output reg [26:0] data_r2,      // registered data 2
    output reg [26:0] data_r3       // registered data 3
);

// Local parameters
localparam ST_IDLE = 2'd0;
localparam ST_MSG  = 2'd1;
localparam ST_WAIT = 2'd2;
localparam ST_PRT  = 2'd3;


// Local signals
reg [1:0] cs, ns;
reg sop;
reg [4:0] msg_sym_len;
reg [4:0] prt_sym_len;


// FSM
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs <= ST_IDLE;
    else if (srst)
        cs <= ST_IDLE;
    else
        cs <= ns;
end

always @ (*) begin
    ns = cs;
    case (cs)
        ST_IDLE: if (sop_in)    ns = ST_MSG;
        ST_MSG: if (cnt_sym == msg_sym_len && cnt_vld == cnt_vld_max)    ns = ST_WAIT;
        ST_WAIT: ns = ST_PRT;
        ST_PRT: if (cnt_sym == prt_sym_len && cnt_vld == cnt_vld_max)    ns = ST_IDLE;
        default: ns = ST_IDLE;
    endcase
end

assign state = cs;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sop <= 1'b0;
    else if (cs == ST_IDLE && sop_in == 1'b1)
        sop <= 1'b1;
    else
        sop <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        vld <= 1'b0;
    else
        vld <= vld_in;
end

assign clr_acc = sop;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        mode <= 4'd0;
    else if (cs == ST_IDLE && sop_in == 1'b1)
        mode <= mode_in;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        msg_sym_len <= 5'd0;
    else if (cs == ST_IDLE && sop_in == 1'b1) begin
        case (mode_in[1:0])
            2'd0: msg_sym_len <= 5'd11;
            2'd1: msg_sym_len <= 5'd15;
            2'd2: msg_sym_len <= 5'd17;
            2'd3: msg_sym_len <= 5'd19;
            default: msg_sym_len <= 5'd11;
        endcase
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        prt_sym_len <= 5'd0;
    else if (cs == ST_IDLE && sop_in == 1'b1) begin
        case (mode_in[1:0])
            2'd0: prt_sym_len <= 5'd11;
            2'd1: prt_sym_len <= 5'd7;
            2'd2: prt_sym_len <= 5'd5;
            2'd3: prt_sym_len <= 5'd3;
            default: prt_sym_len <= 5'd11;
        endcase
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_vld_max <= 2'd0;
    else if (cs == ST_IDLE && sop_in == 1'b1)
        cnt_vld_max <= mode_in[3:2];
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_sym <= 5'd0;
    else if (cs == ST_MSG) begin
        if (vld_in == 1'b1 && cnt_vld == cnt_vld_max)
            cnt_sym <= cnt_sym + 1'b1;
    end
    else if (cs == ST_PRT) begin
        if (cnt_vld == cnt_vld_max)
            cnt_sym <= cnt_sym + 1'b1;
    end
    else
        cnt_sym <= 5'd0;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_vld <= 2'd0;
    else if (cs == ST_MSG) begin
        if (vld_in)
            cnt_vld <= (cnt_vld == cnt_vld_max) ? 2'd0 : (cnt_vld + 1'b1);
    end
    else if (cs == ST_PRT) begin
        cnt_vld <= (cnt_vld == cnt_vld_max) ? 2'd0 : (cnt_vld + 1'b1);
    end
    else
        cnt_vld <= 2'd0;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_r1 <= 27'd0;
        data_r2 <= 27'd0;
        data_r3 <= 27'd0;
    end
    else if ((cs == ST_IDLE && sop_in == 1'b1) || (cs == ST_MSG && vld_in == 1'b1)) begin
        data_r1 <= data_in;
        data_r2 <= data_r1;
        data_r3 <= data_r2;
    end
end


// Output data
assign rdy_in = (cs == ST_IDLE || cs == ST_MSG) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sop_out <= 1'b0;
    else if (cs == ST_MSG)
        sop_out <= sop;
    else
        sop_out <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        vld_out <= 1'b0;
    else if (cs == ST_MSG)
        vld_out <= vld;
    else if (cs == ST_PRT)
        vld_out <= 1'b1;
    else
        vld_out <= 1'b0;
end


endmodule

module ldpcenc_dpu (
    // System signals
    input clk,                  // system clock
    input rst_n,                // system asynchronous reset, active low

    // Data interface
    input [1:0] state,          // current state
    input [3:0] mode,           // input encoder mode, [1:0]:rate, [3:2]:codeword length
    input [4:0] cnt_sym,        // counter of symbol
    input [1:0] cnt_vld,        // counter of valid
    input [1:0] cnt_vld_max,    // maximum value of counter of valid
    input clr_acc,              // clear accumulator
    input vld,                  // valid input
    input [26:0] data_r1,       // registered data 1
    input [26:0] data_r2,       // registered data 2
    input [26:0] data_r3,       // registered data 3
    output reg [26:0] data_out  // output data
);

// Local parameters
localparam ST_IDLE = 2'd0;
localparam ST_MSG  = 2'd1;
localparam ST_WAIT = 2'd2;
localparam ST_PRT  = 2'd3;


// Local signals
wire [8:0] addr;
reg [80:0] msg;
wire z54;
reg en_acc;
reg [3:0] sel_xi;
reg [1:0] sel_p0;
reg sel_pi;
wire en_pi;
reg [4:0] cnt_sym_mid;
wire [7:0] sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8, sh9, sh10, sh11, sh12;
wire [80:0] rcs1, rcs2, rcs3, rcs4, rcs5, rcs6, rcs7, rcs8, rcs9, rcs10, rcs11, rcs12;
reg [80:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12;
wire [80:0] p0;
wire [80:0] p0_rsh1;
reg [80:0] xi;
wire [80:0] p0_mux, pi_mux;
reg [80:0] pi;
wire [80:0] prt;


// Control signals
assign addr = {mode, cnt_sym};

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        msg <= 81'd0;
    else if (state == ST_MSG) begin
        if (mode[3:2] == 2'd0)
            msg <= {data_r1, data_r1, data_r1};
        else if (mode[3:2] == 2'd1)
            msg <= {data_r1, data_r1, data_r2};
        else
            msg <= {data_r1, data_r2, data_r3};
    end
end

assign z54 = (mode[3:2] == 2'd1) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        en_acc <= 1'b0;
    else if (state == ST_MSG && vld == 1'b1 && cnt_vld == cnt_vld_max)
        en_acc <= 1'b1;
    else
        en_acc <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sel_xi <= 4'd0;
    else if (state == ST_PRT) begin
        if (cnt_vld == cnt_vld_max)
            sel_xi <= cnt_sym[3:0];
    end
    else
        sel_xi <= 4'd15;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sel_p0 <= 2'd0;
    else if (state == ST_WAIT)
        sel_p0 <= 2'd1;
    else if (state == ST_PRT) begin
        if (cnt_vld == cnt_vld_max) begin
            if (cnt_sym == 5'd0)
                sel_p0 <= 2'd2;
            else if (cnt_sym == cnt_sym_mid)
                sel_p0 <= 2'd1;
            else
                sel_p0 <= 2'd0;
        end
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        sel_pi <= 1'b0;
    else if (state == ST_PRT) begin
        if (cnt_vld == cnt_vld_max && cnt_sym != 5'd0)
            sel_pi <= 1'b1;
    end
    else
        sel_pi <= 1'b0;
end

assign en_pi = (state == ST_PRT && cnt_vld == cnt_vld_max) ? 1'b1 : 1'b0;

always @ (*) begin
    case (mode[1:0])
        2'd0: cnt_sym_mid = 5'd6;
        2'd1: cnt_sym_mid = 5'd4;
        2'd2: cnt_sym_mid = 5'd3;
        2'd3: cnt_sym_mid = 5'd2;
        default: cnt_sym_mid = 5'd6;
    endcase
end


// Processing unit
ldpcenc_tbl u_ldpcenc_tbl (
    .clk            (clk),
    .addr           (addr),
    .sh1            (sh1),
    .sh2            (sh2),
    .sh3            (sh3),
    .sh4            (sh4),
    .sh5            (sh5),
    .sh6            (sh6),
    .sh7            (sh7),
    .sh8            (sh8),
    .sh9            (sh9),
    .sh10           (sh10),
    .sh11           (sh11),
    .sh12           (sh12)
);

ldpcenc_rcs u1_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh1),
    .d_out          (rcs1)
);

ldpcenc_rcs u2_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh2),
    .d_out          (rcs2)
);

ldpcenc_rcs u3_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh3),
    .d_out          (rcs3)
);

ldpcenc_rcs u4_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh4),
    .d_out          (rcs4)
);

ldpcenc_rcs u5_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh5),
    .d_out          (rcs5)
);

ldpcenc_rcs u6_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh6),
    .d_out          (rcs6)
);

ldpcenc_rcs u7_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh7),
    .d_out          (rcs7)
);

ldpcenc_rcs u8_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh8),
    .d_out          (rcs8)
);

ldpcenc_rcs u9_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh9),
    .d_out          (rcs9)
);

ldpcenc_rcs u10_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh10),
    .d_out          (rcs10)
);

ldpcenc_rcs u11_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh11),
    .d_out          (rcs11)
);

ldpcenc_rcs u12_ldpcenc_rcs (
    .d_in           (msg),
    .z54            (z54),
    .sh             (sh12),
    .d_out          (rcs12)
);

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x1 <= 81'd0;
        x2 <= 81'd0;
        x3 <= 81'd0;
        x4 <= 81'd0;
        x5 <= 81'd0;
        x6 <= 81'd0;
        x7 <= 81'd0;
        x8 <= 81'd0;
        x9 <= 81'd0;
        x10 <= 81'd0;
        x11 <= 81'd0;
        x12 <= 81'd0;
    end
    else if (clr_acc) begin
        x1 <= 81'd0;
        x2 <= 81'd0;
        x3 <= 81'd0;
        x4 <= 81'd0;
        x5 <= 81'd0;
        x6 <= 81'd0;
        x7 <= 81'd0;
        x8 <= 81'd0;
        x9 <= 81'd0;
        x10 <= 81'd0;
        x11 <= 81'd0;
        x12 <= 81'd0;
    end
    else if (en_acc) begin
        x1 <= x1 ^ rcs1;
        x2 <= x2 ^ rcs2;
        x3 <= x3 ^ rcs3;
        x4 <= x4 ^ rcs4;
        x5 <= x5 ^ rcs5;
        x6 <= x6 ^ rcs6;
        x7 <= x7 ^ rcs7;
        x8 <= x8 ^ rcs8;
        x9 <= x9 ^ rcs9;
        x10 <= x10 ^ rcs10;
        x11 <= x11 ^ rcs11;
        x12 <= x12 ^ rcs12;
    end
end

assign p0 = x1 ^ x2 ^ x3 ^ x4 ^ x5 ^ x6 ^ x7 ^ x8 ^ x9 ^ x10 ^ x11 ^ x12;

always @ (*) begin
    case (sel_xi)
        4'd0 : xi = x1;
        4'd1 : xi = x2;
        4'd2 : xi = x3;
        4'd3 : xi = x4;
        4'd4 : xi = x5;
        4'd5 : xi = x6;
        4'd6 : xi = x7;
        4'd7 : xi = x8;
        4'd8 : xi = x9;
        4'd9 : xi = x10;
        4'd10: xi = x11;
        4'd11: xi = x12;
        default: xi = 81'd0;
    endcase
end

assign p0_rsh1 = {p0[0], p0[80:55], ((z54) ? p0[0] : p0[54]), p0[53:1]};
assign p0_mux = (sel_p0 == 2'd0) ? 81'd0 : (sel_p0 == 2'd1) ? p0 : p0_rsh1;
assign pi_mux = (sel_pi) ? pi : 81'd0;
assign prt = p0_mux ^ pi_mux ^ xi;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        pi <= 81'd0;
     else if (en_pi)
        pi <= prt;
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_out <= 27'd0;
     else if (state == ST_MSG)
        data_out <= data_r1;
    else if (state == ST_PRT) begin
        if (cnt_vld == 2'd0)
            data_out <= prt[26:0];
        else if (cnt_vld == 2'd1)
            data_out <= prt[53:27];
        else
            data_out <= prt[80:54];
    end
end


endmodule

module ldpcenc_rcs (
    // Data interface
    input [80:0] d_in,          // input data
    input z54,                  // indicate Z = 54, 0:Z = 27 or 81, 1:Z = 54
    input [7:0] sh,             // [6:0]:right shift number, [7]:clear input, active low
    output [80:0] d_out         // output data
);

// Local signals
wire [80:0] dc;
wire [80:0] d0, d1, d2, d3, d4, d5, d6;
wire [53:0] d0_54, d1_54, d2_54, d3_54, d4_54, d5_54;
wire [53:0] mux_d54;


// Barrel shifter and multiplexer
assign dc = (sh[7]) ? d_in : 81'd0;

assign d0 = (sh[0]) ? {dc[0], dc[80:1]} : dc;
assign d1 = (sh[1]) ? {d0[1:0], d0[80:2]} : d0;
assign d2 = (sh[2]) ? {d1[3:0], d1[80:4]} : d1;
assign d3 = (sh[3]) ? {d2[7:0], d2[80:8]} : d2;
assign d4 = (sh[4]) ? {d3[15:0], d3[80:16]} : d3;
assign d5 = (sh[5]) ? {d4[31:0], d4[80:32]} : d4;
assign d6 = (sh[6]) ? {d5[63:0], d5[80:64]} : d5;

assign d0_54 = (sh[0]) ? {dc[0], dc[53:1]} : dc[53:0];
assign d1_54 = (sh[1]) ? {d0_54[1:0], d0_54[53:2]} : d0_54;
assign d2_54 = (sh[2]) ? {d1_54[3:0], d1_54[53:4]} : d1_54;
assign d3_54 = (sh[3]) ? {d2_54[7:0], d2_54[53:8]} : d2_54;
assign d4_54 = (sh[4]) ? {d3_54[15:0], d3_54[53:16]} : d3_54;
assign d5_54 = (sh[5]) ? {d4_54[31:0], d4_54[53:32]} : d4_54;

assign mux_d54 = (z54) ? d5_54 : d6[53:0];
assign d_out = {d6[80:54], mux_d54};


endmodule


module ldpcenc_tbl (
    // System signals
    input clk,                  // system clock

    // Data interface
    input [8:0] addr,           // read address, [4:0]:cnt, [6:5]:rate, [8:7]:codeword length
    output reg [7:0] sh1,       // shift number for RCS1
    output reg [7:0] sh2,       // shift number for RCS2
    output reg [7:0] sh3,       // shift number for RCS3
    output reg [7:0] sh4,       // shift number for RCS4
    output reg [7:0] sh5,       // shift number for RCS5
    output reg [7:0] sh6,       // shift number for RCS6
    output reg [7:0] sh7,       // shift number for RCS7
    output reg [7:0] sh8,       // shift number for RCS8
    output reg [7:0] sh9,       // shift number for RCS9
    output reg [7:0] sh10,      // shift number for RCS10
    output reg [7:0] sh11,      // shift number for RCS11
    output reg [7:0] sh12       // shift number for RCS12
);

// Local signals
reg [7:0] sh1_w;
reg [7:0] sh2_w;
reg [7:0] sh3_w;
reg [7:0] sh4_w;
reg [7:0] sh5_w;
reg [7:0] sh6_w;
reg [7:0] sh7_w;
reg [7:0] sh8_w;
reg [7:0] sh9_w;
reg [7:0] sh10_w;
reg [7:0] sh11_w;
reg [7:0] sh12_w;


// Tables
always @ (*) begin
    case (addr)
        9'b00_00_00000: sh1_w = 8'd128;
        9'b00_00_00100: sh1_w = 8'd128;
        9'b00_00_00101: sh1_w = 8'd128;
        9'b00_00_01000: sh1_w = 8'd128;
        9'b00_00_01011: sh1_w = 8'd128;
        9'b00_01_00000: sh1_w = 8'd153;
        9'b00_01_00001: sh1_w = 8'd154;
        9'b00_01_00010: sh1_w = 8'd142;
        9'b00_01_00100: sh1_w = 8'd148;
        9'b00_01_00110: sh1_w = 8'd130;
        9'b00_01_01000: sh1_w = 8'd132;
        9'b00_01_01011: sh1_w = 8'd136;
        9'b00_01_01101: sh1_w = 8'd144;
        9'b00_01_01111: sh1_w = 8'd146;
        9'b00_10_00000: sh1_w = 8'd144;
        9'b00_10_00001: sh1_w = 8'd145;
        9'b00_10_00010: sh1_w = 8'd150;
        9'b00_10_00011: sh1_w = 8'd152;
        9'b00_10_00100: sh1_w = 8'd137;
        9'b00_10_00101: sh1_w = 8'd131;
        9'b00_10_00110: sh1_w = 8'd142;
        9'b00_10_01000: sh1_w = 8'd132;
        9'b00_10_01001: sh1_w = 8'd130;
        9'b00_10_01010: sh1_w = 8'd135;
        9'b00_10_01100: sh1_w = 8'd154;
        9'b00_10_01110: sh1_w = 8'd130;
        9'b00_10_10000: sh1_w = 8'd149;
        9'b00_11_00000: sh1_w = 8'd145;
        9'b00_11_00001: sh1_w = 8'd141;
        9'b00_11_00010: sh1_w = 8'd136;
        9'b00_11_00011: sh1_w = 8'd149;
        9'b00_11_00100: sh1_w = 8'd137;
        9'b00_11_00101: sh1_w = 8'd131;
        9'b00_11_00110: sh1_w = 8'd146;
        9'b00_11_00111: sh1_w = 8'd140;
        9'b00_11_01000: sh1_w = 8'd138;
        9'b00_11_01001: sh1_w = 8'd128;
        9'b00_11_01010: sh1_w = 8'd132;
        9'b00_11_01011: sh1_w = 8'd143;
        9'b00_11_01100: sh1_w = 8'd147;
        9'b00_11_01101: sh1_w = 8'd130;
        9'b00_11_01110: sh1_w = 8'd133;
        9'b00_11_01111: sh1_w = 8'd138;
        9'b00_11_10000: sh1_w = 8'd154;
        9'b00_11_10001: sh1_w = 8'd147;
        9'b00_11_10010: sh1_w = 8'd141;
        9'b00_11_10011: sh1_w = 8'd141;
        9'b01_00_00000: sh1_w = 8'd168;
        9'b01_00_00100: sh1_w = 8'd150;
        9'b01_00_00110: sh1_w = 8'd177;
        9'b01_00_00111: sh1_w = 8'd151;
        9'b01_00_01000: sh1_w = 8'd171;
        9'b01_01_00000: sh1_w = 8'd167;
        9'b01_01_00001: sh1_w = 8'd159;
        9'b01_01_00010: sh1_w = 8'd150;
        9'b01_01_00011: sh1_w = 8'd171;
        9'b01_01_00101: sh1_w = 8'd168;
        9'b01_01_00110: sh1_w = 8'd132;
        9'b01_01_01000: sh1_w = 8'd139;
        9'b01_01_01011: sh1_w = 8'd178;
        9'b01_01_01111: sh1_w = 8'd134;
        9'b01_10_00000: sh1_w = 8'd167;
        9'b01_10_00001: sh1_w = 8'd168;
        9'b01_10_00010: sh1_w = 8'd179;
        9'b01_10_00011: sh1_w = 8'd169;
        9'b01_10_00100: sh1_w = 8'd131;
        9'b01_10_00101: sh1_w = 8'd157;
        9'b01_10_00110: sh1_w = 8'd136;
        9'b01_10_00111: sh1_w = 8'd164;
        9'b01_10_01001: sh1_w = 8'd142;
        9'b01_10_01011: sh1_w = 8'd134;
        9'b01_10_01101: sh1_w = 8'd161;
        9'b01_10_01111: sh1_w = 8'd139;
        9'b01_10_10001: sh1_w = 8'd132;
        9'b01_11_00000: sh1_w = 8'd176;
        9'b01_11_00001: sh1_w = 8'd157;
        9'b01_11_00010: sh1_w = 8'd165;
        9'b01_11_00011: sh1_w = 8'd180;
        9'b01_11_00100: sh1_w = 8'd130;
        9'b01_11_00101: sh1_w = 8'd144;
        9'b01_11_00110: sh1_w = 8'd134;
        9'b01_11_00111: sh1_w = 8'd142;
        9'b01_11_01000: sh1_w = 8'd181;
        9'b01_11_01001: sh1_w = 8'd159;
        9'b01_11_01010: sh1_w = 8'd162;
        9'b01_11_01011: sh1_w = 8'd133;
        9'b01_11_01100: sh1_w = 8'd146;
        9'b01_11_01101: sh1_w = 8'd170;
        9'b01_11_01110: sh1_w = 8'd181;
        9'b01_11_01111: sh1_w = 8'd159;
        9'b01_11_10000: sh1_w = 8'd173;
        9'b01_11_10010: sh1_w = 8'd174;
        9'b01_11_10011: sh1_w = 8'd180;
        9'b10_00_00000: sh1_w = 8'd185;
        9'b10_00_00100: sh1_w = 8'd178;
        9'b10_00_00110: sh1_w = 8'd139;
        9'b10_00_01000: sh1_w = 8'd178;
        9'b10_00_01010: sh1_w = 8'd207;
        9'b10_01_00000: sh1_w = 8'd189;
        9'b10_01_00001: sh1_w = 8'd203;
        9'b10_01_00010: sh1_w = 8'd132;
        9'b10_01_00011: sh1_w = 8'd191;
        9'b10_01_00100: sh1_w = 8'd184;
        9'b10_01_01011: sh1_w = 8'd136;
        9'b10_01_01101: sh1_w = 8'd130;
        9'b10_01_01110: sh1_w = 8'd145;
        9'b10_01_01111: sh1_w = 8'd153;
        9'b10_10_00000: sh1_w = 8'd176;
        9'b10_10_00001: sh1_w = 8'd157;
        9'b10_10_00010: sh1_w = 8'd156;
        9'b10_10_00011: sh1_w = 8'd167;
        9'b10_10_00100: sh1_w = 8'd137;
        9'b10_10_00101: sh1_w = 8'd189;
        9'b10_10_01001: sh1_w = 8'd191;
        9'b10_10_01010: sh1_w = 8'd173;
        9'b10_10_01011: sh1_w = 8'd208;
        9'b10_10_01111: sh1_w = 8'd165;
        9'b10_10_10000: sh1_w = 8'd160;
        9'b10_10_10001: sh1_w = 8'd150;
        9'b10_11_00000: sh1_w = 8'd141;
        9'b10_11_00001: sh1_w = 8'd176;
        9'b10_11_00010: sh1_w = 8'd208;
        9'b10_11_00011: sh1_w = 8'd194;
        9'b10_11_00100: sh1_w = 8'd132;
        9'b10_11_00101: sh1_w = 8'd202;
        9'b10_11_00110: sh1_w = 8'd135;
        9'b10_11_00111: sh1_w = 8'd158;
        9'b10_11_01000: sh1_w = 8'd204;
        9'b10_11_01001: sh1_w = 8'd180;
        9'b10_11_01010: sh1_w = 8'd165;
        9'b10_11_01011: sh1_w = 8'd188;
        9'b10_11_01101: sh1_w = 8'd177;
        9'b10_11_01110: sh1_w = 8'd201;
        9'b10_11_01111: sh1_w = 8'd159;
        9'b10_11_10000: sh1_w = 8'd202;
        9'b10_11_10001: sh1_w = 8'd201;
        9'b10_11_10010: sh1_w = 8'd151;
        default: sh1_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh2_w = 8'd150;
        9'b00_00_00001: sh2_w = 8'd128;
        9'b00_00_00100: sh2_w = 8'd145;
        9'b00_00_00110: sh2_w = 8'd128;
        9'b00_00_00111: sh2_w = 8'd128;
        9'b00_00_01000: sh2_w = 8'd140;
        9'b00_01_00000: sh2_w = 8'd138;
        9'b00_01_00001: sh2_w = 8'd137;
        9'b00_01_00010: sh2_w = 8'd143;
        9'b00_01_00011: sh2_w = 8'd139;
        9'b00_01_00101: sh2_w = 8'd128;
        9'b00_01_00111: sh2_w = 8'd129;
        9'b00_01_01010: sh2_w = 8'd146;
        9'b00_01_01100: sh2_w = 8'd136;
        9'b00_01_01110: sh2_w = 8'd138;
        9'b00_10_00000: sh2_w = 8'd153;
        9'b00_10_00001: sh2_w = 8'd140;
        9'b00_10_00010: sh2_w = 8'd140;
        9'b00_10_00011: sh2_w = 8'd131;
        9'b00_10_00100: sh2_w = 8'd131;
        9'b00_10_00101: sh2_w = 8'd154;
        9'b00_10_00110: sh2_w = 8'd134;
        9'b00_10_00111: sh2_w = 8'd149;
        9'b00_10_01001: sh2_w = 8'd143;
        9'b00_10_01010: sh2_w = 8'd150;
        9'b00_10_01100: sh2_w = 8'd143;
        9'b00_10_01110: sh2_w = 8'd132;
        9'b00_10_10001: sh2_w = 8'd144;
        9'b00_11_00000: sh2_w = 8'd131;
        9'b00_11_00001: sh2_w = 8'd140;
        9'b00_11_00010: sh2_w = 8'd139;
        9'b00_11_00011: sh2_w = 8'd142;
        9'b00_11_00100: sh2_w = 8'd139;
        9'b00_11_00101: sh2_w = 8'd153;
        9'b00_11_00110: sh2_w = 8'd133;
        9'b00_11_00111: sh2_w = 8'd146;
        9'b00_11_01000: sh2_w = 8'd128;
        9'b00_11_01001: sh2_w = 8'd137;
        9'b00_11_01010: sh2_w = 8'd130;
        9'b00_11_01011: sh2_w = 8'd154;
        9'b00_11_01100: sh2_w = 8'd154;
        9'b00_11_01101: sh2_w = 8'd138;
        9'b00_11_01110: sh2_w = 8'd152;
        9'b00_11_01111: sh2_w = 8'd135;
        9'b00_11_10000: sh2_w = 8'd142;
        9'b00_11_10001: sh2_w = 8'd148;
        9'b00_11_10010: sh2_w = 8'd132;
        9'b00_11_10011: sh2_w = 8'd130;
        9'b01_00_00000: sh2_w = 8'd178;
        9'b01_00_00001: sh2_w = 8'd129;
        9'b01_00_00100: sh2_w = 8'd176;
        9'b01_00_00101: sh2_w = 8'd163;
        9'b01_00_01000: sh2_w = 8'd141;
        9'b01_00_01010: sh2_w = 8'd158;
        9'b01_01_00000: sh2_w = 8'd153;
        9'b01_01_00001: sh2_w = 8'd180;
        9'b01_01_00010: sh2_w = 8'd169;
        9'b01_01_00011: sh2_w = 8'd130;
        9'b01_01_00100: sh2_w = 8'd134;
        9'b01_01_00110: sh2_w = 8'd142;
        9'b01_01_01000: sh2_w = 8'd162;
        9'b01_01_01100: sh2_w = 8'd152;
        9'b01_01_01110: sh2_w = 8'd165;
        9'b01_10_00000: sh2_w = 8'd176;
        9'b01_10_00001: sh2_w = 8'd149;
        9'b01_10_00010: sh2_w = 8'd175;
        9'b01_10_00011: sh2_w = 8'd137;
        9'b01_10_00100: sh2_w = 8'd176;
        9'b01_10_00101: sh2_w = 8'd163;
        9'b01_10_00110: sh2_w = 8'd179;
        9'b01_10_01000: sh2_w = 8'd166;
        9'b01_10_01010: sh2_w = 8'd156;
        9'b01_10_01100: sh2_w = 8'd162;
        9'b01_10_01110: sh2_w = 8'd178;
        9'b01_10_10000: sh2_w = 8'd178;
        9'b01_11_00000: sh2_w = 8'd145;
        9'b01_11_00001: sh2_w = 8'd132;
        9'b01_11_00010: sh2_w = 8'd158;
        9'b01_11_00011: sh2_w = 8'd135;
        9'b01_11_00100: sh2_w = 8'd171;
        9'b01_11_00101: sh2_w = 8'd139;
        9'b01_11_00110: sh2_w = 8'd152;
        9'b01_11_00111: sh2_w = 8'd134;
        9'b01_11_01000: sh2_w = 8'd142;
        9'b01_11_01001: sh2_w = 8'd149;
        9'b01_11_01010: sh2_w = 8'd134;
        9'b01_11_01011: sh2_w = 8'd167;
        9'b01_11_01100: sh2_w = 8'd145;
        9'b01_11_01101: sh2_w = 8'd168;
        9'b01_11_01110: sh2_w = 8'd175;
        9'b01_11_01111: sh2_w = 8'd135;
        9'b01_11_10000: sh2_w = 8'd143;
        9'b01_11_10001: sh2_w = 8'd169;
        9'b01_11_10010: sh2_w = 8'd147;
        9'b10_00_00000: sh2_w = 8'd131;
        9'b10_00_00010: sh2_w = 8'd156;
        9'b10_00_00100: sh2_w = 8'd128;
        9'b10_00_01000: sh2_w = 8'd183;
        9'b10_00_01001: sh2_w = 8'd135;
        9'b10_01_00000: sh2_w = 8'd184;
        9'b10_01_00001: sh2_w = 8'd202;
        9'b10_01_00010: sh2_w = 8'd205;
        9'b10_01_00011: sh2_w = 8'd148;
        9'b10_01_00111: sh2_w = 8'd192;
        9'b10_01_01000: sh2_w = 8'd152;
        9'b10_01_01001: sh2_w = 8'd132;
        9'b10_01_01010: sh2_w = 8'd195;
        9'b10_01_01100: sh2_w = 8'd135;
        9'b10_10_00000: sh2_w = 8'd132;
        9'b10_10_00001: sh2_w = 8'd177;
        9'b10_10_00010: sh2_w = 8'd170;
        9'b10_10_00011: sh2_w = 8'd176;
        9'b10_10_00100: sh2_w = 8'd139;
        9'b10_10_00101: sh2_w = 8'd158;
        9'b10_10_01001: sh2_w = 8'd177;
        9'b10_10_01010: sh2_w = 8'd145;
        9'b10_10_01011: sh2_w = 8'd169;
        9'b10_10_01100: sh2_w = 8'd165;
        9'b10_10_01101: sh2_w = 8'd143;
        9'b10_10_01111: sh2_w = 8'd182;
        9'b10_11_00000: sh2_w = 8'd197;
        9'b10_11_00001: sh2_w = 8'd191;
        9'b10_11_00010: sh2_w = 8'd202;
        9'b10_11_00011: sh2_w = 8'd184;
        9'b10_11_00100: sh2_w = 8'd192;
        9'b10_11_00101: sh2_w = 8'd205;
        9'b10_11_00110: sh2_w = 8'd185;
        9'b10_11_00111: sh2_w = 8'd193;
        9'b10_11_01000: sh2_w = 8'd134;
        9'b10_11_01001: sh2_w = 8'd144;
        9'b10_11_01010: sh2_w = 8'd179;
        9'b10_11_01100: sh2_w = 8'd192;
        9'b10_11_01110: sh2_w = 8'd196;
        9'b10_11_01111: sh2_w = 8'd137;
        9'b10_11_10000: sh2_w = 8'd176;
        9'b10_11_10001: sh2_w = 8'd190;
        9'b10_11_10010: sh2_w = 8'd182;
        9'b10_11_10011: sh2_w = 8'd155;
        default: sh2_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh3_w = 8'd134;
        9'b00_00_00010: sh3_w = 8'd128;
        9'b00_00_00100: sh3_w = 8'd138;
        9'b00_00_01000: sh3_w = 8'd152;
        9'b00_00_01010: sh3_w = 8'd128;
        9'b00_01_00000: sh3_w = 8'd144;
        9'b00_01_00001: sh3_w = 8'd130;
        9'b00_01_00010: sh3_w = 8'd148;
        9'b00_01_00011: sh3_w = 8'd154;
        9'b00_01_00100: sh3_w = 8'd149;
        9'b00_01_00110: sh3_w = 8'd134;
        9'b00_01_01000: sh3_w = 8'd129;
        9'b00_01_01001: sh3_w = 8'd154;
        9'b00_01_01011: sh3_w = 8'd135;
        9'b00_10_00000: sh3_w = 8'd153;
        9'b00_10_00001: sh3_w = 8'd146;
        9'b00_10_00010: sh3_w = 8'd154;
        9'b00_10_00011: sh3_w = 8'd144;
        9'b00_10_00100: sh3_w = 8'd150;
        9'b00_10_00101: sh3_w = 8'd151;
        9'b00_10_00110: sh3_w = 8'd137;
        9'b00_10_01000: sh3_w = 8'd128;
        9'b00_10_01010: sh3_w = 8'd132;
        9'b00_10_01100: sh3_w = 8'd132;
        9'b00_10_01110: sh3_w = 8'd136;
        9'b00_10_01111: sh3_w = 8'd151;
        9'b00_10_10000: sh3_w = 8'd139;
        9'b00_11_00000: sh3_w = 8'd150;
        9'b00_11_00001: sh3_w = 8'd144;
        9'b00_11_00010: sh3_w = 8'd132;
        9'b00_11_00011: sh3_w = 8'd131;
        9'b00_11_00100: sh3_w = 8'd138;
        9'b00_11_00101: sh3_w = 8'd149;
        9'b00_11_00110: sh3_w = 8'd140;
        9'b00_11_00111: sh3_w = 8'd133;
        9'b00_11_01000: sh3_w = 8'd149;
        9'b00_11_01001: sh3_w = 8'd142;
        9'b00_11_01010: sh3_w = 8'd147;
        9'b00_11_01011: sh3_w = 8'd133;
        9'b00_11_01101: sh3_w = 8'd136;
        9'b00_11_01110: sh3_w = 8'd133;
        9'b00_11_01111: sh3_w = 8'd146;
        9'b00_11_10000: sh3_w = 8'd139;
        9'b00_11_10001: sh3_w = 8'd133;
        9'b00_11_10010: sh3_w = 8'd133;
        9'b00_11_10011: sh3_w = 8'd143;
        9'b01_00_00000: sh3_w = 8'd167;
        9'b01_00_00001: sh3_w = 8'd178;
        9'b01_00_00100: sh3_w = 8'd132;
        9'b01_00_00110: sh3_w = 8'd130;
        9'b01_00_01011: sh3_w = 8'd177;
        9'b01_01_00000: sh3_w = 8'd171;
        9'b01_01_00001: sh3_w = 8'd159;
        9'b01_01_00010: sh3_w = 8'd157;
        9'b01_01_00011: sh3_w = 8'd128;
        9'b01_01_00100: sh3_w = 8'd149;
        9'b01_01_00110: sh3_w = 8'd156;
        9'b01_01_01001: sh3_w = 8'd130;
        9'b01_01_01100: sh3_w = 8'd135;
        9'b01_01_01110: sh3_w = 8'd145;
        9'b01_10_00000: sh3_w = 8'd158;
        9'b01_10_00001: sh3_w = 8'd167;
        9'b01_10_00010: sh3_w = 8'd156;
        9'b01_10_00011: sh3_w = 8'd170;
        9'b01_10_00100: sh3_w = 8'd178;
        9'b01_10_00101: sh3_w = 8'd167;
        9'b01_10_00110: sh3_w = 8'd133;
        9'b01_10_00111: sh3_w = 8'd145;
        9'b01_10_01001: sh3_w = 8'd134;
        9'b01_10_01011: sh3_w = 8'd146;
        9'b01_10_01101: sh3_w = 8'd148;
        9'b01_10_01111: sh3_w = 8'd143;
        9'b01_10_10001: sh3_w = 8'd168;
        9'b01_11_00000: sh3_w = 8'd135;
        9'b01_11_00001: sh3_w = 8'd130;
        9'b01_11_00010: sh3_w = 8'd179;
        9'b01_11_00011: sh3_w = 8'd159;
        9'b01_11_00100: sh3_w = 8'd174;
        9'b01_11_00101: sh3_w = 8'd151;
        9'b01_11_00110: sh3_w = 8'd144;
        9'b01_11_00111: sh3_w = 8'd139;
        9'b01_11_01000: sh3_w = 8'd181;
        9'b01_11_01001: sh3_w = 8'd168;
        9'b01_11_01010: sh3_w = 8'd138;
        9'b01_11_01011: sh3_w = 8'd135;
        9'b01_11_01100: sh3_w = 8'd174;
        9'b01_11_01101: sh3_w = 8'd181;
        9'b01_11_01110: sh3_w = 8'd161;
        9'b01_11_01111: sh3_w = 8'd163;
        9'b01_11_10001: sh3_w = 8'd153;
        9'b01_11_10010: sh3_w = 8'd163;
        9'b01_11_10011: sh3_w = 8'd166;
        9'b10_00_00000: sh3_w = 8'd158;
        9'b10_00_00100: sh3_w = 8'd152;
        9'b10_00_00101: sh3_w = 8'd165;
        9'b10_00_01000: sh3_w = 8'd184;
        9'b10_00_01001: sh3_w = 8'd142;
        9'b10_01_00000: sh3_w = 8'd156;
        9'b10_01_00001: sh3_w = 8'd149;
        9'b10_01_00010: sh3_w = 8'd196;
        9'b10_01_00011: sh3_w = 8'd138;
        9'b10_01_00100: sh3_w = 8'd135;
        9'b10_01_00101: sh3_w = 8'd142;
        9'b10_01_00110: sh3_w = 8'd193;
        9'b10_01_01010: sh3_w = 8'd151;
        9'b10_01_01110: sh3_w = 8'd203;
        9'b10_10_00000: sh3_w = 8'd163;
        9'b10_10_00001: sh3_w = 8'd204;
        9'b10_10_00010: sh3_w = 8'd206;
        9'b10_10_00011: sh3_w = 8'd179;
        9'b10_10_00100: sh3_w = 8'd165;
        9'b10_10_00101: sh3_w = 8'd163;
        9'b10_10_00110: sh3_w = 8'd149;
        9'b10_10_01000: sh3_w = 8'd145;
        9'b10_10_01001: sh3_w = 8'd192;
        9'b10_10_01101: sh3_w = 8'd187;
        9'b10_10_01110: sh3_w = 8'd135;
        9'b10_10_10001: sh3_w = 8'd160;
        9'b10_11_00000: sh3_w = 8'd179;
        9'b10_11_00001: sh3_w = 8'd143;
        9'b10_11_00010: sh3_w = 8'd128;
        9'b10_11_00011: sh3_w = 8'd208;
        9'b10_11_00100: sh3_w = 8'd152;
        9'b10_11_00101: sh3_w = 8'd153;
        9'b10_11_00110: sh3_w = 8'd170;
        9'b10_11_00111: sh3_w = 8'd182;
        9'b10_11_01000: sh3_w = 8'd172;
        9'b10_11_01001: sh3_w = 8'd199;
        9'b10_11_01010: sh3_w = 8'd199;
        9'b10_11_01011: sh3_w = 8'd137;
        9'b10_11_01100: sh3_w = 8'd195;
        9'b10_11_01101: sh3_w = 8'd163;
        9'b10_11_01111: sh3_w = 8'd186;
        9'b10_11_10001: sh3_w = 8'd157;
        9'b10_11_10011: sh3_w = 8'd181;
        default: sh3_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh4_w = 8'd130;
        9'b00_00_00011: sh4_w = 8'd128;
        9'b00_00_00100: sh4_w = 8'd148;
        9'b00_00_01000: sh4_w = 8'd153;
        9'b00_00_01001: sh4_w = 8'd128;
        9'b00_01_00000: sh4_w = 8'd138;
        9'b00_01_00001: sh4_w = 8'd141;
        9'b00_01_00010: sh4_w = 8'd133;
        9'b00_01_00011: sh4_w = 8'd128;
        9'b00_01_00101: sh4_w = 8'd131;
        9'b00_01_00111: sh4_w = 8'd135;
        9'b00_01_01010: sh4_w = 8'd154;
        9'b00_01_01101: sh4_w = 8'd141;
        9'b00_01_01111: sh4_w = 8'd144;
        9'b00_10_00000: sh4_w = 8'd137;
        9'b00_10_00001: sh4_w = 8'd135;
        9'b00_10_00010: sh4_w = 8'd128;
        9'b00_10_00011: sh4_w = 8'd129;
        9'b00_10_00100: sh4_w = 8'd145;
        9'b00_10_00111: sh4_w = 8'd135;
        9'b00_10_01000: sh4_w = 8'd131;
        9'b00_10_01010: sh4_w = 8'd131;
        9'b00_10_01011: sh4_w = 8'd151;
        9'b00_10_01101: sh4_w = 8'd144;
        9'b00_10_10000: sh4_w = 8'd149;
        9'b00_11_00000: sh4_w = 8'd135;
        9'b00_11_00001: sh4_w = 8'd135;
        9'b00_11_00010: sh4_w = 8'd142;
        9'b00_11_00011: sh4_w = 8'd142;
        9'b00_11_00100: sh4_w = 8'd132;
        9'b00_11_00101: sh4_w = 8'd144;
        9'b00_11_00110: sh4_w = 8'd144;
        9'b00_11_00111: sh4_w = 8'd152;
        9'b00_11_01000: sh4_w = 8'd152;
        9'b00_11_01001: sh4_w = 8'd138;
        9'b00_11_01010: sh4_w = 8'd129;
        9'b00_11_01011: sh4_w = 8'd135;
        9'b00_11_01100: sh4_w = 8'd143;
        9'b00_11_01101: sh4_w = 8'd134;
        9'b00_11_01110: sh4_w = 8'd138;
        9'b00_11_01111: sh4_w = 8'd154;
        9'b00_11_10000: sh4_w = 8'd136;
        9'b00_11_10001: sh4_w = 8'd146;
        9'b00_11_10010: sh4_w = 8'd149;
        9'b00_11_10011: sh4_w = 8'd142;
        9'b01_00_00000: sh4_w = 8'd161;
        9'b01_00_00011: sh4_w = 8'd166;
        9'b01_00_00100: sh4_w = 8'd165;
        9'b01_00_00111: sh4_w = 8'd132;
        9'b01_00_01000: sh4_w = 8'd129;
        9'b01_01_00000: sh4_w = 8'd148;
        9'b01_01_00001: sh4_w = 8'd161;
        9'b01_01_00010: sh4_w = 8'd176;
        9'b01_01_00100: sh4_w = 8'd132;
        9'b01_01_00101: sh4_w = 8'd141;
        9'b01_01_00111: sh4_w = 8'd154;
        9'b01_01_01010: sh4_w = 8'd150;
        9'b01_01_01101: sh4_w = 8'd174;
        9'b01_01_01110: sh4_w = 8'd170;
        9'b01_10_00000: sh4_w = 8'd157;
        9'b01_10_00001: sh4_w = 8'd128;
        9'b01_10_00010: sh4_w = 8'd129;
        9'b01_10_00011: sh4_w = 8'd171;
        9'b01_10_00100: sh4_w = 8'd164;
        9'b01_10_00101: sh4_w = 8'd158;
        9'b01_10_00110: sh4_w = 8'd175;
        9'b01_10_01000: sh4_w = 8'd177;
        9'b01_10_01010: sh4_w = 8'd175;
        9'b01_10_01100: sh4_w = 8'd131;
        9'b01_10_01110: sh4_w = 8'd163;
        9'b01_10_10000: sh4_w = 8'd162;
        9'b01_11_00000: sh4_w = 8'd147;
        9'b01_11_00001: sh4_w = 8'd176;
        9'b01_11_00010: sh4_w = 8'd169;
        9'b01_11_00011: sh4_w = 8'd129;
        9'b01_11_00100: sh4_w = 8'd138;
        9'b01_11_00101: sh4_w = 8'd135;
        9'b01_11_00110: sh4_w = 8'd164;
        9'b01_11_00111: sh4_w = 8'd175;
        9'b01_11_01000: sh4_w = 8'd133;
        9'b01_11_01001: sh4_w = 8'd157;
        9'b01_11_01010: sh4_w = 8'd180;
        9'b01_11_01011: sh4_w = 8'd180;
        9'b01_11_01100: sh4_w = 8'd159;
        9'b01_11_01101: sh4_w = 8'd138;
        9'b01_11_01110: sh4_w = 8'd154;
        9'b01_11_01111: sh4_w = 8'd134;
        9'b01_11_10000: sh4_w = 8'd131;
        9'b01_11_10001: sh4_w = 8'd130;
        9'b01_11_10011: sh4_w = 8'd179;
        9'b10_00_00000: sh4_w = 8'd190;
        9'b10_00_00001: sh4_w = 8'd181;
        9'b10_00_00100: sh4_w = 8'd181;
        9'b10_00_00111: sh4_w = 8'd131;
        9'b10_00_01000: sh4_w = 8'd163;
        9'b10_01_00000: sh4_w = 8'd176;
        9'b10_01_00001: sh4_w = 8'd166;
        9'b10_01_00010: sh4_w = 8'd171;
        9'b10_01_00011: sh4_w = 8'd206;
        9'b10_01_00100: sh4_w = 8'd204;
        9'b10_01_01001: sh4_w = 8'd133;
        9'b10_01_01010: sh4_w = 8'd164;
        9'b10_01_01100: sh4_w = 8'd143;
        9'b10_01_01101: sh4_w = 8'd200;
        9'b10_10_00000: sh4_w = 8'd137;
        9'b10_10_00001: sh4_w = 8'd193;
        9'b10_10_00010: sh4_w = 8'd172;
        9'b10_10_00011: sh4_w = 8'd137;
        9'b10_10_00100: sh4_w = 8'd182;
        9'b10_10_00101: sh4_w = 8'd184;
        9'b10_10_00110: sh4_w = 8'd201;
        9'b10_10_00111: sh4_w = 8'd162;
        9'b10_10_01000: sh4_w = 8'd170;
        9'b10_10_01100: sh4_w = 8'd163;
        9'b10_10_10000: sh4_w = 8'd174;
        9'b10_10_10001: sh4_w = 8'd167;
        9'b10_11_00000: sh4_w = 8'd144;
        9'b10_11_00001: sh4_w = 8'd157;
        9'b10_11_00010: sh4_w = 8'd164;
        9'b10_11_00011: sh4_w = 8'd169;
        9'b10_11_00100: sh4_w = 8'd172;
        9'b10_11_00101: sh4_w = 8'd184;
        9'b10_11_00110: sh4_w = 8'd187;
        9'b10_11_00111: sh4_w = 8'd165;
        9'b10_11_01000: sh4_w = 8'd178;
        9'b10_11_01001: sh4_w = 8'd152;
        9'b10_11_01011: sh4_w = 8'd193;
        9'b10_11_01100: sh4_w = 8'd132;
        9'b10_11_01101: sh4_w = 8'd193;
        9'b10_11_01110: sh4_w = 8'd180;
        9'b10_11_10000: sh4_w = 8'd132;
        9'b10_11_10010: sh4_w = 8'd201;
        9'b10_11_10011: sh4_w = 8'd180;
        default: sh4_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh5_w = 8'd151;
        9'b00_00_00100: sh5_w = 8'd131;
        9'b00_00_01000: sh5_w = 8'd128;
        9'b00_00_01010: sh5_w = 8'd137;
        9'b00_00_01011: sh5_w = 8'd139;
        9'b00_01_00000: sh5_w = 8'd151;
        9'b00_01_00001: sh5_w = 8'd142;
        9'b00_01_00010: sh5_w = 8'd152;
        9'b00_01_00100: sh5_w = 8'd140;
        9'b00_01_00110: sh5_w = 8'd147;
        9'b00_01_01000: sh5_w = 8'd145;
        9'b00_01_01100: sh5_w = 8'd148;
        9'b00_01_01110: sh5_w = 8'd149;
        9'b00_10_00000: sh5_w = 8'd152;
        9'b00_10_00001: sh5_w = 8'd133;
        9'b00_10_00010: sh5_w = 8'd154;
        9'b00_10_00011: sh5_w = 8'd135;
        9'b00_10_00100: sh5_w = 8'd129;
        9'b00_10_00111: sh5_w = 8'd143;
        9'b00_10_01000: sh5_w = 8'd152;
        9'b00_10_01001: sh5_w = 8'd143;
        9'b00_10_01011: sh5_w = 8'd136;
        9'b00_10_01101: sh5_w = 8'd141;
        9'b00_10_01111: sh5_w = 8'd141;
        9'b00_10_10001: sh5_w = 8'd139;
        9'b01_00_00000: sh5_w = 8'd173;
        9'b01_00_00100: sh5_w = 8'd128;
        9'b01_00_00101: sh5_w = 8'd150;
        9'b01_00_01000: sh5_w = 8'd148;
        9'b01_00_01001: sh5_w = 8'd170;
        9'b01_01_00000: sh5_w = 8'd173;
        9'b01_01_00001: sh5_w = 8'd135;
        9'b01_01_00010: sh5_w = 8'd146;
        9'b01_01_00011: sh5_w = 8'd179;
        9'b01_01_00100: sh5_w = 8'd140;
        9'b01_01_00101: sh5_w = 8'd153;
        9'b01_01_01001: sh5_w = 8'd178;
        9'b01_01_01100: sh5_w = 8'd133;
        9'b01_10_00000: sh5_w = 8'd129;
        9'b01_10_00001: sh5_w = 8'd160;
        9'b01_10_00010: sh5_w = 8'd139;
        9'b01_10_00011: sh5_w = 8'd151;
        9'b01_10_00100: sh5_w = 8'd138;
        9'b01_10_00101: sh5_w = 8'd172;
        9'b01_10_00110: sh5_w = 8'd140;
        9'b01_10_00111: sh5_w = 8'd135;
        9'b01_10_01001: sh5_w = 8'd176;
        9'b01_10_01011: sh5_w = 8'd132;
        9'b01_10_01101: sh5_w = 8'd137;
        9'b01_10_01111: sh5_w = 8'd145;
        9'b01_10_10001: sh5_w = 8'd144;
        9'b10_00_00000: sh5_w = 8'd168;
        9'b10_00_00011: sh5_w = 8'd148;
        9'b10_00_00100: sh5_w = 8'd194;
        9'b10_00_00111: sh5_w = 8'd150;
        9'b10_00_01000: sh5_w = 8'd156;
        9'b10_01_00000: sh5_w = 8'd168;
        9'b10_01_00001: sh5_w = 8'd130;
        9'b10_01_00010: sh5_w = 8'd181;
        9'b10_01_00011: sh5_w = 8'd153;
        9'b10_01_00101: sh5_w = 8'd180;
        9'b10_01_00110: sh5_w = 8'd190;
        9'b10_01_01000: sh5_w = 8'd148;
        9'b10_01_01011: sh5_w = 8'd172;
        9'b10_10_00000: sh5_w = 8'd131;
        9'b10_10_00001: sh5_w = 8'd190;
        9'b10_10_00010: sh5_w = 8'd135;
        9'b10_10_00011: sh5_w = 8'd208;
        9'b10_10_00100: sh5_w = 8'd196;
        9'b10_10_00101: sh5_w = 8'd154;
        9'b10_10_00111: sh5_w = 8'd208;
        9'b10_10_01000: sh5_w = 8'd183;
        9'b10_10_01010: sh5_w = 8'd164;
        9'b10_10_01100: sh5_w = 8'd154;
        9'b10_10_01110: sh5_w = 8'd137;
        9'b10_10_10000: sh5_w = 8'd200;
        default: sh5_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh6_w = 8'd152;
        9'b00_00_00010: sh6_w = 8'd151;
        9'b00_00_00011: sh6_w = 8'd129;
        9'b00_00_00100: sh6_w = 8'd145;
        9'b00_00_00110: sh6_w = 8'd131;
        9'b00_00_01000: sh6_w = 8'd138;
        9'b00_01_00000: sh6_w = 8'd134;
        9'b00_01_00001: sh6_w = 8'd150;
        9'b00_01_00010: sh6_w = 8'd137;
        9'b00_01_00011: sh6_w = 8'd148;
        9'b00_01_00101: sh6_w = 8'd153;
        9'b00_01_00111: sh6_w = 8'd145;
        9'b00_01_01001: sh6_w = 8'd136;
        9'b00_01_01011: sh6_w = 8'd142;
        9'b00_01_01101: sh6_w = 8'd146;
        9'b00_10_00000: sh6_w = 8'd130;
        9'b00_10_00001: sh6_w = 8'd130;
        9'b00_10_00010: sh6_w = 8'd147;
        9'b00_10_00011: sh6_w = 8'd142;
        9'b00_10_00100: sh6_w = 8'd152;
        9'b00_10_00101: sh6_w = 8'd129;
        9'b00_10_00110: sh6_w = 8'd143;
        9'b00_10_00111: sh6_w = 8'd147;
        9'b00_10_01001: sh6_w = 8'd149;
        9'b00_10_01011: sh6_w = 8'd130;
        9'b00_10_01101: sh6_w = 8'd152;
        9'b00_10_01111: sh6_w = 8'd131;
        9'b00_10_10001: sh6_w = 8'd130;
        9'b01_00_00000: sh6_w = 8'd179;
        9'b01_00_00011: sh6_w = 8'd176;
        9'b01_00_00100: sh6_w = 8'd163;
        9'b01_00_01000: sh6_w = 8'd172;
        9'b01_00_01010: sh6_w = 8'd146;
        9'b01_01_00000: sh6_w = 8'd163;
        9'b01_01_00001: sh6_w = 8'd168;
        9'b01_01_00010: sh6_w = 8'd160;
        9'b01_01_00011: sh6_w = 8'd144;
        9'b01_01_00100: sh6_w = 8'd133;
        9'b01_01_00111: sh6_w = 8'd146;
        9'b01_01_01010: sh6_w = 8'd171;
        9'b01_01_01011: sh6_w = 8'd179;
        9'b01_01_01101: sh6_w = 8'd160;
        9'b01_10_00000: sh6_w = 8'd141;
        9'b01_10_00001: sh6_w = 8'd135;
        9'b01_10_00010: sh6_w = 8'd143;
        9'b01_10_00011: sh6_w = 8'd175;
        9'b01_10_00100: sh6_w = 8'd151;
        9'b01_10_00101: sh6_w = 8'd144;
        9'b01_10_00110: sh6_w = 8'd175;
        9'b01_10_01000: sh6_w = 8'd171;
        9'b01_10_01010: sh6_w = 8'd157;
        9'b01_10_01100: sh6_w = 8'd180;
        9'b01_10_01110: sh6_w = 8'd130;
        9'b01_10_10000: sh6_w = 8'd181;
        9'b10_00_00000: sh6_w = 8'd128;
        9'b10_00_00100: sh6_w = 8'd136;
        9'b10_00_00110: sh6_w = 8'd170;
        9'b10_00_01000: sh6_w = 8'd178;
        9'b10_00_01011: sh6_w = 8'd136;
        9'b10_01_00000: sh6_w = 8'd197;
        9'b10_01_00001: sh6_w = 8'd151;
        9'b10_01_00010: sh6_w = 8'd192;
        9'b10_01_00011: sh6_w = 8'd138;
        9'b10_01_00100: sh6_w = 8'd150;
        9'b10_01_00110: sh6_w = 8'd149;
        9'b10_01_01100: sh6_w = 8'd196;
        9'b10_01_01101: sh6_w = 8'd151;
        9'b10_01_01110: sh6_w = 8'd157;
        9'b10_10_00000: sh6_w = 8'd154;
        9'b10_10_00001: sh6_w = 8'd203;
        9'b10_10_00010: sh6_w = 8'd161;
        9'b10_10_00011: sh6_w = 8'd149;
        9'b10_10_00100: sh6_w = 8'd197;
        9'b10_10_00101: sh6_w = 8'd187;
        9'b10_10_00110: sh6_w = 8'd131;
        9'b10_10_00111: sh6_w = 8'd166;
        9'b10_10_01011: sh6_w = 8'd163;
        9'b10_10_01101: sh6_w = 8'd190;
        9'b10_10_01110: sh6_w = 8'd164;
        9'b10_10_01111: sh6_w = 8'd154;
        default: sh6_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh7_w = 8'd153;
        9'b00_00_00100: sh7_w = 8'd136;
        9'b00_00_01000: sh7_w = 8'd135;
        9'b00_00_01001: sh7_w = 8'd146;
        9'b00_01_00000: sh7_w = 8'd142;
        9'b00_01_00001: sh7_w = 8'd151;
        9'b00_01_00010: sh7_w = 8'd149;
        9'b00_01_00011: sh7_w = 8'd139;
        9'b00_01_00100: sh7_w = 8'd148;
        9'b00_01_00110: sh7_w = 8'd152;
        9'b00_01_01000: sh7_w = 8'd146;
        9'b00_01_01010: sh7_w = 8'd147;
        9'b00_01_01111: sh7_w = 8'd150;
        9'b01_00_00000: sh7_w = 8'd175;
        9'b01_00_00001: sh7_w = 8'd139;
        9'b01_00_00101: sh7_w = 8'd145;
        9'b01_00_01000: sh7_w = 8'd179;
        9'b01_01_00000: sh7_w = 8'd137;
        9'b01_01_00001: sh7_w = 8'd152;
        9'b01_01_00010: sh7_w = 8'd141;
        9'b01_01_00011: sh7_w = 8'd150;
        9'b01_01_00100: sh7_w = 8'd156;
        9'b01_01_00111: sh7_w = 8'd165;
        9'b01_01_01010: sh7_w = 8'd153;
        9'b01_01_01101: sh7_w = 8'd180;
        9'b01_01_01111: sh7_w = 8'd141;
        9'b10_00_00000: sh7_w = 8'd197;
        9'b10_00_00001: sh7_w = 8'd207;
        9'b10_00_00010: sh7_w = 8'd207;
        9'b10_00_00110: sh7_w = 8'd184;
        9'b10_00_01000: sh7_w = 8'd180;
        9'b10_01_00000: sh7_w = 8'd140;
        9'b10_01_00001: sh7_w = 8'd128;
        9'b10_01_00010: sh7_w = 8'd196;
        9'b10_01_00011: sh7_w = 8'd148;
        9'b10_01_00100: sh7_w = 8'd183;
        9'b10_01_00101: sh7_w = 8'd189;
        9'b10_01_00111: sh7_w = 8'd168;
        9'b10_01_01011: sh7_w = 8'd180;
        9'b10_01_01111: sh7_w = 8'd172;
        default: sh7_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh8_w = 8'd141;
        9'b00_00_00001: sh8_w = 8'd152;
        9'b00_00_00100: sh8_w = 8'd128;
        9'b00_00_00110: sh8_w = 8'd136;
        9'b00_00_01000: sh8_w = 8'd134;
        9'b00_01_00000: sh8_w = 8'd145;
        9'b00_01_00001: sh8_w = 8'd139;
        9'b00_01_00010: sh8_w = 8'd139;
        9'b00_01_00011: sh8_w = 8'd148;
        9'b00_01_00101: sh8_w = 8'd149;
        9'b00_01_00111: sh8_w = 8'd154;
        9'b00_01_01001: sh8_w = 8'd131;
        9'b00_01_01100: sh8_w = 8'd146;
        9'b00_01_01110: sh8_w = 8'd154;
        9'b01_00_00000: sh8_w = 8'd133;
        9'b01_00_00010: sh8_w = 8'd153;
        9'b01_00_00100: sh8_w = 8'd134;
        9'b01_00_00110: sh8_w = 8'd173;
        9'b01_00_01000: sh8_w = 8'd141;
        9'b01_00_01001: sh8_w = 8'd168;
        9'b01_01_00000: sh8_w = 8'd160;
        9'b01_01_00001: sh8_w = 8'd150;
        9'b01_01_00010: sh8_w = 8'd132;
        9'b01_01_00011: sh8_w = 8'd149;
        9'b01_01_00100: sh8_w = 8'd144;
        9'b01_01_01000: sh8_w = 8'd155;
        9'b01_01_01001: sh8_w = 8'd156;
        9'b01_01_01011: sh8_w = 8'd166;
        9'b01_01_01111: sh8_w = 8'd136;
        9'b10_00_00000: sh8_w = 8'd193;
        9'b10_00_00100: sh8_w = 8'd166;
        9'b10_00_00101: sh8_w = 8'd185;
        9'b10_00_01000: sh8_w = 8'd200;
        9'b10_00_01010: sh8_w = 8'd155;
        9'b10_01_00000: sh8_w = 8'd186;
        9'b10_01_00001: sh8_w = 8'd136;
        9'b10_01_00010: sh8_w = 8'd162;
        9'b10_01_00011: sh8_w = 8'd192;
        9'b10_01_00100: sh8_w = 8'd206;
        9'b10_01_00111: sh8_w = 8'd139;
        9'b10_01_01000: sh8_w = 8'd206;
        9'b10_01_01001: sh8_w = 8'd152;
        9'b10_01_01111: sh8_w = 8'd186;
        default: sh8_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh9_w = 8'd135;
        9'b00_00_00001: sh9_w = 8'd148;
        9'b00_00_00011: sh9_w = 8'd144;
        9'b00_00_00100: sh9_w = 8'd150;
        9'b00_00_00101: sh9_w = 8'd138;
        9'b00_00_01000: sh9_w = 8'd151;
        9'b01_00_00000: sh9_w = 8'd161;
        9'b01_00_00011: sh9_w = 8'd162;
        9'b01_00_00100: sh9_w = 8'd152;
        9'b01_00_01000: sh9_w = 8'd151;
        9'b01_00_01011: sh9_w = 8'd174;
        9'b10_00_00000: sh9_w = 8'd192;
        9'b10_00_00100: sh9_w = 8'd142;
        9'b10_00_00101: sh9_w = 8'd180;
        9'b10_00_01000: sh9_w = 8'd158;
        9'b10_00_01011: sh9_w = 8'd160;
        default: sh9_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh10_w = 8'd139;
        9'b00_00_00100: sh10_w = 8'd147;
        9'b00_00_01000: sh10_w = 8'd141;
        9'b00_00_01010: sh10_w = 8'd131;
        9'b00_00_01011: sh10_w = 8'd145;
        9'b01_00_00000: sh10_w = 8'd129;
        9'b01_00_00010: sh10_w = 8'd155;
        9'b01_00_00100: sh10_w = 8'd129;
        9'b01_00_01000: sh10_w = 8'd166;
        9'b01_00_01010: sh10_w = 8'd172;
        9'b10_00_00001: sh10_w = 8'd173;
        9'b10_00_00011: sh10_w = 8'd198;
        9'b10_00_00100: sh10_w = 8'd128;
        9'b10_00_01000: sh10_w = 8'd205;
        9'b10_00_01001: sh10_w = 8'd137;
        default: sh10_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh11_w = 8'd153;
        9'b00_00_00010: sh11_w = 8'd136;
        9'b00_00_00100: sh11_w = 8'd151;
        9'b00_00_00101: sh11_w = 8'd146;
        9'b00_00_00111: sh11_w = 8'd142;
        9'b00_00_01000: sh11_w = 8'd137;
        9'b01_00_00001: sh11_w = 8'd146;
        9'b01_00_00100: sh11_w = 8'd151;
        9'b01_00_00111: sh11_w = 8'd136;
        9'b01_00_01000: sh11_w = 8'd128;
        9'b01_00_01001: sh11_w = 8'd163;
        9'b10_00_00000: sh11_w = 8'd130;
        9'b10_00_00001: sh11_w = 8'd184;
        9'b10_00_00011: sh11_w = 8'd185;
        9'b10_00_00100: sh11_w = 8'd163;
        9'b10_00_01010: sh11_w = 8'd140;
        default: sh11_w = 8'd0;
    endcase
end

always @ (*) begin
    case (addr)
        9'b00_00_00000: sh12_w = 8'd131;
        9'b00_00_00100: sh12_w = 8'd144;
        9'b00_00_00111: sh12_w = 8'd130;
        9'b00_00_01000: sh12_w = 8'd153;
        9'b00_00_01001: sh12_w = 8'd133;
        9'b01_00_00000: sh12_w = 8'd177;
        9'b01_00_00010: sh12_w = 8'd145;
        9'b01_00_00100: sh12_w = 8'd158;
        9'b01_00_01000: sh12_w = 8'd162;
        9'b01_00_01011: sh12_w = 8'd147;
        9'b10_00_00000: sh12_w = 8'd152;
        9'b10_00_00010: sh12_w = 8'd189;
        9'b10_00_00100: sh12_w = 8'd188;
        9'b10_00_00111: sh12_w = 8'd155;
        9'b10_00_01000: sh12_w = 8'd179;
        9'b10_00_01011: sh12_w = 8'd144;
        default: sh12_w = 8'd0;
    endcase
end


// output data
always @ (posedge clk) begin
    sh1 <= sh1_w;
    sh2 <= sh2_w;
    sh3 <= sh3_w;
    sh4 <= sh4_w;
    sh5 <= sh5_w;
    sh6 <= sh6_w;
    sh7 <= sh7_w;
    sh8 <= sh8_w;
    sh9 <= sh9_w;
    sh10 <= sh10_w;
    sh11 <= sh11_w;
    sh12 <= sh12_w;
end


endmodule