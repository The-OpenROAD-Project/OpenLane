// file: CPU.v
// author: @tasneem_ismail

`timescale 1ns/1ns
module CPU(clk, rst, Wupdated, W, Result, counter, Instruction, value, Bit, flags);

input clk;
input rst;
input [7:0] W;
output [7:0] Wupdated;
output [7:0] Result;

reg [7:0] PC;
reg [7:0] Data;
reg [7:0] res;
wire [13:0] Ins;
reg[7:0] F;
reg [7:0] Out;
reg RW;
output [7:0] value;
reg f;
output [7:0]counter;
output [13:0] Instruction;
output Bit;
output [6:0] flags;
wire Flag1, Flag3;
reg flag, flag1, flag2;
wire flag3;
wire Flagg2;

always@(posedge clk) begin
	if(!rst)begin
		PC=8'b00000000;
		flag=1'b1;
		f=1'b1;
	end
	else if((Ins[7]==1 && Ins[13:12]==2'b00)|Ins[13:12]==2'b01)begin //read then write on two cycles
		if(f)begin
			RW=0;
			Data=8'b00000000;
			F=value;
			#20flag1=Flag1;
			flag2=1'b0;
			f=1'b0;
		end
		else begin //!f
			RW=1;
			Data=Result;
			#20flag2=flag3;
			flag1=1'b0;
			f=1'b1;
		end
	end
	else begin
		RW=0;
		F=8'b00000000;
		flag1=1'b0;
		flag2=1'b0;
	end
	if(Flag3==1)begin
		if(PC<20)
			PC=PC+1;
	end
	
end

	InsMem insMem (flag, clk,rst, PC, Ins, Flag1);
	
	RAM read (flag1, clk, rst, RW,{8'b00000,Z,DC,C}, Ins[6:0],Data, value, Flagg2);

	ALU alu(Flagg2, clk, Ins, W, F, Result, Wupdated, C, DC,Z, flag3);

	RAM write (flag2, clk, rst, RW,{8'b00000,Z,DC,C}, Ins[6:0], Data, , Flag3);
	
assign flags={Flag1,Flagg2,Flag3, flag, flag1,flag2,flag3};
assign Bit=RW;
assign counter=PC;
assign Instruction=Ins;
endmodule