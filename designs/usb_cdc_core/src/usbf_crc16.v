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

module usbf_crc16
(
    // Inputs
     input  [ 15:0]  crc_in_i
    ,input  [  7:0]  din_i

    // Outputs
    ,output [ 15:0]  crc_out_o
);



//-----------------------------------------------------------------
// Logic
//-----------------------------------------------------------------
assign crc_out_o[15] =    din_i[0] ^ din_i[1] ^ din_i[2] ^ din_i[3] ^ din_i[4] ^ din_i[5] ^ din_i[6] ^ din_i[7] ^ 
                        crc_in_i[7] ^ crc_in_i[6] ^ crc_in_i[5] ^ crc_in_i[4] ^ crc_in_i[3] ^ crc_in_i[2] ^ crc_in_i[1] ^ crc_in_i[0];
assign crc_out_o[14] =    din_i[0] ^ din_i[1] ^ din_i[2] ^ din_i[3] ^ din_i[4] ^ din_i[5] ^ din_i[6] ^
                        crc_in_i[6] ^ crc_in_i[5] ^ crc_in_i[4] ^ crc_in_i[3] ^ crc_in_i[2] ^ crc_in_i[1] ^ crc_in_i[0];
assign crc_out_o[13] =    din_i[6] ^ din_i[7] ^ 
                        crc_in_i[7] ^ crc_in_i[6];
assign crc_out_o[12] =    din_i[5] ^ din_i[6] ^ 
                        crc_in_i[6] ^ crc_in_i[5];
assign crc_out_o[11] =    din_i[4] ^ din_i[5] ^ 
                        crc_in_i[5] ^ crc_in_i[4];
assign crc_out_o[10] =    din_i[3] ^ din_i[4] ^ 
                        crc_in_i[4] ^ crc_in_i[3];
assign crc_out_o[9] =     din_i[2] ^ din_i[3] ^ 
                        crc_in_i[3] ^ crc_in_i[2];
assign crc_out_o[8] =     din_i[1] ^ din_i[2] ^ 
                        crc_in_i[2] ^ crc_in_i[1];
assign crc_out_o[7] =     din_i[0] ^ din_i[1] ^ 
                        crc_in_i[15] ^ crc_in_i[1] ^ crc_in_i[0];
assign crc_out_o[6] =     din_i[0] ^ 
                        crc_in_i[14] ^ crc_in_i[0];
assign crc_out_o[5] =     crc_in_i[13];
assign crc_out_o[4] =     crc_in_i[12];
assign crc_out_o[3] =     crc_in_i[11];
assign crc_out_o[2] =     crc_in_i[10];
assign crc_out_o[1] =     crc_in_i[9];
assign crc_out_o[0] =     din_i[0] ^ din_i[1] ^ din_i[2] ^ din_i[3] ^ din_i[4] ^ din_i[5] ^ din_i[6] ^ din_i[7] ^
                        crc_in_i[8] ^ crc_in_i[7] ^ crc_in_i[6] ^ crc_in_i[5] ^ crc_in_i[4] ^ crc_in_i[3] ^ crc_in_i[2] ^ crc_in_i[1] ^ crc_in_i[0];


endmodule
