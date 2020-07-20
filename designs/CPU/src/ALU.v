// file: ALU.v
// author: @tasneem_ismail

`timescale 1ns/1ns
module ALU(FFlag2,clk, Ins, W, F, Out, Wupdated,C,DC,Z, FFlag3);
input clk;
input FFlag2;
input [13:0] Ins;
input [7:0] W;//working register
input [7:0] F;
output reg [7:0] Out;
output reg [7:0] Wupdated;
output reg C,DC,Z;
output reg FFlag3;

reg [2:0] Reg;
reg [8:0] Sum1;//test
reg [7:0] inp1;
reg [8:0] Sum2;//test
reg [7:0] w;
reg [7:0] f;
reg c1,c2;
reg flag;

always @(posedge clk) begin
if(FFlag2)begin
	case(Ins[13:12]) 
		2'b00:begin //Byte-Oriented
			case(Ins[11:8])
				4'b0111://ADDWF
					begin
						Out=F+W;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						Sum1={1'b0,F}+{1'b0,W};
						C = Sum1[8]; //C bit
						DC = Sum1[4]^F[4]^W[4]; //DC bit
						end
				4'b0101://ANDWF
					begin
						Out=F&W;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
				4'b1010://INCF
					begin
						Out=F+8'b00000001;;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
				4'b0100://IORWF
					begin
						Out=F|W;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
				4'b0011://DECF
					begin
					Out=F-8'b00000001;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
				4'b1001://COMF
					begin
						Out=~F;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
				4'b0010://SUBWF
					begin
					Out=F-W;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						
						inp1 = (~W)+1;//two's complement
						Sum2={1'b0,F}+{1'b0,inp1};
						C = Sum2[8]; //C bit
						DC = Sum2[4]^F[4]^inp1[4]; //DC bit
						end
				4'b0110://XORWF
					begin
						Out=F^W;
						if(!Ins[7])
							Wupdated=Out;
						else
							Wupdated=W;
						
						Z = (Out==8'b00000000);
						end
			endcase
		end
		2'b01:begin //Bit-Oriented
			case(Ins[11:10])
				2'b00:begin //BCF
					f=8'b11111111;
					f[Ins[9:7]] = 1'b0; 
					Out= f & F; end
				2'b01:begin //BSF
					f=8'b00000000;
					f[Ins[9:7]] = 1'b1; 
					Out= f | F;end
			endcase
		end
		2'b11:begin //Literal&Control
			case(Ins[11:8])
				4'b1111:begin //ADDLW
						Out = F+W;
						Z = (Out==8'b00000000);
						
						Sum1={1'b0,F}+{1'b0,W};
						C = Sum1[8]; //C bit
						DC = Sum1[4]^F[4]^W[4]; //DC bit
						end
				4'b1001:begin //ANDLW
						Out = F&W;
						Z = (Out==8'b00000000);end
				4'b1000:begin //IORLW
						Out = F|W;
						Z = (Out==8'b00000000);end
				4'b1101:begin //SUBLW
						Out = F-W;
						Z = (Out==8'b00000000);
						
						inp1 = (~W)+1;//two's complement
						Sum2={1'b0,F}+{1'b0,inp1};
						C = Sum2[8]; //C bit
						DC = Sum2[4]^F[4]^inp1[4]; //DC bit
						end
				4'b1010:begin //XORLW
						Out = F^W;
						Z = (Out==8'b00000000);end
			endcase
			end		
	endcase
	
end
 FFlag3<=1;
end

endmodule

