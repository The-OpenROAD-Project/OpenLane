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
module usb_desc_rom
(
    input        hs_i,
    input  [7:0] addr_i,
    output [7:0] data_o
);

reg [7:0] desc_rom_r;

always @ *
begin
    case (addr_i)
    8'd0: desc_rom_r = 8'h12;
    8'd1: desc_rom_r = 8'h01;
    8'd2: desc_rom_r = 8'h00;
    8'd3: desc_rom_r = 8'h02;
    8'd4: desc_rom_r = 8'h02;
    8'd5: desc_rom_r = 8'h00;
    8'd6: desc_rom_r = 8'h00;
    8'd7: desc_rom_r = hs_i ? 8'h40 : 8'h08;
    8'd8: desc_rom_r = 8'h50;  // VID_L
    8'd9: desc_rom_r = 8'h1d;  // VID_H
    8'd10: desc_rom_r = 8'h49; // PID_L 
    8'd11: desc_rom_r = 8'h61; // PID_H
    8'd12: desc_rom_r = 8'h01;
    8'd13: desc_rom_r = 8'h01;
    8'd14: desc_rom_r = 8'h00;
    8'd15: desc_rom_r = 8'h00;
    8'd16: desc_rom_r = 8'h00;
    8'd17: desc_rom_r = 8'h01;
    8'd18: desc_rom_r = 8'h09;
    8'd19: desc_rom_r = 8'h02;
    8'd20: desc_rom_r = 8'h43;
    8'd21: desc_rom_r = 8'h00;
    8'd22: desc_rom_r = 8'h02;
    8'd23: desc_rom_r = 8'h01;
    8'd24: desc_rom_r = 8'h00;
    8'd25: desc_rom_r = 8'h80;
    8'd26: desc_rom_r = 8'h32;
    8'd27: desc_rom_r = 8'h09;
    8'd28: desc_rom_r = 8'h04;
    8'd29: desc_rom_r = 8'h00;
    8'd30: desc_rom_r = 8'h00;
    8'd31: desc_rom_r = 8'h01;
    8'd32: desc_rom_r = 8'h02;
    8'd33: desc_rom_r = 8'h02;
    8'd34: desc_rom_r = 8'h01;
    8'd35: desc_rom_r = 8'h00;
    8'd36: desc_rom_r = 8'h05;
    8'd37: desc_rom_r = 8'h24;
    8'd38: desc_rom_r = 8'h00;
    8'd39: desc_rom_r = 8'h10;
    8'd40: desc_rom_r = 8'h01;
    8'd41: desc_rom_r = 8'h05;
    8'd42: desc_rom_r = 8'h24;
    8'd43: desc_rom_r = 8'h01;
    8'd44: desc_rom_r = 8'h03;
    8'd45: desc_rom_r = 8'h01;
    8'd46: desc_rom_r = 8'h04;
    8'd47: desc_rom_r = 8'h24;
    8'd48: desc_rom_r = 8'h02;
    8'd49: desc_rom_r = 8'h06;
    8'd50: desc_rom_r = 8'h05;
    8'd51: desc_rom_r = 8'h24;
    8'd52: desc_rom_r = 8'h06;
    8'd53: desc_rom_r = 8'h00;
    8'd54: desc_rom_r = 8'h01;
    8'd55: desc_rom_r = 8'h07;
    8'd56: desc_rom_r = 8'h05;
    8'd57: desc_rom_r = 8'h83;
    8'd58: desc_rom_r = 8'h03;
    8'd59: desc_rom_r = 8'h40;
    8'd60: desc_rom_r = 8'h00;
    8'd61: desc_rom_r = 8'h02;
    8'd62: desc_rom_r = 8'h09;
    8'd63: desc_rom_r = 8'h04;
    8'd64: desc_rom_r = 8'h01;
    8'd65: desc_rom_r = 8'h00;
    8'd66: desc_rom_r = 8'h02;
    8'd67: desc_rom_r = 8'h0a;
    8'd68: desc_rom_r = 8'h00;
    8'd69: desc_rom_r = 8'h00;
    8'd70: desc_rom_r = 8'h00;
    8'd71: desc_rom_r = 8'h07;
    8'd72: desc_rom_r = 8'h05;
    8'd73: desc_rom_r = 8'h01;
    8'd74: desc_rom_r = 8'h02;
    8'd75: desc_rom_r = hs_i ? 8'h00 : 8'h40;
    8'd76: desc_rom_r = hs_i ? 8'h02 : 8'h00;
    8'd77: desc_rom_r = 8'h00;
    8'd78: desc_rom_r = 8'h07;
    8'd79: desc_rom_r = 8'h05;
    8'd80: desc_rom_r = 8'h82;
    8'd81: desc_rom_r = 8'h02;
    8'd82: desc_rom_r = hs_i ? 8'h00 : 8'h40;
    8'd83: desc_rom_r = hs_i ? 8'h02 : 8'h00;
    8'd84: desc_rom_r = 8'h00;
    8'd85: desc_rom_r = 8'h04;
    8'd86: desc_rom_r = 8'h03;
    8'd87: desc_rom_r = 8'h09;
    8'd88: desc_rom_r = 8'h04;
    8'd89: desc_rom_r = 8'h1e;
    8'd90: desc_rom_r = 8'h03;
    8'd91: desc_rom_r = 8'h55;
    8'd92: desc_rom_r = 8'h00;
    8'd93: desc_rom_r = 8'h4c;
    8'd94: desc_rom_r = 8'h00;
    8'd95: desc_rom_r = 8'h54;
    8'd96: desc_rom_r = 8'h00;
    8'd97: desc_rom_r = 8'h52;
    8'd98: desc_rom_r = 8'h00;
    8'd99: desc_rom_r = 8'h41;
    8'd100: desc_rom_r = 8'h00;
    8'd101: desc_rom_r = 8'h2d;
    8'd102: desc_rom_r = 8'h00;
    8'd103: desc_rom_r = 8'h45;
    8'd104: desc_rom_r = 8'h00;
    8'd105: desc_rom_r = 8'h4d;
    8'd106: desc_rom_r = 8'h00;
    8'd107: desc_rom_r = 8'h42;
    8'd108: desc_rom_r = 8'h00;
    8'd109: desc_rom_r = 8'h45;
    8'd110: desc_rom_r = 8'h00;
    8'd111: desc_rom_r = 8'h44;
    8'd112: desc_rom_r = 8'h00;
    8'd113: desc_rom_r = 8'h44;
    8'd114: desc_rom_r = 8'h00;
    8'd115: desc_rom_r = 8'h45;
    8'd116: desc_rom_r = 8'h00;
    8'd117: desc_rom_r = 8'h44;
    8'd118: desc_rom_r = 8'h00;
    8'd119: desc_rom_r = 8'h1e;
    8'd120: desc_rom_r = 8'h03;
    8'd121: desc_rom_r = 8'h55;
    8'd122: desc_rom_r = 8'h00;
    8'd123: desc_rom_r = 8'h53;
    8'd124: desc_rom_r = 8'h00;
    8'd125: desc_rom_r = 8'h42;
    8'd126: desc_rom_r = 8'h00;
    8'd127: desc_rom_r = 8'h20;
    8'd128: desc_rom_r = 8'h00;
    8'd129: desc_rom_r = 8'h44;
    8'd130: desc_rom_r = 8'h00;
    8'd131: desc_rom_r = 8'h45;
    8'd132: desc_rom_r = 8'h00;
    8'd133: desc_rom_r = 8'h4d;
    8'd134: desc_rom_r = 8'h00;
    8'd135: desc_rom_r = 8'h4f;
    8'd136: desc_rom_r = 8'h00;
    8'd137: desc_rom_r = 8'h20;
    8'd138: desc_rom_r = 8'h00;
    8'd139: desc_rom_r = 8'h20;
    8'd140: desc_rom_r = 8'h00;
    8'd141: desc_rom_r = 8'h20;
    8'd142: desc_rom_r = 8'h00;
    8'd143: desc_rom_r = 8'h20;
    8'd144: desc_rom_r = 8'h00;
    8'd145: desc_rom_r = 8'h20;
    8'd146: desc_rom_r = 8'h00;
    8'd147: desc_rom_r = 8'h20;
    8'd148: desc_rom_r = 8'h00;
    8'd149: desc_rom_r = 8'h0e;
    8'd150: desc_rom_r = 8'h03;
    8'd151: desc_rom_r = 8'h30;
    8'd152: desc_rom_r = 8'h00;
    8'd153: desc_rom_r = 8'h30;
    8'd154: desc_rom_r = 8'h00;
    8'd155: desc_rom_r = 8'h30;
    8'd156: desc_rom_r = 8'h00;
    8'd157: desc_rom_r = 8'h30;
    8'd158: desc_rom_r = 8'h00;
    8'd159: desc_rom_r = 8'h30;
    8'd160: desc_rom_r = 8'h00;
    8'd161: desc_rom_r = 8'h30;
    8'd162: desc_rom_r = 8'h00;
    8'd163: desc_rom_r = 8'h00;
    8'd164: desc_rom_r = 8'hc2;
    8'd165: desc_rom_r = 8'h01;
    8'd166: desc_rom_r = 8'h00;
    8'd167: desc_rom_r = 8'h00;
    8'd168: desc_rom_r = 8'h00;
    8'd169: desc_rom_r = 8'h08;
    default: desc_rom_r = 8'h00;
    endcase
end

assign data_o = desc_rom_r;

endmodule
