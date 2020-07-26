//-----------------------------------------------------------------
//                       USB CDC Device
//                            V0.1
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
//
//                 Email: admin@ultra-embedded.com
//
//                         License: LGPL
//-----------------------------------------------------------------
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------

module usbf_sie_rx
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           enable_i
    ,input  [  7:0]  utmi_data_i
    ,input           utmi_rxvalid_i
    ,input           utmi_rxactive_i
    ,input  [  6:0]  current_addr_i

    // Outputs
    ,output [  7:0]  pid_o
    ,output          frame_valid_o
    ,output [ 10:0]  frame_number_o
    ,output          token_valid_o
    ,output [  6:0]  token_addr_o
    ,output [  3:0]  token_ep_o
    ,output          token_crc_err_o
    ,output          handshake_valid_o
    ,output          data_valid_o
    ,output          data_strb_o
    ,output [  7:0]  data_o
    ,output          data_last_o
    ,output          data_crc_err_o
    ,output          data_complete_o
);



//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
`include "usbf_defs.v"

localparam STATE_W                       = 4;
localparam STATE_RX_IDLE                 = 4'd0;
localparam STATE_RX_TOKEN2               = 4'd1;
localparam STATE_RX_TOKEN3               = 4'd2;
localparam STATE_RX_TOKEN_COMPLETE       = 4'd3;
localparam STATE_RX_SOF2                 = 4'd4;
localparam STATE_RX_SOF3                 = 4'd5;
localparam STATE_RX_DATA                 = 4'd6;
localparam STATE_RX_DATA_COMPLETE        = 4'd7;
localparam STATE_RX_IGNORED              = 4'd8;
reg [STATE_W-1:0] state_q;

//-----------------------------------------------------------------
// Wire / Regs
//-----------------------------------------------------------------
`define USB_FRAME_W    11
reg [`USB_FRAME_W-1:0]      frame_num_q;

`define USB_DEV_W      7
reg [`USB_DEV_W-1:0]        token_dev_q;

`define USB_EP_W       4
reg [`USB_EP_W-1:0]         token_ep_q;

`define USB_PID_W      8
reg [`USB_PID_W-1:0]        token_pid_q;

//-----------------------------------------------------------------
// Data delay (to strip the CRC16 trailing bytes)
//-----------------------------------------------------------------
reg [31:0] data_buffer_q;
reg [3:0]  data_valid_q;
reg [3:0]  rx_active_q;

wire shift_en_w = (utmi_rxvalid_i & utmi_rxactive_i) || !utmi_rxactive_i;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_buffer_q <= 32'b0;
else if (shift_en_w)
    data_buffer_q <= {utmi_data_i, data_buffer_q[31:8]};

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_valid_q <= 4'b0;
else if (shift_en_w)
    data_valid_q <= {(utmi_rxvalid_i & utmi_rxactive_i), data_valid_q[3:1]};
else
    data_valid_q <= {data_valid_q[3:1], 1'b0};

reg [1:0] data_crc_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_crc_q <= 2'b0;
else if (shift_en_w)
    data_crc_q <= {!utmi_rxactive_i, data_crc_q[1]};

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    rx_active_q <= 4'b0;
else
    rx_active_q <= {utmi_rxactive_i, rx_active_q[3:1]};

wire [7:0] data_w       = data_buffer_q[7:0];
wire       data_ready_w = data_valid_q[0];
wire       crc_byte_w   = data_crc_q[0];
wire       rx_active_w  = rx_active_q[0];

wire       address_match_w = (token_dev_q == current_addr_i);

//-----------------------------------------------------------------
// Next state
//-----------------------------------------------------------------
reg [STATE_W-1:0] next_state_r;

always @ *
begin
    next_state_r = state_q;

    case (state_q)

    //-----------------------------------------
    // IDLE
    //-----------------------------------------
    STATE_RX_IDLE :
    begin
       if (data_ready_w)
       begin
           // Decode PID
           case (data_w)

              `PID_OUT, `PID_IN, `PID_SETUP, `PID_PING:
                    next_state_r  = STATE_RX_TOKEN2;

              `PID_SOF:
                    next_state_r  = STATE_RX_SOF2;

              `PID_DATA0, `PID_DATA1, `PID_DATA2, `PID_MDATA:
              begin
                    next_state_r  = STATE_RX_DATA;
              end

              `PID_ACK, `PID_NAK, `PID_STALL, `PID_NYET:
                    next_state_r  = STATE_RX_IDLE;

              default : // SPLIT / ERR
                    next_state_r  = STATE_RX_IGNORED;
           endcase
       end
    end

    //-----------------------------------------
    // RX_IGNORED: Unknown / unsupported
    //-----------------------------------------
    STATE_RX_IGNORED :
    begin
        // Wait until the end of the packet
        if (!rx_active_w)
           next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // SOF (BYTE 2)
    //-----------------------------------------
    STATE_RX_SOF2 :
    begin
       if (data_ready_w)
           next_state_r = STATE_RX_SOF3;
       else if (!rx_active_w)
           next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // SOF (BYTE 3)
    //-----------------------------------------
    STATE_RX_SOF3 :
    begin
       if (data_ready_w || !rx_active_w)
           next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
    //-----------------------------------------
    STATE_RX_TOKEN2 :
    begin
       if (data_ready_w)
           next_state_r = STATE_RX_TOKEN3;
       else if (!rx_active_w)
           next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // TOKEN (IN/OUT/SETUP) (Endpoint/CRC)
    //-----------------------------------------
    STATE_RX_TOKEN3 :
    begin
       if (data_ready_w)
           next_state_r = STATE_RX_TOKEN_COMPLETE;
       else if (!rx_active_w)
           next_state_r = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // RX_TOKEN_COMPLETE
    //-----------------------------------------
    STATE_RX_TOKEN_COMPLETE :
    begin
        next_state_r  = STATE_RX_IDLE;
    end

    //-----------------------------------------
    // RX_DATA
    //-----------------------------------------
    STATE_RX_DATA :
    begin
       // Receive complete
       if (crc_byte_w)
            next_state_r = STATE_RX_DATA_COMPLETE;
    end

    //-----------------------------------------
    // RX_DATA_COMPLETE
    //-----------------------------------------
    STATE_RX_DATA_COMPLETE :
    begin
        if (!rx_active_w)
            next_state_r = STATE_RX_IDLE;
    end

    default :
       ;

    endcase
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q   <= STATE_RX_IDLE;
else if (!enable_i)
    state_q   <= STATE_RX_IDLE;
else
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// Handshake:
//-----------------------------------------------------------------
reg handshake_valid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    handshake_valid_q <= 1'b0;
else if (state_q == STATE_RX_IDLE && data_ready_w)
begin
    case (data_w)
    `PID_ACK, `PID_NAK, `PID_STALL, `PID_NYET:
        handshake_valid_q <= address_match_w;
    default :
        handshake_valid_q <= 1'b0;
    endcase
end
else
    handshake_valid_q <= 1'b0;

assign handshake_valid_o = handshake_valid_q;

//-----------------------------------------------------------------
// SOF: Frame number
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    frame_num_q         <= `USB_FRAME_W'b0;
else if (state_q == STATE_RX_SOF2 && data_ready_w)
    frame_num_q         <= {3'b0, data_w};
else if (state_q == STATE_RX_SOF3 && data_ready_w)
    frame_num_q         <= {data_w[2:0], frame_num_q[7:0]};
else if (!enable_i)
    frame_num_q         <= `USB_FRAME_W'b0;

assign frame_number_o = frame_num_q;

reg frame_valid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    frame_valid_q <= 1'b0;
else
    frame_valid_q <= (state_q == STATE_RX_SOF3 && data_ready_w);

assign frame_valid_o = frame_valid_q;

//-----------------------------------------------------------------
// Token: PID
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    token_pid_q <= `USB_PID_W'b0;
else if (state_q == STATE_RX_IDLE && data_ready_w)
    token_pid_q <= data_w;
else if (!enable_i)
    token_pid_q <= `USB_PID_W'b0;

assign pid_o = token_pid_q;

reg token_valid_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    token_valid_q <= 1'b0;
else
    token_valid_q <= (state_q == STATE_RX_TOKEN_COMPLETE) && address_match_w;

assign token_valid_o = token_valid_q;

//-----------------------------------------------------------------
// Token: Device Address
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    token_dev_q <= `USB_DEV_W'b0;
else if (state_q == STATE_RX_TOKEN2 && data_ready_w)
    token_dev_q <= data_w[6:0];
else if (!enable_i)
    token_dev_q <= `USB_DEV_W'b0;

assign token_addr_o = token_dev_q;

//-----------------------------------------------------------------
// Token: Endpoint
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    token_ep_q      <= `USB_EP_W'b0;
else if (state_q == STATE_RX_TOKEN2 && data_ready_w)
    token_ep_q[0]   <= data_w[7];
else if (state_q == STATE_RX_TOKEN3 && data_ready_w)
    token_ep_q[3:1] <= data_w[2:0];
else if (!enable_i)
    token_ep_q      <= `USB_EP_W'b0;

assign token_ep_o = token_ep_q;
assign token_crc_err_o = 1'b0;

wire [7:0] input_data_w  = data_w;
wire       input_ready_w = state_q == STATE_RX_DATA && data_ready_w && !crc_byte_w;

//-----------------------------------------------------------------
// CRC16: Generate CRC16 on incoming data bytes
//-----------------------------------------------------------------
reg [15:0]  crc_sum_q;
wire [15:0] crc_out_w;
reg         crc_err_q;

usbf_crc16
u_crc16
(
    .crc_in_i(crc_sum_q),
    .din_i(data_w),
    .crc_out_o(crc_out_w)
);

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    crc_sum_q   <= 16'hFFFF;
else if (state_q == STATE_RX_IDLE)
    crc_sum_q   <= 16'hFFFF;
else if (data_ready_w)
    crc_sum_q   <= crc_out_w;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    crc_err_q   <= 1'b0;
else if (state_q == STATE_RX_IDLE)
    crc_err_q   <= 1'b0;
else if (state_q == STATE_RX_DATA_COMPLETE && next_state_r == STATE_RX_IDLE)
    crc_err_q   <= (crc_sum_q != 16'hB001);

assign data_crc_err_o = crc_err_q;

reg data_complete_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_complete_q   <= 1'b0;
else if (state_q == STATE_RX_DATA_COMPLETE && next_state_r == STATE_RX_IDLE)
    data_complete_q   <= 1'b1;
else
    data_complete_q   <= 1'b0;

assign data_complete_o = data_complete_q;

reg data_zlp_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    data_zlp_q   <= 1'b0;
else if (state_q == STATE_RX_IDLE && next_state_r == STATE_RX_DATA)
    data_zlp_q   <= 1'b1;
else if (input_ready_w)
    data_zlp_q   <= 1'b0;

//-----------------------------------------------------------------
// Data Output
//-----------------------------------------------------------------
reg        valid_q;
reg        last_q;
reg [7:0]  data_q;
reg        mask_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    valid_q  <= 1'b0;
    data_q   <= 8'b0;
    mask_q   <= 1'b0;
    last_q   <= 1'b0;
end
else
begin
    valid_q  <= input_ready_w || ((state_q == STATE_RX_DATA) && crc_byte_w && data_zlp_q);
    data_q   <= input_data_w;
    mask_q   <= input_ready_w;
    last_q   <= (state_q == STATE_RX_DATA) && crc_byte_w;
end

// Data
assign data_valid_o = valid_q;
assign data_strb_o  = mask_q;
assign data_o       = data_q;
assign data_last_o  = last_q | crc_byte_w;


endmodule
