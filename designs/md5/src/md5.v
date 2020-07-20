//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 implementation                                          ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 implementation                                          ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
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
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $

`timescale 10ns/1ns



module md5(clk,reset,load_i,ready_o,newtext_i,data_i,data_o);	

input clk;
input reset;
input load_i;
output ready_o;
input newtext_i;
	
	
//Input must be padded and in little endian mode
input [127:0] data_i;
output [127:0] data_o;

reg ready_o, next_ready_o;
reg [127:0] data_o, next_data_o;

reg [5:0] round64, next_round64;
reg [43:0] t;


reg [31:0] ar,br,cr,dr,func_out, next_ar,next_br, next_cr, next_dr;
reg [31:0] A,B,C,D,next_A,next_B, next_C, next_D;
reg [511:0] message, next_message;
reg [2:0] round,next_round;
reg next_generate_hash,generate_hash;
reg hash_generated;

reg [2:0] next_getdata_state, getdata_state;

//rom process
always @(round64)
begin
	
   case(round64)
         0: t = 44'hD76AA478070; 
         1: t = 44'hE8C7B7560C1; 		
         2: t = 44'h242070DB112; 
         3: t = 44'hC1BDCEEE163; 
         4: t = 44'hF57C0FAF074; 
         5: t = 44'h4787C62A0C5; 
         6: t = 44'hA8304613116; 
         7: t = 44'hFD469501167; 
         8: t = 44'h698098D8078; 		
         9: t = 44'h8B44F7AF0C9; 
         10: t = 44'hFFFF5BB111A; 
         11: t = 44'h895CD7BE16B; 
         12: t = 44'h6B90112207C; 
         13: t = 44'hFD9871930CD; 
         14: t = 44'hA679438E11E; 
         15: t = 44'h49B4082116F; 		
	   
         16: t = 44'hf61e2562051; 
         17: t = 44'hc040b340096; 
         18: t = 44'h265e5a510EB; 
         19: t = 44'he9b6c7aa140; 
         20: t = 44'hd62f105d055; 
         21: t = 44'h0244145309A; 
         22: t = 44'hd8a1e6810EF; 		
         23: t = 44'he7d3fbc8144; 
         24: t = 44'h21e1cde6059; 
         25: t = 44'hc33707d609E; 
         26: t = 44'hf4d50d870E3; 
         27: t = 44'h455a14ed148; 
         28: t = 44'ha9e3e90505D; 
         29: t = 44'hfcefa3f8092; 		
         30: t = 44'h676f02d90E7; 
         31: t = 44'h8d2a4c8a14C; 
		   
         32: t = 44'hfffa3942045; 
         33: t = 44'h8771f6810B8; 
         34: t = 44'h6d9d612210B; 
         35: t = 44'hfde5380c17E; 
         36: t = 44'ha4beea44041; 		
         37: t = 44'h4bdecfa90B4; 
         38: t = 44'hf6bb4b60107; 
         39: t = 44'hbebfbc7017A; 
         40: t = 44'h289b7ec604D; 
         41: t = 44'heaa127fa0B0; 
         42: t = 44'hd4ef3085103; 
         43: t = 44'h04881d05176; 		
         44: t = 44'hd9d4d039049; 
         45: t = 44'he6db99e50BC; 
         46: t = 44'h1fa27cf810F; 
         47: t = 44'hc4ac5665172; 
		   
         48: t = 44'hf4292244060; 
         49: t = 44'h432aff970A7; 
         50: t = 44'hab9423a70FE; 		
         51: t = 44'hfc93a039155; 
         52: t = 44'h655b59c306C; 
         53: t = 44'h8f0ccc920A3; 
         54: t = 44'hffeff47d0FA; 
         55: t = 44'h85845dd1151; 
         56: t = 44'h6fa87e4f068; 
         57: t = 44'hfe2ce6e00AF; 		
         58: t = 44'ha30143140F6; 
         59: t = 44'h4e0811a115D; 
         60: t = 44'hf7537e82064; 
         61: t = 44'hbd3af2350AB; 
         62: t = 44'h2ad7d2bb0F2; 
         63: t = 44'heb86d391159;		 
    endcase
end
//end process rom


//funcs process


reg [31:0] aux31,fr_var,tr_var,rotate1,rotate2;	
reg [7:0] s_var;	
reg [3:0] nblock;
reg [31:0] message_var[15:0];	
   
always @(t or ar or br or cr or dr or round or message or func_out or message_var[0] or message_var[1] or message_var[2] or message_var[3] 
         or message_var[4] or message_var[5] or message_var[6] or message_var[7] or message_var[8] or message_var[9] or message_var[10]
         or message_var[11] or message_var[12] or message_var[13] or message_var[14] or message_var[15])
begin

   message_var[0]=message[511:480]; 
   message_var[1]=message[479:448]; 
   message_var[2]=message[447:416]; 
   message_var[3]=message[415:384]; 
   message_var[4]=message[383:352]; 
   message_var[5]=message[351:320]; 
   message_var[6]=message[319:288]; 
   message_var[7]=message[287:256]; 
   message_var[8]=message[255:224]; 
   message_var[9]=message[223:192]; 
   message_var[10]=message[191:160]; 
   message_var[11]=message[159:128]; 
   message_var[12]=message[127:96]; 
   message_var[13]=message[95:64]; 
   message_var[14]=message[63:32]; 
   message_var[15]=message[31:0];
	
   fr_var=0;	
	
   case(round)
      0: fr_var=((br&cr)|(~br&dr));
      1: fr_var=((br&dr)|(cr& (~dr)));
      2: fr_var=(br^cr^dr);
      3: fr_var=(cr^(br|~dr));
   endcase
   
  
   tr_var=t[43:12];
   s_var=t[11:4];
   nblock=t[3:0];
   
   aux31=(ar+fr_var+message_var[nblock]+tr_var);
       
   rotate1=aux31 << s_var;
   rotate2=aux31 >> (32-s_var);
   func_out=br+(rotate1 | rotate2);
   
end
//end process funcs


//process round64FSM
always @(newtext_i or round or round64 or ar or br or cr or dr or generate_hash or func_out or getdata_state or A or B or C or D)
begin

      next_ar=ar;
      next_br=br;
      next_cr=cr;
      next_dr=dr;
      next_round64=round64;
      next_round=round;	
      hash_generated=0;
	
      if(generate_hash!=0)
      begin	
        next_ar=dr;		  
        next_br=func_out;
        next_cr=br; 
        next_dr=cr;
      end
			
      case(round64)
        0:
        begin
          next_round=0;
          if(generate_hash) next_round64=1;
        end 
	
        15,31,47:
        begin
          next_round=round+1;
          next_round64=round64+1;
        end

        63:
        begin
          next_round=0;
          next_round64=0;
          hash_generated=1;
        end
	
        default: next_round64=round64+1;

    endcase	  
	

    if(newtext_i)
    begin
      next_ar=32'h67452301;
      next_br=32'hEFCDAB89;
      next_cr=32'h98BADCFE;
      next_dr=32'h10325476;
      next_round=0;
      next_round64=0;		
    end
	
    if(!getdata_state)
    begin
      next_ar=A;
      next_br=B;
      next_cr=C;
      next_dr=D;
    end
	
end
//end round64FSM process

//regsignal process
always @(posedge clk or negedge reset)
begin

   if(!reset)
   begin
     ready_o=0;
     data_o=0;  
     message=0;

     ar=32'h67452301;
     br=32'hEFCDAB89;
     cr=32'h98BADCFE;
     dr=32'h10325476;
	 
     getdata_state=0;  
     generate_hash=0;
	 
     round=0;
     round64=0;	 
     A=32'h67452301;
     B=32'hEFCDAB89;
     C=32'h98BADCFE;
     D=32'h10325476;

   end 	   
   else
   begin
     ready_o=next_ready_o;
     data_o=next_data_o;
     message=next_message;
	 
     ar=next_ar;	   
     br=next_br;
     cr=next_cr;
     dr=next_dr;
	 
     A=next_A;	   
     B=next_B;
     C=next_C;
     D=next_D;
	 
     generate_hash=next_generate_hash;  
     getdata_state=next_getdata_state;
	 
     round=next_round;
     round64=next_round64;
   end
end   
//end regsignals process
	
   
//getdata process

reg [127:0] data_o_var;
reg [511:0] aux; 
wire [31:0] A_t,B_t,C_t,D_t;

assign A_t=dr+A;
assign B_t=func_out+B;
assign C_t=br+C;
assign D_t=cr+D; 

always @(newtext_i or A_t or B_t or C_t or D_t or data_i or load_i or getdata_state or generate_hash or hash_generated or message or func_out or A or B or C or D or ar or br or cr or dr)
begin

   next_A=A;	
   next_B=B;
   next_C=C;
   next_D=D;
	
   next_generate_hash=generate_hash;
   next_ready_o=0;
   next_getdata_state=getdata_state;

   next_data_o=0;
   aux=message;	
   next_message=message;
	
   if(newtext_i)
   begin
     next_A=32'h67452301;
     next_B=32'hEFCDAB89;
     next_C=32'h98BADCFE;
     next_D=32'h10325476;
     next_getdata_state=0;
   end
	
   case(getdata_state)

      0 :
      begin
        if(load_i)
        begin
          aux[511:384]=data_i;	 
          next_message=aux;
          next_getdata_state=1;
        end
      end
		 
      1 :
      begin
       if(load_i)
       begin
         aux[383:256]=data_i;	 
         next_message=aux;
         next_getdata_state=2;
       end
      end
		 
      2 :
      begin 
       if(load_i) 
       begin
         aux[255:128]=data_i;	 
         next_message=aux;
         next_getdata_state=3;
       end
      end
	
      3 :
      begin
        if(load_i)
        begin
          aux[127:0]=data_i;	 
          next_message=aux;
          next_getdata_state=4;
          next_generate_hash=1;
        end
      end
	  
	  4 :
      begin
	  
	    next_generate_hash=1;
	  	      	  
        data_o_var[127:96]=A_t;
        data_o_var[95:64]=B_t;
        data_o_var[63:32]=C_t;
        data_o_var[31:0]=D_t;
        next_data_o=data_o_var;
	  
        if(hash_generated)
        begin
		  next_A=A_t;
          next_B=B_t;
          next_C=C_t;
          next_D=D_t;
          next_getdata_state=0;
          next_ready_o=1;
          next_generate_hash=0;
        end
      end
   endcase
end
//end getdata process
	

endmodule

