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
//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------

// Tokens
`define PID_OUT                    8'hE1
`define PID_IN                     8'h69
`define PID_SOF                    8'hA5
`define PID_SETUP                  8'h2D

// Data
`define PID_DATA0                  8'hC3
`define PID_DATA1                  8'h4B
`define PID_DATA2                  8'h87
`define PID_MDATA                  8'h0F

// Handshake
`define PID_ACK                    8'hD2
`define PID_NAK                    8'h5A
`define PID_STALL                  8'h1E
`define PID_NYET                   8'h96

// Special
`define PID_PRE                    8'h3C
`define PID_ERR                    8'h3C
`define PID_SPLIT                  8'h78
`define PID_PING                   8'hB4
