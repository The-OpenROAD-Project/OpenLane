//`define DEBUG

// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
   
module uart_receiver (
 input             i_Clock,
 input             rst_ni,
 input             i_Rx_Serial,
 input      [15:0] CLKS_PER_BIT,
 
 output reg        o_Rx_DV,
 output reg [7:0]  o_Rx_Byte

 `ifdef DEBUG
  , output reg [15:0]    r_Clock_Count
  , output reg [2:0]     r_Bit_Index
  , output reg [2:0]     r_SM_Main
  , output reg [7:0]     r_Rx_Byte
  , output reg           r_Rx_DV
  
  , output reg           r_Rx_Data_R
  , output reg           r_Rx_Data
 `endif
);
  
parameter s_IDLE         = 3'b000;
parameter s_RX_START_BIT = 3'b001;
parameter s_RX_DATA_BITS = 3'b010;
parameter s_RX_STOP_BIT  = 3'b011;
parameter s_CLEANUP      = 3'b100;
 

`ifndef DEBUG
  reg [15:0]    r_Clock_Count;
  reg [2:0]     r_Bit_Index;
  reg [2:0]     r_SM_Main;
  reg [7:0]     r_Rx_Byte;
  reg           r_Rx_DV;

  reg           r_Rx_Data_R;
  reg           r_Rx_Data;
`endif

// Purpose: Double-register the incoming data.
// This allows it to be used in the UART RX Clock Domain.
// (It removes problems caused by metastability)
// always @(posedge i_Clock)
//   begin
//     r_Rx_Data_R <= i_Rx_Serial;
//     r_Rx_Data   <= r_Rx_Data_R;
//   end
 
 
// Purpose: Control RX state machine
always @(posedge i_Clock or negedge rst_ni)
  begin
    if (!rst_ni) begin
      r_SM_Main     <= s_IDLE;
      r_Rx_DV       <= 1'b0;
      r_Clock_Count <= 0;
      r_Bit_Index   <= 0;

      r_Rx_Byte     <= 0;

      r_Rx_Data_R   <= 1;
      r_Rx_Data     <= 1;
    end else begin

    r_Rx_Data_R <= i_Rx_Serial;
    r_Rx_Data   <= r_Rx_Data_R;

    case (r_SM_Main)
      s_IDLE :
        begin
          r_Rx_DV       <= 1'b0;
          r_Clock_Count <= 0;
          r_Bit_Index   <= 0;
           
          if (r_Rx_Data == 1'b0)          // Start bit detected
            r_SM_Main <= s_RX_START_BIT;
          else
            r_SM_Main <= s_IDLE;
        end
       
      // Check middle of start bit to make sure it's still low
      s_RX_START_BIT :
        begin
          if (r_Clock_Count == ((CLKS_PER_BIT-1)>>1))
            begin
              if (r_Rx_Data == 1'b0)
                begin
                  r_Clock_Count <= 0;  // reset counter, found the middle
                  r_SM_Main     <= s_RX_DATA_BITS;
                end
              else
                r_SM_Main <= s_IDLE;
            end
          else
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_RX_START_BIT;
            end
        end // case: s_RX_START_BIT
       
       
      // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
      s_RX_DATA_BITS :
        begin
          if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_RX_DATA_BITS;
            end
          else
            begin
              r_Clock_Count          <= 0;
              r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
               
              // Check if we have received all bits
              if (r_Bit_Index < 7)
                begin
                  r_Bit_Index <= r_Bit_Index + 1;
                  r_SM_Main   <= s_RX_DATA_BITS;
                end
              else
                begin
                  r_Bit_Index <= 0;
                  r_SM_Main   <= s_RX_STOP_BIT;
                end
            end
        end // case: s_RX_DATA_BITS
   
   
      // Receive Stop bit.  Stop bit = 1
      s_RX_STOP_BIT :
        begin
          // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= s_RX_STOP_BIT;
            end
          else
            begin
              r_Rx_DV       <= 1'b1;
              r_Clock_Count <= 0;
              r_SM_Main     <= s_CLEANUP;
            end
        end // case: s_RX_STOP_BIT
   
       
      // Stay here 1 clock
      s_CLEANUP :
        begin
          r_SM_Main <= s_IDLE;
          r_Rx_DV   <= 1'b0;
        end
       
       
      default :
        r_SM_Main <= s_IDLE;
       
    endcase
    end
  end   
 
assign o_Rx_DV   = r_Rx_DV;
assign o_Rx_Byte = r_Rx_Byte;
 
endmodule // uart_rx
