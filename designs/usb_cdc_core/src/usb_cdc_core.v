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

module usb_cdc_core
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           enable_i
    ,input  [  7:0]  utmi_data_in_i
    ,input           utmi_txready_i
    ,input           utmi_rxvalid_i
    ,input           utmi_rxactive_i
    ,input           utmi_rxerror_i
    ,input  [  1:0]  utmi_linestate_i
    ,input           inport_valid_i
    ,input  [  7:0]  inport_data_i
    ,input           outport_accept_i

    // Outputs
    ,output [  7:0]  utmi_data_out_o
    ,output          utmi_txvalid_o
    ,output [  1:0]  utmi_op_mode_o
    ,output [  1:0]  utmi_xcvrselect_o
    ,output          utmi_termselect_o
    ,output          utmi_dppulldown_o
    ,output          utmi_dmpulldown_o
    ,output          inport_accept_o
    ,output          outport_valid_o
    ,output [  7:0]  outport_data_o
);




parameter USB_SPEED_HS = "False"; // True or False

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
// Device class
`define DEV_CLASS_RESERVED              8'h00
`define DEV_CLASS_AUDIO                 8'h01
`define DEV_CLASS_COMMS                 8'h02
`define DEV_CLASS_HID                   8'h03
`define DEV_CLASS_MONITOR               8'h04
`define DEV_CLASS_PHY_IF                8'h05
`define DEV_CLASS_POWER                 8'h06
`define DEV_CLASS_PRINTER               8'h07
`define DEV_CLASS_STORAGE               8'h08
`define DEV_CLASS_HUB                   8'h09
`define DEV_CLASS_TMC                   8'hFE
`define DEV_CLASS_VENDOR_CUSTOM         8'hFF

// Standard requests (via SETUP packets)
`define REQ_GET_STATUS                  8'h00
`define REQ_CLEAR_FEATURE               8'h01
`define REQ_SET_FEATURE                 8'h03
`define REQ_SET_ADDRESS                 8'h05
`define REQ_GET_DESCRIPTOR              8'h06
`define REQ_SET_DESCRIPTOR              8'h07
`define REQ_GET_CONFIGURATION           8'h08
`define REQ_SET_CONFIGURATION           8'h09
`define REQ_GET_INTERFACE               8'h0A
`define REQ_SET_INTERFACE               8'h0B
`define REQ_SYNC_FRAME                  8'h0C

// Descriptor types
`define DESC_DEVICE                     8'h01
`define DESC_CONFIGURATION              8'h02
`define DESC_STRING                     8'h03
`define DESC_INTERFACE                  8'h04
`define DESC_ENDPOINT                   8'h05
`define DESC_DEV_QUALIFIER              8'h06
`define DESC_OTHER_SPEED_CONF           8'h07
`define DESC_IF_POWER                   8'h08

// Endpoints
`define ENDPOINT_DIR_MASK               8'h80
`define ENDPOINT_DIR_R                  7
`define ENDPOINT_DIR_IN                 1'b1
`define ENDPOINT_DIR_OUT                1'b0
`define ENDPOINT_ADDR_MASK              8'h7F
`define ENDPOINT_TYPE_MASK              8'h3
`define ENDPOINT_TYPE_CONTROL           0
`define ENDPOINT_TYPE_ISO               1
`define ENDPOINT_TYPE_BULK              2
`define ENDPOINT_TYPE_INTERRUPT         3

// Device Requests (bmRequestType)
`define USB_RECIPIENT_MASK              8'h1F
`define USB_RECIPIENT_DEVICE            8'h00
`define USB_RECIPIENT_INTERFACE         8'h01
`define USB_RECIPIENT_ENDPOINT          8'h02
`define USB_REQUEST_TYPE_MASK           8'h60
`define USB_STANDARD_REQUEST            8'h00
`define USB_CLASS_REQUEST               8'h20
`define USB_VENDOR_REQUEST              8'h40

// USB device addresses are 7-bits
`define USB_ADDRESS_MASK                8'h7F

// USB Feature Selectors
`define USB_FEATURE_ENDPOINT_STATE      16'h0000
`define USB_FEATURE_REMOTE_WAKEUP       16'h0001
`define USB_FEATURE_TEST_MODE           16'h0002

// String Descriptors
`define UNICODE_LANGUAGE_STR_ID         8'd0
`define MANUFACTURER_STR_ID             8'd1
`define PRODUCT_NAME_STR_ID             8'd2
`define SERIAL_NUM_STR_ID               8'd3

`define CDC_ENDPOINT_BULK_OUT           1
`define CDC_ENDPOINT_BULK_IN            2
`define CDC_ENDPOINT_INTR_IN            3

`define CDC_SEND_ENCAPSULATED_COMMAND   8'h00
`define CDC_GET_ENCAPSULATED_RESPONSE   8'h01
`define CDC_GET_LINE_CODING             8'h21
`define CDC_SET_LINE_CODING             8'h20
`define CDC_SET_CONTROL_LINE_STATE      8'h22
`define CDC_SEND_BREAK                  8'h23

// Descriptor ROM offsets / sizes
`define ROM_DESC_DEVICE_ADDR            8'd0
`define ROM_DESC_DEVICE_SIZE            16'd18
`define ROM_DESC_CONF_ADDR              8'd18
`define ROM_DESC_CONF_SIZE              16'd67
`define ROM_DESC_STR_LANG_ADDR          8'd85
`define ROM_DESC_STR_LANG_SIZE          16'd4
`define ROM_DESC_STR_MAN_ADDR           8'd89
`define ROM_DESC_STR_MAN_SIZE           16'd30
`define ROM_DESC_STR_PROD_ADDR          8'd119
`define ROM_DESC_STR_PROD_SIZE          16'd30
`define ROM_DESC_STR_SERIAL_ADDR        8'd149
`define ROM_DESC_STR_SERIAL_SIZE        16'd14
`define ROM_CDC_LINE_CODING_ADDR        8'd163
`define ROM_CDC_LINE_CODING_SIZE        16'd7

//-----------------------------------------------------------------
// Wires
//-----------------------------------------------------------------
wire         usb_reset_w;
reg  [6:0]   device_addr_q;

wire         usb_ep0_tx_rd_w;
wire [7:0]   usb_ep0_tx_data_w;
wire         usb_ep0_tx_empty_w;

wire         usb_ep0_rx_wr_w;
wire [7:0]   usb_ep0_rx_data_w;
wire         usb_ep0_rx_full_w;
wire         usb_ep1_tx_rd_w;
wire [7:0]   usb_ep1_tx_data_w;
wire         usb_ep1_tx_empty_w;

wire         usb_ep1_rx_wr_w;
wire [7:0]   usb_ep1_rx_data_w;
wire         usb_ep1_rx_full_w;
wire         usb_ep2_tx_rd_w;
wire [7:0]   usb_ep2_tx_data_w;
wire         usb_ep2_tx_empty_w;

wire         usb_ep2_rx_wr_w;
wire [7:0]   usb_ep2_rx_data_w;
wire         usb_ep2_rx_full_w;
wire         usb_ep3_tx_rd_w;
wire [7:0]   usb_ep3_tx_data_w;
wire         usb_ep3_tx_empty_w;

wire         usb_ep3_rx_wr_w;
wire [7:0]   usb_ep3_rx_data_w;
wire         usb_ep3_rx_full_w;

// Rx SIE Interface (shared)
wire        rx_strb_w;
wire [7:0]  rx_data_w;
wire        rx_last_w;
wire        rx_crc_err_w;

// EP0 Rx SIE Interface
wire        ep0_rx_space_w;
wire        ep0_rx_valid_w;
wire        ep0_rx_setup_w;

// EP0 Tx SIE Interface
wire        ep0_tx_ready_w;
wire        ep0_tx_data_valid_w;
wire        ep0_tx_data_strb_w;
wire [7:0]  ep0_tx_data_w;
wire        ep0_tx_data_last_w;
wire        ep0_tx_data_accept_w;
wire        ep0_tx_stall_w;
// EP1 Rx SIE Interface
wire        ep1_rx_space_w;
wire        ep1_rx_valid_w;
wire        ep1_rx_setup_w;

// EP1 Tx SIE Interface
wire        ep1_tx_ready_w;
wire        ep1_tx_data_valid_w;
wire        ep1_tx_data_strb_w;
wire [7:0]  ep1_tx_data_w;
wire        ep1_tx_data_last_w;
wire        ep1_tx_data_accept_w;
wire        ep1_tx_stall_w;
// EP2 Rx SIE Interface
wire        ep2_rx_space_w;
wire        ep2_rx_valid_w;
wire        ep2_rx_setup_w;

// EP2 Tx SIE Interface
wire        ep2_tx_ready_w;
wire        ep2_tx_data_valid_w;
wire        ep2_tx_data_strb_w;
wire [7:0]  ep2_tx_data_w;
wire        ep2_tx_data_last_w;
wire        ep2_tx_data_accept_w;
wire        ep2_tx_stall_w;
// EP3 Rx SIE Interface
wire        ep3_rx_space_w;
wire        ep3_rx_valid_w;
wire        ep3_rx_setup_w;

// EP3 Tx SIE Interface
wire        ep3_tx_ready_w;
wire        ep3_tx_data_valid_w;
wire        ep3_tx_data_strb_w;
wire [7:0]  ep3_tx_data_w;
wire        ep3_tx_data_last_w;
wire        ep3_tx_data_accept_w;
wire        ep3_tx_stall_w;

wire utmi_chirp_en_w;
wire usb_hs_w;

//-----------------------------------------------------------------
// Transceiver Control (high speed)
//-----------------------------------------------------------------
generate 
if (USB_SPEED_HS == "True")
begin

localparam STATE_W                       = 3;
localparam STATE_IDLE                    = 3'd0;
localparam STATE_WAIT_RST                = 3'd1;
localparam STATE_SEND_CHIRP_K            = 3'd2;
localparam STATE_WAIT_CHIRP_JK           = 3'd3;
localparam STATE_FULLSPEED               = 3'd4;
localparam STATE_HIGHSPEED               = 3'd5;
reg [STATE_W-1:0] state_q;
reg [STATE_W-1:0] next_state_r;

// 60MHz clock rate
`define USB_RST_W  20
reg [`USB_RST_W-1:0] usb_rst_time_q;
reg [7:0]            chirp_count_q;
reg [1:0]            last_linestate_q;

localparam DETACH_TIME    = 20'd60000;  // 1ms -> T0
localparam ATTACH_FS_TIME = 20'd180000; // T0 + 3ms = T1
localparam CHIRPK_TIME    = 20'd246000; // T1 + ~1ms
localparam HS_RESET_TIME  = 20'd600000; // T0 + 10ms = T9
localparam HS_CHIRP_COUNT = 8'd5;

reg [  1:0]  utmi_op_mode_r;
reg [  1:0]  utmi_xcvrselect_r;
reg          utmi_termselect_r;
reg          utmi_dppulldown_r;
reg          utmi_dmpulldown_r;

always @ *
begin
    next_state_r = state_q;

    // Default - disconnect
    utmi_op_mode_r    = 2'd1;
    utmi_xcvrselect_r = 2'd0;
    utmi_termselect_r = 1'b0;
    utmi_dppulldown_r = 1'b0;
    utmi_dmpulldown_r = 1'b0;

    case (state_q)
    STATE_IDLE:
    begin
        // Detached
        if (enable_i && usb_rst_time_q >= DETACH_TIME)
            next_state_r = STATE_WAIT_RST;
    end
    STATE_WAIT_RST:
    begin
        // Assert FS mode, check for SE0 (T0)
        utmi_op_mode_r    = 2'd0;
        utmi_xcvrselect_r = 2'd1;
        utmi_termselect_r = 1'b1;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;

        // Wait for SE0 (T1), send device chirp K
        if (usb_rst_time_q >= ATTACH_FS_TIME)
            next_state_r = STATE_SEND_CHIRP_K;
    end
    STATE_SEND_CHIRP_K:
    begin
        // Send chirp K
        utmi_op_mode_r    = 2'd2;
        utmi_xcvrselect_r = 2'd0;
        utmi_termselect_r = 1'b1;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;

        // End of device chirp K (T2)
        if (usb_rst_time_q >= CHIRPK_TIME)
            next_state_r = STATE_WAIT_CHIRP_JK;
    end
    STATE_WAIT_CHIRP_JK:
    begin
        // Stop sending chirp K and wait for downstream port chirps
        utmi_op_mode_r    = 2'd2;
        utmi_xcvrselect_r = 2'd0;
        utmi_termselect_r = 1'b1;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;

        // Required number of chirps detected, move to HS mode (T7)
        if (chirp_count_q >= HS_CHIRP_COUNT)
            next_state_r = STATE_HIGHSPEED;
        // Time out waiting for chirps, fallback to FS mode
        else if (usb_rst_time_q >= HS_RESET_TIME)
            next_state_r = STATE_FULLSPEED;
    end
    STATE_FULLSPEED:
    begin
        utmi_op_mode_r    = 2'd0;
        utmi_xcvrselect_r = 2'd1;
        utmi_termselect_r = 1'b1;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;

        // USB reset detected...
        if (usb_rst_time_q >= HS_RESET_TIME && usb_reset_w)
            next_state_r = STATE_WAIT_RST;
    end
    STATE_HIGHSPEED:
    begin
        // Enter HS mode
        utmi_op_mode_r    = 2'd0;
        utmi_xcvrselect_r = 2'd0;
        utmi_termselect_r = 1'b0;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;

        // Long SE0 - could be reset or suspend
        // TODO: Should revert to FS mode and check...
        if (usb_rst_time_q >= HS_RESET_TIME && usb_reset_w)
            next_state_r = STATE_WAIT_RST;
    end
    default:
        ;
    endcase
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q   <= STATE_IDLE;
else
    state_q   <= next_state_r;

// Time since T0 (start of HS reset)
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    usb_rst_time_q <= `USB_RST_W'b0;
// Entering wait for reset state
else if (next_state_r == STATE_WAIT_RST && state_q != STATE_WAIT_RST)
    usb_rst_time_q <=  `USB_RST_W'b0;
// Waiting for reset, reset count on line state toggle
else if (state_q == STATE_WAIT_RST && (utmi_linestate_i != 2'b00))
    usb_rst_time_q <=  `USB_RST_W'b0;
else if (usb_rst_time_q != {(`USB_RST_W){1'b1}})
    usb_rst_time_q <= usb_rst_time_q + `USB_RST_W'd1;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    last_linestate_q   <= 2'b0;
else
    last_linestate_q   <= utmi_linestate_i;

// Chirp counter
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    chirp_count_q   <= 8'b0;
else if (state_q == STATE_SEND_CHIRP_K)
    chirp_count_q   <= 8'b0;
else if (state_q == STATE_WAIT_CHIRP_JK && (last_linestate_q != utmi_linestate_i) && chirp_count_q != 8'hFF)
    chirp_count_q   <= chirp_count_q + 8'd1;

assign utmi_op_mode_o    = utmi_op_mode_r;
assign utmi_xcvrselect_o = utmi_xcvrselect_r;
assign utmi_termselect_o = utmi_termselect_r;
assign utmi_dppulldown_o = utmi_dppulldown_r;
assign utmi_dmpulldown_o = utmi_dmpulldown_r;

assign utmi_chirp_en_w   = (state_q == STATE_SEND_CHIRP_K);
assign usb_hs_w          = (state_q == STATE_HIGHSPEED);

end
else
begin
//-----------------------------------------------------------------
// Transceiver Control
//-----------------------------------------------------------------
reg [  1:0]  utmi_op_mode_r;
reg [  1:0]  utmi_xcvrselect_r;
reg          utmi_termselect_r;
reg          utmi_dppulldown_r;
reg          utmi_dmpulldown_r;

always @ *
begin
    if (enable_i)
    begin
        utmi_op_mode_r    = 2'd0;
        utmi_xcvrselect_r = 2'd1;
        utmi_termselect_r = 1'b1;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;
    end
    else
    begin
        utmi_op_mode_r    = 2'd1;
        utmi_xcvrselect_r = 2'd0;
        utmi_termselect_r = 1'b0;
        utmi_dppulldown_r = 1'b0;
        utmi_dmpulldown_r = 1'b0;
    end
end

assign utmi_op_mode_o    = utmi_op_mode_r;
assign utmi_xcvrselect_o = utmi_xcvrselect_r;
assign utmi_termselect_o = utmi_termselect_r;
assign utmi_dppulldown_o = utmi_dppulldown_r;
assign utmi_dmpulldown_o = utmi_dmpulldown_r;

assign utmi_chirp_en_w   = 1'b0;
assign usb_hs_w          = 1'b0;

end
endgenerate

//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------
usbf_device_core
u_core
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .intr_o(),

    // UTMI interface
    .utmi_data_o(utmi_data_out_o),
    .utmi_data_i(utmi_data_in_i),
    .utmi_txvalid_o(utmi_txvalid_o),
    .utmi_txready_i(utmi_txready_i),
    .utmi_rxvalid_i(utmi_rxvalid_i),
    .utmi_rxactive_i(utmi_rxactive_i),
    .utmi_rxerror_i(utmi_rxerror_i),
    .utmi_linestate_i(utmi_linestate_i),

    .reg_chirp_en_i(utmi_chirp_en_w),
    .reg_int_en_sof_i(1'b0),

    .reg_dev_addr_i(device_addr_q),

    // Rx SIE Interface (shared)
    .rx_strb_o(rx_strb_w),
    .rx_data_o(rx_data_w),
    .rx_last_o(rx_last_w),
    .rx_crc_err_o(rx_crc_err_w),

    // EP0 Config
    .ep0_iso_i(1'b0),
    .ep0_stall_i(ep0_tx_stall_w),
    .ep0_cfg_int_rx_i(1'b0),
    .ep0_cfg_int_tx_i(1'b0),

    // EP0 Rx SIE Interface
    .ep0_rx_setup_o(ep0_rx_setup_w),
    .ep0_rx_valid_o(ep0_rx_valid_w),
    .ep0_rx_space_i(ep0_rx_space_w),

    // EP0 Tx SIE Interface
    .ep0_tx_ready_i(ep0_tx_ready_w),
    .ep0_tx_data_valid_i(ep0_tx_data_valid_w),
    .ep0_tx_data_strb_i(ep0_tx_data_strb_w),
    .ep0_tx_data_i(ep0_tx_data_w),
    .ep0_tx_data_last_i(ep0_tx_data_last_w),
    .ep0_tx_data_accept_o(ep0_tx_data_accept_w),

    // EP1 Config
    .ep1_iso_i(1'b0),
    .ep1_stall_i(ep1_tx_stall_w),
    .ep1_cfg_int_rx_i(1'b0),
    .ep1_cfg_int_tx_i(1'b0),

    // EP1 Rx SIE Interface
    .ep1_rx_setup_o(ep1_rx_setup_w),
    .ep1_rx_valid_o(ep1_rx_valid_w),
    .ep1_rx_space_i(ep1_rx_space_w),

    // EP1 Tx SIE Interface
    .ep1_tx_ready_i(ep1_tx_ready_w),
    .ep1_tx_data_valid_i(ep1_tx_data_valid_w),
    .ep1_tx_data_strb_i(ep1_tx_data_strb_w),
    .ep1_tx_data_i(ep1_tx_data_w),
    .ep1_tx_data_last_i(ep1_tx_data_last_w),
    .ep1_tx_data_accept_o(ep1_tx_data_accept_w),

    // EP2 Config
    .ep2_iso_i(1'b0),
    .ep2_stall_i(ep2_tx_stall_w),
    .ep2_cfg_int_rx_i(1'b0),
    .ep2_cfg_int_tx_i(1'b0),

    // EP2 Rx SIE Interface
    .ep2_rx_setup_o(ep2_rx_setup_w),
    .ep2_rx_valid_o(ep2_rx_valid_w),
    .ep2_rx_space_i(ep2_rx_space_w),

    // EP2 Tx SIE Interface
    .ep2_tx_ready_i(ep2_tx_ready_w),
    .ep2_tx_data_valid_i(ep2_tx_data_valid_w),
    .ep2_tx_data_strb_i(ep2_tx_data_strb_w),
    .ep2_tx_data_i(ep2_tx_data_w),
    .ep2_tx_data_last_i(ep2_tx_data_last_w),
    .ep2_tx_data_accept_o(ep2_tx_data_accept_w),

    // EP3 Config
    .ep3_iso_i(1'b0),
    .ep3_stall_i(ep3_tx_stall_w),
    .ep3_cfg_int_rx_i(1'b0),
    .ep3_cfg_int_tx_i(1'b0),

    // EP3 Rx SIE Interface
    .ep3_rx_setup_o(ep3_rx_setup_w),
    .ep3_rx_valid_o(ep3_rx_valid_w),
    .ep3_rx_space_i(ep3_rx_space_w),

    // EP3 Tx SIE Interface
    .ep3_tx_ready_i(ep3_tx_ready_w),
    .ep3_tx_data_valid_i(ep3_tx_data_valid_w),
    .ep3_tx_data_strb_i(ep3_tx_data_strb_w),
    .ep3_tx_data_i(ep3_tx_data_w),
    .ep3_tx_data_last_i(ep3_tx_data_last_w),
    .ep3_tx_data_accept_o(ep3_tx_data_accept_w),

    // Status
    .reg_sts_rst_clr_i(1'b1),
    .reg_sts_rst_o(usb_reset_w),
    .reg_sts_frame_num_o()
);

assign ep0_rx_space_w = 1'b1;

//-----------------------------------------------------------------
// USB: Setup packet capture (limited to 8 bytes for USB-FS)
//-----------------------------------------------------------------
reg [7:0] setup_packet_q[0:7];
reg [2:0] setup_wr_idx_q;
reg       setup_frame_q;
reg       setup_valid_q;
reg       status_ready_q; // STATUS response received

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    setup_packet_q[0]  <= 8'b0;
    setup_packet_q[1]  <= 8'b0;
    setup_packet_q[2]  <= 8'b0;
    setup_packet_q[3]  <= 8'b0;
    setup_packet_q[4]  <= 8'b0;
    setup_packet_q[5]  <= 8'b0;
    setup_packet_q[6]  <= 8'b0;
    setup_packet_q[7]  <= 8'b0;
    setup_wr_idx_q     <= 3'b0;
    setup_valid_q      <= 1'b0;
    setup_frame_q      <= 1'b0;
    status_ready_q     <= 1'b0;
end
// SETUP token received
else if (ep0_rx_setup_w)
begin
    setup_packet_q[0]  <= 8'b0;
    setup_packet_q[1]  <= 8'b0;
    setup_packet_q[2]  <= 8'b0;
    setup_packet_q[3]  <= 8'b0;
    setup_packet_q[4]  <= 8'b0;
    setup_packet_q[5]  <= 8'b0;
    setup_packet_q[6]  <= 8'b0;
    setup_packet_q[7]  <= 8'b0;
    setup_wr_idx_q     <= 3'b0;
    setup_valid_q      <= 1'b0;
    setup_frame_q      <= 1'b1;
    status_ready_q     <= 1'b0;
end
// Valid DATA for setup frame
else if (ep0_rx_valid_w && rx_strb_w)
begin
    setup_packet_q[setup_wr_idx_q] <= rx_data_w;
    setup_wr_idx_q      <= setup_wr_idx_q + 3'd1;
    setup_valid_q       <= setup_frame_q && rx_last_w;
    if (rx_last_w)
        setup_frame_q   <= 1'b0;
end
// Detect STATUS stage (ACK for SETUP GET requests)
// TODO: Not quite correct .... 
else if (ep0_rx_valid_w && !rx_strb_w && rx_last_w)
begin
    setup_valid_q       <= 1'b0;
    status_ready_q      <= 1'b1;
end
else
    setup_valid_q       <= 1'b0;

//-----------------------------------------------------------------
// SETUP request decode
//-----------------------------------------------------------------
wire [7:0]  bmRequestType_w = setup_packet_q[0];
wire [7:0]  bRequest_w      = setup_packet_q[1];
wire [15:0] wValue_w        = {setup_packet_q[3], setup_packet_q[2]};
wire [15:0] wIndex_w        = {setup_packet_q[5], setup_packet_q[4]};
wire [15:0] wLength         = {setup_packet_q[7], setup_packet_q[6]};

wire setup_get_w            = setup_valid_q && (bmRequestType_w[`ENDPOINT_DIR_R] == `ENDPOINT_DIR_IN);
wire setup_set_w            = setup_valid_q && (bmRequestType_w[`ENDPOINT_DIR_R] == `ENDPOINT_DIR_OUT);
wire setup_no_data_w        = setup_set_w && (wLength == 16'b0);

// For REQ_GET_DESCRIPTOR
wire [7:0]  bDescriptorType_w  = setup_packet_q[3];
wire [7:0]  bDescriptorIndex_w = setup_packet_q[2];

//-----------------------------------------------------------------
// Process setup request
//-----------------------------------------------------------------
reg        ctrl_stall_r; // Send STALL
reg        ctrl_ack_r;   // Send STATUS (ZLP)
reg [15:0] ctrl_get_len_r;

reg [7:0]  desc_addr_r;

reg        addressed_q;
reg        addressed_r;
reg [6:0]  device_addr_r;

reg        configured_q;
reg        configured_r;

always @ *
begin
    ctrl_stall_r   = 1'b0;
    ctrl_get_len_r = 16'b0;
    ctrl_ack_r     = 1'b0;
    desc_addr_r    = 8'b0;
    device_addr_r  = device_addr_q;
    addressed_r    = addressed_q;
    configured_r   = configured_q;

    if (setup_valid_q)
    begin
        case (bmRequestType_w & `USB_REQUEST_TYPE_MASK)
        `USB_STANDARD_REQUEST:
        begin
            case (bRequest_w)
            `REQ_GET_STATUS:
            begin
                $display("GET_STATUS");
            end
            `REQ_CLEAR_FEATURE:
            begin
                $display("CLEAR_FEATURE");
                ctrl_ack_r = setup_set_w && setup_no_data_w;
            end
            `REQ_SET_FEATURE:
            begin
                $display("SET_FEATURE");
                ctrl_ack_r = setup_set_w && setup_no_data_w;
            end
            `REQ_SET_ADDRESS:
            begin
                $display("SET_ADDRESS: Set device address %d", wValue_w[6:0]);
                ctrl_ack_r    = setup_set_w && setup_no_data_w;
                device_addr_r = wValue_w[6:0];
                addressed_r   = 1'b1;
            end
            `REQ_GET_DESCRIPTOR:
            begin
                $display("GET_DESCRIPTOR: Type %d", bDescriptorType_w);

                case (bDescriptorType_w)
                `DESC_DEVICE:
                begin
                    desc_addr_r    = `ROM_DESC_DEVICE_ADDR;
                    ctrl_get_len_r = `ROM_DESC_DEVICE_SIZE;
                end
                `DESC_CONFIGURATION:
                begin
                    desc_addr_r    = `ROM_DESC_CONF_ADDR;
                    ctrl_get_len_r = `ROM_DESC_CONF_SIZE;
                end
                `DESC_STRING:
                begin
                    case (bDescriptorIndex_w)
                    `UNICODE_LANGUAGE_STR_ID:
                    begin
                        desc_addr_r    = `ROM_DESC_STR_LANG_ADDR;
                        ctrl_get_len_r = `ROM_DESC_STR_LANG_SIZE;
                    end
                    `MANUFACTURER_STR_ID:
                    begin
                        desc_addr_r    = `ROM_DESC_STR_MAN_ADDR;
                        ctrl_get_len_r = `ROM_DESC_STR_MAN_SIZE;
                    end
                    `PRODUCT_NAME_STR_ID:
                    begin
                        desc_addr_r    = `ROM_DESC_STR_PROD_ADDR;
                        ctrl_get_len_r = `ROM_DESC_STR_PROD_SIZE;
                    end
                    `SERIAL_NUM_STR_ID:
                    begin
                        desc_addr_r    = `ROM_DESC_STR_SERIAL_ADDR;
                        ctrl_get_len_r = `ROM_DESC_STR_SERIAL_SIZE;
                    end
                    default:
                        ;
                    endcase
                end
                default:
                    ;
                endcase
            end
            `REQ_GET_CONFIGURATION:
            begin
                $display("GET_CONF");
            end
            `REQ_SET_CONFIGURATION:
            begin
                $display("SET_CONF: Configuration %x", wValue_w);

                if (wValue_w == 16'd0)
                begin
                    configured_r = 1'b0;
                    ctrl_ack_r   = setup_set_w && setup_no_data_w;
                end
                // Only support one configuration for now
                else if (wValue_w == 16'd1)
                begin
                    configured_r = 1'b1;
                    ctrl_ack_r   = setup_set_w && setup_no_data_w;
                end
                else
                    ctrl_stall_r = 1'b1;
            end
            `REQ_GET_INTERFACE:
            begin
                $display("GET_INTERFACE");
                ctrl_stall_r = 1'b1;
            end
            `REQ_SET_INTERFACE:
            begin
                $display("SET_INTERFACE: %x %x", wValue_w, wIndex_w);
                if (wValue_w == 16'd0 && wIndex_w == 16'd0)
                    ctrl_ack_r   = setup_set_w && setup_no_data_w;
                else
                    ctrl_stall_r = 1'b1;
            end
            default:
            begin
                ctrl_stall_r = 1'b1;
            end
            endcase
        end
        `USB_VENDOR_REQUEST:
        begin
            // None supported
            ctrl_stall_r = 1'b1;
        end
        `USB_CLASS_REQUEST:
        begin
            case (bRequest_w)
            `CDC_GET_LINE_CODING:
            begin
                $display("CDC_GET_LINE_CODING");
                desc_addr_r    = `ROM_CDC_LINE_CODING_ADDR;
                ctrl_get_len_r = `ROM_CDC_LINE_CODING_SIZE;
            end
            default:
                ctrl_ack_r   = setup_set_w && setup_no_data_w;
            endcase
        end
        default:
        begin
            ctrl_stall_r = 1'b1;
        end
        endcase
    end
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    device_addr_q  <= 7'b0;
    addressed_q    <= 1'b0;
    configured_q   <= 1'b0;
end
else if (usb_reset_w)
begin
    device_addr_q  <= 7'b0;
    addressed_q    <= 1'b0;
    configured_q   <= 1'b0;
end
else
begin
    device_addr_q  <= device_addr_r;
    addressed_q    <= addressed_r;
    configured_q   <= configured_r;
end

//-----------------------------------------------------------------
// SETUP response
//-----------------------------------------------------------------
reg        ctrl_sending_q;
reg [15:0] ctrl_send_idx_q;
reg [15:0] ctrl_send_len_q;
wire       ctrl_send_zlp_w = ctrl_sending_q && (ctrl_send_len_q != wLength);

reg        ctrl_sending_r;
reg [15:0] ctrl_send_idx_r;
reg [15:0] ctrl_send_len_r;

reg        ctrl_txvalid_q;
reg [7:0]  ctrl_txdata_q;
reg        ctrl_txstrb_q;
reg        ctrl_txlast_q;
reg        ctrl_txstall_q;

reg        ctrl_txvalid_r;
reg [7:0]  ctrl_txdata_r;
reg        ctrl_txstrb_r;
reg        ctrl_txlast_r;
reg        ctrl_txstall_r;

wire       ctrl_send_accept_w = ep0_tx_data_accept_w || !ep0_tx_data_valid_w;

reg [7:0]  desc_addr_q;
wire[7:0]  desc_data_w;

always @ *
begin
    ctrl_sending_r  = ctrl_sending_q;
    ctrl_send_idx_r = ctrl_send_idx_q;
    ctrl_send_len_r = ctrl_send_len_q;

    ctrl_txvalid_r  = ctrl_txvalid_q;
    ctrl_txdata_r   = ctrl_txdata_q;
    ctrl_txstrb_r   = ctrl_txstrb_q;
    ctrl_txlast_r   = ctrl_txlast_q;
    ctrl_txstall_r  = ctrl_txstall_q;

    // New SETUP request
    if (setup_valid_q)
    begin
        // Send STALL
        if (ctrl_stall_r)
        begin
            ctrl_txvalid_r  = 1'b1;
            ctrl_txstrb_r   = 1'b0;
            ctrl_txlast_r   = 1'b1;
            ctrl_txstall_r  = 1'b1;
        end
        // Send STATUS response (ZLP)
        else if (ctrl_ack_r)
        begin
            ctrl_txvalid_r  = 1'b1;
            ctrl_txstrb_r   = 1'b0;
            ctrl_txlast_r   = 1'b1;
            ctrl_txstall_r  = 1'b0;
        end
        else
        begin
            ctrl_sending_r  = setup_get_w && !ctrl_stall_r;
            ctrl_send_idx_r = 16'b0;
            ctrl_send_len_r = ctrl_get_len_r;
            ctrl_txstall_r  = 1'b0;
        end
    end
    // Abort control send when STATUS received
    else if (status_ready_q)
    begin
        ctrl_sending_r  = 1'b0;
        ctrl_send_idx_r = 16'b0;
        ctrl_send_len_r = 16'b0;

        ctrl_txvalid_r  = 1'b0;
    end
    else if (ctrl_sending_r && ctrl_send_accept_w)
    begin
        // TODO: Send ZLP on exact multiple lengths...
        ctrl_txvalid_r  = 1'b1;
        ctrl_txdata_r   = desc_data_w;
        ctrl_txstrb_r   = 1'b1;
        ctrl_txlast_r   = usb_hs_w ? (ctrl_send_idx_r[5:0] == 6'b111111) : (ctrl_send_idx_r[2:0] == 3'b111);

        // Increment send index
        ctrl_send_idx_r = ctrl_send_idx_r + 16'd1;

        // TODO: Detect need for ZLP
        if (ctrl_send_idx_r == wLength)
        begin
            ctrl_sending_r = 1'b0;
            ctrl_txlast_r  = 1'b1;
        end
    end
    else if (ctrl_send_accept_w)
        ctrl_txvalid_r  = 1'b0;
end

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    ctrl_sending_q  <= 1'b0;
    ctrl_send_idx_q <= 16'b0;
    ctrl_send_len_q <= 16'b0;
    ctrl_txvalid_q  <= 1'b0;
    ctrl_txdata_q   <= 8'b0;
    ctrl_txstrb_q   <= 1'b0;
    ctrl_txlast_q   <= 1'b0;
    ctrl_txstall_q  <= 1'b0;
    desc_addr_q     <= 8'b0;
end
else if (usb_reset_w)
begin
    ctrl_sending_q  <= 1'b0;
    ctrl_send_idx_q <= 16'b0;
    ctrl_send_len_q <= 16'b0;
    ctrl_txvalid_q  <= 1'b0;
    ctrl_txdata_q   <= 8'b0;
    ctrl_txstrb_q   <= 1'b0;
    ctrl_txlast_q   <= 1'b0;
    ctrl_txstall_q  <= 1'b0;
    desc_addr_q     <= 8'b0;
end
else
begin
    ctrl_sending_q  <= ctrl_sending_r;
    ctrl_send_idx_q <= ctrl_send_idx_r;
    ctrl_send_len_q <= ctrl_send_len_r;
    ctrl_txvalid_q  <= ctrl_txvalid_r;
    ctrl_txdata_q   <= ctrl_txdata_r;
    ctrl_txstrb_q   <= ctrl_txstrb_r;
    ctrl_txlast_q   <= ctrl_txlast_r;
    ctrl_txstall_q  <= ctrl_txstall_r;

    if (setup_valid_q)
        desc_addr_q     <= desc_addr_r;
    else if (ctrl_sending_r && ctrl_send_accept_w)
        desc_addr_q     <= desc_addr_q + 8'd1;
end

assign ep0_tx_ready_w      = ctrl_txvalid_q;
assign ep0_tx_data_valid_w = ctrl_txvalid_q;
assign ep0_tx_data_strb_w  = ctrl_txstrb_q;
assign ep0_tx_data_w       = ctrl_txdata_q;
assign ep0_tx_data_last_w  = ctrl_txlast_q;
assign ep0_tx_stall_w      = ctrl_txstall_q;

//-----------------------------------------------------------------
// Descriptor ROM
//-----------------------------------------------------------------
usb_desc_rom
u_rom
(
    .hs_i(usb_hs_w),
    .addr_i(desc_addr_q),
    .data_o(desc_data_w)
);

//-----------------------------------------------------------------
// Unused Endpoints
//-----------------------------------------------------------------
assign ep1_tx_ready_w      = 1'b0;
assign ep1_tx_data_valid_w = 1'b0;
assign ep1_tx_data_strb_w  = 1'b0;
assign ep1_tx_data_w       = 8'b0;
assign ep1_tx_data_last_w  = 1'b0;
assign ep1_tx_stall_w      = 1'b0;
assign ep3_tx_ready_w      = 1'b0;
assign ep3_tx_data_valid_w = 1'b0;
assign ep3_tx_data_strb_w  = 1'b0;
assign ep3_tx_data_w       = 8'b0;
assign ep3_tx_data_last_w  = 1'b0;
assign ep3_tx_stall_w      = 1'b0;
assign ep2_tx_stall_w      = 1'b0;

assign ep2_rx_space_w      = 1'b0;
assign ep3_rx_space_w      = 1'b0;

//-----------------------------------------------------------------
// Stream I/O
//-----------------------------------------------------------------
reg       inport_valid_q;
reg [7:0] inport_data_q;
wire      inport_last_w  = !inport_valid_i;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    inport_valid_q <= 1'b0;
    inport_data_q  <= 8'b0;
end
else if (inport_accept_o)
begin
    inport_valid_q <= inport_valid_i;
    inport_data_q  <= inport_data_i;
end

assign ep2_tx_data_valid_w = inport_valid_q;
assign ep2_tx_data_w       = inport_data_q;
assign ep2_tx_ready_w      = ep2_tx_data_valid_w;
assign ep2_tx_data_strb_w  = ep2_tx_data_valid_w;
assign ep2_tx_data_last_w  = inport_last_w;
assign inport_accept_o     = !inport_valid_q | ep2_tx_data_accept_w;

assign outport_valid_o  = ep1_rx_valid_w && rx_strb_w;
assign outport_data_o   = rx_data_w;
assign ep1_rx_space_w   = outport_accept_i;



endmodule
