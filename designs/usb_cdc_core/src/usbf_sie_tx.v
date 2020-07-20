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

module usbf_sie_tx
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           enable_i
    ,input           chirp_i
    ,input           utmi_txready_i
    ,input           tx_valid_i
    ,input  [  7:0]  tx_pid_i
    ,input           data_valid_i
    ,input           data_strb_i
    ,input  [  7:0]  data_i
    ,input           data_last_i

    // Outputs
    ,output [  7:0]  utmi_data_o
    ,output          utmi_txvalid_o
    ,output          tx_accept_o
    ,output          data_accept_o
);



//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
`include "usbf_defs.v"

localparam STATE_W                       = 3;
localparam STATE_TX_IDLE                 = 3'd0;
localparam STATE_TX_PID                  = 3'd1;
localparam STATE_TX_DATA                 = 3'd2;
localparam STATE_TX_CRC1                 = 3'd3;
localparam STATE_TX_CRC2                 = 3'd4;
localparam STATE_TX_DONE                 = 3'd5;
localparam STATE_TX_CHIRP                = 3'd6;

reg [STATE_W-1:0] state_q;
reg [STATE_W-1:0] next_state_r;

//-----------------------------------------------------------------
// Wire / Regs
//-----------------------------------------------------------------
reg last_q;

//-----------------------------------------------------------------
// Request Type
//-----------------------------------------------------------------
reg data_pid_q;
reg data_zlp_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    data_pid_q <= 1'b0;
    data_zlp_q <= 1'b0;
end
else if (!enable_i)
begin
    data_pid_q <= 1'b0;
    data_zlp_q <= 1'b0;
end
else if (tx_valid_i && tx_accept_o)
begin
    case (tx_pid_i)

    `PID_MDATA, `PID_DATA2, `PID_DATA0, `PID_DATA1:
    begin
        data_pid_q <= 1'b1;
        data_zlp_q <= data_valid_i && (data_strb_i == 1'b0) && data_last_i;
    end

    default :
    begin
        data_pid_q <= 1'b0;
        data_zlp_q <= 1'b0;
    end
    endcase
end
else if (next_state_r == STATE_TX_CRC1)
begin
    data_pid_q <= 1'b0;
    data_zlp_q <= 1'b0;
end

assign tx_accept_o = (state_q == STATE_TX_IDLE);

//-----------------------------------------------------------------
// Next state
//-----------------------------------------------------------------
always @ *
begin
    next_state_r = state_q;

    //-----------------------------------------
    // State Machine
    //-----------------------------------------
    case (state_q)

    //-----------------------------------------
    // IDLE
    //-----------------------------------------
    STATE_TX_IDLE :
    begin
        if (chirp_i)
            next_state_r  = STATE_TX_CHIRP;
        else if (tx_valid_i)
            next_state_r  = STATE_TX_PID;
    end

    //-----------------------------------------
    // TX_PID
    //-----------------------------------------
    STATE_TX_PID :
    begin
        // Data accepted
        if (utmi_txready_i)
        begin
            if (data_zlp_q)
                next_state_r = STATE_TX_CRC1;
            else if (data_pid_q)
                next_state_r = STATE_TX_DATA;
            else
                next_state_r = STATE_TX_DONE;
        end
    end

    //-----------------------------------------
    // TX_DATA
    //-----------------------------------------
    STATE_TX_DATA :
    begin
        // Data accepted
        if (utmi_txready_i)
        begin
            // Generate CRC16 at end of packet
            if (data_last_i)
                next_state_r  = STATE_TX_CRC1;
        end
    end

    //-----------------------------------------
    // TX_CRC1 (first byte)
    //-----------------------------------------
    STATE_TX_CRC1 :
    begin
        // Data sent?
        if (utmi_txready_i)
            next_state_r  = STATE_TX_CRC2;
    end

    //-----------------------------------------
    // TX_CRC (second byte)
    //-----------------------------------------
    STATE_TX_CRC2 :
    begin
        // Data sent?
        if (utmi_txready_i)
            next_state_r  = STATE_TX_DONE;
    end

    //-----------------------------------------
    // TX_DONE
    //-----------------------------------------
    STATE_TX_DONE :
    begin
        // Data sent?
        if (!utmi_txvalid_o || utmi_txready_i)
            next_state_r  = STATE_TX_IDLE;
    end

    //-----------------------------------------
    // TX_CHIRP
    //-----------------------------------------
    STATE_TX_CHIRP :
    begin
        if (!chirp_i)
            next_state_r  = STATE_TX_IDLE;
    end

    default :
       ;

    endcase

    // USB reset but not chirping...
    if (!enable_i && !chirp_i)
        next_state_r  = STATE_TX_IDLE;
end

// Update state
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    state_q   <= STATE_TX_IDLE;
else
    state_q   <= next_state_r;

//-----------------------------------------------------------------
// Data Input
//-----------------------------------------------------------------
reg       input_valid_r;
reg [7:0] input_byte_r;
reg       input_last_r;
always @ *
begin
    input_valid_r = data_strb_i & data_pid_q;
    input_byte_r  = data_i;
    input_last_r  = data_last_i;
end

reg data_accept_r;
always @ *
begin
    if (state_q == STATE_TX_DATA)
        data_accept_r = utmi_txready_i;
    else if (state_q == STATE_TX_PID && data_zlp_q)
        data_accept_r = utmi_txready_i;
    else
        data_accept_r = 1'b0;
end

assign data_accept_o = data_accept_r;

//-----------------------------------------------------------------
// CRC16: Generate CRC16 on outgoing data
//-----------------------------------------------------------------
reg [15:0]  crc_sum_q;
wire [15:0] crc_out_w;
reg         crc_err_q;

usbf_crc16
u_crc16
(
    .crc_in_i(crc_sum_q),
    .din_i(utmi_data_o),
    .crc_out_o(crc_out_w)
);

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    crc_sum_q   <= 16'hFFFF;
else if (state_q == STATE_TX_IDLE)
    crc_sum_q   <= 16'hFFFF;
else if (state_q == STATE_TX_DATA && utmi_txvalid_o && utmi_txready_i)
    crc_sum_q   <= crc_out_w;

//-----------------------------------------------------------------
// Output
//-----------------------------------------------------------------
reg       valid_q;
reg [7:0] data_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    valid_q <= 1'b0;
    data_q  <= 8'b0;
    last_q  <= 1'b0;
end
else if (!enable_i)
begin
    valid_q <= 1'b0;
    data_q  <= 8'b0;
    last_q  <= 1'b0;
end
else if (tx_valid_i && tx_accept_o)
begin
    valid_q <= 1'b1;
    data_q  <= tx_pid_i;
    last_q  <= 1'b0;
end
else if (utmi_txready_i)
begin
    valid_q <= 1'b0;
    data_q  <= 8'b0;
    last_q  <= 1'b0;
end

reg       utmi_txvalid_r;
reg [7:0] utmi_data_r;

always @ *
begin
    if (state_q == STATE_TX_CHIRP)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = 8'b0;
    end
    else if (state_q == STATE_TX_CRC1)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = crc_sum_q[7:0] ^ 8'hFF;
    end
    else if (state_q == STATE_TX_CRC2)
    begin
        utmi_txvalid_r = 1'b1;
        utmi_data_r    = crc_sum_q[15:8] ^ 8'hFF;
    end
    else if (state_q == STATE_TX_DATA)
    begin
        utmi_txvalid_r = data_valid_i;
        utmi_data_r    = data_i;
    end
    else
    begin
        utmi_txvalid_r = valid_q;
        utmi_data_r    = data_q;
    end
end

assign utmi_txvalid_o = utmi_txvalid_r;
assign utmi_data_o    = utmi_data_r;


endmodule
