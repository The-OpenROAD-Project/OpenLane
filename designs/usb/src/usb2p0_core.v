/*

Taken from: https://github.com/avakar/usbcorev
	
No-notice MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

module usb(
    input rst_n,
    input clk_48,

    input rx_j,
    input rx_se0,

    output tx_en,
    output tx_j,
    output tx_se0,

    input[6:0] usb_address,

    output usb_rst,

    output reg transaction_active,
    output reg[3:0] endpoint,
    output reg direction_in,
    output reg setup,
    input data_toggle,

    input[1:0] handshake,
    
    output reg[7:0] data_out,
    input[7:0] data_in,
    input data_in_valid,
    output reg data_strobe,
    output reg success
    );

localparam
    hs_ack = 2'b00,
    hs_none = 2'b01,
    hs_nak = 2'b10,
    hs_stall = 2'b11;

wire[3:0] recv_pid;
wire[7:0] recv_data;
wire recv_packet;
wire recv_datastrobe;
wire recv_crc5_ok;
wire recv_crc16_ok;
wire recv_short_idle;

usb_recv recv(
    .rst_n(rst_n),
    .clk_48(clk_48),

    .rx_j(rx_j),
    .rx_se0(rx_se0),

    .short_idle(recv_short_idle),
    .usb_rst(usb_rst),

    .xpid(recv_pid),
    .xdata(recv_data),
    .xpacket(recv_packet),
    .xdatastrobe(recv_datastrobe),
    .xcrc5_ok(recv_crc5_ok),
    .xcrc16_ok(recv_crc16_ok)
    );

reg tx_transmit;
reg[7:0] tx_data;
wire tx_data_strobe;

reg tx_enable_crc16;
wire tx_send_crc16;
usb_tx tx(
    .rst_n(rst_n),
    .clk_48(clk_48),

    .tx_en(tx_en),
    .tx_j(tx_j),
    .tx_se0(tx_se0),

    .transmit(tx_transmit),
    .data(tx_data),
    .data_strobe(tx_data_strobe),
    
    .update_crc16(tx_enable_crc16),
    .send_crc16(tx_send_crc16)
    );

reg[7:0] recv_queue_0;
reg[7:0] recv_queue_1;
reg recv_queue_0_valid;
reg recv_queue_1_valid;

always @(posedge clk_48) begin
    if (!recv_packet) begin
        recv_queue_1_valid <= 1'b0;
        recv_queue_0_valid <= 1'b0;
    end else if (recv_datastrobe) begin
        data_out <= recv_queue_1;
        recv_queue_1 <= recv_queue_0;
        recv_queue_0 <= recv_data;
        recv_queue_1_valid <= recv_queue_0_valid;
        recv_queue_0_valid <= 1'b1;
    end
end

localparam
    st_idle = 3'b000,
    st_data = 3'b001,
    st_err = 3'b010,
    st_send_handshake = 3'b011,
    st_in = 3'b100,
    st_prep_recv_ack = 3'b101,
    st_recv_ack = 3'b110,
    st_send_ack = 3'b111;

reg[2:0] state;

assign tx_send_crc16 = state == st_prep_recv_ack;

localparam
    pt_special   = 2'b00,
    pt_token     = 2'b01,
    pt_handshake = 2'b10,
    pt_data      = 2'b11;

localparam
    tok_out   = 2'b00,
    tok_sof   = 2'b01,
    tok_in    = 2'b10,
    tok_setup = 2'b11;

// Note that the token is perishable. The standard prescribes at most
// 7.5 bits of inter-packet idle time. We allow at most 31 bits between
// token activation and receiving the corresponding DATA packet.
reg[6:0] token_timeout;
wire token_active = token_timeout != 1'b0;

reg[1:0] handshake_latch;

always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin
        success <= 1'b0;
        state <= st_idle;
        data_strobe <= 1'b0;
        endpoint <= 1'sbx;
        direction_in <= 1'bx;
        setup <= 1'bx;
        transaction_active <= 1'b0;
        token_timeout <= 1'b0;
        tx_transmit <= 1'b0;
        
        tx_enable_crc16 <= 1'b0;
        handshake_latch <= 2'bxx;
    end else begin
        if (token_timeout != 1'b0)
            token_timeout <= token_timeout - 1'b1;

        if (!transaction_active) begin
            endpoint <= 1'sbx;
            direction_in <= 1'bx;
            setup <= 1'bx;
            handshake_latch <= 2'bxx;
        end

        success <= 1'b0;
        data_strobe <= 1'b0;
        tx_transmit <= 1'b0;
        case (state)
            st_idle: begin
                if (!token_active)
                    transaction_active <= 1'b0;

                if (recv_packet) begin
                    if (recv_pid[1:0] == pt_token) begin
                        state <= st_data;
                    end else begin
                        if (recv_pid[1:0] == pt_data && !recv_pid[2] && token_active) begin
                            handshake_latch <= handshake;
                            state <= recv_pid[3] == data_toggle? st_data: st_send_ack;
                        end else begin
                            state <= st_err;
                        end
                    end
                end
            end
            st_data: begin
                if (!recv_packet) begin
                    state <= st_idle;
                    case (recv_pid[1:0])
                        pt_token: begin
                            if (recv_queue_1_valid && recv_crc5_ok && recv_queue_1[6:0] == usb_address && recv_pid[3:2] != tok_sof) begin
                                token_timeout <= 7'h7f;
                                transaction_active <= 1'b1;
                                endpoint <= { recv_queue_0[2:0], recv_queue_1[7] };
                                case (recv_pid[3:2])
                                    tok_in: begin
                                        direction_in <= 1'b1;
                                        setup <= 1'bx;
                                        state <= st_in;
                                    end
                                    tok_out: begin
                                        direction_in <= 1'b0;
                                        setup <= 1'b0;
                                    end
                                    tok_setup: begin
                                        direction_in <= 1'b0;
                                        setup <= 1'b1;
                                    end
                                endcase
                            end else begin
                                transaction_active <= 1'b0;
                                endpoint <= 1'sbx;
                                direction_in <= 1'bx;
                                setup <= 1'bx;
                            end
                        end
                        pt_data: begin
                            if (recv_queue_1_valid && recv_crc16_ok) begin
                                if (handshake_latch == hs_ack || handshake_latch == hs_none)
                                    success <= 1'b1;
                                state <= st_send_handshake;
                            end
                        end
                        default: begin
                            endpoint <= 1'sbx;
                            direction_in <= 1'bx;
                            setup <= 1'bx;
                        end
                    endcase
                end else if (recv_datastrobe) begin
                    case (recv_pid[1:0])
                        pt_token: begin
                            if (recv_queue_1_valid)
                                state <= st_err;
                        end
                        pt_data: begin
                            if (recv_queue_1_valid && (handshake_latch == hs_ack || handshake_latch == hs_none))
                                data_strobe <= 1'b1;
                        end
                        default: begin
                            state <= st_err;
                        end
                    endcase
                end
            end
            st_in: begin
                tx_transmit <= tx_transmit;

                if (!tx_transmit && recv_short_idle) begin
                    if (handshake != hs_ack && handshake != hs_none) begin
                        handshake_latch <= handshake;
                        state <= st_send_handshake;
                    end else begin
                        tx_data <= { !data_toggle, 3'b100, data_toggle, 3'b011 };
                        tx_transmit <= 1'b1;
                    end
                end
                
                if (tx_transmit && tx_data_strobe) begin
                    if (!data_in_valid) begin
                        if (handshake == hs_ack) begin
                            state <= st_prep_recv_ack;
                        end else begin
                            state <= st_err;
                            success <= 1'b1;
                            transaction_active <= 1'b0;
                        end
                        tx_enable_crc16 <= 1'b0;
                        tx_transmit <= 1'b0;
                    end else begin
                        tx_data <= data_in;
                        data_strobe <= 1'b1;
                        tx_enable_crc16 <= 1'b1;
                    end
                end
            end
            st_prep_recv_ack: begin
                token_timeout <= 7'h7f;
                if (!tx_en && !recv_packet)
                    state <= st_recv_ack;
            end
            st_recv_ack: begin
                if (recv_packet) begin
                    state <= st_err;
                    if (recv_pid == 4'b0010) begin
                        success <= 1'b1;
                        transaction_active <= 1'b0;
                    end
                end
                if (!token_active && !recv_packet)
                    state <= st_idle;
            end
            st_send_ack: begin
                tx_transmit <= tx_transmit;

                if (!tx_transmit && recv_short_idle) begin
                    tx_data <= 8'b11010010; // ACK
                    tx_transmit <= 1'b1;
                    
                end
                
                if (tx_transmit && tx_data_strobe) begin
                    tx_transmit <= 1'b0;
                    state <= st_err;
                end
            end
            st_send_handshake: begin
                tx_transmit <= tx_transmit;

                if (!tx_transmit && recv_short_idle) begin
                    case (handshake_latch)
                        hs_none: begin
                            state <= st_idle;
                        end
                        hs_ack: begin
                            tx_data <= 8'b11010010;
                            tx_transmit <= 1'b1;
                        end
                        hs_nak: begin
                            tx_data <= 8'b01011010;
                            tx_transmit <= 1'b1;
                        end
                        hs_stall: begin
                            tx_data <= 8'b00011110;
                            tx_transmit <= 1'b1;
                        end
                    endcase
                end
                
                if (tx_transmit && tx_data_strobe) begin
                    tx_transmit <= 1'b0;
                    state <= st_err;
                end
            end
            default: begin
                transaction_active <= 1'b0;
                if (!tx_en && !recv_packet)
                    state <= st_idle;
            end
        endcase
    end
end

endmodule
module usb_ep(
    input clk,

    input direction_in,
    input setup,
    input success,
    input[6:0] cnt,

    output reg toggle,
    output bank_usb,
    output reg[1:0] handshake,
    output bank_in,
    output bank_out,
    output in_data_valid,

    input ctrl_dir_in,
    output reg[15:0] ctrl_rd_data,
    input[15:0] ctrl_wr_data,
    input[1:0] ctrl_wr_en
    );

localparam
    hs_ack = 2'b00,
    hs_none = 2'b01,
    hs_nak = 2'b10,
    hs_stall = 2'b11;

reg ep_setup;
reg ep_out_full;
reg ep_out_empty;
reg ep_in_full;
reg ep_out_stall;
reg ep_in_stall;
reg ep_out_toggle;
reg ep_in_toggle;
reg[6:0] ep_in_cnt;
reg[6:0] ep_out_cnt;

assign in_data_valid = (cnt != ep_in_cnt);
assign bank_usb = 1'b0;
assign bank_in = 1'b0;
assign bank_out = 1'b0;

always @(*) begin
    if (!direction_in && setup)
        toggle = 1'b0;
    else if (ep_setup)
        toggle = 1'b1;
    else if (direction_in)
        toggle = ep_in_toggle;
    else
        toggle = ep_out_toggle;
end

always @(*) begin
    if (direction_in) begin
        if (!ep_in_stall && !ep_setup && ep_in_full) begin
            handshake = hs_ack;
        end else if (!ep_setup && ep_in_stall) begin
            handshake = hs_stall;
        end else begin
            handshake = hs_nak;
        end
    end else begin
        if (setup || (!ep_out_stall && !ep_setup && ep_out_full)) begin
            handshake = hs_ack;
        end else if (!ep_setup && ep_out_stall) begin
            handshake = hs_stall;
        end else begin
            handshake = hs_nak;
        end
    end
end

always @(*) begin
    if (ctrl_dir_in) begin
        ctrl_rd_data[15:8] = ep_in_cnt;
        ctrl_rd_data[7:0] = { ep_in_toggle, ep_in_stall, 1'b0, !ep_in_full, ep_in_full };
    end else begin
        ctrl_rd_data[15:8] = ep_out_cnt;
        ctrl_rd_data[7:0] = { ep_out_toggle, ep_out_stall, ep_setup, ep_out_empty, ep_out_full };
    end
end

wire flush = ctrl_wr_data[5] || ctrl_wr_data[4] || ctrl_wr_data[3];

always @(posedge clk) begin
    if (success) begin
        if (direction_in) begin
            ep_in_full <= 1'b0;
            ep_in_toggle <= !ep_in_toggle;
        end else begin
            if (setup)
                ep_setup <= 1'b1;

            ep_out_toggle <= !ep_out_toggle;
            ep_out_empty <= 1'b0;
            ep_out_full <= 1'b0;
            ep_out_cnt <= cnt;
        end
    end

    if (ctrl_wr_en[1] && ctrl_dir_in) begin
        ep_in_cnt <= ctrl_wr_data[14:8];
    end

    if (ctrl_wr_en[0] && ctrl_dir_in) begin
        if (ctrl_wr_data[5]) begin
            ep_in_toggle <= 1'b0;
            ep_in_stall <= 1'b0;
        end
        if (ctrl_wr_data[4]) begin
            ep_in_toggle <= 1'b1;
            ep_in_stall <= 1'b0;
        end
        if (ctrl_wr_data[3])
            ep_in_stall <= 1'b1;

        if (flush)
            ep_in_full <= 1'b0;

        if (ctrl_wr_data[0])
            ep_in_full <= 1'b1;
    end

    if (ctrl_wr_en[0] && !ctrl_dir_in) begin
        if (ctrl_wr_data[5]) begin
            ep_out_toggle <= 1'b0;
            ep_out_stall <= 1'b0;
        end
        if (ctrl_wr_data[4]) begin
            ep_out_toggle <= 1'b1;
            ep_out_stall <= 1'b0;
        end
        if (ctrl_wr_data[3])
            ep_out_stall <= 1'b1;

        if (flush) begin
            ep_out_full <= 1'b0;
            ep_out_empty <= 1'b1;
        end

        if (ctrl_wr_data[2])
            ep_setup <= 1'b0;
        if (ctrl_wr_data[1])
            ep_out_empty <= 1'b1;
        if (ctrl_wr_data[0])
            ep_out_full <= 1'b1;
    end
end

endmodule
module usb_ep_banked(
    input clk,

    input direction_in,
    input setup,
    input success,
    input[6:0] cnt,

    output reg toggle,
    output bank_usb,
    output reg[1:0] handshake,
    output bank_in,
    output bank_out,
    output in_data_valid,

    input ctrl_dir_in,
    output reg[15:0] ctrl_rd_data,
    input[15:0] ctrl_wr_data,
    input[1:0] ctrl_wr_en
    );

localparam
    hs_ack = 2'b00,
    hs_none = 2'b01,
    hs_nak = 2'b10,
    hs_stall = 2'b11;

reg ep_setup;
reg ep_out_full;
reg ep_out_empty;
reg ep_in_empty;
reg ep_out_stall;
reg ep_in_stall;
reg ep_out_toggle;
reg ep_in_toggle;
reg ep_in_bank;
reg[6:0] ep_in_cnt_0;
reg[6:0] ep_in_cnt_1;
reg[6:0] ep_out_cnt;

assign in_data_valid = (cnt != (ep_in_toggle? ep_in_cnt_1: ep_in_cnt_0));
assign bank_usb = direction_in? ep_in_toggle: 1'b0;
assign bank_in = ep_in_bank;
assign bank_out = 1'b0;

always @(*) begin
    if (!direction_in && setup)
        toggle = 1'b0;
    else if (ep_setup)
        toggle = 1'b1;
    else if (direction_in)
        toggle = ep_in_toggle;
    else
        toggle = ep_out_toggle;
end

always @(*) begin
    if (direction_in) begin
        if (!ep_in_stall && !ep_setup && !ep_in_empty) begin
            handshake = hs_ack;
        end else if (!ep_setup && ep_in_stall) begin
            handshake = hs_stall;
        end else begin
            handshake = hs_nak;
        end
    end else begin
        if (setup || (!ep_out_stall && !ep_setup && ep_out_full)) begin
            handshake = hs_ack;
        end else if (!ep_setup && ep_out_stall) begin
            handshake = hs_stall;
        end else begin
            handshake = hs_nak;
        end
    end
end

always @(*) begin
    if (ctrl_dir_in) begin
        ctrl_rd_data[15:8] = ep_in_bank? ep_in_cnt_1: ep_in_cnt_0;
        ctrl_rd_data[7:0] = { ep_in_bank, ep_in_toggle, ep_in_stall, 1'b0, ep_in_empty, !ep_in_empty && ep_in_toggle == ep_in_bank };
    end else begin
        ctrl_rd_data[15:8] = ep_out_cnt;
        ctrl_rd_data[7:0] = { ep_out_toggle, ep_out_stall, ep_setup, ep_out_empty, ep_out_full };
    end
end

wire flush = ctrl_wr_data[5] || ctrl_wr_data[4] || ctrl_wr_data[3];

always @(posedge clk) begin
    if (success) begin
        if (direction_in) begin
            if (ep_in_toggle != ep_in_bank)
                ep_in_empty <= 1'b1;
            ep_in_toggle = !ep_in_toggle;
        end else begin
            if (setup)
                ep_setup <= 1'b1;

            ep_out_toggle = !ep_out_toggle;
            ep_out_empty <= 1'b0;
            ep_out_cnt <= cnt;
        end
    end

    if (ctrl_wr_en[1] && ctrl_dir_in) begin
        if (ep_in_bank)
            ep_in_cnt_1 <= ctrl_wr_data[14:8];
        else
            ep_in_cnt_0 <= ctrl_wr_data[14:8];
    end

    if (ctrl_wr_en[0] && ctrl_dir_in) begin
        if (ctrl_wr_data[5]) begin
            ep_in_toggle = 1'b0;
            ep_in_stall <= 1'b0;
            ep_in_bank <= 1'b0;
        end
        if (ctrl_wr_data[4]) begin
            ep_in_toggle = 1'b1;
            ep_in_stall <= 1'b0;
            ep_in_bank <= 1'b1;
        end
        if (ctrl_wr_data[3]) begin
            ep_in_stall <= 1'b1;
            ep_in_bank <= ep_in_toggle;
        end

        if (flush) begin
            ep_in_empty <= 1'b1;
        end

        if (ctrl_wr_data[0]) begin
            ep_in_empty <= 1'b0;
            ep_in_bank <= !ep_in_bank;
        end
    end

    if (ctrl_wr_en[0] && !ctrl_dir_in) begin
        if (ctrl_wr_data[5]) begin
            ep_out_toggle = 1'b0;
            ep_out_stall <= 1'b0;
        end
        if (ctrl_wr_data[4]) begin
            ep_out_toggle = 1'b1;
            ep_out_stall <= 1'b0;
        end
        if (ctrl_wr_data[3])
            ep_out_stall <= 1'b1;

        if (flush) begin
            ep_out_full <= 1'b0;
            ep_out_empty <= 1'b1;
        end

        if (ctrl_wr_data[2])
            ep_setup <= 1'b0;
        if (ctrl_wr_data[1]) begin
            ep_out_empty <= 1'b1;
            ep_out_full <= 1'b0;
        end
        if (ctrl_wr_data[0])
            ep_out_full <= 1'b1;
    end
end

endmodule
module usb_recv_sm(
    input rst_n,
    input clk,
    input strobe,
    input din,
    input sync,
    input se0,
    
    output reg[3:0] xpid,
    output reg[7:0] xdata,
    output xpacket,
    output reg xdatastrobe,
    output reg xcrc5_ok,
    output reg xcrc16_ok
    );

reg clear_shift;
reg[7:0] shift_reg;
reg[8:0] next_shift;

always @(*) begin
    if (clear_shift)
        next_shift = { 7'b1, din };
    else
        next_shift = { shift_reg[7:0], din };
end

always @(posedge clk) begin
    if (strobe) begin
        shift_reg <= next_shift[7:0];
    end
end

localparam
    st_idle = 2'b00,
    st_done = 2'b10,
    st_pid = 2'b01,
    st_data = 2'b11;

reg[1:0] state;

wire crc5_valid;
usb_crc5 crc5(
    .rst_n(rst_n && xpacket),
    .clk(clk),
    .clken(strobe),
    .d(din),
    .valid(crc5_valid)
    );

wire crc16_valid;
usb_crc16 crc16(
    .rst_n(rst_n && xpacket),
    .clk(clk),
    .clken(strobe),
    .d(din),
    .dump(1'b0),
    .out(),
    .valid(crc16_valid)
    );

assign xpacket = (state == st_data);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= st_idle;
        clear_shift <= 1'bx;

        xpid <= 1'sbx;
        xdata <= 1'sbx;
        xdatastrobe <= 1'b0;
        xcrc5_ok <= 1'b0;
        xcrc16_ok <= 1'b0;
    end else if (strobe) begin
        clear_shift <= 1'bx;
        xdatastrobe <= 1'b0;

        case (state)
            st_idle: begin
                if (sync && !se0) begin
                    state <= st_pid;
                    clear_shift <= 1'b1;
                end
            end
            st_pid: begin
                if (se0) begin
                    state <= st_idle;
                end else begin
                    if (next_shift[8]) begin
                        if (next_shift[7:4] == ~next_shift[3:0]) begin
                            clear_shift <= 1'b1;
                            xpid <= { next_shift[4], next_shift[5], next_shift[6], next_shift[7] };
                            state <= st_data;
                            xcrc5_ok <= 1'b0;
                            xcrc16_ok <= 1'b0;
                        end else begin
                            state <= st_done;
                        end
                    end else begin
                        clear_shift <= 1'b0;
                    end
                end
            end
            st_data: begin
                if (se0) begin
                    state <= st_idle;
                end else begin
                    clear_shift <= 1'b0;
                    if (next_shift[8]) begin
                        clear_shift <= 1'b1;
                        xdata <= {
                            next_shift[0], next_shift[1], next_shift[2], next_shift[3],
                            next_shift[4], next_shift[5], next_shift[6], next_shift[7] };
                        xdatastrobe <= 1'b1;
                        xcrc5_ok <= crc5_valid;
                        xcrc16_ok <= crc16_valid;
                    end
                end
            end
            default: begin
                if (se0)
                    state <= st_idle;
            end
        endcase
    end
end

endmodule

module usb_recv(
    input rst_n,
    input clk_48,

    input rx_j,
    input rx_se0,

    output short_idle,
    output usb_rst,

    output[3:0] xpid,
    output[7:0] xdata,
    output xpacket,
    output xdatastrobe,
    output xcrc5_ok,
    output xcrc16_ok
    );

wire j;
multisample3 d_filter(
    .clk(clk_48),
    .in(rx_j),
    .out(j));

wire se0;
multisample5 se0_filter(
    .clk(clk_48),
    .in(rx_se0),
    .out(se0));

reg[2:0] short_idle_counter;
assign short_idle = short_idle_counter == 1'b0;
always @(posedge clk_48) begin
    if (se0 || !j || xpacket)
        short_idle_counter <= 3'b111;
    else if (short_idle_counter != 1'b0)
        short_idle_counter <= short_idle_counter - 1'b1;
end

wire nrzi_strobe;
usb_clk_recovery clk_rcvr(
    .rst_n(rst_n),
    .clk(clk_48),
    .i(j),
    .strobe(nrzi_strobe)
    );

wire d;
nrzi_decode nrzi_decoder(
    .clk(clk_48),
    .clken(nrzi_strobe),
    .i(j),
    .o(d));

wire strobe;
usb_bit_destuff destuffer(
    .rst_n(rst_n),
    .clk(clk_48),
    .clken(nrzi_strobe),
    .d(d),
    .strobe(strobe)
    );

usb_reset_detect reset_detect(
    .rst_n(rst_n),
    .clk(clk_48),
    .se0(se0),
    .usb_rst(usb_rst));

wire sync_seq;
usb_sync_detect sync_detect(
    .rst_n(rst_n),
    .clk(clk_48),
    .clken(nrzi_strobe),
    .j(j),
    .se0(se0),
    .sync(sync_seq));

wire strobed_xdatastrobe;
assign xdatastrobe = strobed_xdatastrobe && strobe;

usb_recv_sm sm(
    .rst_n(rst_n),
    .clk(clk_48),
    .strobe(strobe),
    .din(d),
    .sync(sync_seq),
    .se0(se0),
    
    .xpid(xpid),
    .xdata(xdata),
    .xpacket(xpacket),
    .xdatastrobe(strobed_xdatastrobe),
    .xcrc5_ok(xcrc5_ok),
    .xcrc16_ok(xcrc16_ok)
    );

endmodule
module usb_tx(
    input rst_n,
    input clk_48,

    output tx_en,
    output tx_j,
    output tx_se0,
    
    input transmit,
    input[7:0] data,
    input update_crc16,
    input send_crc16,
    output data_strobe
    );

reg[1:0] tx_clock;
wire bit_strobe = tx_clock == 2'b00;
always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin
        tx_clock <= 2'b00;
    end else begin
        tx_clock <= tx_clock + 1'b1;
    end
end

wire bit_stuff;
wire tx_strobe = bit_strobe && !bit_stuff;

reg[2:0] state;
localparam
    st_idle = 3'b000,
    st_sync = 3'b101,
    st_run  = 3'b001,
    st_eop1 = 3'b010,
    st_eop2 = 3'b011,
    st_eop3 = 3'b100,
    st_crc1 = 3'b110,
    st_crc2 = 3'b111;

assign tx_en = (state != st_idle);

reg[8:0] tx_data;
reg crc_enabled;

wire dump_crc = state == st_crc1 || state == st_crc2;
wire crc_out;
wire d = dump_crc? !crc_out: tx_data[0];
wire se0 = !bit_stuff && (state == st_eop1 || state == st_eop2);

wire tx_data_empty = (tx_data[8:2] == 1'b0);
assign data_strobe = transmit && tx_data_empty && tx_strobe;

always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin
        state <= st_idle;
    end else if (tx_strobe) begin
        case (state)
            st_idle: begin
                if (transmit)
                    state <= st_run;
            end
            st_sync: begin
                if (tx_data_empty)
                    state <= st_run;
            end
            st_run: begin
                if (tx_data_empty && !transmit) begin
                    if (send_crc16)
                        state <= st_crc1;
                    else
                        state <= st_eop1;
                end
            end
            st_crc1: begin
                if (tx_data_empty)
                    state <= st_crc2;
            end
            st_crc2: begin
                if (tx_data_empty)
                    state <= st_eop1;
            end
            st_eop1: begin
                state <= st_eop2;
            end
            st_eop2: begin
                state <= st_eop3;
            end
            st_eop3: begin
                state <= st_idle;
            end
        endcase
    end
end
    
always @(posedge clk_48) begin
    if (tx_strobe) begin
        if (!tx_en) begin
            tx_data <= 9'b110000000; // starting with J, go through KJKJKJKK
            crc_enabled <= 1'b0;
        end else if (tx_data_empty) begin
            tx_data <= { 1'b1, data };
            crc_enabled <= update_crc16;
        end else begin
            tx_data <= { 1'b0, tx_data[8:1] };
        end
    end
end

reg[2:0] bit_stuff_counter;
assign bit_stuff = bit_stuff_counter == 3'd6;
always @(posedge clk_48 or negedge rst_n) begin
    if (!rst_n) begin
        bit_stuff_counter <= 1'b0;
    end else if (bit_strobe) begin
        if (state == st_idle || !d || bit_stuff || se0)
            bit_stuff_counter <= 1'b0;
        else
            bit_stuff_counter <= bit_stuff_counter + 1'b1;
    end
end

reg last_j;
wire j = state == st_idle || state == st_eop3? 1'b1: ((bit_stuff || !d)? !last_j: last_j);
always @(posedge clk_48) begin
    if (bit_strobe)
        last_j <= tx_en? j: 1'b1;
end

assign tx_j = j;
assign tx_se0 = se0;

usb_crc16 tx_crc(
    .rst_n(rst_n && state != st_idle),
    .clk(clk_48),
    .clken(tx_strobe && (dump_crc || crc_enabled)),
    .d(d),
    .dump(dump_crc),
    .out(crc_out),
    .valid()
    );

endmodule
module usb_crc5(
    input rst_n,
    input clk,
    input clken,
    input d,
    output valid
    );

reg[4:0] r;
reg[4:0] next;

wire top = r[4];
assign valid = (next == 5'b01100);

always @(*) begin
    if (top == d)
        next = { r[3], r[2], r[1], r[0], 1'b0 };
    else
        next = { r[3], r[2], !r[1], r[0], 1'b1 };
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r <= 5'b11111;
    end else if (clken) begin
        r <= next;
    end
end

endmodule

//---------------------------------------------------------------------
module usb_crc16(
    input rst_n,
    input clk,
    input clken,
    input d,
    
    input dump,
    output out,
    output valid
    );

reg[15:0] r;
reg[15:0] next;

assign out = r[15];
assign valid = (next == 16'b1000000000001101);

always @(*) begin
    if (dump || out == d)
        next = { r[14:0], 1'b0 };
    else
        next = { !r[14], r[13:2], !r[1], r[0], 1'b1 };
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r <= 16'hffff;
    end else if (clken) begin
        r <= next;
    end
end

endmodule

//---------------------------------------------------------------------
module usb_clk_recovery(
    input rst_n,
    input clk,
    input i,
    output strobe
    );

reg[1:0] cntr;
reg prev_i;

assign strobe = cntr == 1'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntr <= 1'b0;
        prev_i <= 1'b0;
    end else begin
        if (i == prev_i) begin
            cntr <= cntr - 1'b1;
        end else begin
            cntr <= 1'b1;
        end
        prev_i <= i;
    end
end

endmodule

//---------------------------------------------------------------------
module usb_bit_destuff(
    input rst_n,
    input clk,
    input clken,
    input d,
    output strobe);

reg[6:0] data;
assign strobe = clken && (data != 7'b0111111);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data <= 7'b0000000;
    end else if (clken) begin
        data <= { data[5:0], d };
    end
end

endmodule

//---------------------------------------------------------------------
module usb_sync_detect(
    input rst_n,
    input clk,
    input clken,
    input j,
    input se0,
    output sync);

// 3KJ's followed by 2K's
reg[6:0] data;
assign sync = (data == 7'b0101010 && !j && !se0);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data <= 1'd0;
    end else if (clken) begin
        data <= { data[5:0], j || se0 };
    end
end

endmodule

//---------------------------------------------------------------------
module usb_reset_detect(
    input rst_n,
    input clk,
    input se0,
    output usb_rst);

reg[18:0] cntr;
assign usb_rst = cntr == 1'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntr <= 1'b0;
    end else begin
        if (se0) begin
            if (!usb_rst)
                cntr <= cntr - 1'b1;
        end else begin
            cntr <= 19'd480000;
        end
    end
end

endmodule
module multisample3(
    input clk,
    input in,
    output reg out
    );

reg[2:0] r;

always @(r) begin
    case (r)
        3'b000: out = 1'b0;
        3'b001: out = 1'b0;
        3'b010: out = 1'b0;
        3'b011: out = 1'b1;
        3'b100: out = 1'b0;
        3'b101: out = 1'b1;
        3'b110: out = 1'b1;
        3'b111: out = 1'b1;
    endcase
end

always @(posedge clk) begin
    r <= { r[1:0], in };
end

endmodule

//---------------------------------------------------------------------
module multisample5(
    input clk,
    input in,
    output reg out
    );

reg[4:0] r;

always @(r) begin
    case (r)
        5'b00000: out = 1'b0;
        5'b00001: out = 1'b0;
        5'b00010: out = 1'b0;
        5'b00011: out = 1'b0;
        5'b00100: out = 1'b0;
        5'b00101: out = 1'b0;
        5'b00110: out = 1'b0;
        5'b00111: out = 1'b1;
        5'b01000: out = 1'b0;
        5'b01001: out = 1'b0;
        5'b01010: out = 1'b0;
        5'b01011: out = 1'b1;
        5'b01100: out = 1'b0;
        5'b01101: out = 1'b1;
        5'b01110: out = 1'b1;
        5'b01111: out = 1'b1;
        5'b10000: out = 1'b0;
        5'b10001: out = 1'b0;
        5'b10010: out = 1'b0;
        5'b10011: out = 1'b1;
        5'b10100: out = 1'b0;
        5'b10101: out = 1'b1;
        5'b10110: out = 1'b1;
        5'b10111: out = 1'b1;
        5'b11000: out = 1'b0;
        5'b11001: out = 1'b1;
        5'b11010: out = 1'b1;
        5'b11011: out = 1'b1;
        5'b11100: out = 1'b1;
        5'b11101: out = 1'b1;
        5'b11110: out = 1'b1;
        5'b11111: out = 1'b1;
    endcase
end

always @(posedge clk) begin
    r <= { r[3:0], in };
end

endmodule

//---------------------------------------------------------------------
module nrzi_decode(
    input clk,
    input clken,
    input i,
    output o
    );

reg prev_i;
assign o = (prev_i == i);

always @(posedge clk) begin
    if (clken) begin
        prev_i <= i;
    end
end

endmodule