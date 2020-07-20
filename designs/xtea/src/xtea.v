//////////////////////////////////////////////////////////////////////
////                                                              ////
////  XTEA IP Core                                                ////
////                                                              ////
////  This file is part of the xtea project                       ////
////  http://www.opencores.org/projects.cgi/web/xtea/overview     ////
////                                                              ////
////  An implementation of the XTEA encryption algorithm.         ////
////                                                              ////
////  TODO:                                                       ////
////    * Write a spec                                            ////
////    * Wishbone compliance                                     ////
////                                                              ////
////  Author: David Johnson, dj@david-web.co.uk                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2006 David Johnson                             ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, write to the  ////
//// Free Software Foundation, Inc., 51 Franklin Street, Fifth    ////
//// Floor, Boston, MA  02110-1301  USA                           ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module xtea(clock, reset, mode, data_in1, data_in2, key_in, data_out1, data_out2, all_done);

parameter s0 = 8'd0, s1 = 8'd1, s2 = 8'd2, s3 = 8'd3, s4 = 8'd4, s5 = 8'd5, s6 = 8'd6, s7 = 8'd7, s8 = 8'd8, s9 = 8'd9, s10 = 8'd10,
	  s11 = 8'd11, s12 = 8'd12, s13 = 8'd13, s14 = 8'd14, s15 = 8'd15, s16 = 8'd16, s17 = 8'd17;

input clock, reset, mode;
input[31:0] data_in1, data_in2;
input[127:0] key_in;
output[31:0] data_out1, data_out2;
output all_done;

wire clock, reset;
wire[31:0] data_in1, data_in2;
wire[127:0] key_in;
reg all_done, while_flag, modereg;
reg[1:0] selectslice;
reg[7:0] state;
reg[7:0] x;
reg[31:0] data_out1, data_out2, sum, workunit1, workunit2, delta;

always @(posedge clock or posedge reset)
begin
	if (reset)
		//reset state
		state = s0;
	else begin
		case (state)
			s0: state = s1;
			s1: state = s2;
			s2: state = s3;
			s3: state = while_flag ? s4 : s14;
			s4: state = modereg ? s10 : s5;
			s5: state = s6;
			s6: state = s7;
			s7: state = s8;
			s8: state = s9;
			s9: state = s2;
			s10: state = s11;
			s11: state = s12;
			s12: state = s13;
			s13: state = s14;
			s14: state = s2;
			s15: state = s16;
			s16: state = s17;
			s17: state = s17;
			default: state = 4'bxxxx;
		endcase
	end
end

always @(posedge clock or posedge reset)
begin
	if (reset) begin
		//reset all our outputs and registers
		data_out1 = 32'h00000000;
		data_out2 = 32'h00000000;
		x = 8'b00000000;
		sum = 32'h00000000;
		while_flag = 1'b0;
		workunit1 = 32'h00000000;
		workunit2 = 32'h00000000;
		selectslice = 1'b0;
		all_done = 1'b0;
		delta = 32'h00000000;
		modereg = 1'b0;
	end
	else begin
		case (state)
			s1: begin
			    //store input values to registers in case they're not stable
			    workunit1 = data_in1;
			    workunit2 = data_in2;
			    delta = 32'h9E3779B9;
			    sum = 32'hc6ef3720;
			    modereg = mode;
			    end
			s2: if (x < 8'd32) while_flag = 1'b1; else while_flag = 1'b0;
			s3: begin
			    //This null state was necessary to fix a timing issue.
			    //s2 sets while_flag and previously the control path read it in the same state
			    //(but in the next clock cycle), however the reg wasn't set when we tried to
			    //read it, so this state was inserted to add a delay. This was when running @25MHz.
			    //FIXME: there's got to be a better solution to this...
			    end
			s4: begin
			    //This state does nothing in the data path; it's used for an if statement in the
			    //control path.
			end
			/* States 5-9 used for decipher operations */
			s5: selectslice = (sum >> 32'd11 & 32'd3);
			s6: case (selectslice)
				2'b00: workunit2 = workunit2 - (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[127:96]));
				2'b01: workunit2 = workunit2 - (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[95:64]));
				2'b10: workunit2 = workunit2 - (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[63:32]));
				2'b11: workunit2 = workunit2 - (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[31:0]));
				default: workunit2 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			    endcase
			s7: sum = sum - delta;
			s8: selectslice = (sum & 32'd3);
			s9: begin
			    case (selectslice)
			    	2'b00: workunit1 = workunit1 - (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[127:96]));
				2'b01: workunit1 = workunit1 - (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[95:64]));
				2'b10: workunit1 = workunit1 - (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[63:32]));
				2'b11: workunit1 = workunit1 - (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[31:0]));
				default: workunit1 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			    endcase
			    x = x + 1'b1;
			    end
			/* States 10-14 used for encipher operations */
			s10: selectslice = (sum & 32'd3);
                        s11: case (selectslice)
                                2'b00: workunit1 = workunit1 + (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[127:96]));
                                2'b01: workunit1 = workunit1 + (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[95:64]));
                                2'b10: workunit1 = workunit1 + (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[63:32]));
                                2'b11: workunit1 = workunit1 + (((workunit2 << 4 ^ workunit2 >> 5) + workunit2) ^ (sum + key_in[31:0]));
                                default: workunit1 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                            endcase
                        s12: sum = sum + delta;
                        s13: selectslice = (sum >> 32'd11 & 32'd3);
                        s14: begin
                            case (selectslice)
                                2'b00: workunit2 = workunit2 + (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[127:96]));
                                2'b01: workunit2 = workunit2 + (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[95:64]));
                                2'b10: workunit2 = workunit2 + (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[63:32]));
	                        2'b11: workunit2 = workunit2 + (((workunit1 << 4 ^ workunit1 >> 5) + workunit1) ^ (sum + key_in[31:0]));
                                default: workunit2 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
                            endcase
                            x = x + 1'b1;
                            end
			 s15: begin
			       //This state was added to fix a timing issue.
			       //Same issue as above - trying to read workunit1 & workunit2 before they've settled.
			       end
			 s16: begin
			     //set the outputs to the working registers
			     data_out1 = workunit1;
			     data_out2 = workunit2;
			     end
			 s17: all_done = 1'b1;
			 default: begin
			     data_out1 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			     data_out2 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			     end
		 endcase
	end
end

endmodule
